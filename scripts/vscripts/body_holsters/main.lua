require "core"

-- local HOLSTER_DISTANCE = 32
-- local GRAB_DISTANCE = 6
-- local HOLSTER_MIN_HEIGHT = -32
-- local HOLSTER_MAX_HEIGHT = 16

-- Convars:RegisterConvar("holsters_grab_distance", tostring(GRAB_DISTANCE), "", 0)
-- Convars:RegisterConvar("holsters_holster_distance", tostring(HOLSTER_DISTANCE), "Max distance from the player body a weapon can be holstered when released", 0)
-- Convars:RegisterConvar("holsters_holster_min_height", tostring(HOLSTER_MIN_HEIGHT), "Min height from player feet that a weapon can be holstered.", 0)
-- Convars:RegisterConvar("holsters_holster_max_height", tostring(HOLSTER_MAX_HEIGHT), "Max height from player feet that a weapon can be holstered.", 0)
Convars:RegisterConvar("holsters_visible_weapons", "0", "Weapons are visibly attached to the player body.", 0)
-- Convars:RegisterConvar("holsters_debug", "0", "", 0)
Convars:RegisterConvar("holsters_allow_multitool", "0", "Multitool is allowed to be holstered.", 0)

Input:TrackButtons({ DIGITAL_INPUT_USE, DIGITAL_INPUT_USE_GRIP })

local holsterGrabButton = DIGITAL_INPUT_USE_GRIP

local cloneName = "__weapon_clone"

local version = "v0.1.0"

---@class BodyHolsters
BodyHolsters = {}
BodyHolsters.version = version
BodyHolsters.__index = BodyHolsters

---@class BodyHolstersSlot
---@field name string # Name of the slot.
---@field offset Vector # Local offset from the main holster origin (usually the backpack).
---@field angles QAngle? # Local angles to use when parenting to the main holster object.
---@field radius number # Size of the slot sphere.
---@field storedWeapon EntityHandle? # Handle of the actual inventory weapon stored in the slot.

---@type BodyHolstersSlot[]
BodyHolsters.slots =
{
    -- +x = forward
    -- -x = backward
    -- +y = left
    -- -y = right
    {
        name = "left_hip",
        offset = Vector(-3, 7, -22),
        radius = 9,
        storedWeapon = nil,
    },
    {
        name = "right_hip",
        offset = Vector(-3, -7, -22),
        radius = 9,
    },

    {
        name = "left_underarm",
        offset = Vector(-3, 6, -10),
        radius = 5.5,
    },
    {
        name = "right_underarm",
        offset = Vector(-3, -6, -10),
        radius = 5.5,
    },

    {
        name = "left_shoulder",
        offset = Vector(-10, 5, 0),
        radius = 10,
    },
    {
        name = "right_shoulder",
        offset = Vector(-10, -5, 0),
        radius = 10,
    },
}

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
        local slotOrigin = holsterEnt:TransformPointEntityToWorld(slot.offset)
        local distance = VectorDistance(slotOrigin, pos)
        if distance <= slot.radius then
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

local debugballs = {}

local function holsterDebugThink()
    local holsterOrigin, holsterEnt = getPlayerHolsterData()
    local handOrigin = Player.PrimaryHand:GetAttachmentOrigin(Player.PrimaryHand:ScriptLookupAttachment("vr_hand_origin"))

    -- Hand position
    debugoverlay:Sphere(handOrigin, 0.5, 255,255,255,255,true,0)

    for i, slot in ipairs(BodyHolsters.slots) do
        local slotOrigin = holsterEnt:TransformPointEntityToWorld(slot.offset)
        local r,g,b = 255,255,255
        local weapon = Player:GetWeapon()
        if slot.storedWeapon ~= nil then
            if weapon == nil and Player.PrimaryHand.ItemHeld == nil and VectorDistance(slotOrigin, handOrigin) <= slot.radius then
                -- Slot full and can be grabbed
                r,g,b = 0,0,255 --blue
            else
                -- Slot full
                r,g,b = 255,255,0 --yellow
            end
        else
            -- Slot empty and hand has weapon
            if weapon ~= nil and VectorDistance(slotOrigin, getHandPosition()) <= slot.radius then
                r,g,b = 0,255,0 --green
            end
        end
        -- debugballs[i]:SetAbsOrigin(slotOrigin)
        debugoverlay:Sphere(slotOrigin, slot.radius, r, g, b, 255, false, 0)
        debugoverlay:Text(slotOrigin, 0, slot.name, 0, 255, 255, 255, 255, 0)
    end

    return 0
end

