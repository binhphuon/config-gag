--loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/api.lua"))()
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enemies = workspace:WaitForChild("Enemies")
local Lighting = game:GetService("Lighting")

local SEA1_PLACE_IDS = {
    [2753915549] = true,
    [85211729168715] = true
}

local SEA2_PLACE_IDS = {
    [4442272183] = true,
    [79091703265657] = true
}

local SEA3_PLACE_IDS = {
    [7449423635] = true,
    [100117331123090] = true
}

local jobId = tostring(game.JobId)
local playerCount = #Players:GetPlayers()
local joinScript = string.format(
    'game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, "%s", game.Players.LocalPlayer)',
    jobId
)

local Txlerz = {
    ["Mirage Island"] = "https://discord.com/api/webhooks/1492131692507562014/vjcF3UbhHf_Ds2gOZj6xFD-VlW2jlkLXmUl31L5gsfBGOrbUttkcGIiXc2yCYioKk6Bi",
    ["Kitsune Island"] = "https://discord.com/api/webhooks/1492131738997100695/rF_Z4zJ11mEkFa7XnofJLb-m2F978AE--bVDpa6NcbvWNzl4EdB5BjlzQop01Fdynbhd",
    ["Prehistoric Island"] = "https://discord.com/api/webhooks/1492131790297628854/YQhXWG1imCmz3xUelID78nDKhBqYOS9i00oP8ZNPYBJZDYbsEix_-e_X4CYQtNpo2w9Q",
    ["Full Moon"] = "https://discord.com/api/webhooks/1492131116658851860/fg2MMMAKkGtjozRCmtNKPwrbHs-GDIpqHx72T9UkjI7v6Kv6oZpf9KFWXTq36Au46nZr",
    ["Near Full Moon"] = "https://discord.com/api/webhooks/1492131193250910351/bnNJMuMW0TCCdavwoHE3WYozW7Guk6KuYyo3ByST17CCErmeLGNf76zrG4_5Q-49z_El",
    ["Rip Indra"] = "https://discord.com/api/webhooks/1492131276130488373/f7wKT9w3cnfYLR67zMktJ4T3OkIdcrj2LntUT3_FloroleCGZbL211pnxwf3QRCGIAUI",
    ["Dough King"] = "https://discord.com/api/webhooks/1492131363900624997/1sUEnp2dcF58akmPet6gM6S4ArAnMEeLoVW_Ap5fsLQleeVZ-zRiLbooOOl4GKV0TowC",
    ["Cake Prince"] = "https://discord.com/api/webhooks/1492131424839532575/19mBpFri2Y6HkOy1_khOX0HnVaNlLXnw629IqwQtwUMvMI-M6uDr9iP_YBGf5M131JjN",
    ["Tyrant of the Skies"] = "https://discord.com/api/webhooks/1492131493215207554/v92Iu-fqZUiyZ8DYXW-VwlO_x1Jybkc6DSV-eAPRdYdVLsM8PU9VgV6ukJ3UEe8TJ6WC",
    ["Darkbeard"] = "https://discord.com/api/webhooks/1492131554175225949/nDIApB81dFNRPcNsPm6Nb__vIUsmMx-XM6YVi_BJgTwbJA4lQesw3BBlhINb0HcWgz60",
    ["Soul Reaper"] = "https://discord.com/api/webhooks/1492131615453876357/rTTL8aTk4LMbUQqppC0inroKqZQ-lFZy-6lZ08vIQDdU5HLXjc-PrrukRpfH_ctOX5Rb",
    ["Cursed Captain"] = "https://discord.com/api/webhooks/1492130085971431555/23fpq8LJD2lMrzLdnYkYZA4DyPIKaDiWOYKbHc6qZxBC2E7zfUKrYt026r_KEoEf5tL2",
    ["Legendary Sword"] = "https://discord.com/api/webhooks/1492131054134366308/PKGTl6ZzdfrC8UzKjihbPAhtMt1yjDDFalUiA6jfSNByCrpmB-Gah9-6xFVh7OvItR3e"
}

