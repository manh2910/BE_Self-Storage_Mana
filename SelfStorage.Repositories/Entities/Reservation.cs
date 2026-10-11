namespace SelfStorage.Repositories.Entities
{
    public class Reservation
    {
        public int ReservationID { get; set; }
        public int CustomerID { get; set; }
        public int FacilityID { get; set; }
        public int UnitTypeID { get; set; }
        public int? UnitID { get; set; }                    // NULLABLE - key improvement
        public int? DiscountID { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int RentalMonths { get; set; }
        public decimal MonthlyPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal DepositAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public string Status { get; set; } = "Pending";
        public DateTime? HoldExpiresAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation
        public User Customer { get; set; } = null!;
        public Facility Facility { get; set; } = null!;
        public StorageUnitType UnitType { get; set; } = null!;
        public StorageUnit? Unit { get; set; }
        public Discount? Discount { get; set; }
        public Contract? Contract { get; set; }
        public ICollection<ReservationService> ReservationServices { get; set; } = new List<ReservationService>();
    }
}
