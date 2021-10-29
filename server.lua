-- globals

PlayersOnDuty = {}
local lastTweet = nil
local lastTweeter = nil
local clientConfig = { ServerDensity = Config.DefaultDensity }

SetConvar('tfnrp_framework_init', 'true')

RegisterNetEvent('framework:physgunAttachSend', function(serverId, detach)
  TriggerClientEvent('framework:physgunAttach', serverId, source, detach)
end)

RegisterNetEvent('framework:taserLaserSet', function(state)
  if state then
    TriggerClientEvent('framework:taserLaserRender', -1, source)
  else
    TriggerClientEvent('framework:taserLaserRenderStop', -1, source)
  end
end)

RegisterNetEvent('framework:requestConfig', function()
  TriggerClientEvent('framework:setConfig', source, clientConfig)
end)

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
  if GetPlayerDuty(source).type >= duty then duty = 0 end
  SetDuty(source, duty)
end, true)

RegisterFrameworkCommand('onduty', function(source, args, raw)
  SetDuty(source, 1)
end, true)

RegisterFrameworkCommand('offduty', function(source, args, raw)
  SetDuty(source, 0)
end, true)

AddEventHandler('playerDropped', function()
  if PlayersOnDuty[source] then PlayersOnDuty[source] = nil end
end)

-- chat

AddEventHandler('chatMessage', function(source, name, message)
  if ContainsNonWhitespaceCharacter(message) then
    if string.sub(message, 1, 1) == '/' then
      TriggerClientEvent('chat:addMessage', source, {
        args = {
          Constants.SystemPrefix,
          'Command "' .. message .. '" does not exist.'
        }
      })
    elseif not ContainsSwear(message) then
      ServerNotification('chatPublic', source, message)
      TriggerClientEvent('chat:addProximityMessage', -1, source, {
        args = {
          '^r' .. GetPlayerDisplayName(source),
          '^r ' .. message
        },
      })
    end
  end
  CancelEvent()
end)

RegisterNetEvent('chat:addPrivateMessage', function (serverId, message)
  TriggerClientEvent('chat:addMessage', serverId, message)
end)

RegisterFrameworkCommand({ 'me', 'do' }, function (source, args, raw)
  local message = table.concat(args, ' ')
  if ContainsNonWhitespaceCharacter(message) and not ContainsSwear(message) then
    ServerNotification('chatPublic', source, '[me]: ' .. message)
    TriggerClientEvent('chat:addProximityMessage', -1, source, {
      args = {
        '^r ' .. GetPlayerName(source),
        '^r ' .. message
      },
    })
  end
end, false)

RegisterFrameworkCommand({ 'globalme', 'gme', 'globaldo', 'gdo' }, function (source, args, raw)
  local message = table.concat(args, ' ')
  if ContainsNonWhitespaceCharacter(message) and not ContainsSwear(message) then
    ServerNotification('chatPublic', source, '[global me]: ' .. message)
    TriggerClientEvent('chat:addMessage', -1, {
      args = {
        '^*^3[Global Me] ^r ' .. GetPlayerDisplayName(source),
        '^r ' .. message
      }
    })
  end
end, false)

RegisterFrameworkCommand({ 'ooc', 'global' }, function (source, args, raw)
  local message = table.concat(args, ' ')
  if ContainsNonWhitespaceCharacter(message) and not ContainsSwear(message) then
    ServerNotification('chatPublic', source, '[ooc]: ' .. message)
    TriggerClientEvent('chat:addMessage', -1, {
      args = {
        '^*^3[OOC] ' .. GetPlayerDisplayName(source),
        '^r' .. message
      }
    })
  end
end, false)

RegisterFrameworkCommand({ 'ad', 'advert' }, function (source, args, raw)
  local message = table.concat(args, ' ')
  if ContainsNonWhitespaceCharacter(message) and not ContainsSwear(message) then
    ServerNotification('chatPublic', source, '[advert]: ' .. message)
    TriggerClientEvent('chat:addMessage', -1, {
      args = {
        '^*^3[ADVERT] ' .. GetPlayerName(source),
        '^r^*^3' .. message
      }
    })
  end
end, false)

RegisterFrameworkCommand('darkweb', function (source, args, raw)
  local message = table.concat(args, ' ')
  if ContainsNonWhitespaceCharacter(message) and not ContainsSwear(message) then
    ServerNotification('chatPublic', source, '[darkweb]: ' .. message)
    TriggerClientEvent('chat:addMessage', -1, {
      args = {
        '^*[Dark Web]',
        '^r^*' .. message
      },
      color = { 0, 0, 0 },
    })
  end
end, false)

RegisterFrameworkCommand({ 'tweet', 'twt', 'twitter' }, function (source, args, raw)
  local message = table.concat(args, ' ')
  if ContainsNonWhitespaceCharacter(message) and not ContainsSwear(message) then
    ServerNotification('chatPublic', source, '[twitter]: ' .. message)
    TriggerClientEvent('chat:addMessage', -1, {
      args = {
        '^0[^4Twitter^0]',
        '^3@' .. GetPlayerName(source) .. ' ^0' .. message
      },
      color = { 30, 144, 255 },
    })
    lastTweet = message
    lastTweeter = GetPlayerName(source)
  end
end, false)

