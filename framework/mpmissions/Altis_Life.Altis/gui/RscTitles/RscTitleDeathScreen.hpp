/*
	## Nikko Renolds
	## https://github.com/Ni1kko/FrameworkV2
    ## RscTitleDeathScreen.hpp
*/

class RscTitleDeathScreen
{
	idd = 11200;
	duration = INFINTE;
	movingEnable=0;
  	fadein=0; 
  	fadeout=0;
	onLoad = "uiNamespace setVariable ['RscTitleDeathScreen',_this select 0]";
	onUnload = "uiNamespace setVariable ['RscTitleDeathScreen', objNull]";
	onDestroy = "uiNamespace setVariable ['RscTitleDeathScreen', objNull]";
	objects[]={};
	
	class controlsBackground
	{
		class DeathPicture: RscDefinePicture
		{
			idc = -1;
			text = "textures\gui\RscTitles\RscTitleDeathScreen\blood.paa";
			x = 0.2375 * safezoneW + safezoneX;
			y = 0.15 * safezoneH + safezoneY;
			w = 0.525 * safezoneW;
			h = 0.7 * safezoneH;
			colorBackground[] = {0,0,0,0};
		};		
	};
	
	class Controls
	{

		class txt_top_left: RscDefineStructuredText
		{
			idc = 66601;
			x = 0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.5 * safezoneW;
			h = 0.11 * safezoneH;
		};
		class txt_top_right: RscDefineStructuredText
		{
			idc = 66602;
			x = 0.5 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.5 * safezoneW;
			h = 0.11 * safezoneH;			
		};
		class txt_bottom_left: RscDefineStructuredText
		{
			idc = 66603;
			x = 0 * safezoneW + safezoneX;
			y = 0.89 * safezoneH + safezoneY;
			w = 0.5 * safezoneW;
			h = 0.11 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
		};		
		class txt_bottom_right: RscDefineStructuredText
		{
			idc = 66604;
			x = 0.5 * safezoneW + safezoneX;
			y = 0.89 * safezoneH + safezoneY;
			w = 0.5 * safezoneW;
			h = 0.11 * safezoneH;
			colorBackground[] = {0,0,0,0.5};		
		};	
	};
};