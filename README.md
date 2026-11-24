# od_fakeplates

A modular adaptation of Brazzers Fake Plates. Keep the original license and attribution when distributing.

A modular FiveM resource for applying and removing persistent fake plates on player-owned vehicles. QBCore, ESX Legacy or Qbox and qb-target or ox_target are detected automatically at startup, or can be selected in `shared/config.lua`. The client modules contain vehicle handling and interactions; `bridge/` contains framework, target, inventory and keys adapters; the server contains the repository and plate service.

## Installation

1. Install and start oxmysql, ox_lib, your selected framework, inventory and target before this resource. Qbox also requires ox_inventory. QBCore's progress bar needs its configured `progressbar` resource.
2. Leave `Config.Framework`, `Config.Target`, `Config.Inventory` and `Config.Keys` set to `auto`, or choose them explicitly in `shared/config.lua` if several alternatives run on your server. Set `Config.Locale` to `en` or `es`. Use `qb` inventory for qb-inventory, `esx` for ESX inventory, or `ox` for ox_inventory (Qbox). `qb` keys uses the qb-vehiclekeys `vehiclekeys:client:SetOwner` event. Set keys to `none` if unavailable; implement a new bridge for another keys resource. Qbox installations may use their compatibility bridge if installed.
3. Add the `fakeplate` usable item to the active inventory. QBCore examples are in `README/ITEMS.txt`. ESX uses its configured item definition; for Qbox add `['fakeplate'] = { label = 'Fake Plate', weight = 100, stack = true, close = true }` to ox_inventory's `data/items.lua`.
4. Add the nullable `fakeplate` column to the selected vehicle table, if it does not already exist:

```sql
-- QBCore / Qbox
ALTER TABLE player_vehicles ADD COLUMN fakeplate VARCHAR(8) NULL DEFAULT NULL;
-- ESX Legacy (run this instead on ESX)
ALTER TABLE owned_vehicles ADD COLUMN fakeplate VARCHAR(8) NULL DEFAULT NULL;
```

Back up your database first. Do not run an ALTER for a column that already exists. Vehicle plate and owner columns must match `Config.Storage`. `plate` values must uniquely identify vehicles. For collision protection across other scripts, clean up duplicate fake plates and add a unique index on `fakeplate`; standard MySQL permits multiple NULL values.
5. Name the resource folder `od_fakeplates` and use `ensure od_fakeplates` in server.cfg. Remove the original Brazzers resource from the server; do not run both copies. OneSync is required for server-side network entity and distance validation. Test on a staging server before deployment.

## Detection and compatibility

Auto detection checks resources that are already started or starting: Qbox takes priority over ESX and QBCore; ox_target over qb-target; ox_inventory over the framework inventory; qb-vehiclekeys is used when started, otherwise the keys adapter is `none`. Configure an explicit choice when you run multiple alternatives. Start dependencies first; restart this resource after changing them.

`provide 'brazzers-fakeplates'` declares a replacement resource, and an explicit export bridge supports calls to `exports['brazzers-fakeplates']` for the three original server exports. They are also available as `exports.od_fakeplates`. The original `brazzers-fakeplates:client:usePlate`, `:client:removePlate`, `:server:usePlate` and `:server:removePlate` events remain registered, alongside their `od_fakeplates` equivalents. The server ignores the old client-supplied plate and keys arguments, generates its own plate, and applies its authorization checks. The old `:server:checkPlateStatus` QBCore callback remains available on QB, and on Qbox when its QB bridge is enabled. These shims are covered by local mocks but require an in-server integration test.

## Behavior

The server generates plates, checks the entity and distance, verifies the registered owner by citizen ID (QB/Qbox) or identifier (ESX), and consumes the item before persisting. This intentionally restricts the old script: borrowed, NPC and other unregistered vehicles cannot be changed. Status is cached per plate, rather than shared across nearby vehicles. Removal returns an item when inventory accepts it. If inventory or SQL fails, check the server log; item inventory and SQL are separate systems and cannot be committed atomically.

Inventory storage and key resources differ between servers. `Config.ContainerTables` is empty by default: configure the legacy `trunkitems`/`gloveboxitems` tables only if your inventory actually has these tables and plate columns. Other stash formats require a custom migration bridge. The qb keys adapter grants the new key to the actor, but does not revoke old keys or update other players; integrate your keys resource if those features are required. Existing garage, impound, insurance and vehicle-spawn scripts must use the fake plate field when restoring a vehicle; this resource does not patch them. The old server exports `isFakePlateOnVehicle`, `getPlateFromFakePlate` and `getFakePlateFromPlate` remain available.

FiveM, framework, inventory, garage and keys combinations must be tested on the actual server: Lua tests with mocks cannot validate network synchronization or external resources. Qbox uses the cancellable ox_lib progress bar, QB uses its configured progress bar, and ESX uses a timed animation.

## Local checks

Run `lua tests/service.lua`, `lua tests/detection.lua`, and `lua tests/compat.lua` from the resource root and use `luac -p` on each Lua file. The tests exercise server-side ownership, item handling and persistence failures with mocks.
