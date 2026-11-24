Inventories = Inventories or {}
Inventories.qb = {
    remove = function(player) return player.Functions.RemoveItem(Config.Item, 1) end,
    add = function(player) return player.Functions.AddItem(Config.Item, 1) end,
}
