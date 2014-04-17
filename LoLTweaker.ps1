$acl = get-acl c:\
$accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $env:UserName,”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”
$acl.AddAccessRule($accessRule)
$principal = New-Object Security.Principal.NTAccount "$env:computername\$env:UserName"
$acl.psbase.SetOwner($principal)

function Set-Owner {
 param(
  [System.Security.Principal.IdentityReference]$Principal=$(throw "Mandatory parameter -Principal missing."),
  $Env:ProgramFiles=$(throw "Mandatory parameter -File missing.")
 )
 if(-not (Test-Path $Env:ProgramFiles)){
  throw "File $Env:ProgramFiles is missing."
 }
 if($Principal -eq $null){
  throw "Principal is NULL"
 }


 $code = @"
using System;
using System.Runtime.InteropServices;


namespace CosmosKey.Utils
{
 public class TokenManipulator
 {


  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
  ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);


  [DllImport("kernel32.dll", ExactSpelling = true)]
  internal static extern IntPtr GetCurrentProcess();


  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr
  phtok);


  [DllImport("advapi32.dll", SetLastError = true)]
  internal static extern bool LookupPrivilegeValue(string host, string name,
  ref long pluid);


  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct TokPriv1Luid
  {
   public int Count;
   public long Luid;
   public int Attr;
  }


  internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
  internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
  internal const int TOKEN_QUERY = 0x00000008;
  internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;


  public const string SE_ASSIGNPRIMARYTOKEN_NAME = "SeAssignPrimaryTokenPrivilege";
  public const string SE_AUDIT_NAME = "SeAuditPrivilege";
  public const string SE_BACKUP_NAME = "SeBackupPrivilege";
  public const string SE_CHANGE_NOTIFY_NAME = "SeChangeNotifyPrivilege";
  public const string SE_CREATE_GLOBAL_NAME = "SeCreateGlobalPrivilege";
  public const string SE_CREATE_PAGEFILE_NAME = "SeCreatePagefilePrivilege";
  public const string SE_CREATE_PERMANENT_NAME = "SeCreatePermanentPrivilege";
  public const string SE_CREATE_SYMBOLIC_LINK_NAME = "SeCreateSymbolicLinkPrivilege";
  public const string SE_CREATE_TOKEN_NAME = "SeCreateTokenPrivilege";
  public const string SE_DEBUG_NAME = "SeDebugPrivilege";
  public const string SE_ENABLE_DELEGATION_NAME = "SeEnableDelegationPrivilege";
  public const string SE_IMPERSONATE_NAME = "SeImpersonatePrivilege";
  public const string SE_INC_BASE_PRIORITY_NAME = "SeIncreaseBasePriorityPrivilege";
  public const string SE_INCREASE_QUOTA_NAME = "SeIncreaseQuotaPrivilege";
  public const string SE_INC_WORKING_SET_NAME = "SeIncreaseWorkingSetPrivilege";
  public const string SE_LOAD_DRIVER_NAME = "SeLoadDriverPrivilege";
  public const string SE_LOCK_MEMORY_NAME = "SeLockMemoryPrivilege";
  public const string SE_MACHINE_ACCOUNT_NAME = "SeMachineAccountPrivilege";
  public const string SE_MANAGE_VOLUME_NAME = "SeManageVolumePrivilege";
  public const string SE_PROF_SINGLE_PROCESS_NAME = "SeProfileSingleProcessPrivilege";
  public const string SE_RELABEL_NAME = "SeRelabelPrivilege";
  public const string SE_REMOTE_SHUTDOWN_NAME = "SeRemoteShutdownPrivilege";
  public const string SE_RESTORE_NAME = "SeRestorePrivilege";
  public const string SE_SECURITY_NAME = "SeSecurityPrivilege";
  public const string SE_SHUTDOWN_NAME = "SeShutdownPrivilege";
  public const string SE_SYNC_AGENT_NAME = "SeSyncAgentPrivilege";
  public const string SE_SYSTEM_ENVIRONMENT_NAME = "SeSystemEnvironmentPrivilege";
  public const string SE_SYSTEM_PROFILE_NAME = "SeSystemProfilePrivilege";
  public const string SE_SYSTEMTIME_NAME = "SeSystemtimePrivilege";
  public const string SE_TAKE_OWNERSHIP_NAME = "SeTakeOwnershipPrivilege";
  public const string SE_TCB_NAME = "SeTcbPrivilege";
  public const string SE_TIME_ZONE_NAME = "SeTimeZonePrivilege";
  public const string SE_TRUSTED_CREDMAN_ACCESS_NAME = "SeTrustedCredManAccessPrivilege";
  public const string SE_UNDOCK_NAME = "SeUndockPrivilege";
  public const string SE_UNSOLICITED_INPUT_NAME = "SeUnsolicitedInputPrivilege";        


  public static bool AddPrivilege(string privilege)
  {
   try
   {
    bool retVal;
    TokPriv1Luid tp;
    IntPtr hproc = GetCurrentProcess();
    IntPtr htok = IntPtr.Zero;
    retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
    tp.Count = 1;
    tp.Luid = 0;
    tp.Attr = SE_PRIVILEGE_ENABLED;
    retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
    retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
    return retVal;
   }
   catch (Exception ex)
   {
    throw ex;
   }


  }
  public static bool RemovePrivilege(string privilege)
  {
   try
   {
    bool retVal;
    TokPriv1Luid tp;
    IntPtr hproc = GetCurrentProcess();
    IntPtr htok = IntPtr.Zero;
    retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
    tp.Count = 1;
    tp.Luid = 0;
    tp.Attr = SE_PRIVILEGE_DISABLED;
    retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
    retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
    return retVal;
   }
   catch (Exception ex)
   {
    throw ex;
   }


  }
 }
}
"@


 $errPref = $ErrorActionPreference
 $ErrorActionPreference= "silentlycontinue"
 $type = [CosmosKey.Utils.TokenManipulator]
 $ErrorActionPreference = $errPref
 if($type -eq $null){
  add-type $code
 }
 $acl = Get-Acl $Env:ProgramFiles
 $acl.psbase.SetOwner($principal)
 $acl.AddAccessRule($accessRule)
 [void][CosmosKey.Utils.TokenManipulator]::AddPrivilege([CosmosKey.Utils.TokenManipulator]::SE_RESTORE_NAME)
 set-acl -Path $Env:ProgramFiles -AclObject $acl -passthru
 [void][CosmosKey.Utils.TokenManipulator]::RemovePrivilege([CosmosKey.Utils.TokenManipulator]::SE_RESTORE_NAME)
}
cls
Write-Host "Setting Windows Permissions..."
set-owner $(new-object security.principal.ntaccount "$env:computername\$env:UserName") C:\
cls
Write-Host "Unblocking Windows files..."
function unblock {
Get-ChildItem -Recurse -Force C:\ | Unblock-File
Get-ChildItem -Recurse -Force  D:\  | Unblock-File
Get-ChildItem -Recurse -Force  X:\ | Unblock-File
}

