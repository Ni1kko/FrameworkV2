/*

	Function: 	life_fnc_medicRequest
	Project: 	Misty Peaks RPG
	Author:     Tonic, Merrick, Nikko, Affect & IceEagle132
	Github:		https://github.com/AsYetUntitled/Framework
	
*/

if (!params[
	["_caller",objNull,[objNull]],
	["_callerName","Unknown Player",[""]]
]) exitWith {};

if (isNull _caller) exitWith {};

player reveal _caller;

[missionNamespace,["life_var_medicstatusby",player getVariable ["realname",""]]] remoteExec ["setVariable",owner _caller];

["MedicalRequestEmerg",[format[localize "STR_Medic_Request",_callerName]]] call BIS_fnc_showNotification;
