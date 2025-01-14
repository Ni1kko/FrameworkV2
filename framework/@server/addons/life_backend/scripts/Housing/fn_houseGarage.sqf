#include "\life_backend\serverDefines.hpp"
/*
    File: fn_houseGarage.sqf
    Author: BoGuu
    Description:
    Database functionality for house garages.
*/

params [
    ["_uid","",[""]],
    ["_house",objNull,[objNull]],
    ["_mode",-1,[0]]
];

if (_uid isEqualTo "") exitWith {};
if (isNull _house) exitWith {};
if (_mode isEqualTo -1) exitWith {};

private _housePos = getPosATL _house;
private "_query";

if (_mode isEqualTo 0) then {
    _query = format ["UPDATE houses SET garage='1' WHERE pid='%1' AND pos='%2'",_uid,_housePos];
} else {
    _query = format ["UPDATE houses SET garage='0' WHERE pid='%1' AND pos='%2'",_uid,_housePos];
};

[_query,1] call MPServer_fnc_database_rawasync_request;

true