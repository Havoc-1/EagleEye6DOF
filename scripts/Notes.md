
## TO DO LIST
Create method to assign drone as 6dof
Fix Nametags disappearing on zoom

ACE Menu?
    Filter to DOF users only
    Filter to Fireteam only
    Filter to all BLUFOR
    Disable
    Targets filter to fireteam only
    Targets filter to all 6dof 
    ACE point target mark (link to gestureState)

ID Target iteration
    Cannot mark targets that have not been detected by system
    Store global number starting with 1
    if player uses point to mark target, get global and +1
    store target in global array
    if player uses cancel target then check if target was on list, if yes, -1 from global number
    set max marked targets as 10


## NOTES

## EagleEye Players

   - All allied EagleEye players share complete visibility of each other’s bounding boxes and skeletons.
   - Targets identified by one EagleEye player, including drones, are automatically synchronized with all other EagleEye players.
   - Enemy skeletons are only visible when an EagleEye player has a direct line of sight to the target.

## Performance

   - Rendering many targets (25 or more) may significantly impact frame rates.
   - The system is optimized for small teams and has not been extensively tested in large-scale scenarios.