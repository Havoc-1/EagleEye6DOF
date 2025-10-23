params ["_unit", "_gesture"];

if (_gesture isNotEqualTo "ace_gestures_point") exitWith {};

private _targetsList = missionNamespace getVariable ["XK_6dofTargets",[]];
private _targetsListUAV = missionNamespace getVariable ["XK_6dofTargetsUAV",[]];
if ((_targetsList isEqualTo []) && (_targetsListUAV isEqualTo [])) exitWith {};

private _list = [];
_list append _targetsList;
_list append _targetsListUAV;

private _maxScreenDist = 0.15;
private _validTargets = [];

private _distList = [];
{
    private _screenPos = worldToScreen ASLToAGL (eyePos _x);
    if !(_screenPos isEqualTo []) then {
        private _dx = (_screenPos select 0) - 0.5;
        private _dy = (_screenPos select 1) - 0.5;
        private _dist = sqrt ((_dx * _dx) + (_dy * _dy));

        _distList pushback _dist;
        //hintSilent format ["%1, %2", worldToScreen (eyePos _x), _dist];
        if (_dist <= _maxScreenDist) then {
            _validTargets pushBack [_x, _dist];
        };
    };
} forEach _list;

if (_validTargets isEqualTo []) exitWith {};
_validTargets sort true;

private _markedUnit = _validTargets select 0 select 0;
if (_markedUnit getVariable ["XK_6dofMarked",false]) then {
    _markedUnit setVariable ["XK_6dofMarked",nil, true];
} else {
    _markedUnit setVariable ["XK_6dofMarked",true, true];
};

