#include "..\..\script_macros.hpp"
/*
	## Nikko Renolds
	## https://github.com/Ni1kko/Framework
*/

params [
    ["_alive", false, [false]],
    ["_position", [], [[]]]
];

private _openSpawnMenu = false;
private _spawnAtPosition = false;

player setVariable ["life_var_teleported",true,true];

if(playerSide in [civilian,east]) then 
{
	switch (true) do 
	{
		//-- Put them back in jail as they logged off in jail.
		case (life_is_arrested): 
		{
			if(life_var_loadingScreenActive) then {
				["Prisioner detected!","You logged off in prision, you will be returned back to jail!"] call MPClient_fnc_setLoadingText; 
				uiSleep(2);
			};  
			life_is_arrested = false;
			[player,true] spawn MPClient_fnc_jail;
        };
		//-- Reset loadout logged off during combat (combat logged).
		case (life_firstSpawn AND not(life_is_alive) AND not(life_is_arrested)): 
		{
            //-- Comabt logged
			if (LIFE_SETTINGS(getNumber,"save_civilian_positionStrict") isEqualTo 1) then {
				if(life_var_loadingScreenActive) then {
					["Combat logged detected!","Your gear and cash have been reset"] call MPClient_fnc_setLoadingText; 
					uiSleep(2);
				};
				[] call MPClient_fnc_startLoadout;
				life_var_cash = 0;
				[0] call MPClient_fnc_updatePartial;
			};

			_openSpawnMenu = true; 
        };
		//-- Spawn them where they logged off.
		default
		{ 
			if _alive then {
				_spawnAtPosition = true;
			} else {
				_openSpawnMenu = true;
			}; 
		};
	};
}else{
    if _alive then { 
		_spawnAtPosition = true;
    } else {
        _openSpawnMenu = true;
    }; 
};

//-- Open spawn menu
if _openSpawnMenu then
{ 
	if(life_var_loadingScreenActive) then {
		[format["%1 Life",worldName],"Loading spawn selection"] call MPClient_fnc_setLoadingText; 
		uiSleep(2);
	};
	private _display = [] call MPClient_fnc_spawnMenu;
	if(life_var_loadingScreenActive) then {endLoadingScreen};
	waitUntil{isNull _display};
}else{
	if _spawnAtPosition then { 
        player setVehiclePosition [_position, [], 0, "CAN_COLLIDE"];
		
		if(life_var_loadingScreenActive) then {
			[format["%1 Life",worldName],"Returning player to last known position"] call MPClient_fnc_setLoadingText; 
			uiSleep(2);
			endLoadingScreen;//Terminate Loading Screen  
		};
	};
};

//-- First spawn
if (life_firstSpawn) then {
    life_firstSpawn = false;
    [] spawn MPClient_fnc_intro; // Intro Cam Script
}else{
    [true] call MPClient_fnc_gui_hook_management;
};

life_is_alive = true;
disableUserInput false; // Let the user have input 
player allowDamage true; // Let the player take damage
5 spawn{uiSleep _this; player setVariable ["life_var_teleported",false,true]};

true