getgenv().webhook = {
    ["Txlerz"] = true
}

local WebhookURLs = getgenv().webhook

local WebhookGroups = {
    ["Txlerz"] = Txlerz
}

function sendBossWebhook(eventName, swordName)
    local currentSea = "Unknown Sea"

    if SEA1_PLACE_IDS[game.PlaceId] then
        currentSea = "First Sea"
    elseif SEA2_PLACE_IDS[game.PlaceId] then
        currentSea = "Second Sea"
    elseif SEA3_PLACE_IDS[game.PlaceId] then
        currentSea = "Third Sea"
    end

    local displayName = eventName
    if eventName == "Legendary Sword" and swordName then
        displayName = "Legendary Sword (" .. swordName .. ")"
    end

    local data = {
        username = "Notify",
        embeds = {{
            title = displayName .. " | Shopgodfruit.com",
            color = tonumber(0xFFFFFF),
            fields = {
                { name = "Type :", value = "```\n" .. displayName .. " [Spawn]\n```", inline = false },
                { name = "Players In Server :", value = "```\n" .. tostring(playerCount) .. "\n```", inline = false },
                { name = "Sea :", value = "```\n" .. currentSea .. "\n```", inline = false },
                { name = "Job ID (Pc Copy):", value = "```\n" .. jobId .. "\n```", inline = false },
                { name = "Join Script (Pc Copy):", value = "```lua\n" .. joinScript .. "\n```", inline = false },
                { name = "Job ID (Mobile Copy):", value = jobId, inline = false },
                { name = "Join Script (Mobile Copy):", value = joinScript, inline = false }
            },
            footer = {
                text = "Make by ! Txlerz • " .. os.date("Time : %d/%m/%Y - %H:%M:%S")
            }
        }}
    }

    local payload = HttpService:JSONEncode(data)
    local request = http_request or request or HttpPost or (syn and syn.request)

    if request then
        for groupName, isEnabled in pairs(WebhookURLs) do
            if isEnabled and WebhookGroups[groupName] and WebhookGroups[groupName][eventName] then
                pcall(function()
                    request({
                        Url = WebhookGroups[groupName][eventName],
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = payload
                    })
                end)
            end
        end
    end
end

--// Sent flags
local sentDarkbeard = false
local sentCursedCaptain = false
local sentRipIndra = false
local sentDoughKing = false
local sentCakePrince = false
local sentTyrantSkies = false
local sentSoulReaper = false
local sentMirage = false
local sentKitsune = false
local sentPrehistoric = false
local sentFullMoon = false
local sentNearFullMoon = false

--// Darkbeard Only (World 2)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA2_PLACE_IDS[game.PlaceId] and not sentDarkbeard then
            if ReplicatedStorage:FindFirstChild("Darkbeard") or Enemies:FindFirstChild("Darkbeard") then
                sendBossWebhook("Darkbeard")
                sentDarkbeard = true
            end
        end
    end
end)

--// Cursed Captain Only (World 2)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA2_PLACE_IDS[game.PlaceId] and not sentCursedCaptain then
            if ReplicatedStorage:FindFirstChild("Cursed Captain") or Enemies:FindFirstChild("Cursed Captain") then
                sendBossWebhook("Cursed Captain")
                sentCursedCaptain = true
            end
        end
    end
end)

--// Rip Indra Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA3_PLACE_IDS[game.PlaceId] and not sentRipIndra then
            if ReplicatedStorage:FindFirstChild("Rip Indra") or Enemies:FindFirstChild("Rip Indra") then
                sendBossWebhook("Rip Indra")
                sentRipIndra = true
            end
        end
    end
end)

