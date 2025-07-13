# Setup-BillFlow.ps1
Write-Host "BillFlow Setup Script" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

# Create default directories
$directories = @("./BillFlow_Backups")
foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✅ Created directory: $dir" -ForegroundColor Green
    }
}

# Copy template files
if (!(Test-Path "./BillFlow_Config.json")) {
    Copy-Item "./samples/BillFlow_Config_Template.json" -Destination "./BillFlow_Config.json"
    Write-Host "✅ Created default configuration file" -ForegroundColor Green
}

if (!(Test-Path "./BillFlow_Bills.csv")) {
    Copy-Item "./samples/BillFlow_Bills_Sample.csv" -Destination "./BillFlow_Bills.csv"
    Write-Host "✅ Created sample bills file" -ForegroundColor Green
}

Write-Host "`n✅ Setup complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit BillFlow_Config.json with your settings" -ForegroundColor White
Write-Host "2. Open BillFlow-Dashboard.html in your browser" -ForegroundColor White
Write-Host "3. Run ./BillFlow.ps1 to process bills" -ForegroundColor White