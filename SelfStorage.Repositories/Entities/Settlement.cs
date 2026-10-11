namespace SelfStorage.Repositories.Entities
{
    public class Settlement
    {
        public int SettlementID { get; set; }
        public int RequestID { get; set; }
        public int? ManagerID { get; set; }
        public decimal DepositAmount { get; set; }
        public decimal DeductionAmount { get; set; }
        public decimal RefundAmount { get; set; }
        public decimal DebtAmount { get; set; }
        public string? TransactionRef { get; set; }
        public string? DecisionNote { get; set; }
        public string Status { get; set; } = "Pending";
        public DateTime? DecidedAt { get; set; }

        public ReturnRequest Request { get; set; } = null!;
        public User? Manager { get; set; }
    }
}
