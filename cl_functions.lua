-- =====================================================
-- JOMIDAR ADMIN – CLIENT FUNCTIONS (QBOX FINAL)
-- =====================================================

local QBCore = exports['qb-core']:GetCoreObject()

AllPlayerBlips = {}
Group = nil
LoggedIn = false

-- =====================================================
-- Choices Source Resolver
-- =====================================================
local function ResolveChoicesSource(option)
    if not option or not option.ChoicesSource then return end

    if option.ChoicesSource == 'models' then
        option.Choices = GetModels()
    elseif option.ChoicesSource == 'jobs' then
        option.Choices = GetJobs()
    elseif option.ChoicesSource == 'gangs' then
        option.Choices = GetGangs()
    elseif option.ChoicesSource == 'money' then
        option.Choices = GetMoneyTypes()
    elseif option.ChoicesSource == 'items' then
        option.Choices = GetInventoryItems()
    elseif option.ChoicesSource == 'vehicles' then
        option.Choices = GetAddonVehicles()
    elseif option.ChoicesSource == 'deletions' then
        option.Choices = GetDeletionTypes()
    elseif option.ChoicesSource == 'weather' then
        option.Choices = GetWeatherTypes()
    elseif option.ChoicesSource == 'farts' then
        option.Choices = GetFarts()
    end
end

-- =====================================================
-- INIT
-- =====================================================
function InitAdminMenu()
    Citizen.Wait(100)
    RefreshMenu('all')
    Citizen.CreateThread(StartBlipsLoop)
    LoggedIn = true
end

-- =====================================================
-- MENU
-- =====================================================
function ToggleMenu(IsUpdate)
    local Bans = GetBans()
    local Players = GetPlayers()
    local Logs = GetLogs()
    local Commands = GetCommands()

    local favInfo = GetResourceKvpInfo('favorites')
    local Favorites = favInfo and favInfo.Value or {}

    local pinInfo = GetResourceKvpInfo('pinned_targets')
    local Pinned = pinInfo and pinInfo.Value or {}

    local optInfo = GetResourceKvpInfo('options')
    local Options = optInfo and optInfo.Value or {}

    if not IsUpdate then
        SetNuiFocus(true, true)
    end

    SendNUIMessage({
        Action = IsUpdate and 'Update' or 'Open',
        Debug = Config.Settings.Debug,
        Bans = Bans,
        AllPlayers = Players,
        Logs = Logs,
        Favorited = Favorites,
        PinnedPlayers = Pinned,
        MenuOptions = Options,
        Commands = Commands,
        Reports = Config.Reports,
        Staffchat = Config.StaffChat,
        Name = QBCore.Functions.GetPlayerData().name,
        Pages = Config.Settings.Pages,
        BanTypes = Config.BanTimeCategories,
    })
end

-- =====================================================
-- KVP
-- =====================================================
function GenerateKVP(name)
    local prom = promise:new()
    local data = {}

    if not name then
        prom:resolve({})
        return Citizen.Await(prom)
    end

    if name == 'favorites' then
        for _, cat in pairs(Config.CommandList or {}) do
            for _, item in pairs(cat.Items or {}) do
                data[item.Id] = false
            end
        end

    elseif name == 'options' then
        data = {
            LargeDefault = false,
            BindOpen = true,
            Tooltips = true,
            Resizer = true
        }

    elseif name == 'command_perms' then
        for _, cat in pairs(Config.CommandList or {}) do
            for _, item in pairs(cat.Items or {}) do
                if item.UseKVPGroups then
                    data[item.Id] = { 'all' }
                end
            end
        end
    end

    prom:resolve(data)
    return Citizen.Await(prom)
end

function GetResourceKvpInfo(name)
    for i, kvp in ipairs(Config.ResourceKVPs or {}) do
        if kvp.Name:lower() == name:lower() then
            return kvp, i
        end
    end
    return nil
end

function RefreshMenu(type)
    if type ~= 'all' then return end

    for _, kvp in ipairs(Config.ResourceKVPs or {}) do
        local raw = GetResourceKvpString('j0-adminmenu-' .. kvp.Name)
        if not raw or raw == "[]" then
            kvp.Value = GenerateKVP(kvp.Name)
            SetResourceKvp('j0-adminmenu-' .. kvp.Name, json.encode(kvp.Value))
        else
            kvp.Value = json.decode(raw)
        end
    end

    ToggleMenu(true)
