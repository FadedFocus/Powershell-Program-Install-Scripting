# download_installers.ps1
# Installs Discord and Replit Desktop App with logging and basic verification.

# === Global config ===
$logPath = Join-Path $PSScriptRoot "download_installers.log"

# === Logging helper ===
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Message"
    Write-Host $line
    Add-Content -Path $logPath -Value $line
}

# === Install checks ===
function Test-DiscordInstalled {
    $exe = "$env:LocalAppData\Discord\Update.exe"
    return (Test-Path $exe)
}

function Test-ReplitInstalled {
    # This path may differ; adjust after you install Replit once and confirm.
    $exe = "$env:LocalAppData\Replit\Replit.exe"
    return (Test-Path $exe)
}

# === Generic installer helper ===
function Install-App {
    param(
        [string]$Name,
        [string]$Url,
        [string]$InstallerPath,
        [string]$SilentArgs,
        [ScriptBlock]$IsInstalledCheck
    )

    Write-Log "---------- $Name install started ----------"

    if (& $IsInstalledCheck) {
        Write-Log "$Name already installed. Skipping."
        Write-Log "---------- $Name finished (Already Installed) ----------"
        return $true
    }

    Write-Log "Downloading $Name from $Url to $InstallerPath"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $InstallerPath -ErrorAction Stop
        Write-Log "$Name download completed successfully."
    }
    catch {
        Write-Log "$Name download FAILED: $($_.Exception.Message)"
        Write-Log "---------- $Name finished (Download Failure) ----------"
        return $false
    }

    Write-Log "Running $Name installer with args: $SilentArgs"
    try {
        $proc = Start-Process -FilePath $InstallerPath -ArgumentList $SilentArgs -Wait -PassThru
        $exitCode = $proc.ExitCode
        Write-Log "$Name installer exit code: $exitCode"
    }
    catch {
        Write-Log "$Name installer FAILED to start: $($_.Exception.Message)"
        $exitCode = -1
    }

    # Cleanup installer
    if (Test-Path $InstallerPath) {
        Remove-Item $InstallerPath -Force
        Write-Log "$Name installer cleaned up: $InstallerPath"
    }

    # Verify install
    $installedNow = & $IsInstalledCheck
    if ($exitCode -eq 0 -and $installedNow) {
        Write-Log "$Name installation SUCCESS."
        Write-Log "---------- $Name finished (OK) ----------"
        return $true
    }
    else {
        Write-Log "$Name installation FAILED. ExitCode=$exitCode; Installed=$installedNow"
        Write-Log "---------- $Name finished (FAIL) ----------"
        return $false
    }
}

# === Script start ===
Write-Log "========== download_installers.ps1 started =========="

# --- Discord ---
$discordUrl        = "https://discord.com/api/download?platform=win&format=exe"
$discordInstaller  = "$env:TEMP\DiscordSetup.exe"

$discordOk = Install-App `
    -Name "Discord" `
    -Url $discordUrl `
    -InstallerPath $discordInstaller `
    -SilentArgs "/S" `
    -IsInstalledCheck { Test-DiscordInstalled }

# --- Replit Desktop ---
# NOTE: This is pinned to v1.0.14 from the official GitHub releases page.
# If they release a new version, update the version in the URL.
$replitUrl        = "https://github.com/replit/desktop/releases/download/v1.0.14/Replit-1.0.14.Setup.exe"
$replitInstaller  = "$env:TEMP\ReplitSetup.exe"

$replitOk = Install-App `
    -Name "Replit Desktop" `
    -Url $replitUrl `
    -InstallerPath $replitInstaller `
    -SilentArgs "/S" `
    -IsInstalledCheck { Test-ReplitInstalled }

# === Additional applications (add more here later) ===
# Example template – copy, paste, and customize:
# function Test-VSCodeInstalled {
#     $exe = "C:\Program Files\Microsoft VS Code\Code.exe"
#     return (Test-Path $exe)
# }
#
# $vscodeUrl       = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
# $vscodeInstaller = "$env:TEMP\VSCodeSetup.exe"
#
# $vscodeOk = Install-App `
#     -Name "Visual Studio Code" `
#     -Url $vscodeUrl `
#     -InstallerPath $vscodeInstaller `
#     -SilentArgs "/verysilent" `
#     -IsInstalledCheck { Test-VSCodeInstalled }
#
# Remember: if you add more apps, also include them in the summary logic below.

# === Final summary / exit code ===
if ($discordOk -and $replitOk) {
    Write-Log "All installers completed successfully."
    Write-Log "========== download_installers.ps1 finished (OK) =========="
    exit 0
}
else {
    Write-Log "One or more installers FAILED. DiscordOK=$discordOk; ReplitOK=$replitOk"
    Write-Log "========== download_installers.ps1 finished (FAIL) =========="
    exit 1
}
