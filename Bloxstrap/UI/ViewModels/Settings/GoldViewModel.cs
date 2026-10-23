using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Input;
using CommunityToolkit.Mvvm.Input;
using Bloxstrap.Enums;
using Bloxstrap.Models.Persistable;

namespace Bloxstrap.UI.ViewModels.Settings
{
    public class GoldViewModel : NotifyPropertyChangedViewModel
    {
        public ICommand FastForwardTrialCommand => new RelayCommand(FastForwardTrial);
        public ICommand ResetTrialCommand => new RelayCommand(ResetTrial);
        public ICommand UnlockMutexCommand => new RelayCommand(ToggleMutexHold);
        public ICommand LaunchExtraRobloxCommand => new RelayCommand(LaunchExtraRoblox);
        public ICommand ChangeKeyCommand => new RelayCommand(ChangeKey);
        public ICommand AddAccountCommand => new RelayCommand(AddAccount);

        public EventHandler? RequestTrialStateUpdated;

        public bool IsPaymentIgnored => App.State.Prop.IsPaymentIgnored;

        public string CurrentLicenseKey => App.State.Prop.GoldLicenseKey ?? "GOLD-7DAY-ULTRA-DEMO-KEY";

        public string CurrentTierName => App.State.Prop.GoldTier ?? "Gold ULTRA";

        public string CurrentTierBadge
        {
            get
            {
                string key = (App.State.Prop.GoldLicenseKey ?? "").ToUpperInvariant();
                if (key.Contains("-ULTRA-")) return "👑 ULTRA VIP";
                if (key.Contains("-DELUXE-")) return "🥇 DELUXE";
                if (key.Contains("-PLUS-")) return "🥈 PLUS";
                if (key.Contains("-BASIC-")) return "🥉 BASIC";
                return "🟢 VIP TRIAL";
            }
        }

        public string CurrentTierPrice
        {
            get
            {
                string key = (App.State.Prop.GoldLicenseKey ?? "").ToUpperInvariant();
                if (key.Contains("-ULTRA-")) return "$199.99/mo (God Complex Edition)";
                if (key.Contains("-DELUXE-")) return "$109.99/mo (Almost Rich Edition)";
                if (key.Contains("-PLUS-")) return "$54.99/mo (Mid Edition)";
                if (key.Contains("-BASIC-")) return "$24.99/mo (Broke Edition)";
                return "100% Free VIP Access";
            }
        }

        public int DaysRemaining
        {
            get
            {
                if (IsPaymentIgnored)
                    return 7;

                if (App.State.Prop.ForceGoldTrialExpired)
                    return 0;

                DateTime firstRun = App.State.Prop.GoldFirstRunDate ?? DateTime.UtcNow;
                int daysPassed = (int)(DateTime.UtcNow - firstRun).TotalDays;
                return Math.Max(0, 7 - daysPassed);
            }
        }

        public bool IsTrialExpired => !IsPaymentIgnored && (DaysRemaining == 0 || App.State.Prop.ForceGoldTrialExpired);

        public string TrialStatusText
        {
            get
            {
                return $"Active Tier: {CurrentTierName} • Lifetime Authenticated";
            }
        }

        public string TrialBadgeText => CurrentTierBadge;

        public bool MultiInstanceEnabled
        {
            get => App.Settings.Prop.MultiInstanceLaunching;
            set
            {
                App.Settings.Prop.MultiInstanceLaunching = value;
                OnPropertyChanged(nameof(MultiInstanceEnabled));
            }
        }

        public int RunningRobloxCount => MultiInstanceWatcher.GetOpenProcessesCount();

        public bool IsMutexHeld => MultiInstanceWatcher.IsMutexHeld;

        public string MutexStatusText => IsMutexHeld ? "CLAIMED / ACTIVE" : "RELEASED / READY";

        public ObservableCollection<RobloxAccount> Accounts { get; } = new();

        public GoldViewModel()
        {
            LoadAccounts();
        }

        private void LoadAccounts()
        {
            Accounts.Clear();
            if (App.State.Prop.Accounts.Count == 0)
            {
                // Pre-populate with sample account for demo
                App.State.Prop.Accounts.Add(new RobloxAccount { Username = "Player1", DisplayName = "Primary Account", AddedDate = DateTime.Now.ToString("yyyy-MM-dd") });
                App.State.Save();
            }

            foreach (var acc in App.State.Prop.Accounts)
            {
                Accounts.Add(acc);
            }
        }

        private void FastForwardTrial()
        {
            App.State.Prop.ForceGoldTrialExpired = true;
            App.State.Save();
            RefreshTrialState();
        }

        private void ResetTrial()
        {
            App.State.Prop.ForceGoldTrialExpired = false;
            App.State.Prop.GoldFirstRunDate = DateTime.UtcNow;
            App.State.Save();
            RefreshTrialState();
        }

        public void RefreshTrialState()
        {
            OnPropertyChanged(nameof(CurrentLicenseKey));
            OnPropertyChanged(nameof(CurrentTierName));
            OnPropertyChanged(nameof(CurrentTierBadge));
            OnPropertyChanged(nameof(CurrentTierPrice));
            OnPropertyChanged(nameof(DaysRemaining));
            OnPropertyChanged(nameof(IsTrialExpired));
            OnPropertyChanged(nameof(TrialStatusText));
            OnPropertyChanged(nameof(TrialBadgeText));
            OnPropertyChanged(nameof(RunningRobloxCount));
            OnPropertyChanged(nameof(IsMutexHeld));
            OnPropertyChanged(nameof(MutexStatusText));

            RequestTrialStateUpdated?.Invoke(this, EventArgs.Empty);
        }

        private void ChangeKey()
        {
            var dialog = new UI.Elements.Dialogs.ActivationDialog();
            dialog.ShowDialog();
            if (dialog.IsAuthenticated)
            {
                RefreshTrialState();
                Frontend.ShowMessageBox("Bloxstrap Gold license key updated successfully!", MessageBoxImage.Information);
            }
        }

        private void AddAccount()
        {
            string newUsername = $"AltAccount_{Accounts.Count + 1}";
            var newAcc = new RobloxAccount
            {
                Username = newUsername,
                DisplayName = $"Alt Profile #{Accounts.Count + 1}",
                AddedDate = DateTime.Now.ToString("yyyy-MM-dd")
            };
            App.State.Prop.Accounts.Add(newAcc);
            App.State.Save();
            Accounts.Add(newAcc);
            Frontend.ShowMessageBox($"Added account profile '{newUsername}'.", MessageBoxImage.Information);
        }

        private void ToggleMutexHold()
        {
            if (MultiInstanceWatcher.IsMutexHeld)
            {
                MultiInstanceWatcher.ReleaseSingletonPrimitives();
                Frontend.ShowMessageBox("Roblox singleton mutex released.", MessageBoxImage.Information);
            }
            else
            {
                MultiInstanceWatcher.AcquireSingletonPrimitives();
                Frontend.ShowMessageBox("Roblox singleton mutex claimed! Multiple Roblox instances can now launch.", MessageBoxImage.Information);
            }

            OnPropertyChanged(nameof(IsMutexHeld));
            OnPropertyChanged(nameof(MutexStatusText));
        }

        private void LaunchExtraRoblox()
        {
            MultiInstanceWatcher.AcquireSingletonPrimitives();
            Task.Run(() => LaunchHandler.LaunchRoblox(LaunchMode.Player));
            Frontend.ShowMessageBox("Launching an additional Roblox client instance...", MessageBoxImage.Information);
            OnPropertyChanged(nameof(RunningRobloxCount));
        }
    }
}
