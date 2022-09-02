/*
	## Nikko Renolds
	## https://github.com/Ni1kko/Framework

	
	[east] spawn life_fnc_switchSide;
	[west] spawn life_fnc_switchSide;
	[civilian] spawn life_fnc_switchSide;
	[independent] spawn life_fnc_switchSide;
*/

//-- File called and not scheduled
if(!canSuspend) exitWith {_this spawn life_fnc_switchSide};

params [
	["_newside",sideUnknown,[sideUnknown]]
]; 

private _return = false;
private _admin = (call (missionNamespace getVariable ["life_adminlevel",{0}])) >= 1;

//-- Get player rank for given side
private _rank = (switch _newside do {
	case west: {call (missionNamespace getVariable ["life_coplevel",{0}])};
	case independent: {call (missionNamespace getVariable ["life_medicLevel",{0}])};
	default {0};
});
 
//-- Whitelist check
if (_newside in [west,east,independent] AND _rank <= 0 AND not(_admin)) exitWith {
	["NotWhitelisted",false,true] call BIS_fnc_endMission;
	_return
};

//-- Blacklist check
if (_newside in [west,east,independent] AND life_blacklisted) exitWith {
	["Blacklisted",false,true] call BIS_fnc_endMission;
	_return
};

// -- Start Loading Screen
startLoadingScreen ["","life_Rsc_DisplayLoading"];

//--
["Saving Current Data", "Please Wait..."] call life_fnc_setLoadingText;
private _sessionvar = [] call SOCK_fnc_updateRequest;
waitUntil {missionNamespace getVariable [_sessionvar,false]};

//-- Switch side
private _player = player;
["Switching side", "Please Wait..."] call life_fnc_setLoadingText;
[_player,_newside,true] remoteExec ["TON_fnc_switchSideRequest",2];

//-- Wait for system to finish
waitUntil {_player isNotEqualTo player || !isNil {_player getVariable "sideswitch_error"}};

//-- Switch failed
if(!isNil {_player getVariable "sideswitch_error"})exitWith{
	private _error = _player getVariable ["sideswitch_error",""];
	if(typeName _error isEqualTo "STRING")then{
		systemChat format ["Error: %1",_error];
		["An Error Occured!",_error] call life_fnc_setLoadingText; 
		uiSleep 6;
	};

	endLoadingScreen;
	disableUserInput false;
};

 
//-- Switch complete
if(_newside isEqualTo playerSide)then
{
	//-- set rank
	player setVariable ["rank",_rank,true];
	
	[_newside] call life_fnc_paychecks;

	//--
	["Side Switched", "Please Wait..."] call life_fnc_setLoadingText; uiSleep(random[0.5,3,6]);

	//--
	_return = true;
};


["Please Wait..."] call life_fnc_setLoadingText; 
uiSleep(random[0.5,3,6]);
endLoadingScreen;

_return