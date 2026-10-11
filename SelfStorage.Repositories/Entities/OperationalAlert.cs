namespace SelfStorage.Repositories.Entities
{
    public class OperationalAlert
    {
        public int AlertID { get; set; }
        public int UnitID { get; set; }
        public int? ResolvedByStaffID { get; set; }
        public string AlertType { get; set; } = string.Empty;
        public string Severity { get; set; } = "Medium";
        public string Description { get; set; } = string.Empty;
        public DateTime DetectedAt { get; set; } = DateTime.UtcNow;
        public string Status { get; set; } = "Open";
        public DateTime? ResolvedAt { get; set; }

        public StorageUnit Unit { get; set; } = null!;
        public User? ResolvedByStaff { get; set; }
    }
}
