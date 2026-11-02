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

            if (key.StartsWith("GOLD-") && key.Length >= 10)
            {
                ActivateButton.IsEnabled = true;
                TierBadgeBorder.BorderBrush = (Brush)FindResource("GoldBorderBrush");
                TierBadgeBorder.Background = new SolidColorBrush(Color.FromArgb(50, 212, 175, 55));

                if (key.Contains("-ULTRA-"))
                {
                    TierIconText.Text = "★";
                    TierTitleText.Text = "Tier Detected: Gold ULTRA";
                    TierDetailText.Text = "Ultimate Edition • Unlimited Instances, Realtime Performance & FastFlags Vault Unlocked";
                }
                else if (key.Contains("-DELUXE-"))
                {
                    TierIconText.Text = "★";
                    TierTitleText.Text = "Tier Detected: Gold Deluxe";
                    TierDetailText.Text = "Deluxe Edition • Unlimited Instances & Gold Enhancements";
                }
                else if (key.Contains("-PLUS-"))
                {
                    TierIconText.Text = "★";
                    TierTitleText.Text = "Tier Detected: Gold Plus";
                    TierDetailText.Text = "Plus Edition • Up to 5 Multi-Instances & Gold Preset Configurations";
                }
                else if (key.Contains("-BASIC-"))
                {
                    TierIconText.Text = "★";
                    TierTitleText.Text = "Tier Detected: Gold Basic";
                    TierDetailText.Text = "Standard Edition • Multi-Instance Support";
                }
                else
                {
                    TierIconText.Text = "✓";
                    TierTitleText.Text = "Tier Detected: Bloxstrap Gold VIP";
                    TierDetailText.Text = "Full Bloxstrap Gold Access • Unrestricted License";
                }
            }
            else
            {
                ActivateButton.IsEnabled = false;
                TierIconText.Text = "●";
                TierBadgeBorder.BorderBrush = new SolidColorBrush(Color.FromArgb(100, 255, 100, 100));
                TierBadgeBorder.Background = new SolidColorBrush(Color.FromArgb(30, 255, 50, 50));
                TierTitleText.Text = "Invalid License Key";
                TierDetailText.Text = "Key must begin with the prefix GOLD- to authenticate.";
            }
        }

        private void QuickFillButton_Click(object sender, RoutedEventArgs e)
        {
            KeyTextBox.Text = "GOLD-ULTRA-PERPETUAL-ACCESS";
        }

        private void ActivateButton_Click(object sender, RoutedEventArgs e)
        {
            string key = KeyTextBox.Text.Trim().ToUpperInvariant();

            if (!key.StartsWith("GOLD-") || key.Length < 10)
            {
                Frontend.ShowMessageBox("Please enter a valid license key starting with GOLD-.", MessageBoxImage.Warning);
                return;
            }

            string tierName = "Gold VIP";
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
