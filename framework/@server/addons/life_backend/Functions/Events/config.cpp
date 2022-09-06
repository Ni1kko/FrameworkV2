class CfgPatches 
{
    class Events 
    {
        units[] = {};
        weapons[] = {};
        requiredAddons[] = {"Database"};
        authors[] = {"Ni1kko"};
    };
};
 
class CfgEvents
{
    
};

class CfgFunctions 
{
    class Life
    {
        class Events_Functions
        {
            file = "\life_backend\Functions\Events";
            class event_playerConnected {};
            class event_playerDisconnected {};
        };
    };
};