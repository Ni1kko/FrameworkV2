#include "..\..\clientDefines.hpp"
/*
	## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
    ## fn_updatePlayerData.sqf (Client)
*/
 
private _var = format["Sync_%1_Completed_%2",round(random[1000,5000,9999]),round diag_tickTime];

[
    _var,
    player,
    MONEY_CASH,
    MONEY_BANK,
    MONEY_DEBT,
    ([player] call MPClient_fnc_getLicenses),
    ([player] call MPClient_fnc_getGear),
    [life_var_hunger,life_var_thirst],
    (player getVariable ["arrested",false]),
    ((player getVariable ["lifeState",""]) isEqualTo "HEALTHY")
] remoteExecCall ["MPServer_fnc_updateRequest",2];

//Prevent spamming server
life_var_lastSynced = time;

_var