cls
$host.ui.RawUI.WindowTitle = "BlissConsoles installer"
cmd /c 'title [BlissConsoles installer]'
Write-Host 'Welcome to BlissConsoles installer';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
$env:DOCUMENTS = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families
New-PSDrive -Name HKCU -PSProvider Registry -Root HKEY_CURRENT_USER | Out-Null
cls
$installationsteps = @(
	### Require administrator privileges ###
	"RequireAdmin",
	"CreateRestorePoint",
 	"installfonts",
  	"preinstallation",
  	"updatepsprofiles",
	"Finished"
)

#check administrator privilage
Function RequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
		Exit
	}
}
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
   If(-not(Get-InstalledScript winget-install -ErrorAction silentlycontinue)){
    Install-Script -Name winget-install -Confirm:$False -Force
  }
  winget-install
  winget-install -CheckForUpdate
  Start-Sleep -Second 3
  winget install -e --accept-source-agreements --accept-package-agreements Microsoft.WindowsTerminal
  winget install -e --accept-source-agreements --accept-package-agreements Microsoft.PowerShell
  winget install -e --accept-source-agreements --accept-package-agreements JanDeDobbeleer.OhMyPosh
  winget install -e --accept-source-agreements --accept-package-agreements chrisant996.Clink
  Install-Module -Name Terminal-Icons -Repository PSGallery -Force
  Install-Module -Name PSReadLine -Repository PSGallery -Force
}

#installing required fonts
Function installfonts {
Write-Output "Installing required fonts..."
# Check if CaskaydiaCove NF is installed #Christitus script
if ($fontFamilies -notcontains "CaskaydiaCove NF") {
    
    # Download and install CaskaydiaCove NF
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CascadiaCode.zip", ".\CascadiaCode.zip")

    Expand-Archive -Path ".\CascadiaCode.zip" -DestinationPath ".\CascadiaCode" -Force
    $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
    Get-ChildItem -Path ".\CascadiaCode" -Recurse -Filter "*.ttf" | ForEach-Object {
        If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {        
            # Install font
            $destination.CopyHere($_.FullName, 0x10)
        }
    }
    # Clean up
    Remove-Item -Path ".\CascadiaCode" -Recurse -Force
    Remove-Item -Path ".\CascadiaCode.zip" -Force
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
      		 Get-Item -Path ($env:DOCUMENTS + '\WindowsPowerShell\Microsoft.PowerShell_profile.ps1') | Move-Item -Destination ($env:DOCUMENTS + '\WindowsPowerShell\profilebackup.ps1') -Force | Out-Null
                 Invoke-RestMethod 'https://github.com/DaddyMadu/BlissConsoles/raw/main/WindowsPowerShell/Microsoft.PowerShell_profile.ps1' -OutFile ($env:DOCUMENTS + '\WindowsPowerShell\Microsoft.PowerShell_profile.ps1')
            } else {
	    	 Write-Output "Backup profile found, updating active profile to latest one..."
                 Invoke-RestMethod 'https://github.com/DaddyMadu/BlissConsoles/raw/main/WindowsPowerShell/Microsoft.PowerShell_profile.ps1' -OutFile ($env:DOCUMENTS + '\WindowsPowerShell\Microsoft.PowerShell_profile.ps1')
              }
   if (!(Test-Path -Path ($env:DOCUMENTS + '\Powershell'))) {
   		Write-Output "Creating powershell 7 profile folder..."
                New-Item -Path ($env:DOCUMENTS + '\Powershell') -ItemType "directory"
                }
            elseif (!(Test-Path -Path ($env:DOCUMENTS + '\Powershell\profilebackup.ps1') -PathType Leaf)) {
	    	 Write-Output "Downloading powershell 7 profile and backing up old one if avaliable..."
       		 Get-Item -Path ($env:DOCUMENTS + '\Powershell\Microsoft.PowerShell_profile.ps1') | Move-Item -Destination ($env:DOCUMENTS + '\Powershell\profilebackup.ps1') -Force | Out-Null
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
                 Get-Item -Path (${env:ProgramFiles(x86)} + '\clink\oh-my-posh.lua') | Move-Item -Destination (${env:ProgramFiles(x86)} + '\clink\oh-my-posh.bk') -Force | Out-Null
                 Invoke-RestMethod 'https://github.com/DaddyMadu/BlissConsoles/raw/main/clink/oh-my-posh.lua' -OutFile (${env:ProgramFiles(x86)} + '\clink\oh-my-posh.lua')
            }
     }
  if (!(Test-Path -Path ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'))) {
  		Write-Output "Creating windows terminal settings folder..."
                New-Item -Path ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState') -ItemType "directory"
                }
            elseif (!(Test-Path -Path ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settingsbk.json') -PathType Leaf)) {
	    	 Write-Output "Backing old settings file for windows terminal and downloading custom settings file..."
                 Get-Item -Path ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json') | Move-Item -Destination ($env:LOCALAPPDATA + '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settingsbk.json') -Force
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
    Get-ChildItem -Path "HKCU:\Console" -Exclude "%%Startup*","*pwsh*" | ForEach {
  		Set-ItemProperty -Path $_.PsPath -Name "ColorTable05" -Type DWord -Value 0x00562401 -Force
  		Set-ItemProperty -Path $_.PsPath -Name "ColorTable06" -Type DWord -Value 0x00f0edee -Force
    		Set-ItemProperty -Path $_.PsPath -Name "FontFamily" -Type DWord -Value 0x00000036 -Force
      		Set-ItemProperty -Path $_.PsPath -Name "FontWeight" -Type DWord -Value 0x00000190 -Force
		Set-ItemProperty -Path $_.PsPath -Name "ScreenColors" -Type DWord -Value 0x00000056 -Force
  		Set-ItemProperty -Path $_.PsPath -Name "PopupColors" -Type DWord -Value 0x000000f3 -Force
    		Set-ItemProperty -Path $_.PsPath -Name "FaceName" -Type String -Value 'CaskaydiaCove NFM' -Force
	}
    Get-ChildItem -Path "HKCU:\Console" -Exclude "%%Startup*","*WindowsPowerShell*" | ForEach {
     Write-host "Customizing powershell 7 consoles color and font..."
		Set-ItemProperty -Path $_.PsPath -Name "ColorTable00" -Type DWord -Value 0x00342b27 -Force
    		Set-ItemProperty -Path $_.PsPath -Name "FontFamily" -Type DWord -Value 0x00000036 -Force
      		Set-ItemProperty -Path $_.PsPath -Name "FontWeight" -Type DWord -Value 0x00000190 -Force
    		Set-ItemProperty -Path $_.PsPath -Name "FaceName" -Type String -Value 'CaskaydiaCove NFM' -Force
      		Set-ItemProperty -Path $_.PsPath -Name "WindowAlpha" -Type DWord -Value 0x000000e8 -Force
	}
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
