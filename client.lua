-- globals
Config = {}

-- vars
local duty = 0
local usePhysgun = false
local persistentAttach = {}
local showTaserLaserPlayers = {}
local taserLaserState = false
local isCrouching = false
local hideHud = false
local handsUp = false

-- a short welcome message when they join
AddEventHandler('playerSpawned', function ()
  TriggerEvent('chat:addMessage', {
    color = true,
    args = {
      Constants.SystemPrefix,
      'Welcome ' .. GetPlayerName(PlayerId()) ..
      '^0^r^*! Please make sure you\'re in the ^3^_/discord^0^r^* server to get started or for help.'
    },
  })
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    -- decrease dmg output of taser & baton
    SetWeaponDamageModifierThisFrame(GetHashKey('WEAPON_STUNGUN'), .1)
    SetWeaponDamageModifierThisFrame(GetHashKey('WEAPON_NIGHTSTICK'), .1)
    -- disable combat rolling & climbing whilst aiming
    if IsPlayerFreeAiming(PlayerId()) then
      DisableControlAction(0, 22, true)
    end
  end
end)

-- disable pistol-whip
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if IsPedArmed(PlayerPedId(), 6) and not IsPedInAnyVehicle(PlayerPedId()) then
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

-- admin physgun
Citizen.CreateThread(function()
  local pickedUp = false
  local entity, hit
  while true do
    Citizen.Wait(0)
    if usePhysgun then
      DisablePlayerFiring(PlayerId(), true)
      if IsControlJustReleased(0, 229) then
        if not pickedUp then
          local rot = GetGameplayCamRot()
          local fixedRotX = (math.pi / 180) * rot.x
          local fixedRotZ = (math.pi / 180) * rot.z
          local offset = GetOffsetFromEntityInWorldCoords(GetCurrentPedWeaponEntityIndex(GetPlayerPed(-1)), .0, .0, .0)
          local rayHandle = StartShapeTestRay(
            offset.x, offset.y, offset.z,
            offset.x + (-math.sin(fixedRotZ) * math.abs(math.cos(fixedRotX))) * 15000,
            offset.y + (math.cos(fixedRotZ) * math.abs(math.cos(fixedRotX))) * 15000,
            offset.z + math.sin(fixedRotX) * 15000,
            -1, PlayerPedId(), 1
          )
          _, hit, _, _, entity = GetShapeTestResult(rayHandle)
          if
            hit == 1 and (
              IsEntityAPed(entity) or
              IsEntityAVehicle(entity) or
              IsEntityAnObject(entity)
            ) and DoesEntityExist(entity)
          then
            if IsEntityAPed(entity) and IsPedInAnyVehicle(entity, false) then
              entity = GetVehiclePedIsIn(entity, false)
            end
            if entity and entity > 0 then
              pickedUp = true
              SetEntityAlpha(entity, 200)
              if IsEntityAPed(entity) and IsPedAPlayer(entity) then
                TriggerServerEvent(
                  'framework:physgunAttachSend',
                  GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)), false
                )
              else
                persistentAttach:add(entity, GetPlayerPed(PlayerId()))
              end
            end
          end
        else
          pickedUp = false
          if IsEntityAPed(entity) and IsPedAPlayer(entity) then
            TriggerServerEvent('framework:physgunAttachSend', GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)), true)
          else
            persistentAttach:remove()
          end
          SetEntityAlpha(entity, 255)
        end
      elseif IsControlJustPressed(0, 73) and DoesEntityExist(entity) then
        if IsEntityAPed(entity) then
          DeletePed(entity)
          if not (DoesEntityExist(entity)) then
            pickedUp = false
            ShowNotification('~g~Success: ~s~Ped deleted.')
          end
        elseif IsEntityAnObject(entity) then
          SetEntityAsMissionEntity(entity, true, true)
          DeleteObject(entity)
          if not (DoesEntityExist(entity)) then
            pickedUp = false
            ShowNotification('~g~Success: ~s~Object deleted.')
          end
        elseif IsEntityAVehicle(entity) then
          SetEntityAsMissionEntity(entity, true, true)
          DeleteVehicle(entity)
          if not (DoesEntityExist(entity)) then
            pickedUp = false
            ShowNotification('~g~Success: ~s~Vehicle deleted.')
          end
        else
          DeleteEntity(entity)
          if not (DoesEntityExist(entity)) then
            pickedUp = false
            ShowNotification('~g~Success: ~s~Entity deleted.')
          end
        end
      elseif IsControlJustPressed(0, 51) then
        local playerCoords = GetEntityCoords(PlayerPedId(), false)
        local entityCoords = GetEntityCoords(entity, false)
        persistentAttach.difference = GetDistanceBetweenCoords(
          playerCoords.x, playerCoords.y, playerCoords.z, entityCoords.x, entityCoords.y, entityCoords.z
        )
      end
    end
  end
