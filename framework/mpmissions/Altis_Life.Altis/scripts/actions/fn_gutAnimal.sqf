#include "..\..\clientDefines.hpp"
/*
    File: fn_gutAnimal.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Guts the animal?
*/
private ["_animalCorpse","_upp","_ui","_progress","_pgText","_cP","_displayName","_item"];
_animalCorpse = param [0,objNull,[objNull]];
if (isNull _animalCorpse) exitWith {}; //Object passed is null?

life_var_interrupted = false;
if (player distance _animalCorpse > 3.5) exitWith {}; //WTF need check with nearest objects I love Arma
life_var_isBusy = true;

switch (typeOf _animalCorpse) do {
    case "Hen_random_F": {_displayName = localize "STR_ANIM_chicken"; _item = "hen_raw";};
    case "Cock_random_F": {_displayName = localize "STR_ANIM_Rooster"; _item = "rooster_raw";};
    case "Goat_random_F": {_displayName = localize "STR_ANIM_Goat"; _item = "goat_raw";};
    case "Sheep_random_F": {_displayName = localize "STR_ANIM_Sheep"; _item = "sheep_raw";};
    case "Rabbit_F": {_displayName = localize "STR_ANIM_Rabbit"; _item = "rabbit_raw";};
    default {_displayName = ""; _item = "";};
};

if (_displayName isEqualTo "") exitWith {life_var_isBusy = false;};

_upp = format [localize "STR_NOTF_Gutting",_displayName];
//Setup our progress bar.
disableSerialization;
"progressBar" cutRsc ["RscTitleProgressBar","PLAIN"];
_ui = uiNamespace getVariable "RscTitleProgressBar";
_progress = _ui displayCtrl 38201;
_pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format ["%2 (1%1)...","%",_upp];
_progress progressSetPosition 0.01;
_cP = 0.01;

for "_i" from 0 to 1 step 0 do {
    if (animationState player != "AinvPknlMstpSnonWnonDnon_medic_1") then {
        [player,"AinvPknlMstpSnonWnonDnon_medic_1",true] remoteExecCall ["MPClient_fnc_animSync",RE_CLIENT];
        player switchMove "AinvPknlMstpSnonWnonDnon_medic_1";
        player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
    };
    sleep 0.15;
    _cP = _cP + 0.01;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format ["%3 (%1%2)...",round(_cP * 100),"%",_upp];
    if (_cP >= 1) exitWith {};
    if (!alive player) exitWith {};
    if (isNull _animalCorpse) exitWith {};
    if !(isNull objectParent player) exitWith {};
    if (life_var_interrupted) exitWith {};
};

life_var_isBusy = false;
"progressBar" cutText ["","PLAIN"];
player playActionNow "stop";
if (isNull _animalCorpse) exitWith {life_var_isBusy = false;};
if (life_var_interrupted) exitWith {life_var_interrupted = false; titleText[localize "STR_NOTF_ActionCancel","PLAIN"]; life_var_isBusy = false;};
if !(isNull objectParent player) exitWith {titleText[localize "STR_NOTF_ActionInVehicle","PLAIN"];};

if (["ADD",_item,1] call MPClient_fnc_handleVitrualItem) then {
    deleteVehicle _animalCorpse;
    titleText[format [(localize "STR_NOTF_Guttingfinish"),_displayName],"PLAIN"];
} else {
    titleText[(localize "STR_NOTF_InvFull"),"PLAIN"];
};