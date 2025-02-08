function IsInParty()
	local data = LocalPlayer.state.partyData
	if data and data.currentJob then
		return data.inParty and (data.currentJob == Config.Party.jobName)
	end
	return false
end

RegisterNetEvent('bs-trucker:notify', SendNotify)

RegisterNetEvent('bs-trucker:startWork', function(job, netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    SetVehiclePetrolTankHealth(veh, 1000.0)
    SetDisableVehiclePetrolTankDamage(veh, true)
    if job == 'trucker' then
        updateTrucker(true)
    end
end)

RegisterNetEvent('bs-trucker:stopWork', function()
    updateTrucker(false)
end)

CreateThread(function()
    local blipData = Config.Party.jobBlip
    local blip = AddBlipForCoord(blipData.coords)
    SetBlipAsShortRange(blip, true)
    SetBlipSprite(blip, blipData.sprite)
    SetBlipColour(blip, blipData.color)
    SetBlipScale(blip, 0.6)
    SetBlipDisplay(blip, 6)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipData.name)
    EndTextCommandSetBlipName(blip)
    for name, data in pairs(Config.Party.jobPeds) do
        exports['cad-pedspawner']:AddPed(name, {
            model = data.model,
            coords = data.coords,
            type = data.type ,
            distance = 10.0,
            states = {
                freeze = data.freeze,
                blockevents = data.blockevents,
                invincible = data.invincible,
            }
        })
    end
    for _, data in pairs(Config.Party.jobZone) do
        exports.ox_target:addBoxZone({
			coords = data.coords,
			size = data.size,
			rotation = data.rotation,
			debug = Config.Debug,
			options = {
				{
                    label = 'Sign In (Trucker)',
                    icon = 'fa-solid fa-briefcase',
                    distance = 1,
                    canInteract = function ()
                        return not IsInParty()
                    end,
                    onSelect = function()
                        TriggerServerEvent('bs-trucker:initiateWork', 'trucker')
                    end
                },
			}
		})
    end
    for _, data in pairs(Config.Party.jobVehZone) do
        exports.ox_target:addBoxZone({
			coords = data.coords,
			size = data.size,
			rotation = data.rotation,
			debug = Config.Debug,
			options = {
                {
                    label = 'Rent Vehicle',
                    icon = 'fa-solid fa-briefcase',
                    distance = 2,
                    canInteract = function ()
                        return IsInParty()
                    end,
                    onSelect = function()
                        TriggerServerEvent('bs-trucker:rentVehicle')
                    end
                },
                {
                    label = 'Return Vehicle',
                    icon = 'fa-solid fa-briefcase',
                    distance = 2,
                    canInteract = function ()
                        return IsInParty()
                    end,
                    onSelect = function()
                        TriggerServerEvent('bs-trucker:returnVehicle')
                    end
                }
			}
		})
    end
end)

AddEventHandler('onResourceStop', function(resName)
	if resName ~= GetCurrentResourceName() then return end
	for name in pairs(Config.Party.jobPeds) do
		exports['cad-pedspawner']:DeletePed(name)
	end
end)