/* 
    Author: [DMCL] Xephros
    Condition gate to enable 6DOF overlay on unit. Handles draw3D EH and 6DOF target scan PFH variables.

    Return Value: None

    Example:
        [player] call XK_6DOF_fnc_enableOverlay;
*/

params ["_unit"];
//UNTESTED ON AI UNITS, WILL TROUBLESHOOT IN A LATER ITERATION
if (!hasInterface || _unit isNotEqualTo player) exitWith {};

private _hasHeadgear = false;
if (XK_6DOF_headgearToggle) then {
    private _headgearList = XK_6DOF_headgearList splitString ",";
    if !(headgear _unit in _headgearList) then {
        _unit setVariable ["XK_6DOF_enable", nil, true];

        if (isPlayer _unit) then {
            private _id = missionNamespace getVariable ["XK_6DOF_scanPFH", nil];
            if !(isNil "_id") then {
                [_id] call CBA_fnc_removePerFrameHandler;
                missionNamespace setVariable ["XK_6DOF_scanPFH", nil];
            };
        };
    } else {
        _hasHeadgear = true;
    };
};

//Add 6dof tracking if goggles are on
private _goggles = goggles _unit;
if ((_goggles in XK_6DOF_gogglesList) && (_goggles isNotEqualTo "")) then {
    [_unit] call XK_6DOF_fnc_add6dof;
    if (isPlayer _unit) then {
        private _id = addMissionEventHandler ["Draw3D", {call XK_6DOF_fnc_draw3Dsort}];
        missionNamespace setVariable ["XK_6DOF_draw3D", _id];
    };

} else {

    if (isPlayer _unit) then {
        private _id = missionNamespace getVariable ["XK_6DOF_draw3D", nil];
        if !(isNil "_id") then {
            removeMissionEventHandler ["Draw3D", _id];
            diag_log text format ["[6DOF] [enableOverlay] Draw3D MissionEventHandler removed for %1 %2", name _unit, getPosATL _unit];
        };
    };
    if !(_hasHeadgear) then {

        _unit setVariable ["XK_6DOF_enable", nil, true];
        diag_log text format ["[6DOF] [enableOverlay] Variable XK_6DOF_enable removed for %1 %2", name _unit, getPosATL _unit];

        if (isPlayer _unit) then {
            private _id = missionNamespace getVariable ["XK_6DOF_scanPFH", nil];
            if !(isNil "_id") then {
                [_id] call CBA_fnc_removePerFrameHandler;
                missionNamespace setVariable ["XK_6DOF_scanPFH", nil];
                diag_log text format ["[6DOF] [enableOverlay] XK_6DOF_scanPFH removed for %1 %2", name _unit, getPosATL _unit];
            };
        };
    };
};
diag_log text format ["[6DOF] [enableOverlay] Unit: %1 %2 | Goggles: %3 (%4) | hasHeadgear: %5 (%6) | Headgear Toggle: %7", name _unit, getPosATL _unit, (_goggles in XK_6DOF_gogglesList && _goggles isNotEqualTo ""), _goggles, _hasHeadgear, headgear _unit, XK_6DOF_headgearToggle];
