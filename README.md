LoLUpdater
==========

SAVE ALL YOUR WORK BEFORE RUNNING THIS PATCH, IT FORCE RESTARTS THE COMPUTER 1 TIME

Go to C:\Riot Games\League of Legends\RADS\projects\lol_air_client\releases
Delete all folders except the newest one

Right Click the zip file -> Properties -> Unblock

Open a Windows command prompt as admin

cd "Path of extractions (where the files are)"

powershell -NoProfile -ExecutionPolicy bypass -File LoLUpdater.ps1

After the first restart you should just rerun the script, it will the restart again and you can play your game.
