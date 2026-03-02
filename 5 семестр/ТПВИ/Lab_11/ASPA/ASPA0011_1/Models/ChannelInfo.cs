using System.Threading.Channels;

namespace ASPA0011_1.Models
{
    public class ChannelInfo
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public Channel<string>? Channel { get; set; }
    }
}
