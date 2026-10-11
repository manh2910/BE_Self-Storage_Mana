namespace SelfStorage.Repositories.Entities
{
    public class StorageUnitType
    {
        public int UnitTypeID { get; set; }
        public string TypeCode { get; set; } = string.Empty;
        public string TypeName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal AreaM2 { get; set; }
        public bool IsCold { get; set; }
        public decimal? MinTemp { get; set; }
        public decimal? MaxTemp { get; set; }
        public decimal BasePrice { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        public ICollection<StorageUnit> StorageUnits { get; set; } = new List<StorageUnit>();
    }
}
