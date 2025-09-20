-- Webhook Discord của bạn
local webhookUrl = "https://canary.discord.com/api/webhooks/1410216828092940389/ez2OQpw_UmTp3IUtL5fe4nfuIVhrzbMneDoJCje800rV-GMC788S0q8KAWuwID9fxN0F"

-- Services
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Nội dung gửi
local data = {
    ["content"] = "🚀 Script vừa được exec bởi **"..player.Name.."** " ..
        "(UserId: "..player.UserId..")\n" ..
        "📌 GameId: "..game.PlaceId.."\n" ..
        "🆔 JobId: "..game.JobId.."\n" ..
        "HWID: "..HWID
}

-- Encode JSON
local body = HttpService:JSONEncode(data)

-- Gửi request qua Codex API
if http_request then
    http_request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = body
    })
else
    warn("❌ Codex không hỗ trợ http_request")
end
