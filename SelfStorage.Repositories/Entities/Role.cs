namespace SelfStorage.Repositories.Entities
{
    public class Role
    {
        public int RoleID { get; set; }
        public string RoleCode { get; set; } = string.Empty;
        public string RoleName { get; set; } = string.Empty;
        public string? Description { get; set; }

        // Navigation
        public ICollection<User> Users { get; set; } = new List<User>();
    }
}
