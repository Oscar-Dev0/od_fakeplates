CoreClients = CoreClients or {}
CoreClients.qbx = function()
    return {
        notify = function(message, kind) exports.qbx_core:Notify(message, kind or 'error') end,
        progress = function(label, done)
            done(lib.progressBar({
                duration = Config.Duration, label = label, canCancel = true,
                disable = { move = true, car = true, combat = true },
                anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer', flag = 1 },
            }) == true)
        end,
    }
end
