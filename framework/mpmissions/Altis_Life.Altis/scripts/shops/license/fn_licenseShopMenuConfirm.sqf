#include "..\..\..\script_macros.hpp"
/*
	## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
    ## fn_licenseShopMenuConfirm.sqf
*/

private _display = uiNamespace getVariable ["RscDisplayLicenseShop", ctrlParent (param [0, controlNull])];
private _controlShopList = (_display displayCtrl 55126);
private _shopListIndex = lbCurSel _controlShopList;
private _selectedLicense = _controlShopList lbData _shopListIndex;

//-- Try purchase license
if(count _selectedLicense > 0) then 
{
	if (MONEY_CASH < LICENSE_PRICE(_selectedLicense)) exitWith {
		hint format [localize "STR_NOTF_NE_1",[_price] call MPClient_fnc_numberText,LICENSE_DISPLAYNAME(_selectedLicense)];
	};

	["SUB","CASH",_price] call MPClient_fnc_handleMoney;
	
	[player, _selectedLicense, true, true] call MPClient_fnc_setLicense;
};

//-- Refresh menu
[_display] call MPClient_fnc_licenseShopMenuUpdate;

true