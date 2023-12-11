cls
#check administrator privilage
Function RequireAdmin {
	#Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!, installing BlissConsoles..."
  }
  else
    {
Start-Process Powershell -Argumentlist '-ExecutionPolicy RemoteSigned -NoProfile -command "irm "https://github.com/DaddyMadu/BlissConsoles/raw/main/install.ps1" | iex"' -Verb RunAs
Exit
    }
}
RequireAdmin
cls
$host.ui.RawUI.WindowTitle = "BlissConsoles installer"
cmd /c 'title [BlissConsoles installer]'
Write-Host 'Welcome to BlissConsoles installer';
$errpref = $ErrorActionPreference #save actual preference
$ErrorActionPreference = "silentlycontinue"
Set-ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue >$null
$ErrorActionPreference = $errpref #restore previous preference
$env:DOCUMENTS = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$errpref = $ErrorActionPreference #save actual preference
$ErrorActionPreference = "silentlycontinue"
New-PSDrive -Name HKCU -PSProvider Registry -Root HKEY_CURRENT_USER -ErrorAction SilentlyContinue >$null
$ErrorActionPreference = $errpref #restore previous preference
$installationsteps = @(
	"CreateRestorePoint",
 	"installfonts",
  	"preinstallation",
  	"updatepsprofiles",
	"Finished"
)
#Create Restore Point
Function CreateRestorePoint {
  Write-Output "Creating Restore Point incase something bad happens"
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 0
  cmd /c 'vssadmin resize shadowstorage /on="%SystemDrive%" /For="%SystemDrive%" /MaxSize=5GB 2>nul' >$null
  Enable-ComputerRestore -Drive "$env:SystemDrive\"
  Checkpoint-Computer -Description "BeforeDaddyMaduScript" -RestorePointType "MODIFY_SETTINGS"
}