cls
Write-Host "Clearing Windows Update Cache and installing updates"
Stop-Service wuauserv
Remove-Item C:\Windows\SoftwareDistribution\* -Recurse -Force
Start-Service wuauserv

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
					Break
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
						Break
					} 
				} 
				Else
				{
					If($objService.IsDefaultAUService -eq $True)
					{
						$serviceName = $objService.Name
						Break
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
						Break
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
						Break
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
					{[System.Math]::Round($_/1KB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1KB,0))+" KB"; break }
					{[System.Math]::Round($_/1MB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1MB,0))+" MB"; break }  
					{[System.Math]::Round($_/1GB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1GB,0))+" GB"; break }    
					{[System.Math]::Round($_/1TB,0) -lt 1024} { $size = [String]([System.Math]::Round($_/1TB,0))+" TB"; break }
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
				} #End If $AcceptAll
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

Write-Host "Installing Windows Updates..."

Get-WUInstall -IgnoreUserInput -AcceptAll -IgnoreUserInput | out-null
Get-WUInstall -Type "Software" -KBArticleID "KB2819745","KB2858728" -AcceptAll -IgnoreUserInput -AutoReboot | out-null


$dir = $PsScriptRoot
Import-Module BitsTransfer
if(!(Test-Path C:\Users\$env:UserName\Documents\WindowsPowershell\Modules\NTFSSecurity\NTFSSecurity.dll)){
if(Test-Path .\NTFSSecurity.zip){Copy-Item .\NTFSSecurity\ C:\Users\$env:UserName\Documents\WindowsPowershell\Modules -recurse}
Write-Host "Downloading files..."
Start-BitsTransfer https://www.bugsplatsoftware.com/files/BugSplatNative.zip
Start-BitsTransfer http://gallery.technet.microsoft.com/scriptcenter/1abd77a5-9c0b-4a2b-acef-90dbb2b84e85/file/107400/1/NTFSSecurity.zip
new-item NTFSSecurity -itemtype directory
Start-Process 7z.exe "x NTFSSecurity.zip -oNTFSSecurity -y"
Start-Process 7z.exe "x BugSplatNative.zip -oBugSplatNative -y"
Copy-Item .\NTFSSecurity\ C:\Users\$env:UserName\Documents\WindowsPowershell\Modules -recurse
}