RegisterFrameworkCommand({ 'rt', 'retweet' }, function (source, args, raw)
  if not lastTweet then
    return TriggerClientEvent('chat:addMessage', source, {
      args = {
        'There\'s nothing to retweet.'
      }
    })
  end
  if GetPlayerName(source) == lastTweeter then
    return TriggerClientEvent('chat:addMessage', source, {
      args = {
        'You cannot retweet yourself.'
      }
    })
  end
  ServerNotification(
    'chatPublic', source, '[twitter]: ' .. GetPlayerName(source) .. ' RTs @' .. lastTweeter .. ' ^0' .. lastTweet
  )
  TriggerClientEvent('chat:addMessage', -1, {
    args = {
      '^0[^4Twitter^0]',
      '^3@' .. GetPlayerName(source) .. ' ^5RTs ^3@' .. lastTweeter .. ' ^0' .. lastTweet
    },
    color = { 30, 144, 255 },
  })
end, false)

-- allows you to do `reminders_add "My reminder"` in server.cfg
RegisterFrameworkCommand("reminders_add", function(source, args, raw)
  if args[1] and (source == 0 or IsPlayerAceAllowed(source, 'server.reminders.add')) then
    local text = string.gsub(raw, 'reminders_add ', '')
    if (string.sub(text, 1, 1) == '\'' and string.sub(text, #text, #text) == '\'') or (string.sub(text, 1, 1) == '"' and string.sub(text, #text, #text) == '"') then
      text = string.sub(text, 2, #text - 1)
    end

    table.insert(Config.Reminders.Messages, text)
  end
end, true)

RegisterFrameworkCommand("reminders_remove", function(source, args, raw)
  if args[1] and (source == 0 or IsPlayerAceAllowed(source, 'server.reminders.remove')) then
    local index = tonumber(args[1]) or #Config.Reminders.Messages
    if index then
      Config.Reminders.Messages[index] = nil
    end
  end
end, true)

Citizen.CreateThread(function()
  local lastIndex -- the last reminder used
  if #Config.Reminders.Messages > 2 then
    while true do
      local amount = GetConvarInt('reminders_interval', Config.Reminders.Interval)
      local prefix = GetConvar('reminders_prefix', Constants.SystemPrefix)
      if amount <= 0 then amount = 5 end
      local amount = amount * 6e4
      Citizen.Wait(amount)
      if #Config.Reminders.Messages > 0 then
        local index
        local reminder
        repeat
          repeat
            index = math.random(#Config.Reminders.Messages)
          until index ~= lastIndex or #Config.Reminders.Messages <= 1
          reminder = Config.Reminders.Messages[index]
          if type(reminder) == 'function' then
            reminder = reminder()
          end
        until reminder
        lastIndex = index

        local args = { reminder }
        if prefix then table.insert(args, 1, prefix) end
        TriggerClientEvent('chat:addMessage', -1, {
          color = true,
          args = args,
        })
      end
    end
  end
end)

-- staff

RegisterFrameworkCommand('staffduty', function (source, args, raw)
  local duty = 2
  if GetPlayerDuty(source).type >= duty then duty = 0 end
  SetDuty(source, duty)
end, true)

RegisterFrameworkCommand('physgun', function (source, args, raw)
  TriggerClientEvent('framework:physgunToggle', source)
end, true)

RegisterFrameworkCommand('spawncode', function (source, args, raw)
  TriggerClientEvent('framework:printCurrentVehicleName', source)
end, true)

RegisterFrameworkCommand('density', function (source, args, raw)
  local density = tonumber(args[1])
  if type(density) ~= 'number' then
    CommandWarning(source, 'density must be a number.')
  else
    clientConfig.ServerDensity = density + .0
    TriggerClientEvent('framework:setConfig', -1, clientConfig)
  end
end, true)

-- utilities

function SetDuty(source, duty)
  local lastDuty = GetPlayerDuty(source)
  local handlers = {
    {
      nil,
      nil,
      function()
        ServerNotification('staffPublic', nil, {
          title = GetPlayerName(source),
          description = 'now **on** duty.'
        })
      end,
    },
    nil,
    {
      function()
        ServerNotification('staffPublic', nil, {
          title = GetPlayerName(source),
          description = 'now **off** duty.\n' .. 'duration: ' .. FormatTime(lastDuty.timestamp),
        })
      end,
    }
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
    if lastDuty.type == 0 then TriggerClientEvent('chat:addMessage', source, 'You are already off duty.')
    else
      PlayersOnDuty[source] = nil
      TriggerClientEvent('chat:addMessage', source, 'You are now off duty.')
      TriggerClientEvent('framework:dutyChange', source, 0)
    end
  end
  local handler = handlers[lastDuty.type + 1]
  if handler then
    local subHandler = handler[GetPlayerDuty(source).type + 1]
    if subHandler then subHandler() end
  end
end

function ServerNotification(type, source, data)
  local object = Config.ServerNotifications[type]
  if object then
    local webhook = object[1]
    local handler = object[2]
    local message = handler(source, data)
    if string.sub(webhook, 1, 1) == '\'' or string.sub(webhook, 1, 1) == '"' then
      webhook = string.sub(webhook, 2, #webhook - 1)
    end
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

function GetPlayerDuty(player)
  return PlayersOnDuty[player] or {
    type = 0
  }
end

function GetPlayerDisplayName(source)
  for _, prefix in ipairs(Config.PlayerDisplayPrefixes) do
    if IsPlayerAceAllowed(source, prefix[1]) ~= false then return prefix[2] .. GetPlayerName(source) .. '^0' end
  end
  return GetPlayerName(source) .. '^0'
end

function CommandWarning(src, message)
  TriggerClientEvent('chat:addMessage', src, { args = { message } })
end