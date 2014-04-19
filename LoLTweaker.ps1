# Take care of CG


if(-not(Test-Path C:\Downloads\Backup)){
New-Item -Path C:\Downloads\Backup -ItemType Directory
}
# Sets Windows Title
$sScriptVersion = "v1.3"
$Host.UI.RawUI.WindowTitle = "LoLTweaker $sScriptVersion"

#Closing LoL
if((Get-Process -ProcessName LoLLauncher )){
Stop-Process -ProcessName LoLLauncher
}
if(Get-Process -ProcessName LoLClient){
Stop-Process -ProcessName LoLClient
}




#Finds script directory
$dir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
# Setting variables for the latest LoL Updates
Set-Location "$dir\RADS\solutions\lol_game_client_sln\releases"
$sln = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item .\dbghelp.dll -destination "C:\Downloads\Backup"
Move-Item .\msvcp120.dll "C:\Downloads\Backup" 
Move-Item .\msvcr120.dll "C:\Downloads\Backup"
# Move-Item .\cg.dll "C:\Downloads\Backup"
# Move-Item .\cgD3D9.dll "C:\Downloads\Backup"
# Move-Item .\cgGL.dll "C:\Downloads\Backup"
Move-Item .\tbb.dll "C:\Downloads\Backup"


Set-Location "$dir\RADS\projects\lol_launcher\releases"
$launch = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
Move-Item .\dbghelp.dll "C:\Downloads\Backup" 

Move-Item .\msvcp120.dll "C:\Downloads\Backup" 
Move-Item .\msvcr120.dll "C:\Downloads\Backup" 
Move-Item .\cg.dll "C:\Downloads\Backup" 
Move-Item .\cgD3D9.dll "C:\Downloads\Backup" 
Move-Item .\cgGL.dll "C:\Downloads\Backup" 


Set-Location $dir
Set-Location "RADS\projects\lol_air_client\releases"
$air = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$dir\RADS\projects\lol_air_client\releases\$air\deploy\adobe air\versions\1.0"
Move-Item "Adobe Air.dll" "C:\Downloads\Backup" 

Set-Location "$dir\RADS\projects\lol_air_client\releases\$air\deploy\adobe air\versions\1.0\Resources"
Move-Item .\NPSWF32.dll "C:\Downloads\Backup" 


Set-Location $dir

$title = "Main Menu"
$message = "Patch or Restore Backups"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "Patch"

$no = New-Object System.Management.Automation.Host.ChoiceDescription "Restore"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result1 = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result1)
    {
        0 {
cls
Write-Host "Patching..."

#Copying Items
Set-Location $dir
Copy-Item .\dbghelp.dll "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item .\msvcp120.dll "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item .\msvcr120.dll "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
# Copy-Item "$CG\cg.dll" "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
# Copy-Item "$CG\cgD3D9.dll" "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
# Copy-Item "$CG\cgGL.dll" "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item .\dbghelp.dll "RADS\projects\lol_air_client\releases\$air\deploy" 
Copy-Item .\tbb.dll "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item .\NPSWF32.dll "RADS\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources" 
Copy-Item ".\Adobe Air.dll" "RADS\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\" 
Copy-Item "$CG\cg.dll" "RADS\projects\lol_launcher\releases\$launch\deploy" 
Copy-Item "$CG\cgD3D9.dll" "RADS\projects\lol_launcher\releases\$launch\deploy" 
Copy-Item "$CG\cgGL.dll" "RADS\projects\lol_launcher\releases\$launch\deploy" 
Copy-Item .\msvcp120.dll "RADS\projects\lol_launcher\releases\$launch\deploy" 
Copy-Item .\msvcr120.dll "RADS\projects\lol_launcher\releases\$launch\deploy" 


Start-Process .\lol.launcher.exe
$tbb = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("RADS\solutions\lol_game_client_sln\releases\$sln\deploy\tbb.dll") | select -f 1 | Select-Object -ExpandProperty "FileVersion"
      if($tbb -eq "4, 2, 0, 0"){
      Read-Host "Patch Successfull, Press any Key to do Windows Tweaks"
         exit }
      ELSE {
      Read-Host "Patch Failed, Press any Key to do Windows Tweaks"
      exit}
      }
      }
      
        1 
        cd C:\Downloads\Backup
Move-Item "dbghelp.dll" "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "msvcp120.dll." "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "msvcr120.dll" "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
# Move-Item "cg.dll" "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
# Move-Item "cgD3D9.dll" "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
# Move-Item "cgGL.dll" "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "dbghelp.dll" "$dir\RADS\projects\lol_air_client\releases\$air\deploy"
Move-Item "tbb.dll" "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "NPSWF32.dll" "$dir\RADS\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources"
Move-Item "Adobe Air.dll" "$dir\RADS\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0"
# Move-Item "cg.dll" "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
# Move-Item "cgD3D9.dll" "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
# Move-Item "cgGL.dll" "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
Move-Item "msvcp120.dll" "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
Move-Item "msvcr120.dll" "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
Read-Host "Restoring Successfull"

    
   
