#include "..\..\clientDefines.hpp"
/*
	## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
	## fn_inventoryWalletDropCash.sqf
*/

disableSerialization;
private _control = param [0, controlNull, [controlNull]];
private _ctrlParent = ctrlParent _control;

//-- Close display of the control that was clicked
if(not(isNull _ctrlParent))then{
	//_ctrlParent closeDisplay 1;
};

hint "Drop Cash";


// if not([player,"Money",_selectedAmount] call MPClient_fnc_dropItem)exitWith{};