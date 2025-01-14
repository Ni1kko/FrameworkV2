#include "\life_backend\serverDefines.hpp"
/*
	## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
*/


RUN_DEDI_SERVER_ONLY;
FORCE_SUSPEND("MPServer_fnc_antihack_initialize");
AH_CHECK("life_var_antihack_loaded");

//-- Wait for Rcon startup 
waitUntil {!isNil "life_var_rcon_passwordOK"};
AH_BAN_REMOTE_EXECUTED("MPServer_fnc_antihack_initialize");

//--
["Starting AntiHack!"] call MPServer_fnc_antihack_systemlog;
life_var_antihack_loaded = false;
life_var_antihack_networkReady = false;
life_var_antihack_logs = [];
JxMxE_PublishVehicle = compileFinal str(false);

try {
	private _config = (configFile >> "CfgAntiHack");
	private _admins = call MPServer_fnc_antihack_getAdmins;
	private _rconReady = life_var_rcon_passwordOK;
	private _memoryhacks_client = [];
	private _memoryhacks_server = [];
	private _weaponclasses = [];
	private _weaponattachments = [];
	private _vehicleclasses = [];
	private _uniformclasses = [];
	private _headgearclasses = [];
	private _gogglesclasses = [];
	private _vestclasses = [];
	private _backpacksclasses = [];

	//--- Log RCON state
	[format["RCON Functions %1!",["Disabled, BANS will not work","Enabled"] select _rconReady]] call MPServer_fnc_antihack_systemlog;

	//--- Get Config
	if(!isClass _config) throw "Config not found";
	private _dbLogs = getNumber(_config >> "dblogs") isEqualTo 1;
	private _checkrecoil = getNumber(_config >> "checkrecoil") isEqualTo 1;
	private _checkspeed = getNumber(_config >> "checkspeed") isEqualTo 1;
	private _checkdamage = getNumber(_config >> "checkdamage") isEqualTo 1;
	private _checkHidden = getNumber(_config >> "checkHidden") isEqualTo 1;
	private _checksway = getNumber(_config >> "checksway") isEqualTo 1;
	private _checkmapEH = getNumber(_config >> "checkmapEH") isEqualTo 1;
	private _checkteleport = getNumber(_config >> "checkteleport") isEqualTo 1;
	private _checkvehicle = getNumber(_config >> "checkvehicle") isEqualTo 1;
	private _checkvehicleweapon = getNumber(_config >> "checkvehicleweapon") isEqualTo 1; 
	private _checkweapon = getNumber(_config >> "checkweapon") isEqualTo 1;  
	private _checkweaponattachments = getNumber(_config >> "checkweaponattachments") isEqualTo 1; 
	private _checkterraingrid = getNumber(_config >> "checkterraingrid") isEqualTo 1;
	private _checkdetectedmenus = getNumber(_config >> "checkdetectedmenus") isEqualTo 1;
	private _checkdetectedvariables = getNumber(_config >> "checkdetectedvariables") isEqualTo 1;
	private _checknamebadchars = getNumber(_config >> "checknamebadchars") isEqualTo 1;
	private _checknameblacklist = getNumber(_config >> "checknameblacklist") isEqualTo 1;
	private _checklanguage = getNumber(_config >> "checklanguage") isEqualTo 1;
	private _checkmemoryhack = getNumber(_config >> "checkmemoryhack") isEqualTo 1;
	private _interuptinfo = getNumber(_config >> "use_interuptinfo") isEqualTo 1;
	private _checkgear = getNumber(_config >> "checkgear") isEqualTo 1;
	private _checkuniform = getNumber(_config >> "checkuniform") isEqualTo 1;
	private _checkheadgear = getNumber(_config >> "checkheadgear") isEqualTo 1;
	private _checkgoggles = getNumber(_config >> "checkgoggles") isEqualTo 1;
	private _checkvests = getNumber(_config >> "checkvests") isEqualTo 1;
	private _checkbackpacks = getNumber(_config >> "checkbackpacks") isEqualTo 1;
	private _serverlanguage = getText(_config >> "serverlanguage");
	private _nameblacklist = getArray(_config >> "nameblacklist");
	private _detectedvariables = getArray(_config >> "detectedvariables");
	private _detectedmenus = getArray(_config >> "detectedmenus");
	private _badmenus = getArray(_config >> "badmenus");
	private _detectedstrings = getArray(_config >> "detectedstrings");
	private _vehiclewhitelist = getArray(_config >> "vehiclewhitelist");
	private _weaponwhitelist = getArray(_config >> "weaponwhitelist");
	private _weaponattacmentwhitelist = getArray(_config >> "weaponattacmentwhitelist");
	private _uniformwhitelist = getArray(_config >> "uniformwhitelist");
	private _headgearwhitelist = getArray(_config >> "headgearwhitelist");
	private _goggleswhitelist = getArray(_config >> "goggleswhitelist");
	private _vestwhitelist = getArray(_config >> "vestwhitelist");
	private _backpackwhitelist = getArray(_config >> "backpackwhitelist");
	
	//--- Add admin menu to bad menus (Prevents non admins opening menu)
	_badmenus pushBackUnique (getNumber(missionConfigFile >> "RscDisplayAdminMenu" >> "idd"));

	//--- Setup memory hack arrays
	if(_checkmemoryhack)then{
		{
			_memoryhacks_client pushBackUnique _x;
			_memoryhacks_server pushBackUnique (toArray (call compile (_x#0)));
		}forEach [
			["getText(configFile >> 'RscDisplayOptionsVideo' >> 'controls' >> 'G_VideoOptionsControls' >> 'controls' >> 'HideAdvanced' >> 'OnButtonClick')",'RscDisplayOptionsVideo >> HideAdvanced','OnButtonClick'],
			["getText(configFile >> 'RscDisplayOptions' >> 'controls' >> 'BCredits' >> 'OnButtonClick')",'RscDisplayOptions >> BCredits','OnButtonClick'],
			["getText(configFile >> 'RscDisplayOptions' >> 'controls' >> 'ButtonCancel' >> 'OnButtonClick')",'RscDisplayOptions >> ButtonCancel','OnButtonClick'],
			["getText(configFile >> 'RscDisplayOptions' >> 'controls' >> 'ButtonCancel' >> 'action')",'RscDisplayOptions >> ButtonCancel','action'],
			["getText(configFile >> 'RscDisplayOptions' >> 'controls' >> 'BGameOptions' >> 'action')",'RscDisplayOptions >> BGameOptions','action'],
			["getText(configFile >> 'RscDisplayOptions' >> 'controls' >> 'BConfigure' >> 'action')",'RscDisplayOptions >> BConfigure','action'],
			["getText(configFile >> 'RscDisplayMPInterrupt' >> 'controls' >>'ButtonAbort' >> 'action')",'RscDisplayMPInterrupt >> ButtonAbort','action'],
			["getText(configFile >> 'RscDisplayMPInterrupt' >> 'controls' >>'ButtonAbort' >> 'OnButtonClick')",'RscDisplayMPInterrupt >> ButtonAbort','OnButtonClick']
		];
	};
	
	//--- Setup allowed vehicles
	if(_checkvehicle)then{
		private _configcfgVehicleTraders = missionConfigFile >> "cfgVehicleTraders";
		if(isClass _configcfgVehicleTraders) then{
			for "_i" from 0 to ((count _configcfgVehicleTraders) -1) do{
				{
					_vehicleclasses pushBackUnique toLower(_x#0);
				}forEach getArray(_configcfgVehicleTraders >> configName (_configcfgVehicleTraders select _i)  >> "vehicles");
			};
			{
				_vehicleclasses pushBackUnique toLower _x;
			}forEach _vehiclewhitelist;
		}else{
			_checkvehicle = false;
		};
	};

	//--- Setup allowed weapons
	if(_checkweapon)then{
		private _configWeaponShops = missionConfigFile >> "cfgWeaponShops";
		if(isClass _configWeaponShops) then{
			for "_i" from 0 to ((count _configWeaponShops) -1) do{
				{
					_weaponclasses pushBackUnique toLower(_x#0);
				}forEach getArray(_configWeaponShops >> configName (_configWeaponShops select _i)  >> "items");
				
				//--- Setup allowed weapon attachments
				if(_checkweaponattachments)then{
					{
						_weaponattachments pushBackUnique toLower(_x#0);
					}forEach getArray(_configWeaponShops >> configName (_configWeaponShops select _i)  >> "accs");
				};
			};
			{_weaponclasses pushBackUnique toLower _x}forEach _weaponwhitelist;
			if(_checkweaponattachments)then{
				{_weaponattachments pushBackUnique toLower _x}forEach _weaponattacmentwhitelist;
			};
		}else{
			_checkweapon = false;
		};

		private _configLoadouts = missionConfigFile >> "cfgDefaultLoadouts";
		if(isClass _configLoadouts) then{
			for "_i" from 0 to ((count _configLoadouts) -1) do{
				{
					_weaponclasses pushBackUnique toLower(_x#0);
				}forEach getArray(_configLoadouts >> configName (_configLoadouts select _i)  >> "weapon"); 
			};
		}else{
			_checkweapon = false;
		};
	};

	//--- Setup allowed gear
	if(_checkgear)then{
		private _configClothing = missionConfigFile >> "cfgClothing";
		if(isClass _configClothing) then{
			//--- Allowed uniforms
			if(_checkuniform)then{
				for "_i" from 0 to ((count _configClothing) -1) do{
					{
						_uniformclasses pushBackUnique toLower(_x#0);
					}forEach getArray(_configClothing >> configName (_configClothing select _i)  >> "uniforms"); 
				};
				{_uniformclasses pushBackUnique toLower _x}forEach _uniformwhitelist;
			};
			//--- Allowed headgear
			if(_checkheadgear)then{
				for "_i" from 0 to ((count _configClothing) -1) do{
					{
						_headgearclasses pushBackUnique toLower(_x#0);
					}forEach getArray(_configClothing >> configName (_configClothing select _i)  >> "headgear"); 
				};
				{_headgearclasses pushBackUnique toLower _x}forEach _headgearwhitelist;
			};
			//--- Allowed goggles
			if(_checkgoggles)then{
				for "_i" from 0 to ((count _configClothing) -1) do{
					{
						_gogglesclasses pushBackUnique toLower(_x#0);
					}forEach getArray(_configClothing >> configName (_configClothing select _i)  >> "goggles"); 
				};
				{_gogglesclasses pushBackUnique toLower _x}forEach _goggleswhitelist;
			};
			//--- Allowed vests
			if(_checkvests)then{
				for "_i" from 0 to ((count _configClothing) -1) do{
					{
						_vestclasses pushBackUnique toLower(_x#0);
					}forEach getArray(_configClothing >> configName (_configClothing select _i)  >> "vests"); 
				};
				{_vestclasses pushBackUnique toLower _x}forEach _vestwhitelist;
			};
			//--- Allowed backpacks
			if(_checkbackpacks)then{
				for "_i" from 0 to ((count _configClothing) -1) do{
					{
						_backpacksclasses pushBackUnique toLower(_x#0);
					}forEach getArray(_configClothing >> configName (_configClothing select _i)  >> "backpacks"); 
				};
				{_backpacksclasses pushBackUnique toLower _x}forEach _backpackwhitelist;
			};
		}else{
			_checkgear = false;
		};

		private _configLoadouts = missionConfigFile >> "cfgDefaultLoadouts";
		if(isClass _configLoadouts) then{
			//--- Allowed uniforms
			if(_checkuniform)then{
				for "_i" from 0 to ((count _configLoadouts) -1) do{
					{
						_uniformclasses pushBackUnique toLower(_x#0);
					}forEach getArray(_configLoadouts >> configName (_configLoadouts select _i)  >> "uniform"); 
				};
			};
			//--- Allowed headgear
			if(_checkheadgear)then{
				for "_i" from 0 to ((count _configLoadouts) -1) do{
					{
						_headgearclasses pushBackUnique toLower(_x#0);
					}forEach getArray(_configLoadouts >> configName (_configLoadouts select _i)  >> "headgear"); 
				};
			};
			//--- Allowed vests
			if(_checkvests)then{
				for "_i" from 0 to ((count _configLoadouts) -1) do{
					{
						_vestclasses pushBackUnique toLower(_x#0);
					}forEach getArray(_configLoadouts >> configName (_configLoadouts select _i)  >> "vest"); 
				};
			};
			//--- Allowed backpacks
			if(_checkbackpacks)then{
				for "_i" from 0 to ((count _configLoadouts) -1) do{
					{
						_backpacksclasses pushBackUnique toLower(_x#0);
					}forEach getArray(_configLoadouts >> configName (_configLoadouts select _i)  >> "backpack"); 
				};
			};
		}else{
			_checkgear = false;
		};
	};
	
	//--- Wait for database system to ready up
	waitUntil {isFinal "extdb_var_database_key"};
	
	//--- Load logs
	if(_dbLogs)then{
		private _logs = ["READ", "antihack_logs",[["Type","log","steamID"],[]],false] call MPServer_fnc_database_request;
		{
			life_var_antihack_logs pushBackUnique _x;
		}forEach _logs;
	};
	publicVariable "life_var_antihack_logs";

	//--- random vars ref
	private _rndvars = [
		"_rnd_ahvar",
		"_rnd_sysvar",
		"_rnd_hcvar",
		"_rnd_playersvar",
		"_rnd_useRcon",
		"_rnd_admins",
		"_rnd_isadmin",
		"_rnd_adminlvl",
		"_rnd_steamID",
		"_rnd_netID",
		"_rnd_netVar",
		"_rnd_threadone",
		"_rnd_threadtwo",
		"_rnd_threadthree",
		"_rnd_threadfour",
		"_rnd_threadfive",
		"_rnd_threadtwo_one",
		"_rnd_threadinterupt",
		"_rnd_threadtwo_two",
		"_rnd_threadthree_gvars",
		"_rnd_threadthree_objvars",
		"_rnd_threadthree_pvars",
		"_rnd_threadthree_uivars",
		"_rnd_codeone",
		"_rnd_codetwo",
		"_rnd_sendreq",
		"_rnd_kickme",
		"_rnd_banme",
		"_rnd_logme",
		"_rnd_mins2hrsmins",
		"_rnd_vehicleclasses",
		"_rnd_weaponclasses",
		"_rnd_weaponattachments",
		"_rnd_admincode",
		"_rnd_adminvehiclevar",
		"_rnd_masterScheduleThread",
		"_rnd_masterScheduleAH"
	];

	//--- create random vars
	if(isNil "MPServer_fnc_util_randomString") throw "Random string function not found";
	private _tempvars = [];
	_tempvars resize (count _rndvars);
	_tempvars params (_rndvars apply {private _ret=[_x,call MPServer_fnc_util_randomString];[format["`%1` => `%2`",_ret#0,_ret#1]]call MPServer_fnc_antihack_systemlog;_ret});
	_tempvars =nil;

	{_detectedstrings pushBackUnique _x} forEach _rndvars;
	_detectedvariables pushBackUnique _rnd_admincode;
	
	//--- Keeps scheduler thread running. TODO: Move into a fsm
	[_rnd_masterScheduleThread,_rnd_masterScheduleAH] spawn {
		scriptName 'MPServer_fnc_masterScheduleAH';
		while{true}do{
			private _threadName = param [0, ""];
			private _AHScheduleVar = param [1, ""];
			private _thread = [_AHScheduleVar] spawn MPServer_fnc_masterSchedule;
			serverNamespace setVariable [_threadName, _thread];
			waitUntil {
				private _thread = serverNamespace getVariable [_threadName, scriptNull];
				if(typeName _thread isNotEqualTo "SCRIPT")exitWith{true};
				if(isNull _thread)exitWith{true};
				if(scriptDone _thread)exitWith{true};
				sleep 30;
				false
			};
			terminate _thread;
			serverNamespace setVariable [_threadName, scriptNull];
			["Master Scheduler Thread Terminated, Possible hacker online!"] call MPServer_fnc_antihack_systemlog;
			private _startupQueue = call life_var_severSchedulerStartUpQueue;
			if(count life_var_severScheduler < count _startupQueue)then{
				{life_var_severScheduler pushBack _x}forEach _startupQueue;
			};
		};
	};
	
	//--- Junk Code (Basic TODO: add fake code blocks and more random values)
	private _junkCode =  {
		private _junk = "";
		private _vars = [];
		_vars resize (random [10,80,250]);
		{
		   _junk = _junk + format["
		   %1=%2;",_x, selectRandom [true,false,[],random(999),serverTime]];
		} forEach (_vars apply {call MPServer_fnc_util_randomString});
		_junk
	};

	//--- antihack expression
	private _antihackclient = "
		scriptName 'MPClient_fnc_protectionScript';
		if(!isNull(missionNamespace getVariable ['"+_rnd_threadtwo+"',scriptNull]))exitWith{};
		if(isFinal '"+_rnd_kickme+"')then{private _log = 'System ran twice, possible hacker'; _log call "+_rnd_kickme+";['HACK',_log] call "+_rnd_logme+";};
		if(isFinal '"+_rnd_banme+"')then{private _log = 'System ran twice, possible hacker'; _log call "+_rnd_banme+";['HACK',_log] call "+_rnd_logme+";};
		"+(call _junkCode)+"
		"+_rnd_useRcon+" = " + str _rconReady + ";
		"+_rnd_admins+" = " +  str _admins +";
		"+(call _junkCode)+"
		waitUntil {!isNull player && {getClientStateNumber >= 8}};
		"+(call _junkCode)+"
		"+_rnd_steamID+" =   getPlayerUID player;
		"+_rnd_netID+" =     netId player;
		"+_rnd_adminlvl+" =  compileFinal ""private _lvl = 0;{if("+_rnd_steamID+" isEqualTo _x#1)exitWith{_lvl = _x#0;}}forEach "+_rnd_admins+";_lvl"";
		"+_rnd_isadmin+" =   (call "+_rnd_adminlvl+") > 0;
		"+_rnd_sendreq+" =   compileFinal """+ _rnd_netVar + " = [_this#0,"+_rnd_steamID+",_this#1];publicVariable '" + _rnd_netVar + "';"";
		"+_rnd_kickme+" =    compileFinal ""if("+_rnd_useRcon +")then{['kick',_this] call "+_rnd_sendreq+";}else{endMission 'END1';};"";
		"+_rnd_banme+" =     compileFinal ""if("+_rnd_useRcon +")then{['ban',_this] call "+_rnd_sendreq+"}else{_this call "+_rnd_kickme+";};"";
		"+_rnd_logme+" =     compileFinal ""['log',['ANTIHACK',_this#0,_this#1]] call "+_rnd_sendreq+";"";
		"+(call _junkCode)+"
		"+_rnd_vehicleclasses+" = "+str _vehicleclasses+";
		"+_rnd_weaponclasses+" = "+str _weaponclasses+";
		"+_rnd_weaponattachments+" = "+str _weaponattachments+";

		"+_rnd_mins2hrsmins+" = compile ""
			scriptName 'rnd_mins2hrsmins';
			private _hours = floor((_this * 60 ) / 60 / 60);
			private _minutes = (((_this * 60 ) / 60 / 60) - _hours);
			if(_minutes == 0)then{_minutes = 0.0001;};
			_minutes = round(_minutes * 60);
			[_hours,_minutes]
		"";
		 
		"+_rnd_codeone+" =  compileFinal ""
			scriptName 'MPClient_fnc_validateScript';
			"+(call _junkCode)+"
			if((call "+_rnd_adminlvl+") >= 3)exitWith{};
			"+(call _junkCode)+" 
			";
			if(_checkrecoil)then{
				_antihackclient = _antihackclient + "
					private _recoil = unitRecoilCoefficient player;
				";
			};
			if(_checksway)then{ 
				_antihackclient = _antihackclient + "
					private _sway = getCustomAimCoef player;
				";
			};
			if(_checkmapEH)then{ 
				_antihackclient = _antihackclient + "
					private _mapClickEH = -1;
					private _eh = -1;
				";
			};
			_antihackclient = _antihackclient + "	
			"+(call _junkCode)+"
			while {true} do {";
				if(_checkmapEH)then{ 
					_antihackclient = _antihackclient + "
						_eh = addMissionEventHandler['MapSingleClick', {}];
						if (_eh > _mapClickEH) then {
							if (_mapClickEH == -1) then {
								_mapClickEH = _eh;
							}else{
								private _log = format['EventHandlers Changed! - %1, should be %2 | MapSingleClick Cheat',_eh,_mapClickEH]; 
								_log call "+_rnd_banme+";
								['HACK',_log] call "+_rnd_logme+";
							};
						};
						removeAllMissionEventHandlers 'MapSingleClick';
					";
				};
				if(_checkterraingrid)then{
					_antihackclient = _antihackclient + " 
						if(getTerrainGrid >= 50) then {
							private _log = format['No Grass! TerrainGrid set to %1 | No Grass Cheat',getTerrainGrid]; 
							_log call "+_rnd_banme+";
							['HACK',_log] call "+_rnd_logme+";
						};
					";
				};
				if(_checkrecoil)then{ 
					_antihackclient = _antihackclient + "
						if(unitRecoilCoefficient player != _recoil)then{
							if(unitRecoilCoefficient player == 0) then {
								private _log = 'Weapon Recoil Disabled! | No Recoil Cheat'; 
								_log call "+_rnd_banme+";
								['HACK',_log] call "+_rnd_logme+";
							}else{
								if(unitRecoilCoefficient player != 1)then{
									private _log = format['Recoil Changed! %1 Should Be  %2 | No Recoil Cheat',unitRecoilCoefficient player,_recoil]; 
									_log call "+_rnd_banme+";
									['HACK',_log] call "+_rnd_logme+";
								};
							};
						};
					";
				}; 
				if(_checkspeed)then{ 
					_antihackclient = _antihackclient + "
						_speedCount = 0; 
						if (isNull objectParent player) then {
							_speedCount = if (speed player > 30) then {_speedCount + 1} else {0};
							if (_speedCount > 10) then {
								private _log = format['Moved Too Fast! - Moving at %1 on foot for over 5 seconds | Speed Hack',speed player]; 
								_log call "+_rnd_banme+";
								['HACK',_log] call "+_rnd_logme+";
							};
						}else{
							_speedCount = 0;
						}; 
					";
				}; 
				if(_checkdamage)then{ 
					_antihackclient = _antihackclient + "
						if(!isDamageAllowed player) then { 
							private _log = format['Invincibility! AllowDamage set to %1',isDamageAllowed player]; 
							_log call "+_rnd_banme+";
							['HACK',_log] call "+_rnd_logme+";
						}else{
							if((vehicle player) isNotEqualTo player AND {(driver (vehicle player)) isEqualTo player AND {not(isDamageAllowed (vehicle player))}}) then { 
								private _log = format['Vehicle Invincibility! AllowDamage set to %1',isDamageAllowed player]; 
								_log call "+_rnd_banme+";
								['HACK',_log] call "+_rnd_logme+";
							};
						};
					";
				}; 
				if(_checkHidden)then{ 
					_antihackclient = _antihackclient + "
						if(isObjectHidden player AND not(player getVariable ['life_var_hidden',false])) then { 
							private _log = format['Invisibility! hideObject set to %1',isObjectHidden player]; 
							_log call "+_rnd_banme+";
							['HACK',_log] call "+_rnd_logme+";
						}else{
							if((vehicle player) isNotEqualTo player AND {isObjectHidden (vehicle player) AND not((vehicle player) getVariable ['life_var_hidden',false])}) then { 
								private _log = format['Vehicle Invisibility! hideObject set to %1',isObjectHidden player]; 
								_log call "+_rnd_banme+";
								['HACK',_log] call "+_rnd_logme+";
							};
						};
					";
				}; 
				if(_checksway)then{ 
					_antihackclient = _antihackclient + "
						if(getCustomAimCoef player != _sway)then{
							if(getCustomAimCoef player == 0) then {
								private _log = 'Weapon Sway Disabled!'; 
								_log call "+_rnd_banme+";
								['HACK',_log] call "+_rnd_logme+";
							}else{
								if(getCustomAimCoef player != 1)then{
									private _log = format['WeaponSway Changed! %1 Should Be %2',getCustomAimCoef player,_sway]; 
									_log call "+_rnd_banme+";
									['HACK',_log] call "+_rnd_logme+";
								};
							};
						};
					";
				};
				if(_checkvehicle) then {
					_antihackclient = _antihackclient + "
						if((call "+_rnd_adminlvl+") < 4)then{
							private _vehicle = vehicle player;
							if(_vehicle != player) then {
								private _uuid = _vehicle getVariable ['oUUID',''];
								private _check = _vehicle getVariable ['"+_rnd_adminvehiclevar+"',false];
								if(!_check)then{
									if(_uuid isEqualTo '' || !(toLower(typeOf _vehicle) in "+_rnd_vehicleclasses+")) then {
										[[netId _vehicle],{private _vehicle = objectFromNetId(param[0,'']);deleteVehicle _vehicle;}] remoteExecCall ['call',2];
										private _log = format['Bad vehicle: %1',typeOf _vehicle]; 
										_log call "+_rnd_banme+";
										['HACK',_log] call "+_rnd_logme+";
									};
								}else{
									if(call "+_rnd_adminlvl+" < 1)then{ 
										systemChat 'Admin Vehicle, No accses allowed';
										player moveOut _vehicle;
										_vehicle lock 2;
									};
								};
							};
						};
					";
				};
				if(_checkweapon) then {
					_antihackclient = _antihackclient + "
						private _weapon = currentWeapon player;
						if(_weapon isNotEqualTo '')then{
							if !(toLower _weapon in "+_rnd_weaponclasses+") then {
								private _log = format['Bad weapon: %1',_weapon]; 
								_log call "+_rnd_banme+";
								['HACK',_log] call "+_rnd_logme+";
							};
						};
					";
					if(_checkweaponattachments)then{
						_antihackclient = _antihackclient + "
							{
								if(_x isNotEqualTo '')then{
									private _attachments = player weaponAccessories _x;
									if(count _attachments > 0)then{
										{
											private _attachment = _x;
											if(_attachment isNotEqualTo '')then{
												if !(toLower _attachment in "+_rnd_weaponattachments+") then {
													private _log = format['Bad weapon attachment: %1',_x]; 
													_log call "+_rnd_banme+";
													['HACK',_log] call "+_rnd_logme+";
												};	
											};
										}forEach _attachments;
									};
								};
							} forEach [primaryWeapon player,secondaryWeapon player,handgunWeapon player];
						";
					};
				};
				_antihackclient = _antihackclient + "
				sleep random[0.5,1,1.5];
			};
		"";";

		if(_interuptinfo)then{
			_antihackclient = _antihackclient + "
				"+_rnd_codetwo+" = compileFinal ""
					scriptName 'MPClient_fnc_helperScript';
					"+(call _junkCode)+"

					while{true}do{
						waitUntil{!(isNull (findDisplay 49))};
						private _text = '';";
						_antihackclient = _antihackclient + "
						waitUntil{ 
							private _RestartTime = life_var_rcon_RestartTime;
							private _players = count(allPlayers - entities 'HeadlessClient_F');
							private _text = format['%1 Life AntiCheat | Total Players Online (%3/%4) | Guid: (%2)',worldName,call(missionNamespace getVariable ['life_BEGuid',{'Loading...'}]), _players,((playableSlotsNumber west) + (playableSlotsNumber independent) + (playableSlotsNumber civilian)  + (playableSlotsNumber east) + 1)];";
							if(_rconReady)then
							{ 
								_antihackclient = _antihackclient + " 
									if(_RestartTime > 0)then{
										private _timeRestart = _RestartTime call "+_rnd_mins2hrsmins+";  
										if((_timeRestart#0) > 0)then{
											_text = format['%1 | Server Restart In: %2h %3mins',_text,_timeRestart#0,_timeRestart#1];
										}else{
											_text = format['%1 | Server Restart In: %2mins',_text,_timeRestart#1];
										};
									};
								";
							};
							_antihackclient = _antihackclient + "
							((findDisplay 49) displayCtrl 120) ctrlSetText _text;
							isNull (findDisplay 49) || (life_var_rcon_RestartTime isNotEqualTo _RestartTime) || (_players isNotEqualTo count(allPlayers - entities 'HeadlessClient_F'))
						};
					};
				"";
			";
		};

		_antihackclient = _antihackclient + "

		"+_rnd_threadone+" = [] spawn 
		{
			scriptName 'MPClient_fnc_helperScript1';
			if((call "+_rnd_adminlvl+") >= 5)exitWith{};
			"+(call _junkCode)+"";

			if(_checkdetectedmenus)then{
				_antihackclient = _antihackclient + "
					terminate (missionNamespace getVariable ['"+_rnd_threadtwo_one+"',scriptNull]);
					"+_rnd_threadtwo_one+" = [] spawn{
						if((call "+_rnd_adminlvl+") < 10)then{
							waitUntil{(!isNull (findDisplay 49)) && (!isNull (findDisplay 602))};  
							(findDisplay 49) closeDisplay 2; (findDisplay 602) closeDisplay 2;
							private _log = 'Opened Esacpe & Inventory Menus | Possible Inventory Glitch'; 
							_log call "+_rnd_kickme+";
							['HACK',_log] call "+_rnd_logme+";
						};
					};
				";
			};

			_antihackclient = _antihackclient + "
			while {true} do {";
				if(_checkvehicleweapon)then{ 
					_antihackclient = _antihackclient + "
						if(vehicle player != player) then {
							if(local (vehicle player)) then {
								_vehWeps = getArray(configFile >> 'cfgVehicles' >> typeof (vehicle player) >> 'weapons');
								_hasWeps = (weapons (vehicle player));
								if !(_vehWeps isEqualTo _hasWeps) then {
									deleteVehicle (vehicle player);
									private _log = format['Bad Vehicle Weapons: (%1) Should have: (%2)',_hasWeps,_vehWeps]; 
									_log call "+_rnd_banme+";
									['HACK',_log] call "+_rnd_logme+";
								};
							};
						}; 
					";
				};
				if(_checkmemoryhack)then{
					_antihackclient = _antihackclient + "
						{
							private _currentHM = "+str _memoryhacks_client+"#_forEachIndex;
							private _clientHM = toArray(call compile (_currentHM#0));
							if(_clientHM isNotEqualTo _x)then{
								private _log = format['Memoryhack %1 %2 changed: %3, %4', _currentHM#1, _currentHM#2, toString _clientHM, toString _x]; 
								_log call "+_rnd_banme+";
								['HACK',_log] call "+_rnd_logme+";
								['ah'] call MPClient_fnc_clientCrash;
							};
						} forEach "+str _memoryhacks_server+";
					";
				};
				_antihackclient = _antihackclient + "
				sleep (random [1,2,5]);
			};
		};

		"+_rnd_threadtwo+" = [] spawn 
		{
			scriptName 'MPClient_fnc_helperScript2';
			if("+_rnd_isadmin+")then{};
			"+(call _junkCode)+"

			terminate (missionNamespace getVariable ['"+_rnd_threadinterupt+"',scriptNull]);
			"+_rnd_ahvar+" = ['"+_rnd_playersvar+"',"+_rnd_netID+", ['"+_rnd_threadtwo_two+"',"+_rnd_codeone+"]];";
			
			if(_checklanguage)then{ 
				_antihackclient = _antihackclient + "
					"+(call _junkCode)+"
					if !("+_rnd_isadmin+")then{
						if (toLower(language) isNotEqualTo toLower("+_serverlanguage+"))then{ 
							_log = format['Bad Language! %1 Is Not Allowed',language];
							_log call "+_rnd_kickme+";
							['KICK',_log] call "+_rnd_logme+";
						};
					};
				";
			};
			if(_checknamebadchars)then{
				_antihackclient = _antihackclient + "
					"+(call _junkCode)+"
					if !("+_rnd_isadmin+")then{
						_chars = [];
						_lang =	 toLower(language);
						_badchar = false;
						"+(call _junkCode)+"
						if (_lang in ['english','german','italian','spanish'])then{
							_chars = ['Ă','Å','Ć','Č','Ċ','Đ','È','Ę','Ğ','Ģ','Ħ','Ï','Ĩ','Ĵ','ĵ','ĸ','Ŀ','Ľ','Ņ','Ŋ','Ő','Ô','Þ','Ř','Ş','Ţ','Ů','Û','Ŵ','Ŷ','Ż'];
						}else{
							_chars = switch(_lang)do{
								case 'russian': {['Ă','Å','Ć','Č','Ċ','Đ','È','Ę','Ğ','Ģ','Ħ','Ï','Ĩ','Ĵ','ĵ','Ŀ','Ľ','Ņ','Ŋ','Ő','Ô','Þ','Ř','Ş','Ţ','Ů','Û','Ŵ','Ŷ','Ż']};
								case 'french':  {['Ă','Å','Ć','Č','Ċ','Đ','Ę','Ğ','Ģ','Ħ','Ĩ','Ĵ','ĵ','ĸ','Ŀ','Ľ','Ņ','Ŋ','Ő','Þ','Ř','Ş','Ţ','Ů','Ŵ','Ŷ','Ż']}; 
								case 'polish':  {['Ă','Å','Ć','Č','Ċ','Đ','È','Ę','Ğ','Ģ','Ħ','Ï','Ĩ','Ĵ','ĵ','Ŀ','Ľ','Ņ','Ŋ','Ő','Ô','Þ','Ř','Ş','Ţ','Ů','Û','Ŵ','Ŷ']}; 
								case 'czech':   {['Ă','Å','Ć','Ċ','Đ','È','Ę','Ğ','Ģ','Ħ','Ï','Ĩ','Ĵ','ĵ','ĸ','Ŀ','Ľ','Ņ','Ŋ','Ő','Ô','Þ','Ş','Ţ','Û','Ŵ','Ŷ','Ż']};    
								default {[]};
							}; 
						};
						"+(call _junkCode)+"
						{if([_x, profileName,false]call BIS_fnc_inString)exitWith{_badchar = true;}}foreach _chars;
						if(_badchar)then{
							private _log = format['Bad Name! Char: %1 Is Not Allowed',_x];
							_log call "+_rnd_kickme+";
							['KICK',_log] call "+_rnd_logme+";
						};
					};
				";
			};
			if(_checknameblacklist)then{
				_antihackclient = _antihackclient + "
					"+(call _junkCode)+"
						if !("+_rnd_isadmin+")then{
						{
							if([profileName, _x] call BIS_fnc_inString)exitWith{
								private _log = format['Bad Name! %1 Is Not Allowed',_x];
								_log call "+_rnd_kickme+";
								['KICK',_log] call "+_rnd_logme+";
							};
						}forEach "+str _nameblacklist+";
					};
				";
			};
			if(_checkdetectedmenus)then{
				_antihackclient = _antihackclient + "
					if((call "+_rnd_adminlvl+") < 6)then{
						{
							_x spawn {
								scriptName 'MPClient_fnc_cdmenu';
								waitUntil{!isNull (findDisplay _this)};
								private _log = format['Bad Menu: %1',_this];
								_log call "+_rnd_banme+";
								['HACK',_log] call "+_rnd_logme+";
							};
						}forEach " + str _detectedmenus + ";
					};
				";
			};
			if(_checkdetectedvariables)then{
				_antihackclient = _antihackclient + "
					if((call "+_rnd_adminlvl+") < 1)then{
						{
							_x spawn {
								scriptName 'MPClient_fnc_cdvars';
								waitUntil{!isNil _this};
								private _log = format['Bad Var: %1',_this]; 
								_log call "+_rnd_banme+";
								['HACK',_log] call "+_rnd_logme+";
								['ah'] call MPClient_fnc_clientCrash;
								true
							};
						} forEach "+str _detectedvariables+";
					};
				";
			};
			if(_checkteleport)then{
				_antihackclient = _antihackclient + "
					[]spawn{
						if ("+_rnd_isadmin+")exitWith{};
						while {true} do {
							private _checkTime = 5;
							private _oldVehicle = vehicle player;
							private _oldPos = getPosATL _oldVehicle;

							sleep _checkTime;

							private _newVehicle = vehicle player;
							private _newPos = getPosATL _newVehicle;
							if(_oldVehicle isEqualTo _newVehicle) then {
								private _maxSpeed = (30 / 3.6);
								if(_newVehicle != player) then {
									private _topSpeed = getNumber(configfile >> 'CfgVehicles' >> typeOf _newVehicle >> 'maxSpeed');
									_maxSpeed = ((_topSpeed / 3.6) * 1.5);
								};

								private _distance = _oldPos distance _newPos;

								if((_distance > _maxSpeed * _checkTime) && ((player getVariable ['lifeState','']) isEqualTo 'HEALTHY') && (player == (driver _newVehicle)) && local _newVehicle) then {
									if!(player getVariable ['teleported',false]) then {
										private _log = format['Player teleported: moved %1 meters, in %2 seconds! (Max Allowed Speed: %3)',_distance,_checkTime,_maxSpeed]; 
										_log call "+_rnd_banme+";
										['HACK',_log] call "+_rnd_logme+";
									};
								};
							};
						};
					};
				";
			};

			_antihackclient = _antihackclient + "
			systemChat 'Antihack loading!';
			"+_rnd_sysvar+" = "+_rnd_ahvar+";
			"+(call _junkCode)+"
			publicVariable '"+_rnd_sysvar+"';
			waitUntil {isNil {missionNamespace getVariable '"+_rnd_sysvar+"'}};
			[] spawn {
				scriptName 'MPClient_fnc_adminTools';
				if((call "+_rnd_adminlvl+") <= 0)exitWith{false};
				"+(call _junkCode)+"
				waitUntil{!isNil '"+_rnd_admincode+"'};
				["+_rnd_steamID+"] spawn "+_rnd_admincode+";
				true
			};
			"+(call _junkCode)+"
			"+_rnd_ahvar+" = random(99999);
			"+(call _junkCode)+"

			while {true} do 
			{
				sleep 2;";
					if(_interuptinfo)then{
						_antihackclient = _antihackclient + "
							if(isNull (missionNamespace getVariable ['"+_rnd_threadinterupt+"',scriptNull]))then{
								"+_rnd_threadinterupt+" = [] spawn "+_rnd_codetwo+";
							};
						";
					};
					_antihackclient = _antihackclient + "
				sleep 2;
					if(isNil {missionNamespace getVariable '"+_rnd_ahvar+"'})then{
						private _log = '`_rnd_ahvar` nil';
						_log call "+_rnd_banme+";
						['HACK',_log] call "+_rnd_logme+";
					};
				sleep 2;
			};
		};

		"+_rnd_threadthree+" = []spawn 
		{ 
			scriptName 'MPClient_fnc_helperScript3';
			if("+_rnd_isadmin+")exitwith{};
			"+(call _junkCode)+"
			
			{
				_x spawn {
					scriptName 'MPClient_fnc_helperScript3_1';
					"+(call _junkCode)+"
					while {true} do {
						private _display = displayNull;
						waitUntil{
							_display = findDisplay _this;
							!isNull _display
						};
						systemChat format['%1 Life AntiCheat: %2 has been closed.',worldName,str _display];
						['HACK',format['%1 has been closed.',str _display]] call "+_rnd_logme+";
						_display closeDisplay 0;
						closeDialog 0;closeDialog 0;closeDialog 0;
					};
				};	
			}forEach "+str _badmenus+";

			while {true} do {
				waitUntil{!isNull findDisplay 24 && !isNull findDisplay 49};
				private _dynamicText = uiNamespace getvariable ['BIS_dynamicText',displayNull];
				if(!isNull _dynamicText)then {
					private _ctrl = _dynamicText displayctrl 9999;
					private _ctrltext = ctrlText _ctrl;
					if(_ctrltext isNotEqualTo '')then {
						private _log = true;
						{
							if((toLower _ctrltext) find _x > -1)then {
								private _logmsg = format['Hackmenu found: %1 on %2 %3 - %4',_x,ctrlIDD _dynamicText,ctrlIDC _ctrl,_ctrltext]; 
								_logmsg call "+_rnd_banme+";
								['HACK',_logmsg] call "+_rnd_logme+";
								_log = false;
							};
						} forEach "+str _detectedstrings+";
						if(_log)then {
							['INFO',format['Possible Hackmenu found on CTRL: [%1] - TEXT: [%2]',_ctrl, _ctrltext]] call "+_rnd_logme+";
						};
					};
					(findDisplay 24) closeDisplay 0;
					(findDisplay 49) closeDisplay 0;
				};
				sleep 2;
			};
		};

		"+_rnd_threadfour+" = []spawn
		{
			scriptName 'MPClient_fnc_helperScript4';
			if((call "+_rnd_adminlvl+") >= 3)exitWith{}; 
			private _detectedstrings = "+str _detectedstrings+"; 
			private _inittime = diag_tickTime;
			"+(call _junkCode)+"

			while {true} do {
				private _uptime = round((diag_tickTime - _inittime) / 60);
				if(_uptime > 0)then{
					{ 
						private _display = _x;  
						if(!isNull _display)then
						{
							{
								if(!isNull (_display displayCtrl _x))then {
									private _log = format['MenuBasedHack: %1 - %2',_display,_x]; 
									_log call "+_rnd_banme+";
									['HACK',_log] call "+_rnd_logme+";
								};
							} forEach [16030,13163,989187,16100];
							
							{
								private _control = _x;
								if(_uptime mod 1 isEqualTo 0)then{
									private _controltype = ctrlType _control;
									if(_controltype isEqualTo 5)then {
										_size = lbSize _control;
										if(_size > 0)then {
											for '_i' from 0 to (_size-1) do {
												private _lbtxt = _control lbText _i;
												private _txtfilter = toArray _lbtxt;
												_txtfilter = _txtfilter - [94];
												_txtfilter = _txtfilter - [96];
												_txtfilter = _txtfilter - [180];
												private _lowerlbtxt = toLower(toString _txtfilter);
												{
													if(_lowerlbtxt find _x > -1)then {
														private _log = format['BadlbText: %1 FOUND [%2] ON %3 %4',_lbtxt,_x,_display,_control]; 
														_log call "+_rnd_banme+";
														['HACK',_log] call "+_rnd_logme+";
													};
												} forEach _detectedstrings;
											};
										};
									} else {
										if(_controltype isEqualTo 12)then
										{
											private _tvtxt = _control tvText (tvCurSel _control);
											private _txtfilter = toArray _tvtxt;
											_txtfilter = _txtfilter - [94];
											_txtfilter = _txtfilter - [96];
											_txtfilter = _txtfilter - [180];
											private _lowertvtxt = toLower(toString _txtfilter);
											{
												if(_lowertvtxt find _x > -1)then { 
													private _log = format['BadtvText: %1 FOUND [%2] ON %3 %4',_tvtxt,_x,_display,_control]; 
													_log call "+_rnd_banme+";
													['HACK',_log] call "+_rnd_logme+";
												};
											} forEach _detectedstrings;
										} else {
											if!(_controltype in [3,4,8,9,15,42,81,101,102])then{
												private _ctrlTxt = ctrlText _control;
												private _txtfilter = toArray _ctrlTxt;
												_txtfilter = _txtfilter - [94];
												_txtfilter = _txtfilter - [96];
												_txtfilter = _txtfilter - [180];
												private _lowerctrlTxt = toLower(toString _txtfilter);
												{
													if(_lowerctrlTxt find _x > -1)then {
														private _log = format['BadCtrlText: %1 FOUND [%2] ON %3 %4',_ctrlTxt,_x,_display,_control]; 
														_log call "+_rnd_banme+";
														['HACK',_log] call "+_rnd_logme+";
													};
												} forEach _detectedstrings;
											};
										};
									};
								};
							} forEach (allControls _display);
						}; 
					} forEach allDisplays;
					
					sleep 3;
				}else{
					sleep 15;
				};
			};	
		};
		
		"+_rnd_threadfive+" = []spawn
		{
			scriptName 'MPClient_fnc_helperScript5';
			if((call "+_rnd_adminlvl+") >= 4)exitWith{};
			while {true} do {";
				if(_checkgear)then{
					if(_checkuniform)then{
						_antihackclient = _antihackclient + "
							private _uniform = uniform player;
							if(_uniform isNotEqualTo '')then{
								if !(toLower(_uniform) in "+str _uniformclasses+")then{
									private _log = format['Gearhack Bad Uniform: `%1` in not allowed',_uniform]; 
									_log call "+_rnd_banme+";
									['HACK',_log] call "+_rnd_logme+";
								};
							};
						";
					};
					if(_checkheadgear)then{
						_antihackclient = _antihackclient + "
							private _headgear = headgear player;
							if(_headgear isNotEqualTo '')then{
								if !(toLower(_headgear) in "+str _headgearclasses+")then{
									private _log = format['Gearhack Bad Headgear: `%1` in not allowed',_headgear]; 
									_log call "+_rnd_banme+";
									['HACK',_log] call "+_rnd_logme+";
								};
							};
						";
					};
					if(_checkgoggles)then{
						_antihackclient = _antihackclient + "
							private _goggles = goggles player;
							if(_goggles isNotEqualTo '')then{
								if !(toLower(_goggles) in "+str _gogglesclasses+")then{
									private _log = format['Gearhack Bad Goggles: `%1` in not allowed',_goggles]; 
									_log call "+_rnd_banme+";
									['HACK',_log] call "+_rnd_logme+";
								};
							};
						";
					};
					if(_checkvests)then{
						_antihackclient = _antihackclient + "
							private _vest = vest player;
							if (_vest isNotEqualTo '')then{
								if !(toLower(_vest) in "+str _vestclasses+")then{
									private _log = format['Gearhack Bad Vest: `%1` in not allowed',_vest]; 
									_log call "+_rnd_banme+";
									['HACK',_log] call "+_rnd_logme+"; 
								};
							};
						";
					};
					if(_checkbackpacks)then{
						_antihackclient = _antihackclient + "
							private _backpack = backpack player;
							if(_backpack isNotEqualTo '')then{
								if !(toLower(_backpack) in "+str _backpacksclasses+")then{
									private _log = format['Gearhack Bad Backpack: `%1` in not allowed',_backpack]; 
									_log call "+_rnd_banme+";
									['HACK',_log] call "+_rnd_logme+"; 
								};
							};
						";
					};
				};
				_antihackclient = _antihackclient + "
				sleep 3;
			};
		};
		
		"+(call _junkCode)+"
		waitUntil{isNull(missionNamespace getVariable ['"+_rnd_threadtwo+"',scriptNull])};
		private _log = 'Main thread terminated, possible hacker';
		_log call "+_rnd_kickme+";
		['HACK',_log] call "+_rnd_logme+";
	";
	
	//--- something broke with antihackclient expression
	if(isNil "_antihackclient")throw "Failed to load antihack";

	//--- setup network thread
	_antihackclient = [_antihackclient,_rnd_netVar,_rnd_sysvar,_rnd_hcvar] spawn MPServer_fnc_antihack_setupNetwork;
	
	//--- something broke with thread
	if(isNull _antihackclient)throw "Failed to load antihack network";

	life_var_antihack_loaded = true;
	_antihackclient = nil;

	[_admins,_rconReady,_rnd_netVar,_rnd_adminvehiclevar,_rnd_admincode]spawn MPServer_fnc_admin_initialize;
}catch {
	[format["Exception: %1",_exception]] call MPServer_fnc_antihack_systemlog;
	
	life_var_antihack_loaded = false;
};

if(life_var_antihack_loaded)then{
	["System fully initialized!"] call MPServer_fnc_antihack_systemlog;
};

life_var_antihack_loaded