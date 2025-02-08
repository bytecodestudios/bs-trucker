local pgroup = exports['snappy-phone']

local rentedVehicles = {}
local partyTasks = {}
local partyWork = {}
local playerLimit = {}

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

local function getSpawnPoint()
	for _, v in pairs(Config.Party.jobSpawns) do
		if not IsVehicleNearPoint(v.x, v.y, v.z, 3) then
			return true, v
		end
	end
	return false, nil
end

function updatePartyTasks(cid, id, status)
	local partyId = pgroup:getPlayerPartyId(cid)
    if not partyId then return end
    if not partyTasks[partyId] then return end
    if status ~= partyTasks[partyId][id].status then
        partyTasks[partyId][id].status = status
        pgroup:updatePartyTasks(partyId, partyTasks[partyId])
    end
end

function sendToPartyMembers(partyId, callback)
	local members = pgroup:getPartyMembers(partyId)
	for _, member in pairs(members) do
        local player = GetPlayer(member.citizenid)
        if player then
			callback(player.source)
        end
    end
end

function hasPartyLimitReached(partyId)
    local hasReached = false
	local members = pgroup:getPartyMembers(partyId)
	for _, member in pairs(members) do
        local player = GetPlayer(member.citizenid)
        if player then
            local cid = player.citizenid
            if playerLimit[cid] and playerLimit[cid] >= Config.Party.maxPlayerLimit then
                hasReached = true
                break
			end
        end
    end
    return hasReached
end

function getPlayerLimit(cid)
    if playerLimit[cid] then
        return playerLimit[cid]
    else
        playerLimit[cid] = 0
        return playerLimit[cid]
    end
end

function addPlayerLimit(cid)
    if playerLimit[cid] then
        playerLimit[cid] = playerLimit[cid] + 1
    else
        playerLimit[cid] = 1
    end
end

RegisterNetEvent('bs-trucker:returnVehicle', function()
    local source = source
    local player = GetPlayer(source)
    local cid = player?.citizenid
    local partyId = pgroup:getPlayerPartyId(cid)
    local isLeader = pgroup:isPartyLeader(partyId, cid)
    if not isLeader then sendNotify(source, 'You are not party leader') return end
    if rentedVehicles[partyId] then
        local veh = NetworkGetEntityFromNetworkId(rentedVehicles[partyId][2])
        if DoesEntityExist(veh) then
            local c1 = GetEntityCoords(GetPlayerPed(source))
            local c2 = GetEntityCoords(veh)
            if #(c1-c2) > 100 then
                pgroup:sendPartyNotification(partyId, {
                    title = Config.Party.jobName,
                    description = 'You dont have vehicle to return.',
                    icon = 'truck',
                    duration = 10000
                })
                return
            end
            local bodyDamage = 100-(GetVehicleBodyHealth(veh) / 10)
            local engineDamage = 100-(GetVehicleEngineHealth(veh) / 10)
            local damage = (bodyDamage+engineDamage) / 2
            local price = (rentedVehicles[partyId][1] * (1 - (damage/100)))
            if damage > 80 then
                if player.removeMoney(math.abs(price), "Vehicle Damage Cost") then
                    DeleteEntity(veh)
                    rentedVehicles[partyId] = nil
                    pgroup:sendPartyNotification(partyId, {
                        title = Config.Party.jobName,
                        description = 'Vehicle has been returned.',
                        icon = 'truck',
                        duration = 10000
                    })
                    TriggerEvent('phone:server:requestDisbandParty', source)
                end
            else
                player.addMoney(price)
                DeleteEntity(veh)
                rentedVehicles[partyId] = nil
                pgroup:sendPartyNotification(partyId, {
                    title = Config.Party.jobName,
                    description = 'Vehicle has been returned.',
                    icon = 'truck',
                    duration = 10000
                })
                TriggerEvent('phone:server:requestDisbandParty', source)
            end
        else
            rentedVehicles[partyId] = nil
            TriggerEvent('phone:server:requestDisbandParty', source)
        end
    else
        sendNotify(source, 'There is no vehicle to return', 'error')
    end
end)

