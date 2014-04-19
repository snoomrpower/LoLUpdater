if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'" + "-ExecutionPolicy RemoteSigned"
Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $arguments 
}
$dir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Set-ExecutionPolicy RemoteSigned
$PMB = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Pando Networks\PMB" | Select-Object -ExpandProperty "Program Directory"
$LoL = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Riot Games\RADS" | Select-Object -ExpandProperty "LocalRootFolder"
$CG = Get-ItemProperty "HKLM:\SYSTEM\ControlSet001\Control\Session Manager\Environment" | Select-Object -ExpandProperty "CG_BIN_PATH"
Start-Process $PMB\uninst.exe /s
$sScriptVersion = "Development"
$Host.UI.RawUI.WindowTitle = "LoLUpdater $sScriptVersion"
Remove-Item "$env:windir\Temp\*" -recurse 
Remove-Item "$env:windir\Prefetch\*" -recurse
Function StartLoL {
Set-Location $LoL
Start-Process .\lol.launcher.exe}
Function restore {
Set-Location C:\Downloads\Backup
Copy-Item .\dbghelp.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcp120.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\msvcr120.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cg.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cgD3D9.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cgGL.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\dbghelp.dll $LoL\projects\lol_air_client\releases\$air\deploy
Copy-Item .\tbb.dll $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\NPSWF32.dll "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe Air\Versions\1.0\Resources"
Copy-Item "Adobe Air.dll" "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe Air\Versions\1.0"
Copy-Item .\cg.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\cgD3D9.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\cgGL.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\msvcp120.dll $LoL\projects\lol_launcher\releases\$launch\deploy
Copy-Item .\msvcr120.dll $LoL\projects\lol_launcher\releases\$launch\deploy
StartLoL
exit
}
Function Get-WUInstall
{
[OutputType('PSWindowsUpdate.WUInstall')]
[CmdletBinding(
SupportsShouldProcess=$True,
ConfirmImpact="High"
	)]	
	Param
	(
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[ValidateSet("Driver", "Software")]
		[String]$UpdateType="",
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[String[]]$UpdateID,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[Int]$RevisionNumber,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[String[]]$CategoryIDs,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[Switch]$IsInstalled,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[Switch]$IsHidden,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[Switch]$WithHidden,
		[String]$Criteria,
		[Switch]$ShowSearchCriteria,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[String[]]$Category="",
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[String[]]$KBArticleID,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[String]$Title,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[String[]]$NotCategory="",
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[String[]]$NotKBArticleID,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[String]$NotTitle,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[Alias("Silent")]
		[Switch]$IgnoreUserInput,
		[parameter(ValueFromPipelineByPropertyName=$true)]
		[Switch]$IgnoreRebootRequired,
		[String]$ServiceID,
		[Switch]$WindowsUpdate,
		[Switch]$MicrosoftUpdate,
		[Switch]$ListOnly,
		[Switch]$DownloadOnly,
		[Alias("All")]
		[Switch]$AcceptAll,
		[Switch]$AutoReboot,
		[Switch]$IgnoreReboot,
		[Switch]$AutoSelectOnly,
		[Switch]$Debuger
	)
	Begin
	{
		If($PSBoundParameters['Debuger'])
		{
			$DebugPreference = "Continue"
		} 
		$User = [Security.Principal.WindowsIdentity]::GetCurrent()
		$Role = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
		if(!$Role)
		{
			Write-Warning "To perform some operations you must run an elevated Windows PowerShell console."	
		} 
	}
	Process
	{
		If($IsInstalled)
		{
			$ListOnly = $true
		} 
		Try
		{
			$objSystemInfo = New-Object -ComObject "Microsoft.Update.SystemInfo"	
			If($objSystemInfo.RebootRequired)
			{
				Write-Warning "Reboot is required to continue"
				If($AutoReboot)
				{
					Restart-Computer -Force
				} 
				If(!$ListOnly)
				{
					Return
				} 
			}
		} 
		Catch
		{
			Write-Warning "Support local instance only, Continue..."
		} 
		If($ListOnly)
		{
			$NumberOfStage = 2
		} 
		ElseIf($DownloadOnly)
		{
			$NumberOfStage = 3
		} 
		Else
		{
			$NumberOfStage = 4
		} 
		$objServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager" 
		$objSession = New-Object -ComObject "Microsoft.Update.Session" 
		$objSearcher = $objSession.CreateUpdateSearcher()

		If($WindowsUpdate)
		{
			$objSearcher.ServerSelection = 2
			$serviceName = "Windows Update"
		} 
		ElseIf($MicrosoftUpdate)
		{
			$serviceName = $null
			Foreach ($objService in $objServiceManager.Services) 
			{
				If($objService.Name -eq "Microsoft Update")
				{
					$objSearcher.ServerSelection = 3
					$objSearcher.ServiceID = $objService.ServiceID
					$serviceName = $objService.Name
				}
			}
			
			If(-not $serviceName)
			{
				Write-Warning "Can't find registered service Microsoft Update. Use Get-WUServiceManager to get registered service."
				Return
			}
		} 
		Else
		{
			Foreach ($objService in $objServiceManager.Services) 
			{
				If($ServiceID)
				{
					If($objService.ServiceID -eq $ServiceID)
					{
						$objSearcher.ServiceID = $ServiceID
						$objSearcher.ServerSelection = 3
						$serviceName = $objService.Name
					} 
				} 
				Else
				{
					If($objService.IsDefaultAUService -eq $True)
					{
						$serviceName = $objService.Name
					} 
				} 
			} 
		} 
		
		Write-Verbose "Connecting to $serviceName server. Please wait..."
		Try
		{
			$search = ""
			
			If($Criteria)
			{
				$search = $Criteria
			} 
			Else
			{
				If($IsInstalled) 
				{
					$search = "IsInstalled = 1"
				} 
				Else
				{
					$search = "IsInstalled = 0"	
				} 
				
				If($UpdateType -ne "")
				{
					$search += " and Type = '$UpdateType'"
				} 				
				
				If($UpdateID)
				{
					$tmp = $search
					$search = ""
					$LoopCount = 0
					Foreach($ID in $UpdateID)
					{
						If($LoopCount -gt 0)
						{
							$search += " or "
						} 
						If($RevisionNumber)
						{	
							$search += "($tmp and UpdateID = '$ID' and RevisionNumber = $RevisionNumber)"
						}
						Else
						{
							$search += "($tmp and UpdateID = '$ID')"
						} 
						$LoopCount++
					}
				} 

				If($CategoryIDs)
				{
					$tmp = $search
					$search = ""
					$LoopCount =0
					Foreach($ID in $CategoryIDs)
					{
						If($LoopCount -gt 0)
						{
							$search += " or "
						} 
						$search += "($tmp and CategoryIDs contains '$ID')"
						$LoopCount++
					}
				} 
				
				If($IsHidden) 
				{
					$search += " and IsHidden = 1"	
				} 
				ElseIf($WithHidden) 
				{
				} 
				Else
				{
					$search += " and IsHidden = 0"	
				} 
				
				If($IgnoreRebootRequired) 
				{
					$search += " and RebootRequired = 0"	
				} 
			} 
			If($ShowSearchCriteria)
			{
				Write-Output $search
			}
			
			$objResults = $objSearcher.Search($search)
		} 
		Catch
		{
			If($_ -match "HRESULT: 0x80072EE2")
			{
				Write-Warning "Probably you don't have connection to Windows Update server"
			} 
			Return
		} 

		$objCollectionUpdate = New-Object -ComObject "Microsoft.Update.UpdateColl" 
		$NumberOfUpdate = 1
		$UpdateCollection = @()
		$UpdatesExtraDataCollection = @{}
		$PreFoundUpdatesToDownload = $objResults.Updates.count
		Write-Verbose "Found [$PreFoundUpdatesToDownload] Updates in pre search criteria"				

		Foreach($Update in $objResults.Updates)
		{	
			$UpdateAccess = $true
			Write-Progress -Activity "Post search updates for $Computer" -Status "[$NumberOfUpdate/$PreFoundUpdatesToDownload] $($Update.Title) $size" -PercentComplete ([int]($NumberOfUpdate/$PreFoundUpdatesToDownload * 100))
			
			If($Category -ne "")
			{
				$UpdateCategories = $Update.Categories | Select-Object Name	
				Foreach($Cat in $Category)
				{
					If(!($UpdateCategories -match $Cat))
					{
						$UpdateAccess = $false
					}
					Else
					{
						$UpdateAccess = $true
					} 
				} 
			}
			If($NotCategory -ne "" -and $UpdateAccess -eq $true)
			{
				$UpdateCategories = $Update.Categories | Select-Object Name	
				Foreach($Cat in $NotCategory)
				{
					If($UpdateCategories -match $Cat)
					{
						$UpdateAccess = $false
					} 
				} 
			} 		
			If($KBArticleID -ne $null -and $UpdateAccess -eq $true)
			{
				If(!($KBArticleID -match $Update.KBArticleIDs -and "" -ne $Update.KBArticleIDs))
				{
					$UpdateAccess = $false
				}								
			} 
			If($NotKBArticleID -ne $null -and $UpdateAccess -eq $true)
			{
				If($NotKBArticleID -match $Update.KBArticleIDs -and "" -ne $Update.KBArticleIDs)
				{
					$UpdateAccess = $false
				}				
			}
			If($Title -and $UpdateAccess -eq $true)
			{
				If($Update.Title -notmatch $Title)
				{
					$UpdateAccess = $false
				} 
			} 
			If($NotTitle -and $UpdateAccess -eq $true)
			{
				If($Update.Title -match $NotTitle)
				{
					$UpdateAccess = $false
				} 
			} 
			If($IgnoreUserInput -and $UpdateAccess -eq $true)
			{
				If($Update.InstallationBehavior.CanRequestUserInput -eq $true)
				{
					$UpdateAccess = $false
				} 
			} 
			If($IgnoreRebootRequired -and $UpdateAccess -eq $true) 
			{
				If($Update.InstallationBehavior.RebootBehavior -ne 0)
				{
					$UpdateAccess = $false
				} 
			}  
			If($UpdateAccess -eq $true)
			{
				Switch($Update.MaxDownloadSize)
				{
					{[System.Math]::Round($_/1KB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1KB,0))+" KB"}
					{[System.Math]::Round($_/1MB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1MB,0))+" MB"}  
					{[System.Math]::Round($_/1GB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1GB,0))+" GB"}    
					{[System.Math]::Round($_/1TB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1TB,0))+" TB"}
					default { $size = $_+"B" }
				} 
				If($Update.KBArticleIDs -ne "")    
				{
					$KB = "KB"+$Update.KBArticleIDs
				} 
				Else 
				{
					$KB = ""
				} 
				If($ListOnly)
				{
					$Status = ""
					If($Update.IsDownloaded)    {$Status += "D"} else {$status += "-"}
					If($Update.IsInstalled)     {$Status += "I"} else {$status += "-"}
					If($Update.IsMandatory)     {$Status += "M"} else {$status += "-"}
					If($Update.IsHidden)        {$Status += "H"} else {$status += "-"}
					If($Update.IsUninstallable) {$Status += "U"} else {$status += "-"}
					If($Update.IsBeta)          {$Status += "B"} else {$status += "-"} 
	
					Add-Member -InputObject $Update -MemberType NoteProperty -Name ComputerName -Value $env:COMPUTERNAME
					Add-Member -InputObject $Update -MemberType NoteProperty -Name KB -Value $KB
					Add-Member -InputObject $Update -MemberType NoteProperty -Name Size -Value $size
					Add-Member -InputObject $Update -MemberType NoteProperty -Name Status -Value $Status
					Add-Member -InputObject $Update -MemberType NoteProperty -Name X -Value 1
					
					$Update.PSTypeNames.Clear()
					$Update.PSTypeNames.Add('PSWindowsUpdate.WUInstall')
					$UpdateCollection += $Update
				} 
				Else
				{
					$objCollectionUpdate.Add($Update) 
					$UpdatesExtraDataCollection.Add($Update.Identity.UpdateID,@{KB = $KB; Size = $size})
				}
			}
			$NumberOfUpdate++
		} 			
		Write-Progress -Activity "[1/$NumberOfStage] Post search updates" -Status "Completed" -Completed
		
		If($ListOnly)
		{
			$FoundUpdatesToDownload = $UpdateCollection.count
		} 
		Else
		{
			$FoundUpdatesToDownload = $objCollectionUpdate.count				
		} 
		Write-Verbose "Found [$FoundUpdatesToDownload] Updates in post search criteria"
		
		If($FoundUpdatesToDownload -eq 0)
		{
			Return
		}
		If($ListOnly)
		{
			Return $UpdateCollection				
		} 
		If(!$ListOnly) 
		{		
			$NumberOfUpdate = 1
			$logCollection = @()
			$objCollectionChoose = New-Object -ComObject "Microsoft.Update.UpdateColl"
			Foreach($Update in $objCollectionUpdate)
			{	
				$size = $UpdatesExtraDataCollection[$Update.Identity.UpdateID].Size
				Write-Progress -Activity "[2/$NumberOfStage] Choose updates" -Status "[$NumberOfUpdate/$FoundUpdatesToDownload] $($Update.Title) $size" -PercentComplete ([int]($NumberOfUpdate/$FoundUpdatesToDownload * 100))
				If($AcceptAll)
				{
					$Status = "Accepted"

					If($Update.EulaAccepted -eq 0)
					{ 
						$Update.AcceptEula() 
					} 
					$objCollectionChoose.Add($Update) 
				}
				ElseIf($AutoSelectOnly)  
				{  
					If($Update.AutoSelectOnWebsites)  
					{  
						$Status = "Accepted"  
						If($Update.EulaAccepted -eq 0)  
						{  
							$Update.AcceptEula()  
						} 
						$objCollectionChoose.Add($Update)   
					} 
					Else  
					{  
						$Status = "Rejected"  
					} 
				} 
				Else
				{
					If($pscmdlet.ShouldProcess($Env:COMPUTERNAME,"$($Update.Title)[$size]?")) 
					{
						$Status = "Accepted"
						
						If($Update.EulaAccepted -eq 0)
						{ 
							$Update.AcceptEula() 
						} 
						$objCollectionChoose.Add($Update)  
					} 
					Else
					{
						$Status = "Rejected"
					} 
				} 
				$log = New-Object PSObject -Property @{
					Title = $Update.Title
					KB = $UpdatesExtraDataCollection[$Update.Identity.UpdateID].KB
					Size = $UpdatesExtraDataCollection[$Update.Identity.UpdateID].Size
					Status = $Status
					X = 2
				} 
				$log.PSTypeNames.Clear()
				$log.PSTypeNames.Add('PSWindowsUpdate.WUInstall')
				
				$logCollection += $log
				
				$NumberOfUpdate++
			} 
			Write-Progress -Activity "[2/$NumberOfStage] Choose updates" -Status "Completed" -Completed
			
			Write-Debug "Show log collection"
			$logCollection
			
			
			$AcceptUpdatesToDownload = $objCollectionChoose.count
			Write-Verbose "Accept [$AcceptUpdatesToDownload] Updates to Download"
			
			If($AcceptUpdatesToDownload -eq 0)
			{
				Return
			} 
			$NumberOfUpdate = 1
			$objCollectionDownload = New-Object -ComObject "Microsoft.Update.UpdateColl"
			Foreach($Update in $objCollectionChoose)
			{
				Write-Progress -Activity "[3/$NumberOfStage] Downloading updates" -Status "[$NumberOfUpdate/$AcceptUpdatesToDownload] $($Update.Title) $size" -PercentComplete ([int]($NumberOfUpdate/$AcceptUpdatesToDownload * 100))
				$objCollectionTmp = New-Object -ComObject "Microsoft.Update.UpdateColl"
				$objCollectionTmp.Add($Update) 	
				$Downloader = $objSession.CreateUpdateDownloader() 
				$Downloader.Updates = $objCollectionTmp
				Try
				{
					Write-Debug "Try download update"
					$DownloadResult = $Downloader.Download()
				}
				Catch
				{
					If($_ -match "HRESULT: 0x80240044")
					{
						Write-Warning "Your security policy don't allow a non-administator identity to perform this task"
					} 
					Return
				} 
				Switch -exact ($DownloadResult.ResultCode)
				{
					0   { $Status = "NotStarted" }
					1   { $Status = "InProgress" }
					2   { $Status = "Downloaded" }
					3   { $Status = "DownloadedWithErrors" }
					4   { $Status = "Failed" }
					5   { $Status = "Aborted" }
				} 
				$log = New-Object PSObject -Property @{
					Title = $Update.Title
					KB = $UpdatesExtraDataCollection[$Update.Identity.UpdateID].KB
					Size = $UpdatesExtraDataCollection[$Update.Identity.UpdateID].Size
					Status = $Status
					X = 3
				} 
				$log.PSTypeNames.Clear()
				$log.PSTypeNames.Add('PSWindowsUpdate.WUInstall')
				$log
				If($DownloadResult.ResultCode -eq 2)
				{
					Write-Debug "Downloaded then send update to next stage"
					$objCollectionDownload.Add($Update) 
				} 
				
				$NumberOfUpdate++
			} 
			Write-Progress -Activity "[3/$NumberOfStage] Downloading updates" -Status "Completed" -Completed
			$ReadyUpdatesToInstall = $objCollectionDownload.count
			Write-Verbose "Downloaded [$ReadyUpdatesToInstall] Updates to Install"
			If($ReadyUpdatesToInstall -eq 0)
			{
				Return
			} 
			If(!$DownloadOnly)
			{
				$NeedsReboot = $false
				$NumberOfUpdate = 1	
				Foreach($Update in $objCollectionDownload)
				{   
					Write-Progress -Activity "[4/$NumberOfStage] Installing updates" -Status "[$NumberOfUpdate/$ReadyUpdatesToInstall] $($Update.Title)" -PercentComplete ([int]($NumberOfUpdate/$ReadyUpdatesToInstall * 100))
					$objCollectionTmp = New-Object -ComObject "Microsoft.Update.UpdateColl"
					$objCollectionTmp.Add($Update) 
					$objInstaller = $objSession.CreateUpdateInstaller()
					$objInstaller.Updates = $objCollectionTmp
					Try
					{
						$InstallResult = $objInstaller.Install()
					}
					Catch
					{
						If($_ -match "HRESULT: 0x80240044")
						{
							Write-Warning "Your security policy don't allow a non-administator identity to perform this task"
						} 
						Return
					} 
					If(!$NeedsReboot) 
					{ 
						$NeedsReboot = $installResult.RebootRequired 
					} 
					Switch -exact ($InstallResult.ResultCode)
					{
						0   { $Status = "NotStarted"}
						1   { $Status = "InProgress"}
						2   { $Status = "Installed"}
						3   { $Status = "InstalledWithErrors"}
						4   { $Status = "Failed"}
						5   { $Status = "Aborted"}
					} 
					$log = New-Object PSObject -Property @{
						Title = $Update.Title
						KB = $UpdatesExtraDataCollection[$Update.Identity.UpdateID].KB
						Size = $UpdatesExtraDataCollection[$Update.Identity.UpdateID].Size
						Status = $Status
						X = 4
					} 
					$log.PSTypeNames.Clear()
					$log.PSTypeNames.Add('PSWindowsUpdate.WUInstall')
					$log
					$NumberOfUpdate++
				} 
				Write-Progress -Activity "[4/$NumberOfStage] Installing updates" -Status "Completed" -Completed
				If($NeedsReboot)
				{
					If($AutoReboot)
					{
						Restart-Computer -Force
					} 
					ElseIf($IgnoreReboot)
					{
						Return "Reboot is required, but do it manually."
					} 
					Else
					{
						Restart-Computer -Force
						{
							
						} 
					}
				}
			}
		}
	}
	End{}		
} 
function tweaks {
Get-ChildItem -Recurse -Force C:\ | Unblock-File
Get-ChildItem -Recurse -Force  $LoL | Unblock-File
Set-Service AppMgmt -StartupType Disabled 
Set-Service bthserv -StartupType Disabled 
Set-Service PeerDistSvc -StartupType Disabled 
Set-Service CertPropSvc -StartupType Disabled 
Set-Service NfsClnt -StartupType Disabled 
Set-Service WPCSvc -StartupType Disabled 
Set-Service vmickvpexchange -StartupType Disabled 
Set-Service vmicguestinterface -StartupType Disabled 
Set-Service vmicshutdown -StartupType Disabled 
Set-Service vmicheartbeat -StartupType Disabled 
Set-Service vmicrdv -StartupType Disabled 
Set-Service vmictimesync -StartupType Disabled 
Set-Service vmicvss -StartupType Disabled 
Set-Service TrkWks -StartupType Disabled 
Set-Service IEEtwCollectorService -StartupType Disabled 
Set-Service iphlpsvc -StartupType Disabled 
Set-Service MSiSCSI -StartupType Disabled 
Set-Service Netlogon -StartupType Disabled 
Set-Service napagent -StartupType Disabled 
Set-Service CscService -StartupType Disabled 
Set-Service WPCSvc -StartupType Disabled 
Set-Service RpcLocator -StartupType Disabled 
Set-Service SensrSvc -StartupType Disabled 
Set-Service ScDeviceEnum -StartupType Disabled 
Set-Service SCPolicySvc -StartupType Disabled 
Set-Service RemoteRegistry -StartupType Disabled 
Set-Service SCardSvr -StartupType Disabled 
Set-Service SCPolicySvc -StartupType Disabled 
Set-Service SNMPTRAP -StartupType Disabled 
Set-Service StorSvc -StartupType Disabled 
Set-Service wcncsvc -StartupType Disabled 
Set-Service fsvc -StartupType Disabled 
Set-Service WMPNetworkSvc -StartupType Disabled 
Set-Service WSearch -StartupType Disabled 
Dism /online /Disable-Feature /FeatureName:WindowsGadgetPlatform /norestart 
Dism /online /Disable-Feature /FeatureName:InboxGames /norestart 
Dism /online /Disable-Feature /FeatureName:MediaPlayback /norestart 
Dism /online /Disable-Feature /FeatureName:TabletPCOC /norestart 
Dism /online /Disable-Feature /FeatureName:Xps-Foundation-Xps-Viewer /norestart 
Dism /online /Disable-Feature /FeatureName:Printing-XPSServices-Features /norestart 
update
$title = "Restart menu"
$message = "Would you like to restart?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"


$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {Restart-Computer -Force}
        1 {exit}
        }
        }
