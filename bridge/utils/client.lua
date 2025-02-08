function SendNotify(msg, type)
	if type == nil then type = 'inform' end
	lib.notify({ description = msg, type = type })
end

function HandleStress()
    -- add your export here to increase stress
end