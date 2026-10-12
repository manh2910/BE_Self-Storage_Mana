-- ============================================================
-- Self-Storage Facility Rental and Management System
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SelfStorageDB')
BEGIN
    ALTER DATABASE SelfStorageDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SelfStorageDB;
END
GO

CREATE DATABASE SelfStorageDB;
GO

USE SelfStorageDB;
GO

-- ============================================================
-- 1. ROLES (Seed fixed roles)
-- ============================================================
CREATE TABLE ROLES (
    RoleID          INT IDENTITY(1,1) PRIMARY KEY,
    RoleCode        NVARCHAR(50)  NOT NULL UNIQUE,
    RoleName        NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(255) NULL
);
GO

-- ============================================================
-- 2. USERS
-- ============================================================
CREATE TABLE USERS (
    UserID          INT IDENTITY(1,1) PRIMARY KEY,
    RoleID          INT           NOT NULL,
    FullName        NVARCHAR(150) NOT NULL,
    Email           NVARCHAR(150) NOT NULL UNIQUE,
    PasswordHash    NVARCHAR(255) NOT NULL,          -- ASP.NET Identity will manage
    PhoneNumber     NVARCHAR(20)  NULL,
    Status          NVARCHAR(20)  NOT NULL DEFAULT 'Active', -- Active, Inactive, Locked
    CreatedBy       INT           NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME2     NULL,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID) REFERENCES ROLES(RoleID),
    CONSTRAINT FK_Users_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES USERS(UserID)
);
GO

CREATE INDEX IX_Users_Email ON USERS(Email);
CREATE INDEX IX_Users_RoleID ON USERS(RoleID);
GO

-- ============================================================
-- 3. SYSTEM_POLICIES
-- ============================================================
CREATE TABLE SYSTEM_POLICIES (
    PolicyCode      NVARCHAR(50)  PRIMARY KEY,
    PolicyName      NVARCHAR(150) NOT NULL,
    Value           NVARCHAR(100) NOT NULL,
    Unit            NVARCHAR(50)  NULL,              -- %, day, VND...
    UpdatedBy       INT           NULL,
    UpdatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_SystemPolicies_UpdatedBy FOREIGN KEY (UpdatedBy) REFERENCES USERS(UserID)
);
GO

-- ============================================================
-- 4. FACILITIES
-- ============================================================
CREATE TABLE FACILITIES (
    FacilityID      INT IDENTITY(1,1) PRIMARY KEY,
    ManagerUserID   INT           NULL,              -- Facility Manager
    CreatedBy       INT           NULL,
    FacilityCode    NVARCHAR(50)  NOT NULL UNIQUE,
    FacilityName    NVARCHAR(200) NOT NULL,
    CityName        NVARCHAR(100) NOT NULL,
    Address         NVARCHAR(300) NOT NULL,
    PhoneNumber     NVARCHAR(20)  NULL,
    Status          NVARCHAR(20)  NOT NULL DEFAULT 'Active', -- Active, Inactive, Maintenance
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME2     NULL,
    CONSTRAINT FK_Facilities_Manager FOREIGN KEY (ManagerUserID) REFERENCES USERS(UserID),
    CONSTRAINT FK_Facilities_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES USERS(UserID)
);
GO

CREATE INDEX IX_Facilities_Status ON FACILITIES(Status);
GO

-- ============================================================
-- 5. FACILITY_STAFF_ASSIGNMENTS
-- ============================================================
CREATE TABLE FACILITY_STAFF_ASSIGNMENTS (
    AssignmentID    INT IDENTITY(1,1) PRIMARY KEY,
    FacilityID      INT           NOT NULL,
    StaffID         INT           NOT NULL,
    AssignedBy      INT           NULL,
    StartDate       DATE          NOT NULL,
    EndDate         DATE          NULL,              -- NULL = still active
    CONSTRAINT FK_StaffAssign_Facility FOREIGN KEY (FacilityID) REFERENCES FACILITIES(FacilityID),
    CONSTRAINT FK_StaffAssign_Staff FOREIGN KEY (StaffID) REFERENCES USERS(UserID),
    CONSTRAINT FK_StaffAssign_AssignedBy FOREIGN KEY (AssignedBy) REFERENCES USERS(UserID)
);
GO

