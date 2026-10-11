namespace SelfStorage.Repositories.Entities
{
    public class Contract
    {
        public int ContractID { get; set; }
        public int ReservationID { get; set; }
        public int? CheckInByStaffID { get; set; }
        public string ContractCode { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Status { get; set; } = "Active";
        public DateTime? CheckInAt { get; set; }
        public decimal TotalAmount { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation
        public Reservation Reservation { get; set; } = null!;
        public User? CheckInStaff { get; set; }
        public ICollection<ContractRenewal> Renewals { get; set; } = new List<ContractRenewal>();
        public ICollection<ReturnRequest> ReturnRequests { get; set; } = new List<ReturnRequest>();
    }
}
