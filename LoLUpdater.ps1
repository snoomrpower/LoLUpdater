$dir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Set-ExecutionPolicy RemoteSigned
$PMB = Get-ItemProperty "HKLM:\\SOFTWARE\Wow6432Node\Pando Networks\PMB" | Select-Object -ExpandProperty "Program Directory"
Start-Process $PMB\uninst.exe /s

# Sets Windows Title
$sScriptVersion = "Github"
$Host.UI.RawUI.WindowTitle = "LoLUpdater $sScriptVersion"

# Removes contents of folders that can be emptied safely
Remove-Item "$env:windir\Temp\*" -recurse | out-string
Remove-Item "$env:windir\Prefetch\*" -recurse | out-string

Function restore {
        cd C:\Downloads\Backup
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
exit
}



# Windows Update Function
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
		
		Write-Debug "STAGE 0: Prepare environment"
		If($IsInstalled)
		{
			$ListOnly = $true
			Write-Debug "Change to ListOnly mode"
		} 

		Write-Debug "Check reboot status only for local instance"
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
		
		Write-Debug "Set number of stage"
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
			
		
		Write-Debug "STAGE 1: Get updates list"
		Write-Debug "Create Microsoft.Update.ServiceManager object"
		$objServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager" 
		
		Write-Debug "Create Microsoft.Update.Session object"
		$objSession = New-Object -ComObject "Microsoft.Update.Session" 
		
		Write-Debug "Create Microsoft.Update.Session.Searcher object"
		$objSearcher = $objSession.CreateUpdateSearcher()

		If($WindowsUpdate)
		{
			Write-Debug "Set source of updates to Windows Update"
			$objSearcher.ServerSelection = 2
			$serviceName = "Windows Update"
		} 
		ElseIf($MicrosoftUpdate)
		{
			Write-Debug "Set source of updates to Microsoft Update"
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
		Write-Debug "Set source of updates to $serviceName"
		
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
					Write-Debug "Set pre search criteria: IsInstalled = 1"
				} 
				Else
				{
					$search = "IsInstalled = 0"	
					Write-Debug "Set pre search criteria: IsInstalled = 0"
				} 
				
				If($UpdateType -ne "")
				{
					Write-Debug "Set pre search criteria: Type = $UpdateType"
					$search += " and Type = '$UpdateType'"
				} 				
				
				If($UpdateID)
				{
					Write-Debug "Set pre search criteria: UpdateID = '$([string]::join(", ", $UpdateID))'"
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
							Write-Debug "Set pre search criteria: RevisionNumber = '$RevisionNumber'"	
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
					Write-Debug "Set pre search criteria: CategoryIDs = '$([string]::join(", ", $CategoryIDs))'"
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
					Write-Debug "Set pre search criteria: IsHidden = 1"
					$search += " and IsHidden = 1"	
				} 
				ElseIf($WithHidden) 
				{
					Write-Debug "Set pre search criteria: IsHidden = 1 and IsHidden = 0"
				} 
				Else
				{
					Write-Debug "Set pre search criteria: IsHidden = 0"
					$search += " and IsHidden = 0"	
				} 
				
				If($IgnoreRebootRequired) 
				{
					Write-Debug "Set pre search criteria: RebootRequired = 0"
					$search += " and RebootRequired = 0"	
				} 
			} 
			
			Write-Debug "Search criteria is: $search"
			
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
			Write-Debug "Set post search criteria: $($Update.Title)"
			
			If($Category -ne "")
			{
				$UpdateCategories = $Update.Categories | Select-Object Name
				Write-Debug "Set post search criteria: Categories = '$([string]::join(", ", $Category))'"	
				Foreach($Cat in $Category)
				{
					If(!($UpdateCategories -match $Cat))
					{
						Write-Debug "UpdateAccess: false"
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
				Write-Debug "Set post search criteria: NotCategories = '$([string]::join(", ", $NotCategory))'"	
				Foreach($Cat in $NotCategory)
				{
					If($UpdateCategories -match $Cat)
					{
						Write-Debug "UpdateAccess: false"
						$UpdateAccess = $false
					} 
				} 
			} 		
			
			If($KBArticleID -ne $null -and $UpdateAccess -eq $true)
			{
				Write-Debug "Set post search criteria: KBArticleIDs = '$([string]::join(", ", $KBArticleID))'"
				If(!($KBArticleID -match $Update.KBArticleIDs -and "" -ne $Update.KBArticleIDs))
				{
					Write-Debug "UpdateAccess: false"
					$UpdateAccess = $false
				}								
			} 
			If($NotKBArticleID -ne $null -and $UpdateAccess -eq $true)
			{
				Write-Debug "Set post search criteria: NotKBArticleIDs = '$([string]::join(", ", $NotKBArticleID))'"
				If($NotKBArticleID -match $Update.KBArticleIDs -and "" -ne $Update.KBArticleIDs)
				{
					Write-Debug "UpdateAccess: false"
					$UpdateAccess = $false
				}				
			}
			
			If($Title -and $UpdateAccess -eq $true)
			{
				Write-Debug "Set post search criteria: Title = '$Title'"
				If($Update.Title -notmatch $Title)
				{
					Write-Debug "UpdateAccess: false"
					$UpdateAccess = $false
				} 
			} 

			If($NotTitle -and $UpdateAccess -eq $true)
			{
				Write-Debug "Set post search criteria: NotTitle = '$NotTitle'"
				If($Update.Title -match $NotTitle)
				{
					Write-Debug "UpdateAccess: false"
					$UpdateAccess = $false
				} 
			} 
			
			If($IgnoreUserInput -and $UpdateAccess -eq $true)
			{
				Write-Debug "Set post search criteria: CanRequestUserInput"
				If($Update.InstallationBehavior.CanRequestUserInput -eq $true)
				{
					Write-Debug "UpdateAccess: false"
					$UpdateAccess = $false
				} 
			} 

			If($IgnoreRebootRequired -and $UpdateAccess -eq $true) 
			{
				Write-Debug "Set post search criteria: RebootBehavior"
				If($Update.InstallationBehavior.RebootBehavior -ne 0)
				{
					Write-Debug "UpdateAccess: false"
					$UpdateAccess = $false
				} 
			}  

			If($UpdateAccess -eq $true)
			{
				Write-Debug "Convert size"
				Switch($Update.MaxDownloadSize)
				{
					{[System.Math]::Round($_/1KB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1KB,0))+" KB"}
					{[System.Math]::Round($_/1MB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1MB,0))+" MB"}  
					{[System.Math]::Round($_/1GB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1GB,0))+" GB"}    
					{[System.Math]::Round($_/1TB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1TB,0))+" TB"}
					default { $size = $_+"B" }
				} 
			
				Write-Debug "Convert KBArticleIDs"
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
					$objCollectionUpdate.Add($Update) | Out-Null
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
			Write-Debug "Return only list of updates"
			Return $UpdateCollection				
		} 

		

		If(!$ListOnly) 
		{

			
			Write-Debug "STAGE 2: Choose updates"			
			$NumberOfUpdate = 1
			$logCollection = @()
			
			$objCollectionChoose = New-Object -ComObject "Microsoft.Update.UpdateColl"

			Foreach($Update in $objCollectionUpdate)
			{	
				$size = $UpdatesExtraDataCollection[$Update.Identity.UpdateID].Size
				Write-Progress -Activity "[2/$NumberOfStage] Choose updates" -Status "[$NumberOfUpdate/$FoundUpdatesToDownload] $($Update.Title) $size" -PercentComplete ([int]($NumberOfUpdate/$FoundUpdatesToDownload * 100))
				Write-Debug "Show update to accept: $($Update.Title)"
				
				If($AcceptAll)
				{
					$Status = "Accepted"

					If($Update.EulaAccepted -eq 0)
					{ 
						Write-Debug "Accept Eula"
						$Update.AcceptEula() 
					} 
			
					Write-Debug "Add update to collection"
					$objCollectionChoose.Add($Update) | Out-Null
				}
				ElseIf($AutoSelectOnly)  
				{  
					If($Update.AutoSelectOnWebsites)  
					{  
						$Status = "Accepted"  
						If($Update.EulaAccepted -eq 0)  
						{  
							Write-Debug "Accept Eula"  
							$Update.AcceptEula()  
						} 
  
						Write-Debug "Add update to collection"  
						$objCollectionChoose.Add($Update) | Out-Null  
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
							Write-Debug "Accept Eula"
							$Update.AcceptEula() 
						} 
				
						Write-Debug "Add update to collection"
						$objCollectionChoose.Add($Update) | Out-Null 
					} 
					Else
					{
						$Status = "Rejected"
					} 
				} 
				
				Write-Debug "Add to log collection"
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
				

			
			Write-Debug "STAGE 3: Download updates"
			$NumberOfUpdate = 1
			$objCollectionDownload = New-Object -ComObject "Microsoft.Update.UpdateColl" 

			Foreach($Update in $objCollectionChoose)
			{
				Write-Progress -Activity "[3/$NumberOfStage] Downloading updates" -Status "[$NumberOfUpdate/$AcceptUpdatesToDownload] $($Update.Title) $size" -PercentComplete ([int]($NumberOfUpdate/$AcceptUpdatesToDownload * 100))
				Write-Debug "Show update to download: $($Update.Title)"
				
				Write-Debug "Send update to download collection"
				$objCollectionTmp = New-Object -ComObject "Microsoft.Update.UpdateColl"
				$objCollectionTmp.Add($Update) | Out-Null
					
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
				
				Write-Debug "Check ResultCode"
				Switch -exact ($DownloadResult.ResultCode)
				{
					0   { $Status = "NotStarted" }
					1   { $Status = "InProgress" }
					2   { $Status = "Downloaded" }
					3   { $Status = "DownloadedWithErrors" }
					4   { $Status = "Failed" }
					5   { $Status = "Aborted" }
				} 
				
				Write-Debug "Add to log collection"
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
					$objCollectionDownload.Add($Update) | Out-Null
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

				
				Write-Debug "STAGE 4: Install updates"
				$NeedsReboot = $false
				$NumberOfUpdate = 1
				
					
				Foreach($Update in $objCollectionDownload)
				{   
					Write-Progress -Activity "[4/$NumberOfStage] Installing updates" -Status "[$NumberOfUpdate/$ReadyUpdatesToInstall] $($Update.Title)" -PercentComplete ([int]($NumberOfUpdate/$ReadyUpdatesToInstall * 100))
					Write-Debug "Show update to install: $($Update.Title)"
					
					Write-Debug "Send update to install collection"
					$objCollectionTmp = New-Object -ComObject "Microsoft.Update.UpdateColl"
					$objCollectionTmp.Add($Update) | Out-Null
					
					$objInstaller = $objSession.CreateUpdateInstaller()
					$objInstaller.Updates = $objCollectionTmp
						
					Try
					{
						Write-Debug "Try install update"
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
						Write-Debug "Set instalation status RebootRequired"
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
				   
					Write-Debug "Add to log collection"
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

if($PSVersionTable.PSVersion.Major -ge 3){
cls
Write-Host "Unblocking Windows files..."
Get-ChildItem -Recurse -Force C:\ | Unblock-File
Get-ChildItem -Recurse -Force  D:\  | Unblock-File
Get-ChildItem -Recurse -Force  X:\ | Unblock-File
Get-ChildItem -Recurse -Force  $dir | Unblock-File
}
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
# Disables Windows Features
Dism /online /Disable-Feature /FeatureName:WindowsGadgetPlatform /norestart | out-null
Dism /online /Disable-Feature /FeatureName:InboxGames /norestart | out-null
Dism /online /Disable-Feature /FeatureName:MediaPlayback /norestart | out-null
Dism /online /Disable-Feature /FeatureName:TabletPCOC /norestart | out-null
Dism /online /Disable-Feature /FeatureName:Xps-Foundation-Xps-Viewer /norestart | out-null
Dism /online /Disable-Feature /FeatureName:Printing-XPSServices-Features /norestart | out-null
update
$title = "Restart menu"
$message = "Would you like to restart?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "Yes"

$no = New-Object System.Management.Automation.Host.ChoiceDescription "No"


$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {Restart-Computer -Force}
        1 {exit}
        }
        }



Function update {
cls
Write-Host "Installing Windows Updates, It will restart after if you are running this for the first time..."
Get-WUInstall -AcceptAll -IgnoreUserInput -IgnoreReboot | out-null
# Installs custom updates for this patcher and restarts
Get-WUInstall -KBArticleID "KB968930","KB2506146","KB2506143","KB2819745","KB2858728" -AcceptAll -IgnoreReboot | out-null
}

Function patcher {
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
Start-Process .\lol.launcher.exe
$tbb = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$LoL\solutions\lol_game_client_sln\releases\$sln\deploy\tbb.dll") | select -f 1 | Select-Object -ExpandProperty "FileVersion"
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


# Imports the module for BITS
Import-Module BitsTransfer

# Updates "Help" (for devs to help out with this patch)
Update-Help

# Deletes Windows Update Cache
Stop-Service wuauserv
Remove-Item C:\Windows\SoftwareDistribution\* -Recurse -Force
Start-Service wuauser
cls


# Finds the LoL Directory from registry
$LoL = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Riot Games\RADS" | Select-Object -ExpandProperty "LocalRootFolder"

#Nvidia CG Directory
$CG = Get-ItemProperty "HKLM:\SYSTEM\ControlSet001\Control\Session Manager\Environment" | Select-Object -ExpandProperty "CG_BIN_PATH"

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