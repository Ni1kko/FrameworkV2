#include "..\..\clientDefines.hpp"
/*
    File: fn_robPerson.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Robs a person.
*/
params [
    ["_robber",objNull,[objNull]]
];
if (isNull _robber) exitWith {}; //No one to return it to?

if (MONEY_CASH > 0) then {
    [MONEY_CASH,player,_robber] remoteExecCall ["MPClient_fnc_robReceive",_robber];

    if (count extdb_var_database_headless_clients > 0) then {
        [getPlayerUID _robber,_robber getVariable ["realname",name _robber],"211"] remoteExecCall ["HC_fnc_wantedAdd",extdb_var_database_headless_client];
    } else {
        [getPlayerUID _robber,_robber getVariable ["realname",name _robber],"211"] remoteExecCall ["MPServer_fnc_wantedAdd",RE_SERVER];
    };

    [1,"STR_NOTF_Robbed",true,[_robber getVariable ["realname",name _robber],profileName,[MONEY_CASH] call MPClient_fnc_numberText]] remoteExecCall ["MPClient_fnc_broadcast",RE_CLIENT];
    ["ZERO","CASH"] call MPClient_fnc_handleMoney;
} else {
    [2,"STR_NOTF_RobFail",true,[profileName]] remoteExecCall ["MPClient_fnc_broadcast",_robber];
};
