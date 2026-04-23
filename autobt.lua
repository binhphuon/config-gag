--loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/autobt.lua"))()

repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 
local LogService = game:GetService("LogService")

task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20sea%203.lua"))()
end)
getgenv().tmconfig = {
    key = "fDywcIFJa8ApwevtIC0OlZ34M736Mh",
    team = "Pirates", -- "Pirates" "Marines"
    hpTimeout = 15,
    targetTimeout = 10,
    lowHealth = 4000,
    safeHealth = 4500,
    code = "",
    useSkill = false, -- only x f gas fruit
    equipPaleScarf = false,
    webhookurl = "https://discord.com/api/webhooks/1491376052227018772/CQHt5wwLI3haDKgqR4eQ8FI8vqksZuSSkloU3SEDv8eXT2vMwdrE8VsOFzGSZBKZ_kEH",
    webhookEnable = true,
    webhookSendMinutes = 5,
    attackSpeed = 0.0001,
    mode = 2,
    fat = 10, -- 1 = normal UI, 10 = minimal UI 
    sea = 3,
    region = "Singapore",
    trans = true, -- auto press V t rex 
    bltween = true, 
    speedcf = 0.000000001, 
    bpsit = true,
    clearmap = false,
    boostfps = true,
}
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Kuro2112/sorip/refs/heads/main/supanika-obfuscated.lua"))()
end)

local checked = 0

while true do
    task.wait(80)

    local logs = LogService:GetLogHistory()

    for i = checked + 1, #logs do
        local log = logs[i]
        local message = string.lower(log.message)

        if string.find(message, "80/80") then
            task.spawn(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Kuro2112/sorip/refs/heads/main/supanika-obfuscated.lua"))()
            end)
            break
        end
    end

    checked = #logs
end
