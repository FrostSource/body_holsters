-- Don't use frameworkinit if Scalable Init Support is enabled
if Convars:GetStr("default_enabled_addons_list"):find("2182586257") then
    return
end

if IsServer() then
    local success, result = pcall(require, "core")
    if not success then
        Warning("core.lua failed to initialized\n")
        Warning(tostring(result).."\n")
    end

    require "body_holsters.main"
end