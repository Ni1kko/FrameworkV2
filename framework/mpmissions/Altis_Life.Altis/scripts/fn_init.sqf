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

private _name = profileName;
private _side = side player;
private _steamID = getPlayerUID player;
private _cfgSpawnPoints = missionConfigFile >> "CfgSpawnPoints";
private _spawnBuildings = getArray(_cfgSpawnPoints >> "spawnBuildings");
private _factionsWithBuildingSpawns = getArray(_cfgSpawnPoints >> "factionsWithBuildingSpawns");

// -- Start Loading Screen (Arma likes to be a prick and sometimes it fails to load, this is a workaround for it)
endLoadingScreen;
waitUntil{not(call BIS_fnc_isLoading)};
uiSleep 0.2;
startLoadingScreen ["","RscDisplayLoadingScreen"];
waitUntil {currentNamespace isEqualTo missionNamespace};

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

// --
["Waiting for the server to broadcast data..."] call MPClient_fnc_log;
waitUntil {!isNil "MPServer_fnc_util_getSideString"};
private _sideVar = [_side,true] call MPServer_fnc_util_getSideString;
private _factionInit = format["MPClient_fnc_init%1",_sideVar];

["Waiting for player data..."] call MPClient_fnc_log;
[] spawn MPClient_fnc_fetchPlayerData;
waitUntil {
    if(life_var_sessionAttempts > MAX_ATTEMPTS_TOO_QUERY_DATA) exitWith {["Unable to load player data", "Please try again"] call MPClient_fnc_endMission};
    uiSleep 1;    
    life_var_sessionDone
};

["Setting up player", "Please wait..."] call MPClient_fnc_setLoadingText; uiSleep(random[0.5,3,6]);
if (CFG_MASTER(getNumber,"enable_fatigue") isEqualTo 0) then {
    player enableFatigue false;
    if (CFG_MASTER(getNumber,"enable_autorun") isEqualTo 1) then {
        [] spawn MPClient_fnc_autoruninit;
    }; 
};
 
[] call MPClient_fnc_setupEVH;
[] call MPClient_fnc_setupActions;
[] spawn MPClient_fnc_briefing;
[] spawn MPClient_fnc_escInterupt;
[] spawn MPClient_fnc_setupStationService;
[] spawn MPClient_fnc_initTents;

//-- Setup spawn markers for every faction to force spawn inside nearest building
if(count _factionsWithBuildingSpawns > 0)then
{
    {
        private _spawnCfg = (_cfgSpawnPoints >> _worldName >> _x);

        for "_index" from 1 to (count(_spawnCfg)-1) do 
        {
            private _spawnZone = (_spawnCfg select _index);
            private _markerName = getText(_spawnZone >> "spawnMarker"); 
            private _markerPos = getMarkerPos _markerName;
            if(_markerPos isNotEqualTo [0,0,0]) then { 
                private _nearestBuildings = nearestObjects[_markerPos, _spawnBuildings,350];
                if(count _nearestBuildings isEqualTo 0)then{ _nearestBuildings pushBack _markerPos};
                currentNamespace setVariable [_markerName,selectRandom _nearestBuildings];
            };
        };
    }forEach _factionsWithBuildingSpawns;
};

//-- Init faction
private _sideCode = currentNamespace getVariable [_factionInit,{}];
if(_sideCode isNotEqualTo {})then{
    ["Loading faction init!"] call MPClient_fnc_log;
    [player] call _sideCode;
};

//-- Input handlers
(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call MPClient_fnc_keydownHandler"];
(findDisplay 46) displayAddEventHandler ["KeyUp", "_this call MPClient_fnc_keyupHandler"];

[("Welcome " + _name),"Have Fun And Respect The Rules!..."] call MPClient_fnc_setLoadingText; uiSleep(5);
["Life_var_initBlackout"] call BIS_fnc_blackIn;//fail safe for loading screen
private _spawnPlayerThread = [life_var_alive,life_var_position] spawn MPClient_fnc_spawnPlayer;
["Waiting for player to spawn!"] call MPClient_fnc_log;
waitUntil{scriptDone _spawnPlayerThread};
enableRadio true;

//-- Paychecks
[_side] call MPClient_fnc_paychecks;

//-- Update wanted profile
[_steamID, _name] remoteExec ["MPServer_fnc_wantedProfUpdate", 2];

//--
[player, life_var_enableSidechannel, _side] remoteExecCall ["MPServer_fnc_managesc", 2];

[] spawn MPClient_fnc_survival;
[] spawn {
    if(getNumber(missionConfigFile >> "cfgSession" >> "autoSave") isNotEqualTo 1)exitWith{false};

    while {true} do {

        waitUntil{  
            uiSleep 30;
            ((time - life_var_lastSynced) > (getNumber(missionConfigFile >> "cfgSession" >> "autoSaveInterval") * 60))
        };

        [true,false,["Auto Syncing player information to Hive."]] call MPClient_fnc_syncData;
        ["Player data auto synced..."] call MPClient_fnc_log;
    };
};
["objects", 1] call MPClient_fnc_s_onCheckedChange;
["tags", 1] call MPClient_fnc_s_onCheckedChange;

[format["Client init completed! Took %1 seconds",diag_tickTime - (call life_var_initTime)]] call MPClient_fnc_log;

true
 