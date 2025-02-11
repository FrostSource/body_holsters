[h3]Using Custom Buttons[/h3]

[b]This guide explains how to use custom buttons for holstering and unholstering weapons. This is not required to use the Body Holsters addon as the addon will automatically set typical inputs based on your controller type.[/b]

[i]If you have a controller that doesn't work well by default, please leave a comment with the controller you use and buttons you suggest should be default for that controller.[/i]

Due to the multitude of controllers and mappings, Body Holsters allows you to set custom input actions (buttons) for holstering/unholstering weapons.

In Half-Life Alyx, input actions can be categorized as either analog or digital. Analog inputs are continuous and can have varying degrees of engagement (e.g., trigger pull or hand curl), while digital inputs are discrete and have a simple on/off state (e.g., button press).

When configuring custom input actions, you must specify a numerical value that corresponds to the desired input action instead of using its name. Additionally, you must indicate whether the action is an analog input or a digital input using the "body_holsters_unholster_is_analog" and "body_holsters_holster_is_analog" convars. This is because some values are shared between analog and digital actions.

See "Input Actions and Values" at the bottom for a list of all available input actions and their corresponding values.

It is recommended to experiment in-game using the console commands to find the best controls for you, then add them to the hlvr config file so they will be automatically set every time the game sets.

To find the config file, right click Half-Life Alyx in your Steam library and go to "Manage > Browse local files" then navigate to "game\hlvr\cfg\" and open the "skill_hlvr.cfg" file. You can add your custom inputs right at the top of the file just as you would enter them in the console. See the next section for examples.

[hr][/hr]

Examples using the default setups for each controller (please remember that these default examples are automatically set and do not need to be done manually):

[b]Valve Index Controller[/b]
The Index controllers (Knuckles) use the analog Squeeze Xen Grenade action for unholstering and the analog Hand Curl action for holstering.
[code]
body_holsters_unholster_is_analog 1
body_holsters_unholster_action 2
body_holsters_holster_is_analog 1
body_holsters_holster_action 0

body_holsters_holster_ungrip_amount 0.5
[/code]

[b]HTC Vive Controller[/b]
The Vive controllers use the analog Hand Curl action for unholstering and the digital Slide Release action for holstering.
[code]
body_holsters_unholster_is_analog 1
body_holsters_unholster_action 0
body_holsters_holster_is_analog 0
body_holsters_holster_action 11
[/code]

[b]All Other Controllers[/b]
All other controllers use the analog Hand Curl action for unholstering and the analog Hand Curl action for holstering.
[code]
body_holsters_unholster_is_analog 1
body_holsters_unholster_action 0
body_holsters_holster_is_analog 1
body_holsters_holster_action 0
[/code]

To mimic the old 'body_holsters_require_trigger_to_unholster' convar you can use the digital Fire action for unholstering.
[code]
body_holsters_unholster_is_analog 0
body_holsters_unholster_action 7
[/code]

[h3]Input Actions and Values[/h3]

You can see some more information about these values at https://developer.valvesoftware.com/wiki/Half-Life:_Alyx_Workshop_Tools/Scripting_API#Enumerations

[b]Analog Input Actions[/b]
[table]
    [tr]
        [th]Name[/th]
        [th]Value[/th]
    [/tr]
    [tr]
        [td]Hand Curl[/td]
        [td]0[/td]
    [/tr]
    [tr]
        [td]Trigger Pull[/td]
        [td]1[/td]
    [/tr]
    [tr]
        [td]Squeeze Xen Grenade[/td]
        [td]2[/td]
    [/tr]
    [tr]
        [td]Teleport Turn[/td]
        [td]3[/td]
    [/tr]
    [tr]
        [td]Continuous Turn[/td]
        [td]4[/td]
    [/tr]
[/table]

[b]Digital Input Actions[/b]
[table]
    [tr]
        [th]Name[/th]
        [th]Value[/th]
    [/tr]
    [tr]
        [td]Toggle Menu[/td]
        [td]0[/td]
    [/tr]
    [tr]
        [td]Menu Interact[/td]
        [td]1[/td]
    [/tr]
    [tr]
        [td]Menu Dismiss[/td]
        [td]2[/td]
    [/tr]
    [tr]
        [td]Use[/td]
        [td]3[/td]
    [/tr]
    [tr]
        [td]Use Grip[/td]
        [td]4[/td]
    [/tr]
    [tr]
        [td]Show Inventory[/td]
        [td]5[/td]
    [/tr]
    [tr]
        [td]Grav Glove Lock[/td]
        [td]6[/td]
    [/tr]
    [tr]
        [td]Fire[/td]
        [td]7[/td]
    [/tr]
    [tr]
        [td]Alt Fire[/td]
        [td]8[/td]
    [/tr]
    [tr]
        [td]Reload[/td]
        [td]9[/td]
    [/tr]
    [tr]
        [td]Eject Magazine[/td]
        [td]10[/td]
    [/tr]
    [tr]
        [td]Slide Release[/td]
        [td]11[/td]
    [/tr]
    [tr]
        [td]Open Chamber[/td]
        [td]12[/td]
    [/tr]
    [tr]
        [td]Toggle Laser Sight[/td]
        [td]13[/td]
    [/tr]
    [tr]
        [td]Toggle Burst Fire[/td]
        [td]14[/td]
    [/tr]
    [tr]
        [td]Toggle Health Pen[/td]
        [td]15[/td]
    [/tr]
    [tr]
        [td]Arm Grenade[/td]
        [td]16[/td]
    [/tr]
    [tr]
        [td]Arm Xen Grenade[/td]
        [td]17[/td]
    [/tr]
    [tr]
        [td]Teleport[/td]
        [td]18[/td]
    [/tr]
    [tr]
        [td]Turn Left[/td]
        [td]19[/td]
    [/tr]
    [tr]
        [td]Turn Right[/td]
        [td]20[/td]
    [/tr]
    [tr]
        [td]Move Back[/td]
        [td]21[/td]
    [/tr]
    [tr]
        [td]Walk[/td]
        [td]22[/td]
    [/tr]
    [tr]
        [td]Jump[/td]
        [td]23[/td]
    [/tr]
    [tr]
        [td]Mantle[/td]
        [td]24[/td]
    [/tr]
    [tr]
        [td]Crouch Toggle[/td]
        [td]25[/td]
    [/tr]
    [tr]
        [td]Stand Toggle[/td]
        [td]26[/td]
    [/tr]
    [tr]
        [td]Adjust Height[/td]
        [td]27[/td]
    [/tr]
[/table]