# StratAssist
*A script for parsing Armello's log files, to find game statistics and player strategies.*

**Usage**

Download the StratAssist zip, and extract the StratAssist-master folder to a location of your choice

Open the "Run" dialog box, by pressing the Windows Key+R

In the dialogue, type "PowerShell -ExecutionPolicy Unrestricted" and hit Enter

A PowerShell window will open. Drag and drop StratAssist.ps1 into the window and hit Enter

**Features**

On execution, StratAssist will locate Armello's log folder and begin reading the log files. Upon completion, it will output a CSV spreadsheet containing data from all logged online multiplayer games. The data includes:

* Game number, type, and identifier
* Board seed, and tile counts
* Competitor usernames, hero choices, and loadout (In turn order)
* Winning player, hero, and condition

Finally, StratAssist will calculate and display local game statistics. These include the win rate and number of games played, won, lost, or dropped.
