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

int target_id;
char target_name[32];
ArrayList else_ids;
bool invisible;

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
	
	else_ids = new ArrayList(1,0);
	
	RegAdminCmd("sm_start", Command_Start, Admin_Generic, "Starts the WeirdRules Plugin (Usage: start <gamemode>)");
	//RegConsoleCmd("sm_playerinfo", Command_Info);
	
}

public void OnClientPutInServer(int client)
{
	GetClientName(client, ga_cNames[client], 32); //write client name according to his id into array
	
	if(StrEqual(ga_cNames[client], target_name)){
		target_id = getIdByName(ga_cNames[client]);
		//ServerCommand("say Da der Unsichtbare wieder das Spiel betreten hat, wird das Spiel nun fortgesetzt");
		ServerCommand("mp_unpause_match");
	}
}

public void OnClientDisconnect(int client){
	ga_cNames[client] = "";
	int index = else_ids.FindValue(client);
	if(index != -1){
		else_ids.Erase(index);
	}
	if(target_id == client){
		//ServerCommand("say Da der Unsichtbare den Server verlassen hat, wird das Match pausiert.");
		ServerCommand("mp_pause_match");
	}
	
}

public Action Command_Start(int client, int args)
{
	char time[512];
	FormatTime(time, sizeof(time), "%I:%M:%S %p");
	ServerCommand("tv_record dem_%s", time);
	ServerCommand("mp_warmup_end");
	
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
	
	
	
	
	return Plugin_Handled;
}

public Action GameInvis(int client, int args)
{
	//ServerCommand("sv_cheats 1");
	for (int i = 1; i < sizeof(ga_cNames) - 1; i++) {
		if(IsClientConnected(i)){
			FakeClientCommandEx(i, "ent_fire !self addoutput \"rendermode 1\"");
		}
	}
		
	static char invis_body[64] = "ent_fire !self addoutput \"rendermode 10\"";
	
	char name[32];
	GetCmdArg(2, name, sizeof(name));

	for (int i = 0; i < sizeof(ga_cNames); i++)
	{
		if(StrEqual(ga_cNames[i], name))
		{
			target_id = i;
			target_name = ga_cNames[i];
			break;
		}
		else_ids.Push(i);
	}
	
	ReplyToCommand(client, "Making %s with id %d invisible", name, target_id);
	
	CS_SwitchTeam(target_id, CS_TEAM_T);

	CS_SetClientClanTag(target_id, "INVISIBLE");

	
	for (int i = 1; i < sizeof(ga_cNames)-1; i++)
	{
		if(IsClientInGame(i) && target_id != i)
		{
			CS_SwitchTeam(i, CS_TEAM_CT);
		}
	}
	
	SDKHook(target_id, SDKHook_OnTakeDamage, OnTakeDamage);
	HookEvent("player_death", OnPlayerDeath);
	//HookEvent("player_shoot", OnPlayerShoot);
	
	ServerCommand("mp_restartgame 1");
	
	FakeClientCommandEx(target_id, invis_body);
	
	//ServerCommand("sv_cheats 0");
	
	CS_SetClientClanTag(target_id, "INVISIBLE");
	
	return Plugin_Handled;
}

public void OnTakeDamage(int victim){
	MakeVisible(victim, 3);
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast){
	int attacker_id = GetClientOfUserId(event.GetInt("attacker"));
	if(attacker_id == target_id){
		MakeVisible(target_id, 3);
	}
}

public void OnPlayerShoot(Event event, const char[] name, bool dontBroadcast){
	int attacker_id = GetClientOfUserId(event.GetInt("userid"));
	if(attacker_id == target_id){
		MakeVisible(target_id, 1);
	}
}

public void MakeVisible(int client, int time){
	
	//CreateTimer(time, MakeInvisible, client, TIMER_DATA_HNDL_CLOSE);
	//if(invisible){
		//CloseHandle(timer);
		//timer = CreateTimer(time, MakeInvisible, client);
	//}else{
		//invisible = true;
	//ServerCommand("sv_cheats 1");
	PrintHintTextToAll("Der Unsichtbare ist nun sichtbar!");
	PrintHintText(client, "Du bist jetzt sichtbar!");
	FakeClientCommandEx(client, "ent_fire !self addoutput \"rendermode 1\"");
	FakeClientCommandEx(target_id, "ent_fire !self addoutput \"rendermode 10\" %d", time);
	//ServerCommand("sv_cheats 0");
	//}
	
	
	
}

public void MakeInvisible(Handle timer, int client){
	FakeClientCommandEx(target_id, "ent_fire !self addoutput \"rendermode 10\"");
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