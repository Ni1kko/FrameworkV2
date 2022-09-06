/*
	## Nikko Renolds
	## https://github.com/Ni1kko/Framework
*/

if(!isServer)exitwith{false}; 
if(!isNil "life_var_rcon_serverLocked")exitwith{false};
 
life_var_rcon_RestartTimes = getArray (configFile >> "CfgRCON" >> "restartTimes");
life_var_rcon_KickTime = getNumber (configFile >> "CfgRCON" >> "kickTime");
life_var_rcon_LockTime = getNumber (configFile >> "CfgRCON" >> "restartAutoLock");
life_var_rcon_UseAutokick = getNumber (configFile >> "CfgRCON" >> "useAutoKick");
life_var_rcon_FriendlyMessages = getArray(configFile >> "CfgRCON" >> "friendlyMessages");
life_var_rcon_RestartMessages = false;
life_var_rcon_passwordOK = false;
life_var_rcon_serverLocked = false;
life_var_rcon_RestartTime = 0;
life_var_rcon_RestartMode = 0;
life_var_rcon_upTime = 0;
life_var_rcon_RealTime = "12:00";
life_var_rcon_messagequeue = [];
life_var_rcon_setupEvents_thread = scriptNull;
life_var_rcon_nextRestart = "12:00";
life_var_rcon_inittime = compile str diag_tickTime;

"Starting RCON" call life_fnc_rcon_systemlog;

life_fnc_rcon_getUpTime = compileFinal "round((diag_tickTime - (call life_var_rcon_inittime) / 60))";
 
{
	private _tempTime = [_x] call life_fnc_util_getRemainingTime;
	if(_tempTime isNotEqualTo -1)exitWith{
		life_var_rcon_nextRestart = _x;
	};
} forEach life_var_rcon_RestartTimes;

{publicVariable _x} forEach [
	"life_var_rcon_passwordOK",
	"life_var_rcon_RestartTime",
	"life_var_rcon_upTime",
	"life_var_rcon_RealTime",
	"life_var_rcon_RestartMode"
];

if ("#init/" call life_fnc_rcon_sendCommand) then
{
	"Lock Event: server locked for init" call life_fnc_rcon_systemlog;
	[] call life_fnc_rcon_kickAll;
	life_var_rcon_inittime = compileFinal str diag_tickTime;
	life_var_rcon_setupEvents_thread = [] spawn life_fnc_rcon_setupEvents;
};

true