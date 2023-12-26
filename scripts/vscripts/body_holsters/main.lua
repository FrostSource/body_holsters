require "core"

local HOLSTER_DISTANCE = 50
local GRAB_DISTANCE = 6
local HOLSTER_MIN_HEIGHT = 8
local HOLSTER_MAX_HEIGHT = 320

Convars:RegisterConvar("holsters_grab_distance", tostring(GRAB_DISTANCE), "", 0)
Convars:RegisterConvar("holsters_holster_distance", tostring(HOLSTER_DISTANCE), "Max distance from the player body a weapon can be holstered when released", 0)
Convars:RegisterConvar("holsters_holster_min_height", tostring(HOLSTER_MIN_HEIGHT), "Min height from player feet that a weapon can be holstered.", 0)
Convars:RegisterConvar("holsters_holster_max_height", tostring(HOLSTER_MAX_HEIGHT), "Max height from player feet that a weapon can be holstered.", 0)
Convars:RegisterConvar("holsters_visible_weapons", "1", "", 0)

Input:TrackButtons({ DIGITAL_INPUT_USE, DIGITAL_INPUT_USE_GRIP })

local holsterGrabButton = DIGITAL_INPUT_USE_GRIP

local cloneName = "__weapon_clone"

---Get holstered weapon clone based on the weapon class it represents.
---@param classname string
---@return HolsteredWeaponClone?
function GetHolsteredWeaponClone(classname)
    for _, clone in ipairs(Entities:FindAllByName(cloneName)) do
        if clone:GetClassname() == classname then
            return clone--[[@as HolsteredWeaponClone]]
        end
    end
end

local function getPlayerHolsterOrigin()
    local backpack = Player:GetBackpack()
    if backpack then
        return backpack:GetCenter()
    else
        return Player.HMDAvatar:GetAbsOrigin()
    end
end

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
        targetname = "__weapon_clone",
        rendermode = Convars:GetBool("holsters_visible_weapons") and "kRenderNormal" or "kRenderNone",
        vscripts = ""
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

local gunClasses = {
    "hlvr_weapon_energygun",
    "hlvr_weapon_rapidfire",
    "hlvr_weapon_shotgun",
    "hlvr_weapon_generic_pistol",
    "hlvr_multitool"
}

Input:RegisterCallback("release", 2, DIGITAL_INPUT_USE_GRIP, 1, function(params)
    print("RELEASE")
    local weapon = Player:GetWeapon()
    if weapon ~= nil then
        local origin = weapon:GetCenter()
        local holsterModelPos = getPlayerHolsterOrigin()
        -- print((playerPos - origin):Length2D()
        -- , (origin.z - playerPos.z)
        -- , (origin.z - playerPos.z)
        -- )
        if (holsterModelPos - origin):Length2D() <= Convars:GetFloat("holsters_holster_distance")
        and (origin.z - holsterModelPos.z) > Convars:GetFloat("holsters_holster_min_height")
        and (origin.z - holsterModelPos.z) < Convars:GetFloat("holsters_holster_max_height")
        then

            -- Destroy old clone if reholstering from a weapon switch
            local existingWeaponClone = GetHolsteredWeaponClone(weapon:GetClassname())
            if existingWeaponClone then
                existingWeaponClone:Kill()
            end

            -- Create new clone
            local weaponClone = cloneWeapon(weapon)
            weaponClone:SaveString("weaponClass", weapon:GetClassname())

            -- Player:RemoveWeapons(weapon)
            -- Player:UpdateWeapons({weapon}, nil)
            -- print("Finished removal!>")

            -- Remove weapon from hand
            Player:SetWeapon("hand_use_controller")
            -- Player:UpdateWeapons({weapon}, "hand_use_controller")

            local backpack = Player:GetBackpack()
            weaponClone:SetParent(backpack ~= nil and backpack or Player.HMDAvatar, "")



            -- weaponClone:FollowEntity(weapon, false)
            -- weapon:SetParent(Player, "")
            -- local zDiff = (weapon:GetAbsOrigin().z - Player.HMDAvatar:GetAbsOrigin().z)
            -- print(zDiff)

            -- weapon:SetContextThink("holsterThink", function()
            --     weapon:SetAbsOrigin(Vector(weapon:GetAbsOrigin().x, weapon:GetAbsOrigin().y, Player.HMDAvatar:GetAbsOrigin().z + zDiff))
            --     return 0
            -- end, 0)

            StartSoundEventFromPosition("body_holsters.holster", origin)

            devprints("Holstered", weapon:GetClassname())

        end
    end
end)

