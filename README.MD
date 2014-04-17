LoLTweaker
==========
Only for Win7SP1 and up

Right Click the zip file -> Properties -> Unblock

Edit the powershell with notepad and replace $user with your user account name

Open a Powershell prompt as administrator
cd "C:\Riot Games\League of Legends"
Set-ExecutionPolicy Unrestricted
.\LoLTweaker.ps1

After the first restart you should do this:

1.From the Control Panel, click on Programs.
2.Under Programs and Features, select Turn Windows features on or off.
3.Under Remote Server Administration Tools > Role Administration Tools, select AD DS and AD LDS Tools.

Then run the script again
