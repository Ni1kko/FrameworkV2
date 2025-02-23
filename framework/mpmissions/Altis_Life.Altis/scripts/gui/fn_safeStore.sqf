#include "..\..\clientDefines.hpp"
/*
    File: fn_safeStore.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Gateway copy of fn_vehStoreItem but designed for the safe.
*/
private ["_ctrl","_num"];
disableSerialization;
_ctrl = CONTROL_DATA(3503);
_num = ctrlText 3506;

//Error checks
if (!([_num] call MPServer_fnc_isNumber)) exitWith {hint localize "STR_MISC_WrongNumFormat";};
_num = parseNumber(_num);
if (_num < 1) exitWith {hint localize "STR_Cop_VaultUnder1";};
if (!(_ctrl isEqualTo "goldBar")) exitWith {hint localize "STR_Cop_OnlyGold"};
if (_num > life_inv_goldbar) exitWith {hint format [localize "STR_Cop_NotEnoughGold",_num];};

//Store it.
if not(["USE",_ctrl,_num] call MPClient_fnc_handleVitrualItem) exitWith {hint localize "STR_Cop_CantRemove";};
_safeInfo = life_safeObj getVariable ["safe",0];
life_safeObj getVariable ["safe",_safeInfo + _num,true];

[life_safeObj] call MPClient_fnc_safeInventory;
