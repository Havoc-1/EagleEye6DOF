diag_log text format ["[6DOF] [onPlayerRespawn] Respawn detected for %1 %2, applying 6DOF EHs SlotItemChanged & Killed.", _name player, getPosATL player];
[player] call XK_6DOF_fnc_enableOverlay;
[player] call XK_6DOF_fnc_respawnEH;