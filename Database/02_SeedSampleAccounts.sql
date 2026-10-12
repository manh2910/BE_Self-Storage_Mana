-- ============================================================
-- Self-Storage Facility Rental and Management System
-- Seed 5 tài khoản mẫu (1 account / 1 role) & Dữ liệu mẫu cơ bản
-- Password tất cả tài khoản: 123456
-- Chạy SAU khi đã chạy 01_CreateDatabase.sql
-- ============================================================

USE SelfStorageDB;
GO

-- PasswordHash của "123456" (BCrypt cost 11)
-- Hash: $2a$11$ulYE6v3AXW2OEiWP1AL6beHTYV7P7M1jySC1q.13I2ytgIsCKfY5e
DECLARE @Hash NVARCHAR(255) = N'$2a$11$ulYE6v3AXW2OEiWP1AL6beHTYV7P7M1jySC1q.13I2ytgIsCKfY5e';

-- ============================================================
-- 1. SEED 5 TÀI KHOẢN MẪU (1 User / 1 Role)
-- RoleID:
-- 1 = StorageCustomer
-- 2 = FacilityStaff
-- 3 = FacilityManager
-- 4 = BusinessOperationsManager
-- 5 = SystemAdministrator
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM USERS WHERE Email = 'customer@selfstorage.local')
BEGIN
    SET IDENTITY_INSERT USERS ON;
    INSERT INTO USERS (UserID, RoleID, FullName, Email, PasswordHash, PhoneNumber, Status, CreatedAt)
    VALUES
    (1, 1, N'Nguyễn Văn Customer', 'customer@selfstorage.local', @Hash, '0909000005', 'Active', GETDATE()),
    (2, 2, N'Trần Thị Staff',     'staff@selfstorage.local',    @Hash, '0909000004', 'Active', GETDATE()),
    (3, 3, N'Lê Văn Manager',      'manager@selfstorage.local',  @Hash, '0909000003', 'Active', GETDATE()),
    (4, 4, N'Phạm Thị BOM',        'bom@selfstorage.local',      @Hash, '0909000002', 'Active', GETDATE()),
    (5, 5, N'Hoàng Văn Admin',     'admin@selfstorage.local',    @Hash, '0909000001', 'Active', GETDATE());
    SET IDENTITY_INSERT USERS OFF;
END
ELSE
BEGIN
    -- Cập nhật lại mật khẩu chuẩn nếu đã tồn tại
    UPDATE USERS SET PasswordHash = @Hash, Status = 'Active' WHERE Email IN (
        'customer@selfstorage.local',
        'staff@selfstorage.local',
        'manager@selfstorage.local',
        'bom@selfstorage.local',
        'admin@selfstorage.local'
    );
END
GO

-- ============================================================
-- 2. SEED CƠ SỞ KHO MẪU (FACILITIES)
-- Gán ManagerUserID = 3 (Lê Văn Manager)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM FACILITIES WHERE FacilityCode = 'HN-CG01')
BEGIN
    SET IDENTITY_INSERT FACILITIES ON;
    INSERT INTO FACILITIES (FacilityID, ManagerUserID, CreatedBy, FacilityCode, FacilityName, CityName, Address, PhoneNumber, Status, CreatedAt)
    VALUES
    (1, 3, 5, 'HN-CG01',    N'Kho Tự Quản Cầu Giấy',  N'Hà Nội',      N'Số 12 Duy Tân, Cầu Giấy, Hà Nội',                '0243888999', 'Active', GETDATE()),
    (2, 3, 5, 'HCM-Q7-01',  N'Kho Tự Quản Tân Thuận', N'Hồ Chí Minh', N'Khu Chế Xuất Tân Thuận, Quận 7, TP. Hồ Chí Minh', '0283888999', 'Active', GETDATE());
    SET IDENTITY_INSERT FACILITIES OFF;
END
GO

-- ============================================================
-- 3. SEED PHÂN CÔNG NHÂN VIÊN (FACILITY_STAFF_ASSIGNMENTS)
-- Gán StaffID = 2 (Trần Thị Staff) vào cơ sở 1 (Cầu Giấy)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM FACILITY_STAFF_ASSIGNMENTS WHERE FacilityID = 1 AND StaffID = 2)
BEGIN
    SET IDENTITY_INSERT FACILITY_STAFF_ASSIGNMENTS ON;
    INSERT INTO FACILITY_STAFF_ASSIGNMENTS (AssignmentID, FacilityID, StaffID, AssignedBy, StartDate, EndDate)
    VALUES
    (1, 1, 2, 5, '2026-01-01', NULL);
    SET IDENTITY_INSERT FACILITY_STAFF_ASSIGNMENTS OFF;
