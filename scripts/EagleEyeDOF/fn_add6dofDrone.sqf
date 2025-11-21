/* 
    Author: [DMCL] Xephros
    Function to add 6DOF vision to a unit. Turret Vector script was based on KillzoneKid's code.
    
    Arguments:
        0: Target <UNIT> - Enable 6DOF on drone.
        1: Search diameter <NUMBER> (Optional) - Max diameter to consider targets on turret view.
        2: Search Range <NUMBER> (Optional) - Max distance to consider targets on turret view.
        3: Limit to AR-2 Darters Only <BOOL> (Optional) - Only allow AR-2 Darters to have 6DOF capabilities. For debugging.
    
    Return Value: None

    Example:
        [this] call XK_6DOF_fnc_add6dofDrone;
        [this, 25, 500] call XK_6DOF_fnc_add6dofDrone;
*/

params ["_uav",["_searchDiam",30],["_searchRng", 1000],["_ar2Only", true]];

if (_uav getVariable ["XK_6DOF_enable", false]) exitWith {
    [format ["%1 %2 is already has 6DOF enabled. Exiting function.", name _uav, getPosATL _uav], "add6dofDrone",1] call XK_6DOF_fnc_diaglog;
};

private _searchDiamCap = 200;
private _searchRngCap = 1500;

if (isNil "_uav" || isNull _uav) exitWith {
    ["Invalid unit selected. Exiting function.", "add6dofDrone"] call XK_6DOF_fnc_diaglog;
};
if (_ar2Only && !(_uav isKindOf "UAV_01_Base_F")) exitWith {
    [format ["%1's drone %2 is not an AR-2 Darter, exiting add6dofDrone.sqf.", name _uav, getPosATL _uav], "add6dofDrone"] call XK_6DOF_fnc_diaglog;
};

//Cap for gameplay balance and performance, units beyond this range may have undesired results
if (_searchDiam > _searchDiamCap) then {
    [format ["%1's drone %2 search diameter too large (%3), setting search diameter to %4.", name _uav, getPosATL _uav, _searchDiam, _searchDiamCap], "add6dofDrone"] call XK_6DOF_fnc_diaglog;
    _searchDiam = _searchDiamCap;
};
if (_searchRng > _searchRngCap) then {
    [format ["%1's drone %2 search range too long (%3), setting search range to %4.", name _uav, getPosATL _uav, _searchRng, _searchRngCap], "add6dofDrone"] call XK_6DOF_fnc_diaglog;
    _searchRng = _searchRngCap;
};

_uav setVariable ["XK_6DOF_enable", true, true];
[
	{
        _args params ["_uav","_searchDiam","_searchRng"];

        if (!alive _uav) exitWith {
            [format ["%1's drone has been destroyed, exiting function.", name _uav], "add6dofDrone"] call XK_6DOF_fnc_diaglog;
            [_this select 1] call CBA_fnc_removePerFrameHandler;
        };
        
        if (!isEngineOn _uav || (fuel _uav == 0)) exitWith {};

        //Get UAV Turret
        private _uavCfg = configFile >> "CfgVehicles" >> typeOf _uav;
        private _camPosSel = getText (_uavCfg >> "uavCameraGunnerPos");
        if (_camPosSel isEqualTo "") exitWith {
            [format ["%1's drone %2 does not have a valid turret/gunner, exiting function.", name _uav, getPosATL _uav], "add6dofDrone"] call XK_6DOF_fnc_diaglog;
            [_this select 1] call CBA_fnc_removePerFrameHandler;
        };
        private _camDirSel = getText (_uavCfg >> "uavCameraGunnerDir");

        //Calculate vector positions
        private _camPos = _uav selectionPosition _camPosSel;
        private _camModelToWorld = _uav modelToWorldVisualWorld _camPos;
        private _camDir = _camPos vectorAdd (_camPos vectorFromTo (_uav selectionPosition _camDirSel) vectorMultiply _searchRng);
        private _points = lineIntersectsSurfaces [_camModelToWorld, _uav modelToWorldVisualWorld _camDir, _uav];

        //ATL Pos of ground intersect
        private _aimPosATL = ASLToATL (_points select 0 select 0);

        //Find and filter targets
        private _targets = [];
        private _searchList = ([_aimPosATL, _searchDiam, _searchDiam, 0, false] nearEntities [["CAManBase","LandVehicle"], false, true, true]) select {_x != _uav && (_uav distance _x <= _searchRng)};
        {
            _targets append (if (isNull objectParent _x) then {[_x]} else {crew _x});
        } forEach _searchList;
        _targets = _targets select {
            private _eyePosTgt = eyePos _x;
            private _spinePosASL = _x modelToWorldVisualWorld (_x selectionPosition "spine2");
            [_x,"FIRE"] checkVisibility [_camModelToWorld, _eyePosTgt] > 0 || 
            [_x,"FIRE"] checkVisibility [_camModelToWorld, _spinePosASL] > 0 ||
            [_x,"VIEW"] checkVisibility [_camModelToWorld, _eyePosTgt] > 0 ||
            [_x,"VIEW"] checkVisibility [_camModelToWorld, _spinePosASL] > 0
        };
        if (_targets isNotEqualTo []) then {
            _targets = flatten _targets;
            _targets = _targets arrayIntersect _targets;
        };

        //If list is unchanged, do not push to server
        ["XK_6DOF_EH_addTargetList", [_targets, true]] call CBA_fnc_serverEvent;
    },
    1,[_uav, _searchDiam, _searchRng]
]call CBA_fnc_addPerFrameHandler;