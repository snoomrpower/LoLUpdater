Set-ExecutionPolicy Unrestricted
$CG = Get-ItemProperty "HKLM:\SYSTEM\ControlSet001\Control\Session Manager\Environment" | Select-Object -ExpandProperty "CG_BIN_PATH"
$PMB = Get-ItemProperty "HKLM:\\SOFTWARE\Wow6432Node\Pando Networks\PMB" | Select-Object -ExpandProperty "Program Directory"
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
Move-Item .\cg.dll "C:\Downloads\Backup"
Move-Item .\cgD3D9.dll "C:\Downloads\Backup"
Move-Item .\cgGL.dll "C:\Downloads\Backup"
Move-Item .\tbb.dll "C:\Downloads\Backup"


Set-Location "$dir\RADS\projects\lol_launcher\releases"
$launch = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
Move-Item .\msvcp120.dll "C:\Downloads\Backup" 
Move-Item .\msvcr120.dll "C:\Downloads\Backup" 
Move-Item .\cg.dll "C:\Downloads\Backup" 
Move-Item .\cgD3D9.dll "C:\Downloads\Backup" 
Move-Item .\cgGL.dll "C:\Downloads\Backup" 


Set-Location $dir
Set-Location "RADS\projects\lol_air_client\releases"
gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"

Set-Location $dir
Set-Location "RADS\projects\lol_air_client\releases"
$air = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location "$dir\RADS\projects\lol_air_client\releases\$air\deploy\adobe air\versions\1.0"
Move-Item "Adobe Air.dll" "C:\Downloads\Backup" 

Set-Location "$dir\RADS\projects\lol_air_client\releases\$air\deploy\adobe air\versions\1.0\Resources"
Move-Item .\NPSWF32.dll "C:\Downloads\Backup" 

Start-Process $PMB\uninst.exe /s
Set-Location $dir

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
Copy-Item .\dbghelp.dll "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item .\msvcp120.dll "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item .\msvcr120.dll "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item "$CG\cg.dll" "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item "$CG\cgD3D9.dll" "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item "$CG\cgGL.dll" "RADS\solutions\lol_game_client_sln\releases\$sln\deploy" 
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
Move-Item "cg.dll" "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "cgD3D9.dll" "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "cgGL.dll" "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "dbghelp.dll" "$dir\RADS\projects\lol_air_client\releases\$air\deploy"
Move-Item "tbb.dll" "$dir\RADS\solutions\lol_game_client_sln\releases\$sln\deploy"
Move-Item "NPSWF32.dll" "$dir\RADS\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources"
Move-Item "Adobe Air.dll" "$dir\RADS\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0"
Move-Item "cg.dll" "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
Move-Item "cgD3D9.dll" "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
Move-Item "cgGL.dll" "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
Move-Item "msvcp120.dll" "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
Move-Item "msvcr120.dll" "$dir\RADS\projects\lol_launcher\releases\$launch\deploy"
Read-Host "Restoring Successfull"

    
   

