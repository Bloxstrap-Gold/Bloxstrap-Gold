using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace Bloxstrap.UI.Elements.Dialogs
{
    /// <summary>
    /// Interaction logic for ActivationDialog.xaml
    /// </summary>
    public partial class ActivationDialog
    {
        public bool IsAuthenticated { get; private set; } = false;

        public ActivationDialog()
        {
            InitializeComponent();

            if (!string.IsNullOrEmpty(App.State.Prop.GoldLicenseKey))
            {
                KeyTextBox.Text = App.State.Prop.GoldLicenseKey;
            }
        }

        private void KeyTextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            string key = KeyTextBox.Text.Trim().ToUpperInvariant();

            if (key.StartsWith("GOLD-7DAY-") && key.Length >= 12)
            {
                ActivateButton.IsEnabled = true;
                TierBadgeBorder.BorderBrush = (Brush)FindResource("GoldBorderBrush");
                TierBadgeBorder.Background = new SolidColorBrush(Color.FromArgb(50, 212, 175, 55));

                if (key.Contains("-ULTRA-"))
                {
                    TierIconText.Text = "👑";
                    TierTitleText.Text = "Tier Detected: Gold ULTRA ($199.99/mo)";
                    TierDetailText.Text = "God Complex Edition • Infinite Instances, Realtime CPU Priority & FastFlags Vault Unlocked";
                }
                else if (key.Contains("-DELUXE-"))
                {
                    TierIconText.Text = "🥇";
                    TierTitleText.Text = "Tier Detected: Gold Deluxe ($109.99/mo)";
                    TierDetailText.Text = "Almost Rich Edition • Unlimited Instances & Solid Gold Discord Badge";
                }
                else if (key.Contains("-PLUS-"))
                {
                    TierIconText.Text = "🥈";
                    TierTitleText.Text = "Tier Detected: Gold Plus ($54.99/mo)";
                    TierDetailText.Text = "Mid Edition • Up to 5 Multi-Instances & 18k Gold Badge";
                }
                else if (key.Contains("-BASIC-"))
                {
                    TierIconText.Text = "🥉";
                    TierTitleText.Text = "Tier Detected: Gold Basic ($24.99/mo)";
                    TierDetailText.Text = "Broke Edition • Up to 2 Multi-Instances & 10k Gold Badge";
                }
                else
                {
                    TierIconText.Text = "🟢";
                    TierTitleText.Text = "Tier Detected: VIP Free Trial (7 Days)";
                    TierDetailText.Text = "Full Bloxstrap Gold Access • Payment Ignored Forever";
                }
            }
            else
            {
                ActivateButton.IsEnabled = false;
                TierIconText.Text = "🔒";
                TierBadgeBorder.BorderBrush = new SolidColorBrush(Color.FromArgb(100, 255, 100, 100));
                TierBadgeBorder.Background = new SolidColorBrush(Color.FromArgb(30, 255, 50, 50));
                TierTitleText.Text = "Invalid License Key";
                TierDetailText.Text = "Key must begin with the prefix GOLD-7DAY- to authenticate.";
            }
        }

        private void QuickFillButton_Click(object sender, RoutedEventArgs e)
        {
            KeyTextBox.Text = "GOLD-7DAY-ULTRA-XKW6-5TKI-WBFN";
        }

        private void ActivateButton_Click(object sender, RoutedEventArgs e)
        {
            string key = KeyTextBox.Text.Trim().ToUpperInvariant();

            if (!key.StartsWith("GOLD-7DAY-") || key.Length < 12)
            {
                Frontend.ShowMessageBox("Please enter a valid license key starting with GOLD-7DAY-.", MessageBoxImage.Warning);
                return;
            }

            string tierName = "Gold VIP Trial";
            if (key.Contains("-ULTRA-"))
                tierName = "Gold ULTRA";
            else if (key.Contains("-DELUXE-"))
                tierName = "Gold Deluxe";
            else if (key.Contains("-PLUS-"))
                tierName = "Gold Plus";
            else if (key.Contains("-BASIC-"))
                tierName = "Gold Basic";

            App.State.Prop.GoldLicenseKey = key;
            App.State.Prop.GoldTier = tierName;
            App.State.Prop.IsPaymentIgnored = true;
            App.State.Prop.ForceGoldTrialExpired = false;
            App.State.Save();

            IsAuthenticated = true;
            Close();
        }

        private void QuitButton_Click(object sender, RoutedEventArgs e)
        {
            IsAuthenticated = false;
            Close();
        }
    }
}
