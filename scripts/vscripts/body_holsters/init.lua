-- This file was automatically generated by alyxlib.

-- alyxlib can only run on server
if IsServer() then
    -- Load alyxlib before using it, in case this mod loads before the alyxlib mod.
    require("alyxlib.init")

    -- execute code or load mod libraries here
    require("body_holsters.main")
    require("body_holsters.debug")
    require("body_holsters.debug_menu")
end
