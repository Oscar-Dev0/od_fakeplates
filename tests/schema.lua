-- Run with: lua tests/schema.lua
dofile('shared/class.lua')
Config = { ContainerTables = {}, AutoCreateColumn = true }
local columns = { plate = true, citizenid = true }
local alters, fail = 0, false
MySQL = {
    scalar = { await = function(_, params) return columns[params[2]] and 1 or nil end },
    query = { await = function(query)
        assert(query:find('ALTER TABLE `player_vehicles`', 1, true))
        alters = alters + 1
        if fail then error('ALTER denied') end
        columns.fakeplate = true
    end },
}
dofile('server/repository.lua')
local repo = PlateRepository({ vehicles = 'player_vehicles', owner = 'citizenid' })
assert(repo:ensureSchema() == true and alters == 1 and columns.fakeplate)
assert(repo:ensureSchema() == false and alters == 1, 'subsequent start must not alter the table')
columns.fakeplate = nil
Config.AutoCreateColumn = false
assert(not pcall(function() repo:ensureSchema() end) and alters == 1, 'disabled automatic setup must not alter')
Config.AutoCreateColumn = true
fail = true
assert(not pcall(function() repo:ensureSchema() end) and alters == 2, 'SQL errors must stop setup')
columns.citizenid = nil
assert(not pcall(function() repo:ensureSchema() end) and alters == 2, 'missing owner column must stop setup')
assert(not pcall(function() PlateRepository({ vehicles = 'vehicles; DROP TABLE x', owner = 'citizenid' }) end))
print('Schema tests passed')