end)

-- taser laser
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    for serverId in pairs(showTaserLaserPlayers) do
      local playerPed = GetPlayerPed(GetPlayerFromServerId(serverId))
      local _, currentWeapon = GetCurrentPedWeapon(playerPed)
      if currentWeapon == GetHashKey('WEAPON_STUNGUN') then
        local rot = GetGameplayCamRot()
        local fixedRotX = (math.pi / 180) * rot.x
        local fixedRotZ = (math.pi / 180) * rot.z
        local offset = GetOffsetFromEntityInWorldCoords(GetCurrentPedWeaponEntityIndex(playerPed), .0, .0, .0)
        local rayHandle = StartShapeTestRay(
          offset.x, offset.y, offset.z,
          offset.x + (-math.sin(fixedRotZ) * math.abs(math.cos(fixedRotX))) * 15000,
          offset.y + (math.cos(fixedRotZ) * math.abs(math.cos(fixedRotX))) * 15000,
          offset.z + math.sin(fixedRotX) * 15000,
          -1, playerPed, 1
        )
        local _, hit, coords = GetShapeTestResult(rayHandle)
        if hit == 1 then
          DrawMarker(
            28, coords.x, coords.y, coords.z, .0, .0, .0, .0, .0, .0, .014, .014, .014, 255, 0, 0, 210, false, false, 2, nil, nil, false
          )
        end
      end
    end
  end
end)

-- synchronise vehicle weapon
--- Automatically pulls out the last weapon the player selected when in a vehicle.
--- Will not automatically pull out the last weapon if the player entered the vehicle with a large weapon.
Citizen.CreateThread(function()
  local lastHash
  local lastNotInVehicle = true
  local lastNotInVehicleHash
  local switchedWeapon
  while true do
    Citizen.Wait(1)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped) then
      if lastNotInVehicle then
        SetCurrentPedWeapon(ped, lastNotInVehicleHash, true)
        lastHash = lastNotInVehicleHash
      else
        local _, hash = GetCurrentPedWeapon(ped)
        if hash ~= lastHash then
          Citizen.Wait(1)
          switchedWeapon = true
          SetCurrentPedWeapon(ped, hash, true)
          lastHash = hash
        end
      end
      lastNotInVehicle = false
    else
      if not lastNotInVehicle and lastNotInVehicleHash ~= GetHashKey('WEAPON_UNARMED') and (not CanUseWeaponOnParachute(lastNotInVehicleHash) or not switchedWeapon) then
        SetCurrentPedWeapon(ped, lastNotInVehicleHash, true)
      end
      _, lastNotInVehicleHash = GetCurrentPedWeapon(ped)
      switchedWeapon = false
      lastNotInVehicle = true
    end
    GetCurrentPedVehicleWeapon(ped)
  end
end)

-- set players in vehicle shootable
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped) then
      local veh = GetVehiclePedIsIn(ped)
      local seats = GetVehicleModelNumberOfSeats(veh)
      for i = 1, seats do
        local vehPed = GetPedInVehicleSeat(veh, i - 2)
        if vehPed ~= 0 then
          SetPedCanBeShotInVehicle(vehPed, true)
        end
      end
    end
  end
end)

-- hide the hud
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    -- next-line removes the in-game weapon reticle
    HideHudComponentThisFrame(14)
    if hideHud then
      for i = 1, 22 do
        HideHudComponentThisFrame(i)
        HideScriptedHudComponentThisFrame(i)
      end
      HideHudComponentThisFrame(141)
      HideScriptedHudComponentThisFrame(141)
      HideAreaAndVehicleNameThisFrame()
      HideHelpTextThisFrame()
    end
  end
end)

-- reduce the traffic and crowd density
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1) -- wait a tick
    SetPedDensityMultiplierThisFrame(Config.ServerDensity)
    SetVehicleDensityMultiplierThisFrame(Config.ServerDensity)
  end
end)

-- sticky wheels (keeps them in same position)
Citizen.CreateThread(function()
  local vehicle
  local angle
  while true do
    Citizen.Wait(1)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped) then
      vehicle = GetVehiclePedIsIn(ped)
      local current = GetVehicleSteeringAngle(vehicle)
      if current > 20 then
        angle = 40.0
      elseif current < -20 then
        angle = -40.0
      elseif current > 5 or current < -5 then
        angle = current
      end
    end

    if angle and vehicle and DoesEntityExist(vehicle) and (IsPedOnFoot(ped) or IsPedStopped(ped)) then
      SetVehicleSteeringAngle(vehicle, angle)
    end
  end
