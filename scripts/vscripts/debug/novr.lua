

local useClasses = {
    func_physical_button = { output = "OnIn" }
}

local useRadius = Convars:GetInt("player_use_radius") or 80

Convars:RegisterCommand("debug_novr_use", function (_, ...)
    print("NoVR use")
    local bestEnt, bestData = nil, nil
    local bestDot = -1
    local origin = Player:EyePosition()
    local forward = Player:EyeAngles():Forward()
    for class, data in pairs(useClasses) do
        for _, ent in ipairs(Entities:FindAllByClassnameWithin(class, origin, useRadius)) do
            local dot = forward:Dot((ent:GetOrigin() - origin):Normalized())
            if dot > 0.8 and dot > bestDot then
                bestDot = dot
                bestEnt = ent
                bestData = data
            end
            debugoverlay:Text(ent:GetOrigin(), 0, ent:GetClassname() .. " : " .. tostring(dot), 0, 255, 0, 0, 255, 5)
            -- print(ent:GetClassname() .. " : " .. tostring(dot))
        end
    end

    if bestEnt and bestData then
        print("selected", bestEnt:GetClassname(), bestEnt:GetName())
        if bestData.input then
            print("Doing input", bestData.input)
            DoEntFireByInstanceHandle(bestEnt, bestData.input, "", 0, Player, Player)
        else
            print("Doing output", bestData.output)
            -- SendToConsole("ent_fire " .. bestEnt:GetName() .. " runscriptcode \"thisEntity:FireOutput("..bestData.output)")
            bestEnt:FireOutput(bestData.output, nil, nil, nil, 0)
        end
    end
end, "", 0)
SendToServerConsole("bind q debug_novr_use")