end

-- =====================================================
-- COMMAND FILTER
-- =====================================================
function GetCommands()
    local prom = promise:new()
    local out = {}

    for _, cat in ipairs(Config.CommandList or {}) do
        out[cat.Id] = {
            Id = cat.Id,
            Name = cat.Name,
            Items = {}
        }

        for _, item in ipairs(cat.Items or {}) do
            if item.Options then
                for _, opt in ipairs(item.Options) do
                    ResolveChoicesSource(opt)
                end
            end
            table.insert(out[cat.Id].Items, item)
        end
    end

    prom:resolve(out)
    return Citizen.Await(prom)
end

-- =====================================================
-- DATA SOURCES (QBOX SAFE)
-- =====================================================
function GetModels()
    local list = {}
    for _, v in pairs(Config.Models or {}) do
        list[#list + 1] = { Text = v }
    end
    return list
end

function GetInventoryItems()
    local prom = promise:new()
    local items = {}

    for _, v in pairs(QBCore.Shared.Items or {}) do
        items[#items + 1] = { Text = v.name }
    end

    prom:resolve(items)
    return Citizen.Await(prom)
end

-- 🔥 QBOX-CORRECT MONEY TYPES
function GetMoneyTypes()
    local prom = promise:new()
    local moneyTypes = {}

    local PlayerData = QBCore.Functions.GetPlayerData()
    local money = PlayerData and PlayerData.money or {}

    for k, _ in pairs(money) do
        moneyTypes[#moneyTypes + 1] = { Text = k }
    end

    table.sort(moneyTypes, function(a, b)
        return a.Text < b.Text
    end)

    prom:resolve(moneyTypes)
    return Citizen.Await(prom)
end

function GetGangs()
    local prom = promise:new()
    local out = {}

    for k, v in pairs(QBCore.Shared.Gangs or {}) do
        out[#out + 1] = {
            Text = k,
            Label = ' [' .. (v.label or k) .. ']'
        }
    end

    prom:resolve(out)
    return Citizen.Await(prom)
end

function GetJobs()
    local prom = promise:new()
    local out = {}

    for k, v in pairs(QBCore.Shared.Jobs or {}) do
        out[#out + 1] = {
            Text = k,
            Label = ' [' .. v.label .. ']'
        }
    end

    prom:resolve(out)
    return Citizen.Await(prom)
end

function GetAddonVehicles()
    local prom = promise:new()
    local out = {}

    for _, v in pairs(QBCore.Shared.Vehicles or {}) do
        out[#out + 1] = {
            Text = v.model,
            Label = ' [' .. v.brand .. ' ' .. v.name .. ']'
        }
    end

    prom:resolve(out)
    return Citizen.Await(prom)
end

function GetDeletionTypes()
    return {
        { Text = 'Objects' },
        { Text = 'Peds' },
        { Text = 'Vehicles' },
        { Text = 'All' },
    }
end

function GetWeatherTypes()
    local out = {}
    for _, v in ipairs(Config.WeatherTypes or {}) do
        out[#out + 1] = { Text = v }
    end
    return out
end

function GetFarts()
    local prom = promise:new()
    local out = {}

    for _, v in pairs(Config.FartNoises or {}) do
        out[#out + 1] = {
            Text = v.SoundName,
            Label = ' [' .. v.Name .. ']'
        }
    end

    prom:resolve(out)
    return Citizen.Await(prom)
end

-- =====================================================
-- SERVER QUERIES
-- =====================================================
function GetPlayers()
    local prom = promise:new()
    QBCore.Functions.TriggerCallback('j0-admin/server/get-players', function(data)
        prom:resolve(data or {})
    end)
    return Citizen.Await(prom)
end

function GetBans()
    local prom = promise:new()
    QBCore.Functions.TriggerCallback('j0-admin/server/get-bans', function(data)
        prom:resolve(data or {})
    end)
    return Citizen.Await(prom)
end

function GetLogs()
    local prom = promise:new()
    QBCore.Functions.TriggerCallback('j0-admin/server/get-logs', function(data)
        prom:resolve(data or {})
    end)
    return Citizen.Await(prom)
end

-- =====================================================
-- BLIPS
-- =====================================================
function StartBlipsLoop()
    while true do
        Citizen.Wait(2000)
        if not LoggedIn then goto continue end
        ::continue::
    end
end
