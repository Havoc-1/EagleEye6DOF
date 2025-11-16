params ["_str", "_src", ["_push", 0]];

if (XK_6DOF_DebugRPT || (_push isEqualTo 0)) then {
    if (_push <= 1) then {
        diag_log text format ["[6DOF] [%1] %2", _src, _str];
    } else {
        systemChat format ["[6DOF] [%1] %2", _src, _str];
    };
};