CREATE INDEX IX_StaffAssign_Facility ON FACILITY_STAFF_ASSIGNMENTS(FacilityID);
CREATE INDEX IX_StaffAssign_Staff ON FACILITY_STAFF_ASSIGNMENTS(StaffID);
GO

-- ============================================================
-- 6. STORAGE_UNIT_TYPES
-- ============================================================
CREATE TABLE STORAGE_UNIT_TYPES (
    UnitTypeID      INT IDENTITY(1,1) PRIMARY KEY,
    TypeCode        NVARCHAR(50)  NOT NULL UNIQUE,
    TypeName        NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(500) NULL,
    AreaM2          DECIMAL(10,2) NOT NULL,
    IsCold          BIT           NOT NULL DEFAULT 0,
    MinTemp         DECIMAL(5,2)  NULL,
    MaxTemp         DECIMAL(5,2)  NULL,
    BasePrice       DECIMAL(18,2) NOT NULL,           -- Price per month
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME2     NULL
);
GO

-- ============================================================
-- 7. STORAGE_UNITS  (Improved: Access info + nullable assignment later)
-- ============================================================
CREATE TABLE STORAGE_UNITS (
    UnitID          INT IDENTITY(1,1) PRIMARY KEY,
    FacilityID      INT           NOT NULL,
    UnitTypeID      INT           NOT NULL,
    UnitCode        NVARCHAR(50)  NOT NULL,           -- Unique within facility
    Floor           INT           NULL,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Available', 
                    -- Available, Reserved, Occupied, Maintenance, Cleaning, Damaged
    -- Access credentials (important for self-storage)
    AccessCode      NVARCHAR(50)  NULL,
    AccessCardNo    NVARCHAR(50)  NULL,
    LockType        NVARCHAR(50)  NULL,              -- Padlock, Electronic, Mechanical...
    -- Temperature (for cold units)
    TargetTemp      DECIMAL(5,2)  NULL,
    CurrentTemp     DECIMAL(5,2)  NULL,
    PowerStatus     NVARCHAR(20)  NULL,              -- On, Off, Error
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME2     NULL,
    CONSTRAINT FK_Units_Facility FOREIGN KEY (FacilityID) REFERENCES FACILITIES(FacilityID),
    CONSTRAINT FK_Units_UnitType FOREIGN KEY (UnitTypeID) REFERENCES STORAGE_UNIT_TYPES(UnitTypeID),
    CONSTRAINT UQ_Units_Facility_Code UNIQUE (FacilityID, UnitCode)
);
GO

CREATE INDEX IX_Units_Facility ON STORAGE_UNITS(FacilityID);
CREATE INDEX IX_Units_Status ON STORAGE_UNITS(Status);
CREATE INDEX IX_Units_UnitType ON STORAGE_UNITS(UnitTypeID);
GO

-- ============================================================
-- 8. DISCOUNTS
-- ============================================================
CREATE TABLE DISCOUNTS (
    DiscountID      INT IDENTITY(1,1) PRIMARY KEY,
    DiscountName    NVARCHAR(150) NOT NULL,
    DiscountType    NVARCHAR(30)  NOT NULL,           -- Percentage, FixedAmount
    Value           DECIMAL(18,2) NOT NULL,
    MinMonths       INT           NULL DEFAULT 1,
    PromoCode       NVARCHAR(50)  NULL UNIQUE,
    ValidFrom       DATE          NOT NULL,
    ValidTo         DATE          NOT NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME2     NULL
);
GO

-- ============================================================
-- 9. SERVICE_PACKAGES (extra services: insurance, climate, etc.)
-- ============================================================
CREATE TABLE SERVICE_PACKAGES (
    PackageID       INT IDENTITY(1,1) PRIMARY KEY,
    PackageCode     NVARCHAR(50)  NOT NULL UNIQUE,
    PackageName     NVARCHAR(150) NOT NULL,
    Description     NVARCHAR(500) NULL,
    PricePerMonth   DECIMAL(18,2) NOT NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME2     NULL
);
GO

