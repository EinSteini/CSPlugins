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

char ga_cNames[MAXPLAYERS + 1][32];

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
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	
	RegAdminCmd("sm_start", Command_Start, Admin_Generic, "Starts the WeirdRules Plugin (Usage: start <gamemode>)");
	RegConsoleCmd("sm_playerinfo", Command_Info);
}

public void OnClientPutInServer(int client)
{
	GetClientName(client, ga_cNames[client], 32); //write client name according to his id into array
}

public Action Command_Start(int client, int args)
{
	char game[32];
	GetCmdArg(1, game, sizeof(game));
	
	if(StrEqual(game, "invis"))
	{
		GameInvis(client, args);
	}
	else
	{
		ReplyToCommand(client, "Invalid argument");
		return Plugin_Handled;
	}	
}

public Action GameInvis(int client, int args)
{
	static char invis_body[64] = "ent_fire !self addoutput \"rendermode 10\"";
	
	char name[32];
	GetCmdArg(2, name, sizeof(name));
	
	int target_id;
	
	for (int i = 0; i < sizeof(ga_cNames); i++)
	{
		if(StrEqual(ga_cNames[i], name))
		{
			target_id = i;
			break;
		}
	}
	
	ReplyToCommand(client, "Making %s with id %d invisible", name, target_id);
	
	CS_SwitchTeam(target_id, CS_TEAM_T);
	
	CS_SetClientClanTag(target_id, "Invisible Man");
	
	for (int i = 1; i < sizeof(ga_cNames)-1; i++)
	{
		if(IsClientInGame(i) && target_id != i)
		{
			CS_SwitchTeam(i, CS_TEAM_CT);
		}
	}
	
	SDKHook(target_id, SDKHook_OnTakeDamage, OnTakeDamage);
	HookEvent("player_death", OnPlayerDeath);
	
	ServerCommand("mp_restartgame 1");
	
	FakeClientCommandEx(target_id, invis_body);
	
	return Plugin_Handled;
}

public void OnTakeDamage(int victim){
	MakeVisible(victim, 3);
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast){
	ServerCommand("say %d", GetClientOfUserId(event.GetInt("userid")));
	//MakeVisible(GetClientOfUserId(event.GetInt("userid")), 3);
}

public void MakeVisible(int client, int time){
	PrintHintText(client, "Du bist jetzt sichtbar!");
	FakeClientCommandEx(client, "ent_fire !self addoutput \"rendermode 1\"");
	FakeClientCommandEx(client, "ent_fire !self addoutput \"rendermode 10\" %d", time);
}

public int getIdByName(char[] name){
	for (int i = 0; i < sizeof(ga_cNames); i++)
	{
		if(StrEqual(ga_cNames[i], name))
		{
			return i;
		}
	}
	return -1;
}

public Action Command_Info(int client, int args){
	ServerCommand("say 'Hello World'");
	ReplyToCommand(client, "Hello %s, your ID is %d.", ga_cNames[client], client);
	
	return Plugin_Handled;
}