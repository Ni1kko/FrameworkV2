class RscDisplayClothingShop 
{
    idd = 3100; 
    movingEnable = 1;
    enableSimulation = 1;

    class controlsBackground {
        class RscDefineTitleBackground: RscDefineText {
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.7])"};
            idc = -1;
            x = 0.0821059 * safezoneW + safezoneX;
            y = 0.212176 * safezoneH + safezoneY;
            w = 0.318;
            h = (1 / 25);
        };

        class MainBackground: RscDefineText {
            colorBackground[] = {0, 0, 0, 0.7};
            idc = -1;
            x = 0.0822359 * safezoneW + safezoneX;
            y = 0.236099 * safezoneH + safezoneY;
            w = 0.318;
            h = 0.5 - (22 / 250);
        };
    };

    class controls {
        class Title: RscDefineTitle {
            colorBackground[] = {0, 0, 0, 0};
            idc = 3103;
            text = "";
            x = 0.0821059 * safezoneW + safezoneX;
            y = 0.212176 * safezoneH + safezoneY;
            w = 0.6;
            h = (1 / 25);
        };

        class ClothingList: RscDefineListBox {
            idc = 3101;
            text = "";
            sizeEx = 0.035;
            onLBSelChanged = "[_this] call MPClient_fnc_changeClothes;";
            x = 0.0842977 * safezoneW + safezoneX;
            y = 0.240498 * safezoneH + safezoneY;
            w = 0.3;
            h = 0.35;
        };

        class PriceTag: RscDefineStructuredText {
            idc = 3102;
            text = "";
            sizeEx = 0.035;
            x = 0.0853304 * safezoneW + safezoneX;
            y = 0.439419 * safezoneH + safezoneY;
            w = 0.2;
            h = (1 / 25);
        };

        class TotalPrice: RscDefineStructuredText {
            idc = 3106;
            text = "";
            sizeEx = 0.035;
            x = 0.148258 * safezoneW + safezoneX;
            y = 0.439419 * safezoneH + safezoneY;
            w = 0.2;
            h = (1 / 25);
        };

        class FilterList: RscDefineCombo {
            idc = 3105;
            colorBackground[] = {0,0,0,0.7};
            onLBSelChanged  = "_this call MPClient_fnc_clothingFilter";
            x = 0.0822359 * safezoneW + safezoneX;
            y = 0.468 * safezoneH + safezoneY;
            w = 0.318;
            h = 0.035;
        };

        class CloseButtonKey: RscDefineButtonMenu {
            idc = -1;
            text = "$STR_Global_Close";
            onButtonClick = "closeDialog 0;";
            x = 0.157 * safezoneW + safezoneX;
            y = 0.489992 * safezoneH + safezoneY;
            w = (6.25 / 40);
            h = (1 / 25);
        };

        class BuyButtonKey: RscDefineButtonMenu {
            idc = -1;
            text = "$STR_Global_Buy";
            onButtonClick = "[] call MPClient_fnc_buyClothes;";
            x = 0.0822359 * safezoneW + safezoneX;
            y = 0.489992 * safezoneH + safezoneY;
            w = (6.25 / 40);
            h = (1 / 25);
        };

        class viewAngle: RscDefineXSliderH {
            color[] = {1, 1, 1, 0.45};
            colorActive[] = {1, 1, 1, 0.65};
            idc = 3107;
            text = "";
            onSliderPosChanged = "[4,_this select 1] call MPClient_fnc_s_onSliderChange;";
            tooltip = "";
            x = 0.25 * safezoneW + safezoneX;
            y = 0.93 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.02 * safezoneH;
        };
    };
};