#setting up pre installation apps required for the rest to be functional
Function preinstallation {
	Write-Output "Getting things ready, installing chocolatey, winget, clink ...etc"
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
	choco install chocolatey-core.extension -y
 	choco install choco-cleaner -y
  if ((Get-PackageProvider -Name "NuGet" -Force).version -lt "2.8.5.208" ) {
    try {
		Write-Host "Checking if Nuget Package is installed..." (Get-PackageProvider -Name "NuGet").version
		Write-Host "Installing Nuget packageprovider updates..."
        Install-PackageProvider -Name "NuGet" -MinimumVersion "2.8.5.208" -Confirm:$False -Force 
    }
    catch [Exception]{
        $_.message 
        exit
    }
} else {
    Write-Host "Version of NuGet installed = " (Get-PackageProvider -Name "NuGet").version
}
   If(-not(Get-InstalledScript winget-install -ErrorAction silentlycontinue)){
    Install-Script -Name winget-install -Confirm:$False -Force
  }
   if ((winget -v) -lt "v1.6.3132" ) {
    try {
		Write-Host "Checking if winget is installed..." (winget)
		Write-Host "Installing winget updates..."
  		Add-AppxPackage -Path 'https://github.com/microsoft/winget-cli/releases/download/v1.6.3133/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
    }
    catch [Exception]{
        $_.message 
        exit
    }
} else {
    Write-Host "Version of winget installed = " (winget -v)
}
  winget upgrade winget -e --accept-source-agreements --accept-package-agreements
  Start-Sleep -Second 3
  winget install Microsoft.WindowsTerminal -e --accept-source-agreements --accept-package-agreements
  winget install Microsoft.PowerShell -e --accept-source-agreements --accept-package-agreements
  winget install JanDeDobbeleer.OhMyPosh -e --accept-source-agreements --accept-package-agreements
  winget install chrisant996.Clink -e --accept-source-agreements --accept-package-agreements
  if(-not (Get-Module Terminal-Icons -ListAvailable)){
  	Install-Module -Name Terminal-Icons -Repository PSGallery -Force
	}
  if(-not (Get-Module PSReadLine -ListAvailable)){
  	Install-Module -Name PSReadLine -Repository PSGallery -Force
	}
 #updating modules to latest versions
 Set-PSRepository PSGallery -InstallationPolicy Trusted >$null
 Get-InstalledModule | Update-Module
}
#installing required fonts
Function installfonts {
	 If (-not(Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\CaskaydiaCoveNerdFontMono-Regular.ttf")) {
$fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families
Write-Output "Installing required fonts..."
# Check if CaskaydiaCove NF is installed #Christitus script
if ($fontFamilies -notcontains "CaskaydiaCove NF") {
    # Download and install CaskaydiaCove NF
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CascadiaCode.zip", ".\CascadiaCode.zip")

    Expand-Archive -Path ".\CascadiaCode.zip" -DestinationPath ".\CascadiaCode" -Force
    $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
    Get-ChildItem -Path ".\CascadiaCode" -Recurse -Filter "*.ttf" | ForEach-Object {
        If (-not(Test-Path "$env:WINDIR\Fonts\$($_.Name)")) {        
            # Install font
            $destination.CopyHere($_.FullName, 0x10)
        }
    }
    # Clean up
    Remove-Item -Path ".\CascadiaCode" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path ".\CascadiaCode.zip" -Force -ErrorAction SilentlyContinue
		}
    } else {
    Write-Output "Font found, skipping download..."
	}
}
#update consoles profiles
Function updatepsprofiles {
  Write-Output "Updating powershell profiles..."
  if (!(Test-Path -Path ($env:DOCUMENTS + '\WindowsPowerShell'))) {
  		Write-Output "Creating powershell 5 profile folder..."
                New-Item -Path ($env:DOCUMENTS + '\WindowsPowerShell') -ItemType "directory"
                }
            elseif (!(Test-Path -Path ($env:DOCUMENTS + '\WindowsPowerShell\profilebackup.ps1') -PathType Leaf)) {
	    	Write-Output "Downloading powershell 5 profile and backing up old one if avaliable..."
      		$errpref = $ErrorActionPreference #save actual preference
		$ErrorActionPreference = "silentlycontinue"
      		 Get-Item -Path ($env:DOCUMENTS + '\WindowsPowerShell\Microsoft.PowerShell_profile.ps1') | Move-Item -Destination ($env:DOCUMENTS + '\WindowsPowerShell\profilebackup.ps1') -Force -ErrorAction SilentlyContinue >$null
	 	$ErrorActionPreference = $errpref #restore previous preference
                 Invoke-RestMethod 'https://github.com/DaddyMadu/BlissConsoles/raw/main/WindowsPowerShell/Microsoft.PowerShell_profile.ps1' -OutFile ($env:DOCUMENTS + '\WindowsPowerShell\Microsoft.PowerShell_profile.ps1')
            } else {
	    	 Write-Output "Backup profile found, updating active profile to latest one..."
                 Invoke-RestMethod 'https://github.com/DaddyMadu/BlissConsoles/raw/main/WindowsPowerShell/Microsoft.PowerShell_profile.ps1' -OutFile ($env:DOCUMENTS + '\WindowsPowerShell\Microsoft.PowerShell_profile.ps1')
              }
   if (!(Test-Path -Path ($env:DOCUMENTS + '\Powershell'))) {
   		Write-Output "Creating powershell 7 profile folder..."
                New-Item -Path ($env:DOCUMENTS + '\Powershell') -ItemType "directory" >$null
                }
            elseif (!(Test-Path -Path ($env:DOCUMENTS + '\Powershell\profilebackup.ps1') -PathType Leaf)) {
	    	 Write-Output "Downloading powershell 7 profile and backing up old one if avaliable..."
       		 $errpref = $ErrorActionPreference #save actual preference
		 $ErrorActionPreference = "silentlycontinue"
       		 Get-Item -Path ($env:DOCUMENTS + '\Powershell\Microsoft.PowerShell_profile.ps1') | Move-Item -Destination ($env:DOCUMENTS + '\Powershell\profilebackup.ps1') -Force -ErrorAction SilentlyContinue >$null
	  	 $ErrorActionPreference = $errpref #restore previous preference
                 Invoke-RestMethod 'https://github.com/DaddyMadu/BlissConsoles/raw/main/Powershell/Microsoft.PowerShell_profile.ps1' -OutFile ($env:DOCUMENTS + '\Powershell\Microsoft.PowerShell_profile.ps1')
            } else {
	    	 Write-Output "Backup profile found, updating active profile to latest one..."
                 Invoke-RestMethod 'https://github.com/DaddyMadu/BlissConsoles/raw/main/Powershell/Microsoft.PowerShell_profile.ps1' -OutFile ($env:DOCUMENTS + '\Powershell\Microsoft.PowerShell_profile.ps1')
              }
   if (!(Test-Path -Path (${env:ProgramFiles(x86)} + '\clink'))) {
                 Write-Output "Clink is not installed please rerun the script again..."
		 break
              }
	    elseif (!(Test-Path -Path (${env:ProgramFiles(x86)} + '\clink\oh-my-posh.lua') -PathType Leaf)) {
     		Write-Output "Add OMP theme to Clink and backing old clink profile if any..."
       		$errpref = $ErrorActionPreference #save actual preference
		$ErrorActionPreference = "silentlycontinue"
                 Get-Item -Path (${env:ProgramFiles(x86)} + '\clink\oh-my-posh.lua') | Move-Item -Destination (${env:ProgramFiles(x86)} + '\clink\oh-my-posh.bk') -Force -ErrorAction SilentlyContinue >$null
		 $ErrorActionPreference = $errpref #restore previous preference
                 Invoke-RestMethod 'https://github.com/DaddyMadu/BlissConsoles/raw/main/clink/oh-my-posh.lua' -OutFile (${env:ProgramFiles(x86)} + '\clink\oh-my-posh.lua')
            }
  if (!(Test-Path -Path ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'))) {
  		Write-Output "Creating windows terminal settings folder..."
                New-Item -Path ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState') -ItemType "directory" >$null
                }
            elseif (!(Test-Path -Path ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settingsbk.json') -PathType Leaf)) {
	    	 Write-Output "Backing old settings file for windows terminal and downloading custom settings file..."
       		 $errpref = $ErrorActionPreference #save actual preference
		 $ErrorActionPreference = "silentlycontinue"
                 Get-Item -Path ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json') | Move-Item -Destination ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settingsbk.json') -Force -ErrorAction SilentlyContinue >$null
		 $ErrorActionPreference = $errpref #restore previous preference
                 Invoke-RestMethod 'https://github.com/DaddyMadu/BlissConsoles/raw/main/settings.json' -OutFile ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json')
            } else {
	    	 Write-Output "Backup settings file for windows terminal found, updating custom settings file..."
                 Invoke-RestMethod 'https://github.com/DaddyMadu/BlissConsoles/raw/main/settings.json' -OutFile ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json')
              }
	Start-Sleep -Second 3
}

#finishing script and reloading profile
Function Finished {
    Write-host "Customizing powershell 5 consoles color and font..."
    		$errpref = $ErrorActionPreference #save actual preference
		$ErrorActionPreference = "silentlycontinue"
    Get-ChildItem -Path "HKCU:\Console" -Exclude "%%Startup*","*pwsh*" | ForEach {
  		Set-ItemProperty -Path $_.PsPath -Name "ColorTable05" -Type DWord -Value 0x00562401 -Force -ErrorAction SilentlyContinue
  		Set-ItemProperty -Path $_.PsPath -Name "ColorTable06" -Type DWord -Value 0x00f0edee -Force -ErrorAction SilentlyContinue
    		Set-ItemProperty -Path $_.PsPath -Name "FontFamily" -Type DWord -Value 0x00000036 -Force -ErrorAction SilentlyContinue
      		Set-ItemProperty -Path $_.PsPath -Name "FontWeight" -Type DWord -Value 0x00000190 -Force -ErrorAction SilentlyContinue
		Set-ItemProperty -Path $_.PsPath -Name "ScreenColors" -Type DWord -Value 0x00000056 -Force -ErrorAction SilentlyContinue
  		Set-ItemProperty -Path $_.PsPath -Name "PopupColors" -Type DWord -Value 0x000000f3 -Force -ErrorAction SilentlyContinue
    		Set-ItemProperty -Path $_.PsPath -Name "FaceName" -Type String -Value 'CaskaydiaCove NFM' -Force -ErrorAction SilentlyContinue
	}
    Get-ChildItem -Path "HKCU:\Console" -Exclude "%%Startup*","*WindowsPowerShell*" | ForEach {
     Write-host "Customizing powershell 7 consoles color and font..."
		Set-ItemProperty -Path $_.PsPath -Name "ColorTable00" -Type DWord -Value 0x00342b27 -Force -ErrorAction SilentlyContinue
    		Set-ItemProperty -Path $_.PsPath -Name "FontFamily" -Type DWord -Value 0x00000036 -Force -ErrorAction SilentlyContinue
      		Set-ItemProperty -Path $_.PsPath -Name "FontWeight" -Type DWord -Value 0x00000190 -Force -ErrorAction SilentlyContinue
    		Set-ItemProperty -Path $_.PsPath -Name "FaceName" -Type String -Value 'CaskaydiaCove NFM' -Force -ErrorAction SilentlyContinue
      		Set-ItemProperty -Path $_.PsPath -Name "WindowAlpha" -Type DWord -Value 0x000000e8 -Force -ErrorAction SilentlyContinue
	}
 		$ErrorActionPreference = $errpref #restore previous preference
   	Write-host "BlissConsoles installed successfully!, Please restart your terminal to get a Blissed Console ;)"
}


$preset = ""
$PSCommandArgs = $args
If ($args -And $args[0].ToLower() -eq "-preset") {
	$preset = Resolve-Path $($args | Select-Object -Skip 1)
	$PSCommandArgs = "-preset `"$preset`""
}

# Load function names from command line arguments or a preset file
If ($args) {
	$installationsteps = $args
	If ($preset) {
		$installationsteps = Get-Content $preset -ErrorAction Stop | ForEach { $_.Trim() } | Where { $_ -ne "" -and $_[0] -ne "#" }
	}
}

# Call the desired tweak functions
$installationsteps | ForEach { Invoke-Expression $_ }
