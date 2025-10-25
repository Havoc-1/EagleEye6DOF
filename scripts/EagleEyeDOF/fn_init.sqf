/* 
    Author: [DMCL] Xephros
    Init for 6DOF
*/

private _cbaCheck = isClass(configFile >> "CfgPatches" >> "cba_main");
private _aceCheck = isClass(configFile >> "CfgPatches" >> "ace_main");
if !(_cbaCheck || _aceCheck) exitWith {diag_log text format ["[6DOF] Failed to initialize EagleEye 6DOF, dependencies not loaded. CBA_A3: %1, ACE: %2",_cbaCheck, _aceCheck]};
diag_log text "[6DOF] Initializing EagleEye 6DOF.";

XK_6DOF_iconAlly = "\A3\ui_f\data\map\markers\nato\b_unknown.paa";         //IFF Icon for Friendly Targets
XK_6DOF_iconEagleEye = "\A3\ui_f\data\map\markers\nato\b_inf.paa";         //IFF Icon for Friendly 6DOF Users
XK_6DOF_iconEnemy = "\A3\ui_f\data\map\markers\nato\o_unknown.paa";        //IFF Icon for Enemy Targets
XK_6DOF_iconUnknown = "\A3\ui_f\data\map\markers\nato\o_unknown.paa";      //IFF Icon for Unknown Targets (Requires XK_6DOF_enableUnknown set to true)
XK_6DOF_iconUAV = "\A3\ui_f\data\map\markers\nato\b_uav.paa";              //IFF Icon for Self when operating UAV camera

//Initialize CBA Settings
[
    "XK_6DOF_scanList",
    "SLIDER",
    ["Scan Range","Maximum distance in metres from EagleEye user to register as target. May affect performance if set too high."],
    "EagleEye 6DOF",
    [50, 300, 200, 0],
    1
] call CBA_fnc_addSetting;

[
    "XK_6DOF_nameTags",
    "CHECKBOX",
    ["Enable Nametags", "Shows name of 6DOF users next to bounding box when within 15m."],
    "EagleEye 6DOF",
    true,
    1
] call CBA_fnc_addSetting;

[
    "XK_6DOF_iconAlly",
    "COLOR",
    ["Friendly IFF","Color for friendly targets"],
    "EagleEye 6DOF",
    [0.05, 0.05, 1]
] call CBA_fnc_addSetting;

[
    "XK_6DOF_colorTarget",
    "COLOR",
    ["Enemy IFF","Color for enemy targets"],
    "EagleEye 6DOF",
    [1, 0, 0]
] call CBA_fnc_addSetting;

[
    "XK_6DOF_colorMark",
    "COLOR",
    ["Marked Target","Color for marked targets"],
    "EagleEye 6DOF",
    [0.9, 0.4, 0.1]
] call CBA_fnc_addSetting;

[
    "XK_6DOF_colorUnknown",
    "COLOR",
    ["Enemy IFF","Color for unknown targets"],
    "EagleEye 6DOF",
    [0.4, 0, 0.5]
] call CBA_fnc_addSetting;

[
    "XK_6DOF_enableUnknown",
    "CHECKBOX",
    ["Enable Unknown Targets", "Marks unarmed targets as unknown instead of enemy."],
    "EagleEye 6DOF",
    true,
    1
] call CBA_fnc_addSetting;

[
    "XK_6DOF_gogglesList",
    "EDITBOX",
    ["Goggles Whitelist", "Classnames of goggles to enable 6DOF. Array/string format not required. Example: G_Goggles_VR, G_Tactical_Clear,..."],
    "EagleEye 6DOF",
    "G_Goggles_VR, G_Tactical_Clear, G_Tactical_Black, G_Tactical_camo, G_Tactical_yellow",
    1
] call CBA_fnc_addSetting;

[
    "XK_6DOF_headgearList",
    "EDITBOX",
    ["Headgear Whitelist", "Classnames of headgear to enable 6DOF. Array/string format not required. Example: Helmet1, Hat2, ..."],
    "EagleEye 6DOF",
    "H_HelmetSpecB, H_HelmetSpecB_blk, H_HelmetSpecB_paint2, H_HelmetSpecB_paint1, H_HelmetSpecB_sand, H_HelmetSpecB_snakeskin, H_HelmetB_Enh_tna_F, H_HelmetSpecB_wdl, H_HelmetHBK_headset_F, H_HelmetHBK_chops_F, H_HelmetHBK_ear_F",
    1
] call CBA_fnc_addSetting;

