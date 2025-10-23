/* 
    Author: [DMCL] Xephros
    Init for 6DOF
*/

private _cbaCheck = isClass(configFile >> "CfgPatches" >> "cba_main");
if !(_cbaCheck) exitWith {diag_log text format ["[6DOF] Failed to initialize EagleEye 6DOF, dependencies not loaded. CBA_A3: %1",_cbaCheck]};
diag_log text "[6DOF] Initializing EagleEye 6DOF.";



DOF_iconAlly = "\A3\ui_f\data\map\markers\nato\b_unknown.paa";         //IFF Icon for Friendly Targets
DOF_icon6DOF = "\A3\ui_f\data\map\markers\nato\b_inf.paa";             //IFF Icon for Friendly 6DOF Users
DOF_iconEnemy = "\A3\ui_f\data\map\markers\nato\o_unknown.paa";        //IFF Icon for Enemy Targets
DOF_iconUnknown = "\A3\ui_f\data\map\markers\nato\o_unknown.paa";      //IFF Icon for Unknown Targets (Requires DOF_enableUnknown set to true)
DOF_iconUAV = "\A3\ui_f\data\map\markers\nato\b_uav.paa";              //IFF Icon for Self when operating UAV camera

//Initialize CBA Settings

// SLIDER --- extra arguments: [_min, _max, _default, _trailingDecimals, _isPercentage]
[
    "DOF_scanDist",
    "SLIDER",
    ["Scan Range","Maximum distance in metres from EagleEye user to register as target. May affect performance if set too high."],
    "EagleEye 6DOF",
    [50, 300, 200, 0],
    1
] call CBA_fnc_addSetting;

[
    "DOF_Nametags",
    "CHECKBOX",
    ["Enable Nametags", "Shows name of 6DOF users next to bounding box when within 15m."],
    "EagleEye 6DOF",
    true,
    1
] call CBA_fnc_addSetting;

[
    "DOF_colorAlly",
    "COLOR",
    ["Friendly IFF","Color for friendly targets"],
    "EagleEye 6DOF",
    [0.05, 0.05, 1]
] call CBA_fnc_addSetting;

[
    "DOF_colorTarget",
    "COLOR",
    ["Enemy IFF","Color for enemy targets"],
    "EagleEye 6DOF",
    [1, 0, 0]
] call CBA_fnc_addSetting;

[
    "DOF_colorUnknown",
    "COLOR",
    ["Enemy IFF","Color for unknown targets"],
    "EagleEye 6DOF",
    [0.4, 0, 0.5]
] call CBA_fnc_addSetting;

[
    "DOF_enableUnknown",
    "CHECKBOX",
    ["Enable Unknown Targets", "Marks unarmed targets as unknown instead of enemy."],
    "EagleEye 6DOF",
    true,
    1
] call CBA_fnc_addSetting;

[
    "DOF_gogglesList",
    "EDITBOX",
    ["Goggles Whitelist", "Classnames of goggles to enable 6DOF. Array/string format not required. Example: G_Goggles_VR, G_Tactical_Clear,..."],
    "EagleEye 6DOF",
    "G_Goggles_VR, G_Tactical_Clear, G_Tactical_Black, G_Tactical_camo, G_Tactical_yellow",
    1
] call CBA_fnc_addSetting;

[
    "DOF_gogglesToggle",
    "CHECKBOX",
    ["Enable 6DOF on Goggles", "Enable 6DOF overlay for Goggles Whitelist items"],
    "EagleEye 6DOF",
    true,
    1
] call CBA_fnc_addSetting;

[
    "DOF_headgearList",
    "EDITBOX",
    ["Headgear Whitelist", "Classnames of headgear to enable 6DOF. Array/string format not required. Example: Helmet1, Hat2, ..."],
    "EagleEye 6DOF",
    "NVGogglesB_blk_F, NVGogglesB_grn_F, NVGogglesB_gry_F",
    1
] call CBA_fnc_addSetting;

[
    "DOF_headgearToggle",
    "CHECKBOX",
    ["Enable 6DOF on Headgear", "Enable sensors to track targets on headgear. When disabled, goggles will both render and track targets."],
    "EagleEye 6DOF",
    true,
    1
] call CBA_fnc_addSetting;

[
    "DOF_Debug",
    "CHECKBOX",
    ["Enable Debug Mode", "Show debug information."],
    "EagleEye 6DOF",
    false,
    1
] call CBA_fnc_addSetting;

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
[{
    //6DOF Target List
    private _canSee = allUnits select {_x getVariable ["XK_enable6dof",false]};
    private _newTargetsList = [];
    
    if (count _canSee > 0) then {
        private _targetsList = [];
        {
            private _list = _x getVariable ["XK_6dofList",[]];
            if !(isNil "_list") then {_targetsList append _list};
        } forEach _canSee;
        
        _newTargetsList = _targetsList arrayIntersect _targetsList;
        missionNamespace setVariable ["XK_6dofTargets",_newTargetsList, true];
    };

    //UAV Target List
    private _canSeeUAV = allUnitsUAV select {_x getVariable ["XK_enable6dof", false]};
    if (count _canSeeUAV isEqualTo 0) exitWith {};
    private _uavTargetsList = [];

    {
        private _listUAV = _x getVariable ["XK_6dofList",[]];
        if (count _listUAV > 0) then {_uavTargetsList append _listUAV};
    } forEach _canSeeUAV;

    {
        private _index = _uavTargetsList find _x;
        if (_index isNotEqualTo -1) then {
            _uavTargetsList deleteAt _index;
        };
    }forEach _newTargetsList;

    missionNamespace setVariable ["XK_6dofTargetsUAV",_uavTargetsList, true];
},1,[]] call CBA_fnc_addPerFrameHandler;