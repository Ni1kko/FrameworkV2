class CfgPatches 
{
    class Life_Backend_Fsms 
    {
        units[] = {};
        weapons[] = {};
        requiredAddons[] = {};
        authors[] = {"Tonic", "Ni1kko"};
    };
};

class CfgFunctions 
{
    class LifeFSM_Functions
    {
        class FiniteStateMachine
        {
            file="\life_backend\FSM";
            class cleanup {ext=".fsm";};
            class timeModule {ext=".fsm";};
        };
    };
};
