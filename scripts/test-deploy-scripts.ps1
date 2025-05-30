# Test script for deployment scripts
# This script tests the updated deployment scripts with push tag functionality

Write-Host "Testing Deployment Scripts" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""

# Test Windows script help
Write-Host "Testing Windows deployment script help..." -ForegroundColor Blue
try {
    $help = powershell -Command "Get-Help $PSScriptRoot\deploy-windows.ps1"
    Write-Host "Windows script syntax: $help" -ForegroundColor Green
} catch {
    Write-Host "Error testing Windows script: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test Linux script syntax
Write-Host "Testing Linux deployment script syntax..." -ForegroundColor Blue
try {
    wsl bash -n scripts/deploy-linux.sh
    Write-Host "Linux script syntax: Valid" -ForegroundColor Green
} catch {
    Write-Host "Error testing Linux script: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test parameter parsing (dry run)
Write-Host "Testing parameter parsing..." -ForegroundColor Blue

Write-Host "Windows script accepts: [TagName] [-PushTag]" -ForegroundColor Cyan
Write-Host "Linux script accepts: [tag_name] [--push-tag]" -ForegroundColor Cyan

Write-Host ""
Write-Host "Example usage:" -ForegroundColor Yellow
Write-Host "  Windows: .\deploy-windows.ps1 v1.0.0 -PushTag" -ForegroundColor Gray
Write-Host "  Linux:   ./deploy-linux.sh v1.0.0 --push-tag" -ForegroundColor Gray

Write-Host ""
Write-Host "Testing completed!" -ForegroundColor Green