Function update {
Get-WUInstall -AcceptAll -IgnoreUserInput -IgnoreReboot 
Get-WUInstall -KBArticleID "KB968930","KB2506146","KB2506143","KB2819745","KB2858728" -AcceptAll -IgnoreReboot 
}
Function patcher {
Set-Location $dir
Copy-Item .\dbghelp.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item .\msvcp120.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item .\msvcr120.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item $CG\cg.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item $CG\cgD3D9.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item $CG\cgGL.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item .\dbghelp.dll "$LoL\projects\lol_air_client\releases\$air\deploy" 
Copy-Item .\tbb.dll "$LoL\solutions\lol_game_client_sln\releases\$sln\deploy" 
Copy-Item .\NPSWF32.dll "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe Air\Versions\1.0\Resources" 
Copy-Item "Adobe Air.dll" "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe Air\Versions\1.0\" 
Copy-Item $CG\cg.dll "$LoL\projects\lol_launcher\releases\$launch\deploy" 
Copy-Item $CG\cgD3D9.dll "$LoL\projects\lol_launcher\releases\$launch\deploy" 
Copy-Item $CG\cgGL.dll "$LoL\projects\lol_launcher\releases\$launch\deploy" 
Copy-Item .\msvcp120.dll "$LoL\projects\lol_launcher\releases\$launch\deploy" 
Copy-Item .\msvcr120.dll "$LoL\projects\lol_launcher\releases\$launch\deploy" 
$tbb = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$LoL\solutions\lol_game_client_sln\releases\$sln\deploy\tbb.dll") | select -f 1 | Select-Object -ExpandProperty "FileVersion"
if($tbb -eq "4, 2, 0, 0"){StartLoL
Read-Host "Patch Complete, Press Enter to do Windows Tweaks (BETA)"
tweaks
exit }
ELSE {
Read-Host "Patch Failed, Press Enter to do Windows Tweaks (BETA)"
tweaks
exit}
}
Import-Module BitsTransfer
Update-Help
Stop-Service wuauserv
Remove-Item C:\Windows\SoftwareDistribution\* -Recurse -Force
Start-Service wuauserv
New-Item -Path C:\Downloads\Backup -ItemType Directory
Stop-Process -ProcessName LoLLauncher
Stop-Process -ProcessName LoLClient
Set-Location $LoL\solutions\lol_game_client_sln\releases
$sln = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1 | Select-Object -ExpandProperty "Name"
Set-Location $LoL\solutions\lol_game_client_sln\releases\$sln\deploy
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
Set-Location "$LoL\projects\lol_air_client\releases\$air\deploy\Adobe Air\versions\1.0\Resources"
Copy-Item .\NPSWF32.dll C:\Downloads\Backup
Set-Location $dir

