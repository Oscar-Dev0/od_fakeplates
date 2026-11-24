local function running(name)
    local state = GetResourceState(name)
    return state == 'started' or state == 'starting'
end
local function first(candidates)
    for _, candidate in ipairs(candidates) do
        if running(candidate[2]) then return candidate[1] end
    end
end
if Config.Framework == 'auto' then
    Config.Framework = first({ { 'qbx', 'qbx_core' }, { 'esx', 'es_extended' }, { 'qb', 'qb-core' } })
end
assert(Config.Framework, '[od_fakeplates] No framework found. Start qbx_core, es_extended or qb-core first, or configure it explicitly.')
if Config.Target == 'auto' then
    Config.Target = first({ { 'ox', 'ox_target' }, { 'qb', 'qb-target' } })
end
assert(Config.Target, '[od_fakeplates] No target found. Start ox_target or qb-target first, or configure it explicitly.')
if Config.Inventory == 'auto' then
    if running('ox_inventory') then Config.Inventory = 'ox'
    elseif Config.Framework == 'esx' then Config.Inventory = 'esx'
    else Config.Inventory = 'qb' end
end
if Config.Keys == 'auto' then Config.Keys = running('qb-vehiclekeys') and 'qb' or 'none' end