END
GO

-- ============================================================
-- 4. SEED KHO LƯU TRỮ MẪU (STORAGE_UNITS)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM STORAGE_UNITS WHERE FacilityID = 1 AND UnitCode = 'CG-A101')
BEGIN
    SET IDENTITY_INSERT STORAGE_UNITS ON;
    INSERT INTO STORAGE_UNITS (UnitID, FacilityID, UnitTypeID, UnitCode, Floor, Status, LockType, AccessCode, CreatedAt)
    VALUES
    (1, 1, 1, 'CG-A101', 1, 'Available', 'Electronic', '1234', GETDATE()),
    (2, 1, 2, 'CG-A102', 1, 'Available', 'Electronic', '1234', GETDATE()),
    (3, 1, 4, 'CG-C101', 1, 'Available', 'Electronic', '1234', GETDATE()),
    (4, 2, 1, 'TT-B101', 1, 'Available', 'Padlock',    NULL,   GETDATE()),
    (5, 2, 3, 'TT-B201', 2, 'Available', 'Padlock',    NULL,   GETDATE());
    SET IDENTITY_INSERT STORAGE_UNITS OFF;
END
GO

-- ============================================================
-- 5. SEED GÓI DỊCH VỤ MẪU (SERVICE_PACKAGES)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM SERVICE_PACKAGES WHERE PackageCode = 'INS-BASIC')
BEGIN
    SET IDENTITY_INSERT SERVICE_PACKAGES ON;
    INSERT INTO SERVICE_PACKAGES (PackageID, PackageCode, PackageName, Description, PricePerMonth, IsActive, CreatedAt)
    VALUES
    (1, 'INS-BASIC', N'Bảo hiểm tài sản cơ bản',   N'Bảo hiểm cháy nổ và mất cắp lên đến 50 triệu đồng', 100000, 1, GETDATE()),
    (2, 'CLIMATE-CTL', N'Kiểm soát độ ẩm cao cấp', N'Duy trì độ ẩm dưới 50% chống ẩm mốc cho đồ gia dụng', 150000, 1, GETDATE());
    SET IDENTITY_INSERT SERVICE_PACKAGES OFF;
END
GO

-- ============================================================
-- 6. SEED KHUYẾN MÃI MẪU (DISCOUNTS)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM DISCOUNTS WHERE PromoCode = 'WELCOME10')
BEGIN
    SET IDENTITY_INSERT DISCOUNTS ON;
    INSERT INTO DISCOUNTS (DiscountID, DiscountName, DiscountType, Value, MinMonths, PromoCode, ValidFrom, ValidTo, IsActive, CreatedAt)
    VALUES
    (1, N'Khuyến mãi chào mừng khách mới', 'Percentage', 10.00, 1, 'WELCOME10', '2026-01-01', '2026-12-31', 1, GETDATE()),
    (2, N'Giảm giá thuê từ 6 tháng',       'Percentage', 15.00, 6, 'LONGTERM15', '2026-01-01', '2026-12-31', 1, GETDATE());
    SET IDENTITY_INSERT DISCOUNTS OFF;
END
GO

PRINT N'>>> Đã seed dữ liệu mẫu thành công!';
PRINT N'';
PRINT N'--- Danh sách tài khoản đăng nhập (Mật khẩu tất cả: 123456) ---';
PRINT N'1. Storage Customer              | customer@selfstorage.local | 0909000005';
PRINT N'2. Facility Staff                | staff@selfstorage.local    | 0909000004';
PRINT N'3. Facility Manager              | manager@selfstorage.local  | 0909000003';
PRINT N'4. Business Operations Manager   | bom@selfstorage.local      | 0909000002';
PRINT N'5. System Administrator          | admin@selfstorage.local    | 0909000001';
GO

-- Kiểm tra danh sách tài khoản
SELECT u.UserID, u.FullName, u.Email, u.PhoneNumber, r.RoleCode, r.RoleName, u.Status
FROM USERS u
JOIN ROLES r ON u.RoleID = r.RoleID
WHERE u.Email LIKE '%@selfstorage.local'
ORDER BY u.UserID;
GO
