require "core"

EasyConvars:RegisterConvar("body_holsters_visible_weapons", "0", "Weapons are visibly attached to the player body.", 0)
EasyConvars:SetPersistent("body_holsters_visible_weapons", true)
EasyConvars:RegisterConvar("body_holsters_allow_multitool", "0", "Multitool is allowed to be holstered.", 0)
EasyConvars:SetPersistent("body_holsters_allow_multitool", true)
EasyConvars:RegisterConvar("body_holsters_increase_offhand_side_radius", "1", "Slots on the side of the body opposite to the primary hand are increased.", 0)
EasyConvars:SetPersistent("body_holsters_increase_offhand_side_radius", true)

Input:TrackButtons({ DIGITAL_INPUT_USE, DIGITAL_INPUT_USE_GRIP })

local holsterGrabButton = DIGITAL_INPUT_USE_GRIP

local cloneName = "__weapon_clone"

local version = "v0.1.1"

---@class BodyHolsters
BodyHolsters = {}
BodyHolsters.version = version
BodyHolsters.__index = BodyHolsters


---When you look down your head origin moves forwards but body and arms stay the same place
---This causes a perceived disparity between where the slots actually are vs where you think they should be
---This variable artificially moves slots back based on how much the player is looking down
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

---@type BodyHolstersSlot[]
BodyHolsters.slots =
{
    -- +x = forward
    -- -x = backward
    -- +y = left
    -- -y = right
    {
        name = "left_hip",
        offset = Vector(0, 9, -22),
        radius = 7,
        storedWeapon = nil,
        leftside = true,
    },
    {
        name = "right_hip",
        offset = Vector(0, -9, -22),
        radius = 7,
        leftside = false,
    },

    {
        name = "left_underarm",
        offset = Vector(0, 6, -10),
        radius = 5.5,
        leftside = true,
    },
    {
        name = "right_underarm",
        offset = Vector(0, -6, -10),
        radius = 5.5,
        leftside = false,
    },

    {
        name = "left_shoulder",
        offset = Vector(-6.5, 5, 0),
        radius = 10,
        leftside = true,
    },
    {
        name = "right_shoulder",
        offset = Vector(-6.5, -5, 0),
        radius = 10,
        leftside = false,
    },

    {
        name = "chest",
        offset = Vector(1, 0, -11),
        radius = 5,
        leftside = false,
    },
}