end)

-- simple gas mask
Citizen.CreateThread(function()
  local last
  while true do
    Citizen.Wait(100)
    local ped = PlayerPedId()
    -- 46 is the id of gasmak variation
    current = GetPedDrawableVariation(ped, 1) == 46
    if current ~= last then
      local _, a, b, c, d, e, f = GetEntityProofs(ped)
      SetEntityProofs(ped, a, b, c, d, e, f, current, current)
      last = current
    end
  end
end)

-- infinite fire extinguisher
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(30000)
    SetAmmoInClip(PlayerPedId(), GetHashKey('WEAPON_FIREEXTINGUISHER'), 2000)
  end
end)

-- leave engine running
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    local ped = PlayerPedId()

    if DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) and IsControlPressed(2, 75) and not IsEntityDead(ped) and not IsPauseMenuActive() then
      Citizen.Wait(200)
      if IsPedInAnyVehicle(ped, false) and IsControlPressed(2, 75) and not IsEntityDead(ped) then
        local vehicle = GetVehiclePedIsIn(ped, true)
        SetVehicleEngineOn(vehicle, true, true, false)
        TaskLeaveVehicle(ped, vehicle, 0)
      end
    end
  end
end)


-- commands


RegisterFrameworkCommand('point', function()
  RequestAnimDict('anim@mp_point')
  while not HasAnimDictLoaded('anim@mp_point') do
    Wait(50)
  end

  local ped = PlayerPedId();
  if IsTaskMoveNetworkActive(ped) then
    ClearPedSecondaryTask(ped)
  else
    TaskMoveNetworkByName(ped, 'task_mp_pointing', .5, true, 'anim@mp_point', 24)
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

  TriggerServerEvent('chat:addPrivateMessage', serverId, {
    args = {
      string.format(Constants.Format.PM, GetPlayerName(player), 'You'), argMessage
    }
  })
  TriggerEvent('chat:addMessage', { args = { string.format(Constants.Format.PM, 'You', GetPlayerName(player)), argMessage } })
end, false)

RegisterFrameworkCommand('discord', function()
  exports.copyutil:Copy(Constants.DiscordInvite)
  TriggerEvent('chat:addMessage', {
    args = { '^*Copied to Clipboard! >> ^5^_' .. Constants.DiscordInvite },
    color = { 245, 191, 66 },
  })
end, false)

