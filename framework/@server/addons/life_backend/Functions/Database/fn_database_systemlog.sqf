/*
	## Nikko Renolds
	## https://github.com/Ni1kko/Framework
*/

params [
	["_logmessage",""],
	["_logparams",[]]
];
 
if(!isServer)exitwith{false};
if(count _logmessage < 2)exitwith{false};

private _config = configFile >> "CfgExtDB";

_logmessage = format["[LIFE DATABASE SYSTEM]: %1",_logmessage];

//--- Console
if((getNumber(_config >> "conlogs") isEqualTo 1) AND life_var_rcon_passwordOK)then{
	format ["#debug %1", _logmessage] call life_fnc_rcon_sendCommand;
}else{
	//--- RPT
	if(getNumber(_config >> "rptlogs") isEqualTo 1)then{
		diag_log _logmessage;
	};
};

//--- Extension
if(getNumber(_config >> "extlogs") isEqualTo 1)then{
    //"" callExtension format["",_logmessage]
};

true