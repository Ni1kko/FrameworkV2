class RscDisplayPlayerInventorySettings 
{
    idd = 2900; 
    movingEnable = 0;
    enableSimulation = 1;
    onLoad="uiNamespace setVariable ['RscDisplayPlayerInventorySettings', _this#0];";
    onUnload="uiNamespace setVariable ['RscDisplayPlayerInventorySettings', displayNull]";
    onDestroy="uiNamespace setVariable ['RscDisplayPlayerInventorySettings', displayNull]";

    class controlsBackground 
    {
        class RscTitleBackground: RscDefineText 
        {
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.7])"};
            idc = -1;
            x = 0.3;
            y = 0.2;
            w = 0.5;
            h = (1 / 25);
        };

        class RscMainBackground: RscDefineText 
        {
            colorBackground[] = {0,0,0,0.7};
            idc = -1;
            x = 0.3;
            y = 0.2 + (11 / 250);
            w = 0.5;
            h = 0.48 - (22 / 250);
        };

        class PlayerTagsHeader: RscDefineText 
        {
            idc = -1;
            text = "$STR_SM_PlayerTags";
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.7])"};
            x = 0.30;
            y = 0.43;
            w = 0.35;
            h = (1 / 25);
        };

        class SideChatHeader : PlayerTagsHeader 
        {
            idc = -1;
            text = "$STR_SM_SC";
            y = 0.48;
        };

        class RevealNearestHeader : PlayerTagsHeader 
        {
            idc = -1;
            text = "$STR_SM_RNObj";
            y = 0.53;
        };

        class BroacastHeader : PlayerTagsHeader 
        {
            idc = -1;
            text = "$STR_SM_BCSW";
            y = 0.58;
        };

        class Title: RscDefineTitle 
        {
            idc = -1;
            colorBackground[] = {0,0,0,0};
            text = "$STR_SM_Title";
            x = 0.3;
            y = 0.2;
            w = 0.5;
            h = (1 / 25);
        };
    };

    class controls 
    {
        class VDonFoot: RscDefineText 
        {
            idc = -1;
            text = "$STR_SM_onFoot";
            x = 0.32;
            y = 0.258;
            w = 0.275;
            h = 0.04;
        };

        class VDinCar: RscDefineText 
        {
            idc = -1;
            text = "$STR_SM_inCar";
            x = 0.32;
            y = 0.305;
            w = 0.275;
            h = 0.04;
        };

        class VDinAir: RscDefineText 
        {
            idc = -1;
            text = "$STR_SM_inAir";
            x = 0.32;
            y = 0.355;
            w = 0.275;
            h = 0.04;
        };

        class VD_onfoot_slider: RscDefineXSliderH 
        {
            idc = 2901;
            text = "";
            onSliderPosChanged = "[0,_this select 1] call MPClient_fnc_s_onSliderChange;";
            tooltip = "$STR_SM_ToolTip1";
            x = 0.42;
            y = 0.30 - (1 / 25);
            w = "9 *(((safezoneW / safezoneH) min 1.2) / 40)";
            h = "1 *((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
        };

        class VD_onfoot_value: RscDefineTextEdit 
        {
            idc = 2902;
            text = "";
            onChar = "[_this select 0, _this select 1,'ground',false] call MPClient_fnc_s_onChar;";
            onKeyUp = "[_this select 0, _this select 1,'ground',true] call MPClient_fnc_s_onChar;";
            x = .70;
            y = .258;
            w = .08;
            h = .04;
        };

        class VD_car_slider: RscDefineXSliderH 
        {
            idc = 2911;
            text = "";
            onSliderPosChanged = "[1,_this select 1] call MPClient_fnc_s_onSliderChange;";
            tooltip = "$STR_SM_ToolTip2";
            x = 0.42;
            y = 0.35 - (1 / 25);
            w = "9 *(((safezoneW / safezoneH) min 1.2) / 40)";
            h = "1 *((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
        };

        class VD_car_value: RscDefineTextEdit 
        {
            idc = 2912;
            text = "";
            onChar = "[_this select 0, _this select 1,'vehicle',false] call MPClient_fnc_s_onChar;";
            onKeyUp = "[_this select 0, _this select 1,'vehicle',true] call MPClient_fnc_s_onChar;";
            x = .70;
            y = .31;
            w = .08;
            h = .04;
        };

        class VD_air_slider: RscDefineXSliderH 
        {
            idc = 2921;
            text = "";
            onSliderPosChanged = "[2,_this select 1] call MPClient_fnc_s_onSliderChange;";
            tooltip = "$STR_SM_ToolTip3";
            x = 0.42;
            y = 0.40 - (1 / 25);
            w = "9 *(((safezoneW / safezoneH) min 1.2) / 40)";
            h = "1 *((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
        };

        class VD_air_value: RscDefineTextEdit 
        {
            idc = 2922;
            text = "";
            onChar = "[_this select 0, _this select 1,'air',false] call MPClient_fnc_s_onChar;";
            onKeyUp = "[_this select 0, _this select 1,'air',true] call MPClient_fnc_s_onChar;";
            x = 0.70;
            y = 0.36;
            w = .08;
            h = .04;
        };

        class PlayerTagsONOFF: RscDefineCheckbox 
        {
            tooltip = "$STR_GUI_PlayTags";
            idc = 2970;
            sizeEx = 0.04;
            onCheckedChanged = "['tags',_this select 1] call MPClient_fnc_s_onCheckedChange;";
            x = 0.65;
            y = 0.43;

        };

        class SideChatONOFF: PlayerTagsONOFF 
        {
            idc = 2971;
            tooltip = "$STR_GUI_SideSwitch";
            onCheckedChanged = "['sidechat',_this select 1] call MPClient_fnc_s_onCheckedChange;";
            y = 0.48;
        };

        class RevealONOFF : PlayerTagsONOFF 
        {
            idc = 2972;
            tooltip = "$STR_GUI_PlayerReveal";
            onCheckedChanged = "['objects',_this select 1] call MPClient_fnc_s_onCheckedChange;";
            y = 0.53;
        };

        class BroadcastONOFF : PlayerTagsONOFF 
        {
            idc = 2973;
            tooltip = "$STR_GUI_BroadcastSwitch";
            onCheckedChanged = "['broadcast',_this select 1] call MPClient_fnc_s_onCheckedChange;";
            y = 0.58;
        };

        class ButtonClose: RscDefineButtonMenu 
        {
            idc = -1;
            //shortcuts[] = {0x00050000 + 2};
            text = "$STR_Global_Close";
            onButtonClick = "closeDialog 0;";
            x = 0.48;
            y = 0.68 - (1 / 25);
            w = (6.25 / 40);
            h = (1 / 25);
        };
    };
};
