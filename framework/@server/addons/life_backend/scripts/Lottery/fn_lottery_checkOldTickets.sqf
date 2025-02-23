#include "\life_backend\serverDefines.hpp"
/*
	## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
*/


private _queryTickets = ["READ", "unclaimedLotteryTickets", 
	[
		["ticketID", "BEGuid", "winnings", "bonusball","bonusballWinnings"],
		[
			["claimed", ["DB","BOOL", false] call MPServer_fnc_database_parse],
			["serverID",["DB","INT",call life_var_serverID] call MPServer_fnc_database_parse]
		]
	]
] call MPServer_fnc_database_request;

private _claimedTickets = [];

while {count _queryTickets > 0} do {
	private _allPlayers = playableUnits;

	waitUntil {
		sleep 10;
		count _allPlayers isNotEqualTo count playableUnits
	};

	{
		_x params ["_ticketID", "_WinnerGuid", "_winnings", "_wonBonusBall","_bonusballWinnings"];

		private _winnerIndex = _forEachIndex;

		{
			if(isPlayer _x)then{ 
				private _player = _x;
				private _name = (name _player);
				private _steamID = (getPlayerUID _player);
				private _ownerID = (owner _player);
				private _BEGuid = GET_BEGUID(_player);
	
				if (_BEGuid isEqualTo _WinnerGuid) then 
				{  
					[
						[
							_winnings,
							_wonBonusBall,
							[0,_bonusballWinnings]select _wonBonusBall
						],
						{
							params ["_ticketPayout","_bonusBallWinner","_bonusBallPayout"];

							private _totalPayout = _ticketPayout + _bonusBallPayout;
							
							systemChat ([
								format["You have won $%1 from the lottery!",[_ticketPayout] call MPClient_fnc_numberText],
								format["You have won $%1 from the lottery bonusball!",[_bonusBallPayout] call MPClient_fnc_numberText]
							] select _bonusBallWinner);
							
							["ADD","CASH",_totalPayout] call MPClient_fnc_handleMoney;
						}
					] remoteExec ["spawn",_ownerID];

					_queryTickets deleteAt _winnerIndex;
					_claimedTickets pushBack _ticketID;
				}; 
			};
		}forEach _allPlayers;

		sleep 2; 

	}forEach _queryTickets;


	if(count _claimedTickets > 0)then{
		{ 

			["UPDATE", "unclaimedLotteryTickets", 
				[
					[
						["claimed", ["DB","BOOL", true] call MPServer_fnc_database_parse],
						["ticketID", ["DB","INT", _x] call MPServer_fnc_database_parse]
					]
				]
			] call MPServer_fnc_database_request;
			_queryTickets deleteAt _forEachIndex;
		}forEach _claimedTickets;
	};

	sleep 10;

	["CALL", "deleteClaimedLotteryTickets"] call MPServer_fnc_database_request;
};
