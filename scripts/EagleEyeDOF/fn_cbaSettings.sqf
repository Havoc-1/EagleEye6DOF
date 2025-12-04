/* 
    Author: [DMCL] Xephros
    Init CBA Settings for 6DOF
*/

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
    "XK_6DOF_iffOpacity",
    "SLIDER",
    ["IFF Icon Opacity","Opacity for IFF icons above targets."],
    "EagleEye 6DOF",
    [0, 1, 0.8, 0, true],
    0
] call CBA_fnc_addSetting;

[
    "XK_6DOF_colorAlly",
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
    false,
    1
] call CBA_fnc_addSetting;

[
    "XK_6DOF_unconCheck",
    "CHECKBOX",
    ["Scan Unconscious Targets", "Enable sensors to scan and display unconscious targets. If disabled, unconscious enemy and unknown targets will not be displayed. User marked targets will still display when unconscious."],
    "EagleEye 6DOF",
    false,
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

[
    "XK_6DOF_DebugRPT",
    "CHECKBOX",
    ["Detailed Diag_Log Reports", "Push optional information to diag_log RPT logs."],
    "EagleEye 6DOF",
    false,
    0
] call CBA_fnc_addSetting;

XK_6DOF_initCbaSettings = true;
["Finished initializing EagleEye 6DOF CBA Settings.", "cbaSettings",1] call XK_6DOF_fnc_diaglog;