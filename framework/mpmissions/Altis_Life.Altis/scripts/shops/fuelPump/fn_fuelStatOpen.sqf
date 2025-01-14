#include "..\..\..\clientDefines.hpp"
/*
	## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
    ## fn_fuelStatOpen.sqf
*/

if (dialog || life_var_isBusy || life_var_processingResource) exitWith {};

private _fuelStations = nearestObjects [player, ["Land_fs_feed_F", "Land_FuelStation_01_pump_F", "Land_FuelStation_02_pump_F"], 10];
if (_fuelstations isEqualTo []) exitWith {};

private _vehicleList = nearestObjects [player, ["Car","Air"], 10];
if (_vehicleList isEqualTo []) exitWith {hint localize "STR_NOTF_VehicleNear"};

createDialog "RscDisplayFuelShop";
life_var_isBusy = true;

private _fuelCost = CFG_MASTER(getNumber,"fuel_cost");
uiNamespace setVariable ["fuel_cost",_fuelCost];
ctrlSetText [20301,"Fuel Station"];

//Fetch the shop config.
private _vehicleFuelList = [];
{
    private _fuel = fuel _x;
    _vehicleFuelList pushBack [_x,_fuel];
} forEach _vehicleList;
uiNamespace setVariable ["fuel_list",_vehicleFuelList];

private _control = (findDisplay 20300) displayCtrl 20302;
lbClear _control;

ctrlSetText [20322,format [localize "STR_Price_Fuel_Pump",_fuelCost]];
ctrlSetText [20323,format ["Total : %1$",_fuelCost * 0.1]];

//Loop through
{
    _x params ["_vehicle","_fuelLeft"];
    private _className = typeOf _vehicle;

    private _vehicleInfo = [_className] call MPClient_fnc_fetchVehInfo;
    _control lbAdd (_vehicleInfo select 3);
    _control lbSetPicture [_forEachIndex,(_vehicleInfo select 2)];
    _control lbSetData [_forEachIndex,_className];
} forEach _vehicleFuelList;