[
    "XK_6DOF_headgearToggle",
    "CHECKBOX",
    ["Enable 6DOF on Headgear", "Enable sensors to track targets on headgear. When disabled, goggles will both render and track targets."],
    "EagleEye 6DOF",
    true,
    1
] call CBA_fnc_addSetting;

[
    "XK_6DOF_Debug",
    "CHECKBOX",
    ["Enable Debug Mode", "Show debug information."],
    "EagleEye 6DOF",
    false,
    1
] call CBA_fnc_addSetting;

//Initializes 6DOF for non-respawn starts
if (hasInterface) then {
    [
        {(player == player)},
        {
            diag_log text "[6DOF] [Init] Player is initalized. Applying 6DOF event handlers.";
            [player] call XK_6DOF_fnc_respawnEH;
        },
        nil,
        60,
        {}
    ] call CBA_fnc_waitUntilAndExecute;
};
diag_log text "[6DOF] Finished initializing EagleEye 6DOF.";

//Globally broadcasted targets calculated server-side
if !(isServer) exitWith {};
diag_log text "[6DOF] Server/Host detected. Running server-side target list PFH.";

//Create global array for all 6DOF tracked targets
[{
    //6DOF Target List
    private _canSee = allUnits select {_x getVariable ["XK_6DOF_enable",false]};
    private _newTargetsList = [];
    
    if (count _canSee > 0) then {
        private _targetsList = [];
        {
            private _list = _x getVariable ["XK_6DOF_List",[]];
            if !(isNil "_list") then {_targetsList append _list};
        } forEach _canSee;
        
        _newTargetsList = _targetsList arrayIntersect _targetsList;
        missionNamespace setVariable ["XK_6DOF_Targets",_newTargetsList, true];
    };

    //UAV Target List
    private _canSeeUAV = allUnitsUAV select {_x getVariable ["XK_6DOF_enable", false]};
    if (count _canSeeUAV isEqualTo 0) exitWith {};
    private _uavTargetsList = [];

    {
        private _listUAV = _x getVariable ["XK_6DOF_List",[]];
        if (count _listUAV > 0) then {_uavTargetsList append _listUAV};
    } forEach _canSeeUAV;


    _uavTargetsList = [_uavTargetsList, {_this in _newTargetsList}] call CBA_fnc_reject;
    _uavTargetsList arrayIntersect _uavTargetsList;
    /* {
        private _index = _uavTargetsList find _x;
        if (_index isNotEqualTo -1) then {
            _uavTargetsList deleteAt _index;
        };
    }forEach _newTargetsList; */

    missionNamespace setVariable ["XK_6DOF_targetsUAV",_uavTargetsList, true];
},1,[]] call CBA_fnc_addPerFrameHandler;

//Global marked target list
missionNamespace setVariable ["XK_6DOF_markedList", [], true];

//Global event to increment marked targets
["XK_6DOF_EH_targetIncr", {
    
    params ["_target"];
    private _list = missionNamespace getVariable ["XK_6DOF_markedList",[]];
    private _targetIndex = _list findIf {_x isEqualTo _target};
    
    //If target is marked, unmark them
    if (_targetIndex isNotEqualTo -1) then {
        _list set [_targetIndex, nil];
        missionNamespace setVariable ["XK_6DOF_markedList",_list];
        _target setVariable ["XK_6DOF_Marked",nil, true];

    } else {

        //If no targets marked, then pushback, else increment targets and update variables
        if (count _list isEqualTo 0) then {
            _list pushBack _target;
            missionNamespace setVariable ["XK_6DOF_markedList",_list];
            _target setVariable ["XK_6DOF_Marked",0, true];
        } else {

            private _index = _list findIf {isNil "_x"};
            if (_index isEqualTo -1) then {
                _index = _list pushBack _target;
            } else {
                _list set [_index, _target];
            };

            missionNamespace setVariable ["XK_6DOF_markedList", _list];
            _target setVariable ["XK_6DOF_Marked", _index, true];
        };
    };
}] call CBA_fnc_addEventHandler;

