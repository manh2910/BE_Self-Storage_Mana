namespace SelfStorage.Repositories.Entities
{
    public class FacilityStaffAssignment
    {
        public int AssignmentID { get; set; }
        public int FacilityID { get; set; }
        public int StaffID { get; set; }
        public int? AssignedBy { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        public Facility Facility { get; set; } = null!;
        public User Staff { get; set; } = null!;
        public User? Assigner { get; set; }
    }
}
