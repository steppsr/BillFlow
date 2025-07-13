# BillFlow - Enhanced Bill Tracking System
# Tracks bills with categories and improved status management
# Now with full dashboard email configuration support

param(
    [string]$ConfigFile = "./BillFlow_Config.json",
    [switch]$TestEmail,
    [switch]$Verbose
)

# Check if running on Windows or Unix
$IsUnix = $PSVersionTable.PSEdition -eq 'Core' -and -not $IsWindows

#region Configuration Loading
function Load-Configuration {
    param([string]$ConfigPath)
    
    if (!(Test-Path $ConfigPath)) {
        Write-Host "Configuration file not found: $ConfigPath" -ForegroundColor Red
        Write-Host "Please configure through the dashboard first or create a basic config." -ForegroundColor Yellow
        
        # Create minimal config template
        $defaultConfig = @{
            billsPath = "./BillFlow_Bills.csv"
            trackerPath = "./BillFlow.txt"
            backupPath = "./BillFlow_Backups"
            daysWarning = 7
            emailConfig = @{
                enabled = $false
                emailAddress = ""
                smtpServer = ""
                smtpPort = 587
                username = ""
                password = ""
                dailySummary = $false
                dueSoonAlerts = $true
                overdueWarnings = $true
                summaryTime = "08:00"
                alertDaysAhead = 3
            }
        }
        
        $defaultConfig | ConvertTo-Json -Depth 3 | Set-Content -Path $ConfigPath
        Write-Host "Created default configuration at: $ConfigPath" -ForegroundColor Green
        Write-Host "Please edit this file or use the dashboard to configure." -ForegroundColor Yellow
        return $defaultConfig
    }
    
    try {
        return Get-Content $ConfigPath | ConvertFrom-Json
    }
    catch {
        Write-Host "Error loading configuration: $_" -ForegroundColor Red
        exit 1
    }
}

$Config = Load-Configuration -ConfigPath $ConfigFile
$LogFile = Join-Path (Split-Path $Config.trackerPath) "BillFlow_Log.txt"
#endregion

# Add this at the beginning of your script, right after the configuration loading section

# Ensure log file exists and is accessible
$LogFile = Join-Path (Split-Path $Config.trackerPath) "BillFlow_Log.txt"

# Create log file if it doesn't exist
if (!(Test-Path $LogFile)) {
    try {
        New-Item -ItemType File -Path $LogFile -Force | Out-Null
        "BillFlow Log File Created: $(Get-Date)" | Set-Content $LogFile
    }
    catch {
        # If we can't create in the tracker directory, use script directory
        $LogFile = Join-Path $PSScriptRoot "BillFlow_Log.txt"
        New-Item -ItemType File -Path $LogFile -Force | Out-Null
        "BillFlow Log File Created: $(Get-Date)" | Set-Content $LogFile
    }
}

# Enhanced Write-Log function with better error handling
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    # Always try to write to log file
    if ($LogFile) {
        try {
            Add-Content -Path $LogFile -Value $logEntry -ErrorAction Stop
        }
        catch {
            # If log writing fails, at least output to console
            Write-Host "LOG WRITE FAILED: $logEntry" -ForegroundColor Magenta
        }
    }
    
    # Console output based on level and verbosity
    if ($Verbose -or $Level -in @("ERROR", "WARNING", "SUCCESS")) {
        switch ($Level) {
            "ERROR" { 
                Write-Host $logEntry -ForegroundColor Red 
                # For errors, also write the full error details
                if ($Error[0]) {
                    $errorDetails = "$timestamp [ERROR-DETAIL] $($Error[0].Exception.Message)"
                    Add-Content -Path $LogFile -Value $errorDetails -ErrorAction SilentlyContinue
                }
            }
            "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
            default { Write-Host $logEntry }
        }
    }
}

