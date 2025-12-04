# download_installers.ps1
# Installs Discord with logging and verification.

# === Config ===
$discordUrl    = "https://discord.com/api/download?platform=win&format=exe"
$installerPath = "$env:TEMP\DiscordSetup.exe"
$logPath       = Join-Path $PSScriptRoot "download_installers.log"

# === Logging helper ===
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Message"
    Write-Host $line
    Add-Content -Path $logPath -Value $line
}

# === Install check ===
function Test-DiscordInstalled {
    $exe = "$env:LocalAppData\Discord\Update.exe"
    return (Test-Path $exe)
}

Write-Log "---------- Discord install started ----------"

# If installed, skip
if (Test-DiscordInstalled) {
    Write-Log "Discord already installed. Skipping."
    Write-Log "---------- Finished (Already Installed) ----------"
    exit 0
}

# Download Discord
Write-Log "Downloading Discord from $discordUrl to $installerPath"

try {
    Invoke-WebRequest -Uri $discordUrl -OutFile $installerPath -ErrorAction Stop
    Write-Log "Download completed successfully."
}
catch {
    Write-Log "Download FAILED: $($_.Exception.Message)"
    Write-Log "---------- Finished (Download Failure) ----------"
    exit 1
}

# Run installer silently
Write-Log "Runn
