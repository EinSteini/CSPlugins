#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "GamemodeChanger",
	author = "Jenzmann",
	description = "Change Maps and Gammodes via easy commands",
	version = PLUGIN_VERSION,
	url = "deine.mom.de"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_players", printOnlinePlayers,"cmd");
	RegConsoleCmd("sm_info", printInfo,"cmd");
	RegConsoleCmd("sm_surf", changeToSurf,"cmd");
	
	RegConsoleCmd("sm_invis", invis,"cmd");
	//RegConsoleCmd("sm_test", test);
	
}

public Action changeToSurf(int client, int args)
{
	
	return Plugin_Handled;
}

public Action printOnlinePlayers(int client, int args)
{
	for(int i=1;i<GetClientCount()+1;i++)
	{
		char str[32];
		GetClientIP(i, str, 32, false);
		PrintToChat(i, str);
	}
	return Plugin_Handled;
}
public Action printInfo(int client, int args)
{
	char name[32];
	char ip[32];
	GetClientName(client, name, 32);
	GetClientIP(client, ip, 32);
	
	int deaths = GetClientDeaths(client);
	int frags = GetClientFrags(client);
	
	ReplyToCommand(client, "Player: %s with ip: %s and local id: %d ,you have %d deaths and %d frags!",name,ip,client,deaths,frags);
	
	
	return Plugin_Handled;
}

public Action invis(int client, int args)
{
	int id = GetRandomInt(1, GetClientCount(true));
	
	
	CS_SwitchTeam(id, CS_TEAM_T);
	for(int j=1;j<GetClientCount(true)+1;j++)
	{
		if(j!=id)
		{
			CS_SwitchTeam(j, CS_TEAM_CT);
		}
	}
	
	
	ServerCommand("mp_restartgame 1");
	
	FakeClientCommandEx(id,"ent_fire !self addoutput \"rendermode 10\"");
	
	return Plugin_Handled;
}
/*
public Action test(int client, int args)
{
	ReplyToCommand(client, "Test Function");
	
	return Plugin_Handled;
}
*/
//cl_draw_only_deathnotices 1