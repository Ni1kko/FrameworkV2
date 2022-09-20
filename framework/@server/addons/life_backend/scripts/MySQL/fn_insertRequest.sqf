#include "\life_backend\script_macros.hpp"
/*
    File: fn_insertRequest.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Adds a player to the database upon first joining of the server.
    Recieves information from scripts\sesison\fn_insertPlayerInfo.sqf

    Edits by:
    ## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
*/
 
params [
    ["_player",objNull,[objNull]]
];

//--- Player data
private _uid = getPlayerUID _player;
private _name = name _player;
private _ownerID = owner _player;
private _BEGuid = ('BEGuid' callExtension ("get:"+_uid));

//--- Error checks
if (isNull _player) exitWith {systemChat "ReturnToSender is Null!";};
if (_uid isEqualTo "") exitWith {systemChat "Bad UID";};
if (_name isEqualTo "") exitWith {systemChat "Bad name";};
if (_ownerID <= 3) exitWith {systemChat "Not vaild player!";};
if (_BEGuid isEqualTo "") exitWith {systemChat "Bad BEGuid";};

//--- read database
private _queryResult = ["READ", "players", [["pid","serverID"], [["BEGuid",str _BEGuid]]], true]call MPServer_fnc_database_request;
private _queryBankResult = ["READ", "bankaccounts", [["funds"],[["BEGuid",str _BEGuid]]],true]call MPServer_fnc_database_request;

//--- Bad.. fail safe
if (typeName _queryResult isNotEqualTo "ARRAY" || typeName _queryBankResult isNotEqualTo "ARRAY") exitWith{[] remoteExecCall ["MPClient_fnc_dataQuery",_ownerID]};

//--- Check for inserts
private _insertBank = (count _queryBankResult isEqualTo 0);
private _insertPlayer = (count _queryResult isEqualTo 0);

//--- Double check to make sure the client isn't in the database... 
if (!_insertBank AND !_insertPlayer) exitWith {[] remoteExecCall ["MPClient_fnc_dataQuery",_ownerID]};

//--- Add new player to database
if(_insertPlayer)then{ 
    private _emptyArray = ["DB","ARRAY", []] call MPServer_fnc_database_parse;

    ["CREATE", "players", 
        [//What
            ["serverID", 		["DB","INT", (call life_var_serverID)] call MPServer_fnc_database_parse],
            ["BEGuid", 			["DB","STRING", _BEGuid] call MPServer_fnc_database_parse],
            ["pid", 			["DB","STRING", _uid] call MPServer_fnc_database_parse],
            ["name", 			["DB","STRING", _name] call MPServer_fnc_database_parse],
            ["cash", 			["DB","A2NET", 0] call MPServer_fnc_database_parse],
            ["aliases", 		["DB","ARRAY", [_name]] call MPServer_fnc_database_parse],
            ["virtualitems", 	_emptyArray],
            ["cop_licenses", 	_emptyArray],
            ["reb_licenses", 	_emptyArray],
            ["med_licenses", 	_emptyArray],
            ["civ_licenses", 	_emptyArray],
            ["civ_gear", 		_emptyArray],
            ["cop_gear", 		_emptyArray],
            ["reb_gear", 		_emptyArray],
            ["med_gear", 		_emptyArray]
        ]
    ] call MPServer_fnc_database_request;
};

//--- Add new player bankaccount to database
if(_insertBank)then{
    private _funds = getNumber(missionConfigFile >> "Life_Settings" >> "startingFunds");
    ["CREATE", "bankaccounts", 
        [
            ["BEGuid", 			["DB","STRING", _BEGuid] call MPServer_fnc_database_parse],
            ["funds", 			["DB","A2NET", _funds] call MPServer_fnc_database_parse]
        ]
    ] call MPServer_fnc_database_request;
};


//--- Tell client to re query for new data
[] remoteExec ["MPClient_fnc_dataQuery",_ownerID];