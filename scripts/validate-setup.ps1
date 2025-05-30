# Validation script for Ziglets CI/CD setup
Write-Host "=== Ziglets CI/CD Validation ===" -ForegroundColor Green

# Check required files
$RequiredFiles = @(
    "build.zig",
    "build.zig.zon", 
    "README.md",
    "CHANGELOG.md",
    "RELEASE_NOTES.md",
    "src\main.zig",
    "scripts\deploy-linux.sh",
    "scripts\deploy-windows.ps1",
    ".github\workflows\ci.yml",
    ".github\workflows\release.yml"
)

Write-Host "`n=== Checking Required Files ===" -ForegroundColor Yellow
foreach ($File in $RequiredFiles) {
    if (Test-Path $File) {
        Write-Host "✅ $File" -ForegroundColor Green
    } else {
        Write-Host "❌ $File" -ForegroundColor Red
    }
}

Write-Host "`n✅ CI/CD setup validation complete!" -ForegroundColor Green
