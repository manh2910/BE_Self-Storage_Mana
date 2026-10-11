using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SelfStorage.Common.DTOs;
using SelfStorage.Services.Interfaces;

namespace SelfStorage.API.Controllers
{
    [ApiController]
    [Route("api/users")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IAuthService _authService;

        public UsersController(IAuthService authService)
        {
            _authService = authService;
        }

        /// <summary>GET /api/users</summary>
        [HttpGet]
        [Authorize(Roles = "SystemAdministrator")]
        public async Task<IActionResult> GetAll()
        {
            var users = await _authService.GetAllUsersAsync();
            return Ok(users);
        }

        /// <summary>GET /api/users/{id}</summary>
        [HttpGet("{id:int}")]
        [Authorize(Roles = "SystemAdministrator")]
        public async Task<IActionResult> GetById(int id)
        {
            var user = await _authService.GetUserByIdAsync(id);
            if (user == null) return NotFound(new { message = "Không tìm thấy người dùng." });
            return Ok(user);
        }

        /// <summary>POST /api/users</summary>
        [HttpPost]
        [Authorize(Roles = "SystemAdministrator")]
        public async Task<IActionResult> Create([FromBody] CreateUserByAdminDto request)
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest(new { message = "Email và Password là bắt buộc." });

            if (request.RoleID < 1 || request.RoleID > 5)
                return BadRequest(new { message = "RoleID phải từ 1 đến 5." });

            var result = await _authService.CreateUserByAdminAsync(request);
            if (result == null)
                return Conflict(new { message = "Email đã được sử dụng." });

            return CreatedAtAction(nameof(GetById), new { id = result.UserId }, result);
        }

        /// <summary>PUT /api/users/{id}</summary>
        [HttpPut("{id:int}")]
        [Authorize(Roles = "SystemAdministrator")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateUserDto request)
        {
            var result = await _authService.UpdateUserAsync(id, request);
            if (result == null) return NotFound(new { message = "Không tìm thấy người dùng." });
            return Ok(result);
        }

        /// <summary>DELETE /api/users/{id}</summary>
        [HttpDelete("{id:int}")]
        [Authorize(Roles = "SystemAdministrator")]
        public async Task<IActionResult> Delete(int id)
        {
            var ok = await _authService.DeleteUserAsync(id);
            if (!ok) return NotFound(new { message = "Không tìm thấy người dùng." });
            return Ok(new { message = "Xóa thành công." });
        }
    }
}
