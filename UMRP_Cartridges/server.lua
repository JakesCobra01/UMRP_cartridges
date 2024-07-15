local ox_inventory = exports['ox_inventory'] -- Adjust this to match your actual resource name

RegisterServerEvent('checkTaserCartridges')
AddEventHandler('checkTaserCartridges', function()
    local _source = source
    local hasCartridge = false

    -- Ensure ox_inventory is properly initialized and accessible
    if ox_inventory then
        -- Replace 'water' with the actual item name used in ox-inventory
        local item = ox_inventory:GetItem(_source, 'taser_cartridge', nil, false)

        if item then
            -- Modify this part to reflect how your inventory system works
            if item.count > 0 then
                -- Remove the item from the inventory
                ox_inventory:RemoveItem(_source, 'taser_cartridge', 1)
                hasCartridge = true
            end
        end
    else
        print("ox_inventory is not loaded or accessible.")
    end

    -- Trigger the client event with the result
    TriggerClientEvent('reloadTaser', _source, hasCartridge)
end)