Convars:RegisterCommand("body_holsters_slot", function (_, name, x, y, z, radius)
    -- Printing all slots if no name given
    if name == nil then
        for index, slot in ipairs(BodyHolsters.slots) do
            Msg(slot.name .. " " .. slot.offset.x .. " " .. slot.offset.y .. " " .. slot.offset.z .. " " .. slot.radius)
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
        local slotOrigin = holsterEnt:TransformPointEntityToWorld(slot.offset - Vector(adjust))

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
        local slotOrigin = holsterEnt:TransformPointEntityToWorld(slot.offset - Vector(adjust))
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
        debugoverlay:Sphere(slotOrigin, radius, r, g, b, 255, false, 0)
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

    -- Don't need children if weapons are invisible
    -- if EasyConvars:GetBool("body_holsters_visible_weapons") then
        for _, child in ipairs(weapon:GetTopChildren()) do
            if child:GetModelName() ~= "" then
                local childClone = cloneWeapon(child, class, vlua.tableadd(spawnkeys, {targetname = ""}))
                childClone:SetParent(clone, "")
            end
        end
    -- end

    return clone
end

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
---@param slot BodyHolstersSlot
---@param weapon EntityHandle
---@param silent? boolean
function BodyHolsters:HolsterWeapon(slot, weapon, silent)
    -- Destroy old clone if reholstering from a weapon switch
    local existingWeaponClone = GetHolsteredWeaponClone(weapon)
    if existingWeaponClone then
        existingWeaponClone:Kill()
    end

    -- Create new clone
    if EasyConvars:GetBool("body_holsters_visible_weapons") then
        local weaponClone = cloneWeapon(weapon, nil, { targetname = weapon:GetName() .. "_" .. weapon:GetClassname() .. "_clone" })
        local _, holsterEnt = getPlayerHolsterData()
        weaponClone:SetParent(holsterEnt, "")
        weaponClone:SetLocalOrigin(slot.offset)
        if slot.angles then
            weaponClone:SetLocalQAngle(slot.angles)
        end
    end

    slot.storedWeapon = weapon
    Player:SaveEntity("BodyHolster_"..slot.name, weapon, true)

    if not silent then
        StartSoundEventReliable("body_holsters.holster", Player)
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
        StartSoundEventReliable("body_holsters.unholster", Player)
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

local inputReleaseCallback = function(params)
    -- devprint("RELEASE")
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

                devprints("Holstered", weapon:GetClassname(), weapon:GetName())
                break
            end
        end

        if notifyInvalid then
            StartSoundEventReliable("Inventory.Invalid", Player)
        end
    end
end
Input:RegisterCallback("release", 2, DIGITAL_INPUT_USE_GRIP, 1, inputReleaseCallback)

EasyConvars:Register("body_holsters_require_use_to_holster", "0", function (on)
    on = truthy(on)
    Input:UnregisterCallback(inputReleaseCallback)
    Input:RegisterCallback("release", 2, on and DIGITAL_INPUT_USE or DIGITAL_INPUT_USE_GRIP, 1, inputReleaseCallback)
    return on
end, "Use button must be pressed to holster a weapon.", 0)
EasyConvars:SetPersistent("body_holsters_require_trigger_to_unholster", true)

local inputPressCallback = function(params)
    -- devprint("PRESS")
    local weapon = Player:GetWeapon()
    -- Make sure player isn't holding anything first
    if weapon == nil and Player.PrimaryHand.ItemHeld == nil then
        local handOrigin = getHandPosition()
        local slots = getNearestSlots(handOrigin)

        for _, slot in ipairs(slots) do
            if slot.storedWeapon ~= nil then

                Player:SetWeapon(slot.storedWeapon)

                devprints("Unholstering", Debug.EntStr(slot.storedWeapon))
                BodyHolsters:UnholsterSlot(slot, false)
                Player.PrimaryHand:FireHapticPulse(2)
                break
            end
        end
    end
end
Input:RegisterCallback("press", 2, holsterGrabButton, 1, inputPressCallback)

-- local holsters_require_trigger_to_unholster = false
EasyConvars:Register("body_holsters_require_trigger_to_unholster", "0", function (on)
    on = truthy(on)
    Input:UnregisterCallback(inputPressCallback)
    Input:RegisterCallback("press", 2, on and DIGITAL_INPUT_USE or DIGITAL_INPUT_USE_GRIP, 1, inputPressCallback)
    return on
end, "Trigger button (fire) must be pressed to unholster a weapon.", 0)
EasyConvars:SetPersistent("body_holsters_require_trigger_to_unholster", true)

local handWithinSlot = false
---Main think function for providing haptic feedback.
---@return number
local function playerHolsterThink()
    -- Notify hand within slot
    local slot = getNearestSlots(getHandPosition())[1]
    if slot ~= nil
        and (BodyHolsters:CanStoreInSlot(slot, Player:GetWeapon()) or (Player:GetWeapon() == nil and slot.storedWeapon ~= nil))
    then
        if handWithinSlot == false then
            handWithinSlot = true
            Player.PrimaryHand:FireHapticPulse(1)
        end
    else
        handWithinSlot = false
    end
    return 0.1
end


local debug = true

RegisterPlayerEventCallback("vr_player_ready", function (params)

    for _, slot in ipairs(BodyHolsters.slots) do
        slot.storedWeapon = Player:LoadEntity("BodyHolster_"..slot.name)
    end

    Player:SetContextThink("playerHolsterThink", playerHolsterThink, 0)

    if debug and IsInToolsMode() then
        SendToConsole("body_holsters_debug 1")
    end

    print("Body Holsters ".. version .." initialized...")
end)