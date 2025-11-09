--[[
    Utility functions for body holsters.
]]

local cloneName = "__weapon_clone"

---Get the primary hand origin.
---@param hand? CPropVRHand
---@return Vector
local function getHandPosition(hand)
    hand = hand or Player.PrimaryHand
    return hand:GetAttachmentOrigin(hand:ScriptLookupAttachment("vr_hand_origin"))
end

---
---Clones a weapon and any children.
---
---@param weapon EntityHandle # The weapon to clone
---@return EntityHandle # The weapon clone
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

---
---Checks if an entity is an actual weapon entity (as opposed to a clone).
---
---@param ent EntityHandle # The entity to check
---@return boolean # `true` if the entity is an actual weapon, `false` otherwise
local function isActualWeapon(ent)
    if not IsValidEntity(ent) then return false end

    local cls = ent:GetClassname()
    return cls == "hlvr_weapon_energygun"
    or cls == "hlvr_weapon_shotgun"
    or cls == "hlvr_weapon_rapidfire"
    or cls == "hlvr_weapon_generic_pistol"
    or cls == "hlvr_multitool"
end

---@diagnostic disable: undefined-field

---
---Gets the actual weapon entity equipped in a given hand.
---
---@param hand CPropVRHand # The hand to get the weapon from
---@return EntityHandle? # The weapon entity, if any
local function getWeaponFromHand(hand)
    if not IsValidEntity(hand) then return nil end

    if type(hand.GetWeapon) == "function" then
        return hand:GetWeapon()
    end

    if isActualWeapon(hand.ItemHeld) then
        return hand.ItemHeld
    end

    return nil
end

---
---Unequips weapon from a given hand.
---
---Uses the `OnHolsterUnequip` hook if available, otherwise does it manually.
---
---@param weapon EntityHandle
---@param hand CPropVRHand
local function unequipWeapon(weapon, hand)
    if type(weapon.OnHolsterUnequip) == "function" then
        weapon:OnHolsterUnequip(hand)
    else
        if hand == Player.PrimaryHand then
            Player:SetWeapon("hand_use_controller")
        else
            hand:RemoveHandAttachmentByHandle(weapon)
            local use = hand:GetHandUseController()
            if use then
                hand:RemoveHandAttachmentByHandle(use)
                hand:AddHandAttachment(use)
            end
        end
    end
end

---
---Equips a weapon into a given hand.
---
---Uses the `OnHolsterEquip` hook if available, otherwise does it manually.
---
---@param weapon EntityHandle
---@param hand CPropVRHand
local function equipWeapon(weapon, hand)
    if type(weapon.OnHolsterEquip) == "function" then
        weapon:OnHolsterEquip(hand)
    else
        -- Do this manually because weapons don't need special attaching
        hand:RemoveHandAttachmentByHandle(weapon)
        hand:AddHandAttachment(weapon)
        if weapon:GetClassname() == "hlvr_multitool" then
            -- multitool will appear but won't function with hacking ui
            hand:AddHandAttachment(weapon)
        end
    end
end

---@diagnostic enable: undefined-field

---
---Enables rendering for an entity and all children
---except for entities that are normally invisible
---
---@param ent EntityHandle
local function enableAllRenderingForWeapon(ent)
    if not IsValidEntity(ent) then return end

    ent:SetRenderingEnabled(true)
    for child in ent:IterateChildren() do
        -- This is normally invisible, will create shadows
        if child:GetName() ~= "shotgun_tube_physics"
        and child:GetClassname() ~= "hlvr_weaponmodule_itemproxy"
        and child:GetName() ~= "rapidfire_mag_casing_physics"
        then
            child:SetRenderingEnabled(true)
        end
    end
end

return {
    getHandPosition = getHandPosition,
    cloneWeapon = cloneWeapon,
    isActualWeapon = isActualWeapon,
    getWeaponFromHand = getWeaponFromHand,
    unequipWeapon = unequipWeapon,
    equipWeapon = equipWeapon,
    enableAllRenderingForWeapon = enableAllRenderingForWeapon,
}