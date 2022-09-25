-- Event Handler

AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()
        return
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if not PSRCore.Players[src] then return end
    local Player = PSRCore.Players[src]
    TriggerEvent('psr-log:server:CreateLog', 'joinleave', 'Dropped', 'red', '**' .. GetPlayerName(src) .. '** (' .. Player.PlayerData.license .. ') left..' ..'\n **Reason:** ' .. reason)
    Player.Functions.Save()
    PSRCore.Player_Buckets[Player.PlayerData.license] = nil
    PSRCore.Players[src] = nil
end)

-- Player Connecting

local function onPlayerConnecting(name, _, deferrals)
    local src = source
    local license
    local identifiers = GetPlayerIdentifiers(src)
    deferrals.defer()

    -- Mandatory wait
    Wait(0)

    if PSRCore.Config.Server.Closed then
        if not IsPlayerAceAllowed(src, 'psradmin.join') then
            deferrals.done(PSRCore.Config.Server.ClosedReason)
        end
    end

    deferrals.update(string.format(Lang:t('info.checking_ban'), name))

    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    -- Mandatory wait
    Wait(2500)

    deferrals.update(string.format(Lang:t('info.checking_whitelisted'), name))

    local isBanned, Reason = PSRCore.Functions.IsPlayerBanned(src)
    local isLicenseAlreadyInUse = PSRCore.Functions.IsLicenseInUse(license)
    local isWhitelist, whitelisted = PSRCore.Config.Server.Whitelist, PSRCore.Functions.IsWhitelisted(src)

    Wait(2500)

    deferrals.update(string.format(Lang:t('info.join_server'), name))

    if not license then
      deferrals.done(Lang:t('error.no_valid_license'))
    elseif isBanned then
        deferrals.done(Reason)
    elseif isLicenseAlreadyInUse and PSRCore.Config.Server.CheckDuplicateLicense then
        deferrals.done(Lang:t('error.duplicate_license'))
    elseif isWhitelist and not whitelisted then
      deferrals.done(Lang:t('error.not_whitelisted'))
    end

    deferrals.done()

    -- Add any additional defferals you may need!
end

AddEventHandler('playerConnecting', onPlayerConnecting)

-- Open & Close Server (prevents players from joining)

RegisterNetEvent('PSRCore:Server:CloseServer', function(reason)
    local src = source
    if PSRCore.Functions.HasPermission(src, 'admin') then
        reason = reason or 'No reason specified'
        PSRCore.Config.Server.Closed = true
        PSRCore.Config.Server.ClosedReason = reason
        for k in pairs(PSRCore.Players) do
            if not PSRCore.Functions.HasPermission(k, PSRCore.Config.Server.WhitelistPermission) then
                PSRCore.Functions.Kick(k, reason, nil, nil)
            end
        end
    else
        PSRCore.Functions.Kick(src, Lang:t("error.no_permission"), nil, nil)
    end
end)

RegisterNetEvent('PSRCore:Server:OpenServer', function()
    local src = source
    if PSRCore.Functions.HasPermission(src, 'admin') then
        PSRCore.Config.Server.Closed = false
    else
        PSRCore.Functions.Kick(src, Lang:t("error.no_permission"), nil, nil)
    end
end)

-- Callback Events --

