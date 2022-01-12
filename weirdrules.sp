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


enum Gamemode{
	standard,
	invis
}

char ga_cGamemodes[1][2][64] =  { 
	{ "Invis", "1v5, where the solo player is invisible" } 
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

public void OnClientConnected(int client)
{
	clientsIngame[client] = true;
}

public void OnClientDisconnect(int client)
{
	clientsIngame[client] = false;
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
	Gamemode mode;
	ResetValues(); 
	
	char game[16];
	GetCmdArg(1, game, sizeof(game));
	
	if(StrEqual(game, "invis"))
	{
		GameInvis(client, args);
	}
	else
	{
		ReplyToCommand(client, "\n%s is an invalid or not yet implemented game.", game);
		ReplyToCommand(client, "The currently implemented Games are:\n");
		for (int i = 1; i < sizeof(ga_cGamemodes); i++)
		{
			ReplyToCommand(client, "\x01%s", ga_cGamemodes[i][0]);
			ReplyToCommand(client, "%s\n", ga_cGamemodes[i][1]);
		}
		
	}
	return Plugin_Handled;
}

public Action GameInvis(int client, int args)
{
	char invisName[33];
	GetCmdArg(2, invisName, sizeof(invisName));
	
	int invisId = GetClientID(invisName);
	
	if(clientsIngame[invisId]){
		playerInvis = invisId;
	}else{
		ReplyToCommand(client, "Invalid Player Name");
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "Making %s (ID: %d) invisible", invisName, invisId);
	
	ServerCommand("sv_cheats 1");
	
}

public void ResetValues(){
	playerInvis = -1;
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