-- ============================================================
-- 10. RESERVATIONS  (UnitID is NULLABLE - key improvement)
-- ============================================================
CREATE TABLE RESERVATIONS (
    ReservationID   INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID      INT           NOT NULL,
    FacilityID      INT           NOT NULL,           -- Added for clearer filter
    UnitTypeID      INT           NOT NULL,           -- Reserve by type first
    UnitID          INT           NULL,              -- Assigned later at check-in (IMPROVED)
    DiscountID      INT           NULL,
    StartDate       DATE          NOT NULL,
    EndDate         DATE          NOT NULL,
    RentalMonths    INT           NOT NULL,
    MonthlyPrice    DECIMAL(18,2) NOT NULL,
    DiscountAmount  DECIMAL(18,2) NOT NULL DEFAULT 0,
    DepositAmount   DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalAmount     DECIMAL(18,2) NOT NULL,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Pending', 
                    -- Pending, Confirmed, CheckedIn, Cancelled, Expired, Completed
    HoldExpiresAt   DATETIME2     NULL,              -- Hold unit type for X hours
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME2     NULL,
    CONSTRAINT FK_Reservations_Customer FOREIGN KEY (CustomerID) REFERENCES USERS(UserID),
    CONSTRAINT FK_Reservations_Facility FOREIGN KEY (FacilityID) REFERENCES FACILITIES(FacilityID),
    CONSTRAINT FK_Reservations_UnitType FOREIGN KEY (UnitTypeID) REFERENCES STORAGE_UNIT_TYPES(UnitTypeID),
    CONSTRAINT FK_Reservations_Unit FOREIGN KEY (UnitID) REFERENCES STORAGE_UNITS(UnitID),
    CONSTRAINT FK_Reservations_Discount FOREIGN KEY (DiscountID) REFERENCES DISCOUNTS(DiscountID)
);
GO

CREATE INDEX IX_Reservations_Customer ON RESERVATIONS(CustomerID);
CREATE INDEX IX_Reservations_Status ON RESERVATIONS(Status);
CREATE INDEX IX_Reservations_Facility ON RESERVATIONS(FacilityID);
GO

-- ============================================================
-- 11. RESERVATION_SERVICES (many-to-many)
-- ============================================================
CREATE TABLE RESERVATION_SERVICES (
    ReservationID   INT           NOT NULL,
    PackageID       INT           NOT NULL,
    PricePerMonth   DECIMAL(18,2) NOT NULL,
    LineAmount      DECIMAL(18,2) NOT NULL,
    PRIMARY KEY (ReservationID, PackageID),
    CONSTRAINT FK_ResServices_Reservation FOREIGN KEY (ReservationID) REFERENCES RESERVATIONS(ReservationID),
    CONSTRAINT FK_ResServices_Package FOREIGN KEY (PackageID) REFERENCES SERVICE_PACKAGES(PackageID)
);
GO

-- ============================================================
-- 12. CONTRACTS
-- ============================================================
CREATE TABLE CONTRACTS (
    ContractID      INT IDENTITY(1,1) PRIMARY KEY,
    ReservationID   INT           NOT NULL UNIQUE,
    CheckInByStaffID INT          NULL,
    ContractCode    NVARCHAR(50)  NOT NULL UNIQUE,
    StartDate       DATE          NOT NULL,
    EndDate         DATE          NOT NULL,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Active', 
                    -- Active, Completed, Overdue, Terminated, Renewed
    CheckInAt       DATETIME2     NULL,
    TotalAmount     DECIMAL(18,2) NOT NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME2     NULL,
    CONSTRAINT FK_Contracts_Reservation FOREIGN KEY (ReservationID) REFERENCES RESERVATIONS(ReservationID),
    CONSTRAINT FK_Contracts_CheckInStaff FOREIGN KEY (CheckInByStaffID) REFERENCES USERS(UserID)
);
GO

CREATE INDEX IX_Contracts_Status ON CONTRACTS(Status);
CREATE INDEX IX_Contracts_EndDate ON CONTRACTS(EndDate);
GO

