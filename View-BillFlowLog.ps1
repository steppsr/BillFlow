# View-BillFlowLog.ps1
# Simple script to view BillFlow logs with color coding

param(
    [int]$Lines = 50,
    [string]$Level = "ALL",  # ALL, ERROR, WARNING, SUCCESS, INFO
    [switch]$Follow,         # Like tail -f, continuously show new entries
    [switch]$Today          # Show only today's entries
)

# Try to find the log file
$possiblePaths = @(
    "./BillFlow_Log.txt",
    "../BillFlow_Log.txt",
    "$PSScriptRoot/BillFlow_Log.txt",
    "$env:USERPROFILE/Documents/BillFlow/BillFlow_Log.txt"
)

$LogFile = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $LogFile = $path
        break
    }
}

if (!$LogFile) {
    Write-Host "❌ BillFlow log file not found!" -ForegroundColor Red
    Write-Host "Searched in:" -ForegroundColor Yellow
    $possiblePaths | ForEach-Object { Write-Host "  $_" }
    exit
}

Write-Host "📋 BillFlow Log Viewer" -ForegroundColor Cyan
Write-Host "Log file: $LogFile" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

function Show-LogEntry {
    param([string]$Line)
    
    if ($Today) {
        $todayDate = Get-Date -Format "yyyy-MM-dd"
        if ($Line -notmatch $todayDate) {
            return
        }
    }
    
    if ($Level -ne "ALL" -and $Line -notmatch "\[$Level\]") {
        return
    }
    
    if ($Line -match "\[ERROR\]") {
        Write-Host $Line -ForegroundColor Red
    }
    elseif ($Line -match "\[WARNING\]") {
        Write-Host $Line -ForegroundColor Yellow
    }
    elseif ($Line -match "\[SUCCESS\]") {
        Write-Host $Line -ForegroundColor Green
    }
    elseif ($Line -match "====") {
        Write-Host $Line -ForegroundColor Cyan
    }
    else {
        Write-Host $Line
    }
}

if ($Follow) {
    Write-Host "Following log file (Ctrl+C to stop)..." -ForegroundColor Yellow
    Get-Content $LogFile -Tail $Lines -Wait | ForEach-Object { Show-LogEntry $_ }
}
else {
    $logContent = Get-Content $LogFile -Tail $Lines
    
    foreach ($line in $logContent) {
        Show-LogEntry $line
    }
    
    # Show summary
    Write-Host "`n📊 Summary:" -ForegroundColor Cyan
    $errors = ($logContent | Where-Object { $_ -match "\[ERROR\]" }).Count
    $warnings = ($logContent | Where-Object { $_ -match "\[WARNING\]" }).Count
    $success = ($logContent | Where-Object { $_ -match "\[SUCCESS\]" }).Count
    
    Write-Host "Errors: $errors" -ForegroundColor $(if ($errors -gt 0) { "Red" } else { "Green" })
    Write-Host "Warnings: $warnings" -ForegroundColor $(if ($warnings -gt 0) { "Yellow" } else { "Green" })
    Write-Host "Success: $success" -ForegroundColor Green
}

# Show last run time
$lastEntry = Get-Content $LogFile -Tail 1
if ($lastEntry -match "(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})") {
    $lastTime = [DateTime]::ParseExact($matches[1], "yyyy-MM-dd HH:mm:ss", $null)
    $timeSince = (Get-Date) - $lastTime
    Write-Host "`nLast activity: $($timeSince.TotalMinutes.ToString('0')) minutes ago" -ForegroundColor Gray
}