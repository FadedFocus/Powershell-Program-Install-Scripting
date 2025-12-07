-----------------------------------------------------------------------------------------------------------------------------
Build ver. 4.4.17
[Core script version based on # of apps, # of simple appending for new apps, 17 core code changes to stablize app installations]
-Discord
-Replit Desktop
-Wireshark UAC required
-SlimeVR UAC required

-----------------------------------------------------------------------------------------------------------------------------

Usage:
Runs a script to install programs for any windows 11 computer with git capabilities + openSSH(client/server) capabilities

-----------------------------------------------------------------------------------------------------------------------------

Pre-Requisites:
for git method - install git, openSSH client, openSSH server, github repo access MUST BE granted
otherwise use non-git method

-----------------------------------------------------------------------------------------------------------------------------

OPTIONAL pre-requisites: Set up environment variables in Win11 so you can do "run" instead of "./run.bat" in terminal
1. Press Start
2. Type: Environment Variables
3. Open "Edit the system environment variables"
4. Click the "Environment Variables..." Button on the bottom right
5. In the top box (User variables for [username]), find "Path"
6. Select it -> Click Edit
7. Click New
8. Past the folder path where "run.bat" lives: ((e.g. "C:\Users\[username]\Powershell-Program-Install-Scripting"))

-----------------------------------------------------------------------------------------------------------------------------

How-to-Use: [non-git]
1. Unzip the .zip into a folder anywhere you like(copy the folder path for the next steps & the OPTIONAL step)
2. open terminal (as administrator)
3. change directories to the unzipped folder you created (e.g. "cd C:\Users\[username]\Powershell-Program-Install-Scripting")
4. in terminal type in "run", and the prorams listed above should install, if not already.
5. DONE.

-----------------------------------------------------------------------------------------------------------------------------

How-to-Use: [assuming git is installed, openSSH client & openSSH server, github repo access is granted, AND OPTIONAL pre-requisites were followed]
1. in terminal change directory to where you want (e.g. cd E:\)
2. use "git clone [repo https link]" (e.g. git clone https://github.com/FadedFocus/Powershell-Program-Install-Scripting.git)
3. now change directory to the newly cloned repo "Powershell-Program-Install-Scripting" (e.g. cd E:\Powershell-Program-Install-Scripting\)
4. from now on you must be in that directory to run the script or update it using "git pull"
5. in terminal you can now type "run" and the script will run and silently install all programs UAC may be required
