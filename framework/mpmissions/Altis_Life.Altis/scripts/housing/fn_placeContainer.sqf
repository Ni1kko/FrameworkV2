#include "..\..\clientDefines.hpp"
/*
    File: fn_placeContainer.sqf
    Author: NiiRoZz
    Credits: BoGuu

    Description:
    Check container if are in house and if house are owner of player and if all this conditions are true add container in database
*/
private ["_container","_isFloating","_type","_house","_containers","_houseCfg","_message","_isPlaced"];
params [
        ["_container",objNull,[objNull]],
        ["_isFloating",true,[true]]
];

_uid = getPlayerUID player;
_house = nearestObject [player, "House"];

switch (true) do {
    case (typeOf _container isEqualTo "B_supplyCrate_F"): {_type = "storagebig"};
    case (typeOf _container isEqualTo "Box_IND_Grenades_F") : {_type = "storagesmall"};
    default {_type = ""};
};

_message = 0;
_isPlaced = false;
if (!isNull _house) then {
    _message = 1;
    if (([player] call MPClient_fnc_playerInBuilding) && {([_container] call MPClient_fnc_playerInBuilding)}) then {
        _message = 2;
        if ((_house in life_var_vehicles) && !(isNil {_house getVariable "house_owner"})) then {
            _message = 3;
            if (!_isFloating) then {
                _message = 4;
                _containers = _house getVariable ["containers",[]];
                _houseCfg = [(typeOf _house)] call MPClient_fnc_houseConfig;
                if (_houseCfg isEqualTo []) exitWith {};
                if (count _containers < (_houseCfg select 1)) then {
                    _isPlaced = true;
                    if (count extdb_var_database_headless_clients > 0) then {
                        [_uid,_container] remoteExec ["HC_fnc_addContainer",extdb_var_database_headless_client];
                    } else {
                        [_uid,_container] remoteExec ["MPServer_fnc_addContainer",RE_SERVER];
                    };
                    _container setVariable ["virtualInventory",[[],0],true];
                    _container setVariable ["container_owner",[_uid],true];
                    _containers pushBack _container;
                    _house setVariable ["containers",_containers,true];
                    sleep 1;
                };
            };
        };
    };
};

if (_isPlaced) exitWith {};

deleteVehicle _container;
["ADD",_type,1] call MPClient_fnc_handleVitrualItem;

if (_message isEqualTo 0 || _message isEqualTo 1) then {
    hint localize "STR_House_Container_House_Near";
};
if (_message isEqualTo 2) then {
    hint localize "STR_House_Container_House_Near_Owner";
};
if (_message isEqualTo 3) then {
    hint localize "STR_House_Container_Floating";
};
if (_message isEqualTo 4) then {
    hint localize "STR_ISTR_Box_HouseFull";
};