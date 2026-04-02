repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer:FindFirstChild("DataLoaded")

if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)") then
	repeat task.wait() until not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)")
end

local SeaToJoin = 3

local args = {
	[1] = "TravelMain",
	[2] = "TravelDressrosa",
	[3] = "TravelZou"
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

if args[SeaToJoin] then
	CommF:InvokeServer(args[SeaToJoin])
else

end
