namespace SelfStorage.Repositories.Entities
{
    public class ReturnRequest
    {
        public int RequestID { get; set; }
        public int ContractID { get; set; }
        public int? InspectedByStaffID { get; set; }
        public DateTime RequestedAt { get; set; } = DateTime.UtcNow;
        public string RequestType { get; set; } = "Normal";
        public string Status { get; set; } = "Pending";
        public DateTime? InspectedAt { get; set; }
        public string? ConditionNote { get; set; }
        public string? DamageLevel { get; set; }
        public decimal PenaltyAmount { get; set; }
        public DateTime? ClosedAt { get; set; }

        public Contract Contract { get; set; } = null!;
        public User? InspectedByStaff { get; set; }
        public Settlement? Settlement { get; set; }
    }
}
