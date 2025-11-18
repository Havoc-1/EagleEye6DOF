/* 
    Author: [DMCL] Xephros
    Init for 6DOF.
*/

private _cbaCheck = isClass(configFile >> "CfgPatches" >> "cba_main");
private _aceCheck = isClass(configFile >> "CfgPatches" >> "ace_main");
if !(_cbaCheck || _aceCheck) exitWith {
    [format ["Failed to initialize EagleEye 6DOF, dependencies not loaded. CBA_A3: %1, ACE: %2",_cbaCheck, _aceCheck], "Init"] call XK_6DOF_fnc_diaglog;
};
["Initializing EagleEye 6DOF.", "Init"] call XK_6DOF_fnc_diaglog;

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

[] call XK_6DOF_fnc_initEH;
["Finished initializing EagleEye 6DOF.", "Init",1] call XK_6DOF_fnc_diaglog;

//Globally broadcasted targets calculated server-side
if !(isServer) exitWith {};
["Server/Host detected. Running server-side target list PFH.", "Init (Server)"] call XK_6DOF_fnc_diaglog;

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
    if (_canSeeUAV isEqualTo []) exitWith {
        XK_6DOF_serverListUAV = [];
    };

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
["Finished initializing EagleEye 6DOF server-side.", "Init (Server)",1] call XK_6DOF_fnc_diaglog;