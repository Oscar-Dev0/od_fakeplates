-- Run with: lua tests/detection.lua
local states = {}
function GetResourceState(name) return states[name] and 'started' or 'missing' end
local function detect(framework, target, inventory, keys)
    Config = { Framework = 'auto', Target = 'auto', Inventory = 'auto', Keys = 'auto' }
    dofile('shared/detect.lua')
    assert(Config.Framework == framework and Config.Target == target and Config.Inventory == inventory and Config.Keys == keys)
end
states = { qbx_core = true, ['qb-core'] = true, ox_target = true, ['qb-target'] = true, ox_inventory = true }
detect('qbx', 'ox', 'ox', 'none')
states = { ['qb-core'] = true, ['qb-target'] = true, ['qb-vehiclekeys'] = true }
detect('qb', 'qb', 'qb', 'qb')
states = { es_extended = true, ox_target = true }
detect('esx', 'ox', 'esx', 'none')
print('Detection tests passed')
