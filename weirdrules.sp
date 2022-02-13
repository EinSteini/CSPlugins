#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "EinSteini"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

#pragma newdecls required

EngineVersion g_Game;

bool clientsIngame[MAXPLAYERS + 1];

//Globals Invis
int playerInvis = -1;
Handle visTimer;
int sec = 3;

//Globals DontMiss
int shotsRemaining[MAXPLAYERS + 1];
bool firstexec = true;

enum Gamemode{
	standard,
	invis,
	dontmiss
}
Gamemode pluginMode = standard;

char ga_cGamemodes[2][2][128] =  { 
	{ "Invis", "1v5, where the solo player is invisible. \nUsage: (sm_)mode invis Playername" },
	{"DontMiss", "Don't miss more than x shots... or you're out! \nUsage: (sm_)mode dontmiss x"}	
};

public Plugin myinfo = 
{
	name = "WeirdRules",
	author = PLUGIN_AUTHOR,
	description = "A plugin with new, weird gamemodes",
	version = PLUGIN_VERSION,
	url = ""
};


public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO)
	{
		SetFailState("This plugin is for CS:GO only.");	
	}
	
	RegAdminCmd("sm_playerinfo", PlayerInfo, ADMFLAG_GENERIC);
	RegAdminCmd("playerinfo", PlayerInfo, ADMFLAG_GENERIC);
	
	RegAdminCmd("sm_mode", GameMode, ADMFLAG_GENERIC);
	RegAdminCmd("mode", GameMode, ADMFLAG_GENERIC);
}

public void OnClientPostAdminCheck(int client)
{
	clientsIngame[client] = true;
}

public void OnClientDisconnect(int client)
{
	clientsIngame[client] = false;
}

public void OnTakeDamage(int client){
	if(pluginMode == invis){
		TimedVisible(client);
	}
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast){
	if(pluginMode == invis){
		int attacker_id = GetClientOfUserId(event.GetInt("attacker"));
		if(attacker_id == playerInvis){
			TimedVisible(playerInvis);
		}
	}
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(pluginMode == dontmiss)
	{
		PrintToChatAll("Verbleibende Misses: ");
		for (int i = 0; i < sizeof(shotsRemaining); i++)
		{
			if(clientsIngame[i] && !IsClientSourceTV(i) && !IsClientReplay(i))
			{
				char cname[33]; 
				GetClientName(i, cname, sizeof(cname));
				
				PrintToChatAll("%s: %d", cname, shotsRemaining[i]);
			}
		}
	}
}

public void OnWeaponFire(Event event, const char[] name, bool dontBroadcast){
	if(pluginMode == dontmiss)
	{
		char weapon[32]; 
		event.GetString("weapon", weapon, sizeof(weapon));
		
		if(DM_IsWeapon(weapon))
		{
			int attacker = GetClientOfUserId(event.GetInt("userid"));
			shotsRemaining[attacker]--;
			CreateTimer(0.1, DM_KickPlayer, attacker);
		}
	}
}

public Action DM_KickPlayer(Handle timer, int client)
{
	if(shotsRemaining[client] < 1)
	{
		ChangeClientTeam(client, CS_TEAM_SPECTATOR);
	}
	else if(shotsRemaining[client] < 10)
	{
		PrintHintText(client, "Achtung! Du hast nur noch %d Schüsse!", shotsRemaining[client]);
	}
}

public void OnPlayerHurt(Event event, const char[] name, bool dontBroadcast){
	if(pluginMode == dontmiss)
	{
		char weapon[32];
		event.GetString("weapon", weapon, sizeof(weapon));
		
		if(DM_IsWeapon(weapon))
		{
			int attacker = GetClientOfUserId(event.GetInt("attacker"));
			shotsRemaining[attacker]++;	
		}
	}
}

public Action PlayerInfo(int client, int args)
{	
	ReplyToCommand(client, "\nPLAYER INFO\n");
	ReplyToCommand(client, "Name ID IP");
	
	for (int i = 1; i < sizeof(clientsIngame)-1; i++)
	{
		if(IsClientInGame(i))
		{
			char name[33];
			char ip[16];
			
			GetClientName(i, name, sizeof(name));
			GetClientIP(i, ip, sizeof(ip));
			
			ReplyToCommand(client, "%s %d %s", name, i, ip);
		}
	}

	
}

public Action GameMode(int client, int args)
{
	ResetValues(); 
	
	ServerCommand("mp_warmup_end");
	
	char game[16];
	GetCmdArg(1, game, sizeof(game));
	
	if(StrEqual(game, "invis"))
	{
		GameInvis(client, args);
	}
	else if(StrEqual(game, "dontmiss"))
	{
		GameDontMiss(client, args);
	}
	else
	{
		ReplyToCommand(client, "\n%s is an invalid or not yet implemented game.", game);
		ReplyToCommand(client, "The currently implemented games are:\n");
		for (int i = 0; i < sizeof(ga_cGamemodes); i++)
		{
			ReplyToCommand(client, "\x01%s", ga_cGamemodes[i][0]);
			ReplyToCommand(client, "%s\n", ga_cGamemodes[i][1]);
		}
		
	}
	return Plugin_Handled;
}

