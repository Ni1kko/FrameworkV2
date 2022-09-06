#include "..\..\script_macros.hpp"
/*
    File: fn_buyLicense.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Called when purchasing a license. May need to be revised.
*/
private ["_type","_varName","_displayName","_sideFlag","_price"];
_type = _this select 3;

if (!isClass (missionConfigFile >> "Licenses" >> _type)) exitWith {}; //Bad entry?
_displayName = M_CONFIG(getText,"Licenses",_type,"displayName");
_price = M_CONFIG(getNumber,"Licenses",_type,"price");
_sideFlag = M_CONFIG(getText,"Licenses",_type,"side");
_varName = LICENSE_VARNAME(_type,_sideFlag);

if (life_var_cash < _price) exitWith {hint format [localize "STR_NOTF_NE_1",[_price] call MPClient_fnc_numberText,localize _displayName];};
life_var_cash = life_var_cash - _price;

[0] call MPClient_fnc_updatePartial;

titleText[format [localize "STR_NOTF_B_1", localize _displayName,[_price] call MPClient_fnc_numberText],"PLAIN"];
missionNamespace setVariable [_varName,true];

[2] call MPClient_fnc_updatePartial;
