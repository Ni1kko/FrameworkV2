#include "..\..\clientDefines.hpp"
/*
    File: fn_spawnPointCfg.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Master configuration for available spawn points depending on the units side.

    Return:
    [Spawn Marker,Spawn Name,Image Path]
*/

private _sideString = [param [0 ,playerSide,[civilian]],true] call MPServer_fnc_util_getSideString;
private _return = [];

private _spawnCfg = missionConfigFile >> "CfgSpawnPoints" >> worldName >> _sideString;

for "_i" from 0 to count(_spawnCfg)-1 do {

    private _tempConfig = [];
    private _curConfig = (_spawnCfg select _i);
    private _conditions = getText(_curConfig >> "conditions");

    private _flag = [_conditions] call MPClient_fnc_checkConditions;

    if (_flag) then {
        _tempConfig pushBack getText(_curConfig >> "spawnMarker");
        _tempConfig pushBack getText(_curConfig >> "displayName");
        _tempConfig pushBack getText(_curConfig >> "icon");
        _return pushBack _tempConfig;
    };
};

if (playerSide isEqualTo civilian) then {
    if (count life_houses > 0) then {
      {
        _pos = call compile format ["%1",(_x select 0)];
        _house = nearestObject [_pos, "House"];
        _houseName = getText(configFile >> "CfgVehicles" >> (typeOf _house) >> "displayName");
        _return pushBack [format ["house_%1",_house getVariable "uid"],_houseName,"\a3\ui_f\data\map\MapControl\lighthouse_ca.paa"];
        
        true
      } count life_houses;
  };
};

_return;
