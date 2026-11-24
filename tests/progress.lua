-- Run with: lua tests/progress.lua
Config = { Duration = 4000 }
local result, seen = true
lib = { progressBar = function(options) seen = options return result end }
exports = { qbx_core = { Notify = function() end } }
dofile('bridge/core/client/qbx.lua')
local core = CoreClients.qbx()
local completed
core.progress('Attaching plate', function(ok) completed = ok end)
assert(completed == true and seen.duration == 4000 and seen.canCancel == true)
result = false
core.progress('Attaching plate', function(ok) completed = ok end)
assert(completed == false, 'cancelled progress must not complete')
print('Qbox progress tests passed')
