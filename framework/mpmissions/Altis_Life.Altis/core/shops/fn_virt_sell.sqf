#include "..\..\script_macros.hpp"
/*
    File: fn_virt_sell.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Sell a virtual item to the store / shop
*/
private ["_type","_index","_price","_amount","_name"];
if ((lbCurSel 2402) isEqualTo -1) exitWith {};
_type = lbData[2402,(lbCurSel 2402)];
_price = M_CONFIG(getNumber,"VirtualItems",_type,"sellPrice");
if (_price isEqualTo -1) exitWith {};

_amount = ctrlText 2405;
if (!([_amount] call MPServer_fnc_isNumber)) exitWith {hint localize "STR_Shop_Virt_NoNum";};
_amount = parseNumber (_amount);
if (_amount > (ITEM_VALUE(_type))) exitWith {hint localize "STR_Shop_Virt_NotEnough"};
if ((time - life_action_delay) < 0.2) exitWith {hint localize "STR_NOTF_ActionDelay";};
life_action_delay = time;

_price = (_price * _amount);
_name = M_CONFIG(getText,"VirtualItems",_type,"displayName");
if ([false,_type,_amount] call MPClient_fnc_handleInv) then {
    hint format [localize "STR_Shop_Virt_SellItem",_amount,TEXT_LOCALIZE(_name),[_price] call MPClient_fnc_numberText];
    life_var_cash = life_var_cash + _price;
    [0] call MPClient_fnc_updatePartial;
    [] call MPClient_fnc_virt_update;
};

if (life_shop_type isEqualTo "drugdealer") then {
    private ["_array","_ind","_val"];
    _array = life_shop_npc getVariable ["sellers",[]];
    _ind = [getPlayerUID player,_array] call MPServer_fnc_index;
    if (!(_ind isEqualTo -1)) then {
        _val = ((_array select _ind) select 2);
        _val = _val + _price;
        _array set[_ind,[getPlayerUID player,profileName,_val]];
        life_shop_npc setVariable ["sellers",_array,true];
    } else {
        _array pushBack [getPlayerUID player,profileName,_price];
        life_shop_npc setVariable ["sellers",_array,true];
    };
};

if (life_shop_type isEqualTo "gold" && (LIFE_SETTINGS(getNumber,"federalReserve_atmRestrictionTimer")) > 0) then {
    [] spawn {
        life_var_ATMEnabled = false;
        sleep ((LIFE_SETTINGS(getNumber,"federalReserve_atmRestrictionTimer")) * 60);
        life_var_ATMEnabled = true;
    };
};

[3] call MPClient_fnc_updatePartial;