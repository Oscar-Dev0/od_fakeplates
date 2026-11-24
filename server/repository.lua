PlateRepository = Class()
local function identifier(value)
    assert(type(value) == 'string' and value:match('^[%w_]+$'), 'Invalid SQL identifier')
    return '`' .. value .. '`'
end
function PlateRepository:init(storage)
    self.vehicles = identifier(storage.vehicles)
    self.owner = identifier(storage.owner)
    self.containers = {}
    for _, name in ipairs(Config.ContainerTables) do self.containers[#self.containers + 1] = identifier(name) end
end
function PlateRepository:original(fake)
    return MySQL.scalar.await(('SELECT plate FROM %s WHERE fakeplate = ? LIMIT 1'):format(self.vehicles), { fake })
end
function PlateRepository:fake(plate)
    return MySQL.scalar.await(('SELECT fakeplate FROM %s WHERE plate = ? LIMIT 1'):format(self.vehicles), { plate })
end
function PlateRepository:owned(plate, owner)
    return MySQL.scalar.await(('SELECT plate FROM %s WHERE plate = ? AND %s = ? LIMIT 1'):format(self.vehicles, self.owner), { plate, owner }) ~= nil
end
function PlateRepository:available(plate)
    return MySQL.scalar.await(('SELECT plate FROM %s WHERE plate = ? OR fakeplate = ? LIMIT 1'):format(self.vehicles), { plate, plate }) == nil
end
function PlateRepository:set(original, from, to, removing)
    local queries = {{ query = ('UPDATE %s SET fakeplate = %s WHERE plate = ?'):format(self.vehicles, removing and 'NULL' or '?'),
        values = removing and { original } or { to, original } }}
    for _, tableName in ipairs(self.containers) do
        queries[#queries + 1] = { query = ('UPDATE %s SET plate = ? WHERE plate = ?'):format(tableName), values = { to, from } }
    end
    return MySQL.transaction.await(queries)
end
