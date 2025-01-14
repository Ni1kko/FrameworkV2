#include "\life_backend\serverDefines.hpp"
/*
    File: fn_addContainer.sqf
    Author: NiiRoZz

    Description:
    Add container in Database.
*/
private ["_containerPos","_query","_className","_dir"];
params [
    ["_uid","",[""]],
    ["_container",objNull,[objNull]]
];

if (isNull _container || _uid isEqualTo "") exitWith {};

_containerPos = getPosATL _container;
_className = typeOf _container;
_dir = [vectorDir _container, vectorUp _container];

[format ["INSERT INTO containers (pid, pos, classname, inventory, gear, owned, dir) VALUES('%1', '%2', '%3', '""[[],0]""', '""[]""', '1', '%4')",_uid,_containerPos,_className,_dir],1] call MPServer_fnc_database_rawasync_request;

sleep 0.3;

_query = format ["SELECT id FROM containers WHERE pos='%1' AND pid='%2' AND owned='1'",_containerPos,_uid];
_queryResult = [_query,2] call MPServer_fnc_database_rawasync_request;
//systemChat format ["House ID assigned: %1",_queryResult select 0];
_container setVariable ["container_id",(_queryResult select 0),true];
