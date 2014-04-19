Set-ExecutionPolicy RemoteSigned
$LoL = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Riot Games\RADS" | Select-Object -ExpandProperty "LocalRootFolder"
$CG = Get-ItemProperty "HKLM:\SYSTEM\ControlSet001\Control\Session Manager\Environment" | Select-Object -ExpandProperty "CG_BIN_PATH"
$PMB = Get-ItemProperty "HKLM:\\SOFTWARE\Wow6432Node\Pando Networks\PMB" | Select-Object -ExpandProperty "Program Directory"

New-Item -Path C:\Downloads\Backup -ItemType Directory
# Sets Windows Title
$sScriptVersion = "v1.3"
$Host.UI.RawUI.WindowTitle = "LoLTweaker $sScriptVersion"

#Closing LoL
Stop-Process -ProcessName LoLLauncher  
Stop-Process -ProcessName LoLClient  





#Finds script directory
$dir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
# Setting variables for the latest LoL Updates
Set-Location "$LoL\solutions\lol_game_client_sln\releases"  
$sln = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"  
Move-Item .\dbghelp.dll -destination "C:\Downloads\Backup"  
Move-Item .\msvcp120.dll "C:\Downloads\Backup"   
Move-Item .\msvcr120.dll "C:\Downloads\Backup"  
Move-Item .\cg.dll "C:\Downloads\Backup"  
Move-Item .\cgD3D9.dll "C:\Downloads\Backup"  
Move-Item .\cgGL.dll "C:\Downloads\Backup"  
Move-Item .\tbb.dll "C:\Downloads\Backup"  


Set-Location "$LoL\projects\lol_launcher\releases"
$launch = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$LoL\projects\lol_launcher\releases\$launch\deploy"
Move-Item .\msvcp120.dll "C:\Downloads\Backup"   
Move-Item .\msvcr120.dll "C:\Downloads\Backup"   
Move-Item .\cg.dll "C:\Downloads\Backup"   
Move-Item .\cgD3D9.dll "C:\Downloads\Backup"   
Move-Item .\cgGL.dll "C:\Downloads\Backup"   

Set-Location "$LoL\projects\lol_air_client\releases"
$air = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$LoL\projects\lol_air_client\releases\$air\deploy\adobe air\versions\1.0"  
Move-Item "Adobe Air.dll" "C:\Downloads\Backup"   

Set-Location "$LoL\projects\lol_air_client\releases\$air\deploy\adobe air\versions\1.0\Resources"
Move-Item .\NPSWF32.dll "C:\Downloads\Backup"   

Start-Process $PMB\uninst.exe /s  
Set-Location $dir
cls
$title = "Main Menu"
$message = "Patch or Restore Backups"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "Patch"

$no = New-Object System.Management.Automation.Host.ChoiceDescription "Restore"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {
cls
Write-Host "Patching..."

#Copying Items
Set-Location $dir
Copy-Item .\dbghelp.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"  
Copy-Item .\msvcp120.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"   
Copy-Item .\msvcr120.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"   
Copy-Item "$CG\cg.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"   
Copy-Item "$CG\cgD3D9.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"   
Copy-Item "$CG\cgGL.dll" "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"   
Copy-Item .\dbghelp.dll "$LoL\projects\lol_air_client\releases\$air\deploy"   
Copy-Item .\tbb.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"   
Copy-Item .\NPSWF32.dll "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources"   
Copy-Item ".\Adobe Air.dll" "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\"   
Copy-Item "$CG\cg.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy"   
Copy-Item "$CG\cgD3D9.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy"   
Copy-Item "$CG\cgGL.dll" "$LoL\projects\lol_launcher\releases\$launch\deploy"   
Copy-Item .\msvcp120.dll "$LoL\projects\lol_launcher\releases\$launch\deploy" 
Copy-Item .\msvcr120.dll "$LoL\projects\lol_launcher\releases\$launch\deploy"   

Set-Location $LoL
Set-Location ..
Start-Process .\lol.launcher.exe  
$tbb = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$LoL\solutions\lol_game_client_sln\releases\$sln\deploy\tbb.dll") | select -f 1 | Select-Object -ExpandProperty "FileVersion"
      if($tbb -eq "4, 2, 0, 0"){
      Read-Host "Patch Successfull"
         exit }
      ELSE {
      Read-Host "Patch Failed"
      exit}
      }
      }
      
        1 
Set-Location C:\Downloads\Backup
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
Read-Host "Restoring Successfull"

    
   
