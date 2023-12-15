# BlissConsoles
Welcome to Bliss Consoles 
## how to install
open powershell from startmenu and paste the following code and press enter key!
```
irm "https://github.com/DaddyMadu/BlissConsoles/raw/main/install.ps1" | iex
```
this script was made to make your consoles windows beautiful 
using automation and combination of functions and modules to install and update winget, powershell 7, oh-my-posh, chocolatey, psreadline module, terminal-icons module, clink for command prompt
### update-bliss 
 this script is can self update itself and all installed modules, scripts, winget, choco, windows terminal setting file, clink lua file, powershell profiles for version 5/7 to thier latest versions.
using update-bliss command it will backup powershell profiles if found under the name profilebackup.ps1 so if you want get back to it at any time you can!
setting one theme only to rule them all "One Half Dark", from powershell 5/7, windows terminal to cmd!
using the following switchs you can enable/disable updates to specific parts of the script :
### disable-psupdates / enable-psupdates
disable-psupdates create donotupdate.txt file in powershells 5/7 directory that will make sure when using update-bliss command to skip updating those profiles.
will also delete profilebackup.ps1 from powershells 5/7 directory so when you enable update next time it will backup you current version of profiles before updating.
enable-psupdates will delete donotupdate.txt so you can continue updating ps profiles to latest modification i made.
### disable-clinkupdate / enable-clinkupdate
disable-clinkupdate will create donotupdate.txt in clink folder that will make the command update-bliss ignore updating ohmyposh.lua file 
enable-clinkupdate will delete donotupdate.txt so you can get our latest version of this file if we ever needed to update it.
### disable-terminalupdate / enable-terminalupdate
disable-terminalupdate will create donotupdate.txt in terminal directory that will perevent update-bliss from updating terminal setting file which i recommend any way if you gonna add other settings, themes , custom ssh session settings etc. 
enable-terminalupdate will make sure each time you use update-bliss terminal setting file will be in sync with what i have in this repository.
### update
this command will use winget to update every application installed in your system if avaliable exept the skipped list that you can define, it will also update every installed app via chocolatey.
### Edit-wingetskip / nano $wingetskipupdate
this will create wingetskipupdate.txt file in your systemdrive and from there you can add winget packages id that you want winget update to skip each time you use update or winget-update commands 
kindly know you need to add 1 winget id per line, exp:
powershell
gog.galaxy
etc
### reset
will reset you current powershell session and reload your profile 
### reboot
will restart your system
### vpn
will download and lunch my vpn script which grabs vpngate servers and add it your windows vpn and made aconnection to that server by default it will make the vpn route only voip traffic via vpn but you can press c at the end of script to make it system global.
### cleartemp
will clear all of your temp folders, logs, caches, chocolatey cashe files etc also if you have wise registery cleaner installed, it will use it to clean your registery also.
### resetdns
will reset winsocks, flush your dns release and renew your ip address.
### repair
this will trigger a sequance of commands to fix and repair your system using microsoft tools as sfc /scannow, DISM /Online /Cleanup-Image /CheckHealth, DISM /Online /Cleanup-Image /ScanHealth, DISM /Online /Cleanup-Image /RestoreHealth to keep your installation healthy
### dm
this will lunch or download and lunch my windows 10/11 optimizer read more here: https://github.com/DaddyMadu/Windows-Optimzier 
### get-ipinfo
this will get you info about your ip, country, service provider
### list of other useful functions :
md5\
sha1\
sha256\
n\
HKLM:\
HKCU:\
Env:\
admin / su / sudo\
Edit-Profile\
nano\
ll\
dirs\
find-file\
unzip\
grep\
touch\
df\
sed\
which\
export\
pkill\
pgrep\
gotodir / gd
