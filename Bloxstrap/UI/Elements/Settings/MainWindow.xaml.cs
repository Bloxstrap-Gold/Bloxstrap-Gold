using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;

using Wpf.Ui.Controls.Interfaces;
using Wpf.Ui.Mvvm.Contracts;

using Bloxstrap.UI.ViewModels.Settings;

namespace Bloxstrap.UI.Elements.Settings
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : INavigationWindow
    {
        private Models.Persistable.WindowState _state => App.State.Prop.SettingsWindow;

        public MainWindow(bool showAlreadyRunningWarning)
        {
            var viewModel = new MainWindowViewModel();

            viewModel.RequestSaveNoticeEvent += (_, _) => SettingsSavedSnackbar.Show();
            viewModel.RequestCloseWindowEvent += (_, _) => Close();

            DataContext = viewModel;
            
            InitializeComponent();

            App.Logger.WriteLine("MainWindow", "Initializing settings window");

            if (showAlreadyRunningWarning)
                ShowAlreadyRunningSnackbar();

            LoadState();

            if (!App.State.Prop.GoldFirstRunDate.HasValue)
            {
                App.State.Prop.GoldFirstRunDate = DateTime.UtcNow;
                App.State.Save();
            }

            UpdateTrialDisplay();

            if (!App.State.Prop.HasSeenGoldGreeting)
            {
                App.State.Prop.HasSeenGoldGreeting = true;
                App.State.Save();

                Frontend.ShowMessageBox(
                    "Welcome to Bloxstrap Gold!\n\nYour free trial runs out in 7 days.\n\nEnjoy all exclusive Gold features, including built-in Multi-Instance Roblox support and high-roller aesthetics.\n\n(Note: The payment gateway is currently unavailable during your trial period.)",
                    MessageBoxImage.Information
                );
            }
        }

        public void LoadState()
        {
            if (_state.Left > SystemParameters.VirtualScreenWidth)
                _state.Left = 0;

            if (_state.Top > SystemParameters.VirtualScreenHeight)
                _state.Top = 0;

            if (_state.Width > 0)
                this.Width = _state.Width;

            if (_state.Height > 0)
                this.Height = _state.Height;

            if (_state.Left > 0 && _state.Top > 0)
            {
                this.WindowStartupLocation = WindowStartupLocation.Manual;
                this.Left = _state.Left;
                this.Top = _state.Top;
            }
        }

        private async void ShowAlreadyRunningSnackbar()
        {
            await Task.Delay(500); // wait for everything to finish loading
            AlreadyRunningSnackbar.Show();
        }

        #region INavigationWindow methods

        public Frame GetFrame() => RootFrame;

        public INavigation GetNavigation() => RootNavigation;

        public bool Navigate(Type pageType) => RootNavigation.Navigate(pageType);

        public void SetPageService(IPageService pageService) => RootNavigation.PageService = pageService;

        public void ShowWindow() => Show();

        public void CloseWindow() => Close();

        #endregion INavigationWindow methods

        private void WpfUiWindow_Closing(object sender, CancelEventArgs e)
        {
            if (App.FastFlags.Changed || App.PendingSettingTasks.Any())
            {
                var result = Frontend.ShowMessageBox(Strings.Menu_UnsavedChanges, MessageBoxImage.Warning, MessageBoxButton.YesNo);

                if (result != MessageBoxResult.Yes)
                    e.Cancel = true;
            }
            
            _state.Width = this.Width;
            _state.Height = this.Height;

            _state.Top = this.Top;
            _state.Left = this.Left;

            App.State.Save();
        }

        private void WpfUiWindow_Closed(object sender, EventArgs e)
        {
            if (App.LaunchSettings.TestModeFlag.Active)
                LaunchHandler.LaunchRoblox(LaunchMode.Player);
            else
                App.SoftTerminate();
        }

        private readonly Random _rand = new();

        public void UpdateTrialDisplay()
        {
            if (App.State.Prop.IsPaymentIgnored)
            {
                GoldBanner.Background = (Brush)FindResource("GoldDarkGradientBrush");
                GoldBanner.BorderBrush = new SolidColorBrush(Color.FromRgb(40, 180, 80));
                GoldBannerIcon.Text = "👑";
                GoldBannerTitle.Text = "BLOXSTRAP GOLD — VIP ACCESS (ACTIVE FOREVER)";
                GoldBannerTitle.Foreground = (Brush)FindResource("GoldPrimaryBrush");
                GoldBannerBadge.Text = "FREE FOREVER";
                GoldBannerSubtitle.Text = "Status: 100% Free Forever Mode Active • All payments permanently ignored.";
                TrialActiveContainer.Visibility = Visibility.Collapsed;
                TrialExpiredContainer.Visibility = Visibility.Collapsed;
                return;
            }

            DateTime firstRun = App.State.Prop.GoldFirstRunDate ?? DateTime.UtcNow;
            int daysPassed = (int)(DateTime.UtcNow - firstRun).TotalDays;
            int daysRemaining = Math.Max(0, 7 - daysPassed);
            bool isExpired = daysRemaining == 0 || App.State.Prop.ForceGoldTrialExpired;

            if (!isExpired)
            {
                GoldBanner.Background = (Brush)FindResource("GoldDarkGradientBrush");
                GoldBanner.BorderBrush = (Brush)FindResource("GoldBorderBrush");
                GoldBannerIcon.Text = "👑";
                GoldBannerTitle.Text = "BLOXSTRAP GOLD EDITION";
                GoldBannerTitle.Foreground = (Brush)FindResource("GoldPrimaryBrush");
                GoldBannerBadge.Text = "VIP TRIAL";
                GoldBannerSubtitle.Text = $"Your free trial runs out in {daysRemaining} days (Day {8 - daysRemaining}/7).";
                TrialActiveContainer.Visibility = Visibility.Visible;
                TrialExpiredContainer.Visibility = Visibility.Collapsed;
            }
            else
            {
                GoldBanner.Background = (Brush)FindResource("GoldExpiredGradientBrush");
                GoldBanner.BorderBrush = (Brush)FindResource("GoldPrimaryBrush");
                GoldBannerIcon.Text = "⚠️👑";
                GoldBannerTitle.Text = "BLOXSTRAP GOLD — TRIAL EXPIRED!";
                GoldBannerTitle.Foreground = new SolidColorBrush(Color.FromRgb(255, 220, 100));
                GoldBannerBadge.Text = "PAYMENT REQUIRED";
                GoldBannerSubtitle.Text = "Your 7-day free trial has expired! Please pay for Bloxstrap Gold VIP ($999.99/mo) to continue.";
                TrialActiveContainer.Visibility = Visibility.Collapsed;
                TrialExpiredContainer.Visibility = Visibility.Visible;

                Canvas.SetLeft(PayButton, 10);
                Canvas.SetTop(PayButton, 3);
            }
        }

        private void DemoExpireButton_Click(object sender, RoutedEventArgs e)
        {
            App.State.Prop.IsPaymentIgnored = false;
            App.State.Prop.ForceGoldTrialExpired = true;
            App.State.Save();
            UpdateTrialDisplay();
        }

        private void DemoResetButton_Click(object sender, RoutedEventArgs e)
        {
            App.State.Prop.IsPaymentIgnored = false;
            App.State.Prop.ForceGoldTrialExpired = false;
            App.State.Prop.GoldFirstRunDate = DateTime.UtcNow;
            App.State.Save();
            UpdateTrialDisplay();
        }

        private void PayButtonCanvas_MouseMove(object sender, MouseEventArgs e)
        {
            if (PayButton == null || PayButtonCanvas == null)
                return;

            Point mousePos = e.GetPosition(PayButtonCanvas);
            double btnLeft = Canvas.GetLeft(PayButton);
            double btnTop = Canvas.GetTop(PayButton);
            if (double.IsNaN(btnLeft)) btnLeft = 10;
            if (double.IsNaN(btnTop)) btnTop = 3;

            double btnWidth = PayButton.ActualWidth > 0 ? PayButton.ActualWidth : 160;
            double btnHeight = PayButton.ActualHeight > 0 ? PayButton.ActualHeight : 34;

            double btnCenterX = btnLeft + btnWidth / 2.0;
            double btnCenterY = btnTop + btnHeight / 2.0;

            double dist = Math.Sqrt(Math.Pow(mousePos.X - btnCenterX, 2) + Math.Pow(mousePos.Y - btnCenterY, 2));

            if (dist < 80)
            {
                EvadePayButton(mousePos, btnWidth, btnHeight);
            }
        }

        private void PayButton_MouseEnter(object sender, MouseEventArgs e)
        {
            if (PayButton == null || PayButtonCanvas == null)
                return;

            Point mousePos = e.GetPosition(PayButtonCanvas);
            double btnWidth = PayButton.ActualWidth > 0 ? PayButton.ActualWidth : 160;
            double btnHeight = PayButton.ActualHeight > 0 ? PayButton.ActualHeight : 34;
            EvadePayButton(mousePos, btnWidth, btnHeight);
        }

        private void EvadePayButton(Point mousePos, double btnWidth, double btnHeight)
        {
            double maxLeft = Math.Max(10, PayButtonCanvas.ActualWidth - btnWidth);
            double maxTop = Math.Max(4, PayButtonCanvas.ActualHeight - btnHeight);

            double newLeft;
            double newTop;
            int attempts = 0;

            do
            {
                newLeft = _rand.NextDouble() * maxLeft;
                newTop = _rand.NextDouble() * maxTop;
                double newCenterX = newLeft + btnWidth / 2.0;
                double newCenterY = newTop + btnHeight / 2.0;
                double dist = Math.Sqrt(Math.Pow(mousePos.X - newCenterX, 2) + Math.Pow(mousePos.Y - newCenterY, 2));
                if (dist > 85 || attempts > 10)
                    break;
                attempts++;
            } while (attempts <= 10);

            Canvas.SetLeft(PayButton, newLeft);
            Canvas.SetTop(PayButton, newTop);
        }

        private void PayButton_Click(object sender, RoutedEventArgs e)
        {
            var result = Frontend.ShowMessageBox(
                "Would you like to ignore the payment and continue using Bloxstrap Gold for free?",
                MessageBoxImage.Question,
                MessageBoxButton.YesNo
            );

            if (result == MessageBoxResult.Yes)
            {
                App.State.Prop.IsPaymentIgnored = true;
                App.State.Prop.ForceGoldTrialExpired = false;
                App.State.Save();
                UpdateTrialDisplay();

                Frontend.ShowMessageBox(
                    "Payment permanently ignored! Bloxstrap Gold VIP Free Forever mode is now active.",
                    MessageBoxImage.Information
                );
            }
        }
    }
}
