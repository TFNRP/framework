function RegisterFrameworkCommand (name, handler, restricted)
  if type(name) == 'table' then
    for _, c in ipairs(name) do
      RegisterFrameworkCommand(c, handler, restricted)
    end
  else
    RegisterCommand(name, handler, restricted)
  end
end

function RegisterCommandAlias (command, alias)
  if type(alias) == 'table' then
    for _, a in ipairs(alias) do
      RegisterCommandAlias(command, a)
    end
  else
    RegisterCommand(alias, function (source, args, raw)
      ExecuteCommand(command .. ' ' .. table.concat(args, ' '))
    end)
  end
end

function RegisterCommandSuggestion(command, description, parameters, client)
  if type(command) == 'table' then
    for _, c in ipairs(command) do
      RegisterCommandSuggestion(c, description, parameters)
    end
  else
    TriggerEvent('chat:addSuggestion', '/' .. command, description, parameters)
  end
end

function ContainsNonWhitespaceCharacter(string)
  for i = 1, #string do
    local char = string:sub(i,i)
    if char ~= ' ' then
      return true
    end
  end
  return false
end

function GetClosestPlayer(radius, x, y, z)
  if not radius then
    radius = 20
  end
  if not x then
    local coords = GetEntityCoords(PlayerPedId())
    x, y, z = coords.x, coords.y, coords.z
  end

  local closestPlayer = nil
  local closestDistance = radius
  local pointCoords = vector3(x, y, z)
  for _, player in ipairs(GetActivePlayers()) do
    local ped = GetPlayerPed(player)
    if ped ~= 0 and player ~= PlayerId() then
      -- get the relative distance from point A
      local distance = #(GetEntityCoords(ped) - pointCoords)
      if distance < closestDistance then
        closestPlayer, closestDistance = player, distance
      end
    end
  end
  return closestPlayer
end