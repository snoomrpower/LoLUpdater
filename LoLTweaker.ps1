if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'" + "-ExecutionPolicy RemoteSigned"
Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $arguments 
}
Set-ExecutionPolicy RemoteSigned
$sScriptVersion = "1.3"
$Host.UI.RawUI.WindowTitle = "LoLTweaker $sScriptVersion"
$dir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$PMB = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Pando Networks\PMB" | Select-Object -ExpandProperty "Program Directory"
$LoL = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Riot Games\RADS" | Select-Object -ExpandProperty "LocalRootFolder"
$CG = Get-ItemProperty "HKLM:\SYSTEM\ControlSet001\Control\Session Manager\Environment" | Select-Object -ExpandProperty "CG_BIN_PATH"
Start-Process $PMB\uninst.exe /s
New-Item -Path C:\Downloads\Backup -ItemType Directory
Stop-Process -ProcessName LoLLauncher  
Stop-Process -ProcessName LoLClient  
$dir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Get-ChildItem -Recurse -Force  $LoL | Unblock-File
Set-Location "$LoL\solutions\lol_game_client_sln\releases"  
$sln = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy"  
Copy-Item .\dbghelp.dll C:\Downloads\Backup
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
Set-Location $LoL\projects\lol_air_client\releases\$air\deploy\adobe air\versions\1.0\Resources
Copy-Item .\NPSWF32.dll C:\Downloads\Backup   
Start-Process $PMB\uninst.exe /s  
Set-Location $dir
$title = "Main Menu"
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
Copy-Item .\msvcp120.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy  
Copy-Item .\msvcr120.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy 
Copy-Item $CG\cg.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy 
Copy-Item $CG\cgD3D9.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy  
Copy-Item $CG\cgGL.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy 
Copy-Item .\dbghelp.dll $LoL\projects\lol_air_client\releases\$air\deploy  
Copy-Item .\tbb.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\NPSWF32.dll $LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources   
Copy-Item ".\Adobe Air.dll" $LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\
Copy-Item $CG\cg.dll $LoL\projects\lol_launcher\releases\$launch\deploy 
Copy-Item $CG\cgD3D9.dll $LoL\projects\lol_launcher\releases\$launch\deploy   
Copy-Item $CG\cgGL.dll $LoL\projects\lol_launcher\releases\$launch\deploy  
Copy-Item .\msvcp120.dll $LoL\projects\lol_launcher\releases\$launch\deploy 
Copy-Item .\msvcr120.dll $LoL\projects\lol_launcher\releases\$launch\deploy
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
Copy-Item .\msvcp120.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcr120.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cg.dll  $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cgD3D9.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy 
Copy-Item .\cgGL.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy 
Copy-Item .\dbghelp.dll $LoL\projects\lol_air_client\releases\$air\deploy 
Copy-Item .\tbb.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy 
Copy-Item .\NPSWF32.dll "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources"  
Copy-Item .\Adobe Air.dll "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0"  
Copy-Item .\cg.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\cgD3D9.dll $LoL\projects\lol_launcher\releases\$launch\deploy  
Copy-Item .\cgGL.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\msvcp120.dll $LoL\projects\lol_launcher\releases\$launch\deploy 
Copy-Item .\msvcr120.dll $LoL\projects\lol_launcher\releases\$launch\deploy
StartLoL
Exit
}
# SIG # Begin signature block
# MIIMmAYJKoZIhvcNAQcCoIIMiTCCDIUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnE4Nb9unZCWbrBXKJmCFWN1N
# ehmgggfZMIIDPjCCAiqgAwIBAgIQaORVZvF4yK9F8OGWCSD5gjAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDA0MTkwOTE0MjlaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK9b4VIc
# dNEvzRbEk3LYVBPtdZILzN4iLwZX8iGL+p0CnhqxIKcSaalP9ohX/459cqGc7R3Y
# 5ljeP8eNu2Nb3tG46m/cXhRNB23+b3dR3LfWUuwKHh3qVLaOC7rxcCNzlACg5kFw
# Qk5g9mrWioFn4L0sxVP7dMht8IHDihTII8tOh4CqyaxXwQqYkV2VBsr59B4dZz+N
# 20D5r5bg+gIqzILb6Reb5yzpIC8gMqvzOtxYezPLJqWFz854Pc7XgIlZlaTBtCWu
# x6j1YgYV/9QeqXq5wmJXVtuUx0vYxCOMKK0H6siedf8XbIIG74hSAekZ+XUb9k0M
# GxVHR+2Imzx2L5MCAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwXQYDVR0B
# BFYwVIAQLTP4wmRmNNkU26TndKSXH6EuMCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwg
# TG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQ6PD8cWbtZ4RKY14i9x9ntzAJBgUrDgMC
# HQUAA4IBAQBJuVbONuv1VhHaoLJCpCmGf2QbwN8S51wxbqxERAdH4hTDlWOi+1T3
# crJVxV2wcpjU1N/uA60OMYwArwFR7hiJ1M/A+yz8O2qYBgpqEkiRf4oaLehBYgv8
# qNQn1qUjKJy7EgCdGcomPRqiWrNoPib3HyfCN+7wTw9Z2X57B+9rCWVbHrvttBry
# xn0qnh5XL7BtdIlrmP5X8lHa00oxDDa2yiOlodOB3PxcyN/aMcPVeNUpN+HsKDFr
# yDQ3iqJegW/c9yypq6yIHdoeshgPQgP4Yp5TdOqhKxTe0G3pJKGCmbQmJv6c3jg9
# Hch3GUgOJ8Wrry/VvG3+gRBQMTWsrTX9MIIEkzCCA3ugAwIBAgIQR4qO+1nh2D8M
# 4ULSoocHvjANBgkqhkiG9w0BAQUFADCBlTELMAkGA1UEBhMCVVMxCzAJBgNVBAgT
# AlVUMRcwFQYDVQQHEw5TYWx0IExha2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJU
# UlVTVCBOZXR3b3JrMSEwHwYDVQQLExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5jb20x
# HTAbBgNVBAMTFFVUTi1VU0VSRmlyc3QtT2JqZWN0MB4XDTEwMDUxMDAwMDAwMFoX
# DTE1MDUxMDIzNTk1OVowfjELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIg
# TWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENB
# IExpbWl0ZWQxJDAiBgNVBAMTG0NPTU9ETyBUaW1lIFN0YW1waW5nIFNpZ25lcjCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALw1oDZwIoERw7KDudMoxjbN
# JWupe7Ic9ptRnO819O0Ijl44CPh3PApC4PNw3KPXyvVMC8//IpwKfmjWCaIqhHum
# nbSpwTPi7x8XSMo6zUbmxap3veN3mvpHU0AoWUOT8aSB6u+AtU+nCM66brzKdgyX
# ZFmGJLs9gpCoVbGS06CnBayfUyUIEEeZzZjeaOW0UHijrwHMWUNY5HZufqzH4p4f
# T7BHLcgMo0kngHWMuwaRZQ+Qm/S60YHIXGrsFOklCb8jFvSVRkBAIbuDlv2GH3rI
# DRCOovgZB1h/n703AmDypOmdRD8wBeSncJlRmugX8VXKsmGJZUanavJYRn6qoAcC
# AwEAAaOB9DCB8TAfBgNVHSMEGDAWgBTa7WR0FJwUPKvdmam9WyhNizzJ2DAdBgNV
# HQ4EFgQULi2wCkRK04fAAgfOl31QYiD9D4MwDgYDVR0PAQH/BAQDAgbAMAwGA1Ud
# EwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC51c2VydHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0
# LmNybDA1BggrBgEFBQcBAQQpMCcwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVz
# ZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEFBQADggEBAMj7Y/gLdXUsOvHyE6cttqMa
# nK0BB9M0jnfgwm6uAl1IT6TSIbY2/So1Q3xr34CHCxXwdjIAtM61Z6QvLyAbnFSe
# gz8fXxSVYoIPIkEiH3Cz8/dC3mxRzUv4IaybO4yx5eYoj84qivmqUk2MW3e6TVpY
# 27tqBMxSHp3iKDcOu+cOkcf42/GBmOvNN7MOq2XTYuw6pXbrE6g1k8kuCgHswOjM
# PX626+LB7NMUkoJmh1Dc/VCXrLNKdnMGxIYROrNfQwRSb+qz0HQ2TMrxG3mEN3Bj
# rXS5qg7zmLCGCOvb4B+MEPI5ZJuuTwoskopPGLWR5Y0ak18frvGm8C6X0NL2Kzwx
# ggQpMIIEJQIBATBAMCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlm
# aWNhdGUgUm9vdAIQaORVZvF4yK9F8OGWCSD5gjAJBgUrDgMCGgUAoHgwGAYKKwYB
# BAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAc
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU/wTC
# BFV6rYlgINPqSCyT4ofWD7EwDQYJKoZIhvcNAQEBBQAEggEAGp1+npJ8eijfNyRN
# ZY72BFMgHo3p1SAOKyCGhKtdrrpHjJCCIAt/93nJNolz2elpaUvS9/X0VkuS+Z7Z
# aKFqNCeM6mdKByt9iNZ6AxXwhCzPS9EncoK0CchHs6s14hILekl3GopfxZtQdrVN
# vOV4MEsvfzKOiUlhAEUDsQ45lD3pXJrxPZpjDgkFaA9b4YfTTbagHwH7Z1aEdwV5
# BeCYo05PjGjsMCOJdFxn/2pc92uBTJBnaH3znXy1rtuwhAdG87l5UMHQJFSjVY13
# cX9gCjpsIuKzEFN3dt06IfuPsEgCsWL5VUew1HPL5XJgGG/3hrDmdm4BkB+Xv9Zh
# zMZFz6GCAkQwggJABgkqhkiG9w0BCQYxggIxMIICLQIBADCBqjCBlTELMAkGA1UE
# BhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0IExha2UgQ2l0eTEeMBwG
# A1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYDVQQLExhodHRwOi8vd3d3
# LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1VU0VSRmlyc3QtT2JqZWN0AhBH
# io77WeHYPwzhQtKihwe+MAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZI
# hvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNDA0MTkxMTQwNTBaMCMGCSqGSIb3DQEJ
# BDEWBBRJDFR0RIvQ82xqsRRoj+hMEFWIvzANBgkqhkiG9w0BAQEFAASCAQBZ9ZYz
# qVbG3Y1DgykeMsEjHestC9Msxc6lWLzVomjnI0Y87SazDjt9Ycf5te+C00z35rwe
# /RCNmgqzdOU7sD4TmXsTmlgWBbFysiv7tkoU3+3TjBtq+niJGi0s/7Z//seOxPcs
# xN5fsSX8ToZ/0ruV0i35v0493HSXRw0Uq0EF9SipkR2F8W0exZ1Fq1gG0R3xFCWo
# /ZvK2+reRlV/h/xD8UI419uYcYjpYno6cZ0FGvc5s3eg1+fomPTldv9e6JvZ8n7D
# +gjEttS4WUNbkFmJ9NlNayRT/c2q9Va3QfyTmWBDZzK/WZPxz3zejXZa8TZsr8X9
# sXMoYd3pIIB+ZSUn
# SIG # End signature block
