#include "..\script_macros.hpp"
/*
	## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
*/

params ["_serverName","_missionName","_worldName","_worldSize"];

//-- Handle file runing before preInit (Ban hacker)
if (!isFinal "life_var_preInitTime")exitWith{ 
    ["Hack Detected", "MPClient_fnc_init ran before preInit hacker detected", "Antihack"] call MPClient_fnc_endMission;
    false;
};

//-- Handle file runing after init (Ban hacker)
if (isFinal "life_var_initTime")exitWith{
    ["Hack Detected", "`life_var_initTime` already final, Hacker detected", "Antihack"] call MPClient_fnc_endMission;
    false;
};

waitUntil{uiSleep 0.2;(getClientState isEqualTo "BRIEFING READ") && !isNull findDisplay 46};

// -- 
enableSentences false;
enableRadio false;

// -- Start Loading Screen
startLoadingScreen ["","life_Rsc_DisplayLoading"];
["Setting up client", "Please Wait..."] call MPClient_fnc_setLoadingText; uiSleep(random[0.5,3,6]);
 
life_var_initTime = compileFinal str(diag_tickTime);

["Loading client init"] call MPClient_fnc_log;

// --
["Waiting for the server to be ready..."] call MPClient_fnc_log;
waitUntil {!isNil "life_var_serverLoaded" && {!isNil "extdb_var_database_error"}};
if (extdb_var_database_error) exitWith {["Database failed to load", "Please contact an administrator"] call MPClient_fnc_endMission};
if !life_var_serverLoaded then { 
    waitUntil {
        if(life_var_serverTimeout > MAX_SECS_TOO_WAIT_FOR_SERVER) exitWith {["Server failed to load", "Please try again"] call MPClient_fnc_endMission};
        ["Waiting for the server to be ready", "Please wait"] call MPClient_fnc_setLoadingText; 
        uiSleep 0.2;
        ["Waiting for the server to be ready", "Please wait."] call MPClient_fnc_setLoadingText; 
        uiSleep 0.2;
        ["Waiting for the server to be ready", "Please wait.."] call MPClient_fnc_setLoadingText;  
        uiSleep 0.2;
        ["Waiting for the server to be ready", "Please wait..."] call MPClient_fnc_setLoadingText;
        uiSleep 0.4;
        life_var_serverTimeout = life_var_serverTimeout + 1;
        life_var_serverLoaded
    }; 
};

["Waiting for player data..."] call MPClient_fnc_log;
[] spawn MPClient_fnc_dataQuery;
waitUntil {
    if(life_var_session_attempts > MAX_ATTEMPTS_TOO_QUERY_DATA) exitWith {["Unable to load player data", "Please try again"] call MPClient_fnc_endMission};
    uiSleep 1;    
    life_session_completed
};

["Setting up player", "Please wait..."] call MPClient_fnc_setLoadingText; uiSleep(random[0.5,3,6]);
{player setVariable _x} forEach [
    ['restrained', false, true],
    ['Escorting', false, true],
    ['transporting', false, true],
    ['playerSurrender', false, true],
    ['realname', profileName, true],
    ['lifeState','HEALTHY',true]
];

if (LIFE_SETTINGS(getNumber,"enable_fatigue") isEqualTo 0) then {
    player enableFatigue false;
    if (LIFE_SETTINGS(getNumber,"enable_autorun") isEqualTo 1) then {
        [] spawn MPClient_fnc_autoruninit;
    }; 
};
 
[] call MPClient_fnc_setupEVH;
[] call MPClient_fnc_setupActions;
[] spawn MPClient_fnc_briefing;
[] spawn MPClient_fnc_escInterupt;
[] spawn MPClient_fnc_setupStationService;
[] spawn MPClient_fnc_initTents;

//-- Input handlers
(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call MPClient_fnc_keydownHandler"];
(findDisplay 46) displayAddEventHandler ["KeyUp", "_this call MPClient_fnc_keyupHandler"];

//-- Update wanted prifle
[getPlayerUID player, profileName] remoteExec ["MPServer_fnc_wantedProfUpdate", 2];

private _side = side player;
private _sideVar = [_side,true] call MPServer_fnc_util_getSideString;
private _sideCode = missionNamespace getVariable [format["MPClient_fnc_init%1",_sideVar],{}];
 
//-- 
[player, _MPClient_fnc_exit] call _sideCode;
[("Welcome " + profilename),"Have Fun And Respect The Rules!..."] call MPClient_fnc_setLoadingText; uiSleep(5);
private _spawnPlayerThread = [life_is_alive,life_position] spawn MPClient_fnc_spawnPlayer;
["Waiting for player to spawn!"] call MPClient_fnc_log;
waitUntil{scriptDone _spawnPlayerThread};
enableRadio true;

//-- Paychecks
[_side] call MPClient_fnc_paychecks;

//--
[player, life_settings_enableSidechannel, playerSide] remoteExecCall ["MPServer_fnc_managesc", 2];

[] spawn MPClient_fnc_cellphone;//temp
[] spawn MPClient_fnc_survival;

["objects", 1] call MPClient_fnc_s_onCheckedChange;
["tags", 1] call MPClient_fnc_s_onCheckedChange;

[format["Client init completed! Took %1 seconds",diag_tickTime - (call life_var_initTime)]] call MPClient_fnc_log;

true
 