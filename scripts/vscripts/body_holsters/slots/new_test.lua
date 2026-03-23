--[[
    Default slots.
]]

---@return BodyHolstersSlot[]
return function()
    ---@type BodyHolstersSlot[]
    return {
        -- +x = forward
        -- -x = backward
        -- +y = right
        -- -y = left
        {
            name = "left_hip",
            rh_offset = Vector(-2, 6, -21),
            rh_angles = QAngle(55, 135, 0),
            lh_offset = Vector(-4, 10, -25),
            lh_angles = QAngle(90, 0, 0),
            radius = 7,
            leftside = true,
            attachHandle = true,
        },
        {
            name = "right_hip",
            rh_offset = Vector(-4, -10, -25),
            rh_angles = QAngle(90, 0, 0),
            lh_offset = Vector(-2, -6, -21),
            lh_angles = QAngle(55, 225, 0),
            radius = 7,
            leftside = false,
            attachHandle = true,
        },

        {
            name = "left_underarm",
            rh_offset = Vector(-1.5, 8, -12),
            rh_angles = QAngle(35, 180, 0),
            radius = 5.5,
            leftside = true,
            attachHandle = true,
        },
        {
            name = "right_underarm",
            rh_offset = Vector(-1.5, -8, -12),
            rh_angles = QAngle(35, 180, 0),
            radius = 5.5,
            leftside = false,
            attachHandle = true,
        },

        {
            name = "left_shoulder",
            rh_offset = Vector(-8.2, 5, -2),
            rh_angles = QAngle(90, 90, 0),
            radius = 10,
            leftside = true,
            disableBackpack = true,
            attachHandle = true,
        },
        {
            name = "right_shoulder",
            rh_offset = Vector(-8.2, -5, -2),
            rh_angles = QAngle(90, -90, 0),
            radius = 10,
            leftside = false,
            disableBackpack = true,
            attachHandle = true,
        },

        {
            name = "chest",
            rh_offset = Vector(1.5, 0, -12),
            rh_angles = QAngle(35, 90, 0),
            lh_offset = nil,
            lh_angles = QAngle(35, -90, 0),
            radius = 4.5,
            leftside = false,
            attachHandle = false,
        },
    }
end