public Action GameInvis(int client, int args)
{
	pluginMode = invis;
	
	char invisName[33];
	GetCmdArg(2, invisName, sizeof(invisName));
	
	int invisId = GetClientID(invisName);
	
	if(clientsIngame[invisId])
	{
		playerInvis = invisId;
	}
	else
	{
		ReplyToCommand(client, "Invalid Player Name");
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "Making %s (ID: %d) invisible", invisName, invisId);
	
	MakePlayerInvisible(playerInvis); 
	
	for (int i = 1; i < sizeof(clientsIngame); i++)
	{
		if(clientsIngame[i] && !(IsClientSourceTV(i) || IsClientReplay(i)))
		{
			CS_SwitchTeam(i, CS_TEAM_CT);
		}
	}
	
	CS_SwitchTeam(playerInvis, CS_TEAM_T);
	
	SDKHook(playerInvis, SDKHook_OnTakeDamage, OnTakeDamage);
	HookEvent("player_death", OnPlayerDeath);
	
	CS_SetClientClanTag(playerInvis, "INVISIBLE");
	
	ServerCommand("mp_restartgame 1");
	ServerCommand("mp_damage_vampiric_amount 1");
	
	CS_SetClientClanTag(playerInvis, "INVISIBLE");
	
	
	return Plugin_Handled;
}

public Action GameDontMiss(int client, int args)
{
	pluginMode = dontmiss;
	
	firstexec = false;
	
	char maxshots[8];
	GetCmdArg(2, maxshots, sizeof(maxshots));
	
	int i_maxshots = StringToInt(maxshots);
	
	for (int i = 0; i < sizeof(shotsRemaining); i++)
	{
		shotsRemaining[i] = i_maxshots;
	}
	
	HookEvent("round_start", OnRoundStart);
	HookEvent("weapon_fire", OnWeaponFire);
	HookEvent("player_hurt", OnPlayerHurt);
	
	ServerCommand("mp_restartgame 1");
	
	return Plugin_Handled;
}

public void ResetValues(){

	if(!firstexec)
	{
		UnhookEvent("round_start", OnRoundStart);
		UnhookEvent("weapon_fire", OnWeaponFire);
		UnhookEvent("player_hurt", OnPlayerHurt);
	}
	
	
	playerInvis = -1;
	pluginMode = standard;
	sec = 3;
	
	for (int i = 1; i < sizeof(clientsIngame) - 1; i++) {
		if(clientsIngame[i]){
			FakeClientCommandEx(i, "ent_fire !self addoutput \"rendermode 1\"");
		}
	}
	
	if(visTimer != null)
	{
		delete visTimer;
	}
}

public int GetClientID(char name[33])
{
	for (int i = 1; i < sizeof(clientsIngame); i++) 
	{
		if(clientsIngame[i])
		{
			char cname[33];
			GetClientName(i, cname, sizeof(cname));
			
			if(StrEqual(name, cname))
			{
				return i;
			}
		}
	} 
	return -1;
}

public void TimedVisible(int player_id){
	sec = 3;
	
	if(visTimer != null)
	{
		delete visTimer;
		visTimer = null;
	}
	
	MakePlayerVisible(player_id);
	visTimer = CreateTimer(1.0, Timer_Visible, _, TIMER_REPEAT);
	
	for (int i = 1; i < sizeof(clientsIngame); i++)
    {
	    if(clientsIngame[i])
	    {
	    	PrintHintText(i, "Der Unsichtbare ist nun sichtbar für: %d Sekunden", sec);
	    }
   	}
   	PrintHintText(playerInvis, "Du bist nun nun sichtbar für: %d Sekunden", sec);
}

public Action Timer_Visible(Handle timer)
{
	sec--;
	
    if (sec <= 0) 
    {
    	MakePlayerInvisible(playerInvis);
    	
    	for (int i = 1; i < sizeof(clientsIngame); i++)
    	{
    		if(clientsIngame[i])
    		{
    			PrintHintText(i, "Der Unsichtbare ist nun wieder unsichtbar");
    		}
   		}
   		
   		PrintHintText(playerInvis, "Du bist nun wieder unsichtbar!");
    	
		sec = 3;
        visTimer = null;
        
        return Plugin_Stop;
    }
 
    for (int i = 1; i < sizeof(clientsIngame); i++)
    {
	    if(clientsIngame[i])
	    {
	    	PrintHintText(i, "Der Unsichtbare ist nun sichtbar für: %d Sekunden", sec);
	    }
   	}
   	PrintHintText(playerInvis, "Du bist nun nun sichtbar für: %d Sekunden", sec);
 
	return Plugin_Continue;
}

public void MakePlayerInvisible(int player_id)
{	
	FakeClientCommandEx(player_id, "ent_fire !self addoutput \"rendermode 10\"");
}
public void MakePlayerVisible(int player_id)
{
	FakeClientCommandEx(player_id, "ent_fire !self addoutput \"rendermode 1\"");
}

public bool DM_IsWeapon(char[] weapon)
{
	if(StrEqual(weapon, "weapon_knife") || StrEqual(weapon, "weapon_knife_t") || StrEqual(weapon, "weapon_hegrenade") || StrEqual(weapon, "weapon_smokegrenade") || StrEqual(weapon, "weapon_flashbang") || StrEqual(weapon, "weapon_decoy") || StrEqual(weapon, "weapon_molotov") || StrEqual(weapon, "weapon_incgrenade"))
	{
		return false;
	}
	return true;
}