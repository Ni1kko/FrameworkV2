class CfgPatches {
    class Admin {
        units[] = {};
        weapons[] = {};
        requiredAddons[] = {"Database","Rcon"};
        authors[] = {"Ni1kko"};
    };
};
 
class CfgAdmin
{
    //--- logging
    rptlogs = 1;                //Log to RPT file
    conlogs = 1;                //Log to Console
    extlogs = 1;                //Log to Extension
    dblogs = 1;                 //Log to Database
    dblogtypes[] = {            //Types of logs to save to database (0 = disabled, 1 enabled)
        { "KICK",   1 },
        { "BAN",    1 },
        { "INFO",   1 }
    };
    ingamelogs = 1;         //Enable or disable logged admins actions in game (Still wrote to database even if this is disabled)
    ingamelogs_minlvl = 10; //Needed level to view admin logs in game
    
    class Crates {
        class SupplyCrate_0 {
            DisplayName = "Empty Crate";
            CrateClass = "Box_East_Support_F"; 
            Items[] = {};
        };
        class SupplyCrate_1 {
            DisplayName = "Building Supplies";
            CrateClass = "Box_NATO_Support_F";

            Items[] = {};
        };
        class SupplyCrate_2 {
            DisplayName = "Food Supplies";
            CrateClass = "Box_NATO_Support_F";

            Items[] = {};
        };
        class SupplyCrate_3 {
            DisplayName = "Medical Supplies";
            CrateClass = "Box_NATO_Support_F";
            Items[] = {};
        };
    };
   
};

class CfgFunctions {
    class Life {
        class Admin_Functions
        {
            file = "\life_backend\Functions\Admin";
            class admin_initialize {};
            class admin_systemlog {};
        };
    };
};