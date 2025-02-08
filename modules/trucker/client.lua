local shownBlips = {}
local isDoingJob = false
local canRequestNewTrailer = false
local routeBlip = nil
local deliveryZone = nil

local function createBlips()
	for name, data in pairs(Config.Trucker.blips) do
		shownBlips[name] = AddBlipForCoord(data.coords)
		SetBlipAsShortRange(shownBlips[name], true)
		SetBlipSprite(shownBlips[name], data.sprite)
		SetBlipColour(shownBlips[name], data.color)
		SetBlipScale(shownBlips[name], 0.7)
		SetBlipDisplay(shownBlips[name], 6)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(data.name)
		EndTextCommandSetBlipName(shownBlips[name])
	end
end

local function removeBlips()
	for _, id in pairs(shownBlips) do
		RemoveBlip(id)
	end
end

local function createRouteBlip(cd)
	if DoesBlipExist(routeBlip) then RemoveBlip(routeBlip) end
	ClearAllBlipRoutes()
	routeBlip = AddBlipForCoord(cd.x,cd.y,cd.z)
	SetBlipSprite(routeBlip, 367)
	SetBlipColour(routeBlip, 29)
	SetBlipRoute(routeBlip, true)
	SetBlipRouteColour(routeBlip, 29)
end

local function createDestination(trailerNetId, tCoords, destination)
	local coords = destination.coords
	local isWaitingForTrailerAttach = true
	CreateThread(function ()
		while isWaitingForTrailerAttach do
			Wait(4)
			DrawMarker(20, tCoords.x, tCoords.y, tCoords.z+6.0, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 3.0, 97, 154, 218, 255, false, false, 2, false, nil, nil, false)
			if not canRequestNewTrailer then isWaitingForTrailerAttach = false end
		end
	end)
	while isWaitingForTrailerAttach do
		if IsVehicleAttachedToTrailer(cache.vehicle) then
			local retval, trailer = GetVehicleTrailerVehicle(cache.vehicle)
			if retval then
				local trailerClientNetId = NetworkGetNetworkIdFromEntity(trailer)
				if trailerClientNetId == trailerNetId then
					isWaitingForTrailerAttach = false
					createRouteBlip(coords)
				end
			end
		end
		Wait(1000)
	end
	TriggerServerEvent('trucker:hasAttachedTrailer')
	local onEnterDeliverSpot = false
	deliveryZone = lib.zones.box({
		coords = vec3(coords.x, coords.y, coords.z),
		size = vec3(7.5, 25.75, 10.3),
		rotation = coords.w,
		debug = Config.Debug,
		onEnter = function ()
			lib.showTextUI('[E] Deliver Trailer')
			onEnterDeliverSpot = true
		end,
		onExit = function ()
			lib.hideTextUI()
			onEnterDeliverSpot = false
		end
	})
	CreateThread(function()
		while canRequestNewTrailer do
			Wait(10000)
			HandleStress()
		end
	end)
	CreateThread(function()
		while canRequestNewTrailer do
			Wait(4)
			local inDeliverZone = false
			local player = PlayerPedId()
			local plyCoords = GetEntityCoords(player)
			if #(vector3(coords.x, coords.y, coords.z)-vector3(plyCoords.x, plyCoords.y, plyCoords.z)) < 100 then
				inDeliverZone = true
				DrawMarker(43, coords.x, coords.y, coords.z-1.3, 0, 0, 0, 0, 0, coords.w, 7.5, 25.75, 2.0, 59, 130, 246, 155, true, false, 2, false, nil, nil, false)
				if onEnterDeliverSpot then
					if IsControlJustPressed(0, 38) then
						if IsVehicleAttachedToTrailer(cache.vehicle) then
							local retval, trailer = GetVehicleTrailerVehicle(cache.vehicle)
							if retval then
								local hasRemoved = lib.callback.await('trucker:removeTrailer', false, NetworkGetNetworkIdFromEntity(trailer))
								if hasRemoved then
									lib.hideTextUI()
									if DoesBlipExist(routeBlip) then RemoveBlip(routeBlip) end
									ClearAllBlipRoutes()
									DetachVehicleFromTrailer(cache.vehicle)
									if deliveryZone then deliveryZone:remove() end
									onEnterDeliverSpot = false
									canRequestNewTrailer = false
								end
							end
						else
							SendNotify('No trailer is attached to vehicle', 'error')
						end
					end
				end
			end
			if not inDeliverZone then
				Wait(500)
			end
		end
	end)
end

function updateTrucker(bool)
	isDoingJob = bool
	if bool then
		SetNewWaypoint(1197.21, -3253.58)
		createBlips()
	else
		canRequestNewTrailer = false
		if DoesBlipExist(routeBlip) then RemoveBlip(routeBlip) end
		ClearAllBlipRoutes()
		if deliveryZone then deliveryZone:remove() end
		removeBlips()
	end
end

RegisterNetEvent('trucker:initiateTrailerWork', function(trailerNetId, coords, destination)
	canRequestNewTrailer = true
	createRouteBlip(coords)
	createDestination(trailerNetId, coords, destination)
end)

RegisterNetEvent('trucker:resetTrailer', function()
	lib.hideTextUI()
	canRequestNewTrailer = false
	if DoesBlipExist(routeBlip) then RemoveBlip(routeBlip) end
	ClearAllBlipRoutes()
	if deliveryZone then deliveryZone:remove() end
end)

CreateThread(function()
	for _, data in pairs(Config.Trucker.jobZones) do
		exports.ox_target:addBoxZone({
			coords = data.coords,
			size = data.size,
			rotation = data.rotation,
			debug = Config.Debug,
			options = {
				{
                    label = 'Request Trailer',
                    icon = 'fa-solid fa-trailer',
					distance = 2,
                    canInteract = function ()
                        return IsInParty() and isDoingJob and not canRequestNewTrailer
                    end,
                    onSelect = function()
						TriggerServerEvent('trucker:requestTrailer', data.location)
                    end
                },
				{
                    label = 'Request Trailer Replacement',
                    icon = 'fa-solid fa-xmark',
					distance = 2,
                    canInteract = function ()
                        return IsInParty() and isDoingJob and canRequestNewTrailer
                    end,
                    onSelect = function()
						TriggerServerEvent('trucker:resetTrailer', data.location, data.trailerCancelPrice)
                    end
                }
			}
		})
	end
end)