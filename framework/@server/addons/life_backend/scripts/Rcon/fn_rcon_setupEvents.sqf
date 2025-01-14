#include "\life_backend\serverDefines.hpp"
/*
	## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
*/

if(!isServer)exitwith{false};
if(isRemoteExecuted)exitwith{false};

"Events thread initializing" call MPServer_fnc_rcon_systemlog;

if(getNumber (configFile >> "CfgRCON" >> "useRestartMessages") isEqualTo 1)then{
	life_var_rcon_RestartMessages = getArray(configFile >> "CfgRCON" >> "restartWarningTime");
};

"Events thread paused: Waiting for server to load!" call MPServer_fnc_rcon_systemlog;

waitUntil {(missionNamespace getVariable ["life_var_serverLoaded",false])};

private _heartbeat =  0;
private _rconlocked = life_var_rcon_serverLocked;
private _rconshutdown = getNumber(configFile >> "CfgRCON" >> "useShutdown") isEqualTo 1;

if(!life_var_rcon_passwordOK)then{
	_rconlocked = false;
};
 
"Events thread resumed: System fully initialized!" call MPServer_fnc_rcon_systemlog;

if (_rconlocked && life_var_rcon_RestartMode isEqualTo 0) then{
	"Lock Event: server will unlock soon!" call MPServer_fnc_rcon_systemlog;
};

private _mins2hrsmins = compile "
	private _hrs = floor((_this * 60 ) / 60 / 60);
	private _mins = (((_this * 60 ) / 60 / 60) - _hrs);
	if(_mins == 0)then{_mins = 0.0001;};
	_mins = round(_mins * 60);
	[_hrs,_mins]
";

private _serveruptime = false call MPServer_fnc_database_getUpTime;
private _rconuptime = call MPServer_fnc_rcon_getUpTime;

while {true} do 
{
	private _timeRestart = [life_var_rcon_nextRestart] call MPServer_fnc_util_getRemainingTime;

	//--- Main events
	if(_serveruptime > 0 && _rconuptime > 0)then
	{ 
		//--- Restart event (1min)
		if (_serveruptime mod 1 isEqualTo 0) then
		{
			//--- Needs unlocked
			if (life_var_rcon_RestartMode isEqualTo 0 && _rconlocked) then{
				"#unlock" call MPServer_fnc_rcon_sendCommand;
				_rconlocked = false;
				"Lock Event: server unlocked and accepting players!" call MPServer_fnc_rcon_systemlog;
			};

			//--- Realtime
			if(_realtime isNotEqualTo life_var_rcon_RealTime)then{
				life_var_rcon_RealTime = _realtime;
				publicVariable "life_var_rcon_RealTime";
			};

			//--- Uptime
			if(life_var_rcon_upTime isNotEqualTo _rconuptime)then{
				life_var_rcon_upTime = _rconuptime;
				publicVariable "life_var_rcon_upTime";
			};

			//--- Restart time
			if(_timeRestart isNotEqualTo life_var_rcon_RestartTime)then{
				life_var_rcon_RestartTime = _timeRestart;
				publicVariable "life_var_rcon_RestartTime";
			};
			
			if(_timeRestart isNotEqualTo -1)then
			{
				//--- Warning messages
				if (typeName life_var_rcon_RestartMessages isEqualTo "ARRAY") then { 
					if !(life_var_rcon_RestartMessages isEqualTo []) then 
					{
						private _timeRestart_hh_mm = _timeRestart call _mins2hrsmins;
						private _timeRestart_message = format["Next %1 In: %2h %3min",(if(_rconshutdown)then{'Shutdown'}else{'Restart'}),_timeRestart_hh_mm#0,_timeRestart_hh_mm#1];

						{ 
							if (_timeRestart < _x) then {
								format["Server is going to restart in %1 min! Log out before the restart to prevent gear loss.", _x] remoteExec ["hint",-2]; 
								format["Server is going to restart in %1!", _timeRestart_message] call MPServer_fnc_rcon_sendBroadcast;
								format["Restart Event: Warnings for %1min sent",_x] call MPServer_fnc_rcon_systemlog;
								life_var_rcon_RestartMessages deleteAt _forEachIndex;
							};
						} forEach life_var_rcon_RestartMessages;
					};
				};

				//--- Auto lock, kick & restart
				if (_timeRestart < life_var_rcon_LockTime) then 
				{
					//--- Auto Lock
					if (!life_var_rcon_serverLocked AND life_var_rcon_RestartMode == 0) then {
						[] remoteExec ["MPClient_fnc_updatePlayerData",-2];
						"#lock" call MPServer_fnc_rcon_sendCommand;
						"Lock Event: Server locked for restart" call MPServer_fnc_rcon_systemlog;
						"You will be kicked off the server due to a restart." remoteExec ["hint",-2]; 
						"Server locked, You will be kicked soon" call MPServer_fnc_rcon_sendBroadcast;
						life_var_rcon_RestartMode = 0.5;
						[]spawn{
							sleep 45;
							life_var_rcon_RestartMode = 1;
							publicVariable "life_var_rcon_RestartMode";
						};
					};

					//--- Auto kick
					if (_timeRestart < life_var_rcon_KickTime AND life_var_rcon_RestartMode == 1) then { 
						life_var_rcon_RestartMode = 2; 
						publicVariable "life_var_rcon_RestartMode";
						[] call MPServer_fnc_rcon_kickAll;
						"Kick Event: Everyone kicked for restart" call MPServer_fnc_rcon_systemlog;  
					};

					if(_realtime isEqualTo life_var_rcon_nextRestart AND life_var_rcon_RestartMode == 2)then{
						life_var_rcon_RestartMode = 3; 
						publicVariable "life_var_rcon_RestartMode";
						if(_rconshutdown)then{
							'#shutdown' call MPServer_fnc_rcon_sendCommand;
						}else{
							'#restart' call MPServer_fnc_rcon_sendCommand;
						};
					}; 
				};
			};
		};

		//--- unlocked
		if(!_rconlocked)then
		{
			//--- Heartbeat event (3min)
			if (_rconuptime mod 3 isEqualTo 0) then { 
				private _time_mmhh = _rconuptime call _mins2hrsmins;
				_heartbeat = _heartbeat + 1;
				format["Events heartbeat#%1, Thread Still Active - RCON UPTIME: (%2h %3min) %4",_heartbeat,_time_mmhh#0,_time_mmhh#1,_timeRestart_message] call MPServer_fnc_rcon_systemlog; 
			};
			
			//--- Reload bans event (15mins)
			if (_serveruptime mod 15 isEqualTo 0) then {
				"#beserver loadBans" call MPServer_fnc_rcon_sendCommand;
			};

			//---
			if (_serveruptime mod 30 isEqualTo 0) then {
				_timeRestart_message call MPServer_fnc_rcon_sendBroadcast; 
			}; 

			//--- messages event
			if(count life_var_rcon_FriendlyMessages > 0)then{
				{
					_x params ["_n","_messages"];
					if(_serveruptime mod _n isEqualTo 0)then{
						{
							if(count life_var_rcon_messagequeue < 10)then{
								_x call MPServer_fnc_rcon_sendBroadcast;
							};
						} forEach (_messages call BIS_fnc_arrayShuffle);
					};
				} forEach (life_var_rcon_FriendlyMessages call BIS_fnc_arrayShuffle);
			};
		};
	};
 
	
	sleep 60;
};