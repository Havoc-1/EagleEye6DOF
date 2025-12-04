/* 
    Author: [DMCL] Xephros
    CBA settings init.
*/

params [["_player", player]];

[
    {
        params ["_player"];
        XK_6DOF_initCbaSettings && (_player == player) && (!isNull _player) && (!isNil "_player");
    },
    {
        ["Player is initalized. Applying 6DOF event handlers and ACE actions.", "initPlayerLocal",1] call XK_6DOF_fnc_diaglog;
        
        [_player] call XK_6DOF_fnc_enableOverlay;
        [_player] call XK_6DOF_fnc_respawnEH;

        XK_6DOF_allyFilter = 3;
        XK_6DOF_targetFilter = 3;
        XK_6DOF_iffFilter = 4;
        XK_6DOF_filterNVG = false;

        //createAction
        private _eagleEye = ["XK_6DOF_selfAction_eagleEye","EagleEye 6DOF","x\cba\addons\diagnostic\data\monitor_on_ca.paa",
            {},
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _allyFilter = ["XK_6DOF_selfAction_allyFilter","Filter Allies","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {},
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _allyFilterDisabled = ["XK_6DOF_selfAction_allyFilterDisabled","Disabled","z\ace\addons\minedetector\ui\icon_minedetectoroff.paa",
            {
                XK_6DOF_allyFilter = 0;
                ["ace_common_displayTextStructured", ["Filter Allies: Disabled", 1.5, player], [player]] call CBA_fnc_targetEvent;
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _allyFilterFireteam = ["XK_6DOF_selfAction_allyFilterFireteam","Fireteam Only","z\ace\addons\interaction\ui\team\team_white_ca.paa",
            {
                XK_6DOF_allyFilter = 1;
                ["ace_common_displayTextStructured", ["Filter Allies: Fireteam Only", 1.5, player], [player]] call CBA_fnc_targetEvent;
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _allyFilter6DOF = ["XK_6DOF_selfAction_allyFilterAll","EagleEye Users Only","x\cba\addons\diagnostic\data\monitor_on_ca.paa",
            {
                XK_6DOF_allyFilter = 2;
                ["ace_common_displayTextStructured", ["Filter Allies: EagleEye Users Only", 1.5, player], [player]] call CBA_fnc_targetEvent;
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _allyFilterAll = ["XK_6DOF_selfAction_allyFilterAll","Show All","z\ace\addons\interaction\ui\team\team_management_ca.paa",
            {
                XK_6DOF_allyFilter = 3;
                ["ace_common_displayTextStructured", ["Filter Allies: Show All", 1.5, player], [player]] call CBA_fnc_targetEvent;
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _targetFilter = ["XK_6DOF_selfAction_targetFilter","Filter Targets","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {},
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _targetFilterDisabled = ["XK_6DOF_selfAction_targetFilterDisabled","Disabled","z\ace\addons\minedetector\ui\icon_minedetectoroff.paa",
            {
                XK_6DOF_targetFilter = 0;
                ["ace_common_displayTextStructured", ["Filter Targets: Disabled All", 1.5, player], [player]] call CBA_fnc_targetEvent;
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        /* private _targetFilterFireteam = ["XK_6DOF_selfAction_targetFilterFireteam","Fireteam Only","z\ace\addons\interaction\ui\team\team_white_ca.paa",
            {XK_6DOF_targetFilter = 1},
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _targetFilterNearby = ["XK_6DOF_selfAction_targetFilterNearby","Nearby EagleEye Targets Only","x\cba\addons\diagnostic\data\monitor_on_ca.paa",
            {XK_6DOF_targetFilter = 2},
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction; */

        private _targetFilterAll = ["XK_6DOF_selfAction_targetFilterAll","Show All","z\ace\addons\interaction\ui\team\team_management_ca.paa",
            {
                XK_6DOF_targetFilter = 3;
                ["ace_common_displayTextStructured", ["Filter Targets: Show All", 1.5, player], [player]] call CBA_fnc_targetEvent;
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

        private _iffFilter = ["XK_6DOF_selfAction_iffFilter","Filter IFF","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {},
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _iffFilterNone = ["XK_6DOF_selfAction_iffFilterNone","Disabled","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {
                XK_6DOF_iffFilter = 0;
                ["ace_common_displayTextStructured", ["Filter IFF: Disabled", 1.5, player], [player]] call CBA_fnc_targetEvent;

            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;
        
        private _iffFilterFriendly = ["XK_6DOF_selfAction_iffFilterFriendly","Allies Only","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {
                XK_6DOF_iffFilter = 1;
                ["ace_common_displayTextStructured", ["Filter IFF: Allies Only", 1.5, player], [player]] call CBA_fnc_targetEvent;
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _iffFilterEnemy = ["XK_6DOF_selfAction_iffFilterTargets","Targets Only","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {
                XK_6DOF_iffFilter = 2;
                ["ace_common_displayTextStructured", ["Filter IFF: Targets Only", 1.5, player], [player]] call CBA_fnc_targetEvent;
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _iffFilterFireteam = ["XK_6DOF_selfAction_iffFilterFireteam","Fireteam Only","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {
                XK_6DOF_iffFilter = 3;
                ["ace_common_displayTextStructured", ["Filter IFF: Fireteam Only", 1.5, player], [player]] call CBA_fnc_targetEvent;
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        private _iffFilterAll = ["XK_6DOF_selfAction_iffFilterAll","All Units","z\ace\addons\minedetector\ui\icon_minedetectoron.paa",
            {
                XK_6DOF_iffFilter = 4;
                ["ace_common_displayTextStructured", ["Filter IFF: All Units", 1.5, player], [player]] call CBA_fnc_targetEvent;
            },
            {player getVariable ["XK_6DOF_enable", false]}
        ] call ace_interact_menu_fnc_createAction;

        //6DOF Main Action
        ["CAManBase",1,["ACE_SelfActions"],_eagleEye, true] call ace_interact_menu_fnc_addActionToClass;

        //IFF Filter
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye"],_iffFilter, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_iffFilter"],_iffFilterNone, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_iffFilter"],_iffFilterFriendly, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_iffFilter"],_iffFilterEnemy, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_iffFilter"],_iffFilterFireteam, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_iffFilter"],_iffFilterAll, true] call ace_interact_menu_fnc_addActionToClass;

        //Ally Filter
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye"],_allyFilter, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_allyFilter"],_allyFilterDisabled, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_allyFilter"],_allyFilterFireteam, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_allyFilter"],_allyFilter6DOF, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_allyFilter"],_allyFilterAll, true] call ace_interact_menu_fnc_addActionToClass;

        //Target Filter
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye"],_targetFilter, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_targetFilter"],_targetFilterDisabled, true] call ace_interact_menu_fnc_addActionToClass;
        //["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_targetFilter"],_targetFilterFireteam, true] call ace_interact_menu_fnc_addActionToClass;
        //["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_targetFilter"],_targetFilterNearby, true] call ace_interact_menu_fnc_addActionToClass;
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye", "XK_6DOF_selfAction_targetFilter"],_targetFilterAll, true] call ace_interact_menu_fnc_addActionToClass;

        //Toggle NVG
        ["CAManBase",1,["ACE_SelfActions", "XK_6DOF_selfAction_eagleEye"],_filterNVG, true] call ace_interact_menu_fnc_addActionToClass;
    },
    [_player]
] call CBA_fnc_waitUntilAndExecute;