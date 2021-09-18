-- globals

PlayersOnDuty = {}
local lastTweet = nil
local lastTweeter = nil

AddEventHandler('playerConnecting', function(name)
  ServerNotification('serverPublic', nil, name .. ' connecting...')
end)

AddEventHandler('playerJoining', function()
  ServerNotification('serverPublic', nil, GetPlayerName(source) .. ' joined')
end)

AddEventHandler('playerDropped', function(reason)
  ServerNotification('serverPublic', nil, GetPlayerName(source) .. ' left (' .. reason .. ')')
end)

-- LEO

RegisterFrameworkCommand('duty', function (source, args, raw)
  local duty = 1
  if PlayerDutyStub(source).type >= duty then duty = 0 end
  SetDuty(source, duty)
end, true)

RegisterFrameworkCommand('onduty', function(source, args, raw)
  SetDuty(source, 1)
end, true)

RegisterFrameworkCommand('offduty', function(source, args, raw)
  SetDuty(source, 0)
end, true)

AddEventHandler("playerDropped", function()
  if PlayersOnDuty[source] then PlayersOnDuty[source] = nil end
end)

-- chat

AddEventHandler('chatMessage', function(source, name, message)
  if ContainsNonWhitespaceCharacter(message) then
    if string.sub(message, 1, 1) == '/' then
      TriggerClientEvent('chat:addMessage', source, { args = { '^3^*[System]', 'Command "' .. message .. '" does not exist.' } })
    else
      ServerNotification('chatPublic', source, message)
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
  local message = table.concat(args, ' ')
  ServerNotification('chatPublic', source, '[me]: ' .. message)
  TriggerClientEvent('chat:addProximityMessage', -1, source, {
    args = { '^r ' .. GetPlayerName(source), '^r ' .. message },
  })
end, false)

RegisterFrameworkCommand({'ooc', 'global'}, function (source, args, raw)
  local message = table.concat(args, ' ')
  ServerNotification('chatPublic', source, '[ooc]: ' .. message)
  TriggerClientEvent('chat:addMessage', -1, { args = { '^*^3[OOC] ' .. GetPlayerDisplayName(source), '^r' .. message } })
end, false)

RegisterFrameworkCommand({'ad', 'advert'}, function (source, args, raw)
  local message = table.concat(args, ' ')
  ServerNotification('chatPublic', source, '[advert]: ' .. message)
  TriggerClientEvent('chat:addMessage', -1, { args = { '^*^3[ADVERT] ' .. GetPlayerName(source), '^r^*^3' .. message } })
end, false)

RegisterFrameworkCommand('darkweb', function (source, args, raw)
  local message = table.concat(args, ' ')
  ServerNotification('chatPublic', source, '[darkweb]: ' .. message)
  TriggerClientEvent('chat:addMessage', -1, {
    args = { '^*[Dark Web]', '^r^*' .. message },
    color = { 0, 0, 0 },
  })
end, false)

RegisterFrameworkCommand({'tweet', 'twt', 'twitter'}, function (source, args, raw)
  local message = table.concat(args, ' ')
  ServerNotification('chatPublic', source, '[twitter]: ' .. message)
  TriggerClientEvent('chat:addMessage', -1, {
    args = { '^0[^4Twitter^0]', '^3@' .. GetPlayerName(source) .. ' ^0' .. message },
    color = { 30, 144, 255 },
  })
  lastTweet = message
  lastTweeter = GetPlayerName(source)
end, false)

RegisterFrameworkCommand({'rt', 'retweet'}, function (source, args, raw)
  if not lastTweet then
    return TriggerClientEvent('chat:addMessage', source, { args = { 'There\'s nothing to retweet.' } })
  end
  if GetPlayerName(source) == lastTweeter then
    return TriggerClientEvent('chat:addMessage', source, { args = { 'You cannot retweet yourself.' } })
  end
  ServerNotification('chatPublic', source, '[twitter]: ' .. GetPlayerName(source) .. ' RTs @' .. lastTweeter .. ' ^0' .. lastTweet)
  TriggerClientEvent('chat:addMessage', -1, {
    args = { '^0[^4Twitter^0]', '^3@' .. GetPlayerName(source) .. ' ^5RTs ^3@' .. lastTweeter .. ' ^0' .. lastTweet },
    color = { 30, 144, 255 },
  })
end, false)

-- staff

RegisterFrameworkCommand('staffduty', function (source, args, raw)
  local duty = 2
  if PlayerDutyStub(source).type >= duty then duty = 0 end
  SetDuty(source, duty)
end, true)

-- utilities

function SetDuty(source, duty)
  local lastDuty = PlayersOnDuty[source] or PlayerDutyStub()
  local handlers = {
    { nil, nil, function() ServerNotification('staffPublic', nil, { title = GetPlayerName(source), description = 'now **on** duty.' }) end, },
    nil,
    { function()
      ServerNotification('staffPublic', nil, {
        title = GetPlayerName(source),
        description = 'now **off** duty.\n' .. 'duration: ' .. FormatTime(lastDuty.timestamp),
      })
    end, }
  }
  if duty > 0 then
    if lastDuty.type == duty then TriggerClientEvent('chat:addMessage', source, 'You are already on duty.')
    else
      PlayersOnDuty[source] = {
        type = duty,
        timestamp = os.time(),
      }
      TriggerClientEvent('chat:addMessage', source, 'You are now on duty.')
      TriggerClientEvent('framework:dutyChange', source, duty)
    end
  else
    if lastDuty == 0 then TriggerClientEvent('chat:addMessage', source, 'You are already off duty.')
    else
      PlayersOnDuty[source] = nil
      TriggerClientEvent('chat:addMessage', source, 'You are now off duty.')
      TriggerClientEvent('framework:dutyChange', source, 0)
    end
  end
  local handler = handlers[lastDuty.type + 1]
  if handler then
    local subHandler = handler[PlayerDutyStub(source).type + 1]
    if subHandler then subHandler() end
  end
end

function ServerNotification(type, source, data)
  local object = Config.ServerNotifications[type]
  if object then
    local webhook = object[1]
    local handler = object[2]
    local message = handler(source, data)
    if message then
      PerformHttpRequest(webhook, function(code, content)
        if code < 200 or code >= 300 then
          error(code .. ': ' .. (content or 'no message'))
        end
      end, 'POST', json.encode(message), {
        ['Content-Type'] = 'application/json',
      })
    end
  end
end

function PlayerDutyStub(player)
  return PlayersOnDuty[player] or { type = 0 }
end

function GetPlayerDisplayName(source)
  for _, prefix in ipairs(Config.PlayerDisplayPrefixes) do
    if IsPlayerAceAllowed(source, prefix[1]) ~= false then return prefix[2] .. GetPlayerName(source) .. "^0" end
  end
  return GetPlayerName(source) .. "^0"
end