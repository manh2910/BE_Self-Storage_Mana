using SelfStorage.Common.DTOs;

namespace SelfStorage.Services.Interfaces
{
    public interface IAuthService
    {
        Task<LoginResponseDto?> LoginAsync(LoginRequestDto request);
        Task<UserDto?> RegisterCustomerAsync(RegisterRequestDto request);
        Task<UserDto?> GetCurrentUserAsync(int userId);
        Task<List<UserDto>> GetAllUsersAsync();
        Task<UserDto?> GetUserByIdAsync(int userId);
        Task<UserDto?> CreateUserByAdminAsync(CreateUserByAdminDto request);
        Task<UserDto?> UpdateUserAsync(int userId, UpdateUserDto request);
        Task<bool> DeleteUserAsync(int userId);
    }
}
