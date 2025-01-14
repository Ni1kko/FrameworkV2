#include "\life_backend\serverDefines.hpp"
/*
    File: fn_addHouse.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Inserts the players newly bought house in the database.
*/
private ["_housePos","_query"];
params [
    ["_uid","",[""]],
    ["_house",objNull,[objNull]]
];
if (isNull _house || _uid isEqualTo "") exitWith {};

_housePos = getPosATL _house;

[format ["INSERT INTO houses (pid, pos, owned) VALUES('%1', '%2', '1')",_uid,_housePos],1] call MPServer_fnc_database_rawasync_request;

sleep 0.3;

_query = format ["SELECT id FROM houses WHERE pos='%1' AND pid='%2' AND owned='1'",_housePos,_uid];
_queryResult = [_query,2] call MPServer_fnc_database_rawasync_request;
//systemChat format ["House ID assigned: %1",_queryResult select 0];
_house setVariable ["house_id",(_queryResult select 0),true];
