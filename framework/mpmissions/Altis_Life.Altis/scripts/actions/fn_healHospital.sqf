#include "..\..\clientDefines.hpp"
/*
    File: fn_healHospital.sqf
    Author: Bryan "Tonic" Boardwine
    Reworked: Jesse "TKCJesse" Schultz

    Description:
    Prompts user with a confirmation dialog to heal themselves.
    Used at the hospitals to restore health to full.
    Note: Dialog helps stop a few issues regarding money loss.
*/
private ["_healCost","_action"];
if (life_var_isBusy) exitWith {};
if ((damage player) < 0.01) exitWith {hint localize "STR_NOTF_HS_FullHealth"};
_healCost = CFG_MASTER(getNumber,"hospital_heal_fee");
if (MONEY_CASH < _healCost) exitWith {hint format [localize "STR_NOTF_HS_NoCash",[_healCost] call MPClient_fnc_numberText];};

life_var_isBusy = true;
_action = [
    format [localize "STR_NOTF_HS_PopUp",[_healCost] call MPClient_fnc_numberText],
    localize "STR_NOTF_HS_TITLE",
    localize "STR_Global_Yes",
    localize "STR_Global_No"
] call BIS_fnc_guiMessage;

if (_action) then {
    titleText[localize "STR_NOTF_HS_Healing","PLAIN"];
    closeDialog 0;
    sleep 8;
    if (player distance (_this select 0) > 5) exitWith {life_var_isBusy = false; titleText[localize "STR_NOTF_HS_ToFar","PLAIN"]};
    titleText[localize "STR_NOTF_HS_Healed","PLAIN"];
    player setDamage 0;
    ["SUB","CASH",_healCost] call MPClient_fnc_handleMoney;
    life_var_isBusy = false;
} else {
    hint localize "STR_NOTF_ActionCancel";
    closeDialog 0;
    life_var_isBusy = false;
};
