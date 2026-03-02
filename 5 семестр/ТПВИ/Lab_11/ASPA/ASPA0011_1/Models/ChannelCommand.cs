namespace ASPA0011_1.Models
{
    public class ChannelCommand
    {
        public string Command { get; set; } = string.Empty;
        public string? Id { get; set; }
        public string? State { get; set; }
        public string? Reason { get; set; }
        public string? Data { get; set; }
    }
}
