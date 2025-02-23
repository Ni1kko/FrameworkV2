#include "..\..\clientDefines.hpp"
/*
    File: fn_bankTransfer.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Figure it out again.
*/
private ["_value","_unit","_tax"];
_value = parseNumber(ctrlText 2702);
_unit = call compile format ["%1",(lbData[2703,(lbCurSel 2703)])];
if (isNull _unit) exitWith {};
if ((lbCurSel 2703) isEqualTo -1) exitWith {hint localize "STR_ATM_NoneSelected"};
if (isNil "_unit") exitWith {hint localize "STR_ATM_DoesntExist"};
if (_value > 999999) exitWith {hint localize "STR_ATM_TransferMax";};
if (_value < 0) exitWith {};
if (!([str(_value)] call MPServer_fnc_isNumber)) exitWith {hint localize "STR_ATM_notnumeric"};
if (_value > MONEY_BANK) exitWith {hint localize "STR_ATM_NotEnoughFunds"};
_tax = _value * CFG_MASTER(getNumber,"bank_transferTax");
if ((_value + _tax) > MONEY_BANK) exitWith {hint format [localize "STR_ATM_SentMoneyFail",_value,_tax]};
 
["SUB","BANK",_tax] call MPClient_fnc_handleMoney;
["GIVE","BANK",_value,_unit] call MPClient_fnc_handleMoney;

[] call MPClient_fnc_atmMenu;
[1] call MPClient_fnc_updatePlayerDataPartial;
hint format [localize "STR_ATM_SentMoneySuccess",[_value] call MPClient_fnc_numberText,_unit getVariable ["realname",name _unit],[_tax] call MPClient_fnc_numberText];


if (CFG_MASTER(getNumber,"player_moneyLog") isEqualTo 1) then {
    if (CFG_MASTER(getNumber,"battlEye_friendlyLogging") isEqualTo 1) then {
        money_log = format [localize "STR_DL_ML_transferredBank_BEF",_value,_unit getVariable ["realname",name _unit],[MONEY_BANK] call MPClient_fnc_numberText,[MONEY_CASH] call MPClient_fnc_numberText];
    } else {
        money_log = format [localize "STR_DL_ML_transferredBank",profileName,(getPlayerUID player),_value,_unit getVariable ["realname",name _unit],[MONEY_BANK] call MPClient_fnc_numberText,[MONEY_CASH] call MPClient_fnc_numberText];
    };
    publicVariableServer "money_log";
};
