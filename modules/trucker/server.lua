local pgroup = exports['snappy-phone']

local spawnedTrailers = {}

local function sendNotify(src, msg, type)
	if type == nil then type = 'inform' end
	TriggerClientEvent("bs-trucker:notify", src, msg, type)
end

local function IsVehicleNearPoint(x, y, z, radius)
    local coords = vector3(x, y, z)
    local vehicles = GetAllVehicles()
    local closeVeh = {}
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)
        if distance <= radius then
            closeVeh[#closeVeh + 1] = vehicles[i]
        end
    end
    if #closeVeh > 0 then return true end
    return false
end

local function getSpawnPoint(locations)
	for _, v in pairs(locations) do
		if not IsVehicleNearPoint(v.x, v.y, v.z, 3) then
			return true, v
		end
	end
	return false, nil
end

local function getDestination(location)
    local locations = Config.Trucker.deliveryLocations[location]
	local data = locations[math.random(1, #locations)]
	return data
end

lib.callback.register('trucker:removeTrailer', function(source, netId)
    local cid = GetPlayer(source)?.citizenid
    local partyId = pgroup:getPlayerPartyId(cid)
    if not partyId then return end
    local partySize = pgroup:getPartySize(partyId)
    local multiplier = 1
    if partySize > 1 then  multiplier = 1.1 end
    if spawnedTrailers[partyId] and spawnedTrailers[partyId].netId == netId then
        local price = (spawnedTrailers[partyId].payment * multiplier)
        local trailer = NetworkGetEntityFromNetworkId(netId)
        SetTimeout(5000, function()
            DeleteEntity(trailer)
        end)
        spawnedTrailers[partyId] = nil
        updatePartyTasks(cid, 4, 'done')
        updatePartyTasks(cid, 5, 'current')
        local gainLegalXP = math.random(Config.Trucker.addXP[1], Config.Trucker.addXP[2])
        sendToPartyMembers(partyId, function(playerId)
            local player = GetPlayer(source)
            if player then player.addMoney(price) end
            TriggerClientEvent('trucker:resetTrailer', playerId)
            AddXP(playerId, gainLegalXP)
            lib.logger(playerId, 'submitTrailer', string.format('%s earned $%d, party: %s', cid, price, tostring(partyId)))
        end)
        pgroup:sendPartyNotification(partyId, {
            title = Config.Party.jobName,
            description = 'Return to john to request more trailers else return the vehicle.',
            icon = 'truck',
            duration = 10000
        })
        return true
    end
    sendNotify(source, 'Not valid trailer', 'error')
    return false
end)

RegisterNetEvent('trucker:hasAttachedTrailer', function()
    local source = source
    local cid = GetPlayer(source)?.citizenid
    if not cid then return end
    updatePartyTasks(cid, 3, 'done')
    updatePartyTasks(cid, 4, 'current')
end)

RegisterNetEvent('trucker:requestTrailer', function(location, src)
    local source = src or source
    local cid = GetPlayer(source)?.citizenid
    local partyId = pgroup:getPlayerPartyId(cid)
    if not partyId then return end
    if getPlayerLimit(cid) >= Config.Party.maxPlayerLimit then
        pgroup:sendPartyNotification(partyId, {
            title = Config.Party.jobName,
            description = 'No more trailers available to deliver please return to postop.',
            icon = 'trailer',
            duration = 15000
        })
        return
    end
    if spawnedTrailers[partyId] then sendNotify(source, 'Trailer has already been requested') return end
    local isclear, coords = getSpawnPoint(Config.Trucker.trailerLocations[location])
    if isclear and coords then
        local model = Config.Trucker.trailers[math.random(1, #Config.Trucker.trailers)]
        local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
        SetEntityHeading(veh, coords.w or 0.0)
        while not DoesEntityExist(veh) do Wait(0) end
        local destination = getDestination(location)
        local distance = #(vector3(coords.x, coords.y, coords.z)-vector3(destination.coords.x, destination.coords.y, destination.coords.z))
        local travelPayment = Config.Trucker.travelPayment[location]
        local payment = Transform(distance, 0, travelPayment.maxDistance, travelPayment.minPayment, travelPayment.maxPayment)
        spawnedTrailers[partyId] = { netId = NetworkGetNetworkIdFromEntity(veh), payment = payment }
        updatePartyTasks(cid, 2, 'done')
        updatePartyTasks(cid, 3, 'current')
        updatePartyTasks(cid, 4, 'pending')
        updatePartyTasks(cid, 5, 'pending')
        sendToPartyMembers(partyId, function(playerId)
            local pcid = GetPlayer(playerId)?.citizenid
            addPlayerLimit(pcid)
            TriggerClientEvent('trucker:initiateTrailerWork', playerId, NetworkGetNetworkIdFromEntity(veh), coords, destination)
        end)
    end
end)

RegisterNetEvent('trucker:resetTrailer', function(location, cancelPrice)
    local source = source
    local player = GetPlayer(source)
    local cid = player?.citizenid
    local partyId = pgroup:getPlayerPartyId(cid)
    if spawnedTrailers[partyId] then
        local hasremoved = player.removeMoney(cancelPrice, 'Reallotment of trailer')
        if hasremoved then
            local trailer = NetworkGetEntityFromNetworkId(spawnedTrailers[partyId].netId)
            if DoesEntityExist(trailer) then DeleteEntity(trailer) end
            spawnedTrailers[partyId] = nil
            updatePartyTasks(cid, 2, 'done')
            updatePartyTasks(cid, 3, 'done')
            updatePartyTasks(cid, 4, 'done')
            updatePartyTasks(cid, 5, 'current')
            local loseLegalXP = math.random(Config.Trucker.removeXP[1], Config.Trucker.removeXP[2])
            sendToPartyMembers(partyId, function(playerId)
                TriggerClientEvent('trucker:resetTrailer', playerId)
                RemoveXP(playerId, loseLegalXP)
            end)
            pgroup:sendPartyNotification(partyId, {
                title = Config.Party.jobName,
                description = 'You were charged to request for a new trailer.',
                icon = 'trailer',
                duration = 10000
            })
            lib.logger(source, 'resetTrailer', string.format('%s has requested for new trailer which costed them $%d, party: %s', cid, cancelPrice, tostring(partyId)))
            TriggerEvent('trucker:requestTrailer', location, source)
        end
    else
        sendNotify(source, 'You have not requested for a trailer', 'error')
    end
end)