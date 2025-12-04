
# TO DO LIST

Create method to assign drone as 6dof
Filter vehicles by type?

# NOTES

## How to use

   - Equip any goggles listed in the XK_6DOF_gogglesList list. Default goggles are: G_Goggles_VR, G_Tactical_Clear, G_Tactical_Black, G_Tactical_camo, G_Tactical_yellow.
   - If XK_6DOF_headgearToggle is enabled, players must equip the headgear to begin scanning targets.
   - ACE Self Interact to adjust information parameters.

## EagleEye Players

   - Targets are identified by looking at targets with goggles/helmet equipped.
   - All allied EagleEye players share complete visibility of each other’s bounding boxes and skeletons.
   - Targets identified by one EagleEye player, including drones, are automatically synchronized with all other EagleEye players.
   - Enemy skeletons are only visible when an EagleEye player has a direct line of sight to the target. Drones spots will not display skeletons.
   - EagleEye players can mark targets via ACE Pointing (Shift + `) at the tracked target.
   - Marked targets will incrementally update ID.

## Performance

   - Rendering many targets may significantly impact frame rates.
   - The system is optimized for small teams and has not been extensively tested in large-scale scenarios.

# ReadMe Mission Making & Zeus

   ## Functions

   To force add EagleEye to AI (Not requied for players)
   - [_myUnit] call XK_6DOF_fnc_add6dof;

   To force add EagleEye to drone (designed for AR-2 Darters, other drones may not work as intended)
   - [_myDrone] call XK_6DOF_fnc_add6dofDrone;

   Manually mark a unit to EagleEye users
   - ["XK_6DOF_EH_targetIncr", _myUnit] call CBA_fnc_serverEvent;

   ## Variables

   - _name <STRING> - Name to display on nametags, intended for non-EagleEye users.
   - _target setVariable ["XK_6DOF_Name", _name];

   
# Known Limitations

   - It is recommended to host this on a dedicated server. A lot of information is calculated server-side and may have low performance on player-hosted servers.
   - Overlay loses IFF colors under NVGs. This is due to drawLine3D being rendered in world space, the IFF markers above the head are a work around to this problem.
   - Overlays cannot be seen inside vehicles. Vehicle interiors are rendered in front of the world space, same as above.
   - Bad performance with lots of units. Draw3D has to be run on every frame, I've tried to optimise it where possible. This was designed around milsim groups with less target saturation.
   