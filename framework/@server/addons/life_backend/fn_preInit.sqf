#include "script_macros.hpp"
/*
    File: init.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Initialize the server and required systems.
    
    Edits by:
    ## Nanou - HeadlessClient optimization.
    ## Nikko Renolds - https://github.com/Ni1kko/Framework
*/
if(!canSuspend)exitwith{_this spawn life_fnc_preInit; true};
 
life_var_serverLoaded = false;
life_var_severVehicles = [];
life_var_playtimeValues = [];
life_var_playtimeValuesRequest = [];
life_var_corpses = []; 

publicVariable "life_var_serverLoaded";
waitUntil {isFinal "extdb_var_database_key"};

//--- Server info
private _serverDatabaseInit = [] spawn DB_fnc_loadServer;
waitUntil{scriptDone _serverDatabaseInit};

//--- Mission Event handlers
life_var_clientConnected =      addMissionEventHandler ['PlayerConnected',      life_fnc_event_playerConnected,    []];
life_var_clientDisconnected =   addMissionEventHandler ["PlayerDisconnected",   life_fnc_event_playerDisconnected, []];
life_var_handleDisconnectEVH =  addMissionEventHandler ["HandleDisconnect",     {_this call TON_fnc_clientDisconnect; false;}];
life_var_entityRespawnedEVH =   addMissionEventHandler ["EntityRespawned",      TON_fnc_entityRespawned];

[] call TON_fnc_initHouses;
[] call TON_fnc_setupFedralReserve;
[] call TON_fnc_setupHospitals;
[] call TON_fnc_stripNpcs;
[8,true,12] call LifeFSM_fnc_timeModule;

life_var_cleanupThread = [] spawn TON_fnc_cleanup;
life_var_dealersThread = [] spawn TON_fnc_setupDealers;
life_var_huntingThread = ["hunting_zone",30] spawn TON_fnc_huntingZone;

/* Setup radio channels for west/independent/civilian */
life_radio_west = radioChannelCreate [[0, 0.95, 1, 0.8], "Side Channel", "%UNIT_NAME", []];
life_radio_civ = radioChannelCreate [[0, 0.95, 1, 0.8], "Side Channel", "%UNIT_NAME", []];
life_radio_indep = radioChannelCreate [[0, 0.95, 1, 0.8], "Side Channel", "%UNIT_NAME", []];
   
//--- Variable Event handlers
"life_fnc_RequestClientId" addPublicVariableEventHandler {(_this select 1) setVariable ["life_clientID", owner (_this select 1), true];};
"money_log" addPublicVariableEventHandler {diag_log (_this select 1)};
"advanced_log" addPublicVariableEventHandler {diag_log (_this select 1)};
 
//--- 
{publicVariable _x}forEach[
    "TON_fnc_terrainSort",
    "TON_fnc_player_query",
    "TON_fnc_index",
    "TON_fnc_isNumber",
    "TON_fnc_clientGangKick",
    "TON_fnc_clientGetKey",
    "TON_fnc_clientGangLeader",
    "TON_fnc_clientGangLeft",
    "life_var_playtimeValuesRequest",
    "life_var_playtimeValues"
];

//--- Tell clients that the server is ready and is accepting queries
life_var_serverLoaded = true;
publicVariable "life_var_serverLoaded";

true