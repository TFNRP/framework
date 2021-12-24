Citizen.CreateThread(function()
  SetDiscordAppId('717427067872084042')
  SetDiscordRichPresenceAsset('icon')
  SetDiscordRichPresenceAssetText('#' .. GetPlayerServerId(PlayerId()))
  SetDiscordRichPresenceAction(1, 'Discord', 'https://discord.gg/7pzuZBY6Mn')
  while true do
    SetDiscordRichPresenceAction(0, 'Connect (' .. #GetActivePlayers() .. '/64)', 'https://cfx.re/join/734okr')
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local onDuty = exports.framework:GetLocalClientDuty() > 0
    local streetName = GetStreetNameFromHashKey(streetHash)
    if streetName then
      if IsEntityInWater(ped) then
        local height = GetEntityHeightAboveGround(ped)
        if height < -50.0 then
          SetRichPresence('Deep-sea diving')
        elseif height < -10.0 then
          SetRichPresence('Diving')
        elseif height < -1.0 then
          SetRichPresence('Underwater')
        else
          SetRichPresence('Taking a swim')
        end
      elseif IsPedOnFoot(ped) then
        if IsPedSprinting(ped) then
          SetRichPresence('Sprinting down ' .. streetName)
        elseif IsPedRunning(ped) then
          SetRichPresence('Running down ' .. streetName)
        elseif IsPedWalking(ped) then
          SetRichPresence('Walking down ' .. streetName)
        elseif IsPedStill(ped) then
          SetRichPresence('Standing on ' .. streetName)
        end
      elseif IsPedInAnyHeli(ped) or IsPedInAnyPlane(ped) then
        local vehicle = GetVehiclePedIsIn(ped)
        if GetEntityHeightAboveGround(vehicle) > 5.0 then
          SetRichPresence('Flying over ' .. streetName)
        elseif GetEntitySpeed(vehicle) > 2.239 then
          SetRichPresence('Taxiing at ' .. streetName)
        else
          SetRichPresence('Landed at ' .. streetName)
        end
      elseif IsPedInAnyBoat(ped) then
        local vehicle = GetVehiclePedIsIn(ped)
        if IsEntityInWater(vehicle) then
          if GetEntityHeightAboveGround(vehicle) < -5.0 then
            SetRichPresence('Sinking')
          else
            SetRichPresence('Sailing')
          end
        else
          SetRichPresence('Beached')
        end
      elseif IsPedInAnySub(ped) then
        if IsEntityInWater(GetVehiclePedIsIn(ped)) then
          SetRichPresence('Sailing')
        else
          SetRichPresence('Parked vessel')
        end
      elseif IsPedInAnyVehicle(ped) then
        local vehicle = GetVehiclePedIsIn(ped)
        local speed = GetEntitySpeed(vehicle)
        if speed > 22.352 then
          SetRichPresence('Speeding down ' .. streetName)
        elseif speed > 0.22352 then
          if onDuty then
            SetRichPresence('Patrolling on ' .. streetName)
          else
            SetRichPresence('Driving on ' .. streetName)
          end
        else
          if GetIsVehicleEngineRunning(vehicle) then
            SetRichPresence('Stationary on ' .. streetName)
          else
            SetRichPresence('Parked on ' .. streetName)
          end
        end
      end
    end
    Citizen.Wait(5e3)
  end
end)