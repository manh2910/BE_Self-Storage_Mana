namespace SelfStorage.Repositories.Entities
{
    public class Notification
    {
        public int NotificationID { get; set; }
        public int? SenderID { get; set; }
        public string Category { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public User? Sender { get; set; }
        public ICollection<NotificationRecipient> Recipients { get; set; } = new List<NotificationRecipient>();
    }
}
