params [["_player", player]];

[
    {
        XK_6DOF_initCbaSettings
    },
    {
        diag_log text "[6DOF] [initPlayerLocal] Player is initalized. Applying 6DOF event handlers and ACE actions.";
        [_player] call XK_6DOF_fnc_enableOverlay;
        [_player] call XK_6DOF_fnc_respawnEH;

        XK_6DOF_allyFilter = 3;
        XK_6DOF_targetFilter = 3;
        XK_6DOF_filterNVG = false;

        //createAction
        private _eagleEye = ["XK_6DOF_selfAction_eagleEye","EagleEye 6DOF","x\cba\addons\diagnostic\data\monitor_on_ca.paa",
            {},
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _allyFilter = ["XK_6DOF_selfAction_allyFilter","Filter Allies (Not Functional)","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {},
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _allyFilterDisabled = ["XK_6DOF_selfAction_allyFilterDisabled","Disabled","z\ace\addons\minedetector\ui\icon_minedetectoroff.paa",
            {
                XK_6DOF_allyFilter = 0;
                hintSilent format ["%1", XK_6DOF_allyFilter];
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _allyFilterFireteam = ["XK_6DOF_selfAction_allyFilterFireteam","Fireteam Only","z\ace\addons\interaction\ui\team\team_white_ca.paa",
            {
                XK_6DOF_allyFilter = 1;
                hintSilent format ["%1", XK_6DOF_allyFilter];
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _allyFilter6DOF = ["XK_6DOF_selfAction_allyFilterAll","EagleEye Users Only","x\cba\addons\diagnostic\data\monitor_on_ca.paa",
            {
                XK_6DOF_allyFilter = 2;
                hintSilent format ["%1", XK_6DOF_allyFilter];
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _allyFilterAll = ["XK_6DOF_selfAction_allyFilterAll","Show All","z\ace\addons\interaction\ui\team\team_management_ca.paa",
            {
                XK_6DOF_allyFilter = 3;
                hintSilent format ["%1", XK_6DOF_allyFilter];
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _targetFilter = ["XK_6DOF_selfAction_targetFilter","Filter Targets (Not Functional)","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {},
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _targetFilterDisabled = ["XK_6DOF_selfAction_targetFilterDisabled","Disabled","z\ace\addons\minedetector\ui\icon_minedetectoroff.paa",
            {
                XK_6DOF_targetFilter = 0;
                hintSilent format ["%1", XK_6DOF_targetFilter];
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _targetFilterFireteam = ["XK_6DOF_selfAction_targetFilterFireteam","Fireteam Only","z\ace\addons\interaction\ui\team\team_white_ca.paa",
            {
                XK_6DOF_targetFilter = 1;
                hintSilent format ["%1", XK_6DOF_targetFilter];
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _targetFilterNearby = ["XK_6DOF_selfAction_targetFilterNearby","Nearby EagleEye Targets Only","x\cba\addons\diagnostic\data\monitor_on_ca.paa",
            {
                XK_6DOF_targetFilter = 2;
                hintSilent format ["%1", XK_6DOF_targetFilter];
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _targetFilterAll = ["XK_6DOF_selfAction_targetFilterAll","Show All","z\ace\addons\interaction\ui\team\team_management_ca.paa",
            {
                XK_6DOF_targetFilter = 3;
                hintSilent format ["%1", XK_6DOF_targetFilter];
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _filterNVG = ["XK_6DOF_selfAction_allyFilterNVG","Toggle NVG Only","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {
                if (XK_6DOF_filterNVG) then {
                    XK_6DOF_filterNVG = false;
                } else {
                    XK_6DOF_filterNVG = true;
                };
                ["ace_common_displayTextStructured", [format ["Display on NVG only: %1", if (XK_6DOF_filterNVG) then {text "Enabled"} else {text "Disabled"}], 1.5, player], [player]] call CBA_fnc_targetEvent;
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        //Ally Filter
        ["CAManBase",1,["ACE_SelfActions"],_eagleEye, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye"],_allyFilter, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_allyFilter"],_allyFilterDisabled, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_allyFilter"],_allyFilterFireteam, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_allyFilter"],_allyFilter6DOF, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_allyFilter"],_allyFilterAll, true] call ace_interact_menu_fnc_addActionToClass;

        //Target Filter
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye"],_targetFilter, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_targetFilter"],_targetFilterDisabled, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_targetFilter"],_targetFilterFireteam, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_targetFilter"],_targetFilterNearby, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_targetFilter"],_targetFilterAll, true] call ace_interact_menu_fnc_addActionToClass;

        //Toggle NVG
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye"],_filterNVG, true] call ace_interact_menu_fnc_addActionToClass;
    }
] call CBA_fnc_waitUntilAndExecute;