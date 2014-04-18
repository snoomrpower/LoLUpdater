LoLUpdater
==========

SAVE ALL YOUR WORK BEFORE RUNNING THIS PATCH, IT FORCE RESTARTS THE COMPUTER 1 TIME

Go to C:\Riot Games\League of Legends\RADS\projects\lol_air_client\releases
Delete all folders except the newest one

Download this: http://developer.download.nvidia.com/cg/Cg_3.1/Cg-3.1_April2012_Setup.exe

goto C:\Program Files (x86)\NVIDIA Corporation\Cg\bin and copy "cg.dll","cgD3D9","cgGl.dll"

copy these files to

C:\Riot Games\League of Legends\RADS\projects\lol_launcher\releases\0.0.0.205(orlatestnumber)\deploy
and
C:\Riot Games\League of Legends\RADS\solutions\lol_game_client_sln\releases\0.0.1.17(orlatestnumber)\deploy

Right Click the zip file -> Properties -> Unblock

Open a Windows command prompt as admin

Commands:

cd "Path of extractions" (where the files are)

powershell -NoProfile -ExecutionPolicy bypass -File LoLUpdater.ps1


After the restart you should rerun the script again to patch the game.

It creates a errors.log in C:\Windows\Temp
