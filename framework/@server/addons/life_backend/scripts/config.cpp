class CfgPatches 
{
    class Life_Backend_Functions 
    {
        units[] = {};
        weapons[] = {};
        requiredAddons[] = {"Life_Backend_Fsms"};
        authors[] = {"Tonic", "Ni1kko"};
    };
};

class CfgFunctions 
{
    //--- Root Functions
    class MPServer 
    {
        class Root_Functions
        {
            file = "\life_backend\scripts";
            class init {};
            class preInit {preInit = 1;};
            class postInit {postInit = 1;};
        }; 
    };
};