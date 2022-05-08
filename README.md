# CS:GO Plugins
In this repository there are mostly test plugins for CS:GO / SourceMod, all of them still in developement.
However, some plugins provide some functionality that can be interesting to use.
To use them on your server, move the .smx file into the plugins folder of your SourceMod installation.

## WeirdRules
This plugin adds some funny gamemodes to CS:GO, some of which can be found on [YouTube](https://www.youtube.com/playlist?list=PLs5PuqqXOxboG0OjjHgmY6ieWpa_nm3SJ "EinSteini on YouTube (German)"):
### DontMiss

A mode where every player can only miss a certain amount of bullets. If the threshold is reached, the player will be moved to spectator.
Command: `mode dontmiss x` where x represents the number of shots every player can miss before getting spectator'd.

__Attention:__ This version of DontMiss is deprecated and full of bugs and exploits. Please use the standalone plugin (dontmiss.smx).
### Invis

1v5, but the lone player is invisible. To not make it too hard for the CTs, the invisible will become visible for 3 seconds, if:
1. He kills someone
2. He takes any amount of damage (armor damage is enough)

Command: `mode invis playername` where you type the player who should become invisible instead of playername.   
This command can be seen in action on [YouTube](https://youtu.be/y4z7QDn2DLE "Invis on YT (German)").

## DontMiss (standalone)
A mode where every player can only miss a certain amount of bullets. For every missed bullet the responsible player loses a certain amount of health and a certain amount of points depending on the weapon's chest damage from 500 units.  
The player loses a third of this damage in health and a tenth of this damage in points. If a player reaches 0 points, he instantly dies and will also do so at the start of each round, thus he is rendered useless until the end of the round.

Command `dontmiss x`, where x is the amount of points one player gets in the beginning of the round.
This command can be seen in action on [YouTube](https://youtu.be/TKBtF15Ht8c "DontMiss on YT (German)").