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
private _opacity = XK_6DOF_iffOpacity;
_colorAlly set [3,_opacity];
_colorTarget set [3,_opacity];
_colorUnknown set [3,_opacity];

private _iconEagleEye = XK_6DOF_iconEagleEye;
private _iconAlly = XK_6DOF_iconAlly;
private _iconEnemy = XK_6DOF_iconEnemy;
private _iconUnknown = XK_6DOF_iconUnknown;

private _enableUnknown = XK_6DOF_enableUnknown;

private _sidePlayer = side player;
private _sortedList = [_sidePlayer] call XK_6DOF_fnc_sortList;
_sortedList params ["_listAllies","_listEnemy","_listEnemyUAV","_listUnknown","_listUnknownUAV"];

//6DOF units
private _6dofUnits = allUnits select {_x getVariable ["XK_6DOF_enable", false]};
if (_6dofUnits isEqualTo []) exitWith {};
{
    if (side _x isEqualTo _sidePlayer) then {[_x,_colorAlly,_iconEagleEye,true,true,name _x] call XK_6DOF_fnc_renderBones}
} forEach _6dofUnits;

//Render allies
{[_x,_colorAlly,_iconAlly,false,true,"Allied"] call XK_6DOF_fnc_renderBones} forEach _listAllies;

//Render enemies
{[_x,_colorTarget,_iconEnemy] call XK_6DOF_fnc_renderBones} forEach _listEnemy;
{[_x,_colorTarget,_iconEnemy,false] call XK_6DOF_fnc_renderBones} forEach _listEnemyUAV;

//Render unknowns (if enabled)
if (_enableUnknown) then {
    {[_x,_colorUnknown,_iconUnknown] call XK_6DOF_fnc_renderBones} forEach _listUnknown;
    {[_x,_colorUnknown,_iconUnknown,false] call XK_6DOF_fnc_renderBones} forEach _listUnknownUAV;
};