$title = "Main Menu"
$message = "Patch or Restore Backups"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Patch"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&Restore"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0) 
switch ($result)
    {
        0 {patcher}
        1 {restore}
    }
# SIG # Begin signature block
# MIIMmAYJKoZIhvcNAQcCoIIMiTCCDIUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpObNcRFePeQHSLjef43MHuHq
# fi6gggfZMIIDPjCCAiqgAwIBAgIQaORVZvF4yK9F8OGWCSD5gjAJBgUrDgMCHQUA
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
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUU4FB
# NyiCsKi3uh8iR6YWawVKSMMwDQYJKoZIhvcNAQEBBQAEggEAXyujsyvR/3djVH+4
# XzNgzn6t97xjBV22ENoE878YGQV5UdcnfHjaoCyWtQlbbjVWvZDTg5iWOaL5R6Fp
# VVT3UzJ0cvyQegLc1wyi6NXDt8KVi49+O84/ZBl8YSWomHsrIPvLv8d35pTFCafn
# dWMtNCzSWUQpOXJEbauclhjx6LrN0bGlKw/poGLiL4nRWFbSNOnILgLR88j56u4X
# yRnggjzlY8VCYFsd3NiaThY3D2HtywRJawhycPJv5FlYBJvZ2wP0VhvyU/o1M1IW
# 29kOmERBG3aIviHkk31RO7H9ACtasCaJcEernKtLQYQx2+4XH65Atd9knU3M8Gux
# YFNNO6GCAkQwggJABgkqhkiG9w0BCQYxggIxMIICLQIBADCBqjCBlTELMAkGA1UE
# BhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0IExha2UgQ2l0eTEeMBwG
# A1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYDVQQLExhodHRwOi8vd3d3
# LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1VU0VSRmlyc3QtT2JqZWN0AhBH
# io77WeHYPwzhQtKihwe+MAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZI
# hvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNDA0MTkxMTQwNDlaMCMGCSqGSIb3DQEJ
# BDEWBBQ4Lxp2Cf4rMZXtG/cCB4Ero/MDAzANBgkqhkiG9w0BAQEFAASCAQAIKY4p
# wSfBtPjcCVe3G/6QHcokMuBtAdyMEN78MPJXoa2gTzAeKdeC6HFUwKNtWpmkGoSV
# hQHh7oEzbdtMRNovyKLgObHTvUN+4D0XjO46u837+wLFvfkcVgc9yeSd7LJKnc8f
# qWXqL5uL8inc5ry3NOyP/nkj9cbnd8Q4SmVJ7gOPJ+BEX1I/ftNrafo8iKruddLB
# XH2wGEoMu+YKHdBqVuhT+QlAMNH+dJ1+SREe0GzDLtFcceWKS9ZwJaFOi7+lqhzM
# +JlShK++0l7th2bG8q1cNL7sRrpILtL/opS0N/LQyoWlKz+yy2P0jm1daWUAZs4e
# uk0sVrHd9KW/GVpK
# SIG # End signature block
