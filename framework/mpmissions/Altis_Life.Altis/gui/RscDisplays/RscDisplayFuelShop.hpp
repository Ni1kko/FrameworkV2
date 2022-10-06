class RscDisplayFuelShop {
    idd = 20300; 
    movingEnabled = 0;
    enableSimulation = 1;
    onLoad="uiNamespace setVariable ['RscDisplayFuelShop', _this#0];ctrlShow [2330,false];";
    onUnload="uiNamespace setVariable ['RscDisplayFuelShop', displayNull];life_var_isBusy = false;";
    onDestroy="uiNamespace setVariable ['RscDisplayFuelShop', displayNull];life_var_isBusy = false;";
    
    class controlsBackground {
        class RscDefineTitleBackground: RscDefineText    {
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.7])"};
            idc = -1;
            x = 0.1;
            y = 0.2;
            w = 0.8;
            h = (1 / 25);
        };

        class MainBackground: RscDefineText {
            colorBackground[] = {0,0,0,0.7};
            idc = -1;
            x = 0.1;
            y = 0.2 + (11 / 250);
            w = 0.8;
            h = 0.7 - (22 / 250);
        };

        class Title: RscDefineTitle {
            idc = 20301;
            text = "";
            x = 0.1;
            y = 0.2;
            w = 0.8;
            h = (1 / 25);
        };

        class VehicleTitleBox: RscDefineText {
            idc = -1;
            text = "$STR_GUI_ShopStock";
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.7])"};
            x = 0.11;
            y = 0.26;
            w = 0.32;
            h = (1 / 25);
        };

        class VehicleInfoHeader: RscDefineText {
            idc = 20330;
            text = "$STR_GUI_VehInfo";
            colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.7])"};
            x = 0.46;
            y = 0.26;
            w = 0.42;
            h = (1 / 25);
        };

        class FuelPrice: RscDefineTitle {
            idc = 20322;
            text = "Price:";
            x = 0.15;
            y = 0.8;
            w = 0.8;
            h = (1 / 25);
        };

        class literfuel: RscDefineTitle {
            idc = 20324;
            text = "Fuel:";
            x = 0.55;
            y = 0.75;
            w = 0.8;
            h = (1 / 25);
        };
        class Totalfuel: RscDefineTitle {
            idc = 20323;
            text = "Total:";
            x = 0.75;
            y = 0.8;
            w = 0.8;
            h = (1 / 25);
        };
        class CloseBtn: RscDefineButtonMenu {
            idc = -1;
            text = "$STR_Global_Close";
            onButtonClick = "closeDialog 0; life_var_isBusy = false;";
            x = -0.06 + (6.25 / 40) + (1 / 250 / (safezoneW / safezoneH));
            y = 0.9 - (1 / 25);
            w = (6.25 / 40);
            h = (1 / 25);
        };

        class refuelCar: RscDefineButtonMenu {
            idc = 20309;
            text = "Refuel";
            onButtonClick = "[] spawn MPClient_fnc_fuelRefuelCar;";
            x = 0.26 + (6.25 / 40) + (1 / 250 / (safezoneW / safezoneH));
            y = 0.9 - (1 / 25);
            w = (6.25 / 40);
            h = (1 / 25);
        };
    };

    class controls {
        class VehicleList: RscDefineListBox {
            idc = 20302;
            text = "";
            sizeEx = 0.04;
            colorBackground[] = {0.1,0.1,0.1,0.9};
            onLBSelChanged = "_this call MPClient_fnc_fuelLBChange";
            x = 0.11;
            y = 0.302;
            w = 0.32;
            h = 0.49;
        };

        class fuelTank: RscDefineXSliderH {
            idc = 20901;
            text = "";
            onSliderPosChanged = "[3,_this select 1] call MPClient_fnc_s_onSliderChange;";
            tooltip = "";
            x = 0.47;
            y = .80;
            w = "9 *(((safezoneW / safezoneH) min 1.2) / 40)";
            h = "1 *((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
        };

        class vehicleInfomationList: RscDefineStructuredText
        {
            idc = 20303;
            text = "";
            sizeEx = 0.035;
            x = 0.46;
            y = 0.3;
            w = 0.42;
            h = 0.5;
        };
    };
};