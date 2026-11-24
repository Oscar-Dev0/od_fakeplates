-- Run with: lua tests/compat.lua
local events, handlers, exposed, callbacks, actions = {}, {}, {}, {}, {}
Config = { Framework = 'qb', Inventory = 'qb', Keys = 'qb', Storage = { qb = {} } }
CoreServers = { qb = function() return { usable = function() end } end }
Inventories = { qb = {} }
ServerKeys = { qb = function() end }
MySQL = { ready = function(fn) fn() end }
PlateRepository = function() return { ensureSchema = function() return false end, original = function(_, plate) if plate == 'FAKE' then return 'REAL' end end, fake = function() return 'FAKE' end } end
PlateService = function() return { change = function(_, src, id, removing) actions[#actions + 1] = { src, id, removing } end } end
function GetCurrentResourceName() return 'od_fakeplates' end
function RegisterNetEvent(name, fn) events[name] = fn end
function AddEventHandler(name, fn) handlers[name] = fn end
function TriggerClientEvent() end
local qb = { Functions = { CreateCallback = function(name, fn) callbacks[name] = fn end } }
exports = setmetatable({ ['qb-core'] = { GetCoreObject = function() return qb end } }, { __call = function(_, name, fn) exposed[name] = fn end })
source = 17
dofile('server/main.lua')
events['brazzers-fakeplates:server:usePlate'](42, 'UNTRUSTED', 'UNTRUSTED', true)
assert(actions[1][1] == 17 and actions[1][2] == 42 and actions[1][3] == false)
events['brazzers-fakeplates:server:removePlate'](42, 'UNTRUSTED', true)
assert(actions[2][3] == true)
events['od_fakeplates:server:change'](42, false)
assert(actions[3][2] == 42 and actions[3][3] == false)
local alias
handlers['__cfx_export_brazzers-fakeplates_getPlateFromFakePlate'](function(fn) alias = fn end)
assert(alias('FAKE') == 'REAL' and exposed.getPlateFromFakePlate('FAKE') == 'REAL')
local status
callbacks['brazzers-fakeplates:server:checkPlateStatus'](17, function(value) status = value end, 'FAKE')
assert(status == true)
print('Compatibility tests passed')
