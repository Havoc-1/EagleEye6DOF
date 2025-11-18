/* 
    Author: [DMCL] Xephros
    Filters targets to display on HUD. Called in draw3D Event Handler.

    Example:
        addMissionEventHandler ["Draw3D", {call XK_6DOF_fnc_draw3Dsort}];
*/

if (player getVariable ["ACE_isUnconscious", false]) exitWith {};
if (XK_6DOF_filterNVG && (currentVisionMode player isEqualTo 0)) exitWith {};

//Faction Colors
private _colorAlly = XK_6DOF_colorAlly;
private _colorTarget = XK_6DOF_colorTarget;
private _colorUnknown = XK_6DOF_colorUnknown;
_colorAlly set [3,1];
_colorTarget set [3,1];
_colorUnknown set [3,1];

private _sidePlayer = side player;
private _sortedList = [_sidePlayer] call XK_6DOF_fnc_sortList;
_sortedList params ["_listAllies","_listEnemy","_listEnemyUAV","_listUnknown","_listUnknownUAV"];

//6DOF units
private _6dofUnits = allUnits select {_x getVariable ["XK_6DOF_enable", false]};
if (count _6dofUnits isEqualTo 0) exitWith {};
{
    if (side _x isEqualTo side player) then {[_x,_colorAlly,XK_6DOF_iconEagleEye,true,true,name _x] call XK_6DOF_fnc_renderBones}
} forEach _6dofUnits;

//Render allies
{[_x,_colorAlly,XK_6DOF_iconAlly,false,true,"Allied"] call XK_6DOF_fnc_renderBones} forEach _listAllies;

//Render enemies
{[_x,_colorTarget,XK_6DOF_iconEnemy] call XK_6DOF_fnc_renderBones} forEach _listEnemy;
{[_x,_colorTarget,XK_6DOF_iconEnemy,false] call XK_6DOF_fnc_renderBones} forEach _listEnemyUAV;

//Render unknowns (if enabled)
if (XK_6DOF_enableUnknown) then {
    {[_x,_colorUnknown,XK_6DOF_iconUnknown] call XK_6DOF_fnc_renderBones} forEach _listUnknown;
    {[_x,_colorUnknown,XK_6DOF_iconUnknown,false] call XK_6DOF_fnc_renderBones} forEach _listUnknownUAV;
};

//[format ["%1, %2, %3, %4, %5", count _listAllies, count _listEnemy, count _listEnemyUAV, count _listUnknown, count _listUnknownUAV], "draw3DSort", 3] call XK_6DOF_fnc_diaglog;