/*

	Function: 	MPClient_fnc_deathScreenKeyHandler
	Project: 	AsYetUntitled
	Author:     Tonic, Merrick, Nikko, Affect & IceEagle132
	Github:		https://github.com/Ni1kko/FrameworkV2
	
*/
#define DIK_INCLUDES 1
#include "..\..\clientDefines.hpp"

params ["_ctrl","_code","_shift","_ctrlKey","_alt"];

private _handled = false;
private _medicReqKey = (actionKeys "ShowMap") select 0;
private _arrested = (player getVariable ["arrested",false]);

switch _code do {
	case _medicReqKey:
	{
		_handled = true;
		if _arrested then { 
			//[player] call MPClient_fnc_requestJailMedic;
		}else{
			[player] call MPClient_fnc_requestMedic;
		};
	};
	case DIK_R:
	{
		_handled = true;
		if (life_deathScreen_canRespawn) then {
			[player, true, true, _arrested] spawn MPClient_fnc_deathScreen;
		};
	};
	case DIK_H:
	{
		if (call life_adminlevel > 0) then {
			_handled = true;
			[player, player, _arrested] spawn MPClient_fnc_revived;
		};
	};
	case DIK_MINUS:
	{
		if(_shift) then {
			_handled = true;
			[] spawn {
				scriptName 'MPClient_fnc_Frozen';
				hint "You are frozen for 15 seconds for Shift minus";
				disableUserInput true;
				sleep 15;
				disableUserInput false;
				hint "You are thawed";
			};
		};
	};
};

_handled