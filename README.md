# FiveM-LEO-Context-Menu
A lightweight, configurable NativeUI-based script for FiveM that allows emergency personnel to equip weapons, vests, and radios near an emergency vehicle. Includes health/armor refill and customizable keybind support.

## 🔧 Features
- 💼 Toggle Emergency Weapons (with attachments)
- 🦺 Equip Department-Specific Vests & Radios
- ❤️ Refill Armor & Health, Clean player Clothes
- 🚨 Configurable Keybinds and Menu Position
- 🚗 Opens only near emergency vehicles - Configurable
  
## 📦 Installation
1. **Drag and drop** the resource folder into your `resources` directory.
2. Add the following line to your "server.cfg": `ensure FiveM-LEO-Context-Menu`
3. Restart the server / Start the Resource

## ⚙️ Configuration
    MenuPosition = "left", -- Options: "left" or "right"
    MenuKey = "G", -- Keybind to open the menu
    RequireEmergencyVehicle = true, -- Set to false to allow menu anywhere

    Weapons = {
    Rifle = {
        label = "~r~~h~Service Rifle",
        hash = GetHashKey("WEAPON_CARBINERIFLE"),
        attachments = {
            GetHashKey("COMPONENT_AT_SCOPE_MEDIUM"),
            GetHashKey("COMPONENT_AT_AR_AFGRIP"),
            GetHashKey("COMPONENT_AT_AR_FLSH")
            }
        },
    Shotgun = {
        label = "~o~~h~Beanbag Shotgun",
        hash = GetHashKey("WEAPON_PUMPSHOTGUN"),
        attachments = {
            GetHashKey("COMPONENT_AT_AR_FLSH")
        }
    },
    FireExtinguisher = {
        label = "~y~~h~Fire Extinguisher",
        hash = GetHashKey("WEAPON_FIREEXTINGUISHER"),
        attachments = {}
    }
    },
    Vests = {
        { label = "~b~~h~Police Light Patrol Vest", model = 84, texture = 1 },
  
    },
    Radios = {
        { label = "~h~Chest Radio", model = 77 },
}
