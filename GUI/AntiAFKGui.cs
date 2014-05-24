using System;
using System.Drawing;
using System.Windows.Forms;

namespace AntiAFK.GUI
{
    public partial class AntiAfkGui : Form
    {
        #region CBOItem
        public class CboItem
        {
            public readonly int E;
            private readonly string _s;

            public CboItem(int pe, string ps)
            {
                E = pe;
                _s = ps;
            }

            public override string ToString()
            {
                return _s;
            }
        }

        private static void SetComboBoxEnum(ComboBox cb, int e)
        {
            CboItem item;
            for (var i = 0; i < cb.Items.Count; i++)
            {
                item = (CboItem)cb.Items[i];
                if (item.E != e) continue;
                cb.SelectedIndex = i;
                return;
            }
            item = (CboItem)cb.Items[0];
            AntiAFK.AFKLoggingDiag("[AntiAFK Bot] Dialog Error: Combobox {0} does not have enum({1}) in list, defaulting to enum({2})", cb.Name, e, item.E);
            cb.SelectedIndex = 0;
        }

        private static int GetComboBoxEnum(ComboBox cb)
        {
            var item = (CboItem)cb.Items[cb.SelectedIndex];
            return item.E;
        }
        #endregion

        #region GUI Extensions
        private void cbxDesign_DrawItem(object sender, DrawItemEventArgs e)
        {
            ComboBox cbx = sender as ComboBox;

            if (cbx != null)
            {
                e.DrawBackground();

                if (e.Index >= 0)
                {
                    StringFormat sf = new StringFormat();
                    sf.LineAlignment = StringAlignment.Center;
                    sf.Alignment = StringAlignment.Center;

                    Brush brush = new SolidBrush(cbx.ForeColor);

                    if ((e.State & DrawItemState.Selected) == DrawItemState.Selected)
                        brush = SystemBrushes.HighlightText;

                    e.Graphics.DrawString(cbx.Items[e.Index].ToString(), cbx.Font, brush, e.Bounds, sf);
                }
            }
        }
        #endregion

        public AntiAfkGui()
        {
            InitializeComponent();
            AntiAFKSettings.Instance.Load();

            keydropdown.Items.Add(new CboItem((int)Keys.Space, "Space (Jump)"));
            keydropdown.Items.Add(new CboItem((int)Keys.Up, "Forward (Up Arrow)"));
            keydropdown.Items.Add(new CboItem((int)Keys.Down, "Backward (Down Arrow)"));
            keydropdown.Items.Add(new CboItem((int)Keys.Left, "Left (Left Arrow)"));
            keydropdown.Items.Add(new CboItem((int)Keys.Right, "Right (Right Arrow)"));
            keydropdown.Items.Add(new CboItem((int)Keys.W, "Forward (W)"));
            keydropdown.Items.Add(new CboItem((int)Keys.S, "Backward (S)"));
            keydropdown.Items.Add(new CboItem((int)Keys.A, "Left (A)"));
            keydropdown.Items.Add(new CboItem((int)Keys.D, "Right (D)"));

            SetComboBoxEnum(keydropdown, (int)AntiAFKSettings.Instance.AntiAfkKey);
            msnumeric.Value = new decimal(AntiAFKSettings.Instance.AntiAfkTimeValue);
            varnumeric.Value = new decimal(AntiAFKSettings.Instance.AntiAfkRandomValue);
            pluginscheckbox.Checked = AntiAFKSettings.Instance.AntiAfkPlugins;
        }

        private void AntiAFKGui_Load(object sender, EventArgs e) { }

        private void keydropdown_SelectedIndexChanged(object sender, EventArgs e)
        {
            AntiAFKSettings.Instance.AntiAfkKey = (Keys)GetComboBoxEnum(keydropdown);
        }

        private void msnumeric_ValueChanged(object sender, EventArgs e)
        {
            AntiAFKSettings.Instance.AntiAfkTimeValue = (int)msnumeric.Value;
        }

        private void varnumeric_ValueChanged(object sender, EventArgs e)
        {
            AntiAFKSettings.Instance.AntiAfkRandomValue = (int)varnumeric.Value;
        }

        private void pluginscheckbox_CheckedChanged(object sender, EventArgs e)
        {
            AntiAFKSettings.Instance.AntiAfkPlugins = pluginscheckbox.Checked;
        }

        private void buttonsaveandclose_Click(object sender, EventArgs e)
        {
            AntiAFKSettings.Instance.Save();
            AntiAFK.PluginPulsing();
            AntiAFK.AFKLogging("[AntiAFK Bot] Settings are saved!");
            Close();
        }
    }
}
