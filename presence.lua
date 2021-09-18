-- discord presence manager

local WaitTime = 5
local UseKMH = false
local SirenState = 0
local SirenDuration = 0
local IdleDuration = 0
local LightDuration = 0
AddEventHandler('lvc:SetLxSirenState_s2', function(state)
  SirenState = state
end)


SetDiscordAppId(717427067872084042)
SetDiscordRichPresenceAsset('icon')
SetDiscordRichPresenceAction(0, 'Connect', 'https://cfx.re/join/734okr')
SetDiscordRichPresenceAction(1, 'Discord', 'https://discord.gg/7pzuZBY6Mn')
SetRichPresence('Connecting to server...')

Citizen.CreateThread(function()
  SetDiscordAppId(717427067872084042)
  SetDiscordRichPresenceAsset('icon')
  SetDiscordRichPresenceAction(1, 'Discord', 'https://discord.gg/7pzuZBY6Mn')
  while true do
    SetDiscordRichPresenceAction(0, 'Connect ('..#GetActivePlayers()..'/32)', 'https://cfx.re/join/734okr')
    local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
    local StreetHash = GetStreetNameAtCoord(x, y, z)
    local OnDuty = exports.framework:GetLocalClientDuty() > 0
    Citizen.Wait(WaitTime * 1000)
    if StreetHash ~= nil then
      StreetName = GetStreetNameFromHashKey(StreetHash)
      if IsPedOnFoot(PlayerPedId()) and not IsEntityInWater(PlayerPedId()) then
        if IsPedSprinting(PlayerPedId()) then
          if OnDuty then
            SetRichPresence("Foot pursuit on "..StreetName)
          else
            SetRichPresence("Sprinting down "..StreetName)
          end
        elseif IsPedRunning(PlayerPedId()) then
          SetRichPresence("Running down "..StreetName)
        elseif IsPedWalking(PlayerPedId()) then
          SetRichPresence("Walking down "..StreetName)
        elseif IsPedStill(PlayerPedId()) then
          SetRichPresence("Standing on "..StreetName)
        end
      elseif GetVehiclePedIsUsing(PlayerPedId()) ~= nil and not IsPedInAnyHeli(PlayerPedId()) and not IsPedInAnyPlane(PlayerPedId()) and not IsPedOnFoot(PlayerPedId()) and not IsPedInAnySub(PlayerPedId()) and not IsPedInAnyBoat(PlayerPedId()) then
        local VehSpeed = GetEntitySpeed(GetVehiclePedIsUsing(PlayerPedId()))
        local CurSpeed = UseKMH and math.ceil(VehSpeed * 3.6) or math.ceil(VehSpeed * 2.236936)
        if OnDuty then
          if IsVehicleSirenOn(GetVehiclePedIsUsing(PlayerPedId())) then
            LightDuration = LightDuration + WaitTime
            if SirenState > 0 then SirenDuration = SirenDuration + WaitTime else SirenDuration = 0 end
            if SirenState > 0 and SirenDuration > 10 then
              SetRichPresence("Code 3 pursuit on "..StreetName)
            elseif CurSpeed > 50 and LightDuration > 20 then
              SirenDuration = 0
              IdleDuration = 0
              SetRichPresence("Code 2 high-speed pursuit on "..StreetName)
            elseif CurSpeed <= 50 and CurSpeed > 0 then
              SirenDuration = 0
              IdleDuration = 0
              if LightDuration > 30 then
                SetRichPresence("Code 2 low-speed pursuit on "..StreetName)
              else
                SetRichPresence("Pulling someone over on "..StreetName)
              end
            elseif CurSpeed == 0 then
              SirenDuration = 0
              IdleDuration = IdleDuration + WaitTime
              if IdleDuration > 40 and LightDuration > 10 then
                SetRichPresence("Code 4 felony stop on "..StreetName)
              elseif IdleDuration > 10 then
                SetRichPresence("Traffic stop on "..StreetName)
              else
                SetRichPresence("Preparing traffic stop on "..StreetName)
              end
            end
          else
            LightDuration = 0
            if CurSpeed > 50 then
              SetRichPresence("Speeding down "..StreetName)
            elseif CurSpeed <= 50 and CurSpeed > 0 then
              SetRichPresence("Patrolling down "..StreetName)
            elseif CurSpeed == 0 then
              IdleDuration = IdleDuration + WaitTime
              if (IdleDuration > 60) then
                SetRichPresence("Stakeout on "..StreetName)
              else
                SetRichPresence("Parked on "..StreetName)
              end
            end
          end
        elseif CurSpeed > 50 then
          SetRichPresence("Speeding down "..StreetName)
        elseif CurSpeed <= 50 and CurSpeed > 0 then
          SetRichPresence("Cruising down "..StreetName)
        elseif CurSpeed == 0 then
          SetRichPresence("Parked on "..StreetName)
        end
      elseif IsPedInAnyHeli(PlayerPedId()) or IsPedInAnyPlane(PlayerPedId()) then
        if IsEntityInAir(GetVehiclePedIsUsing(PlayerPedId())) or GetEntityHeightAboveGround(GetVehiclePedIsUsing(PlayerPedId())) > 5.0 then
          SetRichPresence("Flying over "..StreetName)
        else
          SetRichPresence("Landed at "..StreetName)
        end
      elseif IsEntityInWater(PlayerPedId()) then
        SetRichPresence("Swimming around")
      elseif IsPedInAnyBoat(PlayerPedId()) and IsEntityInWater(GetVehiclePedIsUsing(PlayerPedId())) then
        SetRichPresence("Sailing around")
      elseif IsPedInAnySub(PlayerPedId()) and IsEntityInWater(GetVehiclePedIsUsing(PlayerPedId())) then
        SetRichPresence("In a submarine")
      end
    end
  end
end)