assert(CoreServers[Config.Framework], 'Unsupported framework: ' .. tostring(Config.Framework))
assert(Config.Storage[Config.Framework], 'Missing storage configuration')
assert(Inventories[Config.Inventory], 'Unsupported inventory: ' .. tostring(Config.Inventory))
assert(ServerKeys[Config.Keys], 'Unsupported keys bridge: ' .. tostring(Config.Keys))
MySQL.ready(function()
    local core = CoreServers[Config.Framework]()
    local repo = PlateRepository(Config.Storage[Config.Framework])
    local schemaOk, result = pcall(repo.ensureSchema, repo)
    if not schemaOk then
        print(('[od_fakeplates] Database initialization failed; resource functions are disabled: %s'):format(tostring(result)))
        return
    end
    if result then print('[od_fakeplates] Created the fakeplate column in the vehicle table.') end
    local service = PlateService(core, repo, Inventories[Config.Inventory], ServerKeys[Config.Keys])
    core.usable(function(src) TriggerClientEvent('od_fakeplates:client:usePlate', src) end)
    for _, prefix in ipairs({ 'od_fakeplates', 'brazzers-fakeplates' }) do
        RegisterNetEvent(prefix .. ':server:change', function(netId, removing)
            service:change(source, netId, removing)
        end)
        -- Legacy arguments (plate, new plate and hasKeys) are intentionally untrusted.
        RegisterNetEvent(prefix .. ':server:usePlate', function(netId)
            service:change(source, netId, false)
        end)
        RegisterNetEvent(prefix .. ':server:removePlate', function(netId)
            service:change(source, netId, true)
        end)
        RegisterNetEvent(prefix .. ':server:status', function(plate)
            local src = source
            if type(plate) ~= 'string' or #plate > 8 then return end
            TriggerClientEvent(prefix .. ':client:status', src, plate, repo:original(plate) ~= nil)
        end)
    end
    local legacyExports = {
        isFakePlateOnVehicle = function(plate) return repo:original(plate) ~= nil end,
        getPlateFromFakePlate = function(plate) return repo:original(plate) end,
        getFakePlateFromPlate = function(plate) return repo:fake(plate) end,
    }
    for name, fn in pairs(legacyExports) do
        exports(name, fn)
        -- Same export-compatibility mechanism used by the Qbox qb-core bridge.
        if GetCurrentResourceName() ~= 'brazzers-fakeplates' then
            AddEventHandler(('__cfx_export_brazzers-fakeplates_%s'):format(name), function(setCallback)
                setCallback(fn)
            end)
        end
    end
    -- Original QBCore callback API, available when qb-core or the Qbox QB bridge is enabled.
    if Config.Framework == 'qb' or Config.Framework == 'qbx' then
        local ok, qb = pcall(function() return exports['qb-core']:GetCoreObject() end)
        if ok and qb and qb.Functions and qb.Functions.CreateCallback then
            for _, prefix in ipairs({ 'od_fakeplates', 'brazzers-fakeplates' }) do
                qb.Functions.CreateCallback(prefix .. ':server:checkPlateStatus', function(_, cb, plate)
                    if type(plate) ~= 'string' or #plate > 8 then cb(false); return end
                    cb(repo:original(plate) ~= nil)
                end)
            end
        end
    end
end)
