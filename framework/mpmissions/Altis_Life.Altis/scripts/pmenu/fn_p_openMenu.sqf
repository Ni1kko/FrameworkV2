#include "..\..\script_macros.hpp"
/*
    File: fn_p_openMenu.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Opens the players virtual inventory menu
*/
if (!alive player || dialog) exitWith {}; //Prevent them from opening this for exploits while dead.
createDialog "playerSettings";
disableSerialization;

switch (playerSide) do {
    case west: {
        ctrlShow[2011,false];
    };

    case civilian: {
        ctrlShow[2012,false];
    };

    case independent: {
        ctrlShow[2012,false];
        ctrlShow[2011,false];
    };
};

if (FETCH_CONST(life_adminlevel) < 1) then {
    ctrlShow[2021,false];
};

//--- Bounty hunting
if (playerSide isNotEqualTo civilian || !license_civ_bounty) then {
    ctrlShow[2024,false];
};

[] call MPClient_fnc_p_updateMenu;