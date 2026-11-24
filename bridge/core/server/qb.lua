CoreServers = CoreServers or {}
CoreServers.qb = function()
    local core = exports['qb-core']:GetCoreObject()
    return {
        player = function(src) return core.Functions.GetPlayer(src) end,
        identifier = function(p) return p.PlayerData.citizenid end,
        usable = function(callback) core.Functions.CreateUseableItem(Config.Item, callback) end,
    }
end
