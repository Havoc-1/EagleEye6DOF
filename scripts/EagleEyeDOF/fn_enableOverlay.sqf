/* 
    Author: [DMCL] Xephros
    Condition gate to enable 6DOF overlay on unit. Handles draw3D EH and 6DOF target scan PFH variables.

    Return Value: None

    Example:
        [player] call XK_6DOF_fnc_enableOverlay;
*/

params ["_unit"];
//UNTESTED ON AI UNITS, WILL TROUBLESHOOT IN A LATER ITERATION
if !(hasInterface || _unit == player) exitWith {};

private _hasHeadgear = false;
if (DOF_headgearToggle) then {
    private _headgearList = DOF_headgearList splitString ",";
    if !(headgear _unit in _headgearList) then {
        _unit setVariable ["XK_enable6dof", nil, true];
        _unit setVariable ["XK_6dofList", nil, true];

        if (isPlayer _unit) then {
            private _id = missionNamespace getVariable ["XK_6dofPFH", nil];
            if !(isNil "_id") then {
                [_id] call CBA_fnc_removePerFrameHandler;
                missionNamespace setVariable ["XK_6dofPFH", nil];
            };
        };
    } else {
        _hasHeadgear = true;
    };
};

//Add 6dof tracking if goggles are on
private _goggles = goggles _unit;
if (_goggles in DOF_gogglesList && _goggles isNotEqualTo "") then {
    [_unit] call XK_6DOF_fnc_add6dof;
    if (isPlayer _unit) then {
        private _id = addMissionEventHandler ["Draw3D", {call XK_6DOF_fnc_draw3Dsort}];
        missionNamespace setVariable ["XK_6dofDraw3D", _id];
    };

} else {

    if (isPlayer _unit) then {
        private _id = missionNamespace getVariable ["XK_6dofDraw3D", nil];
        if !(isNil "_id") then {
            removeMissionEventHandler ["Draw3D", _id];
            diag_log text format ["[6DOF] [enableOverlay] Draw3D MissionEventHandler removed for %1 %2", name _unit, getPosATL _unit];
        };
    };
    if !(DOF_headgearToggle) then {

        _unit setVariable ["XK_enable6dof", nil, true];
        _unit setVariable ["XK_6dofList", nil, true];
        diag_log text format ["[6DOF] [enableOverlay] Variables XK_enable6of and XK_6dofList removed for %1 %2", name _unit, getPosATL _unit];

        if (isPlayer _unit) then {
            private _id = missionNamespace getVariable ["XK_6dofPFH", nil];
            if !(isNil "_id") then {
                [_id] call CBA_fnc_removePerFrameHandler;
                missionNamespace setVariable ["XK_6dofPFH", nil];
                diag_log text format ["[6DOF] [enableOverlay] XK_6dofPFH removed for %1 %2", name _unit, getPosATL _unit];
            };
        };
    };
};
diag_log text format ["[6DOF] [enableOverlay] Unit: %1 %2 | Goggles: %3 (%4) | Headgear: %5 (%6) | Headgear Toggle: %7", name _unit, getPosATL _unit, (_goggles in DOF_gogglesList && _goggles isNotEqualTo ""), goggles _unit, _hasHeadgear, headgear _unit, DOF_headgearToggle];
