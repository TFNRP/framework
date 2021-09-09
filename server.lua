local onDuty = {}

local function setDuty(source, duty)
    if duty == true then
        if onDuty[source] == true then TriggerClientEvent('chat:addMessage', source, 'You are already on duty.')
        else
            onDuty[source] = true
            TriggerClientEvent('chat:addMessage', source, 'You are now on duty.')
            TriggerClientEvent('leo:dutyChange', source, true)
        end
    else
        if onDuty[source] == false then TriggerClientEvent('chat:addMessage', source, 'You are already off duty.')
        else
            onDuty[source] = nil
            TriggerClientEvent('chat:addMessage', source, 'You are now off duty.')
            TriggerClientEvent('leo:dutyChange', source, false)
        end
    end
end

RegisterCommand('duty', function (source, args, raw)
    setDuty(source, not onDuty[source])
end, true)

RegisterCommand('onduty', function(source, args, raw)
    setDuty(source, true)
end, true)

RegisterCommand('offduty', function(source, args, raw)
    setDuty(source, false)
end, true)

AddEventHandler("playerDropped", function()
	if onDuty[source] then onDuty[source] = nil end
end)

function IsOnDuty (source)
    return onDuty[source] or false
end