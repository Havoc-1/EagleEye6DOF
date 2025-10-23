/* 

    Add 6DOF event handlers on unit. Use in on_unitRespawn.sqf

*/

//if item being changed is a type of goggles, exit all else
params [["_player", player]];
if !(isPlayer _player) exitWith {};
private _ehCheck = _player getVariable ["XK_6dofRespawnEH", nil];
if !(isNil "_ehCheck") exitWith {};

private _id1 = _player addEventHandler ["SlotItemChanged", {
    params ["_unit", "_name", "_slot", "_assigned", "_weapon"];
    if !(_slot isEqualTo 603 || _name in DOF_gogglesList || _name isEqualTo "") exitWith {};
    if !(_assigned) then {diag_log text format ["[6DOF] [SlotItemChanged EH] %1 has been unassigned from %2 %3",_name, name _unit, getPosATL _unit]};
    if (_assigned && (_name in DOF_gogglesList)) then {diag_log text format ["[6DOF] [SlotItemChanged EH] Goggles (%1) detected on %2 %3.",_name, name _unit, getPosATL _unit]};
    [_unit] call XK_6DOF_fnc_enableOverlay
}];

private _id2 = _player addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];
    _unit setVariable ["XK_enable6dof", nil, true];
    _unit setVariable ["XK_6dofList", nil, true];
    private _id = missionNamespace getVariable ["XK_6dofPFH", nil];
    if !(isNil "_id") then {
        [_id] call CBA_fnc_removePerFrameHandler;
        missionNamespace setVariable ["XK_6dofPFH", nil];
    };
}];

private _id3 = _player addEventHandler ["GestureChanged", {
	params ["_unit", "_gesture"];
    if (_gesture isNotEqualTo "ace_gestures_point") exitWith {};
    [_unit, _gesture] call XK_6DOF_fnc_pointMark;
}];

_player setVariable ["XK_6dofRespawnEH", [_id1, _id2, _id3]];

diag_log text format ["[6DOF] [respawnEH] 6DOF EHs SlotItemChanged & Killed applied to %1 %2.", name _player, getPosATL _player];