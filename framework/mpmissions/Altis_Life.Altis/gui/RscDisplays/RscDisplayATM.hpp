class RscDisplayATM 
{
    idd = 2700; 
    movingEnable = 0;
    enableSimulation = 1;
	onLoad="uiNamespace setVariable ['RscDisplayATM', _this#0];";
    onUnload="uiNamespace setVariable ['RscDisplayATM', displayNull]";
    onDestroy="uiNamespace setVariable ['RscDisplayATM', displayNull]";

    class controlsBackground 
    {
        class RscDefineTitleBackground: RscDefineText {
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.7])"};
            idc = -1;
            x = 0.35;
            y = 0.2;
            w = 0.3;
            h = (1 / 25);
        };

        class MainBackground: RscDefineText {
            colorBackground[] = {0, 0, 0, 0.7};
            idc = -1;
            x = 0.35;
            y = 0.2 + (11 / 250);
            w = 0.3;
            h = 0.652 - (22 / 250);
        };
    };

    class controls 
    {
        class MoneyInfo: RscDefineStructuredText {
            idc = 2701;
            text = "";
            x = 0.39;
            y = 0.26;
            w = 0.3;
            h = .14;
        };

        class Title: RscDefineTitle {
            colorBackground[] = {0, 0, 0, 0};
            idc = 4885;
            text = "$STR_ATM_Title";
            x = 0.35;
            y = 0.2;
            w = 0.6;
            h = (1 / 25);
        };

        class WithdrawButton: RscDefineButtonMenu {
            idc = 4886;
            text = "$STR_ATM_Withdraw";
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", 0.5};
            onButtonClick = "[] call MPClient_fnc_bankWithdraw";
            x = 0.425;
            y = 0.46;
            w = (6 / 40);
            h = (1 / 25);
        };

        class DepositButton: RscDefineButtonMenu {
            idc = 4887;
            text = "$STR_ATM_Deposit";
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", 0.5};
            onButtonClick = "[] call MPClient_fnc_bankDeposit";
            x = 0.425;
            y = 0.512;
            w = (6 / 40);
            h = (1 / 25);
        };

        class moneyEdit: RscDefineTextEdit {
            idc = 2702;
            text = "1";
            sizeEx = 0.030;
            x = 0.4;
            y = 0.41;
            w = 0.2;
            h = 0.03;
        };

        class PlayerList: RscDefineCombo {
            idc = 2703;
            x = 0.4;
            y = 0.58;
            w = 0.2;
            h = 0.03;
        };

        class TransferButton: RscDefineButtonMenu {
            idc = 4888;
            text = "$STR_ATM_Transfer";
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", 0.5};
            onButtonClick = "[] call MPClient_fnc_bankTransfer";
            x = 0.425;
            y = 0.63;
            w = (6 / 40);
            h = (1 / 25);
        };

        class GangWithdraw : TransferButton {
            idc = 2705;
            text = "$STR_ATM_WithdrawGang";
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", 0.5};
            onButtonClick = "[false] call MPClient_fnc_useGangBank";
            x = 0.365;
            y = 0.7;
            w = 0.275;
        };

        class GangDeposit : TransferButton {
            idc = 2706;
            text = "$STR_ATM_DepositGang";
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", 0.5};
            onButtonClick = "[true] call MPClient_fnc_useGangBank";
            x = 0.365;
            y = 0.752;
            w = 0.275;
        };

        class CloseButtonKey: RscDefineButtonMenu {
            idc = -1;
            text = "$STR_Global_Close";
            onButtonClick = "closeDialog 0;";
            x = 0.35;
            y = 0.812;
            w = (6.25 / 40);
            h = (1 / 25);
        };
    };
};