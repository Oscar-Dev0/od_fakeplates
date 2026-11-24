PlateClient = Class()
function PlateClient:init(core)
    self.core = core
    self.vehicle = Vehicle()
    self.cache = {}
    self.busy = false
end
function PlateClient:apply(vehicle, remove)
    if self.busy or not self.vehicle:valid(vehicle) then return end
    local plate = self.vehicle:plate(vehicle)
    local netId = VehToNet(vehicle)
    if netId == 0 then return end
    self.busy = true
    self.core.progress(Translate(remove and 'removing' or 'attaching'), function(ok)
        self.busy = false
        if ok and self.vehicle:valid(vehicle) and self.vehicle:plate(vehicle) == plate then
            TriggerServerEvent('od_fakeplates:server:change', netId, remove)
        end
    end)
end
function PlateClient:canRemove(vehicle)
    if not self.vehicle:valid(vehicle) then return false end
    local plate = self.vehicle:plate(vehicle)
    local cached = self.cache[plate]
    if not cached or GetGameTimer() - cached.time > 3000 then
        self.cache[plate] = { time = GetGameTimer(), value = cached and cached.value or false }
        TriggerServerEvent('od_fakeplates:server:status', plate)
    end
    return self.cache[plate].value
end
