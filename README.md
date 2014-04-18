LoLUpdater
==========

SAVE ALL YOUR WORK BEFORE RUNNING THIS PATCH, IT FORCE RESTARTS THE COMPUTER 1 TIME
IT ALSO REMOVES WINDOWS MEDIA PLAYER, I RECOMMEND DOWNLOADING VLC

Go to C:\Riot Games\League of Legends\RADS\projects\lol_air_client\releases
Delete all folders except the newest one

Download this: http://developer.download.nvidia.com/cg/Cg_3.1/Cg-3.1_April2012_Setup.exe

Right Click the exe file -> Properties -> Unblock
and install like this: http://imgur.com/z7PhjiS

Download: https://github.com/Loggan08/LoLUpdater/archive/master.zip

Right Click the zip file -> Properties -> Unblock

Edit "Location.reg" and specify the LoL directory that you want to install it on, then save it and run it.

Open a Windows command prompt as admin

Commands:


cd "Path of extraction" (where the files are)

powershell -NoProfile -ExecutionPolicy bypass -File LoLUpdater.ps1

After the restart you should rerun the script again to patch the game.

It creates a log in C:\Windows Temp