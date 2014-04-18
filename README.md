LoLUpdater
==========
Prerequsistes:

XP users need this first: http://www.microsoft.com/en-us/download/details.aspx?id=16818

Vista 64bit: http://www.microsoft.com/en-us/download/details.aspx?id=9239

Vista 32bit: http://www.microsoft.com/sv-se/download/details.aspx?id=9864

--------------

SAVE ALL YOUR WORK BEFORE RUNNING THIS PATCH, IT FORCE RESTARTS THE COMPUTER 1 TIME

Go to C:\Riot Games\League of Legends\RADS\projects\lol_air_client\releases
Delete all folders except the newest one

Right Click the zip file -> Properties -> Unblock

Open a Powershell prompt as administrator

cd "C:\Riot Games\League of Legends"

Set-ExecutionPolicy Unrestricted

.\LoLUpdater.ps1

After the first restart you should just rerun the script, it will the restart again and you can play your game.
