/* 
    Author: [DMCL] Xephros
    Filters targets to display on HUD. Called in draw3D Event Handler.

    Example:
        addMissionEventHandler ["Draw3D", {call XK_6DOF_fnc_draw3Dsort}];
*/

//Render friendly for 6DOF units
private _6dofUnits = allUnits select {_x getVariable ["XK_enable6dof",false]};
if (count _6dofUnits == 0) exitWith {};
private _colorAlly = DOF_colorAlly;
_colorAlly pushBack 1;
{[_x,_colorAlly,DOF_icon6DOF, true, true, name _x] call XK_6DOF_fnc_renderBones} forEach (_6dofUnits select {side _x == side player});

//Get globally tracked targets
private _targetList = missionNamespace getVariable ["XK_6dofTargets",[]];
private _targetListUAV = missionNamespace getVariable ["XK_6dofTargetsUAV",[]];
if (count _targetList isEqualTo 0 && count _targetListUAV isEqualTo 0) exitWith {};

//Render non-6DOF allies
private _targetListAlly = _targetList select {(side _x == side player) && !(_x in _6dofUnits)};
private _targetListAllyUAV = _targetListUAV select {(side _x == side player) && !(_x in _6dofUnits)};
{[_x,_colorAlly,DOF_iconAlly,false, true, "Allied"] call XK_6DOF_fnc_renderBones} forEach _targetListAlly;
{[_x,_colorAlly,DOF_iconAlly,false, true, "Allied"] call XK_6DOF_fnc_renderBones} forEach _targetListAllyUAV;

//Render enemies and filter unknown targets if DOF_enableUnknown is true
private _colorTarget = DOF_colorTarget;
_colorTarget pushBack 1;
private _targetListEnemy = [];
private _targetListEnemyUAV = [];

if (DOF_enableUnknown) then {
    _targetListEnemy = _targetList select {(side _x != side player) && (currentWeapon _x isNotEqualTo "")};
    _targetListEnemyUAV = _targetListUAV select {(side _x != side player) && (currentWeapon _x isNotEqualTo "")};
} else {
    _targetListEnemy = _targetList select {side _x != side player};
    _targetListEnemyUAV = _targetListUAV select {side _x != side player};
};

{[_x,_colorTarget,DOF_iconEnemy] call XK_6DOF_fnc_renderBones} forEach _targetListEnemy;
{[_x,_colorTarget,DOF_iconEnemy, false] call XK_6DOF_fnc_renderBones} forEach _targetListEnemyUAV;

//Render unknown
if !(DOF_enableUnknown) exitWith {};
private _colorUnknown = DOF_colorUnknown;
_colorUnknown pushBack 1;
private _targetListUnknown = _targetList select {(side _x != side player) && (currentWeapon _x isEqualTo "")};
private _targetListUnknownUAV = _targetListUAV select {(side _x != side player) && (currentWeapon _x isEqualTo "")};
{[_x,_colorUnknown,DOF_iconUnknown] call XK_6DOF_fnc_renderBones} forEach _targetListUnknown;
{[_x,_colorUnknown,DOF_iconUnknown,false] call XK_6DOF_fnc_renderBones} forEach _targetListUnknownUAV;