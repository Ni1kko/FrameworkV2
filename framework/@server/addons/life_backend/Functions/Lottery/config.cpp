class CfgPatches 
{
    class Lottery 
    {
        units[] = {};
        weapons[] = {};
        requiredAddons[] = {"Database"};
        authors[] = {"Ni1kko"};
    };
};
 
class CfgLottery
{ 
    ticketPrice = 1000; // Price of one ticket
    ticketBonusballPrice = 200; // Price of one Bonusball
    ticketLength = 8; // Length of ticket number (Larger numbers = more combinations)
    ticketDrawCount = 25; // Amount of winable tickets
    ticketsReclaim = 1; // allow players to reclaim their tickets if the were not online when draw was made
    ticketDrawDay = "Wednesday"; // Day of the week when the draw is made
};

class CfgFunctions 
{
    class Life {
        class Lottery_Functions
        {
            file = "\life_backend\Functions\Lottery";
            class lottery_init {postInit = 1;};
            class lottery_pickwinners {};
            class lottery_buyTicket {};
            class lottery_generateTicket {};
            class lottery_checkOldTickets {};
        };
    };
};