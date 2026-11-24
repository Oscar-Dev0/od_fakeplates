CoreClients = CoreClients or {}
CoreClients.qb = function()
    local core = exports['qb-core']:GetCoreObject()
    return {
        notify = function(message, kind) core.Functions.Notify(message, kind or 'error') end,
        progress = function(label, done)
            core.Functions.Progressbar('fakeplate', label, Config.Duration, false, true,
                { disableMovement = true, disableCarMovement = true, disableCombat = true },
                { animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', anim = 'machinic_loop_mechandplayer', flags = 1 }, {}, {},
                function() done(true) end, function() done(false) end)
        end,
    }
end
