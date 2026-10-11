namespace SelfStorage.Repositories.Entities
{
    public class ReservationService
    {
        public int ReservationID { get; set; }
        public int PackageID { get; set; }
        public decimal PricePerMonth { get; set; }
        public decimal LineAmount { get; set; }

        public Reservation Reservation { get; set; } = null!;
        public ServicePackage Package { get; set; } = null!;
    }
}