-- ============================================================
-- 13. CONTRACT_RENEWALS
-- ============================================================
CREATE TABLE CONTRACT_RENEWALS (
    RenewalID       INT IDENTITY(1,1) PRIMARY KEY,
    ContractID      INT           NOT NULL,
    RenewalMonths   INT           NOT NULL,
    OldEndDate      DATE          NOT NULL,
    NewEndDate      DATE          NOT NULL,
    MonthlyPrice    DECIMAL(18,2) NOT NULL,
    TotalAmount     DECIMAL(18,2) NOT NULL,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Pending', -- Pending, Completed, Cancelled
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    CompletedAt     DATETIME2     NULL,
    CONSTRAINT FK_Renewals_Contract FOREIGN KEY (ContractID) REFERENCES CONTRACTS(ContractID)
);
GO

-- ============================================================
-- 14. PAYMENTS
-- ============================================================
CREATE TABLE PAYMENTS (
    PaymentID       INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID      INT           NOT NULL,
    ReservationID   INT           NULL,              -- Nullable
    RenewalID       INT           NULL,              -- Nullable
    ContractID      INT           NULL,              -- Added for flexibility
    PaymentCode     NVARCHAR(50)  NOT NULL UNIQUE,
    PaymentType     NVARCHAR(50)  NOT NULL,           -- Deposit, Rental, Renewal, ExtraCharge, Penalty, Refund
    Amount          DECIMAL(18,2) NOT NULL,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Pending', -- Pending, Paid, Failed, Refunded, Expired
    QRCode          NVARCHAR(500) NULL,
    QRExpiresAt     DATETIME2     NULL,
    TransactionRef  NVARCHAR(100) NULL,
    PaidAt          DATETIME2     NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Payments_Customer FOREIGN KEY (CustomerID) REFERENCES USERS(UserID),
    CONSTRAINT FK_Payments_Reservation FOREIGN KEY (ReservationID) REFERENCES RESERVATIONS(ReservationID),
    CONSTRAINT FK_Payments_Renewal FOREIGN KEY (RenewalID) REFERENCES CONTRACT_RENEWALS(RenewalID),
    CONSTRAINT FK_Payments_Contract FOREIGN KEY (ContractID) REFERENCES CONTRACTS(ContractID)
);
GO

CREATE INDEX IX_Payments_Customer ON PAYMENTS(CustomerID);
CREATE INDEX IX_Payments_Status ON PAYMENTS(Status);
GO

-- ============================================================
-- 15. RETURN_REQUESTS
-- ============================================================
CREATE TABLE RETURN_REQUESTS (
    RequestID       INT IDENTITY(1,1) PRIMARY KEY,
    ContractID      INT           NOT NULL,
    InspectedByStaffID INT        NULL,
    RequestedAt     DATETIME2     NOT NULL DEFAULT GETDATE(),
    RequestType     NVARCHAR(50)  NOT NULL DEFAULT 'Normal', -- Normal, Early, Forced
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Pending', 
                    -- Pending, Inspecting, Completed, Cancelled
    InspectedAt     DATETIME2     NULL,
    ConditionNote   NVARCHAR(1000) NULL,
    DamageLevel     NVARCHAR(30)  NULL,              -- None, Minor, Moderate, Severe
    PenaltyAmount   DECIMAL(18,2) NOT NULL DEFAULT 0,
    ClosedAt        DATETIME2     NULL,
    CONSTRAINT FK_ReturnRequests_Contract FOREIGN KEY (ContractID) REFERENCES CONTRACTS(ContractID),
    CONSTRAINT FK_ReturnRequests_Staff FOREIGN KEY (InspectedByStaffID) REFERENCES USERS(UserID)
);
GO

-- ============================================================
-- 16. SETTLEMENTS
-- ============================================================
CREATE TABLE SETTLEMENTS (
    SettlementID    INT IDENTITY(1,1) PRIMARY KEY,
    RequestID       INT           NOT NULL UNIQUE,
    ManagerID       INT           NULL,
    DepositAmount   DECIMAL(18,2) NOT NULL DEFAULT 0,
    DeductionAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    RefundAmount    DECIMAL(18,2) NOT NULL DEFAULT 0,
    DebtAmount      DECIMAL(18,2) NOT NULL DEFAULT 0,
    TransactionRef  NVARCHAR(100) NULL,
    DecisionNote    NVARCHAR(1000) NULL,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Pending', -- Pending, Approved, Rejected, Paid
    DecidedAt       DATETIME2     NULL,
    CONSTRAINT FK_Settlements_Request FOREIGN KEY (RequestID) REFERENCES RETURN_REQUESTS(RequestID),
    CONSTRAINT FK_Settlements_Manager FOREIGN KEY (ManagerID) REFERENCES USERS(UserID)
);
GO

