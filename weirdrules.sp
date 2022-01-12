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
int playerInvis;


enum gamemode{
	invis
}

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