--// Dough King Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA3_PLACE_IDS[game.PlaceId] and not sentDoughKing then
            if ReplicatedStorage:FindFirstChild("Dough King") or Enemies:FindFirstChild("Dough King") then
                sendBossWebhook("Dough King")
                sentDoughKing = true
            end
        end
    end
end)

--// Cake Prince Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA3_PLACE_IDS[game.PlaceId] and not sentCakePrince then
            if ReplicatedStorage:FindFirstChild("Cake Prince") or Enemies:FindFirstChild("Cake Prince") then
                sendBossWebhook("Cake Prince")
                sentCakePrince = true
            end
        end
    end
end)

--// Tyrant of the Skies Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA3_PLACE_IDS[game.PlaceId] and not sentTyrantSkies then
            if ReplicatedStorage:FindFirstChild("Tyrant of the Skies") or Enemies:FindFirstChild("Tyrant of the Skies") then
                sendBossWebhook("Tyrant of the Skies")
                sentTyrantSkies = true
            end
        end
    end
end)

--// Soul Reaper Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA3_PLACE_IDS[game.PlaceId] and not sentSoulReaper then
            if ReplicatedStorage:FindFirstChild("Soul Reaper") or Enemies:FindFirstChild("Soul Reaper") then
                sendBossWebhook("Soul Reaper")
                sentSoulReaper = true
            end
        end
    end
end)

--// Mirage Island Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA3_PLACE_IDS[game.PlaceId] and not sentMirage then
            local locs = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
            if locs and locs:FindFirstChild("Mirage Island") then
                sendBossWebhook("Mirage Island")
                sentMirage = true
            end
        end
    end
end)

--// Kitsune Island Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA3_PLACE_IDS[game.PlaceId] and not sentKitsune then
            local locs = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
            if locs and locs:FindFirstChild("Kitsune Island") then
                sendBossWebhook("Kitsune Island")
                sentKitsune = true
            end
        end
    end
end)

--// Prehistoric Island Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA3_PLACE_IDS[game.PlaceId] and not sentPrehistoric then
            local locs = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
            if locs and locs:FindFirstChild("Prehistoric Island") then
                sendBossWebhook("Prehistoric Island")
                sentPrehistoric = true
            end
        end
    end
end)

--// Full Moon Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA3_PLACE_IDS[game.PlaceId] and not sentFullMoon then
            if Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149431" then
                sendBossWebhook("Full Moon")
                sentFullMoon = true
            end
        end
    end
end)

--// Near Full Moon Only (World 3)
task.spawn(function()
    while true do
        task.wait(0.2)
        if SEA3_PLACE_IDS[game.PlaceId] and not sentNearFullMoon then
            if Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149052" then
                sendBossWebhook("Near Full Moon")
                sentNearFullMoon = true
            end
        end
    end
end)

--// Legendary Sword Dealer Only (World 2)
task.spawn(function()
    local previousSword = nil
    local sentLegendarySword = false

    while true do
        task.wait(0.5)
        if SEA2_PLACE_IDS[game.PlaceId] then
            if not previousSword then
                sentLegendarySword = false
            end

            local currentSword = nil
            local success, result

            success, result = pcall(function()
                return ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "1")
            end)
            if success and result then
                currentSword = "Shizu"
            end

            if not currentSword then
                success, result = pcall(function()
                    return ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "2")
                end)
                if success and result then
                    currentSword = "Oroshi"
                end
            end

            if not currentSword then
                success, result = pcall(function()
                    return ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "3")
                end)
                if success and result then
                    currentSword = "Saishi"
                end
            end

            if currentSword and currentSword ~= previousSword and not sentLegendarySword then
                sendBossWebhook("Legendary Sword", currentSword)
                previousSword = currentSword
                sentLegendarySword = true
            elseif not currentSword and previousSword then
                previousSword = nil
                sentLegendarySword = false
            end
        else
            previousSword = nil
            sentLegendarySword = false
            task.wait(5)
        end
    end
end)
