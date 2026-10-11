namespace SelfStorage.Repositories.Entities
{
    public class NotificationRecipient
    {
        public int NotificationID { get; set; }
        public int RecipientUserID { get; set; }
        public DateTime? ReadAt { get; set; }

        public Notification Notification { get; set; } = null!;
        public User RecipientUser { get; set; } = null!;
    }
}
