#include "..\..\clientDefines.hpp"
/*
    File: fn_jerryCanRefuel.sqf
    Author: Bryan "Tonic" Boardwine
    Modified: Jesse "tkcjesse" Schultz

    Description:
    Refuels the empty fuel canister at a gas pump. Based off the jerryRefuel/lockpick scripts by Tonic.
*/
private ["_startPos","_badDistance","_title","_ui","_progress","_pgText","_cP","_action","_fuelCost"];
life_var_interrupted = false;
if (life_inv_fuelEmpty isEqualTo 0) exitWith {};
if (count(nearestObjects [player,["Land_FuelStation_Feed_F","Land_fs_feed_F"],3.5]) isEqualTo 0) exitWith { hint localize "STR_ISTR_Jerry_Distance";};
if (life_var_isBusy) exitWith {};
if !(isNull objectParent player) exitWith {};
if (player getVariable "restrained") exitWith {hint localize "STR_NOTF_isrestrained";};
if (player getVariable "playerSurrender") exitWith {hint localize "STR_NOTF_surrender";};
_fuelCost = CFG_MASTER(getNumber,"fuelCan_refuel");

life_var_isBusy = true;
_action = [
    format [localize "STR_ISTR_Jerry_PopUp",[_fuelCost] call MPClient_fnc_numberText],
    localize "STR_ISTR_Jerry_StationPump",
    localize "STR_Global_Yes",
    localize "STR_Global_No"
] call BIS_fnc_guiMessage;

if (_action) then {
    if (MONEY_CASH < _fuelCost) exitWith {hint localize "STR_NOTF_NotEnoughMoney"; life_var_isBusy = false;};
    _startPos = getPos player;
    //Setup our progress bar.
    disableSerialization;
    "progressBar" cutRsc ["RscTitleProgressBar","PLAIN"];
    _title = localize "STR_ISTR_Jerry_Refuel";
    _ui = uiNamespace getVariable "RscTitleProgressBar";
    _progress = _ui displayCtrl 38201;
    _pgText = _ui displayCtrl 38202;
    _pgText ctrlSetText format ["%2 (1%1)...","%",_title];
    _progress progressSetPosition 0.01;
    _cP = 0.01;

    for "_i" from 0 to 1 step 0 do {
        if (animationState player != "AinvPknlMstpSnonWnonDnon_medic_1") then {
            [player,"AinvPknlMstpSnonWnonDnon_medic_1",true] remoteExecCall ["MPClient_fnc_animSync",RE_CLIENT];
            player switchMove "AinvPknlMstpSnonWnonDnon_medic_1";
            player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
        };
        sleep 0.2;
        if (isNull _ui) then {
            "progressBar" cutRsc ["RscTitleProgressBar","PLAIN"];
            _ui = uiNamespace getVariable "RscTitleProgressBar";
            _progressBar = _ui displayCtrl 38201;
            _titleText = _ui displayCtrl 38202;
        };
        _cP = _cP + 0.01;
        _progress progressSetPosition _cP;
        _pgText ctrlSetText format ["%3 (%1%2)...",round(_cP * 100),"%",_title];
        if (_cP >= 1) exitWith {};
        if (!alive player) exitWith {life_var_isBusy = false;};
        if (life_var_interrupted) exitWith {life_var_interrupted = false; life_var_isBusy = false;};
    };

    //Kill the UI display and check for various states
    "progressBar" cutText ["","PLAIN"];
    player playActionNow "stop";

    if (!alive player || life_var_tazed || life_var_unconscious) exitWith {life_var_isBusy = false;};
    if (player getVariable ["restrained",false]) exitWith {life_var_isBusy = false;};
    if (!isNil "_badDistance") exitWith {titleText[localize "STR_ISTR_Lock_TooFar","PLAIN"]; life_var_isBusy = false;};
    if (life_var_interrupted) exitWith {life_var_interrupted = false; titleText[localize "STR_NOTF_ActionCancel","PLAIN"]; life_var_isBusy = false;};
    if not(["USE","fuelEmpty",1] call MPClient_fnc_handleVitrualItem) exitWith {life_var_isBusy = false;};
    life_var_isBusy = false;
    ["SUB","CASH",_fuelCost] call MPClient_fnc_handleMoney;
    ["ADD","fuelFull",1] call MPClient_fnc_handleVitrualItem;
    hint localize "STR_ISTR_Jerry_Refueled";
} else {
    hint localize "STR_NOTF_ActionCancel";
    closeDialog 0;
    life_var_isBusy = false;
};