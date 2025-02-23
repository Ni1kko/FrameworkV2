#include "..\..\clientDefines.hpp"
/*
    File: fn_knockoutAction.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Knocks out the target.
*/
private "_target";
_target = param [0,objNull,[objNull]];

//Error checks
if (isNull _target) exitWith {};
if (!isPlayer _target) exitWith {};
if (player distance _target > 4) exitWith {};
life_var_knockoutBusy = true;
[player,"AwopPercMstpSgthWrflDnon_End2"] remoteExecCall ["MPClient_fnc_animSync",RE_CLIENT];
sleep 0.08;
[_target,profileName] remoteExec ["MPClient_fnc_knockedOut",_target];

sleep 3;
life_var_knockoutBusy = false;
