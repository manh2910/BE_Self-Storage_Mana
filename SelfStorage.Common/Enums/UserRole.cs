namespace SelfStorage.Common.Enums
{
    /// <summary>
    /// Fixed roles - seed trong database, không cho user tự tạo role mới
    /// </summary>
    public enum UserRole
    {
        StorageCustomer = 1,
        FacilityStaff = 2,
        FacilityManager = 3,
        BusinessOperationsManager = 4,
        SystemAdministrator = 5
    }
}
