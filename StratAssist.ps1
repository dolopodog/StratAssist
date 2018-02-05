<#
StratAssist V1.0

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

#region Set variables
Set-Variable total,drop,skip 0

Set-Variable order,fin @() #endregion

#region Read log files
$path = "$env:appdata\..\LocalLow\League of Geeks\Armello\logs\*M.txt"

$raw = Get-ChildItem $path | %{Write-Host Examining file: $_.name; $_} | Select-String -CaseSensitive -Context 0,13 'Begin Match','Load Game','Setup Game','MapMaking: None:','Creature Equipping Signet','End Game' #endregion

$fix = ForEach ($i in 0..($raw.count-1)){
    If ($raw[$i].line -like '*Begin Match*'){
        If ($raw[$i+8].line -like '*End Game*'){
            $raw[$i..($i+8)]}
        Else{
            $drop++}
        $total++}} #Disregard unfinished games; Count total games played and number of disconnects

Function Id-ToPlaintext($input){
    $input | %{$_ `
        -replace 'Bandit01|0x94B1BC41',"Twiss" `
        -replace 'Bandit02|0x94B1BC42',"Sylas" `
        -replace 'Bandit03|0x94B1BC43',"Horace" `
        -replace 'Bandit04|0x94B1BC44',"Scarlet" `
        -replace 'Bear01|0x765CE8D5',"Sana" `
        -replace 'Bear02|0x765CE8D6',"Brun" `
        -replace 'Bear03|0x765CE8D7',"Ghor" `
        -replace 'Bear04|0x765CE8D8',"Yordana" `
        -replace 'Rabbit01|0xFE2E33BB',"Amber" `
        -replace 'Rabbit02|0xFE2E33BC',"Barnaby" `
        -replace 'Rabbit03|0xFE2E33BD',"Elyssia" `
        -replace 'Rabbit04|0xFE2E33BE',"Hargrave" `
        -replace 'Rat01|0x04B158C6',"Mercurio" `
        -replace 'Rat02|0x04B158C7',"Zosha" `
        -replace 'Rat03|0x04B158C8',"Sargon" `
        -replace 'Rat04|0x04B158C9','Griotte' `
        -replace 'Wolf01|0x9AC46BF3',"Thane" `
        -replace 'Wolf02|0x9AC46BF4',"River" `
        -replace 'Wolf03|0x9AC46BF5',"Magna" `
        -replace 'Wolf04|0x9AC46BF6','Fang' `
        -replace 'SIG01',"Black Opal" `
        -replace 'SIG02',"Obsidian" `
        -replace 'SIG03',"Ruby" `
        -replace 'SIG04',"Turquoise" `
        -replace 'SIG05',"Emerald" `
        -replace 'SIG06',"Pink Topaz" `
        -replace 'SIG07',"Diamond" `
        -replace 'SIG08',"Sunstone" `
        -replace 'SIG09',"Sapphire" `
        -replace 'SIG10',"Moonstone" `
        -replace 'SIG11',"Onyx" `
        -replace 'SIG12',"Celestite" `
        -replace 'SIG13',"Jade" `
        -replace 'SIG14',"Quartz" `
        -replace 'SIG15',"Amethyst" `
        -replace 'SIG16',"Amber" `
        -replace 'SIG17',"Tanzanite" `
        -replace 'SIG18',"Rainbow Quartz" `
        -replace 'SIG19',"Rubellite" `
        -replace 'SIG20',"Aquamarine" `
        -replace 'SIG21',"Serendibite" `
        -replace 'SIG22',"Cat's Eye" `
        -replace 'SIG23',"Spinel" `
        -replace 'SIG24',"Chrysocolla" `
        -replace 'SIG25',"Taaffeite" `
        -replace 'SIG26',"Black Opal" `
        -replace 'SIG27',"Pink Topaz" `
        -replace 'SIG28',"Amethyst" `
        -replace 'SIG29',"Celestite" `
        -replace 'AMU01',"Scratch" `
        -replace 'AMU02',"Soak" `
        -replace 'AMU03',"Think" `
        -replace 'AMU04',"Feel" `
        -replace 'AMU05',"Grow" `
        -replace 'AMU06',"Watch" `
        -replace 'AMU07',"Favour" `
        -replace 'AMU08',"Spoil" `
        -replace 'AMU09',"Listener" `
        -replace 'AMU10',"Dig" `
        -replace 'AMU11',"Sprint" `
        -replace 'AMU12',"Discipline" `
        -replace 'AMU13',"Resist" `
        -replace 'AMU14',"Intimidate" `
        -replace 'BanishKing',"Spirit Stone" `
        -replace 'DefeatKing',"King Slayer"}} #Replace variables with plaintext names

ForEach ($i in $fix){
    If ($i -like '*Creature Equipping Signet*'){
        $order += [regex]::matches($i.context.postcontext[0],'(?<=Player)\d') | %{$_.value}}} #Determine turn order

ForEach ($i in 0..($total-$drop-1)){
    $tmp = [ordered]@{
        'Game' = $i+1}
    ForEach ($j in 0..8){
        $k = $i*9+$j
        if ($fix[$k].line -like '*Begin Match*'){
            $tmp += [ordered]@{
                'Mode' = [regex]::matches($fix[$k].context.postcontext[0],'(?<=Mode:\s).*') | %{$_.value}
                'GameId' = [regex]::matches($fix[$k].context.postcontext,'(?<=GameId:\s).*?(?= )') | %{$_.value}}}
        if ($fix[$k].line -like '*Load Game*'){
            $tmp += [ordered]@{
                'Player1' = [regex]::matches($fix[$k].context.postcontext[$order[$i*4]],'(?<=Name:.*)\S.*(?=,\sNetwork)') | %{$_.value}
                'Hero1' = [regex]::matches($fix[$k].context.postcontext[$order[$i*4]],'(?<=Hero:.*)\S.*') | %{$_.value} | Id-ToPlaintext
                'Player2' = [regex]::matches($fix[$k].context.postcontext[$order[($i*4)+1]],'(?<=Name:.*)\S.*(?=,\sNetwork)') | %{$_.value}
                'Hero2' = [regex]::matches($fix[$k].context.postcontext[$order[($i*4)+1]],'(?<=Hero:.*)\S.*') | %{$_.value} | Id-ToPlaintext
                'Player3' = [regex]::matches($fix[$k].context.postcontext[$order[($i*4)+2]],'(?<=Name:.*)\S.*(?=,\sNetwork)') | %{$_.value}
                'Hero3' = [regex]::matches($fix[$k].context.postcontext[$order[($i*4)+2]],'(?<=Hero:.*)\S.*') | %{$_.value} | Id-ToPlaintext
                'Player4' = [regex]::matches($fix[$k].context.postcontext[$order[($i*4)+3]],'(?<=Name:.*)\S.*(?=,\sNetwork)') | %{$_.value}
                'Hero4' = [regex]::matches($fix[$k].context.postcontext[$order[($i*4)+3]],'(?<=Hero:.*)\S.*') | %{$_.value} | Id-ToPlaintext}}
        if ($fix[$k].line -like '*Setup Game*'){
            $tmp += [ordered]@{
                'Seed' = [regex]::matches($fix[$k].context.postcontext[0],'(?<=Seed:\s).*') | %{$_.value}}}
        If ($fix[$k].line -like '*Mapmaking*'){
            $tmp += [ordered]@{
                'Plains' = [regex]::matches($fix[$k].context.postcontext[0],'(?<=MapMaking.*)\d.*') | %{$_.value}
                'Swamps' = [regex]::matches($fix[$k].context.postcontext[1],'(?<=MapMaking.*)\d.*') | %{$_.value}
                'Forests' = [regex]::matches($fix[$k].context.postcontext[2],'(?<=MapMaking.*)\d.*') | %{$_.value}
                'Mountains' = [regex]::matches($fix[$k].context.postcontext[3],'(?<=MapMaking.*)\d.*') | %{$_.value}
                'StoneCircles' = [regex]::matches($fix[$k].context.postcontext[4],'(?<=MapMaking.*)\d.*') | %{$_.value}
                'Settlements' = [regex]::matches($fix[$k].context.postcontext[5],'(?<=MapMaking.*)\d.*') | %{$_.value}
                'Dungeons' = [regex]::matches($fix[$k].context.postcontext[6],'(?<=MapMaking.*)\d.*') | %{$_.value}}}
        If ($fix[$k].line -like '*Creature Equipping Signet*' -and $skip -eq 0){
            $tmp += [ordered]@{
                'Signet1' = [regex]::matches($fix[$k].line,'(?<=Signet:\s).*') | %{$_.value} | Id-ToPlaintext
                'Amulet1' = [regex]::matches($fix[$k].context.postcontext,'(?<=Amulet:\s).*?(?=\s)') | %{$_.value} | Id-ToPlaintext
                'Signet2' = [regex]::matches($fix[$k+1].line,'(?<=Signet:\s).*') | %{$_.value} | Id-ToPlaintext
                'Amulet2' = [regex]::matches($fix[$k+1].context.postcontext,'(?<=Amulet:\s).*?(?=\s)') | %{$_.value} | Id-ToPlaintext
                'Signet3' = [regex]::matches($fix[$k+2].line,'(?<=Signet:\s).*') | %{$_.value} | Id-ToPlaintext
                'Amulet3' = [regex]::matches($fix[$k+2].context.postcontext,'(?<=Amulet:\s).*?(?=\s)') | %{$_.value} | Id-ToPlaintext
                'Signet4' = [regex]::matches($fix[$k+3].line,'(?<=Signet:\s).*') | %{$_.value} | Id-ToPlaintext
                'Amulet4' = [regex]::matches($fix[$k+3].context.postcontext,'(?<=Amulet:\s).*?(?=\s)') | %{$_.value} | Id-ToPlaintext}
            $skip++}
        If ($fix[$k].line -like '*End Game*'){
            $tmp += [ordered]@{
                'WinningPlayer' = [regex]::matches($fix[$k].context.postcontext[1],'(?<=Winner.*Player.).*(?=.\(Player.\))') | %{$_.value}
                'WinningHero' = [regex]::matches($fix[$k].context.postcontext[1],'(?<=Winner.*Hero.).*(?=.\(\d{4}\))') | %{$_.value} | Id-ToPlaintext
                'WinningCondition' = [regex]::matches($fix[$k].context.postcontext[2],'(?<=GameVictoryType..).*') | %{$_.value} | Id-ToPlaintext
                'Username' = [regex]::matches($fix[$k].filename,'^.*(?=_log)') | %{$_.value}
                'Date' = [regex]::matches($fix[$k].filename,'\d{4}-\d{2}-\d{2}') | %{$_.value}
                'Time' = [regex]::matches($fix[$k].line ,'\d{1,2}:\d{2}:\d{2}') | %{$_.value}}
            $skip--}}
    $fin += @(New-Object PSObject -Property $tmp)
} #Parse data from objects into table entries

#region Create a CSV file
$stamp = [int][double]::parse((Get-Date -UFormat %s))

$fin | Select-Object Game,Username,Date,Time,Mode,GameId,Seed,Plains,Swamps,Forests,Mountains,StoneCircles,Settlements,Dungeons,Player1,Hero1,Signet1,Amulet1,Player2,Hero2,Signet2,Amulet2,Player3,Hero3,Signet3,Amulet3,Player4,Hero4,Signet4,Amulet4,WinningPlayer,WinningHero,WinningCondition | Export-Csv -NoTypeInformation "$($fin.Username[0])-$stamp.csv"

Write-Host "`n`nResults Saved To $($fin.Username[0])-$stamp.csv" #endregion

#region Calculate and display game statistics
Write-Host "`n`nGame Statistics"

$userwon = (0..($fin.count-1) | Where {$fin.WinningPlayer[$_] -eq $fin.Username[$_]}).count
$serverwon = (0..($fin.count-1) | Where {$fin.WinningPlayer[$_] -ne $fin.Username[$_]}).count

$stats = New-Object -TypeName PSObject -Property ([ordered]@{
    'Played' = $total
    'Won' = $userwon
    'Lost' = $serverwon
    'Dropped' = $drop
    'Win Rate' =($userwon/($total-$drop)).tostring("P")})

$stats | Format-List

pause #endregion
