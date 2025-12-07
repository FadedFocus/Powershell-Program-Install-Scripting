# download_installers.ps1 ver. 4.0.17
# Installs Programs
# Current Apps:
# Discord
# Repl.it Desktop App
# Wireshark
# SlimeVR

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


# === Process helper ===
function Stop-AppProcesses {
    param(
        [string[]]$NamePatterns
    )

    if (-not $NamePatterns -or $NamePatterns.Count -eq 0) {
        return
    }

    Write-Log "Checking for running processes: $($NamePatterns -join ', ')"

    foreach ($pattern in $NamePatterns) {
        try {
            # -Name supports wildcards like "slime*" or "Discord*"
            $procs = Get-Process -Name $pattern -ErrorAction SilentlyContinue
            if ($procs) {
                Write-Log "Stopping processes matching '$pattern': $($procs.Name -join ', ')"
                $procs | Stop-Process -Force
            }
            else {
                Write-Log "No processes found for pattern '$pattern'."
            }
        }
        catch {
            Write-Log "Error while stopping processes for pattern '$pattern': $($_.Exception.Message)"
        }
    }
}

# === Install checks ===
# Template for future apps:
# 1) Create a Test-APPNAMEInstalled function in the "Install checks" section.
# 2) Then use that function here with Install-App, like this
#
# $vscodeUrl       = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
# $vscodeInstaller = "$env:TEMP\VSCodeSetup.exe"
#
# $vscodeOk = Install-App `
#     -Name "Visual Studio Code" `
#     -Url $vscodeUrl `
#     -InstallerPath $vscodeInstaller `
#     -SilentArgs "/VERYSILENT /NORESTART" `
#     -IsInstalledCheck { Test-VSCodeInstalled }

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
    $pf86 = ${env:ProgramFiles(x86)}
    $exe = "$pf86\SlimeVR Server\slimevr.exe"
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

    # Download installer
    Write-Log "Downloading $Name from $Url to $InstallerPath"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $InstallerPath -UseBasicParsing
        Write-Log "$Name download completed successfully."
    }
    catch {
        Write-Log "$Name download FAILED: $($_.Exception.Message)"
        Write-Log "---------- $Name finished (FAIL: download) ----------"
        return $false
    }

    # Run installer
    Write-Log "Running $Name installer with args: $SilentArgs"
    $exitCode = $null
    try {
        if ([string]::IsNullOrWhiteSpace($SilentArgs)) {
            $process = Start-Process -FilePath $InstallerPath -PassThru
        }
        else {
            $process = Start-Process -FilePath $InstallerPath -ArgumentList $SilentArgs -PassThru
        }
        $process.WaitForExit()
        $exitCode = $process.ExitCode
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

# For new apps, follow this pattern:
# 1) Define the Test-APPNAMEInstalled function above.
# 2) Set $appUrl and $appInstaller here in the script.
# 3) Call Install-App and capture its boolean result.
# 4) Track overall success with $allOk and $failedApps.

$allOk = $true
$failedApps = @()

# === Discord ===
$discordUrl       = "https://discord.com/api/download?platform=win"
$discordInstaller = "$env:TEMP\DiscordSetup.exe"

$discordOk = Install-App `
    -Name "Discord" `
    -Url $discordUrl `
    -InstallerPath $discordInstaller `
    -SilentArgs "/S" `
    -IsInstalledCheck { Test-DiscordInstalled }

if (-not $discordOk) {
    $allOk = $false
    $failedApps += "Discord"
}

# === Replit Desktop App ===
$replitUrl       = "https://desktop.replit.com/public/Replit%20Setup.exe"
$replitInstaller = "$env:TEMP\ReplitSetup.exe"

$replitOk = Install-App `
    -Name "Replit Desktop" `
    -Url $replitUrl `
    -InstallerPath $replitInstaller `
    -SilentArgs "/S" `
    -IsInstalledCheck { Test-ReplitInstalled }

if (-not $replitOk) {
    $allOk = $false
    $failedApps += "Replit Desktop"
}

# === Wireshark ===
$wiresharkUrl       = "https://www.wireshark.org/download/win64/all-versions/Wireshark-latest-x64.exe"
$wiresharkInstaller = "$env:TEMP\WiresharkSetup.exe"

$wiresharkOk = Install-App `
    -Name "Wireshark" `
    -Url $wiresharkUrl `
    -InstallerPath $wiresharkInstaller `
    -SilentArgs "/S" `
    -IsInstalledCheck { Test-WiresharkInstalled }

if (-not $wiresharkOk) {
    $allOk = $false
    $failedApps += "Wireshark"
}

# === slimeVR ===
# NOTE:
# - slimeVR needs the full UI so it can find your SteamVR folder, no silent args.
# - We also kill any running SlimeVR processes first to avoid the "already running" wizard error.

$slimeVRUrl        = "https://github.com/SlimeVR/SlimeVR-Installer/releases/latest/download/slimevr_web_installer.exe"
$slimeVRInstaller  = "$env:TEMP\slimeVR.exe"

Stop-AppProcesses -NamePatterns @('SlimeVR*')

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
#     -SilentArgs "/VERYSILENT /NORESTART" `
#     -IsInstalledCheck { Test-VSCodeInstalled }

# if (-not $vscodeOk) {
#     $allOk = $false
#     $failedApps += "Visual Studio Code"
# }

# === Result aggregation ===

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
    $allOk = $false
    $failedApps += "Wireshark"
}

# Record slimeVR result
if (-not $slimeVROk) {
    $allOk = $false
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
