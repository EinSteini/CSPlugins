#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "Gamemodes",
	author = "Jenzmann",
	description = "Change between Gamemodes easy!",
	version = PLUGIN_VERSION,
	url = "your.mom.de"
};

bool isSurf = false;


public void OnPluginStart()
{
	RegConsoleCmd("sm_jnormal", normal, "cmd");
	RegConsoleCmd("sm_jArmsrace", armsrace, "cmd");
	RegConsoleCmd("sm_jWingman", wingman, "cmd");
	RegConsoleCmd("sm_jSurf", surf, "cmd");
}

public Action normal(int client, int args)
{
	if(args != 3)
	{
		ReplyToCommand(client, "Usage: map <Mapname> + gametype + gamemode 	(casual 0 0, comp 0 1, arms race 1 0, demolition 1 1, deathmatch 1 2, Training 2 0, Custom 3 0)");
		return Plugin_Handled;
	}
	if(isSurf)
	{
		changeParamsToNormal();
		isSurf = false;
	}
	char mapName[32];
	GetCmdArg(1,mapName, 32);
	
	char gametype[32];
	GetCmdArg(2, gametype, 32);
	
	char gamemode[32];
	GetCmdArg(3, gamemode, 32);
	
	ServerCommand("map %s %s %s",mapName,gametype,gamemode);
	
	return Plugin_Handled;
}
public Action armsrace(int client, int args)
{
	return Plugin_Handled;
}
public Action wingman(int client, int args)
{
	return Plugin_Handled;
}
public Action surf(int client, int args)
{
	if(!isSurf)
	{
		changeParamsToSurf();
		isSurf = true;
	}
	return Plugin_Handled;
}

public void changeParamsToSurf()
{
	ServerCommand("sv_cheats 1");
	ServerCommand("sv_falldamage_scale 0");
	ServerCommand("sv_party_mode 1");
	ServerCommand("mp_freezetime 2.5");
	ServerCommand("sv_accelerate 10");
	ServerCommand("sv_airaccelerate 3000");
	ServerCommand("sv_gravity 800.0");
	ServerCommand("sv_enablebunnyhopping 1");
	ServerCommand("sv_autobunnyhopping 1");
	ServerCommand("mp_respawn_on_death_ct 1");
	ServerCommand("mp_respawn_on_death_t 1");
	ServerCommand("mp_roundtime 99999");
	ServerCommand("mp_startmoney 99999");
	ServerCommand("mp_buytime 99999");
	ServerCommand("sv_cheats 0");
}
public void changeParamsToNormal()
{
	ServerCommand("sv_cheats 1");
	ServerCommand("sv_falldamage_scale 1");
	ServerCommand("sv_party_mode 0");
	ServerCommand("mp_freezetime 15");
	ServerCommand("sv_accelerate 5.5");
	ServerCommand("sv_airaccelerate 12");
	ServerCommand("sv_gravity 800.0");
	ServerCommand("sv_enablebunnyhopping 0");
	ServerCommand("sv_autobunnyhopping 0");
	ServerCommand("mp_respawn_on_death_ct 0");
	ServerCommand("mp_respawn_on_death_t 0");
	ServerCommand("mp_roundtime 1.92");
	ServerCommand("mp_startmoney 800");
	ServerCommand("mp_buytime 20");
	ServerCommand("sv_cheats 0");
}

public void OnMapStart()
{
	/**
	 * @note Precache your models, sounds, etc. here!
	 * Not in OnConfigsExecuted! Doing so leads to issues.
	 */
}
