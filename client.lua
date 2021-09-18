-- vars
local duty = 0
local isPointing = false

-- decrease dmg output of taser & baton
Citizen.CreateThread(function()
  while true do
    SetWeaponDamageModifierThisFrame(GetHashKey("WEAPON_STUNGUN"), 0.1) 
    Citizen.Wait(0)
    SetWeaponDamageModifierThisFrame(GetHashKey("WEAPON_NIGHTSTICK"), 0.1) 
    Citizen.Wait(0)
  end
end)

-- disable pistol-whip
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if IsPedArmed(PlayerPedId(), 6) then
      DisableControlAction(1, 140, true)
         DisableControlAction(1, 141, true)
      DisableControlAction(1, 142, true)
    end
  end
end)

-- disable vehicle shuffle
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    local ped = GetPlayerPed(-1)
    if IsPedInAnyVehicle(ped, false) then
      local vehicle = GetVehiclePedIsIn(ped, 0)
      if GetPedInVehicleSeat(vehicle, 0) == ped then
        if GetIsTaskActive(ped, 165) then
          SetPedIntoVehicle(ped, vehicle, 0)
          SetVehicleCloseDoorDeferedAction(vehicle, 0)
        end
      end
    end
  end
end)


-- commands


RegisterFrameworkCommand('point', function()
  RequestAnimDict("anim@mp_point")
  while not HasAnimDictLoaded("anim@mp_point") do
    Wait(0)
  end

  if isPointing then
    ClearPedTasks(ped)
    isPointing = false
  else
    local ped = GetPlayerPed(-1);
    Citizen.Wait(10)
    TaskMoveNetworkByName(ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    isPointing = true
  end
end, false)

RegisterFrameworkCommand({ 'pm', 'dm', 'message' }, function (source, args, raw)
  local clientId = GetPlayerServerId(PlayerId(-1))
  local serverId = tonumber(args[1])
  local argMessage = table.concat(args, ' ', 2)
  -- argument validation
  if type(serverId) ~= 'number' then
    return CommandWarning('player must be a server id.')
  end
  if #argMessage <= 0 then
    return CommandWarning('message must be more than 0 characters.')
  end

  -- validation
  local player = GetPlayerFromServerId(serverId)
  if type(player) ~= 'number' or player <= 0 then
    return CommandWarning('This player doesn\'t exist.')
  end
  if serverId == clientId then
    return CommandWarning('You PM\'d yourself. Wait, you can\'t.')
  end

  TriggerServerEvent('chat:addPrivateMessage', serverId, { args = { string.format(Format.PM, GetPlayerName(player), 'You'), argMessage } })
  TriggerEvent('chat:addMessage', { args = { string.format(Format.PM, 'You', GetPlayerName(player)), argMessage } })
end, false)

RegisterFrameworkCommand('discord', function()
  exports.copyutil:Copy(Constants.DiscordInvite)
  TriggerEvent('chat:addMessage', {
    args = { '^*Copied to Clipboard! >> ^5^_' .. Constants.DiscordInvite },
    color = { 245, 191, 66 },
  })
end, false)

RegisterFrameworkCommand({'dv', 'delveh'}, function()
  local ped = GetPlayerPed(-1)
  local vehicle = GetVehiclePedIsInOrNear(ped, false)
  if vehicle and vehicle > 1 then
    if IsPedSittingInVehicle(ped, vehicle) and not GetPedInVehicleSeat(vehicle, -1) == ped then
      ShowNotification("~r~Error: ~s~You must be the driver of the vehicle.")
    else
      SetEntityAsMissionEntity(vehicle, true, true)
      DeleteVehicle(vehicle)
      if not (DoesEntityExist(vehicle)) then
        ShowNotification("~g~Success: ~s~Vehicle deleted.")
      end
    end
  else
    ShowNotification("~r~Error: ~w~You must be close to or in a vehicle.")
  end
end)

RegisterFrameworkCommand({ 'fix', 'repair' }, function()
  local vehicle = GetVehiclePedIsInOrNear(PlayerPedId(), false)
  if vehicle and vehicle > 1 then
    SetVehicleEngineHealth(vehicle, 1000)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleFixed(vehicle)
  end
end)

RegisterFrameworkCommand({ 'clean', 'wash' }, function()
  local vehicle = GetVehiclePedIsInOrNear(PlayerPedId(), false)
  if vehicle and vehicle > 1 then
    SetVehicleDirtLevel(vehicle, 0)
  end
end)

RegisterFrameworkCommand('hood', function()
  local vehicle = GetVehiclePedIsInOrNear(PlayerPedId(), false)
  if vehicle and vehicle > 1 then
    NetworkRequestControlOfEntity(vehicle)
    if GetVehicleDoorAngleRatio(vehicle, 4) > 0 then
      SetVehicleDoorShut(vehicle, 4, false)
    else
      SetVehicleDoorOpen(vehicle, 4, false, false)
    end
  end
end)

RegisterFrameworkCommand('trunk', function()
  local vehicle = GetVehiclePedIsInOrNear(PlayerPedId(), false)
  if vehicle and vehicle > 1 then
    NetworkRequestControlOfEntity(vehicle)
    if GetVehicleDoorAngleRatio(vehicle, 5) > 0 then
      SetVehicleDoorShut(vehicle, 5, false)
    else
      SetVehicleDoorOpen(vehicle, 5, false, false)
    end
  end
end)

RegisterFrameworkCommand('door', function(source, args, raw)
  local vehicle = GetVehiclePedIsInOrNear(PlayerPedId(), false)
  local door = (tonumber(args[1]) or 1) - 1
  if vehicle and vehicle > 1 then
    local doors = GetNumberOfVehicleDoors(vehicle) - 1
    if doors < door then door = doors
    elseif door < 0 then door = 0 end
    NetworkRequestControlOfEntity(vehicle)
    if GetVehicleDoorAngleRatio(vehicle, door) > 0 then
      SetVehicleDoorShut(vehicle, door, false)
    else
      SetVehicleDoorOpen(vehicle, door, false, false)
    end
  end
end)

RegisterFrameworkCommand('window', function(source, args, raw)
  local vehicle = GetVehiclePedIsInOrNear(PlayerPedId(), false)
  local window = (tonumber(args[1]) or 1) - 1
  if vehicle and vehicle > 1 then
    if window > 11 then window = 11
    elseif window < 0 then window = 0 end
    local decoratorName = 'WindowRolledDown' .. window
    if not DecorIsRegisteredAsType(decoratorName, 2) then
      DecorRegister(decoratorName, 2)
    end
    if not DecorGetBool(vehicle, decoratorName) then
      DecorSetBool(vehicle, decoratorName, true)
      RollDownWindow(vehicle, window)
    else
      DecorSetBool(vehicle, decoratorName, false)
      RollUpWindow(vehicle, window)
    end
  end
end)


-----/


RegisterNetEvent('framework:dutyChange', function (id)
  if id > 0 then
    duty = id
    ShowNotification('You are now ~g~on~s~ duty.')
  else
    duty = id
    ShowNotification('You are now ~r~off~s~ duty.')
  end

  return duty
end)

RegisterNetEvent('chat:addProximityMessage', function (serverId, message)
  local player = GetPlayerFromServerId(serverId)
  local client = PlayerId()
  if player == client or GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(client)), GetEntityCoords(GetPlayerPed(player)), true) < Constants.ProximityMessageDistance then
    TriggerEvent('chat:addMessage', message)
  end
end)

-- util

function GetVehiclePedIsInOrNear(ped, lastVehicle)
  local vehicle = GetVehiclePedIsIn(ped, lastVehicle)
  if vehicle and vehicle > 1 then
    return vehicle
  else
    local position = GetEntityCoords(ped)
    local front = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    local rayHandle = CastRayPointToPoint(position.x, position.y, position.z, front.x, front.y, front.z, 10, ped, 0)
    local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
    if DoesEntityExist(vehicle) then
      return vehicle
    end
  end
end

function CommandWarning(message)
  TriggerEvent('chat:addMessage', { args = { message } })
end

function GetLocalClientDuty()
  return duty
end

function ShowNotification(message)
  SetNotificationTextEntry("STRING")
  AddTextComponentSubstringPlayerName(message)
  DrawNotification(true, true)
end