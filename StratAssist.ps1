<#
StratAssist V1.11

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

Param([switch]$adv)

#region Read log files
$curdir = Split-Path -parent $PSCommandPath
$logdir = "$env:appdata\..\LocalLow\League of Geeks\Armello\logs\*M.txt"
If ($adv -eq $true){
    $raw = Get-ChildItem $logdir -Exclude '*armello_log*' | %{Write-Host Examining file: $_.name; $_} | Select-String -CaseSensitive -Context 0,13 'Begin Match','Setup Game','MapMaking: None:','Creature Equipping Signet','MapMaking: MapController','Start Game','End Game'
    $offset = 9}
Else{
    $raw = Get-ChildItem $logdir -Exclude '*armello_log*' | %{Write-Host Examining file: $_.name; $_} | Select-String -CaseSensitive -Context 0,3 'Begin Match','End Game'
    $offset = 1} #endregion

$total = 0
$drop = 0
$fix = ForEach ($i in 0..($raw.count-1)){
    If ($raw[$i].line -match 'Begin Match'){
        If ($raw[$i+$offset].line -match 'End Game'){
            $raw[$i..($i+$offset)]}
        Else{
            $drop++}
        $total++}} #Disregard unfinished games; Count total games played and number of disconnects

Function Id-ToPlaintext($input){
    $input | %{$_ `
        -replace 'Bandit01',"Twiss" `
        -replace 'Bandit02',"Sylas" `
        -replace 'Bandit03',"Horace" `
        -replace 'Bandit04',"Scarlet" `
        -replace 'Bear01',"Sana" `
        -replace 'Bear02',"Brun" `
        -replace 'Bear03',"Ghor" `
        -replace 'Bear04',"Yordana" `
        -replace 'Rabbit01',"Amber" `
        -replace 'Rabbit02',"Barnaby" `
        -replace 'Rabbit03',"Elyssia" `
        -replace 'Rabbit04',"Hargrave" `
        -replace 'Rat01',"Mercurio" `
        -replace 'Rat02',"Zosha" `
        -replace 'Rat03',"Sargon" `
        -replace 'Rat04',"Griotte" `
        -replace 'Wolf01',"Thane" `
        -replace 'Wolf02',"River" `
        -replace 'Wolf03',"Magna" `
        -replace 'Wolf04',"Fang" `
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
        -replace 'AMU15',"Harmonise" `
        -replace 'AMU16',"Decay" `
        -replace 'BanishKing',"Spirit Stone" `
        -replace 'DefeatKing',"King Slayer"}} #Replace variables with plaintext names

