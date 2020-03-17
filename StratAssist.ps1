<#
StratAssist V2.0

A script for parsing Armello's log files to find game statistics and player strategies.

    Copyright (C) 2018  Dolop O'Dog

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/
#>

$date = Get-Date "1/1/1970"
$curdir = Split-Path -parent $PSCommandPath
$curtime = (Get-Date).ToString("yyyyMMdd_HHmmss")
$logdir = $logdir = "$env:appdata\..\LocalLow\League of Geeks\Armello\Accounts\*\Games\*.json"
    $raw = Get-ChildItem $logdir | Where-Object {$_.length -gt 10000} | Sort-Object LastWriteTime -Descending
    Clear-Host
    Write-Host Found $raw.count Logs

$create = New-Object System.Collections.Generic.List[System.Object]
$start = New-Object System.Collections.Generic.List[System.Object]
$hero = New-Object System.Collections.Generic.List[System.Object]
$p1hero = New-Object System.Collections.Generic.List[System.Object]
$p2hero = New-Object System.Collections.Generic.List[System.Object]
$p3hero = New-Object System.Collections.Generic.List[System.Object]
$p4hero = New-Object System.Collections.Generic.List[System.Object]
$state = New-Object System.Collections.Generic.List[System.Object]
$p1state = New-Object System.Collections.Generic.List[System.Object]
$p2state = New-Object System.Collections.Generic.List[System.Object]
$p3state = New-Object System.Collections.Generic.List[System.Object]
$p4state = New-Object System.Collections.Generic.List[System.Object]
$stats = New-Object System.Collections.Generic.List[System.Object]
$p1stats = New-Object System.Collections.Generic.List[System.Object]
$p2stats = New-Object System.Collections.Generic.List[System.Object]
$p3stats = New-Object System.Collections.Generic.List[System.Object]
$p4stats = New-Object System.Collections.Generic.List[System.Object]
$game = New-Object System.Collections.Generic.List[System.Object]
$compare = New-Object System.Collections.Generic.List[System.Object]
$multi = New-Object System.Collections.Generic.List[System.Object]
$single = New-Object System.Collections.Generic.List[System.Object]
$table = New-Object System.Collections.Generic.List[System.Object]

$ofs = ' '
$progress=0

$table.clear()

