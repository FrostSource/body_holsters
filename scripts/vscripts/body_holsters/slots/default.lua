--[[
    Default slots.
]]

local function leftHanded(a, b)
    return Convars:GetBool("hlvr_left_hand_primary") and a or b
end

return function()
    return {
        -- +x = forward
        -- -x = backward
        -- +y = right
        -- -y = left
        {
            name = "left_hip",
            offset = leftHanded(Vector(-4, 10, -25), Vector(-2, 6, -21)),
            angles = leftHanded(QAngle(90, 0, 0), QAngle(55, 135, 0)),
            radius = 7,
            storedWeapon = nil,
            leftside = true,
            attachHandle = true,
            flipangles = false,
        },
        {
            name = "right_hip",
            offset = leftHanded(Vector(-2, -6, -21), Vector(-4, -10, -25)),
            angles = leftHanded(QAngle(55, 225, 0), QAngle(90, 0, 0)),
            radius = 7,
            leftside = false,
            attachHandle = true,
            flipangles = false,
        },

        {
            name = "left_underarm",
            offset = Vector(-1.5, 8, -12),
            angles = QAngle(35, 180, 0),
            radius = 5.5,
            leftside = true,
            attachHandle = true,
            flipangles = false,
        },
        {
            name = "right_underarm",
            offset = Vector(-1.5, -8, -12),
            angles = QAngle(35, 180, 0),
            radius = 5.5,
            leftside = false,
            attachHandle = true,
            flipangles = false,
        },

        {
            name = "left_shoulder",
            offset = Vector(-8.2, 5, -2),
            angles = QAngle(90, 90, 0),
            radius = 10,
            leftside = true,
            disableBackpack = true,
            attachHandle = true,
            flipangles = false,
        },
        {
            name = "right_shoulder",
            offset = Vector(-8.2, -5, -2),
            angles = QAngle(90, -90, 0),
            radius = 10,
            leftside = false,
            disableBackpack = true,
            attachHandle = true,
            flipangles = false,
        },

        {
            name = "chest",
            offset = Vector(1.5, 0, -12),
            angles = leftHanded(QAngle(35, -90, 0), QAngle(35, 90, 0)),
            radius = 4.5,
            leftside = false,
            attachHandle = false,
            flipangles = true,
        },
    }
end