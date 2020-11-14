#pragma semicolon 1
#pragma newdecls required
#include <sdktools>
#include <dhooks>

// Uses Flashbang Tools gamedata
// https://forums.alliedmods.net/showthread.php?t=159876

DynamicDetour hFlashbangDetonateDetour;
DynamicDetour hFlashbangDeafen;
//DynamicDetour hPercentageOfFlashForPlayer;

public void OnPluginStart()
{
	GameData temp = new GameData("fbtools.games");
	
	if(temp == INVALID_HANDLE)
	{
		SetFailState("Why you no has gamedata?");
	}
	
	hFlashbangDetonateDetour = new DynamicDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	if (!hFlashbangDetonateDetour)
		SetFailState("Failed to setup detour for Detonate");
	
	if (!hFlashbangDetonateDetour.SetFromConf(temp, SDKConf_Signature, "CFlashbangProjectile::Detonate"))
		SetFailState("Failed to load Detonate signature from gamedata");
	
	if (!hFlashbangDetonateDetour.Enable(Hook_Pre, Detour_OnFlashbangDetonate))
		SetFailState("Failed to detour Detonate.");
		
	if (!hFlashbangDetonateDetour.Enable(Hook_Post, Detour_OnFlashbangDetonate_Post))
		SetFailState("Failed to detour Detonate post.");
	
	PrintToServer("CFlashbangProjectile::Detonate detoured!");
	

	hFlashbangDeafen = DynamicDetour.FromConf(temp, "Deafen");
	if (!hFlashbangDeafen)
		SetFailState("Failed to setup detour for Deafen");
	/*hFlashbangDeafen = new DynamicDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	if (!hFlashbangDeafen)
		SetFailState("Failed to setup detour for Deafen");
	
	if (!hFlashbangDeafen.SetFromConf(temp, SDKConf_Signature, "Deafen"))
		SetFailState("Failed to load Deafen signature from gamedata");
	
	hFlashbangDeafen.AddParam(HookParamType_Float, .custom_register=DHookRegister_XMM1);*/
	
	if (!hFlashbangDeafen.Enable(Hook_Pre, Detour_OnDeafen))
		SetFailState("Failed to detour Deafen.");
		
	if (!hFlashbangDeafen.Enable(Hook_Post, Detour_OnDeafen_Post))
		SetFailState("Failed to detour Deafen post.");
	
	PrintToServer("CCSPlayer::Deafen detoured!");
	
	
	/*hPercentageOfFlashForPlayer = new DynamicDetour(Address_Null, CallConv_CDECL, ReturnType_Float, ThisPointer_Ignore);
	if (!hPercentageOfFlashForPlayer)
		SetFailState("Failed to setup detour for PercentageOfFlashForPlayer");
	
	if (!hPercentageOfFlashForPlayer.SetFromConf(temp, SDKConf_Signature, "PercentageOfFlashForPlayer"))
		SetFailState("Failed to load PercentageOfFlashForPlayer signature from gamedata");
	
	hPercentageOfFlashForPlayer.AddParam(HookParamType_CBaseEntity);
	hPercentageOfFlashForPlayer.AddParam(HookParamType_Object, 12);
	hPercentageOfFlashForPlayer.AddParam(HookParamType_CBaseEntity);
	
	if (!hPercentageOfFlashForPlayer.Enable(Hook_Pre, Detour_OnPercentageOfFlashForPlayer))
		SetFailState("Failed to detour PercentageOfFlashForPlayer.");
	
	if (!hPercentageOfFlashForPlayer.Enable(Hook_Post, Detour_OnPercentageOfFlashForPlayer_Post))
		SetFailState("Failed to detour PercentageOfFlashForPlayer post.");
	
	PrintToServer("PercentageOfFlashForPlayer detoured!");*/
}

public MRESReturn Detour_OnFlashbangDetonate(int pThis)
{
	PrintToServer("Detonate called on entity %d!", pThis);
	return MRES_Handled;
}

public MRESReturn Detour_OnFlashbangDetonate_Post(int pThis)
{
	PrintToServer("Detonate post called on entity %d!", pThis);
	return MRES_Handled;
}

public MRESReturn Detour_OnDeafen(int pThis, DHookParam hParams)
{
	PrintToServer("Deafen called on entity %d! distance: %f", pThis, DHookGetParam(hParams, 1));
	hParams.Set(1, 999.0);
	return MRES_ChangedHandled;
}

public MRESReturn Detour_OnDeafen_Post(int pThis, DHookParam hParams)
{
	PrintToServer("Deafen post called on entity %d! distance: %f", pThis, DHookGetParam(hParams, 1));
}

public MRESReturn Detour_OnPercentageOfFlashForPlayer(DHookReturn hReturn, DHookParam hParams)
{
	float pos[3];
	hParams.GetObjectVarVector(2, 0, ObjectValueType_Vector, pos);
	PrintToServer("PercentageOfFlashForPlayer called! entity1 %d, pos [%f %f %f], entity2 %d", hParams.Get(1), pos[0], pos[1], pos[2], hParams.Get(3));
	hReturn.Value = 0.3;
	return MRES_Supercede;
}

public MRESReturn Detour_OnPercentageOfFlashForPlayer_Post(DHookReturn hReturn, DHookParam hParams)
{
	float pos[3];
	hParams.GetObjectVarVector(2, 0, ObjectValueType_Vector, pos);
	PrintToServer("PercentageOfFlashForPlayer_Post called! entity1 %d, pos [%f %f %f], entity2 %d: %f", hParams.Get(1), pos[0], pos[1], pos[2], hParams.Get(3), hReturn.Value);
}