---@TODO Test gas mask preventing unholster on shoulder (hmd attachments seem to be internally handled)
---@TODO Add animations for weapon holster
---@TODO Update ammo count on holstered weapons (no known way to getting ammo count)

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

EasyConvars:RegisterConvar("body_holsters_visible_weapons", "0", "Weapons are visibly attached to the player body.", 0)
EasyConvars:SetPersistent("body_holsters_visible_weapons", true)

EasyConvars:RegisterConvar("body_holsters_increase_offhand_side_radius", "1", "Body slots on the non-dominant side of your body will have a slightly larger radius to accommodate for increased reach distance.", 0)
EasyConvars:SetPersistent("body_holsters_increase_offhand_side_radius", true)

EasyConvars:RegisterConvar("body_holsters_allow_multitool", "0", "Multitool is allowed to be holstered.", 0)
EasyConvars:SetPersistent("body_holsters_allow_multitool", true)

EasyConvars:RegisterConvar("body_holsters_unholster_grip_amount", 1.0, "[0-1] value for how much the controller must be gripped to unholster a weapon (only applicable if body_holsters_unholster_is_analog is 1)", 0, convarUpdateController)
EasyConvars:SetPersistent("body_holsters_unholster_grip_amount", true)

EasyConvars:RegisterConvar("body_holsters_holster_ungrip_amount", 0.1, "[0-1] value for how much the controller must be ungripped to holster a weapon (only applicable if body_holsters_holster_is_analog is 1)", 0, convarUpdateController)
EasyConvars:SetPersistent("body_holsters_holster_ungrip_amount", true)


EasyConvars:RegisterConvar("body_holsters_use_procedural_angles", "0", "Visible weapons will use the angle of the weapon when holstered.", 0)
EasyConvars:SetPersistent("body_holsters_use_procedural_angles", true)


EasyConvars:RegisterConvar("body_holsters_holster_is_analog", function()
    -- Vive doesn't have analog grip for grabbing apparently, so it will use button above touchpad (slide release)
    if getVRControllerType() == VR_CONTROLLER_TYPE_VIVE then
        return false
    else
        return true
    end
end, "Whether analog actions should be used instead of digital actions for holstering.", 0, nil,
-- Display func
function (reg)
    Msg(reg.name .. " = " .. tostring(reg.value) .. "\n")
    Msg("Whether analog actions should be used instead of digital actions for holstering. ")
    if truthy(reg.value) then
        Msg("Holstering is using analog actions.\n")
    else
        Msg("Holstering is using digital actions.\n")
    end
end)
EasyConvars:SetPersistent("body_holsters_holster_is_analog", true)


EasyConvars:RegisterConvar("body_holsters_holster_action", ANALOG_INPUT_HAND_CURL, "The digital or analog action for holstering.", 0, convarUpdateController,
-- Display func
function (reg)
    Msg(reg.name .. " = " .. tostring(reg.value) .. "\n")
    if EasyConvars:GetBool("body_holsters_holster_is_analog") then
        Msg("Holster analog action is " .. Input:GetAnalogDescription(tonumber(reg.value)) .. "\n")
    else
        Msg("Holster digital action is " .. Input:GetButtonDescription(tonumber(reg.value)) .. "\n")
    end
end)
EasyConvars:SetPersistent("body_holsters_holster_action", true)


EasyConvars:RegisterConvar("body_holsters_unholster_is_analog", true, "Whether analog actions should be used instead of digital actions for unholstering", 0, nil,
-- Display func
function (reg)
    Msg(reg.name .. " = " .. tostring(reg.value) .. "\n")
    Msg("Whether analog actions should be used instead of digital actions for unholstering. ")
    if truthy(reg.value) then
        Msg("Unholstering is using analog actions.\n")
    else
        Msg("Unholstering is using digital actions.\n")
    end
end)
EasyConvars:SetPersistent("body_holsters_unholster_is_analog", true)


