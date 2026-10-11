namespace SelfStorage.Repositories.Entities
{
    public class User
    {
        public int UserID { get; set; }
        public int RoleID { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string Status { get; set; } = "Active";
        public int? CreatedBy { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation
        public Role Role { get; set; } = null!;
        public User? Creator { get; set; }
    }
}
