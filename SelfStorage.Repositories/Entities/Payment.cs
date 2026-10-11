namespace SelfStorage.Repositories.Entities
{
    public class Payment
    {
        public int PaymentID { get; set; }
        public int CustomerID { get; set; }
        public int? ReservationID { get; set; }
        public int? RenewalID { get; set; }
        public int? ContractID { get; set; }
        public string PaymentCode { get; set; } = string.Empty;
        public string PaymentType { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Status { get; set; } = "Pending";
        public string? QRCode { get; set; }
        public DateTime? QRExpiresAt { get; set; }
        public string? TransactionRef { get; set; }
        public DateTime? PaidAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public User Customer { get; set; } = null!;
        public Reservation? Reservation { get; set; }
        public ContractRenewal? Renewal { get; set; }
        public Contract? Contract { get; set; }
    }
}
