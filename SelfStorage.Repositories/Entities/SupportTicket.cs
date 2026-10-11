namespace SelfStorage.Repositories.Entities
{
    public class SupportTicket
    {
        public int TicketID { get; set; }
        public int CustomerID { get; set; }
        public int? ContractID { get; set; }
        public int? FacilityID { get; set; }
        public int? HandledByStaffID { get; set; }
        public string Priority { get; set; } = "Medium";
        public string Subject { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string? StaffReply { get; set; }
        public string Status { get; set; } = "Open";
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? RepliedAt { get; set; }

        public User Customer { get; set; } = null!;
        public Contract? Contract { get; set; }
        public Facility? Facility { get; set; }
        public User? HandledByStaff { get; set; }
    }
}
