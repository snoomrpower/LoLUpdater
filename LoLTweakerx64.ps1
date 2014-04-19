if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
$arguments = "& '" + $myinvocation.mycommand.definition + "'" + "-ExecutionPolicy Unrestricted"
Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $arguments
break
}

Function StartLoL {
Set-Location $LoL
Set-Location ..
Start-Process .\lol.launcher.exe
}
New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers -Name NewKey -Value "Default Value" -Force
New-ItemProperty  -Path  HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layer -Name "C:\Windows\Explorer.exe" -PropertyType "String" -Value 'NoDTToDITMouseBatch'
Invoke-Expression "Rundll32 apphelp.dll,ShimFlushCache"
$sScriptVersion = "1.3"
$Host.UI.RawUI.WindowTitle = "LoLTweaker $sScriptVersion"
$dir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$PMB = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Pando Networks\PMB" | Select-Object -ExpandProperty "Program Directory"
$LoL = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Riot Games\RADS" | Select-Object -ExpandProperty "LocalRootFolder"
$CG = Get-ItemProperty "HKLM:\SYSTEM\ControlSet001\Control\Session Manager\Environment" | Select-Object -ExpandProperty "CG_BIN64_PATH"
Start-Process $PMB\uninst.exe /s
Set-Location $dir
Set-Location ..
Invoke-Item Mouseaccel.vbs
Set-Location $dir
New-Item -Path C:\Downloads\Backup -ItemType Directory
Stop-Process -ProcessName LoLLauncher
Stop-Process -ProcessName LoLClient
$dir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Get-ChildItem -Recurse -Force  $LoL | Unblock-File
Set-Location $LoL\solutions\lol_game_client_sln\releases
$sln = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\dbghelp.dll C:\Downloads\Backup
Copy-Item .\msvcp110.dll C:\Downloads\Backup
Copy-Item .\msvcr110.dll C:\Downloads\Backup
Copy-Item .\msvcp120.dll C:\Downloads\Backup
Copy-Item .\msvcr120.dll C:\Downloads\Backup
Copy-Item .\cg.dll C:\Downloads\Backup
Copy-Item .\cgD3D9.dll C:\Downloads\Backup
Copy-Item .\cgGL.dll C:\Downloads\Backup
Copy-Item .\tbb.dll C:\Downloads\Backup
Set-Location $LoL\projects\lol_launcher\releases
$launch = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\msvcp120.dll C:\Downloads\Backup
Copy-Item .\msvcr120.dll C:\Downloads\Backup
Copy-Item .\cg.dll C:\Downloads\Backup
Copy-Item .\cgD3D9.dll C:\Downloads\Backup
Copy-Item .\cgGL.dll C:\Downloads\Backup
Set-Location $LoL\projects\lol_air_client\releases
$air = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe Air\versions\1.0"
Copy-Item "Adobe Air.dll" C:\Downloads\Backup
Set-Location "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe Air\versions\1.0\Resources"
Copy-Item .\NPSWF32.dll C:\Downloads\Backup
Set-Location $LoL\projects\lol_air_client\releases\$air\deploy
Copy-Item .\msvcp110.dll C:\Downloads\Backup
Copy-Item .\msvcr110.dll C:\Downloads\Backup
Set-Location $LoL\projects\lol_game_client\releases
$game = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\dbghelp.dll C:\Downloads\Backup
Copy-Item .\msvcp120.dll C:\Downloads\Backup
Copy-Item .\msvcr120.dll C:\Downloads\Backup
Copy-Item .\msvcp110.dll C:\Downloads\Backup
Copy-Item .\msvcr110.dll C:\Downloads\Backup
Copy-Item .\cg.dll C:\Downloads\Backup
Copy-Item .\cgD3D9.dll C:\Downloads\Backup
Copy-Item .\cgGL.dll C:\Downloads\Backup
Copy-Item .\tbb.dll C:\Downloads\Backup
Start-Process $PMB\uninst.exe /s
Set-Location $dir

$message = "Patch or Restore Backups"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Patch"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&Restore"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch ($result)
{
0 {
Set-Location $dir
Copy-Item .\dbghelp.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcp110.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcr110.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcp120.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcr120.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item $CG\cg.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item $CG\cgD3D9.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item $CG\cgGL.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\dbghelp.dll $LoL\projects\lol_air_client\releases\$air\deploy
Copy-Item .\tbb.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\NPSWF32.dll "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe Air\Versions\1.0\Resources"
Copy-Item "Adobe Air.dll" "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe Air\Versions\1.0"
Copy-Item .\msvcp110.dll $LoL\projects\lol_air_client\releases\$air\deploy
Copy-Item .\msvcr110.dll $LoL\projects\lol_air_client\releases\$air\deploy
Copy-Item $CG\cg.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item $CG\cgD3D9.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item $CG\cgGL.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\msvcp120.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\msvcr120.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\dbghelp.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\msvcp120.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\msvcr120.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\msvcp110.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\msvcr110.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item $CG\cg.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item $CG\cgD3D9.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item $CG\cgGL.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\tbb.dll $LoL\projects\lol_game_client\releases\$game\deploy
$tbb = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$LoL\solutions\lol_game_client_sln\releases\$sln\deploy\tbb.dll") | select -f 1 | Select-Object -ExpandProperty "FileVersion"
if($tbb -eq "4, 2, 0, 0"){
StartLoL
Read-Host "Patch Complete"
exit}
ELSE {
Read-Host "Patch Failed"
exit}
}
1 {
Set-Location C:\Downloads\Backup
Copy-Item .\dbghelp.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcp110.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcr110.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcp120.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcr120.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cg.dll  $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cgD3D9.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cgGL.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy 
Copy-Item .\dbghelp.dll $LoL\projects\lol_air_client\releases\$air\deploy
Copy-Item .\tbb.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\NPSWF32.dll "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources"
Copy-Item .\Adobe Air.dll "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0"
Copy-Item .\msvcp110.dll $LoL\projects\lol_air_client\releases\$air\deploy
Copy-Item .\msvcr110.dll $LoL\projects\lol_air_client\releases\$air\deploy
Copy-Item .\cg.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\cgD3D9.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\cgGL.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\msvcp120.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\msvcr120.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\dbghelp.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\msvcp120.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\msvcr120.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\msvcp110.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\msvcr110.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\cg.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\cgD3D9.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\cgGL.dll $LoL\projects\lol_game_client\releases\$game\deploy
Copy-Item .\tbb.dll $LoL\projects\lol_game_client\releases\$game\deploy
StartLoL
Exit
}
}