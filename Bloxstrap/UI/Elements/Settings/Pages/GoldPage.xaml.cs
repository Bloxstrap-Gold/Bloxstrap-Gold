using Bloxstrap.UI.ViewModels.Settings;

namespace Bloxstrap.UI.Elements.Settings.Pages
{
    public partial class GoldPage
    {
        public GoldPage()
        {
            DataContext = new GoldViewModel();
            InitializeComponent();
        }
    }
}
