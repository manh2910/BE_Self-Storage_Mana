using SelfStorage.Repositories.Entities;

namespace SelfStorage.Repositories.Interfaces
{
    public interface IFacilityRepository
    {
        Task<List<Facility>> GetAllActiveAsync();
        Task<Facility?> GetByIdAsync(int facilityId);
    }
}
