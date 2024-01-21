[h1]Body Holsters[/h1]

Body Holsters is a global addon allowing you to store your weapons directly on your body instead of using the standard weapon selection menu.

[i]This addon is compatible with Scalable Init Support but does not require it.[/i]

[h2]How To Use[/h2]

[b]Holstering:[/b]

With a weapon equipped in your primary hand, hold your grip button (squeeze the controller gently for Valve Index Knuckles) and move your hand to one of the six holster slots on your body until you feel a vibration in your controller, then release the grip to holster.

[b]Unholstering:[/b]

With an empty primary hand, move your hand to a body slot which has previously had a weapon holstered in it, then press your grip button to unholster and equip.

[hr][/hr]
Your weapon switch menu remains fully functional so you can mix your play-style between holsters and menus. Picking a weapon from the menu accidentally will not remove it from its body slot, but placing it into a different slot will remove it from its previous slot.

[h2]Console Commands[/h2]

[list]

[*][b]holsters_visible_weapons[/b]
Default = 0
Weapons will be visibly attached to the player body when holstered. If enabled when weapons are already holstered, they will have to be reholstered to appear.
[i]This convar is persistent with your save file.[/i]

[*][b]holsters_allow_multitool[/b]
Default = 0
Multitool is allowed to be holstered.
[i]This convar is persistent with your save file.[/i]
[b]See [i]Known Issues[/i] below for important information about this![/b]

[*][b]holsters_require_trigger_to_unholster[/b]
Default = 0
The use button will be required to unholster weapons instead of the grip.
[i]This convar is persistent with your save file.[/i]

[*][b]holsters_slot[/b]
Syntax = holsters_slot <name> <x> <y> <z> <radius>
Allows temporary modification of holster slot properties for debugging purposes, best used in conjunction with [b]holsters_debug[/b] to see positions. Any changes will revert on map reload. Leave a comment if you think you've found better slot positions.

If command is entered without any parameters all slots will be listed in the console.
If only a name is provided that slot will be listed in the console.

Parameters X/Y/Z are relative to the player body near the head. Setting 0/0/0 will put the slot at that position near the head. X is forward/backwards, Y is right/left, Z is up/down.

[*][b]holsters_debug[/b]
Default = 0
Draws debug spheres for the holster slots and their states.

[/list]

[h2]Known Issues[/h2]

Due to the way Half-Life: Alyx works, the multitool will fail to function correctly if equipped by some means other than the weapon selection menu. The multitool is not allowed to be holstered by default for this reason.

Maps without a backpack will function incorrectly.

If a map allows the player to have the same custom weapon in more than one weapon slot, holstering both might cause issues.