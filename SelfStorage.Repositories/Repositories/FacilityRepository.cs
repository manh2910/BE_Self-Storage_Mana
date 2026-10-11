using Microsoft.EntityFrameworkCore;
using SelfStorage.Repositories.Data;
using SelfStorage.Repositories.Entities;
using SelfStorage.Repositories.Interfaces;

namespace SelfStorage.Repositories.Repositories
{
    public class FacilityRepository : IFacilityRepository
    {
        private readonly AppDbContext _context;

        public FacilityRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Facility>> GetAllActiveAsync()
        {
            return await _context.Facilities
                .Where(f => f.Status == "Active")
                .OrderBy(f => f.FacilityName)
                .ToListAsync();
        }

        public async Task<Facility?> GetByIdAsync(int facilityId)
        {
            return await _context.Facilities
                .Include(f => f.StorageUnits)
                .FirstOrDefaultAsync(f => f.FacilityID == facilityId);
        }
    }
}
