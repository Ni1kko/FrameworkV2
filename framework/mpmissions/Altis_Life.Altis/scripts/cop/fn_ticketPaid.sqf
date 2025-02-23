#include "..\..\clientDefines.hpp"
/*
    File: fn_ticketPaid.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Verifies that the ticket was paid.
*/
params [
    ["_value",5,[0]],
    ["_unit",objNull,[objNull]],
    ["_cop",objNull,[objNull]]
];
if (isNull _unit || {!(_unit isEqualTo life_ticket_unit)}) exitWith {}; //NO
if (isNull _cop || {!(_cop isEqualTo player)}) exitWith {}; //Double NO

["ADD","BANK",_value] call MPClient_fnc_handleMoney;

true