RegisterFrameworkCommand({ 'dv', 'delveh' }, function()
  local ped = GetPlayerPed(-1)
  local vehicle = GetVehiclePedIsInOrNear(ped, false)
  if vehicle and vehicle > 1 then
    if IsPedSittingInVehicle(ped, vehicle) and not GetPedInVehicleSeat(vehicle, -1) == ped then
      ShowNotification('~r~Error: ~s~You must be the driver of the vehicle.')
    else
      SetEntityAsMissionEntity(vehicle, true, true)
      DeleteVehicle(vehicle)
      if not (DoesEntityExist(vehicle)) then
        ShowNotification('~g~Success: ~s~Vehicle deleted.')
      end
    end
  else
    ShowNotification('~r~Error: ~w~You must be close to or in a vehicle.')
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
  else
    local ped = PlayerPedId()
    ClearPedBloodDamage(ped)
    ClearPedWetness(ped)
    ClearPedEnvDirt(ped)
    ResetPedVisibleDamage(ped)
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
      Wait(1e3)
      SetVehicleDoorOpen(vehicle, 4, true, false)
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
      Wait(1e3)
      SetVehicleDoorOpen(vehicle, 5, true, false)
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
      Wait(1e3)
      SetVehicleDoorOpen(vehicle, door, true, false)
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

RegisterFrameworkCommand('taserlaser', function(source, args, raw)
  local _, currentWeapon = GetCurrentPedWeapon(PlayerPedId())
  if currentWeapon == GetHashKey('WEAPON_STUNGUN') then
    if taserLaserState then
      taserLaserState = false
      ShowNotification('~y~Taser~s~: Laser ~r~deactivated~s~.')
    else
      taserLaserState = true
      ShowNotification('~y~Taser~s~: Laser ~g~activated~s~.')
    end
    TriggerServerEvent('framework:taserLaserSet', taserLaserState)
  end
end)

RegisterFrameworkCommand({ 'heal', 'health' }, function(source, args, raw)
  local amount = (tonumber(args[1]) or 5) * 40
  if not IsPlayerDead(PlayerId()) then
    if amount > 200 then amount = 200
    elseif amount < 0 then amount = 0 end
    SetEntityHealth(PlayerPedId(), amount)
  end
end)

RegisterFrameworkCommand({ 'armour', 'armor' }, function(source, args, raw)
  local amount = (tonumber(args[1]) or 5) * 20
  if not IsPlayerDead(PlayerId()) then
    if amount > 100 then amount = 100
    elseif amount < 0 then amount = 0 end
    SetPedArmour(PlayerPedId(), amount)
  end
end)

RegisterKeyMapping('crouch', 'Crouch down to your knees', 'keyboard', 'lcontrol')
RegisterKeyMapping('crouch', 'Crouch down to your knees', 'keyboard', 'lcontrol')
RegisterFrameworkCommand({ 'crouch', 'cr' }, function(source, args, raw)
  DisableControlAction(0, 36, true)
  local ped = PlayerPedId()
  if DoesEntityExist(ped) and not IsEntityDead(ped) and not IsPedInAnyVehicle(ped) then
    RequestAnimSet('move_ped_crouched')
    while not HasAnimSetLoaded('move_ped_crouched') do
      Citizen.Wait(50)
    end

    SetPedStealthMovement(ped, 0)
    if isCrouching then
      if IsControlPressed(0, 21) then
        ResetPedMovementClipset(ped, .2)
      else
        ResetPedMovementClipset(ped, .3)
      end
      isCrouching = false
    else
      if IsControlPressed(0, 21) then
        SetPedMovementClipset(ped, 'move_ped_crouched', .2)
      else
        SetPedMovementClipset(ped, 'move_ped_crouched', .3)
      end
      isCrouching = true
    end
  end
end)

RegisterKeyMapping('stealth', 'Toggle stealth mode', 'keyboard', 'rcontrol')
RegisterFrameworkCommand({ 'stealth', 'duck' }, function(source, args, raw)
  local ped = PlayerPedId()
  if GetPedStealthMovement(ped) == 1 then
    SetPedStealthMovement(ped, 0)
  else
    SetPedStealthMovement(ped, 'DEFAULT_ACTION')
  end
end)

RegisterFrameworkCommand('hud', function(source, args, raw)
  if hideHud then
    ShowNotification('~y~HUD~s~ now ~g~visible~s~.')
    hideHud = false
    DisplayRadar(true)
  else
    ShowNotification('~y~HUD~s~ now ~r~hidden~s~.')
    hideHud = true
    DisplayRadar(false)
  end
end)

RegisterFrameworkCommand({ 'engine', 'eng' }, function(source, args, raw)
  local ped = PlayerPedId()
  if IsPedInAnyVehicle(ped) then
    local vehicle = GetVehiclePedIsIn(ped)
    local on = GetIsVehicleEngineRunning(vehicle)
    SetVehicleEngineOn(vehicle, not on, false, true)
  end
end)

RegisterFrameworkCommand({ 'handsup', 'hu' }, function(source, args, raw)
  local ped = PlayerPedId()
  if DoesEntityExist(ped) and not IsEntityDead(ped) then
    Citizen.CreateThread(function()
      RequestAnimDict('random@getawaydriver')
      while not HasAnimDictLoaded('random@getawaydriver') do
        Citizen.Wait(50)
      end

      if handsUp then
        -- playing anim and waiting 1 tick fixes unclearable anim union
        TaskPlayAnim(ped, 'random@getawaydriver', 'idle_2_hands_up', 8.0, -8, -1, 50, 0)
        Citizen.Wait(1)
        ClearPedSecondaryTask(ped)
        handsUp = false
      else
        TaskPlayAnim(ped, 'random@getawaydriver', 'idle_2_hands_up', 8.0, -8, -1, 50, 0)
        handsUp = true
      end
    end)
  end
end)

RegisterFrameworkCommand({ 'handsupkneel', 'huk' }, function(source, args, raw)
  local ped = PlayerPedId()
  if DoesEntityExist(ped) and not IsEntityDead(ped) then
    Citizen.CreateThread(function()
      RequestAnimDict('random@getawaydriver')
      while not HasAnimDictLoaded('random@getawaydriver') do
        Citizen.Wait(50)
      end

      if IsEntityPlayingAnim(ped, 'random@getawaydriver', 'idle_a', 3) then
        local arrested = IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3)
        StopAnimTask(ped, 'random@getawaydriver', 'idle_a', 3)
        StopAnimTask(ped, 'random@getawaydriver', 'idle_2_hands_up', 3)
        TaskPlayAnim(ped, 'random@getawaydriver', 'hands_up_2_idle', 1.0, -1, -1, 0, 0)
        ClearPedSecondaryTask(ped)
        if arrested then
          TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0)
        end
      else
        TaskPlayAnim(ped, 'random@getawaydriver', 'idle_2_hands_up', 1.0, -1, -1, 0, 0)
        Citizen.Wait(3500)
        TaskPlayAnim(ped, 'random@getawaydriver', 'idle_a', 1.0, -1, -1, 1, 0)
      end
    end)
  end
