-- vars
local isOnDuty = false
local isPointing = false

-- suggestions

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/duty', 'Toggle on/off duty.')
    TriggerEvent('chat:addSuggestion', '/offduty', 'Disable patrolman duties.')
    TriggerEvent('chat:addSuggestion', '/onduty', 'Enable patrolman duties.')
end)

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

    print(serverId, clientId)

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
    if (IsPedSittingInAnyVehicle(ped)) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        if (GetPedInVehicleSeat(vehicle, -1) == ped) then
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
            if not (DoesEntityExist(vehicle)) then
                ShowNotification("~g~Success: ~s~Vehicle deleted.")
            end
        else
            ShowNotification("~r~Error: ~s~You must be the driver of the vehicle.")
        end
    else
        local position = GetEntityCoords(ped)
        local front = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 2.0, 0.0)
        local rayHandle = CastRayPointToPoint(position.x, position.y, position.z, front.x, front.y, front.z, 10, ped, 0)
        local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
        if (DoesEntityExist(vehicle)) then
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
            if not (DoesEntityExist(vehicle)) then
                ShowNotification("~g~Success: ~s~Vehicle deleted.")
            end
        else
            ShowNotification("~r~Error: ~w~You must be close to or in a vehicle.")
        end
    end
end)


-----/


RegisterNetEvent('leo:dutyChange', function (bool)
    if bool == true then
        isOnDuty = true
        ShowNotification('You are now ~g~on~s~ duty.')
    else
        isOnDuty = false
        ShowNotification('You are now ~r~off~s~ duty.')
    end

    return isOnDuty
end)

RegisterNetEvent('chat:addProximityMessage', function (serverId, message)
    local player = GetPlayerFromServerId(serverId)
    local client = PlayerId()
    if player == client or GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(client)), GetEntityCoords(GetPlayerPed(player)), true) < Constants.ProximityMessageDistance then
        TriggerEvent('chat:addMessage', message)
    end
end)

-- util

function CommandWarning(message)
    TriggerEvent('chat:addMessage', { args = { message } })
end

function IsLocalClientOnDuty()
    return isOnDuty
end

function ShowNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(message)
    DrawNotification(true, true)
end