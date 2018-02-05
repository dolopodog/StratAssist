# StratAssist
*A script for parsing Armello log files, to find game statistics and player strategies.*

**Usage**

Download StratAssist to a folder of your choice.

Execute using the PowerShell Window, or by right clicking StratAssist.ps1 and selecting "Run with PowerShell" in the context menu.

**Features**

On execution, StratAssist will locate Armello's log folder and begin reading the log files. Upon completion, it will output a CSV spreadsheet containing data from all logged online multiplayer games. The data includes:

* Game number, type, and identifier
* Board seed, and tile counts
* Competitor usernames, hero choices, and loadout (In turn order)
* Winning player, hero, and condition

Finally, StratAssist will calculate and display local game statistics. These include the win rate and number of games played, won, lost, or dropped.