ForEach($i in $raw)
{

    $json = $i | Get-Content | Select-String -CaseSensitive 'SessionGame', 'HeroSelection', 'GameWon', 'GameLost', 'GameDidNotFinish',  'EndStats' | ConvertFrom-Json
    $duration = 0
    $turn = 0

    $hero.clear()
    $state.clear()
    $stats.clear()

    ForEach($j in $json)
    {

        If($j.EventName -eq "SessionGameCreate")
        {

            $create.clear()

            $create.add([pscustomobject]@{
                date=$date.AddSeconds($j.Time).ToLocalTime()
                gameMode=$j.Properties.GameData.GameMode
                matchMode=$j.Properties.GameData.MatchmakingMode
            })

        }

        If($j.EventName -eq "SessionGameStart")
        {

            $start.clear()
            
            $start.add([pscustomobject]@{
                plains=$j.Properties.MapData.TileCounts.Plains
                forests=$j.Properties.MapData.TileCounts.Forest
                dungeons=$j.Properties.MapData.TileCounts.Dungeon
                mountains=$j.Properties.MapData.TileCounts.Mountains
                settlements=$j.Properties.MapData.TileCounts.Settlement
                swamps=$j.Properties.MapData.TileCounts.Swamp
                stoneCircles=$j.Properties.MapData.TileCounts.StoneCircle
            })

        }

        If($j.EventName -eq "HeroSelection")
        {

            $hero.add([pscustomobject]@{
                heroName=$j.Properties.HeroSelectionData.HeroName
                heroSkin=$j.Properties.HeroSelectionData.HeroSkinName
                diceSkin=$j.Properties.HeroSelectionData.DieName
                amulet=$j.Properties.HeroSelectionData.AmuletName
                signet=$j.Properties.HeroSelectionData.SignetName
                playerType=$j.Properties.PlayerType
            })

        }

        If($j.EventName -eq "GameStateAchieved")
        {

            $state.add([pscustomobject]@{
                playerType=$j.Properties.PlayerType
                playerID=$j.Properties.PlayerNetworkID
            })

        }

        If($j.EventName -match 'EndStats')
        {

            $stats.add([pscustomobject]@{
                fight=$j.Properties.PlayerStatsData.Fight
                body=$j.Properties.PlayerStatsData.Body
                health=$j.Properties.PlayerStatsData.Health
                wits=$j.Properties.PlayerStatsData.Wits
                spirit=$j.Properties.PlayerStatsData.Spirit
                gold=$j.Properties.PlayerStatsData.Gold
                magic=$j.Properties.PlayerStatsData.Magic
                rot=$j.Properties.PlayerStatsData.Rot
                prestige=$j.Properties.PlayerStatsData.Prestige
                settlements=$j.Properties.PlayerStatsData.Settlements
                spiritStones=$j.Properties.PlayerStatsData.SpiritStones
                turns=$j.Properties.PlayerStatsData.Turns
            })

        }

        If($j.EventName -eq "SessionGame")
        {
            
            $game.clear()

            $game.add([pscustomobject]@{
                victoryType=$j.Properties.VictoryType
                playerWin=$j.Properties.VictoryState
                duration=[math]::Round($j.Duration/60,2)
            })

            $duration += $game.duration

        }

    }

    If($($stats.turns).length -gt 3)
    {
        $stats.turns[-4..-1] | ForEach {$turn += $_}
    }

    $p1hero.clear()
    $p2hero.clear()
    $p3hero.clear()
    $p4hero.clear()
           
    $p1hero.add($($hero | ForEach {$i=0} {if($i++ % 4 -eq 0){$_}}))
    $p2hero.add($($hero | ForEach {$i=1} {if($i++ % 4 -eq 0){$_}}))
    $p3hero.add($($hero | ForEach {$i=2} {if($i++ % 4 -eq 0){$_}}))
    $p4hero.add($($hero | ForEach {$i=3} {if($i++ % 4 -eq 0){$_}}))

    $p1state.clear()
    $p2state.clear()
    $p3state.clear()
    $p4state.clear()
           
    $p1state.add($($state | ForEach {$i=0} {if($i++ % 4 -eq 0){$_}}))
    $p2state.add($($state | ForEach {$i=1} {if($i++ % 4 -eq 0){$_}}))
    $p3state.add($($state | ForEach {$i=2} {if($i++ % 4 -eq 0){$_}}))
    $p4state.add($($state | ForEach {$i=3} {if($i++ % 4 -eq 0){$_}}))

    $p1stats.clear()
    $p2stats.clear()
    $p3stats.clear()
    $p4stats.clear()

    $p1stats.add($($stats | ForEach {$i=0} {if($i++ % 4 -eq 0){$_}}))
    $p2stats.add($($stats | ForEach {$i=1} {if($i++ % 4 -eq 0){$_}}))
    $p3stats.add($($stats | ForEach {$i=2} {if($i++ % 4 -eq 0){$_}}))
    $p4stats.add($($stats | ForEach {$i=3} {if($i++ % 4 -eq 0){$_}}))

    $table.add([pscustomobject]@{
        'Date'=$create.date
        'Game Mode'=$create.gameMode
        'Match Mode'=$create.matchMode
        'Turns'=($turn/4)
        'Duration'=$duration
        'Victory Type'=$game.victoryType
        'Local Outcome'=$game.playerWin
        'Plains'=$start.plains
        'Forests'=$start.forests
        'Dungeons'=$start.dungeons
        'Mountains'=$start.mountains
        'Settlements'=$start.settlements
        'Swamps'=$start.swamps
        'StoneCircles'=$start.stoneCircles
        'P1 Steam ID'="$($p1state.playerID)"
        'P1 Init Type'="$($p1hero.playerType)"
        'P1 End Type'="$($p1state.playerType)"
        'P1 Hero'="$($p1hero.heroName)"
        'P1 Hero Skin'="$($p1hero.heroSkin)"
        'P1 Dice Skin'="$($p1hero.diceSkin)"
        'P1 Amulet'="$($p1hero.amulet)"
        'P1 Ring'="$($p1hero.signet)"
        'P1 Fight'="$($p1stats.fight)"
        'P1 Health'="$($p1stats.health)"
        'P1 Body'="$($p1stats.body)"
        'P1 Wits'="$($p1stats.wits)"
        'P1 Spirit'="$($p1stats.spirit)"
        'P1 Gold'="$($p1stats.gold)"
        'P1 Magic'="$($p1stats.magic)"
        'P1 Prestige'="$($p1stats.prestige)"
        'P1 Rot'="$($p1stats.rot)"
        'P2 Steam ID'="$($p2state.playerID)"
        'P2 Init Type'="$($p2hero.playerType)"
        'P2 End Type'="$($p2state.playerType)"
        'P2 Hero'="$($p2hero.heroName)"
        'P2 Hero Skin'="$($p2hero.heroSkin)"
        'P2 Dice Skin'="$($p2hero.diceSkin)"
        'P2 Amulet'="$($p2hero.amulet)"
        'P2 Ring'="$($p2hero.signet)"
        'P2 Fight'="$($p2stats.fight)"
        'P2 Health'="$($p2stats.health)"
        'P2 Body'="$($p2stats.body)"
        'P2 Wits'="$($p2stats.wits)"
        'P2 Spirit'="$($p2stats.spirit)"
        'P2 Gold'="$($p2stats.gold)"
        'P2 Magic'="$($p2stats.magic)"
        'P2 Prestige'="$($p2stats.prestige)"
        'P2 Rot'="$($p2stats.rot)"
        'P3 Steam ID'="$($p3state.playerID)"
        'P3 Init Type'="$($p3hero.playerType)"
        'P3 End Type'="$($p3state.playerType)"
        'P3 Hero'="$($p3hero.heroName)"
        'P3 Hero Skin'="$($p3hero.heroSkin)"
        'P3 Dice Skin'="$($p3hero.diceSkin)"
        'P3 Amulet'="$($p3hero.amulet)"
        'P3 Ring'="$($p3hero.signet)"
        'P3 Fight'="$($p3stats.fight)"
        'P3 Health'="$($p3stats.health)"
        'P3 Body'="$($p3stats.body)"
        'P3 Wits'="$($p3stats.wits)"
        'P3 Spirit'="$($p3stats.spirit)"
        'P3 Gold'="$($p3stats.gold)"
        'P3 Magic'="$($p3stats.magic)"
        'P3 Prestige'="$($p3stats.prestige)"
        'P3 Rot'="$($p3stats.rot)"
        'P4 Steam ID'="$($p4state.playerID)"
        'P4 Init Type'="$($p4hero.playerType)"
        'P4 End Type'="$($p4state.playerType)"
        'P4 Hero'="$($p4hero.heroName)"
        'P4 Hero Skin'="$($p4hero.heroSkin)"
        'P4 Dice Skin'="$($p4hero.diceSkin)"
        'P4 Amulet'="$($p4hero.amulet)"
        'P4 Ring'="$($p4hero.signet)"
        'P4 Fight'="$($p4stats.fight)"
        'P4 Health'="$($p4stats.health)"
        'P4 Body'="$($p4stats.body)"
        'P4 Wits'="$($p4stats.wits)"
        'P4 Spirit'="$($p4stats.spirit)"
        'P4 Gold'="$($p4stats.gold)"
        'P4 Magic'="$($p4stats.magic)"
        'P4 Prestige'="$($p4stats.prestige)"
        'P4 Rot'="$($p4stats.rot)"
        })

    $progress++
    Write-Progress -Activity "Analyzing..." -Status "$([math]::Round($progress/$raw.count*100))% Complete" -PercentComplete $([math]::Round($progress/$raw.count*100));

}

