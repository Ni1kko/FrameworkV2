#include "\life_backend\script_macros.hpp"
/*
    File: fn_queryRequest.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Handles the incoming request and sends an asynchronous query
    request to the database.

    Return:
    ARRAY - If array has 0 elements it should be handled as an error in client-side files.
    STRING - The request had invalid handles or an unknown error and is logged to the RPT.
*/
params [
    ["_player",objNull,[objNull]]
];

if (isNull _player) exitWith {};

if (LIFE_SETTINGS(getNumber,"player_deathLog") isEqualTo 1) then {
    _player addMPEventHandler ["MPKilled", {_this call MPServer_fnc_whoDoneIt}];
};
 
private _uid = getPlayerUID _player;
private _ownerID = owner _player;
private _netID = netId _player;
private _side = side _player;
private _sideVar = (switch (_side) do {case west: {"cop"}; case east: {"reb"}; case independent: {"med"}; default {"civ"};});
private _BEGuid = ('BEGuid' callExtension ("get:"+_uid));

private _queryClause = [["BEGuid",str _BEGuid]];
private _queryParams = [
    /* 0 */ "pid", 
    /* 1 */ "name", 
    /* 2 */ "cash", 
    /* 3 */ "adminlevel", 
    /* 4 */ "donorlevel", 
    /* 5 */ "joblevel", 
    /* 6 */ "reblevel", 
    /* 7 */ "mediclevel", 
    /* 8 */ "coplevel",
    /* 9 */ format ["%1_licenses",_sideVar],
    /* 10 */ format ["%1_gear",_sideVar], 
    /* 11 */ "virtualitems", 
    /* 12 */ "arrested", 
    /* 13 */ "blacklist", 
    /* 14 */ "alive", 
    /* 15 */ "stats", 
    /* 16 */ "position", 
    /* 17 */ "playtime"
];
private _queryResult = ["READ", "players", [_queryParams,_queryClause],true]call MPServer_fnc_database_request;
private _queryBankResult = ["READ", "bankaccounts", [["funds"],_queryClause],true]call MPServer_fnc_database_request;

if (_queryResult isEqualTo ["DB:Read:Task-failure",false]) exitWith {
    diag_log format ["Error reading player: %1",_BEGuid];
}; 

if (_queryBankResult isEqualTo ["DB:Read:Task-failure",false]) exitWith {
    diag_log format ["Error reading player-bank: %1",_BEGuid];
};

if (count _queryResult isEqualTo 0 || count _queryBankResult isEqualTo 0) exitWith {
    [] remoteExecCall ["MPClient_fnc_insertPlayerInfo",_ownerID];
};


_queryResult set [0,_BEGuid];

private _return = _queryResult select [0,2];

//--- Cash (2)
_return pushBack (["GAME","A2NET", (_queryResult#2)] call MPServer_fnc_database_parse);
//--- Admin (3)
_return pushBack (["GAME","INT", (_queryResult#3)] call MPServer_fnc_database_parse);
//--- Donator (4)
_return pushBack (["GAME","INT", (_queryResult#4)] call MPServer_fnc_database_parse);
//--- Job (5)
_return pushBack (["GAME","INT", (_queryResult#5)] call MPServer_fnc_database_parse);
//--- Rebel (6)
_return pushBack (["GAME","INT", (_queryResult#6)] call MPServer_fnc_database_parse);
//--- Medic (7)
_return pushBack (["GAME","INT", (_queryResult#7)] call MPServer_fnc_database_parse);
//--- Cop (8)
_return pushBack (["GAME","INT", (_queryResult#8)] call MPServer_fnc_database_parse);
//--- Licenses (9)
_return pushBack ((["GAME","ARRAY", _queryResult#9] call MPServer_fnc_database_parse) apply{[_x#0,["GAME","BOOL", _x#1] call MPServer_fnc_database_parse]});
//--- Gear (19)
_return pushBack ([
    ["GAME","ARRAY", (_queryResult#10)] call MPServer_fnc_database_parse,
    ["GAME","ARRAY", (_queryResult#11)] call MPServer_fnc_database_parse
]); 
//--- Arrested (11)
_return pushBack (["GAME","BOOL", (_queryResult#12)] call MPServer_fnc_database_parse);
//--- Blacklist (12)
_return pushBack (["GAME","BOOL", (_queryResult#13)] call MPServer_fnc_database_parse);
//--- Alive (13)
_return pushBack (["GAME","BOOL", (_queryResult#14)] call MPServer_fnc_database_parse);
//--- Stats (14)
_return pushBack (["GAME","ARRAY", (_queryResult#15)] call MPServer_fnc_database_parse);
//--- Position (15)
_return pushBack (["GAME","ARRAY", (_queryResult#16)] call MPServer_fnc_database_parse); 

//--- Playtime
private _playtimenew = ["GAME","ARRAY", (_queryResult#17)] call MPServer_fnc_database_parse;
private _playtimeindex = life_var_playtimeValuesRequest find [_uid, _playtimenew];
if (_playtimeindex != -1) then {
    life_var_playtimeValuesRequest set[_playtimeindex,-1];
    life_var_playtimeValuesRequest = life_var_playtimeValuesRequest - [-1];
    life_var_playtimeValuesRequest pushBack [_uid, _playtimenew];
} else {
    life_var_playtimeValuesRequest pushBack [_uid, _playtimenew];
};

switch (_side) do {
    case west: { 
        [_uid,_playtimenew#0] call MPServer_fnc_setPlayTime;
    };
    case independent: { 
        [_uid,_playtimenew#1] call MPServer_fnc_setPlayTime;
    };
    case east: { 
        [_uid,_playtimenew#2] call MPServer_fnc_setPlayTime;
    };
    default { 
        [_uid,_playtimenew#3] call MPServer_fnc_setPlayTime;
    };
};
publicVariable "life_var_playtimeValuesRequest";

//--- Tents (16)
//private _tentsData = _uid spawn MPServer_fnc_fetchPlayerTents;
//waitUntil {scriptDone _tentsData};
_return pushBack (missionNamespace getVariable [format ["tents_%1",_uid],[]]);
 
//--- Houses (17)
private _houseData = _uid spawn MPServer_fnc_fetchPlayerHouses;
waitUntil {scriptDone _houseData};
_return pushBack (missionNamespace getVariable [format ["houses_%1",_uid],[]]);

//--- Gang (18)
private _gangData = _uid spawn MPServer_fnc_queryPlayerGang;
waitUntil{scriptDone _gangData};
_return pushBack (missionNamespace getVariable [format ["gang_%1",_uid],[]]);

//--- Keychain (19)
_return pushBack (missionNamespace getVariable [format ["%1_KEYS_%2",_uid,_side],[]]);

//--- Bank 
[missionNamespace,["life_var_bank",(["GAME","A2NET", (_queryBankResult#0)] call MPServer_fnc_database_parse)]] remoteExec ["setVariable",_ownerID];


//--- Return
_return remoteExec ["MPClient_fnc_requestReceived",_ownerID];