Convars:RegisterCommand("holsters_debug", function (_, on)
    on = truthy(on)
    if on then
        local _,ent = getPlayerHolsterData()
        local s

        -- s = SpawnEntityFromTableSynchronous("prop_dynamic_override", {
        --     model="models/controller/vr_hmd.vmdl",
        -- })
        -- s:SetParent(Player.HMDAvatar, "")
        -- s:ResetLocal()

        -- s = SpawnEntityFromTableSynchronous("prop_dynamic_override", {
        --     model="models/items/backpack/backpack_inventory.vmdl",
        -- })
        -- s:SetParent(ent, "")
        -- s:ResetLocal()

        Player:SetContextThink("holsterDebugThink", holsterDebugThink, 0)

        -- for i, slot in ipairs(BodyHolsters.slots) do
        --     s = SpawnEntityFromTableSynchronous("prop_dynamic_override", {
        --         model="models/dev/unit_radius_sphere.vmdl",
        --     })
        --     s:SetAbsScale(slot.radius)
        --     s:SetParent(ent, "")
        --     s:SetLocalOrigin(slot.offset)
        --     s:SetLocalAngles(0,0,0)
        --     debugballs[i] = s
        -- end
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
        rendermode = Convars:GetBool("holsters_visible_weapons") and "kRenderNormal" or "kRenderNone",
        vscripts = "",
        disableshadows = "1",
    }, spawnkeys))
    clone:SetMaterialGroupHash(weapon:GetMaterialGroupHash())
    clone:SetMaterialGroupMask(weapon:GetMaterialGroupMask())

    -- Don't need children if weapons are invisible
    if Convars:GetBool("holsters_visible_weapons") then
        for _, child in ipairs(weapon:GetTopChildren()) do
            if child:GetModelName() ~= "" then
                local childClone = cloneWeapon(child, class, vlua.tableadd(spawnkeys, {targetname = ""}))
                childClone:SetParent(clone, "")
            end
        end
    end

    return clone
end

function BodyHolsters:CanStoreInSlot(slot, weapon)
    if
        (slot.storedWeapon == nil or slot.storedWeapon == weapon)
        and weapon ~= nil and (weapon:GetClassname() ~= "hlvr_multitool" or Convars:GetBool("holsters_allow_multitool"))
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

    -- if weapon:GetName() == "" then
    --     weapon:SetEntityName("player_weapon_" .. (weapon:GetClassname():match(".*_([^_]+)$") or weapon:GetClassname()))
    -- end

    -- Create new clone
    if Convars:GetBool("holsters_visible_weapons") then
        local weaponClone = cloneWeapon(weapon, nil, { targetname = weapon:GetName() .. "_" .. weapon:GetClassname() .. "_clone" })
        local _, holsterEnt = getPlayerHolsterData()
        weaponClone:SetParent(holsterEnt, "")
        weaponClone:SetLocalOrigin(slot.offset)
        if slot.angles then
            weaponClone:SetLocalQAngle(slot.angles)
        end
    end
    -- weaponClone:SaveString("weaponClass", weapon:GetClassname())

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
    else
        Warning("Clone doesn't exist for stored weapon " ..Debug.EntStr(slot.storedWeapon).."\n")
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

Input:RegisterCallback("release", 2, DIGITAL_INPUT_USE_GRIP, 1, function(params)
    devprint("RELEASE")
    local weapon = Player:GetWeapon()
    if weapon ~= nil then
        if weapon:GetClassname() == "hlvr_multitool" and not Convars:GetBool("holsters_allow_multitool") then
            StartSoundEventReliable("Inventory.Invalid", Player)
            return
        end
        local holsterPos, holsterEnt = getPlayerHolsterData()
        local handOrigin = getHandPosition()
        local slots = getNearestSlots(handOrigin)
        for _, slot in ipairs(slots) do
            -- local slotOrigin = holsterPos + holsterEnt:TransformPointEntityToWorld(slot.offset)
            if
               --VectorDistance(slotOrigin, weaponOrigin) <= slot.radius and
               (slot.storedWeapon == nil or slot.storedWeapon == weapon)
            then
                BodyHolsters:HolsterWeapon(slot, weapon, false)
                Player.PrimaryHand:FireHapticPulse(1)

                -- Remove weapon from hand
                Player:SetWeapon("hand_use_controller")

                devprints("Holstered", weapon:GetClassname(), weapon:GetName())
                break
            end

        end
    end
end)

local inputPressCallback = function(params)
    devprint("PRESS")
    local weapon = Player:GetWeapon()
    -- Make sure player isn't holding anything first
    if weapon == nil and Player.PrimaryHand.ItemHeld == nil then
        local holsterPos, holsterEnt = getPlayerHolsterData()
        local handOrigin = getHandPosition()
        local slots = getNearestSlots(handOrigin)

        for _, slot in ipairs(slots) do
            -- local slotOrigin = holsterPos + holsterEnt:TransformPointEntityToWorld(slot.offset)
            if
               --VectorDistance(slotOrigin, handOrigin) <= slot.radius and
               slot.storedWeapon ~= nil
            then
                
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

local holsters_require_trigger_to_unholster = false
Convars:RegisterCommand("holsters_require_trigger_to_unholster", function (_, on)
    if on == nil then
        Msg("holsters_require_trigger_to_unholster" .. (holsters_require_trigger_to_unholster and "1" or "0"))
        return
    end

    on = truthy(on)
    Input:UnregisterCallback(inputPressCallback)
    Input:RegisterCallback("press", 2, on and DIGITAL_INPUT_USE or DIGITAL_INPUT_USE_GRIP, 1, inputPressCallback)
end, "Trigger button (fire) must be pressed to unholster a weapon.", 0)

local handWithinSlot = false
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
        SendToConsole("holsters_debug 1")
    end

    print("Body Holsters ".. version .." initialized...")
end)