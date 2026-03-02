using Microsoft.AspNetCore.Mvc;
using ASPA0011_1.Models;
using ASPA0011_1.Services;

namespace ASPA0011_1.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChannelsController : ControllerBase
    {
        private readonly ChannelManager _manager;
        private readonly ILogger<ChannelsController> _logger;

        public ChannelsController(ChannelManager manager, ILogger<ChannelsController> logger)
        {
            _manager = manager;
            _logger = logger;
        }

        [HttpGet]
        public IActionResult GetAll()
        {
            var list = _manager.GetAll().ToList();

            return list.Count == 0 ? NoContent() : Ok(list);
        }

        [HttpGet("{id}")]
        public IActionResult Get(Guid id)
        {
            var ch = _manager.Get(id);

            if (ch == null)
            {
                _logger.LogError($"Channel {id} not found");
                return NotFound();
            }

            return Ok(ch);
        }

        [HttpPost]
        public IActionResult Create([FromBody] ChannelInfo info)
        {
            if (_manager.Get(info.Id) != null)
            {
                return Conflict($"Channel with id {info.Id} already exists");
            }

            var ch = _manager.Create(info.Id, info.Name, info.Description, info.State);

            if (ch.State == "CLOSED")
            { 
                return NoContent(); 
            }

            return Created("", ch);
        }

        [HttpPut]
        public IActionResult Modify([FromBody] ChannelCommand cmd)
        {
            switch (cmd.Command.ToLower())
            {
                case "close":
                    if (!string.IsNullOrEmpty(cmd.Id))
                    {
                        _manager.Close(Guid.Parse(cmd.Id), cmd.Reason ?? "");
                    }
                    else
                    {
                        foreach (var ch in _manager.GetAll())
                        {
                            _manager.Close(ch.Id, cmd.Reason ?? "");
                        }
                    }
                    break;
                case "open":
                    if (!string.IsNullOrEmpty(cmd.Id))
                    {
                        _manager.Open(Guid.Parse(cmd.Id));
                    }
                    else
                    {
                        foreach (var ch in _manager.GetAll())
                        {
                            _manager.Open(ch.Id);
                        }
                    }
                    break;
                default:
                    return BadRequest();
            }

            var allChannels = _manager.GetAll().ToList();

            //if (allChannels.All(c => c.State == "CLOSED"))
            //{ 
            //    return NoContent(); 
            //}

            return Ok(allChannels);
        }



        [HttpDelete]
        public IActionResult Delete([FromBody] ChannelCommand cmd)
        {
            if (!string.IsNullOrEmpty(cmd.Id))
            {
                bool ok = _manager.Delete(Guid.Parse(cmd.Id), cmd.State);

                return ok ? Ok() : NotFound();
            }
            else
            {
                bool ok = _manager.Delete(null, cmd.State);

                return ok ? Ok() : Ok(_manager.GetAll());
            }
        }


    }
}
