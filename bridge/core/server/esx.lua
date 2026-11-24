CoreServers = CoreServers or {}
CoreServers.esx = function()
    local core = exports['es_extended']:getSharedObject()
    return {
        player = function(src) return core.GetPlayerFromId(src) end,
        identifier = function(p) return p.getIdentifier() end,
        usable = function(callback) core.RegisterUsableItem(Config.Item, callback) end,
    }
end
