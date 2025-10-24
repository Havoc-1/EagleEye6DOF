params ["_unit", "_gesture"];

if (_gesture isNotEqualTo "ace_gestures_point") exitWith {};

//Append global target list
private _targetsList = missionNamespace getVariable ["XK_6dofTargets",[]];
private _targetsListUAV = missionNamespace getVariable ["XK_6dofTargetsUAV",[]];
if ((_targetsList isEqualTo []) && (_targetsListUAV isEqualTo [])) exitWith {};
private _list = [];
_list append _targetsList;
_list append _targetsListUAV;

//Init variables
private _maxScreenDist = 0.15;
private _validTargets = [];

//Get all tracked targets and sort by closest to centre of screen.
{
    private _screenPos = worldToScreen ASLToAGL (eyePos _x);
    if !(_screenPos isEqualTo []) then {
        private _dx = (_screenPos select 0) - 0.5;
        private _dy = (_screenPos select 1) - 0.5;
        private _dist = sqrt ((_dx * _dx) + (_dy * _dy));

        if (_dist <= _maxScreenDist) then {
            _validTargets pushBack [_x, _dist];
        };
    };
} forEach _list;
if (_validTargets isEqualTo []) exitWith {};
_validTargets sort true;

//If target is already marked, then unmark, otherwise mark target.
private _markedUnit = _validTargets select 0 select 0;
private _targetNum = missionNamespace getVariable ["XK_6dofMarkNum", 0];
private _isMarked = _markedUnit getVariable ["XK_6dofMarked",nil];

//If already marked, subtract from global target increment and remove variable, else mark target
if !(isNil "_isMarked") then {
    _markedUnit setVariable ["XK_6dofMarked",nil, true];
    //_targetNum = _targetNum - 1;
    //missionNamespace setVariable ["XK_6dofMarkNum", _targetNum, true];
} else {
    _targetNum = _targetNum + 1;
    if (_targetNum > 99) then {_targetNum = 1};
    _markedUnit setVariable ["XK_6dofMarked",_targetNum, true];
    missionNamespace setVariable ["XK_6dofMarkNum", _targetNum, true];
};

