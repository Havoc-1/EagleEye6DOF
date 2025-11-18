params ["_str", "_src", ["_push", 0]];

if (_push isEqualTo 0) then {
    diag_log text format ["[6DOF] [%1] %2", _src, _str];
} else {
    if !(XK_6DOF_DebugRPT) exitWith {};
    switch (_push) do {
        case 1: {diag_log text format ["[6DOF] [%1] %2", _src, _str]};
        case 2: {systemChat format ["[6DOF] [%1] %2", _src, _str]};
        case 3: {hintSilent format ["[6DOF] [%1]\n\n%2", _src, _str]};
        default {diag_log text format ["[6DOF] [%1] %2", _src, _str]};
    };
};