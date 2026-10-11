namespace SelfStorage.Repositories.Entities
{
    public class ContractRenewal
    {
        public int RenewalID { get; set; }
        public int ContractID { get; set; }
        public int RenewalMonths { get; set; }
        public DateTime OldEndDate { get; set; }
        public DateTime NewEndDate { get; set; }
        public decimal MonthlyPrice { get; set; }
        public decimal TotalAmount { get; set; }
        public string Status { get; set; } = "Pending";
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? CompletedAt { get; set; }

        public Contract Contract { get; set; } = null!;
    }
}
