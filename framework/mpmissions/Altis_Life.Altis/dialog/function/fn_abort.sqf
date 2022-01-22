/*

	Function: 	life_fnc_abort
	Project: 	AsYetUntitled
	Author:     Nikko, IceEagle132
	Github:		https://github.com/AsYetUntitled/Framework
	
*/
 
//-- Close escape menu (must be closed before display 46 is closed)
(findDisplay 49) closeDisplay 2;

for "_idd" from 140 to 46 do {
    private _display = (findDisplay _idd);
    if(!isNull _display)then{
        _display closeDisplay 2;
    };
};

(findDisplay 46) spawn{
    startLoadingScreen ["","Life_Rsc_DisplayLoading"];

    //-- Sync player data to server
    [] call SOCK_fnc_updateRequest;
    ["Syncing your data", "", "red"] call life_fnc_setLoadingText;
    uiSleep 2;

    //--- Request server to clean up player
    [player] remoteExec ["TON_fnc_cleanupRequest",2];
    ["Server Cleanup", "", "red"] call life_fnc_setLoadingText;
    uiSleep 2;

    ["Thanks for playing","Till next time","red"] call life_fnc_setLoadingText;
    uiSleep 3;
    endLoadingScreen;
    _this closeDisplay 2; 
};