--[[
    Slot definitions for Ritsukan's player body addon.

    https://steamcommunity.com/sharedfiles/filedetails/?id=3581426521
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
            rh_offset = Vector(0, 0, 0),
            rh_angles = QAngle(0, 0, 0), -- these will need to be rotated
            lh_offset = Vector(0, 0, 0),
            lh_angles = QAngle(0, 0, 0),
            radius = 7,
            leftside = true,
            attachHandle = false,
            attachment = "item_2_any",
        },
        {
            name = "right_hip",
            rh_offset = Vector(0, 0, 0),
            rh_angles = QAngle(0, 0, 0),
            lh_offset = Vector(0, 0, 0),
            lh_angles = QAngle(0, 0, 0),
            radius = 7,
            leftside = false,
            attachHandle = false,
            attachment = "item_3_any",
        },

        {
            name = "left_underarm",
            rh_offset = Vector(0, 0, 0),
            rh_angles = QAngle(0, 0, 0),
            radius = 5.5,
            leftside = true,
            attachHandle = true,
            attachment = "item_4_any",
        },
        {
            name = "right_underarm",
            rh_offset = Vector(0, 0, 0),
            rh_angles = QAngle(0, 0, 0),
            radius = 5.5,
            leftside = false,
            attachHandle = false,
            attachment = "item_5_any",
        },

        {
            name = "left_shoulder",
            rh_offset = Vector(0, 0, 0),
            rh_angles = QAngle(0, 0, 0),
            radius = 10,
            leftside = true,
            disableBackpack = true,
            attachHandle = false,
            attachment = "item_7_any",
        },
        {
            name = "right_shoulder",
            rh_offset = Vector(0, 0, 0),
            rh_angles = QAngle(0, 0, 0),
            radius = 10,
            leftside = false,
            disableBackpack = true,
            attachHandle = false,
            attachment = "item_8_any",
        },

        {
            name = "chest",
            rh_offset = Vector(0, 0, 0),
            rh_angles = QAngle(0, 0, 0),
            lh_offset = nil,
            lh_angles = QAngle(0, 0, 0),
            radius = 4.5,
            leftside = false,
            attachHandle = false,
            attachment = "item_6_any",
        },
    }
end