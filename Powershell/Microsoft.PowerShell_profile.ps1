### PowerShell template profile 
### Version 1.03 - Tim Sneath <tim@sneath.org>
### From https://gist.github.com/timsneath/19867b12eee7fd5af2ba
###
### This file should be stored in $PROFILE.CurrentUserAllHosts
### If $PROFILE.CurrentUserAllHosts doesn't exist, you can make one with the following:
###    PS> New-Item $PROFILE.CurrentUserAllHosts -ItemType File -Force
### This will create the file and the containing subdirectory if it doesn't already 
###
### As a reminder, to enable unsigned script execution of local scripts on client Windows, 
### you need to run this line (or similar) from an elevated PowerShell prompt:
###   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
### This is the default policy on Windows Server 2012 R2 and above for server Windows. For 
### more information about execution policies, run Get-Help about_Execution_Policies.
	# Find out if the current user identity is elevated (has admin rights)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$env:DOCUMENTS = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
$env:DESKTOP = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
$env:TEMP = [Environment]::GetEnvironmentVariable("Temp", [EnvironmentVariableTarget]::User)
$wingetdonotupdate = ($env:homedrive + '\wingetdonotupdate.txt')
# If so and the current host is a command line, then change to red color 
# as warning to user that they are operating in an elevated context
# Useful shortcuts for traversing directories
function cd...  { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }

# Compute file hashes - useful for checking successful downloads 
function md5    { Get-FileHash -Algorithm MD5 $args }
function sha1   { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

# Quick shortcut to start notepad
function n      { notepad++ $args }

# Drive shortcuts
function HKLM:  { Set-Location HKLM: }
function HKCU:  { Set-Location HKCU: }
function Env:   { Set-Location Env: }

# Set up command prompt and window title. Use UNIX-style convention for identifying 
# whether user is elevated (root) or not. Window title shows current version of PowerShell
# and appends [ADMIN] if appropriate for easy taskbar identification
function prompt 
{ 
    if ($isAdmin) 
    {
        "[" + (Get-Location) + "] # " 
    }
    else 
    {
        "[" + (Get-Location) + "] $ "
    }
}

$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
if ($isAdmin)
{
    $Host.UI.RawUI.WindowTitle += " [ADMIN]"
}

# Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
function dirs
{
    if ($args.Count -gt 0)
    {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
    }
    else
    {
        Get-ChildItem -Recurse | Foreach-Object FullName
    }
}

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin
{
    if ($args.Count -gt 0)
    {   
       $argList = "& '" + $args + "'"
       Start-Process "$psHome\pwsh.exe" -Verb runAs -ArgumentList $argList
    }
    else
    {
       Start-Process "$psHome\pwsh.exe" -Verb runAs
    }
}

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command
# with elevated rights. 
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin
Set-Alias -Name update-all -Value update
Set-Alias -Name winget-update -Value winget-update-all-except-skippedlist

# Make it easy to edit this profile once it's installed
function Edit-Profile
{
    if ($host.Name -match "ise")
    {
        $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
    }
    else
    {
        notepad $profile.CurrentUserAllHosts
    }
}

# We don't need these any more; they were just temporary variables to get to $isAdmin. 
# Delete them to prevent cluttering up the user profile. 
Remove-Variable identity
Remove-Variable principal

Function Test-CommandExists
{
 Param ($command)
 $oldPreference = $ErrorActionPreference
 $ErrorActionPreference = 'SilentlyContinue'
 try {if(Get-Command $command){RETURN $true}}
 Catch {Write-Host "$command does not exist"; RETURN $false}
 Finally {$ErrorActionPreference=$oldPreference}
} 
#
# Aliases
#
# If your favorite editor is not here, add an elseif and ensure that the directory it is installed in exists in your $env:Path
#
if (Test-CommandExists nvim) {
    $EDITOR='nvim'
} elseif (Test-CommandExists pvim) {
    $EDITOR='pvim'
} elseif (Test-CommandExists vim) {
    $EDITOR='vim'
} elseif (Test-CommandExists vi) {
    $EDITOR='vi'
} elseif (Test-CommandExists code) {
    #VS Code
    $EDITOR='code'
} elseif (Test-CommandExists notepad++) {
$EDITOR='notepad++'
} elseif (Test-CommandExists notepad) {
    #fallback to notepad since it exists on every windows machine
    $EDITOR='notepad'
}
Set-Alias -Name nano -Value $EDITOR


function ll { Get-ChildItem -Path $pwd -File }
Function update-bliss {
 $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!, installing BlissConsoles..."
       irm "https://github.com/DaddyMadu/BlissConsoles/raw/main/install.ps1" | iex
  }
  else
    {
Start-Process Powershell -Argumentlist '-ExecutionPolicy RemoteSigned -NoProfile -command "irm "https://github.com/DaddyMadu/BlissConsoles/raw/main/install.ps1" | iex"' -Verb RunAs
Exit
    }
}
Function disable-psupdates {
 New-Item -Path ($env:DOCUMENTS + '\WindowsPowerShell\donotupdate.txt') -ItemType File -Force
 New-Item -Path ($env:DOCUMENTS + '\Powershell\donotupdate.txt') -ItemType File -Force	
}
Function enable-psupdates {
 Remove-Item -Path ($env:DOCUMENTS + '\WindowsPowerShell\donotupdate.txt') -Force
 Remove-Item -Path ($env:DOCUMENTS + '\Powershell\donotupdate.txt') -Force	
}
Function disable-clinkupdate {
 New-Item -Path (${env:ProgramFiles(x86)} + '\clink\donotupdate.txt') -ItemType File -Force
}
Function enable-clinkupdate {
 Remove-Item -Path (${env:ProgramFiles(x86)} + '\clink\donotupdate.txt') -Force
}
Function disable-terminalupdate {
 New-Item -Path ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\donotupdate.txt') -ItemType File -Force
}
Function enable-terminalupdate {
 Remove-Item -Path ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\donotupdate.txt') -Force
}
Function get-ipinfo {
 $InfoFromJSON = Invoke-WebRequest -URI https://ifconfig.co/json | Select -expand Content | ConvertFrom-Json
 $FilteredJSON = $InfoFromJSON | Select-Object * -ExcludeProperty  ip_decimal,country_iso,country_eu,region_code,region_name,latitude,longitude,asn,user_agent
$FilteredJSON.asn_org |
    ForEach-Object{
        if ($FilteredJSON.asn_org -EQ "RAYA Telecom - Egypt") {
            $FilteredJSON.asn_org = 
                $FilteredJSON.asn_org.Replace("RAYA Telecom - Egypt", "Vodafone - Egypt")
        }
		elseif ($FilteredJSON.asn_org -EQ "TE-AS") {
            $FilteredJSON.asn_org = 
                $FilteredJSON.asn_org.Replace("TE-AS", "WE - Egypt")
        } else {
			$FilteredJSON.asn_org = 
                $FilteredJSON.asn_org
		}
    }
$FilteredJSON
}
function uptime {
	$bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
	$CurrentDate = Get-Date
	$uptime = $CurrentDate - $bootuptime
	Write-Output "Os Uptime --> Days: $($uptime.days), Hours: $($uptime.Hours), Minutes:$($uptime.Minutes), Seconds:$($uptime.Seconds)"
}
Function Edit-wingetskip {
if (!(Test-Path -Path $wingetdonotupdate -PathType Leaf)) {
 New-Item -Path $wingetdonotupdate -Force >$null
 nano $wingetdonotupdate
 } else {
 nano $wingetdonotupdate
 }
}
function winget-update-all-except-skippedlist {
if (!(Test-Path -Path $wingetdonotupdate -PathType Leaf)) {
 New-Item -Path $wingetdonotupdate -Force >$null
} else {
(Get-Content -path $wingetdonotupdate) | ? {$_.trim() -ne "" } | set-content $wingetdonotupdate
}
# add id to skip the update
$skipUpdate = @(Get-Content $wingetdonotupdate)
# object to be used basically for view only
class Software {
  [string]$Name
  [string]$Id
  [string]$Version
  [string]$AvailableVersion
}

# get the available upgrades
$upgradeResult = winget upgrade -u

# run through the list and get the app data
$upgrades = @()
$idStart = -1
$isStartList = 0
$upgradeResult | ForEach-Object -Process {

  if ($isStartList -lt 1 -and -not $_.StartsWith("Name") -or $_.StartsWith("---") -or $_.StartsWith("The following packages"))
  {
    return
  }

  if ($_.StartsWith("Name"))
  {
    $idStart = $_.toLower().IndexOf("id")
    $isStartList = 1
    return
  }

  if ($_.Length -lt $idStart)
  {
    return
  }

  $Software = [Software]::new()
  $Software.Name = $_.Substring(0, $idStart-1)
  $info = $_.Substring($idStart) -split '\s+'
  $Software.Id = $info[0]
  $Software.Version = $info[1]
  $Software.AvailableVersion = $info[2]

  $upgrades += $Software
}

# view the list
$upgrades | Format-Table

# run through the list, compare with the skip list and execute the upgrade (could be done in the upper foreach as well)
$upgrades | ForEach-Object -Process {

  if ($skipUpdate -contains $_.Id)
  {
    Write-Host "Skipped upgrade to package $($_.id)"
    return
  }

  Write-Host "Going to upgrade $($_.Id)"
  winget upgrade -u $_.Id
}
}
function update {
Write-Output "Checking for updates Please Wait, it will be installed shortly......"
Choco upgrade all -y -r --allowemptychecksum --allowemptychecksumsecure --ignore-checksums
winget-update
}
Function reboot {
Write-Output "Rebooting system......"
cmd /c 'C:\Windows\System32\shutdown.exe /r /f /t 0'
}
Function vpn {
if (Test-Path "$env:temp\dmtmp\DaddyMadu-VPN-VOIP.bat")
	{
Write-Output "Lunching DaddyMadu VPN Script...."
Start-Process -FilePath cmd.exe -ArgumentList "/c $env:temp\dmtmp\DaddyMadu-VPN-VOIP.bat"
	} else {
Write-Output "File not found!, downloading and lunching DaddyMadu VPN..."
Invoke-RestMethod 'https://github.com/DaddyMadu/Windows-Optimzier/raw/main/DaddyMadu-VPN-VOIP.bat' -OutFile ($env:temp + '\dmtmp\DaddyMadu-VPN-VOIP.bat')
Start-Process -FilePath cmd.exe -ArgumentList "/c $env:temp\dmtmp\DaddyMadu-VPN-VOIP.bat"
	}
}
Function dm {
if (Test-Path "$env:temp\dmtmp\DaddyMadu-VPN-VOIP.bat")
		{
Write-Output "Lunching DaddyMadu Windows Script...."
Start-Process -FilePath cmd.exe -ArgumentList "/c $env:temp\dmtmp\DaddyMadu-Windows-Optimizer.bat"	
} else {
Write-Output "File not found!, downloading and lunching DaddyMadu Windows Script..."
Invoke-RestMethod 'https://github.com/DaddyMadu/Windows-Optimzier/raw/main/DaddyMadu-Windows-Optimizer.bat' -OutFile ($env:temp + '\dmtmp\DaddyMadu-Windows-Optimizer.bat')
Start-Process -FilePath cmd.exe -ArgumentList "/c $env:temp\dmtmp\DaddyMadu-Windows-Optimizer.bat"
	}
}
Function resetdns {
Write-Host "Flush DNS + Reset IP...."
cmd /c 'netsh winsock reset 2>nul'
cmd /c 'netsh int ip reset 2>nul'
cmd /c 'ipconfig /release 2>nul'
cmd /c 'ipconfig /flushdns 2>nul'
cmd /c 'ipconfig /renew 2>nul'
Get-NetAdapter -Physical | ForEach-Object { Set-DnsClientServerAddress $_.Name -ServerAddresses ('108.61.209.16','') }
cmd /c 'echo Flush DNS + IP Reset Completed Successfully!'
}
Function cleartemp {
cmd /c 'echo Clearing Temp folders....'
cmd /c 'del /f /s /q %systemdrive%\*.tmp 2>nul'
cmd /c 'del /f /s /q %systemdrive%\*._mp 2>nul'
cmd /c 'del /f /s /q %systemdrive%\*.log 2>nul'
cmd /c 'del /f /s /q %systemdrive%\*.gid 2>nul'
cmd /c 'del /f /s /q %systemdrive%\*.chk 2>nul'
cmd /c 'del /f /s /q %systemdrive%\*.old 2>nul'
cmd /c 'del /f /s /q %systemdrive%\recycled\*.* 2>nul'
cmd /c 'del /f /s /q %windir%\*.bak 2>nul'
cmd /c 'del /f /s /q %windir%\prefetch\*.* 2>nul'
cmd /c 'del /f /q %userprofile%\cookies\*.* 2>nul'
cmd /c 'del /f /q %userprofile%\recent\*.* 2>nul'
cmd /c 'del /f /s /q %userprofile%\Local Settings\Temporary Internet Files\*.* 2>nul'
$errpref = $ErrorActionPreference #save actual preference
$ErrorActionPreference = "silentlycontinue"
Get-ChildItem -Path "$env:temp" -Exclude "dmtmp" | foreach ($_) {
       "CLEANING :" + $_.fullname
       Remove-Item $_.fullname -Force -Recurse
       "CLEANED... :" + $_.fullname
   }
$ErrorActionPreference = $errpref #restore previous preference
cmd /c 'del /f /s /q %userprofile%\recent\*.* 2>nul'
cmd /c 'del /f /s /q %windir%\Temp\*.* 2>nul'
choco-cleaner
cmd /c '"%systemdrive%\Program Files (x86)\Wise\Wise Registry Cleaner\WiseRegCleaner.exe" -a -safe'
cmd /c 'echo Temp folders Cleared Successfully!'
}
function repair {
Write-Host "Reparing windows system files...."
sfc /scannow
sfc /scannow
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /RestoreHealth
Write-Host "Repair completed successfully!"
}
function reload-profile {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait(". $")
    [System.Windows.Forms.SendKeys]::SendWait("PROFILE")
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}
function find-file($name) {
        Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
                $place_path = $_.directory
                Write-Output "${place_path}\${_}"
        }
}
function unzip ($file) {
    $dirname = (Get-Item $file).Basename
    New-Item -Force -ItemType directory -Path $dirname
    expand-archive $file -DestinationPath $dirname
}
function grep($regex, $dir) {
        if ( $dir ) {
                Get-ChildItem $dir | select-string $regex
                return
        }
        $input | select-string $regex
}
function touch($file) {
        "" | Out-File $file -Encoding ASCII
}
function df {
        get-volume
}
function sed($file, $find, $replace){
        (Get-Content $file).replace("$find", $replace) | Set-Content $file
}
function which($name) {
        Get-Command $name | Select-Object -ExpandProperty Definition
}
function export($name, $value) {
        set-item -force -path "env:$name" -value $value;
}
function pkill($name) {
        Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
function pgrep($name) {
        Get-Process $name
}
function gotodir($dir) {
if ((get-item $dir -erroraction silentlycontinue ) -is [system.io.directoryinfo]) {
cd $dir
} else {
cd (split-path -path $dir)
}
}
set-alias -name gd -value gotodir
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
Import-Module PSReadLine;
Import-Module Terminal-Icons;
