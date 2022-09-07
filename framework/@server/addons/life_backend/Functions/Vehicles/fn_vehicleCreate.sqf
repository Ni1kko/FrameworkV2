/*
    File: fn_vehicleCreate.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Answers the query request to create the vehicle in the database.
*/
private ["_uid","_side","_type","_classname","_color","_plate"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_side = [_this,1,sideUnknown,[west]] call BIS_fnc_param;
_vehicle = [_this,2,objNull,[objNull]] call BIS_fnc_param;
_color = [_this,3,-1,[0]] call BIS_fnc_param;

//Error checks
if (_uid isEqualTo "" || _side isEqualTo sideUnknown || isNull _vehicle) exitWith {};
if (!alive _vehicle) exitWith {};
_className = typeOf _vehicle;
if !(isClass (missionConfigFile >> "LifeCfgVehicles" >> _className)) exitWith {}; // No-Inject Batiment hack
_type = switch (true) do {
    case (_vehicle isKindOf "Car"): {"Car"};
    case (_vehicle isKindOf "Air"): {"Air"};
    case (_vehicle isKindOf "Ship"): {"Ship"};
};

private _side = [_side,true] call MPServer_fnc_util_getSideString;

_plate = round(random(1000000));
[_uid,_side,_type,_classname,_color,_plate] call MPServer_fnc_insertVehicle;
_vehicle setVariable ["oUUID",_uid,true];
_vehicle setVariable ["dbInfo",[_uid,_plate],true];