#include "\life_backend\serverDefines.hpp"
/*
    File : fn_updateHouseContainers.sqf
    Author: NiiRoZz

    Description:
    Update inventory "i" in container
*/
private ["_containerID","_containers","_query","_vehItems","_vehMags","_vehWeapons","_vehBackpacks","_cargo"];
_container = [_this,0,objNull,[objNull]] call BIS_fnc_param;
if (isNull _container) exitWith {};
_containerID = _container getVariable ["container_id",-1];
if (_containerID isEqualTo -1) exitWith {};

_vehItems = getItemCargo _container;
_vehMags = getMagazineCargo _container;
_vehWeapons = getWeaponCargo _container;
_vehBackpacks = getBackpackCargo _container;
_cargo = [_vehItems,_vehMags,_vehWeapons,_vehBackpacks];

_cargo = ["DB","ARRAY", _cargo] call MPServer_fnc_database_parse;

_query = format ["UPDATE containers SET gear='%1' WHERE id='%2'",_cargo,_containerID];

[_query,1] call MPServer_fnc_database_rawasync_request;
