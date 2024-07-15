local QBCore = exports['qb-core']:GetCoreObject() -- Ensure this is correctly referencing the QBCore object

local cartridges = Config.MaxCartridges
local NoCartgridgesMessage = false
local cartridgesin = true
local SpamCooldownPressed = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_STUNGUN') then
            if cartridgesin == false then
                if IsControlJustReleased(0, Config.ReloadKey) then
                    if SpamCooldownPressed == false then
                        if Config.Debug == true then
                            print('Debug Pressed R')
                        end
                        SpamCooldownPressed = true
                        TriggerServerEvent('checkTaserCartridges')
                    else
                        QBCore.Functions.Notify('Broo, Chill', 'error', 3000)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('reloadTaser')
AddEventHandler('reloadTaser', function(hasCartridge)
    if hasCartridge then
        cartridgesin = true
        cartridges = Config.MaxCartridges
        QBCore.Functions.Notify('Taser Reloaded', 'success', 3000)
        NoCartgridgesMessage = false
        TriggerEvent('playReloadAnimation')  -- Trigger the reload animation
        TriggerEvent('spam')
    else
        QBCore.Functions.Notify('There are no Cartridges left.', 'error', 3000)
        TriggerEvent('spam')
    end
end)

RegisterNetEvent('spam')
AddEventHandler('spam', function()
    Citizen.Wait(Config.SpamCooldown)
    SpamCooldownPressed = false
    if Config.Debug == true then
        print('Spam Protection Deactivated')
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_STUNGUN') then
            if cartridges <= 0 then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 257, true) 
                DisableControlAction(0, 142, true) 
                SetPedInfiniteAmmo(PlayerPedId(), false, GetHashKey('WEAPON_STUNGUN'))
                if NoCartgridgesMessage == false then
                    cartridgesin = false
                    NoCartgridgesMessage = true
                    QBCore.Functions.Notify('Out of cartridges! Press R to reload.', 'error', 3000)
                end
            end
        end
        if IsPedShooting(PlayerPedId()) and GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_STUNGUN') then
            if cartridges > 0 then
                cartridges = cartridges - 1
                if NoCartgridgesMessage == false then
                    if cartridges <= 0 then
                        cartridgesin = false
                        NoCartgridgesMessage = true
                        QBCore.Functions.Notify('Out of cartridges! Press R to reload.', 'error', 3000)
                    end
                end
            end
        end
    end
end)

-- Function to play reload animation
RegisterNetEvent('playReloadAnimation')
AddEventHandler('playReloadAnimation', function()
    local playerPed = PlayerPedId()
    local animDict = 'anim@cover@weapon@reloads@pistol@revolver'  -- Replace with the correct animation dictionary
    local animName = 'reload_low_left'  -- Replace with the correct animation name

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 48, 0, false, false, false)
    
    Citizen.Wait(2000)  -- Wait for the animation to finish (adjust the duration as needed)
    
    ClearPedTasks(playerPed)  -- Clear the animation
    RemoveAnimDict(animDict)
end)
