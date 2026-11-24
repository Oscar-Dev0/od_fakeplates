Inventories = Inventories or {}
Inventories.esx = {
    remove = function(player)
        local item = player.getInventoryItem(Config.Item)
        if not item or item.count < 1 then return false end
        player.removeInventoryItem(Config.Item, 1)
        return true
    end,
    add = function(player)
        if player.canCarryItem and not player.canCarryItem(Config.Item, 1) then return false end
        player.addInventoryItem(Config.Item, 1)
        return true
    end,
}
