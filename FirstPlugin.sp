#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Test Plugin",
	author = "Jenzmann",
	description = "Prints Hello World",
	version = "0.1",
	url = "Your.mom.lol"
};

public void OnPluginStart()
{
	PrintToServer("Hello World!");
	RegConsoleCmd("sm_test", commandTest, "Prints Hello World to Chat!");
}

public Action commandTest(int client, int num)
{
	ReplyToCommand(client, "Hello Worlddsa!");
	return Plugin_Handled;
}

