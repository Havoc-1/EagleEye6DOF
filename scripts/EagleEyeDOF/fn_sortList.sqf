params [["_sidePlayer", side player]];

// Get globally tracked targets
private _targetLists = [
    missionNamespace getVariable ["XK_6DOF_Targets", []],
    missionNamespace getVariable ["XK_6DOF_targetsUAV", []]
];

if (((_targetLists select 0) isEqualTo []) && ((_targetLists select 1) isEqualTo [])) exitWith {};

//HashMap Filter
private _targets = createHashMapFromArray [
    ["ally", []],
    ["enemy", []],
    ["enemyUAV", []],
    ["unknown", []],
    ["unknownUAV", []]
];

{//Categorise targets
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

//Return Value
[_targets get "ally", _targets get "enemy", _targets get "enemyUAV", _targets get "unknown", _targets get "unknownUAV"];