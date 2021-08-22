/*
	## Nikko Renolds
	## https://github.com/Ni1kko/Framework
*/

//["76561199109931625","Trolling, So Dan Got A Ban"] call life_fnc_rcon_ban;

params [
	["_uid","",["",0]],
	["_msg","No Reason Given"],
	["_mins",0]
];

private _ownerID = _uid;

//get ownerID & steamID for target
if(typeName _uid isNotEqualTo "STRING")then{
	_uid = "";
	//steamID from ownerID
	{
		if(owner _x == _ownerID) exitWith { 
			_uid = getPlayerUID _x;
		};
	} forEach (allPlayers - entities 'HeadlessClient_F'); 
}else{
	_ownerID = -100; 
	//ownerID from steamID
	{
		if(getPlayerUID _x == _uid) exitWith { 
			_ownerID = owner _x;
		};
	} forEach (allPlayers - entities 'HeadlessClient_F'); 
};

//opps error
if(_uid isEqualTo "" || _ownerID < 3)exitwith{false};

//get targets beguid
private _BEGuid = ('BEGuid' callExtension ("get:"+_uid));

//ban target
if(format["#beserver addban %1 %2 %3",_bEGuid, _mins, _msg] call life_fnc_rcon_sendCommand)then{
	"#beserver writeBans" call life_fnc_rcon_sendCommand;
}else{
	('#exec ban ' + str _ownerID) call life_fnc_rcon_sendCommand;
};

//kick target
[_ownerID] call life_fnc_rcon_kick;

//log reason, time and beguid
if(getNumber(configFile >> "CfgRCON" >> "dblogs") isEqualTo 1)then{
		
}else{
	format["'%1' Banned Due To: %2",_bEGuid,_msg] call life_fnc_rcon_systemlog;
};

true