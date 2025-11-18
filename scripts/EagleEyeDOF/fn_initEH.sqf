["XK_6DOF_EH_addTargetList", {

    params [["_targetList",[]],["_isUAV", false]];

    if !(_isUAV) then {
        XK_6DOF_serverList append _targetList;
        XK_6DOF_serverList = XK_6DOF_serverList arrayIntersect XK_6DOF_serverList;
    } else {
        XK_6DOF_serverListUAV append _targetList;
        XK_6DOF_serverListUAV = XK_6DOF_serverListUAV arrayIntersect XK_6DOF_serverListUAV;
    };
}] call CBA_fnc_addEventHandler;

//Updates missionNamespace for 6DOF player locally
["XK_6DOF_EH_sendTargetList", {

    _this params [["_targetList",[]],["_isUAV", false]];
    private _namespace = if !(_isUAV) then {"XK_6DOF_Targets"} else {"XK_6DOF_TargetsUAV"};
    missionNamespace setVariable [_namespace, _targetList];

}] call CBA_fnc_addEventHandler;

//Global event to increment marked targets
["XK_6DOF_EH_targetIncr", {
    
    params ["_target"];
    private _list = missionNamespace getVariable ["XK_6DOF_markedList",[]];
    private _targetIndex = _list findIf {_x isEqualTo _target};
    
    //If target is marked, unmark them
    if (_targetIndex isNotEqualTo -1) then {
        _list set [_targetIndex, nil];
        missionNamespace setVariable ["XK_6DOF_markedList",_list];
        _target setVariable ["XK_6DOF_Marked",nil, true];

    } else {

        //If no targets marked, then pushback, else increment targets and update variables
        if (_list isEqualTo []) then {
            _list pushBack _target;
            missionNamespace setVariable ["XK_6DOF_markedList",_list];
            _target setVariable ["XK_6DOF_Marked",0, true];
        } else {

            private _index = _list findIf {isNil "_x"};
            if (_index isEqualTo -1) then {
                _index = _list pushBack _target;
            } else {
                _list set [_index, _target];
            };

            missionNamespace setVariable ["XK_6DOF_markedList", _list];
            _target setVariable ["XK_6DOF_Marked", _index, true];
        };
    };
}] call CBA_fnc_addEventHandler;