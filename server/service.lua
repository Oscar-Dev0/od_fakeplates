PlateService = Class()
function PlateService:init(core, repository, inventory)
    self.core, self.repo, self.inventory, self.busy, self.reserved = core, repository, inventory, {}, {}
end
function PlateService:notify(src, message, kind)
    TriggerClientEvent('od_fakeplates:client:notify', src, message, kind or 'error')
end
function PlateService:generate()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    for _ = 1, 30 do
        local result = ''
        for _ = 1, 8 do local i = math.random(#chars); result = result .. chars:sub(i, i) end
        if not self.reserved[result] and self.repo:available(result) and not self.reserved[result] then
            self.reserved[result] = true
            return result
        end
    end
end
function PlateService:change(src, netId, removing)
    if type(netId) ~= 'number' or type(removing) ~= 'boolean' then return end
    local player = self.core.player(src)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local ped = GetPlayerPed(src)
    if not player or vehicle == 0 or ped == 0 or not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2 then return end
    if #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) > Config.MaxDistance + 1.0 then return end
    local current = GetVehicleNumberPlateText(vehicle):match('^%s*(.-)%s*$')
    if current == '' or self.busy[current] then return end
    self.busy[current] = true
    local ok, err = xpcall(function()
        local original = current
        if removing then original = self.repo:original(current) end
        if not original then self:notify(src, Translate('no_fake')); return end
        if not self.repo:owned(original, self.core.identifier(player)) then self:notify(src, Translate('not_owner')); return end
        if not removing and (self.repo:original(current) or self.repo:fake(current)) then
            self:notify(src, Translate('already_fake')); return
        end
        local newPlate = removing and original or self:generate()
        if not newPlate then self:notify(src, Translate('generation_failed')); return end
        if not removing and not self.inventory.remove(player, src) then self.reserved[newPlate] = nil; self:notify(src, Translate('need_item')); return end
        local queryOk, success = pcall(self.repo.set, self.repo, original, current, newPlate, removing)
        if not removing then self.reserved[newPlate] = nil end
        if not queryOk or not success then
            if not removing and not self.inventory.add(player, src) then print(('[od_fakeplates] Failed to refund item to %s'):format(src)) end
            self:notify(src, Translate('database_failed')); return
        end
        SetVehicleNumberPlateText(vehicle, newPlate)
        TriggerClientEvent('od_fakeplates:client:keys', src, newPlate)
        if removing and not self.inventory.add(player, src) then
            print(('[od_fakeplates] Could not return fake plate to %s'):format(src))
            self:notify(src, Translate('inventory_full'))
        else self:notify(src, Translate(removing and 'removed' or 'attached'), 'success') end
    end, debug.traceback)
    self.busy[current] = nil
    if not ok then print('[od_fakeplates] ' .. tostring(err)); self:notify(src, Translate('failed')) end
end