-- ============================================================
-- 17. SUPPORT_TICKETS
-- ============================================================
CREATE TABLE SUPPORT_TICKETS (
    TicketID        INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID      INT           NOT NULL,
    ContractID      INT           NULL,
    FacilityID      INT           NULL,
    HandledByStaffID INT          NULL,
    Priority        NVARCHAR(20)  NOT NULL DEFAULT 'Medium', -- Low, Medium, High, Urgent
    Subject         NVARCHAR(200) NOT NULL,
    Message         NVARCHAR(2000) NOT NULL,
    StaffReply      NVARCHAR(2000) NULL,
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Open', 
                    -- Open, InProgress, Resolved, Closed, Cancelled
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    RepliedAt       DATETIME2     NULL,
    CONSTRAINT FK_Tickets_Customer FOREIGN KEY (CustomerID) REFERENCES USERS(UserID),
    CONSTRAINT FK_Tickets_Contract FOREIGN KEY (ContractID) REFERENCES CONTRACTS(ContractID),
    CONSTRAINT FK_Tickets_Facility FOREIGN KEY (FacilityID) REFERENCES FACILITIES(FacilityID),
    CONSTRAINT FK_Tickets_Staff FOREIGN KEY (HandledByStaffID) REFERENCES USERS(UserID)
);
GO

CREATE INDEX IX_Tickets_Status ON SUPPORT_TICKETS(Status);
CREATE INDEX IX_Tickets_Customer ON SUPPORT_TICKETS(CustomerID);
GO

-- ============================================================
-- 18. OPERATIONAL_ALERTS
-- ============================================================
CREATE TABLE OPERATIONAL_ALERTS (
    AlertID         INT IDENTITY(1,1) PRIMARY KEY,
    UnitID          INT           NOT NULL,
    ResolvedByStaffID INT         NULL,
    AlertType       NVARCHAR(50)  NOT NULL,           -- Temperature, Power, Access, Damage, Other
    Severity        NVARCHAR(20)  NOT NULL DEFAULT 'Medium', -- Low, Medium, High, Critical
    Description     NVARCHAR(1000) NOT NULL,
    DetectedAt      DATETIME2     NOT NULL DEFAULT GETDATE(),
    Status          NVARCHAR(30)  NOT NULL DEFAULT 'Open', -- Open, InProgress, Resolved, Closed
    ResolvedAt      DATETIME2     NULL,
    CONSTRAINT FK_Alerts_Unit FOREIGN KEY (UnitID) REFERENCES STORAGE_UNITS(UnitID),
    CONSTRAINT FK_Alerts_Staff FOREIGN KEY (ResolvedByStaffID) REFERENCES USERS(UserID)
);
GO

CREATE INDEX IX_Alerts_Status ON OPERATIONAL_ALERTS(Status);
CREATE INDEX IX_Alerts_Unit ON OPERATIONAL_ALERTS(UnitID);
GO

-- ============================================================
-- 19. NOTIFICATIONS
-- ============================================================
CREATE TABLE NOTIFICATIONS (
    NotificationID  INT IDENTITY(1,1) PRIMARY KEY,
    SenderID        INT           NULL,              -- NULL = system
    Category        NVARCHAR(50)  NOT NULL,           -- Payment, Reservation, Support, Alert, System
    Title           NVARCHAR(200) NOT NULL,
    Content         NVARCHAR(2000) NOT NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Notifications_Sender FOREIGN KEY (SenderID) REFERENCES USERS(UserID)
);
GO

-- ============================================================
-- 20. NOTIFICATION_RECIPIENTS
-- ============================================================
CREATE TABLE NOTIFICATION_RECIPIENTS (
    NotificationID  INT           NOT NULL,
    RecipientUserID INT           NOT NULL,
    ReadAt          DATETIME2     NULL,
    PRIMARY KEY (NotificationID, RecipientUserID),
    CONSTRAINT FK_NotifRecip_Notification FOREIGN KEY (NotificationID) REFERENCES NOTIFICATIONS(NotificationID),
    CONSTRAINT FK_NotifRecip_User FOREIGN KEY (RecipientUserID) REFERENCES USERS(UserID)
);
GO

