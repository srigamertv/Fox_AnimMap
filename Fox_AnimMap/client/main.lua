local MAP_APP_HASH = GetHashKey('map')
local mapOpen = false
local mapProp = nil
local transitioning = false
local useEvent = 'Fox_AnimMap:client:use'

local function debugPrint(message)
    if Config.Debug then
        print(('[%s] %s'):format(GetCurrentResourceName(), message))
    end
end

local function isMapActive()
    if IsUiappActiveByHash then
        return IsUiappActiveByHash(MAP_APP_HASH) ~= 0
    end

    return IsAppActive(MAP_APP_HASH) ~= 0
end

local function loadAnimation(animDict)
    if not DoesAnimDictExist(animDict) then
        debugPrint(('Animation dictionary not found: %s'):format(animDict))
        return false
    end

    RequestAnimDict(animDict)

    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(animDict) do
        if GetGameTimer() > timeout then
            debugPrint(('Timed out loading animation dictionary: %s'):format(animDict))
            return false
        end
        Wait(0)
    end

    return true
end

local function loadModel(modelHash)
    if not IsModelValid(modelHash) then
        debugPrint(('Invalid map prop model: %s'):format(Config.Map.model))
        return false
    end

    RequestModel(modelHash)

    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(modelHash) do
        if GetGameTimer() > timeout then
            debugPrint(('Timed out loading map prop model: %s'):format(Config.Map.model))
            return false
        end
        Wait(0)
    end

    return true
end

local function removeMapProp()
    if not mapProp or not DoesEntityExist(mapProp) then
        mapProp = nil
        return
    end

    DetachEntity(mapProp, false, true)
    SetEntityAsMissionEntity(mapProp, true, true)
    DeleteObject(mapProp)

    if DoesEntityExist(mapProp) then
        DeleteEntity(mapProp)
    end

    mapProp = nil
end

local function createMapProp(playerPed)
    removeMapProp()

    local coords = GetEntityCoords(playerPed)
    local modelHash = GetHashKey(Config.Map.model)

    if not loadModel(modelHash) then
        return false
    end

    mapProp = CreateObject(modelHash, coords.x, coords.y, coords.z, true, false, true)
    SetModelAsNoLongerNeeded(modelHash)

    if not mapProp or mapProp == 0 or not DoesEntityExist(mapProp) then
        mapProp = nil
        return false
    end

    SetEntityAsMissionEntity(mapProp, true, true)

    if loadAnimation(Config.Map.carryAnimDict) then
        TaskPlayAnim(
            playerPed,
            Config.Map.carryAnimDict,
            Config.Map.carryAnim,
            1.0,
            8.0,
            -1,
            31,
            0.0,
            false,
            false,
            false
        )
    end

    local boneIndex = GetEntityBoneIndexByName(playerPed, Config.Map.boneName)

    AttachEntityToEntity(
        mapProp,
        playerPed,
        boneIndex,
        Config.Map.offset.x,
        Config.Map.offset.y,
        Config.Map.offset.z,
        Config.Map.rotation.x,
        Config.Map.rotation.y,
        Config.Map.rotation.z,
        true,
        true,
        false,
        true,
        1,
        true
    )

    return true
end

local function playMapAnimation(animName)
    if not loadAnimation(Config.Map.animDict) then
        return false
    end

    TaskPlayAnim(
        PlayerPedId(),
        Config.Map.animDict,
        animName,
        -1.0,
        -0.5,
        -1,
        14,
        0.0,
        true,
        false,
        false
    )

    return true
end

local function onMapOpened()
    if mapOpen or transitioning then
        return
    end

    transitioning = true
    mapOpen = true

    local playerPed = PlayerPedId()
    SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
    playMapAnimation(Config.Map.enterAnim)

    Wait(Config.Map.spawnDelay)

    if mapOpen and isMapActive() then
        createMapProp(PlayerPedId())
    end

    transitioning = false
end

local function onMapClosed()
    if not mapOpen and not mapProp then
        return
    end

    mapOpen = false
    transitioning = false

    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    RemoveAnimDict(Config.Map.carryAnimDict)
    playMapAnimation(Config.Map.exitAnim)
    ClearPedSecondaryTask(playerPed)
    removeMapProp()
end

local function toggleNativeMap()
    if not Config.ToggleMapWithCommandAndItem then
        if not mapOpen then
            onMapOpened()
        else
            onMapClosed()
        end
        return
    end

    if isMapActive() then
        CloseUiappByHash(MAP_APP_HASH)
        return
    end

    if CanLaunchUiappByHash and CanLaunchUiappByHash(MAP_APP_HASH) == 0 then
        debugPrint('Native map UIApp cannot be launched right now.')
        return
    end

    LaunchUiappByHash(MAP_APP_HASH)
end

RegisterNetEvent(useEvent, toggleNativeMap)

if Config.Command.enabled and Config.Command.name ~= '' then
    RegisterCommand(Config.Command.name, toggleNativeMap, false)
end

CreateThread(function()
    while true do
        if Config.AnimateNormalMapOpen then
            Wait(0)

            local active = isMapActive()

            if active and not mapOpen then
                onMapOpened()
            elseif not active and mapOpen then
                onMapClosed()
            end
        else
            Wait(500)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    mapOpen = false
    transitioning = false
    ClearPedTasks(PlayerPedId())
    removeMapProp()
end)
