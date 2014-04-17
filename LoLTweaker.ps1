Import-Module BitsTransfer
$dir = $PsScriptRoot
$user = "Loggan"
$net = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client" | Select-Object -ExpandProperty "Version"
Remove-Item NTFSSecurity.zip
Remove-Item NDP451-KB2858728-x86-x64-AllOS-ENU.exe
Remove-Item *.msu
Write-Host "Downloading files..."
Start-BitsTransfer http://gallery.technet.microsoft.com/scriptcenter/1abd77a5-9c0b-4a2b-acef-90dbb2b84e85/file/107400/1/NTFSSecurity.zip
new-item .\NTFSSecurity -itemtype directory
Start-Process 7z.exe "x NTFSSecurity.zip -oNTFSSecurity -y"
Copy-Item .\NTFSSecurity\ C:\Users\$User\Documents\WindowsPowershell\Modules -recurse


if(!(Test-Path $net) -eq "4.5.51078")
{

Start-BitsTransfer http://download.microsoft.com/download/1/6/7/167F0D79-9317-48AE-AEDB-17120579F8E2/NDP451-KB2858728-x86-x64-AllOS-ENU.exe

}


if(!(Test-Path .\Windows6.1-KB958830*.msu)){

if (($ENV:Processor_Architecture -eq "AMD64")){
if(!($PSVersionTable.PSVersion.Major -eq 4 )) {
Start-BitsTransfer http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu
}
Start-BitsTransfer http://download.microsoft.com/download/4/F/7/4F71806A-1C56-4EF2-9B4F-9870C4CFD2EE/Windows6.1-KB958830-x64-RefreshPkg.msu
}
Else
{
if(!($PSVersionTable.PSVersion.Major -eq 4 )) {
Start-BitsTransfer http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x86-MultiPkg.msu
}

Start-BitsTransfer http://download.microsoft.com/download/4/F/7/4F71806A-1C56-4EF2-9B4F-9870C4CFD2EE/Windows6.1-KB958830-x86-RefreshPkg.msu
}

ls NDP451-KB2858728-x86-x64-AllOS-ENU.exe | %{start -wait $_ -argumentlist '/quiet /norestart'}
ls *.msu | %{start -wait $_ -argumentlist '/quiet /norestart'}
Restart-Computer
}

try { Import-Module ActiveDirectory }
catch { "Error occured" }
if (error) {
Read-Host "You didn't follow the image or didnt install the updates"
exit
}
Else
{

if($PSVersionTable.PSVersion.Major -eq 4 ) {
Import-Module NTFSSecurity
Update-Help
Write-Host "Finding Latest LoL Update"

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


$file = "C:\Program Files"
$acl = get-acl c:\
$accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $user,”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”
$acl.AddAccessRule($accessRule)
$principal = New-Object Security.Principal.NTAccount "$env:computername\$user"
$acl.psbase.SetOwner($principal)

function Set-Owner {
 param(
  [System.Security.Principal.IdentityReference]$Principal=$(throw "Mandatory parameter -Principal missing."),
  $File=$(throw "Mandatory parameter -File missing.")
 )
 if(-not (Test-Path $file)){
  throw "File $file is missing."
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
 $acl = Get-Acl $File
 $acl.psbase.SetOwner($principal)
 $acl.AddAccessRule($accessRule)
 [void][CosmosKey.Utils.TokenManipulator]::AddPrivilege([CosmosKey.Utils.TokenManipulator]::SE_RESTORE_NAME)
 set-acl -Path $File -AclObject $acl -passthru
 [void][CosmosKey.Utils.TokenManipulator]::RemovePrivilege([CosmosKey.Utils.TokenManipulator]::SE_RESTORE_NAME)
}

Write-Host "Setting Windows Permissions..."
set-owner $(new-object security.principal.ntaccount "$env:computername\$user") C:\
Write-Host "Unblocking Windows files..."
Get-ChildItem -Recurse -Force C:\ | Unblock-File
Get-ChildItem -Recurse -Force  $dir | Unblock-File
Write-Host "Clearing Windows Update Cache..."
Stop-Service wuauserv
Remove-Item -Recurse -Force "$env:windir\SoftwareDistribution"
Start-Service wuauserv
Write-Host "Configuring Windows Services..."
Set-Service -Name AppMgmt -StartupType Disabled
Set-Service -Name bthserv -StartupType Disabled
Set-Service -Name PeerDistSvc -StartupType Disabled
Set-Service -Name CertPropSvc -StartupType Disabled
Set-Service -Name NfsClnt -StartupType Disabled
Set-Service -Name WPCSvc -StartupType Disabled
Set-Service -Name vmickvpexchange -StartupType Disabled
Set-Service -Name vmicguestinterface -StartupType Disabled
Set-Service -Name vmicshutdown -StartupType Disabled
Set-Service -Name vmicheartbeat -StartupType Disabled
Set-Service -Name vmicrdv -StartupType Disabled
Set-Service -Name vmictimesync -StartupType Disabled
Set-Service -Name vmicvss -StartupType Disabled
Set-Service -Name TrkWks -StartupType Disabled
Set-Service -Name IEEtwCollectorService -StartupType Disabled
Set-Service -Name iphlpsvc -StartupType Disabled
Set-Service -Name MSiSCSI -StartupType Disabled
Set-Service -Name Netlogon -StartupType Disabled
Set-Service -Name napagent -StartupType Disabled
Set-Service -Name CscService -StartupType Disabled
Set-Service -Name WPCSvc -StartupType Disabled
Set-Service -Name RpcLocator -StartupType Disabled
Set-Service -Name SensrSvc -StartupType Disabled
Set-Service -Name ScDeviceEnum -StartupType Disabled
Set-Service -Name SCPolicySvc -StartupType Disabled
Set-Service -Name RemoteRegistry -StartupType Disabled
Set-Service -Name SCardSvr -StartupType Disabled
Set-Service -Name SCPolicySvc -StartupType Disabled
Set-Service -Name SNMPTRAP -StartupType Disabled
Set-Service -Name StorSvc -StartupType Disabled
Set-Service -Name WbioSrvc -StartupType Disabled
Set-Service -Name wcncsvc -StartupType Disabled
Set-Service -Name fsvc -StartupType Disabled
Set-Service -Name WMPNetworkSvc -StartupType Disabled
Set-Service -Name WSearch -StartupType Disabled
Write-Host "Closing League of Legends..."
Stop-Process -ProcessName LoLLauncher
Stop-Process -ProcessName LoLClient
Write-Host "Copying files..."
Copy-Item .\BsSndRpt.exe .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\BugSplat.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\dbghelp.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cg.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cgD3D9.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\cgGL.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\tbb.dll .\RADS\solutions\lol_game_client_sln\releases\$sln\deploy
Copy-Item .\NPSWF32.dll "RADS\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\Resources"
Copy-Item "Adobe Air.dll" "RADS\projects\lol_air_client\releases\$air\deploy\Adobe AIR\Versions\1.0\"
Write-Host "Cleaning Up..."
$PMB = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Pando Networks\PMB"| Select-Object -ExpandProperty "Program Directory"
Start-Process $PMB\uninst.exe
Remove-Item .\NTFSSecurity.zip
Remove-Item .\NDP451-KB2858728-x86-x64-AllOS-ENU.exe
Remove-Item .\*.msu
Write-Host "Starting The LoL-Launcher"
Start-Process .\lol.launcher.exe}
Else
{Exit}

}


