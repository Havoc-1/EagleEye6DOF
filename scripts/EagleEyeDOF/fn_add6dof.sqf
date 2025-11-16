/* 
    Author: [DMCL] Xephros
    Function to add 6DOF vision to a unit.
    
    Arguments:
        0: Target <UNIT> - Enable 6DOF on unit.
        1: Search Distance <NUMBER> - Max distance to consider targets.
        2: Field of View <NUMBER> (Optional) - FOV for tracking targets. Min 10, Max 80. Default 40.
    
    Return Value: None

    Example:
        [this] call XK_6DOF_fnc_add6dof;
        [this, 200, 60] call XK_6DOF_fnc_add6dof;
*/

params ["_unit",["_searchDist",XK_6DOF_scanList],["_fov", 40]];

if (isNil "_unit" || isNull _unit) exitWith {
    ["Invalid unit selected. Exiting fn_add6dof.sqf", "add6dof",1] call XK_6DOF_fnc_diaglog;
};

private _6dof = _unit getVariable ["XK_6DOF_enable", false];
private _scanPFH = _unit getVariable ["XK_6DOF_scanPFH", nil];

if (_6dof || !isNil "_scanPFH") exitWith {
    [format ["%1 %2 is already has 6DOF enabled. exiting fn_add6dof.sqf.", name _unit, getPosATL _unit], "add6dof",1] call XK_6DOF_fnc_diaglog;
};

_unit setVariable ["XK_6DOF_enable", true, true];
[format ["Enabled 6DOF on %1 %2", name _unit, getPosATL _unit], "add6dof",1] call XK_6DOF_fnc_diaglog;

//Limit FOV on unit, limited for performance purposes
if (_fov < 10 || _fov > 80) then {
    [format ["6DOF FOV on %1 %2 out of range (%3), FOV clamped between 10 and 80.", name _unit, getPosATL _unit, _fov], "add6dof"] call XK_6DOF_fnc_diaglog;
    _fov max 80 min 10;
};

[format ["Started 6DOF Target Scan PFH on %1 %2", name _unit, getPosATL _unit], "add6dof"] call XK_6DOF_fnc_diaglog;
private _id = [
    {
        _args params ["_unit","_searchDist","_fov"];
        private _PFHid = _unit getVariable ["XK_6DOF_scanPFH", nil];
        
        //Exit PFH checks
        if (isNull _unit || isNil "_unit") exitWith {[_this select 1] call CBA_fnc_removePerFrameHandler};
        if (isNil "_PFHid" || _PFHid isNotEqualTo (_this select 1)) exitWith {
            [format ["Mismatch PFH ID: %1 (Current) | %2 (New). Exiting current PFH on %3 %4.", _PFHid, (_this select 1), name _unit, getPosATL _unit], "add6dof",1] call XK_6DOF_fnc_diaglog;
            [_this select 1] call CBA_fnc_removePerFrameHandler;
        };
        if !(alive _unit) exitWith {
            [format ["%1 %2 has died. Exiting 6DOF PFH.",name _unit, getPosATL _unit], "add6dof"] call XK_6DOF_fnc_diaglog;
            _unit setVariable ["XK_6DOF_enable", nil, true];
            _unit setVariable ["XK_6DOF_scanPFH", nil];
            [_this select 1] call CBA_fnc_removePerFrameHandler;
        };
        if !(_unit getVariable ["XK_6DOF_enable", false]) exitWith {
            [format ["6DOF disabled on %1 %2. Exiting 6DOF PFH.",name _unit, getPosATL _unit], "add6dof"] call XK_6DOF_fnc_diaglog;
            _unit setVariable ["XK_6DOF_scanPFH", nil];
            [_this select 1] call CBA_fnc_removePerFrameHandler;
        };

        private _targets = [];
        private _searchList = ([getPosATL _unit, _searchDist*2, _searchDist*2, 0, false] nearEntities [["CAManBase","LandVehicle"], false, true, true]) select {_x != _unit};
        {
            _targets append (if (isNull objectParent _x) then {[_x]} else {crew _x});
        } forEach _searchList;
        
        _targets = _targets select {
            (((eyeDirection _unit) vectorDotProduct (eyePos _unit vectorFromTo eyePos _x)) >= cos (_fov/2)) &&
            (([objNull,"VIEW"] checkVisibility [eyePos _unit, eyePos _x] > 0.5) || ([objNull,"VIEW"] checkVisibility [eyePos _unit, (_x modelToWorldVisualWorld (_x selectionPosition "spine2"))] > 0.5))
        };

        if (_targets isNotEqualTo []) then {
            _targets = flatten _targets;
            _targets = _targets arrayIntersect _targets;
        };
        
        ["XK_6DOF_EH_addTargetList", [_targets]] call CBA_fnc_serverEvent;
    },
    1,
    [_unit, _searchDist, _fov]
] call CBA_fnc_addPerFrameHandler;

_unit setVariable ["XK_6DOF_scanPFH", _id];