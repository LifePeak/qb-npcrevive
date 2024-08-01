local QBCore = exports['qb-core']:GetCoreObject()
local isTextActive = false
local toggleRange = 2.5
local interactionKey = 38

function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
end

Citizen.CreateThread(function()

    -- Create NPC
    loadModel(Config.NPCModel)
    local npc = CreatePed(4, Config.NPCModel, Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z-1, Config.NPCHeading, false, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedFleeAttributes(npc, 0, 0)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedDiesWhenInjured(npc, false)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)


    -- DistanceCheck
    while true do
        Citizen.Wait(0)
        local plyPosition = GetEntityCoords(PlayerPedId())
        local distance = GetDistanceBetweenCoords(plyPosition, Config.NPCLocation, true)
        if distance <= toggleRange then
            if not isTextActive then
                isTextActive = true
                showIntegration()
            end
            if IsControlJustPressed(0, 38) then
                print("Pressed")
                openReviveMenu()
            end
        elseif distance > toggleRange and isTextActive then
            isTextActive = false
            hideIntegration()
        end
    end
end)

function showIntegration()
    exports['qb-core']:DrawText('Drücke [E] zum interagieren', 'left')
end

function hideIntegration()
    exports['qb-core']:HideText()
end

function openReviveMenu()
    local menuItems = {}
    local revivablePlayers = nil
    menuItems[#menuItems + 1] = { -- create non-clickable header button
        isMenuHeader = true,
        header = 'QBCore Test Loop Menu',
        icon = 'fa-solid fa-infinity'
    }

    QBCore.Functions.TriggerCallback(Config.callbackGetReviveablePlayers, function(data)
        Citizen.Wait(2000)
        if data == nil then print("ERROR") end
        if data == false then
            QBCore.Functions.Notify("Kein Spieler verfügbar", "primary", 3000)
            return 
        end
        print(json.encode(data))
        revivablePlayers = data
    end)

    Citizen.CreateThread(function()
        -- Wait until the data is received
        while revivablePlayers == nil do
            Citizen.Wait(0) -- Yield to prevent blocking
        end

        -- If no players are available, no need to open the menu
        if revivablePlayers == false then
            return
        end

        -- Now that we have the data, we can construct the menu
        for k, player in pairs(revivablePlayers) do
            menuItems[#menuItems + 1] = {
                header = player.name,  -- Display the player's name
                txt = "Player ID: " .. player.source, -- You can adjust this text as needed
                icon = 'fa-solid fa-face-grin-tears',
                params = {
                    event = Config.eventRequestRevive, -- Event name to trigger
                    args = {
                        source = player.source, -- Player ID
                    }
                }
            }
        end

        -- Open the menu with the populated items
        exports['qb-menu']:openMenu(menuItems)
    end)
end

RegisterNetEvent(Config.eventRequestRevive)
AddEventHandler(Config.eventRequestRevive, function(playerId)
    QBCore.Functions.TriggerCallback(Config.callbackRevivePlayer, function(data)
        if data == nil then print("ERROR") end
        if data ~= ReturnCodes.SUCCESS then
            sendErrorMessage(data)
            return
        end
        QBCore.Functions.Notify("Spieler wiederbelebt", "success", 3000)
    end, playerId)
end)

function sendErrorMessage(error_code)
    if error_code == ReturnCodes.NOT_ENOUGH_MONEY then
        QBCore.Functions.Notify("Nicht genug Geld", "error", 3000)
    elseif error_code == ReturnCodes.MEDICS_ARE_ONLINE then
        QBCore.Functions.Notify("Sanitäter sind online", "error", 3000)
    elseif error_code == ReturnCodes.PLAYER_NOT_REVIVABLE then
        QBCore.Functions.Notify("Spieler nicht wiederbelebbar", "error", 3000)
    end
end