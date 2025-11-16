/* 

    Add 6DOF event handlers on unit. Use in on_unitRespawn.sqf

*/


params [["_player", player]];
private _ehCheck = _player getVariable ["XK_6dofRespawnEH", false];
if (_ehCheck || !isPlayer _player) exitWith {
    [format ["6DOF EHs already applied to %1 %2, exiting fn_respawnEH.sqf.", name _player, getPosATL _player], "respawnEH", 1] call XK_6DOF_fnc_diaglog;
};

_player addEventHandler ["SlotItemChanged", {
    params ["_unit", "_name", "_slot", "_assigned", "_weapon"];
    if (_slot isNotEqualTo 603 && _slot isNotEqualTo 605) exitWith {};
    [_unit] call XK_6DOF_fnc_enableOverlay;
}];

_player addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];
    _unit setVariable ["XK_6DOF_enable", nil, true];
    private _id = _unit getVariable ["XK_6DOF_scanPFH", nil];
    if !(isNil "_id") then {
        [_id] call CBA_fnc_removePerFrameHandler;
        _unit setVariable ["XK_6DOF_scanPFH", nil];
    };
}];

_player addEventHandler ["GestureChanged", {
	params ["_unit", "_gesture"];
    if (_gesture isNotEqualTo "ace_gestures_point") exitWith {};
    [_unit, _gesture] call XK_6DOF_fnc_pointMark;
}];

_player setVariable ["XK_6dofRespawnEH", true];
[format ["6DOF EHs SlotItemChanged & Killed applied to %1 %2.", name _player, getPosATL _player], "respawnEH", 1] call XK_6DOF_fnc_diaglog;