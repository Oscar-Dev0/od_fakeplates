Targets = Targets or {}
Targets.ox = function(canInteract, action)
    exports.ox_target:addGlobalVehicle({{
        name = 'od_fakeplates_remove', icon = 'fas fa-closed-captioning',
        label = Translate('remove_target'), bones = { 'boot' }, distance = 2.5,
        canInteract = canInteract, onSelect = function(data) action(data.entity) end,
    }})
end
