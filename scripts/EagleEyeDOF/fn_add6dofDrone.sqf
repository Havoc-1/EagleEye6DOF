/* 
    Author: [DMCL] Xephros
    Function to add 6DOF vision to a unit. Turret Vector script was based on KillzoneKid's code.
    
    Arguments:
        0: Target <UNIT> - Enable 6DOF on drone.
        1: Search diameter <NUMBER> (Optional) - Max diameter to consider targets on turret view.
        2: Search Range <NUMBER> (Optional) - Max distance to consider targets on turret view.
    
    Return Value: None

    Example:
        [this] call XK_6DOF_fnc_add6dofDrone;
        [this, 25, 500] call XK_6DOF_fnc_add6dofDrone;
*/

params ["_uav",["_searchDiam",30],["_searchRng", 1000]];

if (_uav getVariable ["XK_6DOF_enable", false]) exitWith {diag_log text format ["[6DOF] %1 %2 is already has 6DOF enabled. exiting add6dofDrone.sqf.", name _uav, getPosATL _uav]};

private _searchDiamCap = 200;
private _searchRngCap = 1500;

if (isNil "_uav" || isNull _uav) exitWith {
    diag_log text "[6DOF] Invalid unit selected. Exiting fn_add6dofDrone.sqf";
};
if !(_uav isKindOf "UAV_01_Base_F") exitWith {
    diag_log text format ["[6DOF] %1's drone %2 is not an AR-2 Darter, exiting add6dofDrone.sqf.", name _uav, getPosATL _uav];
};

//Cap for gameplay balance and performance, units beyond this range may have undesired results
if (_searchDiam > _searchDiamCap) then {
    diag_log text format ["[6DOF] %1's drone %2 search diameter too large (%3), setting search diameter to %4.", name _uav, getPosATL _uav, _searchDiam, _searchDiamCap];
    _searchDiam = _searchDiamCap;
};
if (_searchRng > _searchRngCap) then {
    diag_log text format ["[6DOF] %1's drone %2 search range too long (%3), setting search range to %4.", name _uav, getPosATL _uav, _searchRng, _searchRngCap];
    _searchRng = _searchRngCap;
};

_uav setVariable ["XK_6DOF_enable", true, true];
[
	{
        _args params ["_uav","_searchDiam","_searchRng"];

        if (!alive _uav) exitWith {
            diag_log text format ["[6DOF] %1's drone has been destroyed, exiting add6dofDrone.sqf.", name _uav];
            [_this select 1] call CBA_fnc_removePerFrameHandler;
        };
        
        if (!isEngineOn _uav || (fuel _uav == 0)) exitWith {};

        //Get UAV Turret
        private _uavCfg = configFile >> "CfgVehicles" >> typeOf _uav;
        private _camPosSel = getText (_uavCfg >> "uavCameraGunnerPos");
        if (_camPosSel isEqualTo "") exitWith {
            diag_log text format ["[6DOF] %1's drone %2 does not have a valid turret/gunner, exiting add6dofDrone.sqf.", name _uav, getPosATL _uav];
            [_this select 1] call CBA_fnc_removePerFrameHandler;
        };
        private _camDirSel = getText (_uavCfg >> "uavCameraGunnerDir");

        //Calculate vector positions
        private _camPos = _uav selectionPosition _camPosSel;
        private _camDir = _camPos vectorAdd (_camPos vectorFromTo (_uav selectionPosition _camDirSel) vectorMultiply _searchRng);
        private _points = lineIntersectsSurfaces [_uav modelToWorldVisualWorld _camPos, _uav modelToWorldVisualWorld _camDir, _uav];

        //ATL Pos of ground intersect
        private _aimPosATL = ASLToATL (_points select 0 select 0);

        //Find and filter targets
        private _targets = [];
        private _searchList = ([_aimPosATL, _searchDiam, _searchDiam, 0, false] nearEntities [["CAManBase","LandVehicle"], false, true, true]) select {_x != _uav && (_uav distance _x <= _searchRng)};
        {
            _targets append (if (isNull objectParent _x) then {[_x]} else {crew _x});
        } forEach _searchList;
        _targets = _targets select {
            ([_x,"VIEW",_uav] checkVisibility [_uav modelToWorldVisualWorld _camPos, eyePos _x] > 0 || [_x,"VIEW",_uav] checkVisibility [_uav modelToWorldVisualWorld _camPos, (_x modelToWorldVisualWorld (_x selectionPosition "spine2"))] > 0)
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