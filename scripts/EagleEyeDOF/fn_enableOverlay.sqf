/*
    Author: [DMCL] Xephros
    Condition gate to enable 6DOF overlay on unit. Handles draw3D EH and 6DOF target scan PFH variables.
    
    Return Value: None
    
    Example:
    [player] call XK_6DOF_fnc_enableOverlay;
*/

params ["_unit"];

if (!hasInterface || _unit isNotEqualTo player || isNull _unit || isNil "_unit") exitWith {};

private _hasHeadgear = false;
private _headgear = headgear _unit;
private _PFHid = _unit getVariable ["XK_6DOF_scanPFH", nil];
private _6dof = _unit getVariable ["XK_6DOF_enable", false];
/* if !(isNil "_PFHid") then {
    [format ["ScanPFH (%1) removed for %2 %3", name _unit, getPosATL _unit], "enableOverlay",1] call XK_6DOF_fnc_diaglog;
}; */

if (XK_6DOF_headgearToggle) then {
    
    if (!(_headgear in XK_6DOF_headgearList) || _headgear isEqualTo "") then {

        _unit setVariable ["XK_6DOF_enable", nil, true];
        
        if (!isNil "_PFHid") then {
            [_PFHid] call CBA_fnc_removePerFrameHandler;
            _unit setVariable ["XK_6DOF_scanPFH", nil];
            [format ["ScanPFH (%1) removed for %2 %3", name _unit, getPosATL _unit], "enableOverlay",1] call XK_6DOF_fnc_diaglog;
        };
    } else {_hasHeadgear = true};
} else {_hasHeadgear = true};

private _goggles = goggles _unit;
if ((_goggles in XK_6DOF_gogglesList) && (_goggles isNotEqualTo "")) then {
    if (isPlayer _unit) then {
        private _id = addMissionEventHandler ["Draw3D", { call XK_6DOF_fnc_draw3Dsort }];
        missionNamespace setVariable ["XK_6DOF_draw3D", _id];
    };
} else {
    if (isPlayer _unit) then {
        private _id = missionNamespace getVariable ["XK_6DOF_draw3D", nil];
        if !(isNil "_id") then {
            removeMissionEventHandler ["Draw3D", _id];
            [format ["Draw3D MissionEventHandler removed for %1 %2",name _unit, getPosATL _unit], "enableOverlay",1] call XK_6DOF_fnc_diaglog;
        };
    };
};

if (_hasHeadgear) then {
    [_unit] call XK_6DOF_fnc_add6dof;
} else {
    
    if (_6dof) then {
        _unit setVariable ["XK_6DOF_enable", nil, true];
        [format ["Variable XK_6DOF_enable removed for %1 %2",name _unit, getPosATL _unit], "enableOverlay",1] call XK_6DOF_fnc_diaglog;
    };

    if (isPlayer _unit) then {
        if !(isNil "_PFHid") then {
            [_PFHid] call CBA_fnc_removePerFrameHandler;
            _unit setVariable ["XK_6DOF_scanPFH", nil];

            [format ["XK_6DOF_scanPFH removed for %1 %2",name _unit, getPosATL _unit], "enableOverlay",1] call XK_6DOF_fnc_diaglog;
        };
    };
};

[
    format [
        "Unit: %1 %2 | Goggles: %3 (%4) | hasHeadgear: %5 (%6) | Headgear Toggle: %7",
        name _unit,
        getPosATL _unit,
        (_goggles in XK_6DOF_gogglesList && _goggles isNotEqualTo ""),
        _goggles,
        _hasHeadgear,
        headgear _unit,
        XK_6DOF_headgearToggle
    ],
    "enableOverlay",
    1
] call XK_6DOF_fnc_diaglog;