# Add at the very beginning of the script execution
Write-Log "========================================" -Level "INFO"
Write-Log "BillFlow Script Started" -Level "SUCCESS"
Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)" -Level "INFO"
Write-Log "Operating System: $($PSVersionTable.Platform)" -Level "INFO"
Write-Log "Script Path: $PSCommandPath" -Level "INFO"
Write-Log "Config File: $ConfigFile" -Level "INFO"
Write-Log "Log File: $LogFile" -Level "INFO"
Write-Log "========================================" -Level "INFO"

# Add error handling wrapper for the main script
try {
    # Your main script logic here
    
    # At the end of successful execution
    Write-Log "========================================" -Level "INFO"
    Write-Log "BillFlow Script Completed Successfully" -Level "SUCCESS"
    Write-Log "========================================" -Level "INFO"
}
catch {
    Write-Log "FATAL ERROR: $_" -Level "ERROR"
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" -Level "ERROR"
    Write-Log "========================================" -Level "INFO"
    
    # Also output to console so you can see it
    Write-Host "FATAL ERROR: $_" -ForegroundColor Red
    Write-Host "Check log file at: $LogFile" -ForegroundColor Yellow
    
    # Pause so you can read the error if running from Task Scheduler
    if (-not $Verbose) {
        Start-Sleep -Seconds 5
    }
    
    exit 1
}

# Add this function to view recent log entries
function Get-BillFlowLog {
    param(
        [int]$Lines = 50,
        [string]$Level = "ALL"
    )
    
    if (Test-Path $LogFile) {
        $logContent = Get-Content $LogFile -Tail $Lines
        
        if ($Level -ne "ALL") {
            $logContent = $logContent | Where-Object { $_ -match "\[$Level\]" }
        }
        
        foreach ($line in $logContent) {
            if ($line -match "\[ERROR\]") {
                Write-Host $line -ForegroundColor Red
            }
            elseif ($line -match "\[WARNING\]") {
                Write-Host $line -ForegroundColor Yellow
            }
            elseif ($line -match "\[SUCCESS\]") {
                Write-Host $line -ForegroundColor Green
            }
            else {
                Write-Host $line
            }
        }
    }
    else {
        Write-Host "Log file not found at: $LogFile" -ForegroundColor Red
    }
}

#region Enhanced Functions
<#
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    if ($LogFile) {
        try {
            Add-Content -Path $LogFile -Value $logEntry -ErrorAction SilentlyContinue
        }
        catch {
            # Ignore logging errors to prevent script failure
        }
    }
    
    if ($Verbose -or $Level -eq "ERROR" -or $Level -eq "WARNING") {
        switch ($Level) {
            "ERROR" { Write-Host $logEntry -ForegroundColor Red }
            "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
            "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
            default { Write-Host $logEntry }
        }
    }
}
#>

