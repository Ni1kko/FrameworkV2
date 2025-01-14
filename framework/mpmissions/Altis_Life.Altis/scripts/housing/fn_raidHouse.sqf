#include "..\..\clientDefines.hpp"
/*
    File: fn_raidHouse.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Raids the players house?
*/
private ["_house","_uid","_cpRate","_cP","_title","_titleText","_ui","_houseInv","_houseInvData","_houseInvVal"];
_house = param [0,objNull,[objNull]];

if (isNull _house || !(_house isKindOf "House_F")) exitWith {};
if (isNil {(_house getVariable "house_owner")}) exitWith {hint localize "STR_House_Raid_NoOwner"};

_uid = ((_house getVariable "house_owner") select 0);

if (!([_uid] call MPClient_fnc_isUIDActive)) exitWith {hint localize "STR_House_Raid_OwnerOff"};

_houseInv = _house getVariable ["virtualInventory",[[],0]];
if (_houseInv isEqualTo [[],0]) exitWith {hint localize "STR_House_Raid_Nothing"};
life_var_isBusy = true;

//Setup the progress bar
disableSerialization;
_title = localize "STR_House_Raid_Searching";
"progressBar" cutRsc ["RscTitleProgressBar","PLAIN"];
_ui = uiNamespace getVariable "RscTitleProgressBar";
_progressBar = _ui displayCtrl 38201;
_titleText = _ui displayCtrl 38202;
_titleText ctrlSetText format ["%2 (1%1)...","%",_title];
_progressBar progressSetPosition 0.01;
_cP = 0.01;
_cpRate = 0.0075;

for "_i" from 0 to 1 step 0 do {
    sleep 0.26;
    if (isNull _ui) then {
        "progressBar" cutRsc ["RscTitleProgressBar","PLAIN"];
        _ui = uiNamespace getVariable "RscTitleProgressBar";
    };
    _cP = _cP + _cpRate;
    _progressBar progressSetPosition _cP;
    _titleText ctrlSetText format ["%3 (%1%2)...",round(_cP * 100),"%",_title];
    if (_cP >= 1 || !alive player) exitWith {};
    if (player distance _house > 13) exitWith {};
};

//Kill the UI display and check for various states
"progressBar" cutText ["","PLAIN"];
if (player distance _house > 13) exitWith {life_var_isBusy = false; titleText[localize "STR_House_Raid_TooFar","PLAIN"]};
if (!alive player) exitWith {life_var_isBusy = false;};
life_var_isBusy = false;

_houseInvData = (_houseInv select 0);
_houseInvVal = (_houseInv select 1);
_value = 0;
{
    _var = _x select 0;
    _val = _x select 1;

    if (ITEM_ILLEGAL(_var) isEqualTo 1) then {
        if (!(ITEM_SELLPRICE(_var) isEqualTo -1)) then {
            _houseInvData deleteAt _forEachIndex;
            _houseInvVal = _houseInvVal - (([_var] call MPClient_fnc_itemWeight) * _val);
            _value = _value + (_val * ITEM_SELLPRICE(_var));
        };
    };
} forEach (_houseInv select 0);

if (_value > 0) then {
    [0,"STR_House_Raid_Successful",true,[[_value] call MPClient_fnc_numberText]] remoteExecCall ["MPClient_fnc_broadcast",RE_CLIENT];
    
    ["ADD","BANK",round(_value / 2)] call MPClient_fnc_handleMoney;

    _house setVariable ["virtualInventory",[_houseInvData,_houseInvVal],true];

    if (count extdb_var_database_headless_clients > 0) then {
        [_house] remoteExecCall ["HC_fnc_updateHouseTrunk",extdb_var_database_headless_client];
    } else {
        [_house] remoteExecCall ["MPServer_fnc_updateHouseTrunk",RE_SERVER];
    };
} else {
    hint localize "STR_House_Raid_NoIllegal";
};
