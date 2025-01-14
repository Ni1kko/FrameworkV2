#include "..\..\clientDefines.hpp"
/*
    File: fn_lightHouseAction.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Lights up the house.
*/
private "_house";
_house = param [0,objNull,[objNull]];
if (isNull _house) exitWith {};
if (!(_house isKindOf "House_F")) exitWith {};

if (isNull (_house getVariable ["lightSource",objNull])) then {
    [_house,true] remoteExecCall ["MPClient_fnc_lightHouse",RE_CLIENT];
} else {
    [_house,false] remoteExecCall ["MPClient_fnc_lightHouse",RE_CLIENT];
};