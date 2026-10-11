namespace SelfStorage.Repositories.Entities
{
    public class AuditLog
    {
        public long LogID { get; set; }
        public int? UserID { get; set; }
        public string ActionType { get; set; } = string.Empty;
        public string EntityName { get; set; } = string.Empty;
        public string? EntityID { get; set; }
        public string? Description { get; set; }
        public string? IpAddress { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public User? User { get; set; }
    }
}