local inputPressCallback = function(params)
    print("PRESS")
    local weapon = Player:GetWeapon()
    -- print("weapon == nil", weapon)
    -- print("Player.PrimaryHand.ItemHeld == nil", Player.PrimaryHand.ItemHeld == nil)
    if weapon == nil and Player.PrimaryHand.ItemHeld == nil then
        local handOrigin = Player.PrimaryHand:GetAttachmentOrigin(Player.PrimaryHand:ScriptLookupAttachment("vr_hand_origin"))
        for _, clone in ipairs(Entities:FindAllByName(cloneName)) do
            local attachment = clone:ScriptLookupAttachment("vr_controller_root")
            -- print(VectorDistance(clone:GetAttachmentOrigin(attachment), handOrigin))
            if VectorDistance(clone:GetAttachmentOrigin(attachment), handOrigin) <= Convars:GetFloat("holsters_grab_distance") then
                local weaponClass = clone:LoadString("weaponClass")
                Player:SetWeapon(weaponClass)
                -- weapon = clone:GetMoveParent()
                -- weapon:SetParent(nil, "")
                clone:Kill()
                -- weapon:Grab(Player.PrimaryHand)
                -- weapon:SetContextThink("holsterThink", nil, 0)
                StartSoundEventFromPosition("body_holsters.unholster", handOrigin)
                devprints("Unholstering", weaponClass)
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

local debug = true
if debug then
    RegisterPlayerEventCallback("vr_player_ready", function (params)
        Player:SetContextThink("debugholster", function()
            local holsterDist = Convars:GetFloat("holsters_holster_distance")
            local vec = Player:GetAbsOrigin() + Vector(-holsterDist, -holsterDist, Convars:GetFloat("holsters_holster_min_height"))
            local vec2 = Player:GetAbsOrigin() + Vector(holsterDist, holsterDist, Convars:GetFloat("holsters_holster_max_height"))
            debugoverlay:Box(vec, vec2, 0, 255, 0, 255, false, 0)

            local handOrigin = Player.PrimaryHand:GetAttachmentOrigin(Player.PrimaryHand:ScriptLookupAttachment("vr_hand_origin"))

            -- Hand position
            debugoverlay:Sphere(handOrigin, 0.5, 255,255,255,255,true,0)

            -- Weapon grab positions
            for _, clone in ipairs(Entities:FindAllByName("__weapon_clone")) do
                local attachment = clone:ScriptLookupAttachment("vr_controller_root")
                local r,g,b = 255,255,255
                if VectorDistance(clone:GetAttachmentOrigin(attachment), handOrigin) <= Convars:GetFloat("holsters_grab_distance") then
                    r,g,b = 0,255,0
                end
                debugoverlay:Sphere(clone:GetAttachmentOrigin(attachment), Convars:GetFloat("holsters_grab_distance"), r,g,b,255,false,0)
            end

            -- Assuming forwardVector is a 3D vector representing the forward direction
            local forwardVector = Player:GetWorldForward()
            local yaw = math.atan2(forwardVector.y, forwardVector.x) * (180 / math.pi)

            -- Adjust the range to be between 0 and 360 degrees
            yaw = yaw < 0 and yaw + 360 or yaw

            -- debugoverlay:YawArrow(handOrigin, yaw, 12, 4, 255,255,255,255,true,0)
            debugoverlay:VertArrow(handOrigin, handOrigin + forwardVector * 8, 2, 255,255,255,255,true,0)
            debugoverlay:HorzArrow(handOrigin, handOrigin + forwardVector * 8, 2, 215,215,215,255,true,0)

            debugoverlay:Sphere(Player:GetAbsOrigin(), 5, 255,0,255,255,true,0)


            return 0
        end, 0)
    end)
end

print("BODY HOLSTERS ACTIVE")