$table | ConvertTo-CSV -NoTypeInformation | Set-Content "$curdir\StratAssist_$($curtime).csv"

ForEach($t in $table)
{

    $compare.add([pscustomobject]@{
        'multicomplete'=[int]$($t.'Match Mode' -match 'P' -and $t.'Local Outcome' -ne 'DidNotFinish')
        'multiwon'=[int]$($t.'Match Mode' -match 'P' -and $t.'Local Outcome' -eq 'Won')
        'multilost'=[int]$($t.'Match Mode' -match 'P' -and $t.'Local Outcome' -eq 'Lost')
        'singlecomplete'=[int]$($t.'Game Mode' -eq 'Singleplayer' -and $t.'Local Outcome' -ne 'DidNotFinish')
        'singlewon'=[int]$($t.'Game Mode' -eq 'Singleplayer' -and $t.'Local Outcome' -eq 'Won')
        'singlelost'=[int]$($t.'Game Mode' -eq 'Singleplayer' -and $t.'Local Outcome' -eq 'Lost')
    })

}

$multi.add([pscustomobject]@{
    'Multiplayer Games Completed'=$compare.multicomplete | Measure-Object -sum | Select-Object -expand Sum
    'Multiplayer Games Won'=$compare.multiwon | Measure-Object -sum | Select-Object -expand Sum
    'Multiplayer Games Lost'=$compare.multilost | Measure-Object -sum | Select-Object -expand Sum
    'Multiplayer Win Rate'=$($($compare.multiwon | Measure-Object -sum | Select-Object -expand Sum)/$($compare.multicomplete | Measure-Object -sum | Select-Object -expand Sum)).tostring("P")
})

$single.add([pscustomobject]@{
    'Singleplayer Games Completed'=$compare.singlecomplete | Measure-Object -sum | Select-Object -expand Sum
    'Singleplayer Games Won'=$compare.singlewon | Measure-Object -sum | Select-Object -expand Sum
    'Singleplayer Games Lost'=$compare.singlelost | Measure-Object -sum | Select-Object -expand Sum
    'Singleplayer Win Rate'=$($($compare.singlewon | Measure-Object -sum | Select-Object -expand Sum)/$($compare.singlecomplete | Measure-Object -sum | Select-Object -expand Sum)).tostring("P")
})

$multi | Format-Table

$single | Format-Table

Write-Host "`nResults Saved To $curdir\StratAssist_$($curtime).csv"
pause