local isVehicleSpawning = {}
RegisterNetEvent('bs-trucker:rentVehicle', function()
    local source = source
    local player = GetPlayer(source)
    local cid = player?.citizenid
    local partyId = pgroup:getPlayerPartyId(cid)
    if not partyId then return end
    local isLeader = pgroup:isPartyLeader(partyId, cid)
    if not isLeader then sendNotify(source, 'You are not party leader') return end
    if not partyWork[partyId] then return end
    if isVehicleSpawning[source] then sendNotify(source, 'Please wait..') return end
    if rentedVehicles[partyId] then sendNotify(source, 'Cannot rent another vehicle') return end
    local job = partyWork[partyId]
    local clear, coords = getSpawnPoint()
    if not clear or not coords then sendNotify(source, 'There are vehicles in way') return false end
    if Config.Party.jobVehicle[job] then
        local model = Config.Party.jobVehicle[job].model
        local price = Config.Party.jobVehicle[job].price
        local canPay = player.removeMoney(price, 'Vehicle Rent - PostOP')
        if not canPay then sendNotify(source, 'could not rent a vehicle') return false end
        local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
        SetEntityHeading(veh, coords.w or 0.0)
        while not DoesEntityExist(veh) do Wait(0) end
        isVehicleSpawning[source] = true
        while NetworkGetEntityOwner(veh) ~= source do Wait(0) end
        TriggerClientEvent('fuel:setFuel', source, NetworkGetNetworkIdFromEntity(veh), 100)
        rentedVehicles[partyId] = {price, NetworkGetNetworkIdFromEntity(veh), job}
        local netId = NetworkGetNetworkIdFromEntity(veh)
        local vehplate = GetVehicleNumberPlateText(veh)
        updatePartyTasks(cid, 1, 'done')
        updatePartyTasks(cid, 2, 'current')
        sendToPartyMembers(partyId, function(playerId)
            if playerId then
                AddKeys(playerId, netId, vehplate)
                TriggerClientEvent('bs-trucker:startWork', playerId, job, netId)
                sendNotify(playerId, 'You started work: '..Config.Party.jobName)
            end
        end)
        pgroup:sendPartyNotification(partyId, {
            title = Config.Party.jobName,
            description = 'You rented a truck with plate: '..vehplate,
            icon = 'truck',
            duration = 15000
        })
        isVehicleSpawning[source] = nil
    end
end)

RegisterNetEvent("bs-trucker:initiateWork", function(work)
    local source = source
	local cid = GetPlayer(source)?.citizenid
	local partyId = pgroup:getPlayerPartyId(cid)
	if not partyId then sendNotify(source, 'You need to be in party to start work') return end
	local isLeader = pgroup:isPartyLeader(partyId, cid)
	if not isLeader then sendNotify(source, 'You are not party leader') return end
    if pgroup:getPartyJob(partyId) == Config.Party.jobName then sendNotify(source, 'Already doing work') return end
	local partySize = pgroup:getPartySize(partyId)
	if partySize >= Config.Party.minSize and partySize <= Config.Party.maxSize then
        if hasPartyLimitReached(partyId) then sendNotify(source, 'There is no work for you') return end
        if partyWork[partyId] then sendNotify(source, 'Already work has been assigned') return end
        local canSet = pgroup:setPartyJob(partyId, Config.Party.jobName)
        if not canSet.status then sendNotify(source, canSet.msg) return end
        if work == 'trucker' then
            partyTasks[partyId] = {
                {name='Rent a truck from person outside PostOP', status='current'},
                {name='Go to John and get your trailer', status='pending'},
                {name='Headover to the designated location to attach the trailer', status='pending'},
                {name='Continue to the given location and deliver the trailer', status='pending'},
                {name='Continue delivering or return the vehicle', status='pending'},
            }
        end
        pgroup:updatePartyTasks(partyId, partyTasks[partyId])
        partyWork[partyId] = work
	else sendNotify(source, 'Unmet Activity Requirements') return end
end)

RegisterNetEvent('phone:server:disbandParty', function(source, partyId)
    if partyTasks[partyId] then
        partyTasks[partyId] = nil
    end
    if rentedVehicles[partyId] then
        local veh = NetworkGetEntityFromNetworkId(rentedVehicles[partyId][2])
        DeleteEntity(veh)
        rentedVehicles[partyId] = nil
    end
end)

RegisterNetEvent("phone:server:leftParty", function(source, data)
    if data.currentJob == Config.Party.jobName then
        TriggerClientEvent('bs-trucker:stopWork', source)
    end
end)

RegisterNetEvent('phone:server:resumePendingJobs', function(source, data)
    if data.currentJob == Config.Party.jobName then
        local partyId = data.partyId
        if rentedVehicles[partyId] then
            TriggerClientEvent('bs-trucker:startWork', source, rentedVehicles[partyId][3], rentedVehicles[partyId][2])
            sendNotify(source, 'You continued work: '..Config.Party.jobName)
        end
    end
end)

pgroup:registerJob({
	name = Config.Party.jobName,
	icon = Config.Party.jobIcon,
	size = Config.Party.jobSize,
	type = Config.Party.jobType
})