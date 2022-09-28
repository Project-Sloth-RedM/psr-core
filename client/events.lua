-- Player load and unload handling
-- New method for checking if logged in across all scripts (optional)
-- if LocalPlayer.state['isLoggedIn'] then
RegisterNetEvent('PSRCore:Client:OnPlayerLoaded', function()
    ShutdownLoadingScreenNui()
    LocalPlayer.state:set('isLoggedIn', true, false)
    if QBConfig.EnablePVP then
        Citizen.InvokeNative(0xF808475FA571D823, true)
        SetRelationshipBetweenGroups(5, `PLAYER`, `PLAYER`)
    end
    if QBConfig.Player.RevealMap then
		SetMinimapHideFow(true)
	end
end)

RegisterNetEvent('PSRCore:Client:OnPlayerUnload', function()
    LocalPlayer.state:set('isLoggedIn', false, false)
end)

RegisterNetEvent('QBCore:Client:PvpHasToggled', function(pvp_state)
    NetworkSetFriendlyFireOption(pvp_state)
end)

-- Teleport Commands

RegisterNetEvent('PSRCore:Command:TeleportToPlayer', function(coords) -- #MoneSuer | Fixed Teleport Command
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z) 
end)

RegisterNetEvent('PSRCore:Command:TeleportToCoords', function(x, y, z, h) -- #MoneSuer | Fixed Teleport Command
    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z) 
end)

RegisterNetEvent('PSRCore:Command:GoToMarker', function()
    local PlayerPedId = PlayerPedId
    local GetEntityCoords = GetEntityCoords
    local GetGroundZAndNormalFor_3dCoord = GetGroundZAndNormalFor_3dCoord

    if not IsWaypointActive() then
        PSRCore.Functions.Notify(Lang:t("error.no_waypoint"), "error", 5000)
        return 'marker'
    end

    --Fade screen to hide how clients get teleported.
    DoScreenFadeOut(650)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    local ped, coords <const> = PlayerPedId(), GetWaypointCoords()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local oldCoords <const> = GetEntityCoords(ped)

    -- Unpack coords instead of having to unpack them while iterating.
    -- 825.0 seems to be the max a player can reach while 0.0 being the lowest.
    local x, y, groundZ, Z_START = coords['x'], coords['y'], 850.0, 950.0
    local found = false
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, true)
    else
        FreezeEntityPosition(ped, true)
    end

    for i = Z_START, 0, -25.0 do
        local z = i
        if (i % 2) ~= 0 then
            z = Z_START - i
        end
        Citizen.InvokeNative(0x387AD749E3B69B70, x, y, z, x, y, z, 50.0, 0)
        local curTime = GetGameTimer()
        while Citizen.InvokeNative(0xCF45DF50C7775F2A) do
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        Citizen.InvokeNative(0x5A8B01199C3E79C3)
        SetEntityCoords(ped, x, y, z - 1000)
        while Citizen.InvokeNative(0xCF45DF50C7775F2A) do
            RequestCollisionAtCoord(x, y, z)
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        -- Get ground coord. As mentioned in the natives, this only works if the client is in render distance.
        --found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
        found, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, z)
        if found then
            Wait(0)
            SetEntityCoords(ped, x, y, groundZ)
            break
        end
        Wait(0)
    end

    -- Remove black screen once the loop has ended.
    DoScreenFadeIn(650)
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, false)
    else
        FreezeEntityPosition(ped, false)
    end

    if not found then
        -- If we can't find the coords, set the coords to the old ones.
        -- We don't unpack them before since they aren't in a loop and only called once.
        SetEntityCoords(ped, oldCoords['x'], oldCoords['y'], oldCoords['z'] - 1.0)
        PSRCore.Functions.Notify(Lang:t("error.tp_error"), "error", 5000)
    end

    -- If Z coord was found, set coords in found coords.
    SetEntityCoords(ped, x, y, groundZ)
    PSRCore.Functions.Notify(Lang:t("success.teleported_waypoint"), "success", 5000)
