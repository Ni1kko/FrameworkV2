#include "..\..\clientDefines.hpp"
/*
    File: fn_robReceive.sqf
    Author: Bryan "Tonic" Boardwine

    Description:

*/
params [
    ["_cash",0,[0]],
    ["_victim",objNull,[objNull]],
    ["_robber",objNull,[objNull]]
];

if (_robber == _victim) exitWith {};
if (_cash isEqualTo 0) exitWith {titleText[localize "STR_Civ_RobFail","PLAIN"]};
 
["ADD","CASH",_cash] call MPClient_fnc_handleMoney;
titleText[format [localize "STR_Civ_Robbed",[_cash] call MPClient_fnc_numberText],"PLAIN"];

if (CFG_MASTER(getNumber,"player_moneyLog") isEqualTo 1) then {
    if (CFG_MASTER(getNumber,"battlEye_friendlyLogging") isEqualTo 1) then {
        money_log = format [localize "STR_DL_ML_Robbed_BEF",[_cash] call MPClient_fnc_numberText,_victim,[MONEY_BANK] call MPClient_fnc_numberText,[MONEY_CASH] call MPClient_fnc_numberText];
    } else {
        money_log = format [localize "STR_DL_ML_Robbed",profileName,(getPlayerUID player),[_cash] call MPClient_fnc_numberText,_victim,[MONEY_BANK] call MPClient_fnc_numberText,[MONEY_CASH] call MPClient_fnc_numberText];
    };
    publicVariableServer "money_log";
};
