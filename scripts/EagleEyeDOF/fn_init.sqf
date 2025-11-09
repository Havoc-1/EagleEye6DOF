/* 
    Author: [DMCL] Xephros
    Init for 6DOF
*/

private _cbaCheck = isClass(configFile >> "CfgPatches" >> "cba_main");
private _aceCheck = isClass(configFile >> "CfgPatches" >> "ace_main");
if !(_cbaCheck || _aceCheck) exitWith {diag_log text format ["[6DOF] Failed to initialize EagleEye 6DOF, dependencies not loaded. CBA_A3: %1, ACE: %2",_cbaCheck, _aceCheck]};
diag_log text "[6DOF] Initializing EagleEye 6DOF.";

XK_6DOF_iconAlly = "\A3\ui_f\data\map\markers\nato\b_unknown.paa";         //IFF Icon for Friendly Targets
XK_6DOF_iconEagleEye = "\A3\ui_f\data\map\markers\nato\b_inf.paa";         //IFF Icon for Friendly 6DOF Users
XK_6DOF_iconEnemy = "\A3\ui_f\data\map\markers\nato\o_unknown.paa";        //IFF Icon for Enemy Targets
XK_6DOF_iconUnknown = "\A3\ui_f\data\map\markers\nato\o_unknown.paa";      //IFF Icon for Unknown Targets (Requires XK_6DOF_enableUnknown set to true)
XK_6DOF_iconUAV = "\A3\ui_f\data\map\markers\nato\b_uav.paa";              //IFF Icon for Self when operating UAV camera

//Initialize CBA Settings
[] call XK_6DOF_fnc_cbaSettings;

XK_6DOF_serverList = [];
XK_6DOF_serverListOld = [];
XK_6DOF_serverListUAV = [];
XK_6DOF_serverListUAVOld = [];

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
diag_log text "[6DOF] Finished initializing EagleEye 6DOF.";

//Globally broadcasted targets calculated server-side
if !(isServer) exitWith {};
diag_log text "[6DOF] Server/Host detected. Running server-side target list PFH.";

[{
    //6DOF Target List
    private _canSee = allUnits select {_x getVariable ["XK_6DOF_enable",false]};
    if (_canSee isEqualTo []) exitWith {};
    if (XK_6DOF_serverList isNotEqualTo XK_6DOF_serverListOld) then {
        ["XK_6DOF_EH_sendTargetList", [XK_6DOF_serverList], _canSee] call CBA_fnc_targetEvent;
        XK_6DOF_serverListOld = XK_6DOF_serverList;
        
    };
    XK_6DOF_serverList = [];
    
    //UAV Target List
    private _canSeeUAV = allUnitsUAV select {_x getVariable ["XK_6DOF_enable", false]};
    if (_canSeeUAV isEqualTo []) exitWith {};

    //Filter UAV targets
    private _uavTargetsList = XK_6DOF_serverListUAV;
    {
        private _index = _uavTargetsList find _x;
        if (_index isNotEqualTo -1) then {
            _uavTargetsList deleteAt _index;
        };
    }forEach XK_6DOF_serverList;

    if (XK_6DOF_serverListUAV isNotEqualTo XK_6DOF_serverListUAVOld) then {
        ["XK_6DOF_EH_sendTargetList", [_uavTargetsList, true], _canSee] call CBA_fnc_targetEvent;
        XK_6DOF_serverListUAVOld = _uavTargetsList;
        
    };
    XK_6DOF_serverListUAV = [];
},1,[]] call CBA_fnc_addPerFrameHandler;

//Marked target list
missionNamespace setVariable ["XK_6DOF_markedList", []];
diag_log text "[6DOF] Finished initializing EagleEye 6DOF server-side.";