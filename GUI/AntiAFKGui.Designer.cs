namespace AntiAFK.GUI
{
    partial class AntiAfkGui
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.buttonsaveandclose = new System.Windows.Forms.Button();
            this.msnumeric = new System.Windows.Forms.NumericUpDown();
            this.stopwatchtimer = new System.Windows.Forms.Label();
            this.keydropdown = new System.Windows.Forms.ComboBox();
            this.selectkeytopress = new System.Windows.Forms.Label();
            this.pluginscheckbox = new System.Windows.Forms.CheckBox();
            this.timervariation = new System.Windows.Forms.Label();
            this.varnumeric = new System.Windows.Forms.NumericUpDown();
            ((System.ComponentModel.ISupportInitialize)(this.msnumeric)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.varnumeric)).BeginInit();
            this.SuspendLayout();
            // 
            // buttonsaveandclose
            // 
            this.buttonsaveandclose.Font = new System.Drawing.Font("Century Gothic", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.buttonsaveandclose.Location = new System.Drawing.Point(12, 223);
            this.buttonsaveandclose.Name = "buttonsaveandclose";
            this.buttonsaveandclose.Size = new System.Drawing.Size(184, 23);
            this.buttonsaveandclose.TabIndex = 0;
            this.buttonsaveandclose.Text = "Save and Close";
            this.buttonsaveandclose.UseVisualStyleBackColor = true;
            this.buttonsaveandclose.Click += new System.EventHandler(this.buttonsaveandclose_Click);
            // 
            // msnumeric
            // 
            this.msnumeric.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.msnumeric.Font = new System.Drawing.Font("Century Gothic", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.msnumeric.Location = new System.Drawing.Point(12, 28);
            this.msnumeric.Maximum = new decimal(new int[] {
            300,
            0,
            0,
            0});
            this.msnumeric.Name = "msnumeric";
            this.msnumeric.Size = new System.Drawing.Size(184, 23);
            this.msnumeric.TabIndex = 1;
            this.msnumeric.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.msnumeric.Value = new decimal(new int[] {
            5,
            0,
            0,
            0});
            this.msnumeric.ValueChanged += new System.EventHandler(this.msnumeric_ValueChanged);
            // 
            // stopwatchtimer
            // 
            this.stopwatchtimer.AutoSize = true;
            this.stopwatchtimer.Font = new System.Drawing.Font("Century Gothic", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.stopwatchtimer.Location = new System.Drawing.Point(9, 9);
            this.stopwatchtimer.Name = "stopwatchtimer";
            this.stopwatchtimer.Size = new System.Drawing.Size(165, 15);
            this.stopwatchtimer.TabIndex = 2;
            this.stopwatchtimer.Text = "Stopwatch Timer (In seconds):";
            // 
            // keydropdown
            // 
            this.keydropdown.DrawMode = System.Windows.Forms.DrawMode.OwnerDrawFixed;
            this.keydropdown.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.keydropdown.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.keydropdown.Font = new System.Drawing.Font("Century Gothic", 9.75F);
            this.keydropdown.FormattingEnabled = true;
            this.keydropdown.Location = new System.Drawing.Point(12, 136);
            this.keydropdown.Name = "keydropdown";
            this.keydropdown.Size = new System.Drawing.Size(184, 24);
            this.keydropdown.TabIndex = 3;
            this.keydropdown.DrawItem += new System.Windows.Forms.DrawItemEventHandler(this.cbxDesign_DrawItem);
            this.keydropdown.SelectedIndexChanged += new System.EventHandler(this.keydropdown_SelectedIndexChanged);
            // 
            // selectkeytopress
            // 
            this.selectkeytopress.AutoSize = true;
            this.selectkeytopress.Font = new System.Drawing.Font("Century Gothic", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.selectkeytopress.Location = new System.Drawing.Point(9, 118);
            this.selectkeytopress.Name = "selectkeytopress";
            this.selectkeytopress.Size = new System.Drawing.Size(109, 15);
            this.selectkeytopress.TabIndex = 4;
            this.selectkeytopress.Text = "Select key to press:";
            // 
            // pluginscheckbox
            // 
            this.pluginscheckbox.AutoSize = true;
            this.pluginscheckbox.Font = new System.Drawing.Font("Century Gothic", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.pluginscheckbox.Location = new System.Drawing.Point(12, 197);
            this.pluginscheckbox.Name = "pluginscheckbox";
            this.pluginscheckbox.Size = new System.Drawing.Size(104, 20);
            this.pluginscheckbox.TabIndex = 5;
            this.pluginscheckbox.Text = "Enable Plugins";
            this.pluginscheckbox.UseVisualStyleBackColor = true;
            this.pluginscheckbox.CheckedChanged += new System.EventHandler(this.pluginscheckbox_CheckedChanged);
            // 
            // timervariation
            // 
            this.timervariation.AutoSize = true;
            this.timervariation.Font = new System.Drawing.Font("Century Gothic", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.timervariation.Location = new System.Drawing.Point(9, 64);
            this.timervariation.Name = "timervariation";
            this.timervariation.Size = new System.Drawing.Size(158, 15);
            this.timervariation.TabIndex = 6;
            this.timervariation.Text = "Timer Variation (In seconds):";
            // 
            // varnumeric
            // 
            this.varnumeric.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.varnumeric.Font = new System.Drawing.Font("Century Gothic", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.varnumeric.Location = new System.Drawing.Point(12, 82);
            this.varnumeric.Maximum = new decimal(new int[] {
            300,
            0,
            0,
            0});
            this.varnumeric.Name = "varnumeric";
            this.varnumeric.Size = new System.Drawing.Size(184, 23);
            this.varnumeric.TabIndex = 7;
            this.varnumeric.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.varnumeric.Value = new decimal(new int[] {
            20,
            0,
            0,
            0});
            this.varnumeric.ValueChanged += new System.EventHandler(this.varnumeric_ValueChanged);
            // 
            // AntiAfkGui
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(208, 257);
            this.Controls.Add(this.varnumeric);
            this.Controls.Add(this.timervariation);
            this.Controls.Add(this.pluginscheckbox);
            this.Controls.Add(this.selectkeytopress);
            this.Controls.Add(this.keydropdown);
            this.Controls.Add(this.stopwatchtimer);
            this.Controls.Add(this.msnumeric);
            this.Controls.Add(this.buttonsaveandclose);
            this.Name = "AntiAfkGui";
            this.Text = "AntiAFK GUI";
            this.Load += new System.EventHandler(this.AntiAFKGui_Load);
            ((System.ComponentModel.ISupportInitialize)(this.msnumeric)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.varnumeric)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button buttonsaveandclose;
        private System.Windows.Forms.NumericUpDown msnumeric;
        private System.Windows.Forms.Label stopwatchtimer;
        private System.Windows.Forms.ComboBox keydropdown;
        private System.Windows.Forms.Label selectkeytopress;
        private System.Windows.Forms.CheckBox pluginscheckbox;
        private System.Windows.Forms.Label timervariation;
        private System.Windows.Forms.NumericUpDown varnumeric;
    }
}