end)

-- Vehicle Commands

RegisterNetEvent('PSRCore:Command:SpawnVehicle', function(vehName)
    local ped = PlayerPedId()
    local hash = GetHashKey(vehName)
    local veh = GetVehiclePedIsUsing(ped)
    if not IsModelInCdimage(hash) then return end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    if IsPedInAnyVehicle(ped) then
        DeleteVehicle(veh)
    end

    local vehicle = CreateVehicle(hash, GetEntityCoords(ped), GetEntityHeading(ped), true, false)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    SetModelAsNoLongerNeeded(hash)
end)

RegisterNetEvent('PSRCore:Command:DeleteVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsUsing(ped)
    if veh ~= 0 then
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
    else
        local pcoords = GetEntityCoords(ped)
        local vehicles = GetGamePool('CVehicle')
        for _, v in pairs(vehicles) do
            if #(pcoords - GetEntityCoords(v)) <= 5.0 then
                SetEntityAsMissionEntity(v, true, true)
                DeleteVehicle(v)
            end
        end
    end
end)

-- Other stuff

RegisterNetEvent('PSRCore:Player:SetPlayerData', function(val)
    PSRCore.PlayerData = val
end)

RegisterNetEvent('PSRCore:Player:UpdatePlayerData', function()
    TriggerServerEvent('PSRCore:UpdatePlayer')
end)

RegisterNetEvent('PSRCore:Notify', function(text, type, length)
    PSRCore.Functions.Notify(text, type, length)
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon.
RegisterNetEvent('PSRCore:Client:UseItem', function(item)
    PSRCore.Debug(string.format("%s triggered PSRCore:Client:UseItem by ID %s with the following data. This event is deprecated due to exploitation, and will be removed soon. Check psr-inventory for the right use on this event.", GetInvokingResource(), GetPlayerServerId(PlayerId())))
    PSRCore.Debug(item)
end)

-- Callback Events --

-- Client Callback
RegisterNetEvent('PSRCore:Client:TriggerClientCallback', function(name, ...)
    PSRCore.Functions.TriggerClientCallback(name, function(...)
        TriggerServerEvent('PSRCore:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- Server Callback
RegisterNetEvent('PSRCore:Client:TriggerCallback', function(name, ...)
    if PSRCore.ServerCallbacks[name] then
        PSRCore.ServerCallbacks[name](...)
        PSRCore.ServerCallbacks[name] = nil
    end
end)

-- Me command

local function Draw3DText(coords, str)
    local onScreen, worldX, worldY = World3dToScreen2d(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoord()
    local scale = 200 / (GetGameplayCamFov() * #(camCoords - coords))
    if onScreen then
        SetTextScale(1.0, 0.5 * scale)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextProportional(1)
        SetTextOutline()
        SetTextCentre(1)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(str)
        EndTextCommandDisplayText(worldX, worldY)
    end
end

RegisterNetEvent('PSRCore:Command:ShowMe3D', function(senderId, msg)
    local sender = GetPlayerFromServerId(senderId)
    CreateThread(function()
        local displayTime = 5000 + GetGameTimer()
        while displayTime > GetGameTimer() do
            local targetPed = GetPlayerPed(sender)
            local tCoords = GetEntityCoords(targetPed)
            Draw3DText(tCoords, msg)
            Wait(0)
        end
    end)
end)

-- Listen to Shared being updated
RegisterNetEvent('PSRCore:Client:OnSharedUpdate', function(tableName, key, value)
    PSRCore.Shared[tableName][key] = value
    TriggerEvent('PSRCore:Client:UpdateObject')
end)

RegisterNetEvent('PSRCore:Client:OnSharedUpdateMultiple', function(tableName, values)
    for key, value in pairs(values) do
        PSRCore.Shared[tableName][key] = value
    end
    TriggerEvent('PSRCore:Client:UpdateObject')
end)
