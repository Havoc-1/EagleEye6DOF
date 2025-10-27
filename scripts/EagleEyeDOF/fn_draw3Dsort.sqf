/* 
    Author: [DMCL] Xephros
    Filters targets to display on HUD. Called in draw3D Event Handler.

    Example:
        addMissionEventHandler ["Draw3D", {call XK_6DOF_fnc_draw3Dsort}];
*/

private _sidePlayer = side player;

//Faction Colors
private _colorAlly = XK_6DOF_colorAlly;
private _colorTarget = XK_6DOF_colorTarget;
private _colorUnknown = XK_6DOF_colorUnknown;
_colorAlly set [3,1];
_colorTarget set [3,1];
_colorUnknown set [3,1];


//6DOF units
private _6dofUnits = allUnits select {_x getVariable ["XK_6DOF_enable", false]};
if (count _6dofUnits isEqualTo 0) exitWith {};
{
    if (side _x isEqualTo _sidePlayer) then {[_x,_colorAlly,XK_6DOF_iconEagleEye,true,true,name _x] call XK_6DOF_fnc_renderBones}
} forEach _6dofUnits;

// Get globally tracked targets
private _targetLists = [
    missionNamespace getVariable ["XK_6DOF_Targets", []],
    missionNamespace getVariable ["XK_6DOF_targetsUAV", []]
];
if ((count (_targetLists select 0) isEqualTo 0) && (count (_targetLists select 1) isEqualTo 0)) exitWith {};

//HashMap Filter
private _targets = createHashMapFromArray [
    ["ally", []],
    ["enemy", []],
    ["enemyUAV", []],
    ["unknown", []],
    ["unknownUAV", []]
];

//Categorise targets
{
    private _isUAV = (_forEachIndex isEqualTo 1);
    {
        private _unit = _x;
        private _side = side _unit;
        private _is6DOF = _unit getVariable ["XK_6DOF_enable", false];
        private _armed = currentWeapon _unit isNotEqualTo "";

        if (!_is6DOF) then {
            if (_side isEqualTo _sidePlayer) then {
                (_targets get "ally") pushBack _unit;
            } else {
                if (XK_6DOF_enableUnknown) then {
                    if (_armed) then {
                        (_targets get (["enemy","enemyUAV"] select _isUAV)) pushBack _unit;
                    } else {
                        (_targets get (["unknown","unknownUAV"] select _isUAV)) pushBack _unit;
                    };
                } else {
                    if (_armed) then {
                        (_targets get (["enemy","enemyUAV"] select _isUAV)) pushBack _unit;
                    };
                };
            };
        };
    } forEach _x;
} forEach _targetLists;

//Render allies
{[_x,_colorAlly,XK_6DOF_iconAlly,false,true,"Allied"] call XK_6DOF_fnc_renderBones} forEach (_targets get "ally");

//Render enemies
{[_x,_colorTarget,XK_6DOF_iconEnemy] call XK_6DOF_fnc_renderBones} forEach (_targets get "enemy");
{[_x,_colorTarget,XK_6DOF_iconEnemy,false] call XK_6DOF_fnc_renderBones} forEach (_targets get "enemyUAV");

//Render unknowns (if enabled)
if (XK_6DOF_enableUnknown) then {
    {[_x,_colorUnknown,XK_6DOF_iconUnknown] call XK_6DOF_fnc_renderBones} forEach (_targets get "unknown");
    {[_x,_colorUnknown,XK_6DOF_iconUnknown,false] call XK_6DOF_fnc_renderBones} forEach (_targets get "unknownUAV");
};
