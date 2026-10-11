using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SelfStorage.Common.DTOs;
using SelfStorage.Services.Interfaces;

namespace SelfStorage.API.Controllers
{
    [ApiController]
    [Route("api/auth")]
    [Produces("application/json")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        /// <summary>POST /api/auth/login — body: email, password</summary>
        [HttpPost("login")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(LoginResponseDto), 200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(401)]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest(new { message = "Email và mật khẩu không được để trống." });

            var result = await _authService.LoginAsync(request);
            if (result == null)
                return Unauthorized(new { message = "Email hoặc mật khẩu không đúng, hoặc tài khoản bị khóa." });

            return Ok(result);
        }

        /// <summary>POST /api/auth/register — body: fullName, email, password, phoneNumber?</summary>
        [HttpPost("register")]
        [AllowAnonymous]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(409)]
        public async Task<IActionResult> Register([FromBody] RegisterRequestDto request)
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password) || string.IsNullOrWhiteSpace(request.FullName))
                return BadRequest(new { message = "FullName, Email, Password là bắt buộc." });

            var result = await _authService.RegisterCustomerAsync(request);
            if (result == null)
                return Conflict(new { message = "Email đã được sử dụng." });

            return Ok(new { message = "Đăng ký thành công", user = result });
        }

        /// <summary>GET /api/auth/me — cần Bearer token</summary>
        [HttpGet("me")]
        [Authorize]
        [ProducesResponseType(typeof(UserDto), 200)]
        [ProducesResponseType(401)]
        [ProducesResponseType(404)]
        public async Task<IActionResult> GetMe()
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim, out int userId))
                return Unauthorized();

            var user = await _authService.GetCurrentUserAsync(userId);
            if (user == null) return NotFound(new { message = "Không tìm thấy người dùng." });

            return Ok(user);
        }
    }
}