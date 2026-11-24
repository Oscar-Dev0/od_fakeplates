assert(CoreClients[Config.Framework], 'Unsupported framework: ' .. tostring(Config.Framework))
assert(Targets[Config.Target], 'Unsupported target: ' .. tostring(Config.Target))
assert(Keys[Config.Keys], 'Unsupported keys bridge: ' .. tostring(Config.Keys))
local plates = PlateClient(CoreClients[Config.Framework]())
local function usePlate() plates:apply(plates.vehicle:closest(), false) end
local function removePlate() plates:apply(plates.vehicle:closest(), true) end
for _, prefix in ipairs({ 'od_fakeplates', 'brazzers-fakeplates' }) do
    RegisterNetEvent(prefix .. ':client:usePlate', usePlate)
    RegisterNetEvent(prefix .. ':client:removePlate', removePlate)
    RegisterNetEvent(prefix .. ':client:status', function(plate, value)
        plates.cache[plate] = { time = GetGameTimer(), value = value == true }
    end)
    RegisterNetEvent(prefix .. ':client:notify', function(message, kind) plates.core.notify(message, kind) end)
    RegisterNetEvent(prefix .. ':client:keys', function(plate) Keys[Config.Keys](plate) end)
end
CreateThread(function()
    Targets[Config.Target](function(entity) return plates:canRemove(entity) end,
        function(entity) plates:apply(entity, true) end)
end)
