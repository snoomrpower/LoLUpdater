LoLUpdater
==========
Only for Win7SP1+ (If you have WIN7SP0 you need to Install SP1 first)

SAVE ALL YOUR WORK BEFORE RUNNING THIS PATCH, IT FORCE RESTARTS THE COMPUTER 2 TIMES

Go to C:\Riot Games\League of Legends\RADS\projects\lol_air_client\releases
Delete all folders except the newest one

Right Click the zip file -> Properties -> Unblock

Open a Powershell prompt as administrator
cd "C:\Riot Games\League of Legends"
Set-ExecutionPolicy Unrestricted
.\LoLTweaker.ps1

After the first restart you should just rerun the script, it will the restart again and you can play your game.
