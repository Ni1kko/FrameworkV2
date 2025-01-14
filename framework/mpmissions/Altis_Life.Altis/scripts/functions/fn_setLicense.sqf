#include "..\..\clientDefines.hpp"
/*
	## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
    ## fn_setLicense.sqf
*/

params [
	["_player",objNull,[objNull]],
	["_licenseName","",[""]],
	["_licenseState",false,[false]],
	["_forceUpdate",true,[false]]
];

private _cfgLicenses = missionConfigFile >> "CfgLicenses";;
private _licenseData = life_var_licenses getOrDefault [_licenseName,createHashMapFromArray [
	["Name", _licenseName],
	["State", _licenseState]
]];

//-- is class name? if so convert to mission var
{
	private _classname = configName _x;
	private _sideflag = getText(_x >> "side");
	private	_licenseVarName = LICENSE_VARNAME(_classname,_sideflag);
	
	if(toLower _licenseName in [toLower _classname,toLower _licenseVarName])exitWith{
		_licenseData = life_var_licenses getOrDefault [_classname,createHashMapFromArray [
			["Name", _licenseVarName],
			["State", _licenseState]
		]];
	};
}forEach ("true" configClasses _cfgLicenses);

//-- Update hashMap
life_var_licenses = _licenseData;

//-- TEMP (OLD system method)
missionNamespace setVariable [_licenseData get "Name",_licenseData get "State"];

//-- Sync to database
if _forceUpdate then{
	[2] call MPClient_fnc_updatePlayerDataPartial;
};

//-- return
_licenseData