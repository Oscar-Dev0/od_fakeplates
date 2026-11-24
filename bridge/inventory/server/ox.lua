Inventories = Inventories or {}
Inventories.ox = {
    remove = function(_, src) return exports.ox_inventory:RemoveItem(src, Config.Item, 1) end,
    add = function(_, src) return exports.ox_inventory:AddItem(src, Config.Item, 1) end,
}