-- ============================================================
-- 21. AUDIT_LOGS
-- ============================================================
CREATE TABLE AUDIT_LOGS (
    LogID           BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID          INT           NULL,
    ActionType      NVARCHAR(50)  NOT NULL,           -- Create, Update, Delete, Login, Logout, View...
    EntityName      NVARCHAR(100) NOT NULL,
    EntityID        NVARCHAR(50)  NULL,
    Description     NVARCHAR(1000) NULL,
    IpAddress       NVARCHAR(50)  NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_AuditLogs_User FOREIGN KEY (UserID) REFERENCES USERS(UserID)
);
GO

CREATE INDEX IX_AuditLogs_User ON AUDIT_LOGS(UserID);
CREATE INDEX IX_AuditLogs_CreatedAt ON AUDIT_LOGS(CreatedAt);
GO

-- ============================================================
-- SEED DATA: 5 Fixed Roles
-- ============================================================
SET IDENTITY_INSERT ROLES ON;
INSERT INTO ROLES (RoleID, RoleCode, RoleName, Description) VALUES
(1, 'StorageCustomer', 'Storage Customer', N'Khách hàng thuê kho tự phục vụ'),
(2, 'FacilityStaff', 'Facility Staff', N'Nhân viên cơ sở kho'),
(3, 'FacilityManager', 'Facility Manager', N'Quản lý cơ sở kho'),
(4, 'BusinessOperationsManager', 'Business Operations Manager', N'Quản lý vận hành kinh doanh toàn hệ thống'),
(5, 'SystemAdministrator', 'System Administrator', N'Quản trị hệ thống');
SET IDENTITY_INSERT ROLES OFF;
GO

-- ============================================================
-- SEED DATA: System Policies (mẫu)
-- ============================================================
INSERT INTO SYSTEM_POLICIES (PolicyCode, PolicyName, Value, Unit) VALUES
('DEPOSIT_PERCENT', N'Tỷ lệ đặt cọc', '30', '%'),
('HOLD_HOURS', N'Thời gian giữ chỗ (giờ)', '24', 'hour'),
('OVERDUE_FEE_PER_DAY', N'Phí quá hạn mỗi ngày', '50000', 'VND'),
('RENEWAL_DISCOUNT', N'Giảm giá gia hạn', '5', '%'),
('CANCELLATION_FEE', N'Phí hủy đặt chỗ', '10', '%'),
('MIN_RENTAL_MONTHS', N'Số tháng thuê tối thiểu', '1', 'month');
GO

-- ============================================================
-- SEED DATA: Sample Unit Types
-- ============================================================
SET IDENTITY_INSERT STORAGE_UNIT_TYPES ON;
INSERT INTO STORAGE_UNIT_TYPES (UnitTypeID, TypeCode, TypeName, Description, AreaM2, IsCold, BasePrice, IsActive) VALUES
(1, 'STD-5', N'Kho tiêu chuẩn 5m²', N'Kho khô tiêu chuẩn nhỏ', 5.00, 0, 800000, 1),
(2, 'STD-10', N'Kho tiêu chuẩn 10m²', N'Kho khô tiêu chuẩn trung bình', 10.00, 0, 1400000, 1),
(3, 'STD-20', N'Kho tiêu chuẩn 20m²', N'Kho khô tiêu chuẩn lớn', 20.00, 0, 2500000, 1),
(4, 'COLD-5', N'Kho lạnh 5m²', N'Kho lạnh bảo quản', 5.00, 1, 1500000, 1),
(5, 'COLD-10', N'Kho lạnh 10m²', N'Kho lạnh trung bình', 10.00, 1, 2800000, 1);
SET IDENTITY_INSERT STORAGE_UNIT_TYPES OFF;
GO

PRINT N'>>> Database SelfStorageDB created successfully with adjusted ERD!';
PRINT N'>>> 5 Roles seeded.';
PRINT N'>>> Ready for EF Core / ASP.NET Core 8.';
GO
