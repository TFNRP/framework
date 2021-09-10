-- globals

local onDuty = {}
local lastTweet = nil
local lastTweeter = nil

-- LEO

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

-- chat

AddEventHandler('chatMessage', function(source, name, message)
    if ContainsNonWhitespaceCharacter(message) then
        if string.sub(message, 1, 1) == '/' then
            TriggerClientEvent('chat:addMessage', source, { args = { '^3^*[System]', 'Command "' .. message .. '" does not exist.' } })
        else
            TriggerClientEvent('chat:addProximityMessage', -1, source, {
                args = { '^r' .. GetPlayerDisplayName(source), '^r ' .. message },
            })
        end
    end
    CancelEvent()
end)

RegisterNetEvent('chat:addPrivateMessage', function (serverId, message)
    TriggerClientEvent('chat:addMessage', serverId, message)
end)

RegisterFrameworkCommand({'me', 'do'}, function (source, args, raw)
    TriggerClientEvent('chat:addProximityMessage', -1, source, {
        args = { '^r ' .. GetPlayerName(source), '^r ' .. message },
    })
end, false)

RegisterFrameworkCommand({'ooc', 'global'}, function (source, args, raw)
    TriggerClientEvent('chat:addMessage', -1, { args = { '^*^3[OOC] ' .. GetPlayerDisplayName(source), '^r' .. table.concat(args, ' ') } })
end, false)

RegisterFrameworkCommand({'ad', 'advert'}, function (source, args, raw)
    TriggerClientEvent('chat:addMessage', -1, { args = { '^*^3[ADVERT] ' .. GetPlayerName(source), '^r^*^3' .. table.concat(args, ' ') } })
end, false)

RegisterFrameworkCommand('darkweb', function (source, args, raw)
    TriggerClientEvent('chat:addMessage', -1, {
        args = { '^*[Dark Web]', '^r^*' .. table.concat(args, ' ') },
        color = { 0, 0, 0 },
    })
end, false)

RegisterFrameworkCommand({'tweet', 'twt', 'twitter'}, function (source, args, raw)
    TriggerClientEvent('chat:addMessage', -1, {
        args = { '^0[^4Twitter^0]', '^3@' .. GetPlayerName(source) .. ' ^0' .. table.concat(args, ' ') },
        color = { 30, 144, 255 },
    })
    lastTweet = table.concat(args, ' ')
    lastTweeter = GetPlayerName(source)
end, false)

RegisterFrameworkCommand({'rt', 'retweet'}, function (source, args, raw)
    if not lastTweet then
        return TriggerClientEvent('chat:addMessage', source, { args = { 'There\'s nothing to retweet.' } })
    end
    if GetPlayerName(source) == lastTweeter then
        return TriggerClientEvent('chat:addMessage', source, { args = { 'You cannot retweet yourself.' } })
    end
    TriggerClientEvent('chat:addMessage', -1, {
        args = { '^0[^4Twitter^0]', '^3@' .. GetPlayerName(source) .. ' ^5RTs ^3@' .. lastTweeter .. ' ^0' .. lastTweet },
        color = { 30, 144, 255 },
    })
end, false)

-- utilities

function IsOnDuty (source)
    return onDuty[source] or false
end

function GetPlayerDisplayName(source)
	local prefixes = {
		{"prefix.admin", "^1[Administrator] "},
		{"prefix.moderator", "^2[Moderator] "},
		{"prefix.staff", "^2[Staff] "},
		{"prefix.lspd", "^5[LSPD] "},
		{"prefix.bcso", "^8[BCSO] "},
		{"prefix.sahp", "^3[SAHP] "},
		{"prefix.sams", "^2[SAMS] "},
	}
	for _, prefix in ipairs(prefixes) do
		if IsPlayerAceAllowed(source, prefix[1]) ~= false then return prefix[2] .. GetPlayerName(source) .. "^0" end
	end
	return GetPlayerName(source) .. "^0"
end