local categoryId = "body_holsters"
DebugMenu:AddCategory(categoryId, "Body Holsters")

local function toggle(name, command)
    DebugMenu:AddToggle(categoryId, command, name, command)
end

DebugMenu:AddLabel(categoryId, "body_holsters_settings_label", "Settings")
toggle("Visible Holstered Weapons", "body_holsters_visible_weapons")
toggle("Animate Holster", "body_holsters_animate")
toggle("Holster Actual Weapons", "body_holsters_use_actual_weapons")
toggle("Procedural Holstered Angles", "body_holsters_use_procedural_angles")