if($PSVersionTable.PSVersion.Major -eq 4 ) {
cls
Write-Host "Closing League of Legends..."
Stop-Process -ProcessName LoLLauncher
Stop-Process -ProcessName LoLClient
Write-Host "Patching LoL"
Pop-Location
Push-Location
Push-Location RADS\solutions\lol_game_client_sln\releases
$sln = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1
Pop-Location
Push-Location RADS\projects\lol_launcher\releases
$launch = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1
Pop-Location
Push-Location RADS\projects\lol_air_client\releases
$air = gci | ? {$_.PSIsContainer} | sort CreationTime -desc | select -f 1
cd $dir

Copy-Item .\BugSplatNative\bin\BsSndRpt.exe .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\BugSplatNative\bin\BugSplat.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\dbghelp.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cg.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cgD3D9.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cgGL.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\tbb.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\NPSWF32.dll "RADS\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources"
Copy-Item "Adobe Air.dll" "RADS\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\"
cls
Write-Host "Starting The LoL-Launcher"
Start-Process .\lol.launcher.exe
cls
Write-Host "Importing Modules and updating Help"
Import-Module NTFSSecurity
Update-Help

cls
Write-Host "Configuring Windows Services..."
Set-Service -Name AppMgmt -StartupType Disabled | out-null
Set-Service -Name bthserv -StartupType Disabled | out-null
Set-Service -Name PeerDistSvc -StartupType Disabled | out-null
Set-Service -Name CertPropSvc -StartupType Disabled | out-null
Set-Service -Name NfsClnt -StartupType Disabled | out-null
Set-Service -Name WPCSvc -StartupType Disabled | out-null
Set-Service -Name vmickvpexchange -StartupType Disabled | out-null
Set-Service -Name vmicguestinterface -StartupType Disabled | out-null
Set-Service -Name vmicshutdown -StartupType Disabled | out-null
Set-Service -Name vmicheartbeat -StartupType Disabled | out-null
Set-Service -Name vmicrdv -StartupType Disabled | out-null
Set-Service -Name vmictimesync -StartupType Disabled | out-null
Set-Service -Name vmicvss -StartupType Disabled | out-null
Set-Service -Name TrkWks -StartupType Disabled | out-null
Set-Service -Name IEEtwCollectorService -StartupType Disabled | out-null
Set-Service -Name iphlpsvc -StartupType Disabled | out-null
Set-Service -Name MSiSCSI -StartupType Disabled | out-null
Set-Service -Name Netlogon -StartupType Disabled | out-null
Set-Service -Name napagent -StartupType Disabled | out-null
Set-Service -Name CscService -StartupType Disabled | out-null
Set-Service -Name WPCSvc -StartupType Disabled | out-null
Set-Service -Name RpcLocator -StartupType Disabled | out-null
Set-Service -Name SensrSvc -StartupType Disabled | out-null
Set-Service -Name ScDeviceEnum -StartupType Disabled | out-null
Set-Service -Name SCPolicySvc -StartupType Disabled | out-null
Set-Service -Name RemoteRegistry -StartupType Disabled | out-null
Set-Service -Name SCardSvr -StartupType Disabled | out-null
Set-Service -Name SCPolicySvc -StartupType Disabled | out-null
Set-Service -Name SNMPTRAP -StartupType Disabled | out-null
Set-Service -Name StorSvc -StartupType Disabled | out-null
Set-Service -Name WbioSrvc -StartupType Disabled | out-null
Set-Service -Name wcncsvc -StartupType Disabled | out-null
Set-Service -Name fsvc -StartupType Disabled | out-null
Set-Service -Name WMPNetworkSvc -StartupType Disabled | out-null
Set-Service -Name WSearch -StartupType Disabled | out-null
cls
Write-Host "Configuring Windows Features..."
Dism /online /Disable-Feature /FeatureName:WindowsGadgetPlatform /norestart | out-null
Dism /online /Disable-Feature /FeatureName:InboxGames /norestart | out-null
Dism /online /Disable-Feature /FeatureName:MediaPlayback /norestart | out-null
Dism /online /Disable-Feature /FeatureName:TabletPCOC /norestart | out-null
Dism /online /Disable-Feature /FeatureName:Xps-Foundation-Xps-Viewer /norestart | out-null
Dism /online /Disable-Feature /FeatureName:Printing-XPSServices-Features /norestart | out-null
cls
Write-Host "Cleaning Up..."
$PMB = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Pando Networks\PMB"| Select-Object -ExpandProperty "Program Directory"
Start-Process $PMB\uninst.exe
Remove-Item .\NTFSSecurity -recurse
Remove-Item .\NTFSSecurity.zip 
Remove-Item .\BugSplatNative -recurse
Remove-Item .\BugSplatNative.zip
Restart-Computer -Force
}
Else
{Exit}