using System.Windows;
using System.Windows.Input;
using CommunityToolkit.Mvvm.Input;
using Bloxstrap.Enums;

namespace Bloxstrap.UI.ViewModels.Settings
{
    public class GoldViewModel : NotifyPropertyChangedViewModel
    {
        public ICommand FastForwardTrialCommand => new RelayCommand(FastForwardTrial);
        public ICommand ResetTrialCommand => new RelayCommand(ResetTrial);
        public ICommand UnlockMutexCommand => new RelayCommand(ToggleMutexHold);
        public ICommand LaunchExtraRobloxCommand => new RelayCommand(LaunchExtraRoblox);
        public ICommand PayForItCommand => new RelayCommand(TriggerPayForIt);

        public EventHandler? RequestTrialStateUpdated;

        public bool IsPaymentIgnored => App.State.Prop.IsPaymentIgnored;

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
                if (IsPaymentIgnored)
                    return "Status: 100% Free Forever Mode Active • All payments permanently ignored.";
                if (IsTrialExpired)
                    return "Your 7-day free trial has expired! Please pay to continue using Bloxstrap Gold VIP.";
                return $"Your free trial runs out in {DaysRemaining} days (Day {8 - DaysRemaining}/7).";
            }
        }

        public string TrialBadgeText => IsPaymentIgnored ? "FREE FOREVER" : (IsTrialExpired ? "EXPIRED" : "VIP TRIAL");

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
            OnPropertyChanged(nameof(DaysRemaining));
            OnPropertyChanged(nameof(IsTrialExpired));
            OnPropertyChanged(nameof(TrialStatusText));
            OnPropertyChanged(nameof(TrialBadgeText));
            OnPropertyChanged(nameof(RunningRobloxCount));
            OnPropertyChanged(nameof(IsMutexHeld));
            OnPropertyChanged(nameof(MutexStatusText));

            RequestTrialStateUpdated?.Invoke(this, EventArgs.Empty);
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

        private void TriggerPayForIt()
        {
            var res = Frontend.ShowMessageBox("Would you like to ignore the payment and continue using Bloxstrap Gold for free?", MessageBoxImage.Question, MessageBoxButton.YesNo);
            if (res == MessageBoxResult.Yes)
            {
                App.State.Prop.IsPaymentIgnored = true;
                App.State.Prop.ForceGoldTrialExpired = false;
                App.State.Save();
                RefreshTrialState();

                Frontend.ShowMessageBox("Payment permanently ignored! Bloxstrap Gold VIP Free Forever mode is now active.", MessageBoxImage.Information);
            }
        }
    }
}
