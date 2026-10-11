using Microsoft.EntityFrameworkCore;
using SelfStorage.Repositories.Entities;

namespace SelfStorage.Repositories.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Role> Roles => Set<Role>();
        public DbSet<User> Users => Set<User>();
        public DbSet<Facility> Facilities => Set<Facility>();
        public DbSet<FacilityStaffAssignment> FacilityStaffAssignments => Set<FacilityStaffAssignment>();
        public DbSet<StorageUnitType> StorageUnitTypes => Set<StorageUnitType>();
        public DbSet<StorageUnit> StorageUnits => Set<StorageUnit>();
        public DbSet<Discount> Discounts => Set<Discount>();
        public DbSet<ServicePackage> ServicePackages => Set<ServicePackage>();
        public DbSet<Reservation> Reservations => Set<Reservation>();
        public DbSet<ReservationService> ReservationServices => Set<ReservationService>();
        public DbSet<Contract> Contracts => Set<Contract>();
        public DbSet<ContractRenewal> ContractRenewals => Set<ContractRenewal>();
        public DbSet<Payment> Payments => Set<Payment>();
        public DbSet<ReturnRequest> ReturnRequests => Set<ReturnRequest>();
        public DbSet<Settlement> Settlements => Set<Settlement>();
        public DbSet<SupportTicket> SupportTickets => Set<SupportTicket>();
        public DbSet<OperationalAlert> OperationalAlerts => Set<OperationalAlert>();
        public DbSet<Notification> Notifications => Set<Notification>();
        public DbSet<NotificationRecipient> NotificationRecipients => Set<NotificationRecipient>();
        public DbSet<SystemPolicy> SystemPolicies => Set<SystemPolicy>();
        public DbSet<AuditLog> AuditLogs => Set<AuditLog>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ===== ROLES =====
            modelBuilder.Entity<Role>(e =>
            {
                e.ToTable("ROLES");
                e.HasKey(x => x.RoleID);
                e.Property(x => x.RoleCode).HasMaxLength(50).IsRequired();
                e.HasIndex(x => x.RoleCode).IsUnique();
            });

            // ===== USERS =====
            modelBuilder.Entity<User>(e =>
            {
                e.ToTable("USERS");
                e.HasKey(x => x.UserID);
                e.Property(x => x.Email).HasMaxLength(150).IsRequired();
                e.HasIndex(x => x.Email).IsUnique();
                e.HasOne(x => x.Role).WithMany(r => r.Users).HasForeignKey(x => x.RoleID);
                e.HasOne(x => x.Creator).WithMany().HasForeignKey(x => x.CreatedBy).OnDelete(DeleteBehavior.Restrict);
            });

            // ===== FACILITIES =====
            modelBuilder.Entity<Facility>(e =>
            {
                e.ToTable("FACILITIES");
                e.HasKey(x => x.FacilityID);
                e.Property(x => x.FacilityCode).HasMaxLength(50).IsRequired();
                e.HasIndex(x => x.FacilityCode).IsUnique();
                e.HasOne(x => x.Manager).WithMany().HasForeignKey(x => x.ManagerUserID).OnDelete(DeleteBehavior.Restrict);
            });

            // ===== STORAGE_UNITS =====
            modelBuilder.Entity<StorageUnit>(e =>
            {
                e.ToTable("STORAGE_UNITS");
                e.HasKey(x => x.UnitID);
                e.HasIndex(x => new { x.FacilityID, x.UnitCode }).IsUnique();
                e.HasOne(x => x.Facility).WithMany(f => f.StorageUnits).HasForeignKey(x => x.FacilityID);
                e.HasOne(x => x.UnitType).WithMany(t => t.StorageUnits).HasForeignKey(x => x.UnitTypeID);
            });

            // ===== RESERVATIONS =====
            modelBuilder.Entity<Reservation>(e =>
            {
                e.ToTable("RESERVATIONS");
                e.HasKey(x => x.ReservationID);
                e.HasOne(x => x.Customer).WithMany().HasForeignKey(x => x.CustomerID).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(x => x.Facility).WithMany().HasForeignKey(x => x.FacilityID).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(x => x.UnitType).WithMany().HasForeignKey(x => x.UnitTypeID).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(x => x.Unit).WithMany().HasForeignKey(x => x.UnitID).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(x => x.Discount).WithMany().HasForeignKey(x => x.DiscountID).OnDelete(DeleteBehavior.Restrict);
            });

            // ===== CONTRACTS =====
            modelBuilder.Entity<Contract>(e =>
            {
                e.ToTable("CONTRACTS");
                e.HasKey(x => x.ContractID);
                e.HasIndex(x => x.ContractCode).IsUnique();
                e.HasOne(x => x.Reservation).WithOne(r => r.Contract).HasForeignKey<Contract>(x => x.ReservationID);
                e.HasOne(x => x.CheckInStaff).WithMany().HasForeignKey(x => x.CheckInByStaffID).OnDelete(DeleteBehavior.Restrict);
            });

            // ===== CÁC BẢNG CÒN LẠI (Định nghĩa rõ khóa chính và quan hệ) =====
            modelBuilder.Entity<FacilityStaffAssignment>().ToTable("FACILITY_STAFF_ASSIGNMENTS").HasKey(x => x.AssignmentID);
            modelBuilder.Entity<StorageUnitType>().ToTable("STORAGE_UNIT_TYPES").HasKey(x => x.UnitTypeID);
            modelBuilder.Entity<Discount>().ToTable("DISCOUNTS").HasKey(x => x.DiscountID);
            modelBuilder.Entity<ServicePackage>().ToTable("SERVICE_PACKAGES").HasKey(x => x.PackageID);

            modelBuilder.Entity<ReservationService>().ToTable("RESERVATION_SERVICES")
                .HasKey(x => new { x.ReservationID, x.PackageID });

            modelBuilder.Entity<ContractRenewal>().ToTable("CONTRACT_RENEWALS").HasKey(x => x.RenewalID);
            modelBuilder.Entity<Payment>().ToTable("PAYMENTS").HasKey(x => x.PaymentID);
            modelBuilder.Entity<ReturnRequest>().ToTable("RETURN_REQUESTS").HasKey(x => x.RequestID);

            modelBuilder.Entity<Settlement>(e =>
            {
                e.ToTable("SETTLEMENTS");
                e.HasKey(x => x.SettlementID);
                e.HasOne(s => s.Request)
                 .WithOne(r => r.Settlement)
                 .HasForeignKey<Settlement>(s => s.RequestID)
                 .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<SupportTicket>().ToTable("SUPPORT_TICKETS").HasKey(x => x.TicketID);
            modelBuilder.Entity<OperationalAlert>().ToTable("OPERATIONAL_ALERTS").HasKey(x => x.AlertID);
            modelBuilder.Entity<Notification>().ToTable("NOTIFICATIONS").HasKey(x => x.NotificationID);

            modelBuilder.Entity<NotificationRecipient>().ToTable("NOTIFICATION_RECIPIENTS")
                .HasKey(x => new { x.NotificationID, x.RecipientUserID });

            modelBuilder.Entity<SystemPolicy>().ToTable("SYSTEM_POLICIES").HasKey(x => x.PolicyCode);
            modelBuilder.Entity<AuditLog>().ToTable("AUDIT_LOGS").HasKey(x => x.LogID);
        }
    }
}