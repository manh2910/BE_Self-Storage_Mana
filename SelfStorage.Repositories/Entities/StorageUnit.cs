namespace SelfStorage.Repositories.Entities
{
    public class StorageUnit
    {
        public int UnitID { get; set; }
        public int FacilityID { get; set; }
        public int UnitTypeID { get; set; }
        public string UnitCode { get; set; } = string.Empty;
        public int? Floor { get; set; }
        public string Status { get; set; } = "Available";

        // Access credentials (improved)
        public string? AccessCode { get; set; }
        public string? AccessCardNo { get; set; }
        public string? LockType { get; set; }

        public decimal? TargetTemp { get; set; }
        public decimal? CurrentTemp { get; set; }
        public string? PowerStatus { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation
        public Facility Facility { get; set; } = null!;
        public StorageUnitType UnitType { get; set; } = null!;
    }
}
