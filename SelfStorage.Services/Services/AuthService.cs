using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using SelfStorage.Common.DTOs;
using SelfStorage.Repositories.Entities;
using SelfStorage.Repositories.Interfaces;
using SelfStorage.Services.Interfaces;

namespace SelfStorage.Services.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUserRepository _userRepository;
        private readonly IConfiguration _configuration;

        public AuthService(IUserRepository userRepository, IConfiguration configuration)
        {
            _userRepository = userRepository;
            _configuration = configuration;
        }

        // ========== POST: Login ==========
        public async Task<LoginResponseDto?> LoginAsync(LoginRequestDto request)
        {
            var user = await _userRepository.GetByEmailAsync(request.Email);
            if (user == null || user.Status != "Active")
                return null;

            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                return null;

            var token = GenerateJwtToken(user);
            var expireMinutes = int.Parse(_configuration["Jwt:ExpireMinutes"] ?? "1440");

            return new LoginResponseDto
            {
                Token = token,
                ExpiresAt = DateTime.UtcNow.AddMinutes(expireMinutes),
                User = MapToUserDto(user)
            };
        }

        // ========== POST: Register (Customer only) ==========
        public async Task<UserDto?> RegisterCustomerAsync(RegisterRequestDto request)
        {
            if (await _userRepository.EmailExistsAsync(request.Email))
                return null;

            var user = new User
            {
                RoleID = 1, // StorageCustomer
                FullName = request.FullName,
                Email = request.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                PhoneNumber = request.PhoneNumber,
                Status = "Active",
                CreatedAt = DateTime.UtcNow
            };

            var created = await _userRepository.CreateAsync(user);
            var fullUser = await _userRepository.GetByIdAsync(created.UserID);
            return fullUser == null ? null : MapToUserDto(fullUser);
        }

        // ========== GET: Current user (me) ==========
        public async Task<UserDto?> GetCurrentUserAsync(int userId)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            return user == null ? null : MapToUserDto(user);
        }

        // ========== GET: All users (Admin) ==========
        public async Task<List<UserDto>> GetAllUsersAsync()
        {
            var users = await _userRepository.GetAllAsync();
            return users.Select(MapToUserDto).ToList();
        }

        // ========== GET: User by id ==========
        public async Task<UserDto?> GetUserByIdAsync(int userId)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            return user == null ? null : MapToUserDto(user);
        }

        // ========== POST: Create user by Admin ==========
        public async Task<UserDto?> CreateUserByAdminAsync(CreateUserByAdminDto request)
        {
            if (await _userRepository.EmailExistsAsync(request.Email))
                return null;

            var user = new User
            {
                RoleID = request.RoleID,
                FullName = request.FullName,
                Email = request.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                PhoneNumber = request.PhoneNumber,
                Status = "Active",
                CreatedAt = DateTime.UtcNow
            };

            var created = await _userRepository.CreateAsync(user);
            var fullUser = await _userRepository.GetByIdAsync(created.UserID);
            return fullUser == null ? null : MapToUserDto(fullUser);
        }

        // ========== PUT: Update user ==========
        public async Task<UserDto?> UpdateUserAsync(int userId, UpdateUserDto request)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null) return null;

            user.FullName = request.FullName;
            user.PhoneNumber = request.PhoneNumber;
            user.Status = request.Status;
            user.UpdatedAt = DateTime.UtcNow;

            await _userRepository.UpdateAsync(user);
            var updated = await _userRepository.GetByIdAsync(userId);
            return updated == null ? null : MapToUserDto(updated);
        }

        // ========== DELETE: Delete user ==========
        public async Task<bool> DeleteUserAsync(int userId)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null) return false;

            await _userRepository.DeleteAsync(user);
            return true;
        }

        private string GenerateJwtToken(User user)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
                _configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key missing")));

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.UserID.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Name, user.FullName),
                new Claim(ClaimTypes.Role, user.Role.RoleCode),
                new Claim("RoleCode", user.Role.RoleCode)
            };

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var expireMinutes = int.Parse(_configuration["Jwt:ExpireMinutes"] ?? "1440");

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(expireMinutes),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private static UserDto MapToUserDto(User user)
        {
            return new UserDto
            {
                UserId = user.UserID,
                FullName = user.FullName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                RoleCode = user.Role?.RoleCode ?? "",
                RoleName = user.Role?.RoleName ?? "",
                Status = user.Status
            };
        }
    }
}
