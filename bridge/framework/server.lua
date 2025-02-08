if GetResourceState('qb-core') == 'started' then
local QBCore = exports['qb-core']:GetCoreObject()

function GetPlayer(source)
    local player = nil
    if type(source) == 'string' then
        player = QBCore.Functions.GetPlayerByCitizenId(source)
    else
        player = QBCore.Functions.GetPlayer(source)
    end

    return player and {
        source = player.PlayerData.source,
        citizenid = player.PlayerData.citizenid,
        addMoney = function(amount, reason)
            return player.Functions.AddMoney('bank', amount, reason)
        end,
        removeMoney = function(amount, reason)
            return player.Functions.RemoveMoney('bank', amount, reason)
        end
    }
end

elseif GetResourceState('qbx_core') == 'started' then

function GetPlayer(source)
    local player = nil
    if type(source) == 'string' then
        player = exports.qbx_core:GetPlayerByCitizenId(source)
    else
        player = exports.qbx_core:GetPlayer(source)
    end

    return player and {
        source = player.PlayerData.source,
        citizenid = player.PlayerData.citizenid,
        addMoney = function(amount, reason)
            return player.Functions.AddMoney('bank', amount, reason)
        end,
        removeMoney = function(amount, reason)
            return player.Functions.RemoveMoney('bank', amount, reason)
        end
    }
end

elseif GetResourceState('es_extended') == 'started' then
local ESX = exports["es_extended"]:getSharedObject()
function GetPlayer(source)
    local player = nil
    if type(source) == 'string' then
        player = ESX.GetPlayerFromIdentifier(source)
    else
        player = ESX.GetPlayerFromId(source)
    end

    return player and {
        source = player.source,
        citizenid = player.license or player.identifier,
        addMoney = function(amount, reason)
            return player.addMoney(amount, reason)
        end,
        removeMoney = function(amount, reason)
            return player.removeMoney(amount, reason)
        end
    }
end

end