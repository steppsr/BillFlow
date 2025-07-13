# BillFlow - Personal Bill Management System

<div align="center">
  <h3>💰 Track Bills • 📊 Analyze Spending • 🔔 Never Miss a Payment</h3>
  <p>A cross-platform personal finance tool for managing recurring bills and tracking payments</p>
</div>

## 🌟 Features

- **📊 Interactive Dashboard** - Visual charts and real-time statistics
- **💳 Bill Tracking** - Track payment status, due dates, and amounts
- **🔄 Recurring Bills** - Manage monthly, annual, and custom recurring bills
- **📈 Advanced Analytics** - Spending trends, category breakdowns, and payment performance
- **📧 Email Alerts** - Automated notifications for upcoming and overdue bills
- **🗄️ Backup & Restore** - Secure data backup with easy restoration
- **🎨 Modern UI** - Clean, responsive interface that works on all devices
- **🖥️ Cross-Platform** - Works on Windows, macOS, and Linux

## 📸 Screenshots

<details>
<summary>Click to view screenshots</summary>

- Dashboard Overview
- Analytics View
- Bill Management
- Email Configuration
- Backup System

</details>

## 🚀 Quick Start

### Prerequisites

- **PowerShell** 5.0+ (Windows) or PowerShell Core 6.0+ (macOS/Linux)
- Modern web browser (Chrome, Firefox, Edge, Safari)
- Text editor (optional, for manual file editing)

### Installation

1. **Clone or download this repository**
   ```bash
   git clone https://github.com/yourusername/billflow.git
   cd billflow
   ```

2. **Install PowerShell (if needed)**
   
   **Windows:** Already included
   
   **macOS:**
   ```bash
   brew install --cask powershell
   ```
   
   **Linux (Ubuntu/Debian):**
   ```bash
   sudo apt update && sudo apt install -y powershell
   ```

3. **Set PowerShell execution policy** (first time only)
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Open the Dashboard**
   - Double-click `BillFlow-Dashboard.html` or open in your browser
   - Click the ☰ menu and select "Setup Configuration"
   - Configure your file paths

## 📝 File Format

BillFlow uses a simple text format for tracking bills:

```
* 2025-08-15 PowerGrid Electric [Utilities] ;; 280.00
= 2025-08-10 StreamFlix Subscription [Subscription] ;; 15.99
x 2025-07-12 2025-07-30 SafeGuard Auto Insurance [Insurance] ;; 95.50
```

### Status Codes:
- `*` - Unpaid bill (manual payment required)
- `=` - Auto-payment scheduled
- `x` - Paid/Completed (with payment date)
- `Y` - Due within warning period (set by script)
- `R` - Overdue

### Format Structure:
- **Unpaid/Scheduled:** `[status] [due-date] [name] [category] ;; [amount]`
- **Paid:** `x [payment-date] [due-date] [name] [category] ;; [amount]`

## 💻 Usage

### Daily Workflow

1. **Run the PowerShell script** to update bill statuses:
   ```powershell
   ./BillFlow.ps1
   ```

2. **Check the dashboard** for bills due soon

3. **Mark bills as paid** by either:
   - Using the "Pay" button in the dashboard
   - Manually editing the file (change `*` to `x` and add payment date)

4. **Export updated data** after making changes in the dashboard

### Dashboard Features

- **Load BillFlow File** - Import your bill tracking file
- **Manage Recurring Bills** - Add, edit, or remove recurring bills
- **View Analytics** - Analyze spending patterns and payment performance
- **Configure Email Alerts** - Set up automated notifications
- **Backup & Restore** - Save and restore your configuration and data

## 📊 Sample Data

Click "Generate Sample Data" in the dashboard to load demo data:

```
* 2025-08-12 MegaStore Credit Card [Credit Card]
* 2025-08-10 GreenGas Utilities [Utilities]
= 2025-08-07 TeleConnect Plus [Utilities] ;; 189.99
= 2025-08-04 Holiday Fund Transfer [Savings] ;; 125.00
x 2025-07-12 2025-07-30 SafeGuard Auto Insurance [Insurance] ;; 95.50
x 2025-07-04 2025-07-27 Rewards Plus Card [Credit Card] ;; 245.80
```

## ⚙️ Configuration

### Email Alerts Setup

1. Open dashboard → ☰ Menu → Configure Email Alerts
2. Enable email alerts and enter SMTP settings
3. Common SMTP servers:
   - Gmail: `smtp.gmail.com` (port 587)
   - Outlook: `smtp-mail.outlook.com` (port 587)
4. Use app-specific passwords for Gmail/Outlook

### Recurring Bills CSV Format

```csv
Action,Recurrance,Day,Name,Category,EstAmount
*,M,15,PowerGrid Electric,Utilities,280.00
=,M,5,StreamFlix Subscription,Subscription,15.99
*,A,2025-12-31,Property Tax Annual,Tax,2000.00
```

## 🛡️ Security & Privacy

- All data stored locally on your device
- No cloud services or external dependencies
- Email passwords can be excluded from backups
- Supports secure SMTP connections

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the Apache 2.0 License - see the LICENSE file for details.

## ⚠️ Disclaimer

**IMPORTANT: Please read before using BillFlow**

1. **Educational Purpose**: This software is provided for educational and personal use only.

2. **Not Financial Advice**: BillFlow is a tool for organizing bill information. It does not provide financial advice, investment recommendations, or tax guidance. Always consult qualified financial professionals for financial decisions.

3. **Use at Your Own Risk**: 
   - The developers assume no responsibility for missed payments, late fees, or any financial losses
   - Always verify bill due dates and amounts with your actual service providers
   - Maintain backup payment methods and don't rely solely on this tool

4. **No Warranty**: This software is provided "as is" without warranty of any kind, express or implied.

5. **Data Accuracy**: You are responsible for maintaining accurate bill information and payment records.

6. **Security**: 
   - Store your data files securely
   - Use strong passwords for email configurations
   - Regularly backup your data

By using BillFlow, you acknowledge that you have read and agree to these terms.

## 🙏 Acknowledgments

- Built with Chart.js for data visualization
- Inspired by the need for simple, effective bill management
- Created for the personal finance community

---

<div align="center">
  Made with ❤️ for better financial management
</div>