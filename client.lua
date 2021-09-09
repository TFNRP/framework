-- vars
local isOnDuty = false

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

RegisterNetEvent('leo:dutyChange')
AddEventHandler('leo:dutyChange', function (bool)
    if bool == true then
        isOnDuty = true
        ShowNotification('You are now ~g~on~s~ duty.')
    else
        isOnDuty = false
        ShowNotification('You are now ~r~off~s~ duty.')
    end

    return isOnDuty
end)

function IsLocalClientOnDuty()
    return isOnDuty
end

function ShowNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(message)
    DrawNotification(true, true)
end