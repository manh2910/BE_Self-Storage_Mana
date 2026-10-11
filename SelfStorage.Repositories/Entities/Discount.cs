namespace SelfStorage.Repositories.Entities
{
    public class Discount
    {
        public int DiscountID { get; set; }
        public string DiscountName { get; set; } = string.Empty;
        public string DiscountType { get; set; } = string.Empty;
        public decimal Value { get; set; }
        public int? MinMonths { get; set; }
        public string? PromoCode { get; set; }
        public DateTime ValidFrom { get; set; }
        public DateTime ValidTo { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}
