/* 
    Author: [DMCL] Xephros
    Function to add 6DOF vision to a unit.
    
    Arguments:
        0: Target <UNIT> - Enable 6DOF on unit.
        1: Search Distance <NUMBER> - Max distance to consider targets.
        2: Field of View <NUMBER> - FOV for tracking targets.
    
    Return Value: None

    Example:
        [this] call XK_6DOF_fnc_add6dof;
        [this, 200, 60] call XK_6DOF_fnc_add6dof;
*/

params ["_unit",["_searchDist",XK_6DOF_scanList],["_fov", 40]];

if (isNil "_unit" || isNull _unit) exitWith {diag_log text "[6DOF] [add6dof] Invalid unit selected. Exiting fn_add6dof.sqf"};

if (_unit getVariable ["XK_6DOF_enable", false]) exitWith {diag_log text format ["[6DOF] [add6dof] %1 %2 is already has 6DOF enabled. exiting fn_add6dof.sqf.", name _unit, getPosATL _unit]};

_unit setVariable ["XK_6DOF_enable", true, true];
diag_log text format ["[6DOF] [add6dof] Enabled 6DOF on %1 %2", name _unit, getPosATL _unit];

//Limit FOV on unit, limited for performance purposes
if (_fov < 10) then {
    diag_log text format ["[6DOF] [add6dof] FOV on %1 %2 is too narrow (%3), FOV set to 30.", name _unit, getPosATL _unit, _fov];
    _fov = 10;  
};
if (_fov > 80) then {
    diag_log text format ["[6DOF] [add6dof] FOV on %1 %2 is too wide (%3), FOV set to 180.", name _unit, getPosATL _unit, _fov];
    _fov = 80
};

diag_log text format ["[6DOF] [add6dof] Started 6DOF Target Scan PFH on %1 %2", name _unit, getPosATL _unit];
private _id = [
    {
        _args params ["_unit","_searchDist","_fov"];
        
        //Exit PFH checks
        if (isNull _unit || isNil "_unit") exitWith {[_this select 1] call CBA_fnc_removePerFrameHandler};
        if !(alive _unit) exitWith {
            diag_log text format ["[6DOF] [add6dof] %1 %2 has died. Exiting 6DOF PFH.",name _unit, getPosATL _unit];
            _unit setVariable ["XK_6DOF_enable", nil, true];
            _unit setVariable ["XK_6DOF_List", nil, true];
            missionNamespace setVariable ["XK_6DOF_scanPFH", nil];
            [_this select 1] call CBA_fnc_removePerFrameHandler;
        };
        if !(_unit getVariable ["XK_6DOF_enable", false]) exitWith {
            diag_log text format ["[6DOF] [add6dof] 6DOF disabled on %1 %2. Exiting 6DOF PFH.",name _unit, getPosATL _unit];
            _unit setVariable ["XK_6DOF_List", nil, true];
            missionNamespace setVariable ["XK_6DOF_scanPFH", nil];
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
        _targets = flatten _targets;
        _targetsFilter = _targets arrayIntersect _targets;
        _unit setVariable ["XK_6DOF_List", _targetsFilter, true];
    },
    1,
    [_unit, _searchDist, _fov]
] call CBA_fnc_addPerFrameHandler;

missionNamespace setVariable ["XK_6DOF_scanPFH", _id];