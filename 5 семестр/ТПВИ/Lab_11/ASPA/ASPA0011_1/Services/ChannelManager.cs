using System.Collections.Concurrent;
using System.Threading.Channels;
using ASPA0011_1.Models;

namespace ASPA0011_1.Services
{
    public class ChannelManager
    {
        private readonly ConcurrentDictionary<Guid, ChannelInfo> _channels = new();
        private readonly ILogger<ChannelManager> _logger;
        private readonly TimeSpan _waitEnqueue;

        public ChannelManager(ILogger<ChannelManager> logger, IConfiguration config)
        {
            _logger = logger;

            int waitSec = config.GetValue<int>("WaitEnqueue", 5);
            _waitEnqueue = TimeSpan.FromSeconds(waitSec);
        }


        public IEnumerable<ChannelInfo> GetAll() => _channels.Values;


        public ChannelInfo? Get(Guid id) =>
            _channels.TryGetValue(id, out var ch) ? ch : null;


        public ChannelInfo Create(Guid id, string name, string desc, string state)
        {
            var ch = new ChannelInfo
            {
                Id = id,
                Name = name,
                Description = desc,
                Channel = Channel.CreateUnbounded<string>(),
                State = state
            };

            _channels[ch.Id] = ch;
            _logger.LogInformation($"[CREATE] Channel {ch.Name} ({ch.Id}) created");

            return ch;
        }


        public void Close(Guid? id = null, string reason = "")
        {
            var channels = id.HasValue ? _channels.Where(c => c.Key == id.Value) : _channels;

            foreach (var kv in channels)
            {
                var ch = kv.Value;

                if (ch.State == "CLOSED")
                {
                    _logger.LogWarning($"[CLOSE] Channel {ch.Id} already closed");
                    continue;
                }

                ch.State = "CLOSED";
                //ch.Channel?.Writer.Complete();

                _logger.LogInformation($"[CLOSE] Channel {ch.Id} closed: {reason}");
            }
        }


        public void Open(Guid? id = null)
        {
            var channels = id.HasValue ? _channels.Where(c => c.Key == id.Value) : _channels;

            foreach (var kv in channels)
            {
                var ch = kv.Value;

                if (ch.State == "ACTIVE")
                {
                    _logger.LogWarning($"[OPEN] Channel {ch.Id} already active");
                    continue;
                }

                ch.State = "ACTIVE";
                //ch.Channel = Channel.CreateUnbounded<string>();

                _logger.LogInformation($"[OPEN] Channel {ch.Id} reopened");
            }
        }


        public bool Delete(Guid? id = null, string? state = null)
        {
            if (id.HasValue)
            {
                if (_channels.TryGetValue(id.Value, out var ch))
                {
                    if (!string.IsNullOrEmpty(state) && ch.State != state)
                    {
                        _logger.LogWarning($"[DELETE] Channel {id.Value} skipped: state is {ch.State}, expected {state}");
                        return false;
                    }

                    if (_channels.TryRemove(id.Value, out _))
                    {
                        _logger.LogInformation($"[DELETE] Channel {id.Value} deleted");
                        return true;
                    }

                    return false;
                }

                _logger.LogError($"[DELETE] Channel {id.Value} not found");
                return false;
            }


            IEnumerable<KeyValuePair<Guid, ChannelInfo>> channelsToDelete;

            if (string.IsNullOrEmpty(state))
            {
                channelsToDelete = _channels.ToList();
            }
            else
            {
                channelsToDelete = _channels
                    .Where(c => c.Value.State.Equals(state, StringComparison.OrdinalIgnoreCase))
                    .ToList();
            }

            bool anyDeleted = false;

            foreach (var pair in channelsToDelete)
            {
                if (_channels.TryRemove(pair.Key, out _))
                {
                    _logger.LogInformation($"[DELETE] Channel {pair.Key} deleted");
                    anyDeleted = true;
                }
            }

            return anyDeleted;
        }


        public async Task<string?> Enqueue(Guid id, string data)
        {
            if (_channels.TryGetValue(id, out var ch))
            {
                if (ch.State != "ACTIVE")
                {
                    _logger.LogWarning($"[ENQUEUE] Channel {id} is closed");
                    return null;
                }

                var writer = ch.Channel!.Writer;
                using var cts = new CancellationTokenSource(_waitEnqueue);

                try
                {
                    await writer.WriteAsync(data, cts.Token);

                    _logger.LogDebug($"[ENQUEUE] Message added to {id}");
                    return data;
                }
                catch (OperationCanceledException)
                {
                    _logger.LogWarning($"[ENQUEUE] Timeout for channel {id}");
                    return null;
                }
            }

            return null;
        }


        public async Task<string?> Dequeue(Guid id)
        {
            if (_channels.TryGetValue(id, out var ch))
            {
                var reader = ch.Channel!.Reader;

                if (ch.State != "ACTIVE")
                {
                    _logger.LogWarning($"[DEQUEUE] Channel {id} is closed");
                    return null;
                }

                if (reader.Completion.IsCompleted)
                {
                    return null;
                }

                if (reader.TryRead(out var msg))
                {
                    _logger.LogDebug($"[DEQUEUE TryRead] {id} -> {msg}");
                    return msg;
                }

                using var cts = new CancellationTokenSource(_waitEnqueue);

                try
                {
                    if (await reader.WaitToReadAsync(cts.Token))
                    {
                        if (reader.TryRead(out msg))
                        {
                            _logger.LogDebug($"[DEQUEUE Wait] {id} -> {msg}");
                            return msg;
                        }
                    }
                }
                catch (OperationCanceledException)
                {
                    _logger.LogWarning($"[DEQUEUE] Timeout waiting for message on channel {id}");
                    return null;
                }
            }

            return null;
        }


        public async Task<string?> Peek(Guid id)
        {
            if (_channels.TryGetValue(id, out var ch))
            {
                var reader = ch.Channel!.Reader;

                if (ch.State != "ACTIVE")
                {
                    _logger.LogWarning($"[PEEK] Channel {id} is closed");
                    return null;
                }

                if (reader.Completion.IsCompleted)
                {
                    return null;
                }

                if (reader.TryPeek(out var msg))
                {
                    _logger.LogDebug($"[PEEK TryPeek] {id} -> {msg}");
                    return msg;
                }

                using var cts = new CancellationTokenSource(_waitEnqueue);

                try
                {
                    if (await reader.WaitToReadAsync(cts.Token))
                    {
                        if (reader.TryPeek(out msg))
                        {
                            _logger.LogDebug($"[PEEK Wait] {id} -> {msg}");
                            return msg;
                        }
                    }
                }
                catch (OperationCanceledException)
                {
                    _logger.LogWarning($"[PEEK] Timeout waiting for message on channel {id}");
                    return null;
                }
            }

            return null;
        }
    }
}
