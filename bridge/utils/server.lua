function AddKeys(source, vehNet, plate)
    if GetResourceState('MrNewbVehicleKeys') == 'started' then
        exports.MrNewbVehicleKeys:GiveKeys(source, vehNet)
    elseif GetResourceState('Renewed-Vehiclekeys') == 'started' then
        exports['Renewed-Vehiclekeys']:addKey(source, plate)
    elseif GetResourceState('vehicles_keys') == 'started' then
        exports["vehicles_keys"]:giveVehicleKeysToPlayerId(source, plate, 'temporary')
    else
        TriggerClientEvent('vehiclekeys:client:SetOwner', source, plate)
    end
end

function AddXP(source, amount)
    -- add your xp exports/events here
end

function RemoveXP(source, amount)
    -- add your xp exports/events here
end

function RoundVal(value, places)
    if type(value) == 'string' then value = tonumber(value) end
    if type(value) ~= 'number' then error('Value must be a number') end

    if places then
        if type(places) == 'string' then places = tonumber(places) end
        if type(places) ~= 'number' then error('Places must be a number') end

        if places > 0 then
            local mult = 10 ^ (places or 0)
            return math.floor(value * mult + 0.5) / mult
        end
    end

    return math.floor(value + 0.5)
end

function Transform(val, min, max, newMin, newMax)
	return (val - min) / (max - min) * (newMax - newMin) + newMin
end