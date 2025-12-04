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
Write-Log "Running silent installer..."
$process = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru
$exitCode = $process.ExitCode

Write-Log "Installer exited with code: $exitCode"

# Clean up installer file
if (Test-Path $installerPath) {
    Remove-Item $installerPath -Force
    Write-Log "Installer cleaned up."
}

# Verify final install state
if ($exitCode -eq 0 -and (Test-DiscordInstalled)) {
    Write-Log "Discord installation SUCCESS."
    Write-Log "---------- Finished (OK) ----------"
    exit 0
} else {
    Write-Log "Discord installation FAILED. ExitCode=$exitCode; Exists=$((Test-DiscordInstalled))"
    Write-Log "---------- Finished (FAIL) ----------"
    exit 2
}

# === Replit Desktop App ===
$replitUrl        = "https://replit.com/desktop"  # official download page
$replitInstaller  = "$env:TEMP\ReplitSetup.exe"

Write-Log "Downloading Replit Desktop App from $replitUrl"
Invoke-WebRequest -Uri $replitUrl -OutFile $replitInstaller -ErrorAction Stop
Write-Log "Download of Replit setup done."

Write-Log "Running Replit installer..."
$replitProc = Start-Process -FilePath $replitInstaller -ArgumentList "/S" -Wait -PassThru
Write-Log "Replit installer exit code: $($replitProc.ExitCode)"

# Clean up
if (Test-Path $replitInstaller) {
    Remove-Item $replitInstaller -Force
    Write-Log "Removed installer file."
}

# Optionally check if Replit is installed (adjust path if needed)
$possiblePath1 = "$env:LOCALAPPDATA\Replit\Replit.exe"
if (Test-Path $possiblePath1 -and $replitProc.ExitCode -eq 0) {
    Write-Log "Replit Desktop App installation SUCCESS."
} else {
    Write-Log "Replit installation may have FAILED. Check manually."
}
