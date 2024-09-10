
Convars:RegisterCommand("body_holsters_holster_current_weapon", function (_, slotName)
    local weapon = Player:GetWeapon()
    if not weapon then
        warn("Cannot holster, player does not have a weapon equipped\n")
        return
    end

    if slotName then
        local slot = BodyHolsters:GetSlot(slotName)
        if not slot then
            warn("Slot "..slotName.." does not exist! Use body_holsters_slot to list names.")
            return
        end

        if BodyHolsters:CanStoreInSlot(slot, weapon) then
            BodyHolsters:HolsterWeapon(slot, weapon)
            -- -- Remove weapon from hand
            -- Player:SetWeapon("hand_use_controller")
            Msg(weapon:GetClassname() .. " stored in " .. slot.name .. "\n")
            return
        else
            warn("Could not store weapon in slot "..slotName.."!")
            return
        end
    else

        for _, slot in ipairs(BodyHolsters.slots) do
            if BodyHolsters:CanStoreInSlot(slot, weapon) then
                BodyHolsters:HolsterWeapon(slot, weapon)
                -- -- Remove weapon from hand
                -- Player:SetWeapon("hand_use_controller")
                Msg(weapon:GetClassname() .. " stored in " .. slot.name .. "\n")
                return
            end
        end
    end

    warn("Cannot store weapon in any slot either because there is no free slot or the weapon is invalid!\n")
end, "", 0)

Convars:RegisterCommand("body_holsters_remove_weapon_from_hand", function (_)
    local weapon = Player:GetWeapon()
    if not weapon then
        warn("Cannot remove weapon, player does not have a weapon equipped\n")
        return
    end

    Player:SetWeapon("hand_use_controller")
end, "", 0)

Convars:RegisterCommand("body_holsters_test_respirator", function (_)
    local resp1 = Entities:FindByModel(nil, "models/props/hazmat/respirator_01a.vmdl")
    local resp2 = Entities:FindByModel(nil, "models/props/hazmat/respirator_01b.vmdl")
    if not resp1 and not resp2 then
        warn("No respirator model exists in the map, cannot spawn!")
        return
    end

    local respModel = resp1 and "models/props/hazmat/respirator_01a.vmdl" or "models/props/hazmat/respirator_01b.vmdl"

    local trace = TraceLineSimple(Player:EyePosition(), Player:EyePosition() + Player:EyeAngles():Forward() * 32, Player)
    SpawnEntityFromTableSynchronous("prop_physics", {
        model = respModel,
        targetname = "body_holsters_debug_respirator",
        -- origin = Player:EyePosition() + Player:EyeAngles():Forward() * 32,
        origin = trace.pos
    })
end, "", 0)