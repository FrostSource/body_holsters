[h1]Body Holsters[/h1]

Body Holsters is a global addon allowing you to store your weapons directly on your body instead of using the standard weapon selection menu.

[i]This addon require [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3329679071]AlyxLib[/url] to work.[/i]

[img]https://steamuserimages-a.akamaihd.net/ugc/2312102971541192814/6C973CA6790B85B47D70B39F38E0839D42C52448/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false[/img]

[h2]How To Use[/h2]

[h3]Holstering:[/h3]

[b]For most controllers:[/b] With a weapon equipped in your primary hand, hold your grip button and move your hand to one of the seven holster slots on your body until you feel a vibration in your controller, then release the grip to holster.

[b]For HTC Vive controllers:[/b] With a weapon equipped in your primary hand, move your hand to one of the seven holster slots on your body, then press the slide release button to holster.

[h3]Unholstering:[/h3]

With an empty primary hand, move your hand to a body slot which has previously had a weapon holstered in it, then press your grip button to unholster and equip.

Buttons can be changed using console commands. Please see the [url=https://steamcommunity.com/workshop/filedetails/discussion/3144612716/732500995379036779/]Custom Input Actions Guide[/url] for more info.

[h3]Slots:[/h3]

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

Console commands allow you to customize and tweak the addon while playing. They are not required to use the addon, and for most users the default values will provide a good experience. 

If you don't know how to use the console, follow this guide: https://steamcommunity.com/sharedfiles/filedetails/?id=2040205272

See the list of console commands here: https://steamcommunity.com/workshop/filedetails/discussion/3144612716/732500995379037046/

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

[h2]Getting Help[/h2]

Please feel free to reach out either by commenting below or on the Discord server!

[url=https://discord.gg/42SC3Wyjv4][img]https://steamuserimages-a.akamaihd.net/ugc/2397692528302959470/036A75FE4B2E8CD2224F8B62E7CEBEE649493C40/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false[/img][/url]