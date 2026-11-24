CoreClients = CoreClients or {}
CoreClients.esx = function()
    local core = exports['es_extended']:getSharedObject()
    return {
        notify = function(message) core.ShowNotification(message) end,
        progress = function(label, done)
            core.ShowNotification(label)
            local ped = PlayerPedId()
            local dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@'
            RequestAnimDict(dict)
            local deadline = GetGameTimer() + 3000
            while not HasAnimDictLoaded(dict) and GetGameTimer() < deadline do Wait(10) end
            if HasAnimDictLoaded(dict) then TaskPlayAnim(ped, dict, 'machinic_loop_mechandplayer', 8.0, -8.0, Config.Duration, 1, 0, false, false, false) end
            Wait(Config.Duration)
            ClearPedTasks(ped)
            done(not IsEntityDead(ped))
        end,
    }
end