$fin = @()
ForEach($i in 0..($total-$drop-1)){
$tmp = [ordered]@{"Game" = $i+1}
$b = 1
    ForEach($j in $fix[($i*($offset+1))..($i*($offset+1)+$offset)]){
        If ($j.line -match 'Begin Match'){
            $tmp += [ordered]@{
                "Mode" = [regex]::matches($j.context.postcontext[0],'(?<=Mode: ).*') | %{$_.value}
                "Date" = [regex]::matches($j.filename,'\d{4}-\d{2}-\d{2}') | %{$_.value}
                "StartTime" = [regex]::matches($j.line ,'\d{1,2}:\d{2}:\d{2}') | %{$_.value}}}
        If ($j.line -match 'Setup Game'){
            $tmp += [ordered]@{
                "Seed" = [regex]::matches($j.context.postcontext[0],'(?<=Seed: ).*') | %{$_.value}}}
        If ($j.line -match 'MapMaking: None:'){
            $tmp += [ordered]@{
                "Plains" = [regex]::matches($j.context.postcontext[0],'(?<=MapMaking: Plains: )\d.*') | %{$_.value}
                "Swamps" = [regex]::matches($j.context.postcontext[1],'(?<=MapMaking: Swamp: )\d.*') | %{$_.value}
                "Forests" = [regex]::matches($j.context.postcontext[2],'(?<=MapMaking: Forest: )\d.*') | %{$_.value}
                "Mountains" = [regex]::matches($j.context.postcontext[3],'(?<=MapMaking: Mountains: )\d.*') | %{$_.value}
                "StoneCircles" = [regex]::matches($j.context.postcontext[4],'(?<=MapMaking: StoneCircle: )\d.*') | %{$_.value}
                "Settlements" = [regex]::matches($j.context.postcontext[5],'(?<=MapMaking: Settlement: )\d.*') | %{$_.value}
                "Dungeons" = [regex]::matches($j.context.postcontext[6],'(?<=MapMaking: Dungeon: )\d.*') | %{$_.value}}}
        If ($j.line -match 'MapMaking: MapController'){
            ForEach($a in 1..4){
                $tmp += [ordered]@{
                    "Player$a" = [regex]::matches($j.context.postcontext[$a*3-1],'(?<=Player: Init Player ).*') | %{$_.value}
                    "Hero$a" = [regex]::matches($j.context.postcontext[$a*3-3],'(?<=for ).*\d{2}') | %{$_.value} | Id-ToPlaintext}}}
        If ($j.line -match 'Start Game'){
            $tmp += [ordered]@{
                "GameId" = [regex]::matches($j.context.postcontext,'(?<=GameId: ).*?(?= )') | %{$_.value}}}
        If ($j.line -match 'End Game'){
            $tmp += [ordered]@{
                "Winner" = [regex]::matches($j.context.postcontext[1],'(?<=Winner: \[Player ).*(?= \(Player.\))') | %{$_.value}
                "WinCondition" = [regex]::matches($j.context.postcontext[2],'(?<=GameVictoryType: ).*') | %{$_.value} | Id-ToPlaintext
                "Username" = [regex]::matches($j.filename,'^.*(?=_log)') | %{$_.value}
                "EndTime" = [regex]::matches($j.line ,'\d{1,2}:\d{2}:\d{2}') | %{$_.value}}}
        If ($j.line -match 'Creature Equipping Signet'){
            $tmp += [ordered]@{
                "Signet$b" = [regex]::matches($j.line,'(?<=Signet: ).*') | %{$_.value} | Id-ToPlaintext
                "Amulet$b" = [regex]::matches($j.context.postcontext,'(?<=Amulet: ).*?(?= )') | %{$_.value} | Id-ToPlaintext}
            $b++}}
$fin += @(New-Object PSObject -Property $tmp)} #Parse game statistics

If ($adv -eq $true){
    $stamp = [int][double]::parse((Get-Date -UFormat %s))
    $fin | Select-Object Game,Date,StartTime,EndTime,Username,Mode,GameId,Seed,Plains,Swamps,Forests,Mountains,StoneCircles,Settlements,Dungeons,Player1,Hero1,Signet1,Amulet1,Player2,Hero2,Signet2,Amulet2,Player3,Hero3,Signet3,Amulet3,Player4,Hero4,Signet4,Amulet4,Winner,WinCondition | Export-Csv -NoTypeInformation "$curdir\$($fin.Username[0])-$stamp.csv"
    Write-Host "`n`nResults Saved To $curdir\$($fin.Username[0])-$stamp.csv"} #Create a CSV file

#region Calculate and display game statistics
Write-Host "`n`nGame Statistics"
$userwon = (0..($fin.count-1) | Where {$fin.Winner[$_] -eq $fin.Username[$_]}).count
$serverwon = (0..($fin.count-1) | Where {$fin.Winner[$_] -ne $fin.Username[$_]}).count
$stats = New-Object -TypeName PSObject -Property ([ordered]@{
    'Played' = $total
    'Won' = $userwon
    'Lost' = $serverwon
    'Dropped' = $drop
    'Win Rate' =($userwon/($total-$drop)).tostring("P")})
$stats | Format-List
pause #endregion
