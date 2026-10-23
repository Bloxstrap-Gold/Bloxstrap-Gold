using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using Bloxstrap.UI.ViewModels.Settings;

namespace Bloxstrap.UI.Elements.Settings.Pages
{
    public partial class GoldPage
    {
        private readonly Random _rand = new();

        public GoldPage()
        {
            DataContext = new GoldViewModel();
            InitializeComponent();
        }

        private void PagePayCanvas_MouseMove(object sender, MouseEventArgs e)
        {
            if (PagePayButton == null || PagePayCanvas == null)
                return;

            Point mousePos = e.GetPosition(PagePayCanvas);
            double btnLeft = Canvas.GetLeft(PagePayButton);
            double btnTop = Canvas.GetTop(PagePayButton);
            if (double.IsNaN(btnLeft)) btnLeft = 20;
            if (double.IsNaN(btnTop)) btnTop = 4;

            double btnWidth = PagePayButton.ActualWidth > 0 ? PagePayButton.ActualWidth : 160;
            double btnHeight = PagePayButton.ActualHeight > 0 ? PagePayButton.ActualHeight : 34;

            double btnCenterX = btnLeft + btnWidth / 2.0;
            double btnCenterY = btnTop + btnHeight / 2.0;

            double dist = Math.Sqrt(Math.Pow(mousePos.X - btnCenterX, 2) + Math.Pow(mousePos.Y - btnCenterY, 2));

            if (dist < 80)
            {
                EvadePageButton(mousePos, btnWidth, btnHeight);
            }
        }

        private void PagePayButton_MouseEnter(object sender, MouseEventArgs e)
        {
            if (PagePayButton == null || PagePayCanvas == null)
                return;

            Point mousePos = e.GetPosition(PagePayCanvas);
            double btnWidth = PagePayButton.ActualWidth > 0 ? PagePayButton.ActualWidth : 160;
            double btnHeight = PagePayButton.ActualHeight > 0 ? PagePayButton.ActualHeight : 34;
            EvadePageButton(mousePos, btnWidth, btnHeight);
        }

        private void EvadePageButton(Point mousePos, double btnWidth, double btnHeight)
        {
            double maxLeft = Math.Max(10, PagePayCanvas.ActualWidth - btnWidth);
            double maxTop = Math.Max(4, PagePayCanvas.ActualHeight - btnHeight);

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

            Canvas.SetLeft(PagePayButton, newLeft);
            Canvas.SetTop(PagePayButton, newTop);
        }

        private void PagePayButton_Click(object sender, RoutedEventArgs e)
        {
            Frontend.ShowMessageBox(
                "Confirm ignore?",
                MessageBoxImage.Question,
                MessageBoxButton.YesNo
            );
        }
    }
}
