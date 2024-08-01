local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback(Config.callbackGetReviveablePlayers, function(source, cb)
    --rangecheck
    local players = QBCore.Functions.GetQBPlayers()
    local revivablePlayers = {}

    for _,player in pairs(players) do
        local playerSource = player.PlayerData.source
        if true == true then
        --if playerSource ~= source then -- Check if its own source
            local playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
            if isPlayerRevivable(playerSource) then
                table.insert(revivablePlayers, {source = playerSource, name = playerName})
            end
        end
    end

    if (#revivablePlayers <= 0) then
        cb({})
    end

    QBCore.Debug(revivablePlayers)
    
    cb(revivablePlayers)
end)

QBCore.Functions.CreateCallback(Config.callbackRevivePlayer, function(source, cb, args)
    -- Is no medic online?
    local medicCount = getMedicCount()
    if medicCount > 0 then
        cb(ReturnCodes.MEDICS_ARE_ONLINE)
        return
    end
    -- Has enough money?
    if not hasEnoughMoney(source) then
        cb(ReturnCodes.NOT_ENOUGH_MONEY)
        return
    end

    -- Is player revivable?
    if not isPlayerRevivable(args.source) then
        cb(ReturnCodes.PLAYER_NOT_REVIVABLE)
        return
    end

    -- Revive player
    local player = QBCore.Functions.GetPlayer(source)
    player.Functions.RemoveMoney('cash', Config.ReviveCost, 'Revive')
    TriggerClientEvent('hospital:client:Revive', args.source)
    TriggerClientEvent("visn_are:resetHealthBuffer", args.source)
    cb(ReturnCodes.SUCCESS)
end)

function getMedicCount()
    local players = QBCore.Functions.GetQBPlayers()
    local medicCount = 0
    for _,player in pairs(players) do
        if player.PlayerData.job.name == Config.MedicJob then
            medicCount = medicCount + 1
        end
    end

    return medicCount
end

function hasEnoughMoney(source)
    local player = QBCore.Functions.GetPlayer(source)
    local money = player.PlayerData.money.cash
    if money < Config.ReviveCost then
        return false
    end

    return true
end

function isPlayerRevivable(source)
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords-Config.NPCLocation)
    if distance > Config.ReviveRange then
        print("ERROR NOT REVIVABLE")
        return false
    end

    --visnare deathcheck
    --local isDead = true
    local isDead = Player(source).state.healthBuffer.unconscious
    if not isDead then
        print("ERROR NOT REVIVABLE - NOT DEAD")
        return false
    end

    return true
end