Targets = Targets or {}
Targets.qb = function(canInteract, action)
    exports['qb-target']:AddTargetBone({ 'boot' }, { options = {{
        icon = 'fas fa-closed-captioning', label = Translate('remove_target'),
        canInteract = canInteract, action = action,
    }}, distance = 2.5 })
end
