using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace SelfStorage.Common.DTOs
{
    public class LoginRequestDto
    {
        [Required]
        [EmailAddress]
        [DefaultValue("customer@selfstorage.local")]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        [DefaultValue("123456")]
        public string Password { get; set; } = string.Empty;
    }

    public class RegisterRequestDto
    {
        [Required]
        [MaxLength(150)]
        [DefaultValue("Nguyen Van A")]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        [DefaultValue("newcustomer@example.com")]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        [DefaultValue("123456")]
        public string Password { get; set; } = string.Empty;

        [DefaultValue("0909123456")]
        public string? PhoneNumber { get; set; }
    }

    public class UserDto
    {
        public int UserId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string RoleCode { get; set; } = string.Empty;
        public string RoleName { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
    }

    public class LoginResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
        public UserDto User { get; set; } = null!;
    }

    public class UpdateUserDto
    {
        [Required]
        public string FullName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        [DefaultValue("Active")]
        public string Status { get; set; } = "Active";
    }

    public class CreateUserByAdminDto
    {
        [Required]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        public string Password { get; set; } = string.Empty;

        public string? PhoneNumber { get; set; }

        /// <summary>1=Customer, 2=Staff, 3=Manager, 4=BOM, 5=Admin</summary>
        [Range(1, 5)]
        [DefaultValue(1)]
        public int RoleID { get; set; }
    }
}