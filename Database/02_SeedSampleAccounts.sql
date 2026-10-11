-- ============================================================
-- Seed 5 tài khoản mẫu (1 account / 1 role)
-- Password tất cả: 123456
-- Chạy SAU khi đã chạy 01_CreateDatabase.sql
-- ============================================================

USE SelfStorageDB;
GO

-- Xóa user mẫu cũ nếu chạy lại script (tránh trùng email)
DELETE FROM USERS WHERE Email IN (
    'customer@selfstorage.local',
    'staff@selfstorage.local',
    'manager@selfstorage.local',
    'bom@selfstorage.local',
    'admin@selfstorage.local'
);
GO

-- PasswordHash của "123456" (BCrypt cost 11)
-- Hash: $2y$11$ulYE6v3AXW2OEiWP1AL6beHTYV7P7M1jySC1q.13I2ytgIsCKfY5e

DECLARE @Hash NVARCHAR(255) = N'$2a$11$ulYE6v3AXW2OEiWP1AL6beHTYV7P7M1jySC1q.13I2ytgIsCKfY5e';

-- RoleID theo seed trong 01_CreateDatabase.sql:
-- 1 = StorageCustomer
-- 2 = FacilityStaff
-- 3 = FacilityManager
-- 4 = BusinessOperationsManager
-- 5 = SystemAdministrator

INSERT INTO USERS (RoleID, FullName, Email, PasswordHash, PhoneNumber, Status, CreatedAt)
VALUES
-- 1. Storage Customer
(1, N'Nguyễn Văn Customer', 'customer@selfstorage.local', @Hash, '0909000005', 'Active', GETDATE()),

-- 2. Facility Staff
(2, N'Trần Thị Staff', 'staff@selfstorage.local', @Hash, '0909000004', 'Active', GETDATE()),

-- 3. Facility Manager
(3, N'Lê Văn Manager', 'manager@selfstorage.local', @Hash, '0909000003', 'Active', GETDATE()),

-- 4. Business Operations Manager
(4, N'Phạm Thị BOM', 'bom@selfstorage.local', @Hash, '0909000002', 'Active', GETDATE()),

-- 5. System Administrator
(5, N'Hoàng Văn Admin', 'admin@selfstorage.local', @Hash, '0909000001', 'Active', GETDATE());
GO

PRINT N'>>> Đã seed 5 tài khoản mẫu thành công!';
PRINT N'';
PRINT N'--- Thông tin đăng nhập (Password tất cả: 123456) ---';
PRINT N'1. Storage Customer              | customer@selfstorage.local | 0909000005';
PRINT N'2. Facility Staff                | staff@selfstorage.local    | 0909000004';
PRINT N'3. Facility Manager              | manager@selfstorage.local  | 0909000003';
PRINT N'4. Business Operations Manager   | bom@selfstorage.local      | 0909000002';
PRINT N'5. System Administrator          | admin@selfstorage.local    | 0909000001';
GO

-- Kiểm tra nhanh
SELECT u.UserID, u.FullName, u.Email, u.PhoneNumber, r.RoleCode, r.RoleName, u.Status
FROM USERS u
JOIN ROLES r ON u.RoleID = r.RoleID
WHERE u.Email LIKE '%@selfstorage.local'
ORDER BY r.RoleID;
GO