-- Client Callback
RegisterNetEvent('PSRCore:Server:TriggerClientCallback', function(name, ...)
    if PSRCore.ClientCallbacks[name] then
        PSRCore.ClientCallbacks[name](...)
        PSRCore.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
RegisterNetEvent('PSRCore:Server:TriggerCallback', function(name, ...)
    local src = source
    PSRCore.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('PSRCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

-- Player

RegisterNetEvent('PSRCore:UpdatePlayer', function()
    local src = source
    local Player = PSRCore.Functions.GetPlayer(src)
    if not Player then return end
    local newHunger = Player.PlayerData.metadata['hunger'] - PSRCore.Config.Player.HungerRate
    local newThirst = Player.PlayerData.metadata['thirst'] - PSRCore.Config.Player.ThirstRate
    if newHunger <= 0 then
        newHunger = 0
    end
    if newThirst <= 0 then
        newThirst = 0
    end
    Player.Functions.SetMetaData('thirst', newThirst)
    Player.Functions.SetMetaData('hunger', newHunger)
    TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, newThirst)
    Player.Functions.Save()
end)

RegisterNetEvent('PSRCore:Server:SetMetaData', function(meta, data)
    local src = source
    local Player = PSRCore.Functions.GetPlayer(src)
    if not Player then return end
    if meta == 'hunger' or meta == 'thirst' then
        if data > 100 then
            data = 100
        end
    end
    Player.Functions.SetMetaData(meta, data)
    TriggerClientEvent('hud:client:UpdateNeeds', src, Player.PlayerData.metadata['hunger'], Player.PlayerData.metadata['thirst'])
end)

RegisterNetEvent('PSRCore:ToggleDuty', function()
    local src = source
    local Player = PSRCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('PSRCore:Notify', src, Lang:t('info.off_duty'))
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('PSRCore:Notify', src, Lang:t('info.on_duty'))
    end
    TriggerClientEvent('PSRCore:Client:SetDuty', src, Player.PlayerData.job.onduty)
end)

-- Items

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon.
RegisterNetEvent('PSRCore:Server:UseItem', function(item)
    print(string.format("%s triggered PSRCore:Server:UseItem by ID %s with the following data. This event is deprecated due to exploitation, and will be removed soon. Check qb-inventory for the right use on this event.", GetInvokingResource(), source))
    PSRCore.Debug(item)
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot)
RegisterNetEvent('PSRCore:Server:RemoveItem', function(itemName, amount)
    local src = source
    print(string.format("%s triggered PSRCore:Server:RemoveItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.", GetInvokingResource(), src, amount, itemName))
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot, info)
RegisterNetEvent('PSRCore:Server:AddItem', function(itemName, amount)
    local src = source
    print(string.format("%s triggered PSRCore:Server:AddItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.", GetInvokingResource(), src, amount, itemName))
end)

-- Non-Chat Command Calling (ex: psr-adminmenu)

RegisterNetEvent('PSRCore:CallCommand', function(command, args)
    local src = source
    if not PSRCore.Commands.List[command] then return end
    local Player = PSRCore.Functions.GetPlayer(src)
    if not Player then return end
    local hasPerm = PSRCore.Functions.HasPermission(src, "command."..PSRCore.Commands.List[command].name)
    if hasPerm then
        if PSRCore.Commands.List[command].argsrequired and #PSRCore.Commands.List[command].arguments ~= 0 and not args[#PSRCore.Commands.List[command].arguments] then
            TriggerClientEvent('PSRCore:Notify', src, Lang:t('error.missing_args2'), 'error')
        else
            PSRCore.Commands.List[command].callback(src, args)
        end
    else
        TriggerClientEvent('PSRCore:Notify', src, Lang:t('error.no_access'), 'error')
    end
end)

-- Use this for player vehicle spawning
-- Vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
PSRCore.Functions.CreateCallback('PSRCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local ped = GetPlayerPed(source)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(ped) end
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then
        while GetVehiclePedIsIn(ped) ~= veh do
            Wait(0)
            TaskWarpPedIntoVehicle(ped, veh, -1)
        end
    end
    while NetworkGetEntityOwner(veh) ~= source do Wait(0) end
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

-- Use this for long distance vehicle spawning
-- vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
PSRCore.Functions.CreateCallback('PSRCore:Server:CreateVehicle', function(source, cb, model, coords, warp)
    model = type(model) == 'string' and GetHashKey(model) or model
    if not coords then coords = GetEntityCoords(GetPlayerPed(source)) end
    local CreateAutomobile = GetHashKey("CREATE_AUTOMOBILE")
    local veh = Citizen.InvokeNative(CreateAutomobile, model, coords, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then TaskWarpPedIntoVehicle(GetPlayerPed(source), veh, -1) end
    cb(NetworkGetNetworkIdFromEntity(veh))
end)