[h1]Body Holsters[/h1]

Body Holsters is a global addon allowing you to store your weapons directly on your body instead of using the standard weapon selection menu.

[i]This addon is compatible with Scalable Init Support but does not require it.[/i]

[img]https://steamuserimages-a.akamaihd.net/ugc/2312102971541192814/6C973CA6790B85B47D70B39F38E0839D42C52448/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false[/img]

[h2]How To Use[/h2]

[b]Holstering:[/b]

With a weapon equipped in your primary hand, hold your grip button (squeeze the controller gently for Valve Index Knuckles) and move your hand to one of the seven holster slots on your body until you feel a vibration in your controller, then release the grip to holster.

[b]Unholstering:[/b]

With an empty primary hand, move your hand to a body slot which has previously had a weapon holstered in it, then press your grip button to unholster and equip.

[b]Slots:[/b]

[list]
    [*]Left Hip
    [*]Right Hip
    [*]Left Underarm
    [*]Right Underarm
    [*]Left Shoulder
    [*]Right Shoulder
    [*]Chest
[/list]

[hr][/hr]
Your weapon switch menu remains fully functional so you can mix your play-style between holsters and menus. Picking a weapon from the menu accidentally will not remove it from its body slot, but placing it into a different slot will remove it from its previous slot.

[h2]Console Commands[/h2]

If you don't know how to use the console, follow this guide: https://steamcommunity.com/sharedfiles/filedetails/?id=2040205272

[hr][/hr]
[list]

[*][b]body_holsters_visible_weapons[/b]
Default = 0
Weapons will be visibly attached to the player body when holstered. If enabled when weapons are already holstered, they will need to be reholstered to appear.
[i]This convar is persistent with your save file.[/i]

[*][b]body_holsters_increase_offhand_side_radius[/b]
Default = 1
Body slots on the non-dominant side of your body will have a slightly larger radius to accommodate for increased reach distance.
[i]This convar is persistent with your save file.[/i]

[*][b]body_holsters_allow_multitool[/b]
Default = 0
Multitool is allowed to be holstered.
[i]This convar is persistent with your save file.[/i]
[b]See [i]Known Issues[/i] below for important information about this![/b]

[*][b]body_holsters_unholster_grip_amount[/b]
Default (Knuckles) = 0.5
Default (Other)    = 1.0
The [0-1] amount you must grip your controller to unholster a weapon.
On the Valve Index Knuckles this is a different value by default because it uses the squeeze mechanic instead of the hand curl.
For controllers with a grip button this is the just the amount that the button must be pressed.
[i]This convar is persistent with your save file.[/i]

[*][b]body_holsters_holster_ungrip_amount[/b]
Default = 0.1
The [0-1] amount you must ungrip your controller to holster a weapon.
For controllers with a grip button this is the just the amount that the button must be unpressed.
[i]This convar is persistent with your save file.[/i]

[*][b]body_holsters_require_trigger_to_unholster[/b]
Default = 0
The trigger/shoot button will be required to unholster weapons instead of the grip.
[i]This convar is persistent with your save file.[/i]

[*][b]body_holsters_knuckles_use_squeeze[/b]
Default = 1
Valve Index Knuckles controllers will use the squeeze mechanic instead of the hand curl to unholster weapons.
Different values for `body_holsters_unholster_grip_amount` should be tested to find a grip amount you're happy with.
[i]This convar is persistent with your save file.[/i]

[*][b]body_holsters_use_procedural_angles[/b]
Default = 0
Visible weapons will use the current angle of the weapon when holstering, otherwise they will use a default angle.
[i]This convar is persistent with your save file.[/i]

[*][b]body_holsters_slot[/b]
Syntax = holsters_slot <name> <x> <y> <z> <radius>
Allows temporary modification of holster slot properties for debugging purposes, best used in conjunction with [b]holsters_debug[/b] to see positions. Any changes will revert on map reload. Leave a comment if you think you've found better slot positions.

If command is entered without any parameters all slots will be listed in the console.
If only a name is provided that slot will be listed in the console.

Parameters X/Y/Z are relative to the player body near the head. Setting 0/0/0 will put the slot at that position near the head. X is forward/backwards, Y is right/left, Z is up/down.

[*][b]body_holsters_debug[/b]
Default = 0
Draws debug spheres for the holster slots and their states.

[/list]

[hr][/hr]
Console commands can be set in the [url=https://help.steampowered.com/faqs/view/7D01-D2DD-D75E-2955]launch options[/url] for Half-Life: Alyx, just put a hyphen before each name and the value after, e.g. [b]-body_holsters_visible 1[/b]
They can also be added to your [b]Half-Life Alyx\game\hlvr\cfg\skill.cfg[/b] file, one per line without the hyphen, e.g. [b]body_holsters_visible 1[/b]

[h2]Source Code[/h2]

GitHub: https://github.com/FrostSource/body_holsters

[h2]Known Issues[/h2]

Ammo displays on visible holstered weapons will show incorrect amount of ammo. Unfortunately I have not found a way to get the current ammo inside a weapon.

Trying to grab a weapon near the face while wearing a mask or respirator will cause the player to accidentally remove the worn item instead of the weapon. Unfortunately I have not found a way to get around this.

Due to the way Half-Life: Alyx works, the multitool will fail to function correctly if equipped by some means other than the weapon selection menu. The multitool is not allowed to be holstered by default for this reason.

Maps without a backpack will function incorrectly.

Holstering can be buggy when the head is mismatched from the real life body (looking sideways while facing forwards). There is no easy way to track where the body is relative to the head.

If a map allows the player to have the same custom weapon in more than one weapon slot, holstering both might cause issues.

[b]body_holsters_require_trigger_to_unholster[/b] will cause rapidfire weapons to shoot if the trigger is held too long after unholstering.
