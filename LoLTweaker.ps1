# Sets Windows Title
$sScriptVersion = "v1.3"
$Host.UI.RawUI.WindowTitle = "LoLTweaker $sScriptVersion"

Function restore {
cd "C:\Downloads\Backup"
Move-Item "dbghelp.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "msvcp120.dll." "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "msvcr120.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "cg.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "cgD3D9.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "cgGL.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "dbghelp.dll" "$LoL\projects\lol_air_client\releases\$air\deploy"
Move-Item "tbb.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "NPSWF32.dll" "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources"
Move-Item "Adobe Air.dll" "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0"
Move-Item "cg.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy"
Move-Item "cgD3D9.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy"
Move-Item "cgGL.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy"
Move-Item "msvcp120.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy"
Move-Item "msvcr120.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy"
exit
}





    
function tweaks {


cls
# Disables Windows Services
Write-Host "Configuring Windows..."
Set-Service AppMgmt -StartupType Disabled | out-null
Set-Service bthserv -StartupType Disabled | out-null
Set-Service PeerDistSvc -StartupType Disabled | out-null
Set-Service CertPropSvc -StartupType Disabled | out-null
Set-Service NfsClnt -StartupType Disabled | out-null
Set-Service WPCSvc -StartupType Disabled | out-null
Set-Service vmickvpexchange -StartupType Disabled | out-null
Set-Service vmicguestinterface -StartupType Disabled | out-null
Set-Service vmicshutdown -StartupType Disabled | out-null
Set-Service vmicheartbeat -StartupType Disabled | out-null
Set-Service vmicrdv -StartupType Disabled | out-null
Set-Service vmictimesync -StartupType Disabled | out-null
Set-Service vmicvss -StartupType Disabled | out-null
Set-Service TrkWks -StartupType Disabled | out-null
Set-Service IEEtwCollectorService -StartupType Disabled | out-null
Set-Service iphlpsvc -StartupType Disabled | out-null
Set-Service MSiSCSI -StartupType Disabled | out-null
Set-Service Netlogon -StartupType Disabled | out-null
Set-Service napagent -StartupType Disabled | out-null
Set-Service CscService -StartupType Disabled | out-null
Set-Service WPCSvc -StartupType Disabled | out-null
Set-Service RpcLocator -StartupType Disabled | out-null
Set-Service SensrSvc -StartupType Disabled | out-null
Set-Service ScDeviceEnum -StartupType Disabled | out-null
Set-Service SCPolicySvc -StartupType Disabled | out-null
Set-Service RemoteRegistry -StartupType Disabled | out-null
Set-Service SCardSvr -StartupType Disabled | out-null
Set-Service SCPolicySvc -StartupType Disabled | out-null
Set-Service SNMPTRAP -StartupType Disabled | out-null
Set-Service StorSvc -StartupType Disabled | out-null
Set-Service wcncsvc -StartupType Disabled | out-null
Set-Service fsvc -StartupType Disabled | out-null
Set-Service WMPNetworkSvc -StartupType Disabled | out-null
Set-Service WSearch -StartupType Disabled | out-null

      }





Function patcher {
cls
Write-Host "Patching..."

#Copying Items
Copy-Item .\dbghelp.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" | Out-String
Copy-Item .\msvcp120.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" | Out-String
Copy-Item .\msvcr120.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" | Out-String
Copy-Item "$CG\cg.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" | Out-String
Copy-Item "$CG\cgD3D9.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" | Out-String
Copy-Item "$CG\cgGL.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" | Out-String
Copy-Item .\dbghelp.dll "$LoL\projects\lol_air_client\releases\$air\deploy" | Out-String
Copy-Item .\tbb.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" | Out-String
Copy-Item .\NPSWF32.dll "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources" | Out-String
Copy-Item ".\Adobe Air.dll" "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\" | Out-String
Copy-Item "$CG\cg.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy" | Out-String
Copy-Item "$CG\cgD3D9.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy" | Out-String
Copy-Item "$CG\cgGL.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy" | Out-String
Copy-Item .\msvcp120.dll "$LoL\projects\lol_launcher\releases\$launch\deploy" | Out-String
Copy-Item .\msvcr120.dll "$LoL\projects\lol_launcher\releases\$launch\deploy" | Out-String

cls
Set-Location $LoL
Set-Location ..
Start-Process .\lol.launcher.exe
$tbb = (Get-Command "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy\tbb.dll").FileVersionInfo.FileVersion
      if($tbb -eq "4, 2, 0, 0"){
      Read-Host "Patch Successfull, Press any Key to do Windows Tweaks"
      tweaks
         exit }
      ELSE {
      Read-Host "Patch Failed, Press any Key to do Windows Tweaks"
      tweaks
      exit}
      }
cls


function patch {
#Closing LoL
Stop-Process -ProcessName LoLLauncher | out-null
Stop-Process -ProcessName LoLClient | out-null


# These are not included in Powershell by default
cls
New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
cls
New-PSDrive HKU Registry HKEY_CURRENT_USER
cls

#Finds script directory
$dir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition


#Todo: Add PMB Uninstall


# Finds the LoL Directory from registry

$LoL = Get-ItemProperty "HKCR:\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\Riot Games\RADS" | Select-Object -ExpandProperty "LocalRootFolder"

#Nvidia CG Directory

$CG = Get-ItemProperty "HKU:\Environment" | Select-Object -ExpandProperty "CG_BIN_PATH"

# Setting variables for the latest LoL Updates

Set-Location $LoL\solutions\lol_game_client_sln\releases
$sln = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"

Move-Item "dbghelp.dll" "C:\Downloads\Backup" | Out-string
Move-Item "msvcp120.dll" "C:\Downloads\Backup" | Out-string
Move-Item "msvcr120.dll" "C:\Downloads\Backup" | Out-string
Move-Item "cg.dll" "C:\Downloads\Backup" | Out-string
Move-Item "cgD3D9.dll" "C:\Downloads\Backup" | Out-string
Move-Item "cgGL.dll" "C:\Downloads\Backup" | Out-string
Move-Item "tbb.dll" "C:\Downloads\Backup" | Out-string


Set-Location "$LoL\projects\lol_launcher\releases"
$launch = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"

Move-Item "dbghelp.dll" "C:\Downloads\Backup" | Out-string

Move-Item "msvcp120.dll" "C:\Downloads\Backup" | Out-string
Move-Item "msvcr120.dll" "C:\Downloads\Backup" | Out-string
Move-Item "cg.dll" "C:\Downloads\Backup" | Out-string
Move-Item "cgD3D9.dll" "C:\Downloads\Backup" | Out-string
Move-Item "cgGL.dll" "C:\Downloads\Backup" | Out-string


Set-Location $LoL\solutions\lol_air_client\releases
$air = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$air\deploy\adobe air\versions\1.0\"
Move-Item "Adobe Air.dll" "C:\Downloads\Backup" | Out-string

Set-Location .\resources
Move-Item "NPSWF32.dll" "C:\Downloads\Backup" | Out-string


Set-Location $dir

$title = "Main Menu"
$message = "Patch or Restore Backups"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "Patch"

$no = New-Object System.Management.Automation.Host.ChoiceDescription "Restore"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result1 = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result1)
    {
        0 {patcher}
        1 {restore}
    }
    }

   patch