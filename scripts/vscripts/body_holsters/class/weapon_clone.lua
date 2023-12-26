---@class HolsteredWeaponClone : EntityClass
local base = entity("WeaponClone")

---Called automatically on spawn
---@param spawnkeys CScriptKeyValues
function base:OnSpawn(spawnkeys)
end

---Called automatically on activate.
---Any self values set here are automatically saved
---@param loaded boolean
function base:OnReady(loaded)
    -- self:ResumeThink()
end

---Main entity think function. Think state is saved between loads
function base:Think()
    -- local origin = self:GetAbsOrigin()
    -- self:SetAbsOrigin(origin.x, origin.y, max(Player:GetAbsOrigin().z, ))
    return 0
end

--Used for classes not attached directly to entities
return base