-- Run with: lua tests/service.lua
dofile('shared/class.lua')
Config = { MaxDistance = 5 }
function Translate(key) return key end
local vec = setmetatable({}, { __sub = function() return '' end })
function GetEntityCoords() return vec end
function NetworkGetEntityFromNetworkId() return 1 end
function GetPlayerPed() return 2 end
function DoesEntityExist() return true end
function GetEntityType() return 2 end
local current = 'ORIGINAL'
function GetVehicleNumberPlateText() return current end
function SetVehicleNumberPlateText(_, plate) current = plate end
function TriggerClientEvent() end
local inventory, owns, fail, fake = 1, true, false, nil
local core = {
    player = function() return {} end, identifier = function() return 'owner' end,
}
local items = {
    remove = function() if inventory == 0 then return false end inventory = inventory - 1 return true end,
    add = function() inventory = inventory + 1 return true end,
}
local repo = {
    original = function(_, plate) if plate == fake then return 'ORIGINAL' end end,
    fake = function() return fake end,
    owned = function() return owns end,
    available = function() return true end,
    set = function(_, _, _, to, removing)
        if fail then error('database failure') end
        if removing then fake = nil else fake = to end
        return true
    end,
}
dofile('server/service.lua')
local service = PlateService(core, repo, items)
service:change(1, 1, true)
assert(inventory == 1 and current == 'ORIGINAL' and fake == nil, 'removing an ordinary plate must do nothing')
owns = false
service:change(1, 1, false)
assert(inventory == 1 and current == 'ORIGINAL', 'non-owner must be rejected')
owns = true
fail = true
service:change(1, 1, false)
assert(inventory == 1 and current == 'ORIGINAL', 'database error must refund item')
fail = false
service:change(1, 1, false)
assert(inventory == 0 and fake == current and current ~= 'ORIGINAL', 'apply must persist and consume item')
service:change(1, 1, true)
assert(inventory == 1 and current == 'ORIGINAL' and fake == nil, 'removal must restore plate and item')
inventory = 0
service:change(1, 1, false)
assert(current == 'ORIGINAL' and fake == nil, 'missing item must prevent update')
print('Plate service tests passed')

