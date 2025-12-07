# download_installers.ps1
# Installs Programs
# Current Apps:
# Discord
# Repl.it Desktop App
# Wireshark [WIP]

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
# Template for future apps:
# 1) Create a Test-APPNAMEInstalled function in the "Install checks" section.
# 2) Then use that function here with Install-App, like this:
#
# function Test-VSCodeInstalled {
#     $exe = "C:\Program Files\Microsoft VS Code\Code.exe"
#     return (Test-Path $exe)
# }

function Test-DiscordInstalled {
    $exe = "$env:LocalAppData\Discord\Update.exe"
    return (Test-Path $exe)
}

function Test-ReplitInstalled {
    $exe = "$env:LocalAppData\Replit\Replit.exe"
    return (Test-Path $exe)
}

function Test-WiresharkInstalled {
    $exe = "$env:ProgramFiles\Wireshark\Wireshark.exe"
    return (Test-Path $exe)
}

function Test-slimeVRInstalled {
    $exe = "$env:ProgramFiles\slimeVR/slimeVR.exe"
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
$replitUrl        = "https://github.com/replit/desktop/releases/download/v1.0.14/Replit-1.0.14.Setup.exe"
$replitInstaller  = "$env:TEMP\ReplitSetup.exe"

$replitOk = Install-App `
    -Name "Replit Desktop" `
    -Url $replitUrl `
    -InstallerPath $replitInstaller `
    -SilentArgs "/S" `
    -IsInstalledCheck { Test-ReplitInstalled }

# --- Wireshark ---
$wiresharkUrl        = "https://2.na.dl.wireshark.org/win64/Wireshark-4.6.2-x64.exe"
$wiresharkInstaller  = "$env:TEMP\Wireshark.exe"

$wiresharkOk = Install-App `
    -Name "Wireshark" `
    -Url $wiresharkUrl `
    -InstallerPath $wiresharkInstaller `
    -SilentArgs "/S" `
    -IsInstalledCheck { Test-WiresharkInstalled }

# --- slimeVR ---
# UI is required to find your SteamVR folder, no avoiding that unfortunately
$slimeVRUrl        = "https://github.com/SlimeVR/SlimeVR-Installer/releases/latest/download/slimevr_web_installer.exe"
$slimeVRInstaller  = "$env:TEMP\slimeVR.exe"

$slimeVROk = Install-App `
    -Name "slimeVR" `
    -Url $slimeVRURL `
    -InstallerPath $slimeVRInstaller `
    -SilentArgs "/S" `
    -IsInstalledCheck { Test-slimeVRInstalled }

# === Additional applications (add more here later) ===
# TEMPLATE for future apps in the === Script start === section:
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

# === Track overall results ===
$allOk = $true
$failedApps = @()

# Record Discord result
if (-not $discordOk) {
    $allOk = $false
    $failedApps += "Discord"
}

# Record Replit result
if (-not $replitOk) {
    $allOk = $false
    $failedApps += "Replit Desktop"
}

# Record Wireshark result
if (-not $wiresharkOk) {
    $allOk - $false
    $failedApps += "Wireshark"
}

# Record slimeVR result
if (-not $slimeVROk) {
    $allOk - $false
    $failedApps += "SlimeVR"
}

# IMPORTANT:
# When you add new installers later, add their tracking here:
#
# if (-not $vscodeOk) {
#     $allOk = $false
#     $failedApps += "Visual Studio Code"
# }

# === Final summary / exit code ===
if ($allOk) {
    Write-Log "All installers completed successfully (including apps already installed)."
    Write-Log "========== download_installers.ps1 finished (OK) =========="
    exit 0
}
else {
    Write-Log "Some installers FAILED: $($failedApps -join ', ')"
    Write-Log "========== download_installers.ps1 finished (FAIL) =========="
    exit 1
}