end)

RegisterFrameworkCommand('radioloud', function(source, args, raw)
  local ped = PlayerPedId()
  if IsPedInAnyVehicle(ped) then
    local vehicle = GetVehiclePedIsIn(ped)
    if IsVehicleRadioLoud(vehicle) then
      SetVehicleRadioLoud(vehicle, false)
    else
      SetVehicleRadioLoud(vehicle, true)
    end
  end
end)

RegisterFrameworkCommand('fuel', function(source, args, raw)
  local ped = PlayerPedId()
  if IsPedInAnyVehicle(ped) and DecorIsRegisteredAsType('_Fuel_Level', 1) then
    local vehicle = GetVehiclePedIsIn(ped)
    local max = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')
    local amount = (tonumber(args[1]) or 5) * max / 5.0 -- ensures it's a float lol
    if amount > max then amount = max
    elseif amount < 0.0 then amount = 0.0 end
    DecorSetFloat(vehicle, '_Fuel_Level', amount)
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
  if
    player == client or #(
      GetEntityCoords(GetPlayerPed(client)) - GetEntityCoords(GetPlayerPed(player))
    ) < Constants.ProximityMessageDistance
  then
    TriggerEvent('chat:addMessage', message)
  end
end)

RegisterNetEvent('framework:physgunToggle', function()
  usePhysgun = not usePhysgun
  if usePhysgun then
    ShowNotification('~y~Admin~s~: Physgun ~g~enabled~s~.')
  else
    ShowNotification('~y~Admin~s~: Physgun ~r~disabled~s~.')
  end
end)

RegisterNetEvent('framework:physgunAttach', function(serverId, detach)
  if detach then
    persistentAttach:remove()
  else
    persistentAttach:add(PlayerPedId(), GetPlayerPed(GetPlayerFromServerId(serverId)))
  end
end)

RegisterNetEvent('framework:taserLaserRender', function(serverId)
  showTaserLaserPlayers[serverId] = true
end)

RegisterNetEvent('framework:taserLaserRenderStop', function(serverId)
  showTaserLaserPlayers[serverId] = nil
end)

RegisterNetEvent('framework:printCurrentVehicleName', function(serverId)
  local vehicle = GetVehiclePedIsInOrNear(PlayerPedId(), true)
  local code = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
  print(code)
  exports.copyutil:Copy(code)
  TriggerEvent('chat:addMessage', {
    color = true,
    args = {
      Constants.SystemPrefix,
      '(Copied): ' .. code
    },
  })
end)

RegisterNetEvent('framework:setConfig', function(conf)
  Config = conf
end)

TriggerServerEvent('framework:requestConfig')

-- util

function persistentAttach:add(entity, target)
  persistentAttach.entity = entity
  local entityCoords = GetEntityCoords(entity, false)
  local targetCoords = GetEntityCoords(target, false)
  persistentAttach.difference = GetDistanceBetweenCoords(
    entityCoords.x, entityCoords.y, entityCoords.z, targetCoords.x, targetCoords.y, targetCoords.z
  )
  Citizen.CreateThread(function()
    while persistentAttach.entity == entity do
      Citizen.Wait(1)
      if not NetworkHasControlOfEntity(entity) then NetworkRequestControlOfEntity(entity) end
      AttachEntityToEntity(
        entity, target, GetPedBoneIndex(target, 28422), persistentAttach.difference, .0, .0, -78.5, .0, .0, true, true, false, true,
        false, true
      )
    end
    DetachEntity(entity, true, false)
  end)
end

function persistentAttach:remove()
  persistentAttach.entity = nil
end

function GetVehiclePedIsInOrNear(ped, lastVehicle)
  local vehicle = GetVehiclePedIsIn(ped, lastVehicle)
  if vehicle and vehicle > 1 then
    return vehicle
  else
    local position = GetEntityCoords(ped)
    local front = GetOffsetFromEntityInWorldCoords(ped, .0, 3.5, -.5)
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

function IsHudHidden()
  return hideHud
end

function ShowNotification(message)
  SetNotificationTextEntry('STRING')
  AddTextComponentSubstringPlayerName(message)
  DrawNotification(true, true)
end