EasyConvars:RegisterConvar("body_holsters_unholster_action", function()
    if getVRControllerType() == VR_CONTROLLER_TYPE_KNUCKLES then
        return ANALOG_INPUT_SQUEEZE_XEN_GRENADE
    else
        return ANALOG_INPUT_HAND_CURL
    end
end, "The digital or analog action for unholstering", 0, convarUpdateController,
-- Display func
function (reg)
    Msg(reg.name .. " = " .. tostring(reg.value) .. "\n")
    if EasyConvars:GetBool("body_holsters_unholster_is_analog") then
        Msg("Unholster analog action is " .. Input:GetAnalogDescription(tonumber(reg.value)) .. "\n")
    else
        Msg("Unholster digital action is " .. Input:GetButtonDescription(tonumber(reg.value)) .. "\n")
    end
end)
EasyConvars:SetPersistent("body_holsters_unholster_action", true)


---All convar work that needs to be done after convars have finished setting up
---Extra checks need to happen here to make sure we don't overwrite user's custom values
EasyConvars:SetPostInitializer(function()

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

require "alyxlib.controls.input"
Input.AutoStart = true

local cloneName = "__weapon_clone"

local version = "v1.1.0"

---@class BodyHolsters
BodyHolsters = {}
BodyHolsters.version = version
BodyHolsters.__index = BodyHolsters

local addonID = RegisterAlyxLibAddon("Body Holsters", version, "3144612716", "body_holsters", "v1.3.0", nil)

local lastThinkTime = 0

RegisterAlyxLibDiagnostic(addonID, function ()
    if not Player.HMDAvatar then
        return false, "Resin watch requires VR or +vr_enable_fake_vr to be enabled"
    end

    local convars = {
        "body_holsters_visible_weapons",
        "body_holsters_increase_offhand_side_radius",
        "body_holsters_allow_multitool",
        "body_holsters_unholster_grip_amount",
        "body_holsters_holster_ungrip_amount",
        "body_holsters_use_procedural_angles",
        "body_holsters_holster_is_analog",
        "body_holsters_holster_action",
        "body_holsters_unholster_is_analog",
        "body_holsters_unholster_action",
    }

    for _, convar in ipairs(convars) do
        if EasyConvars:WasChangedByUser(convar) then
            Msg(convar .. " = " .. EasyConvars:GetStr(convar) .. "\n")
        end
    end

    local holsterIsAnalog = EasyConvars:GetBool("body_holsters_holster_is_analog")
    local holsterAction = EasyConvars:GetFloat("body_holsters_holster_action")
    if holsterIsAnalog then
        if holsterAction  < 0 or holsterAction > 4 then
            return false, "body_holsters_holster_action must be an analog action ranging from 0 to 4. See this guide for more info: "
        end
    else
        if holsterAction < 0 or holsterAction > 27 then
            return false, "body_holsters_holster_action must be a digital action ranging from 0 to 27. See this guide for more info: "
        end
    end

    local unholsterIsAnalog = EasyConvars:GetBool("body_holsters_unholster_is_analog")
    local unholsterAction = EasyConvars:GetFloat("body_holsters_unholster_action")
    if unholsterIsAnalog then
        if unholsterAction  < 0 or unholsterAction > 4 then
            return false, "body_holsters_unholster_action must be an analog action ranging from 0 to 4. See this guide for more info: "
        end
    else
        if unholsterAction < 0 or unholsterAction > 27 then
            return false, "body_holsters_unholster_action must be a digital action ranging from 0 to 27. See this guide for more info: "
        end
    end

    if not Player then
        return false, "Player entity not found."
    end

    if not Player:GetBackpack() then
        return false, "Backpack entity not found. Backpack is required for body holsters to function correctly."
    end

    Msg("Body Holsters last think time: " .. Time() - lastThinkTime .. " seconds ago (" .. lastThinkTime .. ")\n")

    return true
end)

---When you look down your head origin moves forward and down but body and arms stay the same place
---This causes a perceived disparity between where the slots actually are vs where you think they should be
---This variable artificially moves slots back and up based on how much the player is looking down
---When fully looking down the slots will be moved this many units back
BodyHolsters.cameraForwardZSlotAdjustment = 5

---Players have less reach to the non-dominant side of the body.
---If `body_holsters_increase_offhand_side_radius` is true then non-dominant side slots will increase there radius by this many units.
BodyHolsters.offHandRadiusIncrease = 1.2

---@class BodyHolstersSlot
---@field name string # Name of the slot.
---@field offset Vector # Local offset from the main holster origin (usually the backpack).
---@field angles QAngle? # Local angles to use when parenting to the main holster object.
---@field radius number # Size of the slot sphere.
---@field storedWeapon EntityHandle? # Handle of the actual inventory weapon stored in the slot.
---@field leftside boolean # Slot is on the left-hand side of the body.
---@field disableBackpack boolean? # If the backpack should be disabled when hand is inside this slot.

---@type BodyHolstersSlot[]
BodyHolsters.slots =
{
    -- +x = forward
    -- -x = backward
    -- +y = left
    -- -y = right
    {
        name = "left_hip",
        offset = Vector(0, 9, -26),
        angles = QAngle(90, 0, 0),
        radius = 7,
        storedWeapon = nil,
        leftside = true,
    },
    {
        name = "right_hip",
        offset = Vector(0, -9, -26),
        angles = QAngle(90, 0, 0),
        radius = 7,
        leftside = false,
    },

    {
        name = "left_underarm",
        offset = Vector(0, 6, -12),
        angles = QAngle(35, 180, 0),
        radius = 5.5,
        leftside = true,
    },
    {
        name = "right_underarm",
        offset = Vector(0, -6, -12),
        angles = QAngle(35, 180, 0),
        radius = 5.5,
        leftside = false,
    },

    {
        name = "left_shoulder",
        offset = Vector(-6.5, 5, -2),
        angles = QAngle(90, 90, 0),
        radius = 10,
        leftside = true,
        disableBackpack = true,
    },
    {
        name = "right_shoulder",
        offset = Vector(-6.5, -5, -2),
        angles = QAngle(90, -90, 0),
        radius = 10,
        leftside = false,
        disableBackpack = true,
    },

    {
        name = "chest",
        offset = Vector(1, 0, -12),
        angles = QAngle(35, 90, 0),
        radius = 5,
        leftside = false,
    },
}

Convars:RegisterCommand("body_holsters_slot", function (_, name, x, y, z, radius)
    -- Printing all slots if no name given
    if name == nil then
        for index, slot in ipairs(BodyHolsters.slots) do
            Msg(slot.name .. " " .. slot.offset.x .. " " .. slot.offset.y .. " " .. slot.offset.z .. " " .. slot.radius .. "\n")
        end
        return
    end

    local slot = BodyHolsters:GetSlot(name)
    if slot == nil then
        Msg("No body holster slot with name '"..name.."'")
        return
    end

    -- Printing specific slot if no values given
    if x == nil then
        Msg(slot.name .. " " .. slot.offset.x .. " " .. slot.offset.y .. " " .. slot.offset.z .. " " .. slot.radius)
        return
    end

    -- Modifying

    x = tonumber(x) or slot.offset.x
    y = tonumber(y) or slot.offset.y
    z = tonumber(z) or slot.offset.z
    radius = tonumber(radius) or slot.radius

    slot.offset = Vector(x, y, z)
    slot.radius = radius

    Msg("Modified " .. slot.name .. " " .. slot.offset.x .. " " .. slot.offset.y .. " " .. slot.offset.z .. " " .. slot.radius)

end, "", 0)

---Get a slot table by its name.
---@param name string
---@return BodyHolstersSlot?
function BodyHolsters:GetSlot(name)
    for _, slot in ipairs(BodyHolsters.slots) do
        if slot.name == name then
            return slot
        end
    end
    return nil
end

---Get holstered weapon clone based on the weapon class it represents.
---@param weapon EntityHandle
---@return EntityHandle?
function GetHolsteredWeaponClone(weapon)
    return Entities:FindByName(nil, weapon:GetName() .. "_" .. weapon:GetClassname() .. "_clone")
end

---Get data related to holstering, usually to do with the backpack.
---@return Vector holsterOrigin # The origin of the holster entity.
---@return EntityHandle holsterEnt # The entity used for holstering.
local function getPlayerHolsterData()
    local backpack = Player:GetBackpack()
    if backpack then
        return backpack:GetCenter(), backpack
    else
        return Player.HMDAvatar:GetAbsOrigin(), Player.HMDAvatar
    end
end

---Get slots within range of `pos`, sorted by ascending distance.
---@param pos Vector
---@return BodyHolstersSlot[]
local function getNearestSlots(pos)
    local slots = {}
    local holsterPos, holsterEnt = getPlayerHolsterData()
    for _, slot in ipairs(BodyHolsters.slots) do

        local lookZ = Player:EyeAngles():Forward().z
        local adjust = RemapValClamped(lookZ, -1, 0, BodyHolsters.cameraForwardZSlotAdjustment, 0)
                                                                    ---@TODO PUT adjust BACK IN VECTOR BEFORE RELEASE, SAME IN DEBUG FUNCTION
        local slotOrigin = holsterEnt:TransformPointEntityToWorld(slot.offset - Vector(adjust, 0, -adjust))

        local distance = VectorDistance(slotOrigin, pos)

        -- Dynamic radius
        local radius = slot.radius
        if EasyConvars:GetBool("body_holsters_increase_offhand_side_radius") and (slot.leftside ~= Player.IsLeftHanded) then
            radius = radius + BodyHolsters.offHandRadiusIncrease
        end

        if distance <= radius then
            table.insert(slots, { slot = slot, distance = distance })
        end
    end

    -- Sort the slots based on distance in ascending order
    table.sort(slots, function(a, b) return a.distance < b.distance end)

    -- Extract the sorted slots from the table
    local sortedSlots = {}
    for _, entry in ipairs(slots) do
        table.insert(sortedSlots, entry.slot)
    end

    return sortedSlots
end

---Get the primary hand origin.
---@return Vector
local function getHandPosition()
    return Player.PrimaryHand:GetAttachmentOrigin(Player.PrimaryHand:ScriptLookupAttachment("vr_hand_origin"))
end

local function holsterDebugThink()
    local holsterOrigin, holsterEnt = getPlayerHolsterData()
    local handOrigin = Player.PrimaryHand:GetAttachmentOrigin(Player.PrimaryHand:ScriptLookupAttachment("vr_hand_origin"))

    -- Hand position
    debugoverlay:Sphere(handOrigin, 0.5, 255,255,255,255,true,0)

    for i, slot in ipairs(BodyHolsters.slots) do
        local lookZ = Player:EyeAngles():Forward().z
        local adjust = RemapValClamped(lookZ, -1, 0, BodyHolsters.cameraForwardZSlotAdjustment, 0)
        local slotOrigin = holsterEnt:TransformPointEntityToWorld(slot.offset - Vector(adjust, 0, -adjust))
        local r,g,b = 255,255,255
        local weapon = Player:GetWeapon()
        local radius = slot.radius
        if EasyConvars:GetBool("body_holsters_increase_offhand_side_radius") and (slot.leftside ~= Player.IsLeftHanded) then
            radius = radius + BodyHolsters.offHandRadiusIncrease
        end
        if slot.storedWeapon ~= nil then
            if weapon == nil and Player.PrimaryHand.ItemHeld == nil and VectorDistance(slotOrigin, handOrigin) <= radius then
                -- Slot full and can be grabbed
                r,g,b = 0,0,255 --blue
            else
                -- Slot full
                r,g,b = 255,255,0 --yellow
            end
        else
            -- Slot empty and hand has weapon
            if weapon ~= nil and VectorDistance(slotOrigin, getHandPosition()) <= radius then
                r,g,b = 0,255,0 --green
            end
        end
        debugoverlay:Sphere(slotOrigin, radius, r, g, b, 5, false, 0)
        debugoverlay:Text(slotOrigin, 0, slot.name, 0, 255, 255, 255, 255, 0)
    end

    return 0
end

Convars:RegisterCommand("body_holsters_debug", function (_, on)
    on = truthy(on)
    if on then
        Player:SetContextThink("holsterDebugThink", holsterDebugThink, 0)
    else
        Player:SetContextThink("holsterDebugThink", nil, 0)
    end
end, "", 0)

---Clone a weapon and any children
---@param weapon EntityHandle
local function cloneWeapon(weapon, class, spawnkeys)
    class = class or "prop_dynamic_override"
    spawnkeys = spawnkeys or {}

    local clone = SpawnEntityFromTableSynchronous(class, vlua.tableadd({
        angles = weapon:GetAngles(),
        origin = weapon:GetOrigin(),
        model = weapon:GetModelName(),
        solid = "0",
        targetname = cloneName,
        -- rendermode = EasyConvars:GetBool("body_holsters_visible_weapons") and "kRenderNormal" or "kRenderNone",
        vscripts = "",
        disableshadows = "1",
    }, spawnkeys))
    clone:SetMaterialGroupHash(weapon:GetMaterialGroupHash())
    clone:SetMaterialGroupMask(weapon:GetMaterialGroupMask())

    -- Clone weapon children
    for _, child in ipairs(weapon:GetTopChildren()) do
        if child:GetModelName() ~= "" and child:GetClassname() ~= "prop_handpose" then
            local childClone = cloneWeapon(child, class, vlua.tableadd(spawnkeys, {targetname = ""}))
            childClone:SetParent(clone, "")
        end
    end

    return clone
end

---Get if a weapon can be stored in a slot, making sure it's empty and multitool is accepted.
---@param slot BodyHolstersSlot
---@param weapon EntityHandle
---@return boolean
function BodyHolsters:CanStoreInSlot(slot, weapon)
    if
        (slot.storedWeapon == nil or slot.storedWeapon == weapon)
        and weapon ~= nil and (weapon:GetClassname() ~= "hlvr_multitool" or EasyConvars:GetBool("body_holsters_allow_multitool"))
    then
        return true
    end
    return false
end

---Holster a weapon in a slot.
---
---**This does NOT remove the weapon from the hand! It only assigns it to a slot.**
---@param slot BodyHolstersSlot
---@param weapon EntityHandle
---@param silent? boolean
function BodyHolsters:HolsterWeapon(slot, weapon, silent)
    -- Destroy old clone if reholstering from a weapon switch
    local existingWeaponClone = GetHolsteredWeaponClone(weapon)
    if existingWeaponClone then
        existingWeaponClone:Kill()
    end

    -- Create new clone if enabled
    if EasyConvars:GetBool("body_holsters_visible_weapons") then
        local weaponClone = cloneWeapon(weapon, nil, { targetname = weapon:GetName() .. "_" .. weapon:GetClassname() .. "_clone" })
        local _, holsterEnt = getPlayerHolsterData()
        weaponClone:SetParent(holsterEnt, "")

        if slot.angles and not EasyConvars:GetBool("body_holsters_use_procedural_angles") then
            weaponClone:SetLocalQAngle(slot.angles)
        end

        weaponClone:SetCenter(holsterEnt:TransformPointEntityToWorld(slot.offset))

    end

    slot.storedWeapon = weapon
    Player:SaveEntity("BodyHolster_"..slot.name, weapon, true)

    if not silent then
        StartSoundEventFromPositionReliable("body_holsters.holster", Player.PrimaryHand:GetPalmPosition())
    end
end

---Unholster a weapon from a given slot.
---@param slot BodyHolstersSlot
---@param silent? boolean
---@return boolean # If the weapon was unholstered successfully.
function BodyHolsters:UnholsterSlot(slot, silent)
    local weapon = slot.storedWeapon
    if not weapon then
        return false
    end

    local clone = GetHolsteredWeaponClone(weapon)
    if clone then
        clone:Kill()
    -- Warn only if clones should exist
    elseif EasyConvars:GetBool("body_holsters_visible_weapons") then
        warn("Clone doesn't exist for stored weapon " ..Debug.EntStr(slot.storedWeapon))
    end

    slot.storedWeapon = nil
    Player:SaveEntity("BodyHolster_"..slot.name, nil)

    if not silent then
        StartSoundEventFromPositionReliable("body_holsters.unholster", Player.PrimaryHand:GetPalmPosition())
    end
    return true
end

---Unholster a weapon from whatever slot it's stored in.
---@param weapon EntityHandle
---@param silent? boolean
---@return boolean # If the weapon was unholstered successfully.
function BodyHolsters:UnholsterWeapon(weapon, silent)
    for _, slot in ipairs(BodyHolsters.slots) do
        if weapon == slot.storedWeapon then
            return BodyHolsters:UnholsterSlot(slot, silent)
        end
    end
    return false
end

local inputHolsterCallback = function(params)
    local weapon = Player:GetWeapon()
    if weapon ~= nil then
        if weapon:GetClassname() == "hlvr_multitool" and not EasyConvars:GetBool("body_holsters_allow_multitool") then
            StartSoundEventReliable("Inventory.Invalid", Player)
            return
        end
        local handOrigin = getHandPosition()
        local notifyInvalid = false -- Plays a sound if holster is invalid
        local slots = getNearestSlots(handOrigin)
        for _, slot in ipairs(slots) do
            if slot.storedWeapon ~= nil and slot.storedWeapon ~= weapon then
                notifyInvalid = true
            elseif slot.storedWeapon == nil or slot.storedWeapon == weapon then
                -- Unholster the weapon everywhere else first
                BodyHolsters:UnholsterWeapon(weapon, true)
                -- Then holster into slot
                BodyHolsters:HolsterWeapon(slot, weapon, false)

                Player.PrimaryHand:FireHapticPulse(1)
                notifyInvalid = false

                -- Remove weapon from hand
                Player:SetWeapon("hand_use_controller")

                devprints("Holstered", weapon:GetClassname(), weapon:GetName(), "in", slot.name)
                break
            end
        end

        if notifyInvalid then
            StartSoundEventReliable("Inventory.Invalid", Player)
        end
    end
end

local inputHolsterID

local inputUnholsterCallback = function(params)

    -- Make sure player isn't holding anything first
    local weapon = Player:GetWeapon()
    if weapon == nil and Player.PrimaryHand.ItemHeld == nil then
        local handOrigin = getHandPosition()
        local slots = getNearestSlots(handOrigin)

        for _, slot in ipairs(slots) do
            if slot.storedWeapon ~= nil then

                local coughpose = Player.HMDAvatar:GetFirstChildWithClassname("prop_handpose")
                if coughpose then
                    coughpose:EntFire("Disable")
                    local stored = slot.storedWeapon
                    Player:Delay(function()
                        Player:SetWeapon(stored)
                        coughpose:Delay(function() coughpose:EntFire("Enable") end, 0.2)
                    end, 0.1)
                else
                    Player:SetWeapon(slot.storedWeapon)
                end


                devprints("Unholstered", Debug.EntStr(slot.storedWeapon), "from", slot.name)
                BodyHolsters:UnholsterSlot(slot, false)
                Player.PrimaryHand:FireHapticPulse(2)
                break
            end
        end
    end
end

local inputUnholsterID

---Updates the input callbacks using the current settings.
function BodyHolsters:UpdateControllerInputs()
    Input:StopListening(inputUnholsterID)
    if EasyConvars:GetBool("body_holsters_unholster_is_analog") then
        inputUnholsterID = Input:ListenToAnalog("up", 2, EasyConvars:GetInt("body_holsters_unholster_action"), EasyConvars:GetFloat("body_holsters_unholster_grip_amount"), inputUnholsterCallback)
    else
        inputUnholsterID = Input:ListenToButton("press", 2, EasyConvars:GetInt("body_holsters_unholster_action"), 1, inputUnholsterCallback)
    end

    Input:StopListening(inputHolsterID)
    -- inputHolsterID = Input:ListenToAnalog("down", 2, ANALOG_INPUT_HAND_CURL, EasyConvars:GetFloat("body_holsters_holster_ungrip_amount"), inputHolsterCallback)
    if EasyConvars:GetBool("body_holsters_holster_is_analog") then
        inputHolsterID = Input:ListenToAnalog("down", 2, EasyConvars:GetInt("body_holsters_holster_action"), EasyConvars:GetFloat("body_holsters_holster_ungrip_amount"), inputHolsterCallback)
    else
        inputHolsterID = Input:ListenToButton("press", 2, EasyConvars:GetInt("body_holsters_holster_action"), 1, inputHolsterCallback)
    end
end

local handWithinSlot = false
---Main think function for providing haptic feedback.
---@return number
local function playerHolsterThink()
    lastThinkTime = Time()

    -- Notify hand within slot
    local slot = getNearestSlots(getHandPosition())[1]
    if slot ~= nil
        and (BodyHolsters:CanStoreInSlot(slot, Player:GetWeapon()) or (Player:GetWeapon() == nil and slot.storedWeapon ~= nil))
    then
        if handWithinSlot == false then
            handWithinSlot = true
            Player.PrimaryHand:FireHapticPulse(1)
            if slot.storedWeapon and Player.PrimaryHand.ItemHeld == nil then
                if slot.disableBackpack then
                    BodyHolsters:DisableBackpack()
                end
            end
        end
    elseif handWithinSlot == true then
        handWithinSlot = false
        BodyHolsters:EnableBackpack()
    end
    return 0.1
end

---@type EntityHandle?
local equipDisableBackpack
---@type EntityHandle?
local equipEnableBackpack
---@type EntityHandle?
local equipDisableBackpackWrist
---@type EntityHandle?
local equipEnableBackpackWrist

function BodyHolsters:DisableBackpack()
    if equipDisableBackpack and equipDisableBackpackWrist and Player:GetBackpack() then
        if Player:HasItemHolder() then
            equipDisableBackpackWrist:EntFire("EquipNow")
        else
            equipDisableBackpack:EntFire("EquipNow")
        end
    end
end

function BodyHolsters:EnableBackpack()
    if equipEnableBackpack and equipEnableBackpackWrist and Player:GetBackpack() then
        -- Delay is required to stop grabbing magazine at the same time
        if Player:HasItemHolder() then
            equipEnableBackpackWrist:EntFire("EquipNow", nil, 0.1)
        else
            equipEnableBackpack:EntFire("EquipNow", nil, 0.1)
        end
    end
end

local debug = true

local EQUIP_BACKPACK_KEYS = {
    classname = "info_hlvr_equip_player",
    equip_on_mapstart = "0",
    itemholder = "0",
    inventory_enabled = "0",
    backpack_enabled = "0",
}

ListenToPlayerEvent("vr_player_ready", function (params)

    for _, slot in ipairs(BodyHolsters.slots) do
        slot.storedWeapon = Player:LoadEntity("BodyHolster_"..slot.name)
    end

    equipDisableBackpack = Entities:FindByName(nil, "body_holsters_equipDisableBackpack")
    if not equipDisableBackpack then
        equipDisableBackpack = SpawnEntityFromTableSynchronous(EQUIP_BACKPACK_KEYS.classname,vlua.tableadd(EQUIP_BACKPACK_KEYS,{targetname="body_holsters_equipDisableBackpack"}))
    end
    equipDisableBackpackWrist = Entities:FindByName(nil, "body_holsters_equipDisableBackpackWrist")
    if not equipDisableBackpackWrist then
        equipDisableBackpackWrist = SpawnEntityFromTableSynchronous(EQUIP_BACKPACK_KEYS.classname,vlua.tableadd(EQUIP_BACKPACK_KEYS,{targetname="body_holsters_equipDisableBackpackWrist",itemholder="1"}))
    end

    equipEnableBackpack = Entities:FindByName(nil, "body_holsters_equipEnableBackpack")
    if not equipEnableBackpack then
        equipEnableBackpack = SpawnEntityFromTableSynchronous(EQUIP_BACKPACK_KEYS.classname,vlua.tableadd(EQUIP_BACKPACK_KEYS,{targetname="body_holsters_equipEnableBackpack",backpack_enabled = "1"}))
    end
    equipEnableBackpackWrist = Entities:FindByName(nil, "body_holsters_equipEnableBackpackWrist")
    if not equipEnableBackpackWrist then
        equipEnableBackpackWrist = SpawnEntityFromTableSynchronous(EQUIP_BACKPACK_KEYS.classname,vlua.tableadd(EQUIP_BACKPACK_KEYS,{targetname="body_holsters_equipEnableBackpackWrist",backpack_enabled = "1",itemholder="1"}))
    end

    Player:SetContextThink("playerHolsterThink", playerHolsterThink, 0)

    if debug and IsInToolsMode() and Convars:GetInt("developer") > 1 then
        SendToConsole("body_holsters_debug 1")
    end

    Player:Delay(function ()
        BodyHolsters:UpdateControllerInputs()
    end)

    print("Body Holsters ".. version .." initialized...")
end)