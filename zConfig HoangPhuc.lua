-- Đợi game và Player load xong
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Services
local Players         = game:GetService("Players")
local ReplicatedStore = game:GetService("ReplicatedStorage")
local player          = Players.LocalPlayer

-- Modules
local PetsService     = require(ReplicatedStore.Modules.PetServices.PetsService)

-- Helper parse pet name
local function parsePetFromName(name)
    if not name then return nil end
    local kgStr  = name:match("%[(%d+%.?%d*)%s*KG%]")
    local ageStr = name:match("Age%s*:?%s*(%d+)")
    if not (kgStr and ageStr) then return nil end
    local petName = name:match("^(.-)%s*%[") or name
    petName = petName:gsub("^%s*(.-)%s*$", "%1")
    return petName, tonumber(kgStr), tonumber(ageStr)
end

-- Check blacklist
local function isUnvalidPet(petName)
    if not petName then return false end
    local lname = petName:lower()
    for _, bad in ipairs(unvalidToolNames) do
        if lname:find(bad:lower(), 1, true) then
            return true
        end
    end
    return false
end

-- Lấy tool theo config
local function getTool(name_pet, min_age, max_age)
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local petName, kg, age = parsePetFromName(tool.Name)
            if petName and age then
                -- ⚡ Nếu name_pet == nil thì mới check blacklist
                if (name_pet or not isUnvalidPet(petName)) then
                    if (not name_pet or petName:lower():find(name_pet:lower(), 1, true)) 
                        and age >= min_age and age < max_age then
                        return tool
                    end
                end
            end
        end
    end
    return nil
end

-- Hàm tặng pet
local function giftPetToPlayer(targetPlayerName)
    local args = {
        "GivePet",
        Players:WaitForChild(targetPlayerName)
    }
    ReplicatedStore.GameEvents.PetGiftingService:FireServer(unpack(args))
    print("🛍️ Tặng pet cho", targetPlayerName)
end

-- Vòng lặp chính
while true do
    task.wait(1)
    for _, cfg in ipairs(DataGetTool) do
        for _, p in ipairs(Players:GetPlayers()) do
            if table.find(cfg.playerlist, p.Name) then
                local tool = getTool(cfg.name_pet, cfg.min_age, cfg.max_age)
                if tool then
                    player.Character.Humanoid:EquipTool(tool)
                    giftPetToPlayer(p.Name)
                else
                    warn("[autoPickup] Không tìm thấy tool hợp lệ cho", p.Name)
                end
            end
        end
    end
end
