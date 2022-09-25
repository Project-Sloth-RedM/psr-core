CreateThread(function()
    while true do
        local sleep = 0
        if LocalPlayer.state.isLoggedIn then
            sleep = (1000 * 60) * PSRCore.Config.UpdateInterval
            TriggerServerEvent('PSRCore:UpdatePlayer')
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            if (PSRCore.PlayerData.metadata['hunger'] <= 0 or PSRCore.PlayerData.metadata['thirst'] <= 0) and not PSRCore.PlayerData.metadata['isdead'] then
                local ped = PlayerPedId()
                local currentHealth = GetEntityHealth(ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(ped, currentHealth - decreaseThreshold)
            end
        end
        Wait(PSRCore.Config.StatusInterval)
    end
end)
