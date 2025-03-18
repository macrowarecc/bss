local importants = {W = game.Workspace, SpawnersFolder = "MonsterSpawners"}
local MonsterTypes = require(game:GetService("ReplicatedStorage").MonsterTypes)
local ClientStatCache = require(game:GetService("ReplicatedStorage").ClientStatCache)
local StatModifiers = require(game:GetService("ReplicatedStorage").StatModifiers)

function revertTimeString(timeString)
    local timeItems = timeString:split(":")
    local seconds = 0
    local multipliers = {}
    local iterations = 0
    for i = #timeItems, 1 , -1 do
        multipliers[i] = (iterations == 0 and 1 or iterations == 1 and 60 or iterations == 2 and 3600 or iterations == 3 and 86400)
        iterations = iterations + 1
    end
    for i = #timeItems, 1 , -1 do
        seconds = seconds + (tonumber(timeItems[i]) * multipliers[i])
    end
    return tonumber(seconds)
end

local module = {}

function module.GetSpawner(spawnerName)
    return importants.W:WaitForChild(importants.SpawnersFolder):FindFirstChild(spawnerName)
end

function module.GetMonsterCooldownReduction()
    local modCaches = ClientStatCache:Get().ModifierCaches.Value
    if not modCaches then return nil end

    local idk = StatModifiers.ParamsTag()
    
    local MonsterCooldownReduction = modCaches.MonsterCooldownReduction
    if not MonsterCooldownReduction then return nil end

    return MonsterCooldownReduction[idk]
end

function module.GetSpawnerCooldown(spawnerName)
    local spawner = module.GetSpawner(spawnerName)
    if not spawner then return math.huge end

    local monsterType = spawner.MonsterType.Value

    local monsterData = MonsterTypes.Get(monsterType)
    if not monsterData then return math.huge end
    
    local cooldown = monsterData.Stats.RespawnCooldown
    if not cooldown then return math.huge end

    local MonsterCooldownReduction = module.GetMonsterCooldownReduction()

    if MonsterCooldownReduction then
        cooldown = cooldown * (1 - MonsterCooldownReduction)
    end

    return cooldown
end

return module
