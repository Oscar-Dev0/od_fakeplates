Vehicle = Class()
function Vehicle:closest()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, Config.MaxDistance, 0, 70)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
    return vehicle
end
function Vehicle:valid(vehicle)
    return vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)
        and #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle)) <= Config.MaxDistance
end
function Vehicle:plate(vehicle)
    return (GetVehicleNumberPlateText(vehicle):gsub('^%s*(.-)%s*$', '%1'))
end
