PlateRepository = Class()
local function identifier(value)
    assert(type(value) == 'string' and value:match('^[%w_]+$'), 'Invalid SQL identifier')
    return '`' .. value .. '`'
end
function PlateRepository:init(storage)
    self.tableName = storage.vehicles
    self.ownerName = storage.owner
    self.vehicles = identifier(storage.vehicles)
    self.owner = identifier(storage.owner)
    self.containers = {}
    for _, name in ipairs(Config.ContainerTables) do self.containers[#self.containers + 1] = identifier(name) end
end
function PlateRepository:ensureSchema()
    local function hasColumn(column)
        return MySQL.scalar.await([[
            SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? LIMIT 1
        ]], { self.tableName, column }) ~= nil
    end
    assert(hasColumn('plate'), ('Table %s is missing the plate column or does not exist'):format(self.tableName))
    assert(hasColumn(self.ownerName), ('Table %s is missing the %s column'):format(self.tableName, self.ownerName))
    if hasColumn('fakeplate') then return false end
    assert(Config.AutoCreateColumn, ('Table %s is missing fakeplate and automatic creation is disabled'):format(self.tableName))
    local ok, err = pcall(MySQL.query.await,
        ('ALTER TABLE %s ADD COLUMN `fakeplate` VARCHAR(8) NULL DEFAULT NULL'):format(self.vehicles))
    -- Another resource or operator might have created the column during the check.
    if not ok and not hasColumn('fakeplate') then error(err) end
    assert(hasColumn('fakeplate'), ('Could not create fakeplate in %s'):format(self.tableName))
    return ok
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
