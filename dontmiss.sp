#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.00 ALPHA"

public Plugin myinfo = 
{
	name = "DontMiss",
	author = "EinSteini",
	description = "well,  ... just dont miss",
	version = PLUGIN_VERSION,
	url = "www.youtube.com/u/EinSteini"
};

char notweapon[27][32] = {
	"weapon_knife",
	"weapon_knife_t",
	"weapon_bayonet",
	"weapon_knife_survival_bowie",
	"weapon_knife_butterfly",
	"weapon_knife_css",
	"weapon_knife_falchion",
	"weapon_knife_flip",
	"weapon_knife_gut",
	"weapon_knife_tactical",
	"weapon_knife_karambit",
	"weapon_knife_m9_bayonet",
	"weapon_knife_gypsy_jackknife",
	"weapon_knife_outdoor",
	"weapon_knife_cord",
	"weapon_knife_push",
	"weapon_knife_skeleton",
	"weapon_knife_stiletto",
	"weapon_knife_canis",
	"weapon_knife_widowmaker",
	"weapon_knife_ursus",
	"weapon_hegrenade",
	"weapon_smokegrenade",
	"weapon_flashbang",
	"weapon_decoy",
	"weapon_molotov",
	"weapon_incgrenade"
};

char weapon_ids[33][32] = {
	"weapon_ak47",
	"weapon_aug",
	"weapon_awp",
	"weapon_bizon",
	"weapon_cz75a",
	"weapon_deagle",
	"weapon_elite",
	"weapon_famas",
	"weapon_fiveseven",
	"weapon_g3sg1",
	"weapon_galilar",
	"weapon_glock",
	"weapon_hkp2000",
	"weapon_m249",
	"weapon_m4a1",
	"weapon_m4a1_silencer",
	"weapon_mac10",
	"weapon_mag7",
	"weapon_mp5sd",
	"weapon_mp7",
	"weapon_mp9",
	"weapon_negev",
	"weapon_nova",
	"weapon_p250",
	"weapon_p90",
	"weapon_sawedoff",
	"weapon_scar20",
	"weapon_sg556",
	"weapon_ssg08",
	"weapon_tec9",
	"weapon_ump45",
	"weapon_usp_silencer",
	"weapon_xm1014"
};

int damageChart[33][2] = {
	{11,3},
	{9,2},
	{37,11},
	{7,2},
	{8,2},
	{15,4},
	{10,3},
	{9,2},
	{8,2},
	{26,7},
	{9,2},
	{8,2},
	{10,3},
	{10,3},
	{10,3},
	{12,3},
	{7,2},
	{36,10},
	{7,2},
	{8,2},
	{7,2},
	{11,3},
	{54,16},
	{11,3},
	{7,2},
	{38,11},
	{26,7},
	{9,2},
	{28,8},
	{8,2},
	{8,2},
	{10,3},
	{28,8}
};

int shotsRemaining[MAXPLAYERS + 1];
bool bufferPlayers[MAXPLAYERS + 1];

bool firstTime = true;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// No need for the old GetGameFolderName setup.
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_CSGO)
	{
		SetFailState("This plugin was made for use with Counter-Strike: Global Offensive only.");
	}
} 

public void OnPluginStart()
{
	CreateConVar("sm_dontmiss_version", PLUGIN_VERSION, "Standard plugin version ConVar. Please don't change me!", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	RegAdminCmd("sm_dontmiss", DontMiss, ADMFLAG_GENERIC);
	RegAdminCmd("dontmiss", DontMiss, ADMFLAG_GENERIC);
	
	for(int i = 0; i < sizeof(bufferPlayers); i++)
	{
		bufferPlayers[i] = false;
	}
}

public Action DontMiss(int client, int args)
{
	if (!firstTime) { reset(); } else { firstTime = false; }
	
	
	char maxshots[8];
	GetCmdArg(1, maxshots, sizeof(maxshots));
	
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

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	PrintToChatAll("Verbleibende Misses: ");
	for(int i = 1; i < sizeof(shotsRemaining) - 1; i++)
	{
		if (IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i))
		{
			char cname[33];
			GetClientName(i, cname, sizeof(cname));
			
			PrintToChatAll("%s: %d", cname, shotsRemaining[i]);
			
			if(shotsRemaining[i] < 1)
			{
				KillPlayer(i);
			}
		}
	}
}

public void OnWeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	char weapon[32];
	event.GetString("weapon", weapon, sizeof(weapon));
	
	if(IsWeapon(weapon)){
		int client = GetClientOfUserId(event.GetInt("userid"));
		int w_id = GetWeaponID(weapon);
		int payload = client * 100 + w_id;
		CreateTimer(0.05, checkHit, payload);
	}
}

public void OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	char weapon[32];
	event.GetString("weapon", weapon, sizeof(weapon));
	
	if(IsWeapon(weapon))
	{
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		bufferPlayers[attacker] = true;
	}
}

public Action checkHit(Handle timer, int p)
{	
	int weapon_id = p % 100;
	int client = (p - weapon_id)/100;
	
	if(bufferPlayers[client])
	{
		bufferPlayers[client] = false;
		return Plugin_Continue;
	}
	
	if(weapon_id == -1)
	{
		PrintToServer("Unknown weapon in hitHandling");
		return Plugin_Continue;
	}
	
	//int weapon_stats[2] = damageChart[weapon_id];

	int newHealth = GetClientHealth(client) - damageChart[weapon_id][0];
	if(newHealth > 0)
	{
		SetEntityHealth(client, newHealth);
	}
	else
	{
		KillPlayer(client);
	}
	
	if(shotsRemaining[client] > damageChart[weapon_id][1])
	{
		shotsRemaining[client] -= damageChart[weapon_id][1];
		if(shotsRemaining[client] < 15)
		{
			PrintHintText(client, "Achtung! Du hast nur noch %d Schüsse!", shotsRemaining[client]);
		}
	}
	else
	{
		shotsRemaining[client] = 0;
		KillPlayer(client);
	}
	
	return Plugin_Continue;
}

public void reset()
{
	UnhookEvent("round_start", OnRoundStart);
	UnhookEvent("weapon_fire", OnWeaponFire);
	UnhookEvent("player_hurt", OnPlayerHurt);
}

public bool IsWeapon(char[] weapon)
{
	for(int i = 0; i < sizeof(notweapon); i++)
	{
		if (StrEqual(notweapon[i], weapon)) { return false; }
	}
	return true;
}

public int GetWeaponID(char[] weapon)
{
	for(int i = 0; i < sizeof(weapon_ids); i++)
	{
		if(StrEqual(weapon, weapon_ids[i]))
		{
			return i;
		}
	}
	return -1;
}

public void KillPlayer(int client)
{
	char name[33];
	GetClientName(client, name, sizeof(name));
	ServerCommand("sm_slay %s", name);
}