function Test-FileAccess {
    param([string]$FilePath)
    try {
        if (!(Test-Path $FilePath)) {
            $dir = Split-Path $FilePath
            if ($dir -and !(Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            New-Item -ItemType File -Path $FilePath -Force | Out-Null
        }
        $null = [System.IO.File]::OpenWrite($FilePath).Close()
        return $true
    }
    catch {
        Write-Log "Cannot access file: $FilePath - $_" -Level "ERROR"
        return $false
    }
}

function Backup-TrackerFile {
    if (!(Test-Path $Config.trackerPath)) {
        Write-Log "Tracker file does not exist yet: $($Config.trackerPath)" -Level "WARNING"
        return
    }
    
    $backupDir = $Config.backupPath
    if (!(Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    
    $backupName = "BillTracker_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $backupPath = Join-Path $backupDir $backupName
    
    try {
        Copy-Item -Path $Config.trackerPath -Destination $backupPath
        Write-Log "Backup created: $backupPath"
        
        # Keep only last 30 backups
        Get-ChildItem $backupDir -Filter "BillTracker_*.txt" | 
            Sort-Object CreationTime -Descending | 
            Select-Object -Skip 30 | 
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Log "Failed to create backup: $_" -Level "ERROR"
    }
}

function Send-EmailAlert {
    param(
        [string[]]$Messages,
        [string]$AlertType = "Notification",
        [switch]$IsTest
    )
    
    if (!$Config.emailConfig.enabled -or $Messages.Count -eq 0) { 
        if ($IsTest) {
            Write-Host "Email is not enabled in configuration." -ForegroundColor Yellow
        }
        return $false
    }
    
    # Validate required email settings
    $required = @('emailAddress', 'smtpServer', 'username', 'password')
    foreach ($field in $required) {
        if (!$Config.emailConfig.$field) {
            Write-Log "Missing email configuration: $field" -Level "ERROR"
            return $false
        }
    }
    
    try {
        # Create secure credential
        $securePassword = ConvertTo-SecureString $Config.emailConfig.password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential(
            $Config.emailConfig.username, $securePassword
        )
        
        # Build email body
        $body = @"
BillFlow Alert - $AlertType
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

$($Messages -join "`n")

---
This is an automated message from BillFlow.
"@
        
        # Email parameters
        $emailParams = @{
            To = $Config.emailConfig.emailAddress
            From = $Config.emailConfig.emailAddress
            Subject = "BillFlow Alert: $AlertType - $(Get-Date -Format 'yyyy-MM-dd')"
            Body = $body
            SmtpServer = $Config.emailConfig.smtpServer
            Port = [int]$Config.emailConfig.smtpPort
            Credential = $credential
        }
        
        # Add SSL if port suggests it
        if ($Config.emailConfig.smtpPort -eq 587 -or $Config.emailConfig.smtpPort -eq 465) {
            $emailParams.UseSsl = $true
        }
        
        Send-MailMessage @emailParams
        
        if ($IsTest) {
            Write-Host "✅ Test email sent successfully!" -ForegroundColor Green
        } else {
            Write-Log "Email notification sent: $AlertType" -Level "SUCCESS"
        }
        return $true
    }
    catch {
        $errorMsg = "Failed to send email notification: $_"
        Write-Log $errorMsg -Level "ERROR"
        if ($IsTest) {
            Write-Host "❌ $errorMsg" -ForegroundColor Red
        }
        return $false
    }
}

function Test-EmailConfiguration {
    Write-Host "`n🧪 Testing Email Configuration..." -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    
    if (!$Config.emailConfig.enabled) {
        Write-Host "❌ Email alerts are disabled in configuration." -ForegroundColor Red
        return $false
    }
    
    # Test configuration
    Write-Host "📧 Email Address: $($Config.emailConfig.emailAddress)"
    Write-Host "🌐 SMTP Server: $($Config.emailConfig.smtpServer):$($Config.emailConfig.smtpPort)"
    Write-Host "👤 Username: $($Config.emailConfig.username)"
    Write-Host "🔒 Password: $('*' * $Config.emailConfig.password.Length)"
    
    $testMessages = @(
        "This is a test message from BillFlow PowerShell script.",
        "Configuration test completed at $(Get-Date)",
        "If you receive this email, your email alerts are working correctly!"
    )
    
    $result = Send-EmailAlert -Messages $testMessages -AlertType "Configuration Test" -IsTest
    
    if ($result) {
        Write-Host "`n✅ Email test completed successfully!" -ForegroundColor Green
        Write-Host "Check your inbox for the test message." -ForegroundColor Green
    } else {
        Write-Host "`n❌ Email test failed. Please check your configuration." -ForegroundColor Red
    }
    
    return $result
}

function Get-NextOccurrence {
    param(
        [string]$Recurrence,
        [string]$Day,
        [DateTime]$ReferenceDate = (Get-Date)
    )
    
    switch ($Recurrence) {
        "M" { # Monthly
            $nextDate = $ReferenceDate.AddMonths(1)
            try {
                return New-Object DateTime $nextDate.Year, $nextDate.Month, [int]$Day
            }
            catch {
                # Handle invalid days (like Feb 31)
                $lastDay = [DateTime]::DaysInMonth($nextDate.Year, $nextDate.Month)
                return New-Object DateTime $nextDate.Year, $nextDate.Month, [Math]::Min([int]$Day, $lastDay)
            }
        }
        "A" { # Annual
            return [DateTime]::ParseExact($Day, "yyyy-MM-dd", $null)
        }
        "W" { # Weekly
            return $ReferenceDate.AddDays(7)
        }
        "Q" { # Quarterly
            return $ReferenceDate.AddMonths(3)
        }
    }
}

function Format-BillLine {
    param(
        [string]$Action,
        [DateTime]$Date,
        [string]$Name,
        [string]$Category = "",
        [string]$Amount = ""
    )
    
    $dateStr = $Date.ToString("yyyy-MM-dd")
    $line = "$Action $dateStr $Name"
    if ($Category) { $line += " [$Category]" }
    if ($Amount) { $line += " ;; $Amount" }
    return $line
}
#endregion

#region Main Script
# Handle test email parameter
if ($TestEmail) {
    Test-EmailConfiguration
    exit
}

Write-Log "BillFlow started (Enhanced Version)" -Level "SUCCESS"

# Verify files exist and are accessible
if (!(Test-Path $Config.billsPath)) {
    Write-Log "Bills file not found: $($Config.billsPath)" -Level "WARNING"
    Write-Log "Creating empty bills file..." -Level "INFO"
    "Action,Recurrance,Day,Name,Category,EstAmount" | Set-Content $Config.billsPath
}

if (!(Test-FileAccess $Config.trackerPath)) {
    exit 1
}

# Create backup before modifications
Backup-TrackerFile

$content = ""
$notifications = @()
$dueSoonNotifications = @()
$overdueNotifications = @()
$today = Get-Date
$nextMonth = $today.AddMonths(1)
$warningDate = $today.AddDays([int]$Config.emailConfig.alertDaysAhead)


# Process recurring bills from CSV
try {
    if (Test-Path $Config.billsPath) {
        $bills = Import-Csv $Config.billsPath
        Write-Log "Loaded $($bills.Count) recurring bills"
        
        foreach ($bill in $bills) {
            if (!$bill.Name -or !$bill.Recurrence) { 
                Write-Log "Skipping invalid bill entry (missing Name or Recurrance)" -Level "WARNING"
                continue 
            }
            
            # Debug log for bill processing
            Write-Log "Processing bill: $($bill.Name) - Recurrance: $($bill.Recurrance) - Day: $($bill.Day)" -Level "INFO"
            
            try {
                $nextOccurrence = Get-NextOccurrence -Recurrence $bill.Recurrance -Day $bill.Day -ReferenceDate $today
                
                # Check if bill should be added this month
                $shouldAdd = $false
                switch ($bill.Recurrance) {
                    "M" {
                        # For monthly bills, add on the specified day
                        $shouldAdd = ([int]$bill.Day -eq $today.Day)
                        Write-Log "Monthly bill $($bill.Name): Day=$($bill.Day), Today=$($today.Day), ShouldAdd=$shouldAdd" -Level "INFO"
                    }
                    "A" {
                        # For annual bills, check if the date is within the next month
                        try {
                            $billDate = [DateTime]::ParseExact($bill.Day, "yyyy-MM-dd", $null)
                            $shouldAdd = ($billDate.Date -eq $nextMonth.Date)
                            Write-Log "Annual bill $($bill.Name): BillDate=$($billDate.ToString('yyyy-MM-dd')), ShouldAdd=$shouldAdd" -Level "INFO"
                        }
                        catch {
                            Write-Log "Invalid annual date format for $($bill.Name): $($bill.Day)" -Level "ERROR"
                            continue
                        }
                    }
                    default {
                        Write-Log "Unknown recurrence type for $($bill.Name): $($bill.Recurrance)" -Level "WARNING"
                    }
                }
                
                if ($shouldAdd) {
                    $newLine = Format-BillLine -Action $bill.Action -Date $nextOccurrence `
                        -Name $bill.Name -Category $bill.Category -Amount $bill.EstAmount
                    
                    # Fix: Use string concatenation properly
                    if ([string]::IsNullOrEmpty($content)) {
                        $content = $newLine + "`r`n"
                    }
                    else {
                        $content = $newLine + "`r`n" + $content
                    }
                    
                    Write-Log "Added new bill: $($bill.Name) due $($nextOccurrence.ToString('yyyy-MM-dd'))"
                    
                    if ($nextOccurrence -le $warningDate) {
                        $notifications += "NEW: $($bill.Name) due $($nextOccurrence.ToString('yyyy-MM-dd'))"
                    }
                }
            }
            catch {
                Write-Log "Error processing bill $($bill.Name): $_" -Level "ERROR"
                continue
            }
        }
    }
    else {
        Write-Log "Bills CSV file not found at: $($Config.billsPath)" -Level "WARNING"
    }
}
catch {
    Write-Log "Error processing bills CSV: $_" -Level "ERROR"
    Write-Log "Error type: $($_.Exception.GetType().FullName)" -Level "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level "ERROR"
}

# Process existing tracker file
$processedLines = 0
$updatedLines = 0

if (Test-Path $Config.trackerPath) {
    foreach ($line in [System.IO.File]::ReadLines($Config.trackerPath)) {
        $processedLines++
        
        if ($line.Length -lt 2) {
            $content += $line + "`r`n"
            continue
        }
        
        $bill_action = $line.Substring(0, 1)
        $updated = $false
        
        # Parse date if present
        $bill_date = $null
        if ($line.Length -gt 12 -and $line.Substring(2, 10) -match '^\d{4}-\d{2}-\d{2}$') {
            try {
                $bill_date = [DateTime]::ParseExact($line.Substring(2, 10), "yyyy-MM-dd", $null)
            }
            catch {
                Write-Log "Invalid date format in line: $line" -Level "WARNING"
            }
        }
        
        # Update status based on rules
        $new_action = $bill_action
        if ($bill_date) {
            switch ($bill_action) {
                "*" {
                    if ($bill_date -le $warningDate) {
                        $new_action = "Y"
                        $updated = $true
                        $billName = $line.Substring(13).Split('[')[0].Trim()
                        $dueSoonNotifications += "DUE SOON: $billName on $($bill_date.ToString('yyyy-MM-dd'))"
                    }
                }
                "Y" {
                    if ($bill_date -lt $today) {
                        $new_action = "R"
                        $updated = $true
                        $billName = $line.Substring(13).Split('[')[0].Split(';;')[0].Trim()
                        $overdueNotifications += "OVERDUE: $billName was due $($bill_date.ToString('yyyy-MM-dd'))"
                    }
                }
                "=" {
                    if ($bill_date.Date -eq $today.Date) {
                        $new_action = "x"
                        $updated = $true
                        $billName = $line.Substring(13).Split('[')[0].Split(';;')[0].Trim()
                        Write-Log "Auto-completed: $billName"
                    }
                }
            }
        }
        
        # Reconstruct line
        if ($new_action -ne $bill_action) {
            $content += $new_action + $line.Substring(1) + "`r`n"
            $updatedLines++
        }
        else {
            $content += $line + "`r`n"
        }
    }
}

# Write updated content
try {
    Set-Content -Path $Config.trackerPath -Value $content -NoNewline
    Write-Log "Processed $processedLines lines, updated $updatedLines lines"
}
catch {
    Write-Log "Failed to write tracker file: $_" -Level "ERROR"
    exit 1
}

# Send email notifications based on configuration
if ($Config.emailConfig.enabled) {
    # Send due soon alerts
    if ($Config.emailConfig.dueSoonAlerts -and $dueSoonNotifications.Count -gt 0) {
        Send-EmailAlert -Messages $dueSoonNotifications -AlertType "Bills Due Soon"
    }
    
    # Send overdue warnings
    if ($Config.emailConfig.overdueWarnings -and $overdueNotifications.Count -gt 0) {
        Send-EmailAlert -Messages $overdueNotifications -AlertType "Overdue Bills"
    }
    
    # Send daily summary if configured
    if ($Config.emailConfig.dailySummary) {
        $currentTime = Get-Date -Format "HH:mm"
        $summaryTime = $Config.emailConfig.summaryTime
        
        # Check if it's time for daily summary (within 30 minutes of scheduled time)
        $scheduledTime = [DateTime]::ParseExact($summaryTime, "HH:mm", $null)
        $now = [DateTime]::ParseExact($currentTime, "HH:mm", $null)
        $timeDiff = [Math]::Abs(($now - $scheduledTime).TotalMinutes)
        
        if ($timeDiff -le 30) {
            # Generate daily summary
            $stats = @{
                TotalBills = ($content -split "`r`n" | Where-Object { $_ -match '^[*YR=x]' }).Count
                DueSoon = ($content -split "`r`n" | Where-Object { $_ -match '^Y' }).Count
                Overdue = ($content -split "`r`n" | Where-Object { $_ -match '^R' }).Count
                Pending = ($content -split "`r`n" | Where-Object { $_ -match '^\*' }).Count
                AutoPay = ($content -split "`r`n" | Where-Object { $_ -match '^=' }).Count
            }
            
            $summaryMessages = @(
                "📊 Daily Bill Summary for $(Get-Date -Format 'yyyy-MM-dd')",
                "",
                "📋 Total Active Bills: $($stats.TotalBills)",
                "⚠️  Due Soon: $($stats.DueSoon)",
                "🚨 Overdue: $($stats.Overdue)",
                "⏳ Pending: $($stats.Pending)",
                "🤖 Auto-Pay: $($stats.AutoPay)"
            )
            
            if ($dueSoonNotifications.Count -gt 0) {
                $summaryMessages += "", "🔔 Due Soon Details:"
                $summaryMessages += $dueSoonNotifications
            }
            
            if ($overdueNotifications.Count -gt 0) {
                $summaryMessages += "", "⚠️ Overdue Details:"
                $summaryMessages += $overdueNotifications
            }
            
            Send-EmailAlert -Messages $summaryMessages -AlertType "Daily Summary"
        }
    }
}

# Summary statistics
$stats = @{
    TotalBills = ($content -split "`r`n" | Where-Object { $_ -match '^[*YR=x]' }).Count
    DueSoon = ($content -split "`r`n" | Where-Object { $_ -match '^Y' }).Count
    Overdue = ($content -split "`r`n" | Where-Object { $_ -match '^R' }).Count
    Pending = ($content -split "`r`n" | Where-Object { $_ -match '^\*' }).Count
    AutoPay = ($content -split "`r`n" | Where-Object { $_ -match '^=' }).Count
}

Write-Log "Summary - Total: $($stats.TotalBills), Due Soon: $($stats.DueSoon), Overdue: $($stats.Overdue), Pending: $($stats.Pending), AutoPay: $($stats.AutoPay)" -Level "SUCCESS"
Write-Log "BillFlow completed successfully" -Level "SUCCESS"

# Show summary if verbose
if ($Verbose) {
    Write-Host "`n📊 BillFlow Summary:" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    Write-Host "📋 Total Bills: $($stats.TotalBills)"
    Write-Host "⚠️  Due Soon: $($stats.DueSoon)" -ForegroundColor Yellow
    Write-Host "🚨 Overdue: $($stats.Overdue)" -ForegroundColor Red
    Write-Host "⏳ Pending: $($stats.Pending)"
    Write-Host "🤖 Auto-Pay: $($stats.AutoPay)" -ForegroundColor Green
    Write-Host ""
}
#endregion