# Deploy script for Windows - Ziglets Multi-platform Release
# This script builds Ziglets for multiple Windows targets and creates release artifacts
#
# Usage: .\deploy-windows.ps1 [tag_name] [-PushTag]
#
# Parameters:
#   TagName  - Git tag to deploy (e.g., v1.0.0)
#   PushTag  - If specified, pushes the tag to remote repository before deployment
#
# Prerequisites:
# - Zig compiler installed and available in PATH
# - Git repository with proper tags
# - Write permissions to create artifacts directory
# - Git remote configured for tag pushing

param(
    [string]$TagName = "",
    [switch]$PushTag = $false
)

# Script configuration
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$ArtifactsDir = Join-Path $ProjectRoot "artifacts"
$BuildDir = Join-Path $ProjectRoot "zig-out"

# Function to write colored output
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to check if we're on a tagged commit
function Test-Tag {
    param([string]$Tag)
    
    # Check if we're in a git repository
    try {
        git rev-parse --git-dir | Out-Null
    }
    catch {
        Write-Error-Custom "Not in a git repository"
        exit 1
    }
    
    # Check if the tag exists
    $TagExists = git tag -l | Where-Object { $_ -eq $Tag }
    if (-not $TagExists) {
        Write-Error-Custom "Tag '$Tag' does not exist"
        exit 1
    }
    
    # Check if we're currently on the tagged commit
    $CurrentCommit = git rev-parse HEAD
    $TagCommit = git rev-parse $Tag
    
    if ($CurrentCommit -ne $TagCommit) {
        Write-Error-Custom "Current commit is not the tagged commit for '$Tag'"
        Write-Error-Custom "Current: $CurrentCommit"
        Write-Error-Custom "Tagged:  $TagCommit"
        exit 1
    }
    
    Write-Success "Validated tag '$Tag' matches current commit"
}

# Function to validate semantic versioning tag format
function Test-SemverTag {
    param([string]$Tag)
    
    # Check if tag follows v*.*.* format (semantic versioning)
    if ($Tag -notmatch "^v\d+\.\d+\.\d+$") {
        Write-Error-Custom "Tag '$Tag' does not follow semantic versioning format (vMAJOR.MINOR.PATCH)"
        Write-Error-Custom "Expected format: v1.0.0, v2.1.3, etc."
        exit 1
    }
    
    Write-Success "Tag '$Tag' follows semantic versioning format"
}

# Function to push tag to remote repository
function Push-TagToRemote {
    param([string]$Tag)
    
    Write-Info "Pushing tag '$Tag' to remote repository..."
    
    try {
        # Check if remote origin exists
        $RemoteOrigin = git remote get-url origin 2>$null
        if (-not $RemoteOrigin) {
            Write-Error-Custom "No remote 'origin' configured"
            exit 1
        }
        
        Write-Info "Remote origin: $RemoteOrigin"
        
        # Push the specific tag to remote
        git push origin $Tag
        Write-Success "Successfully pushed tag '$Tag' to remote"
        
        # Optionally push all tags (commented out to be more conservative)
        # git push origin --tags
        # Write-Success "Pushed all tags to remote"
        
    }
    catch {
        Write-Error-Custom "Failed to push tag '$Tag' to remote: $($_.Exception.Message)"
        Write-Error-Custom "Make sure you have push permissions to the remote repository"
        exit 1
    }
}

# Function to build for a specific target
function Build-Target {
    param(
        [string]$Target,
        [string]$OutputName
    )
    
    Write-Info "Building for target: $Target"
    
    # Clean previous build
    if (Test-Path $BuildDir) {
        Remove-Item $BuildDir -Recurse -Force
    }
    
    # Build for the specific target
    try {
        & zig build "-Dtarget=$Target" "-Doptimize=ReleaseFast"
    }
    catch {
        Write-Error-Custom "Failed to build for target: $Target"
        return $false
    }
    
    # Create target-specific artifact directory
    $TargetDir = Join-Path $ArtifactsDir $Target
    New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
    
    # Determine binary extension and name
    $BinaryName = if ($Target -like "*windows*") { "ziglets.exe" } else { "ziglets" }
    $OutputBinary = if ($Target -like "*windows*") { "$OutputName.exe" } else { $OutputName }
    $BinaryPath = Join-Path $BuildDir "bin\$BinaryName"
    
    # Copy binary to artifacts directory
    if (Test-Path $BinaryPath) {
        Copy-Item $BinaryPath (Join-Path $TargetDir $OutputBinary)
        Write-Success "Built $OutputBinary for $Target"
    }
    else {
        Write-Error-Custom "Binary not found for target: $Target"
        return $false
    }
    
    # Create compressed archive
    $ArchiveName = "$OutputName-$Target.zip"
    $ArchivePath = Join-Path $ArtifactsDir $ArchiveName
    
    # Use PowerShell's Compress-Archive for creating zip files
    Compress-Archive -Path (Join-Path $TargetDir $OutputBinary) -DestinationPath $ArchivePath -Force
    Write-Success "Created archive: $ArchiveName"
    
    return $true
}

