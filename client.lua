-- ==================
-- CONFIG SECTION
-- ==================
Config = {
    MenuPosition = "left", -- Options: "left" or "right"
    MenuKey = "G", -- Keybind to open the menu https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
    RequireEmergencyVehicle = true, -- Set to false to allow menu anywhere

    Weapons = {
    Rifle = {
        label = "~r~~h~Service Rifle", 
        hash = GetHashKey("WEAPON_CARBINERIFLE"), -- https://docs.fivem.net/docs/game-references/weapon-models/
        attachments = {  -- https://wiki.rage.mp/wiki/Weapons_Components
            GetHashKey("COMPONENT_AT_SCOPE_MEDIUM"),
            GetHashKey("COMPONENT_AT_AR_AFGRIP"),
            GetHashKey("COMPONENT_AT_AR_FLSH")
            }
        },
    Shotgun = {
        label = "~o~~h~Beanbag Shotgun",
        hash = GetHashKey("WEAPON_PUMPSHOTGUN"), -- https://docs.fivem.net/docs/game-references/weapon-models/
        attachments = {  -- https://wiki.rage.mp/wiki/Weapons_Components
            GetHashKey("COMPONENT_AT_AR_FLSH")
        }
    },
    FireExtinguisher = {
        label = "~y~~h~Fire Extinguisher",
        hash = GetHashKey("WEAPON_FIREEXTINGUISHER"), -- https://docs.fivem.net/docs/game-references/weapon-models/
        attachments = {} -- https://wiki.rage.mp/wiki/Weapons_Components
    }
    },
    Vests = {
        { label = "~b~~h~Police Light Patrol Vest", model = 84, texture = 1 },
    },
    Radios = {
        { label = "~h~Chest Radio", model = 77 },
    }
}

local menuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu("LEO Menu", "~o~~h~Context Menu")
menuPool:Add(mainMenu)

-- Set menu position
mainMenu:SetMenuWidthOffset(Config.MenuPosition == "right" and -50 or 50)
-- Removed invalid SetLeftBadgeType call (not a NativeUI method)

-- The rest of the script remains unchanged...


-- Override OpenVehicleMenu to check for emergency vehicle if required
function OpenVehicleMenu()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = GetGamePool("CVehicle")

    local closestVehicle = nil
    local closestDistance = 3.0

    if Config.RequireEmergencyVehicle then
        for _, vehicle in ipairs(vehicles) do
            local vehCoords = GetEntityCoords(vehicle)
            local distance = #(playerCoords - vehCoords)
            if distance < closestDistance and GetVehicleClass(vehicle) == 18 then
                closestVehicle = vehicle
                closestDistance = distance
            end
        end

        if not closestVehicle then
            Notify("~r~You must be near an emergency vehicle to open this menu.")
            return
        end

        SetVehicleDoorOpen(closestVehicle, 5, false, false)
    end

    mainMenu:Clear()

local weaponOrder = { "Rifle", "Shotgun", "FireExtinguisher" }

for _, name in ipairs(weaponOrder) do
    local data = Config.Weapons[name]
    if data then
    local item = NativeUI.CreateItem("~b~~h~Toggle " .. data.label, "Equip or unequip the " .. data.label)
        item.Activated = function()
            ToggleWeapon(data.hash)
            AddWeaponAttachments(data.hash)
        end
        mainMenu:AddItem(item)
    end
end

    local refillArmorHealth = NativeUI.CreateItem("~g~~h~Refill Armor & Health", "Restore health and armor to full")
    refillArmorHealth.Activated = function()
        RefillArmorHealth()
    end

    local vestsOption = NativeUI.CreateItem("~d~~h~Accessories", "Choose a vest or radio")
    vestsOption.Activated = function()
        menuPool:CloseAllMenus()
        local vestMenu = CreateVestsSubMenu()
        menuPool:Add(vestMenu)
    end

    mainMenu:AddItem(refillArmorHealth)
    mainMenu:AddItem(vestsOption)

    menuPool:RefreshIndex()
    mainMenu:Visible(true)
    SetNuiFocus(false, false)
    SetCursorLocation(0.5, 0.5)

    Citizen.CreateThread(function()
        while mainMenu:Visible() or menuPool:IsAnyMenuOpen() do
            Citizen.Wait(500)
        end
        if Config.RequireEmergencyVehicle and closestVehicle then
            SetVehicleDoorShut(closestVehicle, 5, false)
        end
    end)
end

-- Update keybind registration
RegisterKeyMapping("vehiclemenu", "Open Vehicle Menu", "keyboard", Config.MenuKey)
RegisterCommand("vehiclemenu", function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        Notify("~r~You cannot access this menu while inside a vehicle.")
        return
    end
    OpenVehicleMenu()
end, false)

-- The rest of the script remains unchanged...

local menuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu("LEO Menu", "~o~~h~Context Menu")
menuPool:Add(mainMenu)

