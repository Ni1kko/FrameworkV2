#include "..\..\clientDefines.hpp"
/*
    File: fn_dpFinish.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Finishes the DP Mission and calculates the money earned based
    on distance between A->B
*/
private ["_dp","_dis","_price"];
_dp = [_this,0,objNull,[objNull]] call BIS_fnc_param;
life_var_deliveringPackage = false;
life_dp_point = nil;
_dis = round((getPos life_dp_start) distance (getPos _dp));
_price = round(1.7 * _dis);

["DeliverySucceeded",[format [(localize "STR_NOTF_Earned_1"),[_price] call MPClient_fnc_numberText]]] call bis_fnc_showNotification;
life_cur_task setTaskState "Succeeded";
player removeSimpleTask life_cur_task;

["ADD","CASH",_price] call MPClient_fnc_handleMoney;

true