# SIG # Begin signature block
# MIILEgYJKoZIhvcNAQcCoIILAzCCCv8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQcbWGSN8cELS4ZvGwwLHKnbN
# ieegggbUMIICOTCCAaagAwIBAgIQCVuLJg8bsJ5DkjKoLRDVEzAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDA0MTkwNTI5MTFaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAujzfOXRdZ2fB
# 1gdLwK7w+8SATjn0nn9xzMOxbIEH/HJ1lk3T7kGVwQSua6By8KqW7nU6xpurgPM5
# K9PkstwNDPLCD5t8Ak2hhAJjBzr2c5odhyG2ot/mejEqJaHmL5uJQ4AnFz6yJZVx
# XiTjktUhag9n5FjPXSPEBsd82CdlLiUCAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwXQYDVR0BBFYwVIAQqu1u6zdlP2iYkg4pMtB0v6EuMCwxKjAoBgNVBAMT
# IVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQ5ATHA5ft0YdOFtc/
# 7d0ZQTAJBgUrDgMCHQUAA4GBAEuTw0i/fZef+7StkPXIPo38Eqn+WkKZr5bx8FwS
# NOsPmqEC+Y75FwpypUycrc/3ZcwTlSRxTbS9HbOZWwaiyGs5pgJo4cOD+hwzzleL
# ys8EBpZXoER1qYK8XTtL2mEHhkw5PQe826Wq5dGX8DLL5Y1P/DB3+MMUoi80i5Y4
# iD/GMIIEkzCCA3ugAwIBAgIQR4qO+1nh2D8M4ULSoocHvjANBgkqhkiG9w0BAQUF
# ADCBlTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0IExh
# a2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYDVQQL
# ExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1VU0VSRmly
# c3QtT2JqZWN0MB4XDTEwMDUxMDAwMDAwMFoXDTE1MDUxMDIzNTk1OVowfjELMAkG
# A1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMH
# U2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxJDAiBgNVBAMTG0NP
# TU9ETyBUaW1lIFN0YW1waW5nIFNpZ25lcjCCASIwDQYJKoZIhvcNAQEBBQADggEP
# ADCCAQoCggEBALw1oDZwIoERw7KDudMoxjbNJWupe7Ic9ptRnO819O0Ijl44CPh3
# PApC4PNw3KPXyvVMC8//IpwKfmjWCaIqhHumnbSpwTPi7x8XSMo6zUbmxap3veN3
# mvpHU0AoWUOT8aSB6u+AtU+nCM66brzKdgyXZFmGJLs9gpCoVbGS06CnBayfUyUI
# EEeZzZjeaOW0UHijrwHMWUNY5HZufqzH4p4fT7BHLcgMo0kngHWMuwaRZQ+Qm/S6
# 0YHIXGrsFOklCb8jFvSVRkBAIbuDlv2GH3rIDRCOovgZB1h/n703AmDypOmdRD8w
# BeSncJlRmugX8VXKsmGJZUanavJYRn6qoAcCAwEAAaOB9DCB8TAfBgNVHSMEGDAW
# gBTa7WR0FJwUPKvdmam9WyhNizzJ2DAdBgNVHQ4EFgQULi2wCkRK04fAAgfOl31Q
# YiD9D4MwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAww
# CgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWgM4YxaHR0cDovL2NybC51c2VydHJ1
# c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0LmNybDA1BggrBgEFBQcBAQQpMCcw
# JQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcN
# AQEFBQADggEBAMj7Y/gLdXUsOvHyE6cttqManK0BB9M0jnfgwm6uAl1IT6TSIbY2
# /So1Q3xr34CHCxXwdjIAtM61Z6QvLyAbnFSegz8fXxSVYoIPIkEiH3Cz8/dC3mxR
# zUv4IaybO4yx5eYoj84qivmqUk2MW3e6TVpY27tqBMxSHp3iKDcOu+cOkcf42/GB
# mOvNN7MOq2XTYuw6pXbrE6g1k8kuCgHswOjMPX626+LB7NMUkoJmh1Dc/VCXrLNK
# dnMGxIYROrNfQwRSb+qz0HQ2TMrxG3mEN3BjrXS5qg7zmLCGCOvb4B+MEPI5ZJuu
# TwoskopPGLWR5Y0ak18frvGm8C6X0NL2KzwxggOoMIIDpAIBATBAMCwxKjAoBgNV
# BAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdAIQCVuLJg8bsJ5D
# kjKoLRDVEzAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZ
# BgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYB
# BAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUAFlgvgE37Aq+N8suKD6plD5fDIswDQYJ
# KoZIhvcNAQEBBQAEgYA3D/s1DZJ9Qmvo5U8g9zZdUHcP5MqoULpPyn4mDmiTOtyV
# uDvmUePet8THFK1UePFcLgVTSu4BUYIka9xdI/Ux9R8ArP14WNeGs/gPVtXlYVGW
# UktgPuDkGPPPHjFvjUEta2U6N+CZIH8enx5mC5W0dfPnELNNeyfMlxff57DBJ6GC
# AkQwggJABgkqhkiG9w0BCQYxggIxMIICLQIBADCBqjCBlTELMAkGA1UEBhMCVVMx
# CzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0IExha2UgQ2l0eTEeMBwGA1UEChMV
# VGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYDVQQLExhodHRwOi8vd3d3LnVzZXJ0
# cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1VU0VSRmlyc3QtT2JqZWN0AhBHio77WeHY
# PwzhQtKihwe+MAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
# MBwGCSqGSIb3DQEJBTEPFw0xNDA0MTkwNTMyMzRaMCMGCSqGSIb3DQEJBDEWBBQK
# gnMEd07E0Q6+K1AQhbsTrEuR1jANBgkqhkiG9w0BAQEFAASCAQCJdvA9oAR6OZ/U
# Shvw2qHJOHnU26SKMuaBgzDKDAv54vC5IN3QO6A7rFcg5y5nLtDOl6XWyN/gVbny
# uZCiRY4sKG6VbQUnol7zxoXQYDhovirQYuYDKrGL1fhYhiVCZWczE6d0oy8FTCn8
# MQCOjafm8AuzPTkzpUsjPfkJ4ZUvRvsjklY8j5eRW0jP5I4T3N2ZdIicVdQmhbjM
# 2Je23D+tcOcRLTzdGVSUjp64v+KWi+sXcfKJQ/NFQa/73j7x0ysbrnjT6/dzAZxK
# MR6Nvinn2snSILywTmEU7njXJ/vbeblHVUA4l7xGRL81oAW81SMfmqRkMtTAm2WT
# OlWTqJ1K
# SIG # End signature block