function ToggleWeapon(weaponHash)
    local playerPed = PlayerPedId()
    if HasPedGotWeapon(playerPed, weaponHash, false) then
        RemoveWeaponFromPed(playerPed, weaponHash)
        Notify("Weapon removed.")
    else
        GiveWeaponToPed(playerPed, weaponHash, 60, false, true)
        Notify("Weapon equipped.")
    end
end

function AddWeaponAttachments(weaponHash)
    local playerPed = PlayerPedId()
    for _, attachment in ipairs(Config.Weapons[GetWeaponNameFromHash(weaponHash)].attachments) do
        GiveWeaponComponentToPed(playerPed, weaponHash, attachment)
    end
end

function ToggleVest(vestId, textureId)
    local playerPed = PlayerPedId()
    SetPedComponentVariation(playerPed, 9, vestId - 1, textureId - 1, 2)
    Notify("Vest equipped.")
end

function RefillArmorHealth()
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    SetPedArmour(playerPed, 100)
    ClearPedBloodDamage(playerPed)
    ResetPedVisibleDamage(playerPed)
    ClearPedWetness(playerPed)
    Notify("~g~Armor & Health refilled.")
end

function ToggleRadioBodycam(shoulderId)
    local playerPed = PlayerPedId()
    SetPedComponentVariation(playerPed, 9, shoulderId, 0, 2)
    Notify("Radio & Bodycam equipped.")
end

function CreateVestsSubMenu()
    local vestMenu = NativeUI.CreateMenu("Vests", "Select a vest or equipment")

    for _, radio in ipairs(Config.Radios) do
        local item = NativeUI.CreateItem(radio.label, "Model " .. radio.model .. ", Texture 1")
        item.Activated = function()
            ToggleRadioBodycam(radio.model)
        end
        vestMenu:AddItem(item)
    end

    for _, vest in ipairs(Config.Vests) do
        local item = NativeUI.CreateItem(vest.label, "MP Ped " .. vest.model .. ", Texture " .. vest.texture)
        item.Activated = function()
            ToggleVest(vest.model, vest.texture)
        end
        vestMenu:AddItem(item)
    end

    Citizen.Wait(0)
    menuPool:RefreshIndex()
    vestMenu:Visible(true)
    vestMenu:CurrentSelection(0)

    return vestMenu
end

function OpenVehicleMenu()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = GetGamePool("CVehicle")

    local closestVehicle = nil
    local closestDistance = 3.0

    for _, vehicle in ipairs(vehicles) do
        local vehCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehCoords)
        if distance < closestDistance and GetVehicleClass(vehicle) == 18 then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end

    if not closestVehicle then
        Notify("~r~You must be near an emergency vehicle to open this menu.")
        return
    end

    SetVehicleDoorOpen(closestVehicle, 5, false, false)
    mainMenu:Clear()

local weaponOrder = { "Rifle", "Shotgun", "FireExtinguisher" }

for _, name in ipairs(weaponOrder) do
    local data = Config.Weapons[name]
    if data then
        local item = NativeUI.CreateItem("~b~~h~Toggle " .. data.label, "Equip or unequip the " .. data.label)
        item.Activated = function()
            ToggleWeapon(data.hash)
            AddWeaponAttachments(data.hash)
        end
        mainMenu:AddItem(item)
    end
end

    local refillArmorHealth = NativeUI.CreateItem("~g~~h~Refill Armor & Health", "Restore health and armor to full")
    refillArmorHealth.Activated = function()
        RefillArmorHealth()
    end

    local vestsOption = NativeUI.CreateItem("~d~~h~Vests", "Choose a vest or equipment")
    vestsOption.Activated = function()
        menuPool:CloseAllMenus()
        local vestMenu = CreateVestsSubMenu()
        menuPool:Add(vestMenu)
        SetCursorLocation(0.5, 0.5)
    end

    mainMenu:AddItem(refillArmorHealth)
    mainMenu:AddItem(vestsOption)

    menuPool:RefreshIndex()
    mainMenu:Visible(true)
    SetNuiFocus(false, false)
    SetCursorLocation(0.5, 0.5)

    Citizen.CreateThread(function()
        while mainMenu:Visible() or menuPool:IsAnyMenuOpen() do
            Citizen.Wait(500)
        end
        if closestVehicle then
            SetVehicleDoorShut(closestVehicle, 5, false)
        end
    end)
end

function BackToMainMenu(vestMenu)
    vestMenu:Visible(false)
    menuPool:CloseAllMenus()
    OpenVehicleMenu()
end

function Notify(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end

RegisterKeyMapping("vehiclemenu", "Open Vehicle Menu", "keyboard", "G")
RegisterCommand("vehiclemenu", function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        Notify("~r~You cannot access this menu while inside a vehicle.")
        return
    end
    OpenVehicleMenu()
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        menuPool:ProcessMenus()
    end
end)

function GetWeaponNameFromHash(hash)
    for name, weapon in pairs(Config.Weapons) do
        if weapon.hash == hash then
            return name
        end
    end
    return nil
end
