namespace Bloxstrap.Models.Persistable
{
    public class RobloxAccount
    {
        public string Username { get; set; } = "";
        public string DisplayName { get; set; } = "";
        public long UserId { get; set; } = 0;
        public string AddedDate { get; set; } = "";
    }

    public class State
    {
        public bool PromptWebView2Install { get; set; } = true;

        public bool ForceReinstall { get; set; } = false;

        public WindowState SettingsWindow { get; set; } = new();
        
        public DateTime? GoldFirstRunDate { get; set; } = null;

        public bool HasSeenGoldGreeting { get; set; } = false;

        public bool ForceGoldTrialExpired { get; set; } = false;
        
        public bool IsPaymentIgnored { get; set; } = false;

        public string? GoldLicenseKey { get; set; } = null;

        public string? GoldTier { get; set; } = null;

        public List<RobloxAccount> Accounts { get; set; } = new();
    }
}
