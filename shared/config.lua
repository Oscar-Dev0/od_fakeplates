Config = {}
-- Select the integrations installed on your server.
Config.Framework = 'auto' -- auto, qb, esx, qbx
Config.Target = 'auto' -- auto, qb, ox
Config.Inventory = 'auto' -- auto, qb, esx, ox
Config.Keys = 'auto' -- auto, qbx, qb, none
Config.Locale = 'en' -- en, es
Config.Item = 'fakeplate'
Config.Duration = 4000
Config.MaxDistance = 5.0
Config.AutoCreateColumn = true -- Create the fakeplate column when it is missing.
-- DB identifiers are trusted administrator configuration, never client input.
Config.Storage = {
    qb = { vehicles = 'player_vehicles', owner = 'citizenid' },
    qbx = { vehicles = 'player_vehicles', owner = 'citizenid' },
    esx = { vehicles = 'owned_vehicles', owner = 'owner' },
}
-- Enable only when your inventory actually uses these legacy tables.
Config.ContainerTables = {} -- e.g. { 'trunkitems', 'gloveboxitems' }
