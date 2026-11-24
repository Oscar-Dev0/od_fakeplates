CoreServers = CoreServers or {}
CoreServers.qbx = function()
    return {
        player = function(src) return exports.qbx_core:GetPlayer(src) end,
        identifier = function(p) return p.PlayerData.citizenid end,
        usable = function(callback) exports.qbx_core:CreateUseableItem(Config.Item, callback) end,
    }
end
