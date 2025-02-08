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

end