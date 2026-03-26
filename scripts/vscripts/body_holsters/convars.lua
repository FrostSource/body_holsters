local util = require("body_holsters.util")
local isPlayerBodyEnabled = util.isPlayerBodyEnabled

local function convarUpdateController()
    BodyHolsters:UpdateControllerInputs()
end

---Used to test other controller value types without actually having the controller
local function getVRControllerType()
    if IsInToolsMode() then
        -- return VR_CONTROLLER_TYPE_KNUCKLES
        -- return VR_CONTROLLER_TYPE_RIFT_S
        -- return VR_CONTROLLER_TYPE_VIVE
        return Player:GetVRControllerType()
    else
        return Player:GetVRControllerType()
    end
end

EasyConvars:RegisterConvar("body_holsters_visible_weapons", function()
    return isPlayerBodyEnabled()
end, "Weapons are visibly attached to the player body.", 0)
EasyConvars:SetPersistent("body_holsters_visible_weapons", true)

EasyConvars:RegisterConvar("body_holsters_increase_offhand_side_radius", "1", "Body slots on the non-dominant side of your body will have a slightly larger radius to accommodate for increased reach distance.", 0)
EasyConvars:SetPersistent("body_holsters_increase_offhand_side_radius", true)

EasyConvars:RegisterConvar("body_holsters_allow_multitool", "0", "Multitool is allowed to be holstered.", 0)
EasyConvars:SetPersistent("body_holsters_allow_multitool", true)

EasyConvars:RegisterConvar("body_holsters_unholster_grip_amount", 1.0, "[0-1] value for how much the controller must be gripped to unholster a weapon (only applicable if body_holsters_unholster_is_analog is 1)", 0, convarUpdateController)
EasyConvars:SetPersistent("body_holsters_unholster_grip_amount", true)

EasyConvars:RegisterConvar("body_holsters_holster_ungrip_amount", 0.1, "[0-1] value for how much the controller must be ungripped to holster a weapon (only applicable if body_holsters_holster_is_analog is 1)", 0, convarUpdateController)
EasyConvars:SetPersistent("body_holsters_holster_ungrip_amount", true)


EasyConvars:RegisterConvar("body_holsters_use_procedural_angles", function()
    return not isPlayerBodyEnabled()
end, "Visible weapons will use the angle of the weapon when holstered.", 0)
EasyConvars:SetPersistent("body_holsters_use_procedural_angles", true)


EasyConvars:RegisterConvar("body_holsters_holster_is_analog", function()
    -- Vive doesn't have analog grip for grabbing apparently, so it will use button above touchpad (slide release)
    if getVRControllerType() == VR_CONTROLLER_TYPE_VIVE then
        return false
    else
        return true
    end
end, "Whether analog actions should be used instead of digital actions for holstering.", 0,
-- Main callback (also display)
function (newValue, prevValue)
    if truthy(newValue) then
        Msg("Holstering is using analog actions.\n")
    else
        Msg("Holstering is using digital actions.\n")
    end
end)
EasyConvars:SetPersistent("body_holsters_holster_is_analog", true)


EasyConvars:RegisterConvar("body_holsters_holster_action", ANALOG_INPUT_HAND_CURL, "The digital or analog action for holstering.", 0,
-- Main callback (also display)
function (newValue, prevValue)
    convarUpdateController()
    if EasyConvars:GetBool("body_holsters_holster_is_analog") then
        Msg("Holster analog action is now '" .. Input:GetAnalogDescription(tonumber(newValue)) .. "'\n")
    else
        Msg("Holster digital action is now '" .. Input:GetButtonDescription(tonumber(newValue)) .. "'\n")
    end
end)
EasyConvars:SetPersistent("body_holsters_holster_action", true)


EasyConvars:RegisterConvar("body_holsters_unholster_is_analog", true, "Whether analog actions should be used instead of digital actions for unholstering", 0,
-- Main callback (also display)
function (newValue, prevValue)
    if truthy(newValue) then
        Msg("Unholstering is now using analog actions.\n")
    else
        Msg("Unholstering is now using digital actions.\n")
    end
end)
EasyConvars:SetPersistent("body_holsters_unholster_is_analog", true)


EasyConvars:RegisterConvar("body_holsters_unholster_action", function()
    if getVRControllerType() == VR_CONTROLLER_TYPE_KNUCKLES then
        return ANALOG_INPUT_SQUEEZE_XEN_GRENADE
    else
        return ANALOG_INPUT_HAND_CURL
    end
end, "The digital or analog action for unholstering", 0,
-- Main callback (also display)
function (newValue, prevValue)
    convarUpdateController()
    if EasyConvars:GetBool("body_holsters_unholster_is_analog") then
        Msg("Unholster analog action is now '" .. Input:GetAnalogDescription(tonumber(newValue)) .. "'\n")
    else
        Msg("Unholster digital action is now '" .. Input:GetButtonDescription(tonumber(newValue)) .. "'\n")
    end
end)
EasyConvars:SetPersistent("body_holsters_unholster_action", true)

EasyConvars:RegisterConvar("body_holsters_use_actual_weapons", true, "If the actual weapon entities should be holstered for accurate display", 0)
EasyConvars:SetPersistent("body_holsters_use_actual_weapons", true)

EasyConvars:RegisterConvar("body_holsters_animate", true, "If holstered weapons should animate to their position", 0)
EasyConvars:SetPersistent("body_holsters_animate", true)

EasyConvars:RegisterConvar("body_holsters_haptics", true, "Whether to use haptic feedback when hovering over holster slots", 0)
EasyConvars:SetPersistent("body_holsters_haptics", true)


---All convar work that needs to be done after convars have finished setting up
---Extra checks need to happen here to make sure we don't overwrite user's custom values
EasyConvars:AddPostInitializer(function()

    local controllerType = getVRControllerType()

    -- Automatic holster actions
    if not EasyConvars:WasChangedByUser("body_holsters_holster_action") then
        if EasyConvars:GetBool("body_holsters_holster_is_analog") then
            EasyConvars:SetInt("body_holsters_holster_action", ANALOG_INPUT_HAND_CURL)
        else
            -- Vive doesn't have analog grip for grabbing apparently, so it will use button above touchpad (slide release)
            if controllerType == VR_CONTROLLER_TYPE_VIVE then
                EasyConvars:SetInt("body_holsters_holster_action", DIGITAL_INPUT_SLIDE_RELEASE)
            else
                EasyConvars:SetInt("body_holsters_holster_action", DIGITAL_INPUT_USE_GRIP)
            end
        end
    end

    -- Automatic unholster actions
    if not EasyConvars:WasChangedByUser("body_holsters_unholster_action") then
        if EasyConvars:GetBool("body_holsters_unholster_is_analog") then
            -- Index automatically gets squeeze analog
            if controllerType == VR_CONTROLLER_TYPE_KNUCKLES then
                EasyConvars:SetInt("body_holsters_unholster_action", ANALOG_INPUT_SQUEEZE_XEN_GRENADE)
                EasyConvars:SetIfUnchanged("body_holsters_unholster_grip_amount", 0.5)
            else
                EasyConvars:SetInt("body_holsters_unholster_action", ANALOG_INPUT_HAND_CURL)
            end
        else
            EasyConvars:SetInt("body_holsters_unholster_action", DIGITAL_INPUT_USE_GRIP)
        end
    end

end)