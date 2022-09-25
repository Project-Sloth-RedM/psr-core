PSRCore = {}
PSRCore.Config = PSRConfig
PSRCore.Shared = PSRShared
PSRCore.ClientCallbacks = {}
PSRCore.ServerCallbacks = {}

exports('GetCoreObject', function()
    return PSRCore
end)

-- To use this export in a script instead of manifest method
-- Just put this line of code below at the very top of the script
-- local PSRCore = exports['qb-core']:GetCoreObject()
