#include "..\..\script_macros.hpp"
/*
    File: fn_respawned.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Sets the player up if he/she used the respawn option.
*/
private ["_handle"];
//Reset our weight and other stuff

life_var_isBusy = false;
life_var_ATMEnabled = true;
life_var_hunger = 100;
life_var_thirst = 100;
life_var_carryWeight = 0;
life_var_cash = 0; //Make sure we don't get our cash back.
life_var_respawned = false;
player playMove "AmovPercMstpSnonWnonDnon";

//Bad boy
if (life_is_arrested) exitWith {
    hint localize "STR_Jail_Suicide";
    life_is_arrested = false;
    [player,true] spawn MPClient_fnc_jail;
    [] call MPClient_fnc_updateRequest;
};

//Johnny law got me but didn't let the EMS revive me, reward them half the bounty.
if (!isNil "life_copRecieve") then {
    [getPlayerUID player,player,life_copRecieve,true] remoteExecCall ["MPServer_fnc_wantedBounty",RSERV];
    life_copRecieve = nil;
};

//So I guess a fellow gang member, cop or myself killed myself so get me off that Altis Most Wanted
if (life_removeWanted) then {
    [getPlayerUID player] remoteExecCall ["MPServer_fnc_wantedRemove",RSERV];
};

//Set some vars on our new body.
{player setVariable _x} forEach [
    ['restrained',false,true],
    ['Escorting',false,true],
    ['transporting',false,true],
    ['playerSurrender',false,true],
    ['steam64id',getPlayerUID player,true],
    ['realname',profileName,true]
];

[] call MPClient_fnc_startLoadout;
[] call MPClient_fnc_setupActions;
 
[player,life_settings_enableSidechannel,playerSide] remoteExecCall ["MPServer_fnc_managesc",RSERV];
if (LIFE_SETTINGS(getNumber,"enable_fatigue") isEqualTo 0) then {player enableFatigue false;};

player playMoveNow "AmovPpneMstpSrasWrflDnon";
 
[] call MPClient_fnc_updateRequest;