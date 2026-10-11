namespace SelfStorage.Repositories.Entities
{
    public class Facility
    {
        public int FacilityID { get; set; }
        public int? ManagerUserID { get; set; }
        public int? CreatedBy { get; set; }
        public string FacilityCode { get; set; } = string.Empty;
        public string FacilityName { get; set; } = string.Empty;
        public string CityName { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string Status { get; set; } = "Active";
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation
        public User? Manager { get; set; }
        public ICollection<StorageUnit> StorageUnits { get; set; } = new List<StorageUnit>();
        public ICollection<FacilityStaffAssignment> StaffAssignments { get; set; } = new List<FacilityStaffAssignment>();
    }
}