# Main deployment function
function Start-Deploy {
    param([string]$Tag)
    
    # If no tag provided, try to get current tag
    if ([string]::IsNullOrEmpty($Tag)) {
        try {
            $Tag = git describe --tags --exact-match 2>$null
        }
        catch {
            $Tag = ""
        }
          if ([string]::IsNullOrEmpty($Tag)) {
            Write-Error-Custom "No tag specified and current commit is not tagged"
            Write-Error-Custom "Usage: .\deploy-windows.ps1 [tag_name] [-PushTag]"
            Write-Error-Custom ""
            Write-Error-Custom "Parameters:"
            Write-Error-Custom "  tag_name  - Git tag to deploy (e.g., v1.0.0)"
            Write-Error-Custom "  -PushTag  - Push the tag to remote repository before deployment"
            exit 1
        }
    }
    
    Write-Info "Starting deployment for tag: $Tag"
    
    # Validate tag format
    Test-SemverTag $Tag
    
    # Push tag to remote if requested
    if ($PushTag) {
        Push-TagToRemote $Tag
    }
    
    # Validate that we're on the correct tag
    Test-Tag $Tag
    
    # Extract version from tag (remove 'v' prefix)
    $Version = $Tag.Substring(1)
    $OutputName = "ziglets-$Version"
    
    # Change to project root
    Set-Location $ProjectRoot
    
    # Clean and create artifacts directory
    if (Test-Path $ArtifactsDir) {
        Remove-Item $ArtifactsDir -Recurse -Force
    }
    New-Item -Path $ArtifactsDir -ItemType Directory -Force | Out-Null
    
    Write-Info "Building Ziglets version $Version for multiple Windows targets"
    
    # Define target platforms for Windows
    $Targets = @(
        "x86_64-windows-gnu",
        "x86_64-windows-msvc",
        "aarch64-windows-gnu"
    )
    
    # Build for each target
    $FailedBuilds = @()
    foreach ($Target in $Targets) {
        if (-not (Build-Target $Target $OutputName)) {
            $FailedBuilds += $Target
            Write-Warning "Failed to build for $Target, continuing with other targets"
        }
    }
    
    # Report results
    if ($FailedBuilds.Count -eq 0) {
        Write-Success "All Windows targets built successfully!"
    }
    else {
        Write-Warning "Some builds failed: $($FailedBuilds -join ', ')"
        Write-Warning "Successful builds are available in: $ArtifactsDir"
    }
    
    # Create checksums for all artifacts
    Set-Location $ArtifactsDir
    $ZipFiles = Get-ChildItem -Filter "*.zip"
    if ($ZipFiles.Count -gt 0) {
        $Checksums = @()
        foreach ($File in $ZipFiles) {
            $Hash = Get-FileHash $File.Name -Algorithm SHA256
            $Checksums += "$($Hash.Hash.ToLower())  $($File.Name)"
        }
        $Checksums | Out-File -FilePath "checksums.txt" -Encoding UTF8
        Write-Success "Created checksums.txt"
    }
    
    Write-Success "Deployment completed for tag: $Tag"
    Write-Info "Artifacts available in: $ArtifactsDir"
    
    # List created artifacts
    Write-Info "Created artifacts:"
    Get-ChildItem $ArtifactsDir | Format-Table -AutoSize
}

# Script entry point
function Main {
    Write-Info "Ziglets Windows Deployment Script"
    Write-Info "Project: $(Split-Path -Leaf $ProjectRoot)"
    Write-Info "Script: $($MyInvocation.MyCommand.Name)"
    Write-Info "Arguments: $($args -join ' ')"
    
    # Check prerequisites
    try {
        $ZigVersion = & zig version
        Write-Info "Using Zig: $ZigVersion"
    }
    catch {
        Write-Error-Custom "Zig compiler not found in PATH"
        exit 1
    }
    
    # Start deployment
    Start-Deploy $TagName
}

# Run main function
Main
