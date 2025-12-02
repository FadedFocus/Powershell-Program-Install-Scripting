# Download Discord Setup
$discordUrl = "https://discord.com/api/download?platform=win&format=exe"
$installerPath = "$env:TEMP\DiscordSetup.exe"

Invoke-WebRequest -Uri $discordUrl -OutFile $installerPath

# Run the installer silently
Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait

# Optional: delete installer afterward
Remove-Item $installerPath -Force
