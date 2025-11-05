--loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/kaitun%20ostrich.lua", true))()

--// =========================
--// Auto Farm Eggs (Plant + Hatch, Farm-based) — base-only capacity
--// =========================

-- ======= BYPASS "CLICK ANYWHERE TO CONTINUE" =======
local Players           = game:GetService("Players")
local GuiService        = game:GetService("GuiService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local StarterGui        = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStore   = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local SPLASH_MAX_WAIT     = 10
local SPLASH_POLL         = 0.25
local FORCE_HIDE_SPLASH   = false

local function sendVirtualClick(x, y)
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        vim:SendMouseMoveEvent(x, y, game, 0)
        vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
        vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
end
local function sendKey(code)
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        vim:SendKeyEvent(true, code, false, game)
        task.wait(0.02)
        vim:SendKeyEvent(false, code, false, game)
    end)
end
local function findSplashCandidate()
    local kws = {
        "click anywhere","click to continue","tap to continue",
        "nhấn để tiếp tục","chạm để tiếp tục","tiếp tục","continue"
    }
    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton") or gui:IsA("TextLabel"))
            and gui.Visible and gui.AbsoluteSize.Magnitude > 0 then
            local text = (gui.Text or gui.Name or ""):lower()
            for _, kw in ipairs(kws) do
                if text:find(kw, 1, true) then return gui end
            end
        end
    end
    return nil
end
local function splashGone() return findSplashCandidate() == nil end
local function bypassClickAnywhere()
    local cam = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera")
    local vp  = cam.ViewportSize
    local deadline = time() + SPLASH_MAX_WAIT

    sendVirtualClick(vp.X/2, vp.Y/2)
    task.wait(0.2)
    if splashGone() then return true end

    local c = findSplashCandidate()
    if c then
        local pos = c.AbsolutePosition
        local size= c.AbsoluteSize
        sendVirtualClick(pos.X + size.X/2, pos.Y + size.Y/2)
        task.wait(0.2)
        if splashGone() then return true end
    end

    sendKey(Enum.KeyCode.Space); task.wait(0.1); if splashGone() then return true end
    sendKey(Enum.KeyCode.Return);task.wait(0.1); if splashGone() then return true end

    while time() < deadline do
        task.wait(SPLASH_POLL)
        local cam2 = workspace.CurrentCamera
        local sz   = (cam2 and cam2.ViewportSize) or vp
        local cand = findSplashCandidate()
        if cand then
            local p = cand.AbsolutePosition; local s = cand.AbsoluteSize
            sendVirtualClick(p.X + s.X/2, p.Y + s.Y/2)
        else
            sendVirtualClick(sz.X/2, sz.Y/2)
        end
        if splashGone() then return true end
    end

    if FORCE_HIDE_SPLASH then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                local hit = false
                for _, d in ipairs(gui:GetDescendants()) do
                    if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Visible then
                        local t = (d.Text or ""):lower()
                        if t:find("continue",1,true) or t:find("tiếp tục",1,true) then
                            hit = true; break
                        end
                    end
                end
                if hit then gui.Enabled = false end
            end
        end
        task.wait(0.1)
        if splashGone() then return true end
    end
    return false
end

pcall(function()
    if bypassClickAnywhere() then
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title="Splash", Text="Đã bỏ qua màn hình continue", Duration=2})
        end)
    end
end)
-- ======= END SPLASH BYPASS =======


-- ======= Character refs =======
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local hrp       = character:WaitForChild("HumanoidRootPart")
player.CharacterAdded:Connect(function()
    task.wait(0.2)
    character = player.Character or player.CharacterAdded:Wait()
    humanoid  = character:WaitForChild("Humanoid")
    hrp       = character:WaitForChild("HumanoidRootPart")
end)

-- ======= Config main =======
local SCAN_INTERVAL       = 0.5
local TELEPORT_OFFSET_Z   = 2        -- lệch +Z local của egg
local ANNOUNCE            = true
local PLANT_INTERVAL_MIN  = 1.0
local PLANT_INTERVAL_MAX  = 2.0
local MAX_ACTIVE_EGGS     = 3        -- sẽ được cập nhật từ DataService (base only)

local eggPriority = {
    "Common Egg",
	"Common Summer Egg",
    "Uncommon Egg",
    "Rare Egg",
    "Rare Summer Egg",
    "Legendary Egg",
    "Mythical Egg",
    "Bug Egg",
	"Sprout Egg",
	"Enchanted Egg",
	"Jungle Egg",
    "Fall Egg"
}

-- ======= Modules & Remotes =======
local GetFarm       = require(ReplicatedStore.Modules.GetFarm)
local Manhattan2D   = require(ReplicatedStore.Code.Manhattan2D)
local PetsService   = require(ReplicatedStore.Modules.PetServices.PetsService)
local PetEggService = ReplicatedStore:WaitForChild("GameEvents"):WaitForChild("PetEggService")

-- ======= Helpers =======
local function debugPrint(...) print("[AutoEgg]", ...) end
local function notify(title, text, dur)
    if not ANNOUNCE then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 3})
    end)
end

-- ======= getValidCFrame (bạn cung cấp) =======
local function getValidCFrame()
    local farm = GetFarm(player)
    if not farm then return nil end

    local petArea = farm:FindFirstChild("PetArea")
    if not petArea then return nil end

    local size   = petArea.Size
    local center = petArea.Position

    for _ = 1, 5 do
        local offset = Vector3.new(
            math.random(-size.X/2 + 2, size.X/2 - 2),
            0,
            math.random(-size.Z/2 + 2, size.Z/2 - 2)
        )
        local pos = center + offset
        local cf  = CFrame.new(pos.X, 0, pos.Z)
        if Manhattan2D(cf.Position, petArea) then
            return cf
        end
    end
    return nil
end

-- ======= Tool parsing & selection (không nhầm Common/Uncommon) =======
local function parseToolName(name: string): (string, number)
    local base, cnt = name:match("^%s*(.-)%s+x(%d+)%s*$")
    if base and cnt then
        base = base:gsub("^%s+", ""):gsub("%s+$", "")
        return base, tonumber(cnt)
    end
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    return name, 1
end

-- Trả về: toolInstance, baseName, count
local function getTool()
    local char = player.Character or player.CharacterAdded:Wait()

    local candidates = {}
    local function collect(container)
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local base, count = parseToolName(tool.Name)
                table.insert(candidates, {inst=tool, base=base, count=count, parent=container})
            end
        end
    end
    collect(player.Backpack)
    collect(char)

    -- đang equip?
    local equipped = nil
    for _, t in ipairs(candidates) do
        if t.parent == char then equipped = t; break end
    end

    for _, want in ipairs(eggPriority) do
        if equipped and equipped.base == want then
            debugPrint(("✅ Tool đang equip: %s (x%d)"):format(equipped.inst.Name, equipped.count))
            return equipped.inst, equipped.base, equipped.count
        end
        local best, bestCount = nil, -1
        for _, t in ipairs(candidates) do
            if t.base == want and t.count > bestCount then
                best, bestCount = t, t.count
            end
        end
        if best then
            debugPrint(("✅ Chọn tool: %s (x%d)"):format(best.inst.Name, best.count))
            return best.inst, best.base, best.count
        end
    end

    debugPrint("❌ Không tìm thấy tool trứng phù hợp")
    return nil
end

-- ======= Farm-wide egg listing =======
local function getPetArea()
    local farm = GetFarm(player)
    if not farm then return nil end
    return farm:FindFirstChild("PetArea")
end

-- trả về danh sách egg của bạn nằm trong PetArea
local function getOwnedFarmEggs()
    local petArea = getPetArea()
    if not petArea then return {} end

    local eggs = {}
    for _, egg in ipairs(CollectionService:GetTagged("PetEggServer")) do
        if egg:IsDescendantOf(workspace) and egg:GetAttribute("OWNER") == player.Name then
            local pos = egg:GetPivot().Position
            if Manhattan2D(pos, petArea) then
                table.insert(eggs, {
                    inst  = egg,
                    pos   = pos,
                    tth   = egg:GetAttribute("TimeToHatch"),
                    ready = egg:GetAttribute("READY") == true
                })
            end
        end
    end
    return eggs
end

local function countActiveOwnedEggs()
    local list = getOwnedFarmEggs()
    local cnt = 0
    for _, e in ipairs(list) do
        local tth = typeof(e.tth)=="number" and e.tth or 1
        if tth > 0 or not e.ready then cnt += 1 end
    end
    return cnt
end

-- ======= Hatch helpers =======
local function isShowTimePassed(egg: Instance)
    local st = egg:GetAttribute("ShowTime")
    if st == nil then return true end
    return st <= workspace:GetServerTimeNow()
end
local function isReadyToHatch(egg: Instance)
    if egg:GetAttribute("OWNER") ~= player.Name then return false end
    if egg:GetAttribute("READY") ~= true then return false end
    if not isShowTimePassed(egg) then return false end
    local tth = egg:GetAttribute("TimeToHatch")
    if typeof(tth) ~= "number" or tth > 0 then return false end
    return true
end
local function teleportNearEgg(egg: Instance, offsetZ: number)
    local pivot = egg:GetPivot()
    local destCF = pivot * CFrame.new(0, 0, offsetZ) -- +Z local
    local lookAt = CFrame.new(destCF.Position, pivot.Position)
    pcall(function() humanoid.Sit = false end)
    pcall(function() hrp.Anchored = false end)
    hrp.CFrame = lookAt
end
local hatchedByUUID: {[string]: boolean} = {}
local function getUUID(egg: Instance) return egg:GetAttribute("OBJECT_UUID") or tostring(egg) end

-- ======= Capacity (base only) từ DataService =======
local DataService
pcall(function()
    DataService = require(ReplicatedStore.Modules.DataService)
end)

local function updateCapacityFromDataService()
    if not DataService then return end
    local data
    local ok = pcall(function() data = DataService:GetData() end)
    if not ok or type(data) ~= "table" then return end
    local pets = data.PetsData or {}
    local mutable = pets.MutableStats or {}
    local base = tonumber(mutable.MaxEggsInFarm) or MAX_ACTIVE_EGGS
    if base ~= MAX_ACTIVE_EGGS then
        MAX_ACTIVE_EGGS = base
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Capacity",
                Text  = ("Max eggs (base) = %d"):format(MAX_ACTIVE_EGGS),
                Duration = 3
            })
        end)
    end
end
game:GetService("RunService"):Set3dRenderingEnabled(false)
-- khởi tạo & cập nhật định kỳ
task.spawn(function()
    -- đợi dữ liệu lên lần đầu
    for i=1,50 do
        updateCapacityFromDataService()
        if MAX_ACTIVE_EGGS and MAX_ACTIVE_EGGS > 0 then break end
        task.wait(0.2)
    end
    -- cập nhật sau mỗi vài giây (nếu bạn nâng cấp giữa chừng)
    while true do
        task.wait(5)
        updateCapacityFromDataService()
    end
end)

-- ===================== WORKER 1: AUTO HATCH (farm-based) =====================
task.spawn(function()
    notify("Auto Hatch", "Đang bật tự động mở trứng (theo farm)…", 3)
    while true do
        task.wait(SCAN_INTERVAL)

        if not character or not character.Parent then
            character = player.Character or player.CharacterAdded:Wait()
            humanoid  = character:WaitForChild("Humanoid")
            hrp       = character:WaitForChild("HumanoidRootPart")
        end

        local eggs = getOwnedFarmEggs()
        table.sort(eggs, function(a,b)
            local ar = isReadyToHatch(a.inst)
            local br = isReadyToHatch(b.inst)
            if ar ~= br then return ar and not br end
            local at = (typeof(a.tth)=="number" and a.tth or math.huge)
            local bt = (typeof(b.tth)=="number" and b.tth or math.huge)
            return at < bt
        end)

        for _, e in ipairs(eggs) do
            local egg = e.inst
            local uuid = getUUID(egg)
            if not hatchedByUUID[uuid] and isReadyToHatch(egg) then
                teleportNearEgg(egg, TELEPORT_OFFSET_Z)
                if isReadyToHatch(egg) then
                    local ok, err = pcall(function()
                        PetEggService:FireServer("HatchPet", egg)
                    end)
                    if ok then
                        hatchedByUUID[uuid] = true
                        notify("Hatch", ("Đã mở: %s"):format(egg:GetAttribute("EggName") or "Egg"), 2)
                    else
                        notify("Hatch", "HatchPet lỗi: "..tostring(err), 4)
                    end
                end
            end
        end
    end
end)

--Anti afk
task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20change%20pet.lua", true))()
end)

--Auto slot
task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20slot.lua", true))()
end)

--Buy egg
task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/buy%20common%20egg", true))()
end)

--Equip ostrich
task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/evxncodes/mainroblox/main/anti-afk", true))()
end)

--Auto gift
task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/auto%20gift%20pet.lua"))()
end)
-- ===================== WORKER 2: AUTO PLANT =====================
task.spawn(function()
    notify("Auto Plant", "Đang bật tự động trồng trứng…", 3)
    while true do
        local active = countActiveOwnedEggs()
        if active < MAX_ACTIVE_EGGS then
            local tool, baseName, count = getTool()
            if tool then
                if tool.Parent ~= character then
                    pcall(function() humanoid:EquipTool(tool) end)
                    debugPrint(("Equip tool: %s"):format(tool.Name))
                else
                    debugPrint(("Tool đã equip: %s"):format(tool.Name))
                end

                local cf = getValidCFrame()
                if cf then
                    local pos = cf.Position
                    local v3arg
                    local okArg = pcall(function()
                        -- Dùng đúng vector.create
                        v3arg = vector.create(pos.X, pos.Y, pos.Z)
                    end)
                    if okArg and v3arg then
                        local ok, err = pcall(function()
                            PetEggService:FireServer("CreateEgg", v3arg)
                        end)
                        if ok then
                            notify("Plant", ("Trồng '%s' tại (%.1f, %.1f, %.1f)"):format(baseName or "Egg", pos.X, pos.Y, pos.Z), 2)
                        else
                            notify("Plant", "CreateEgg lỗi: "..tostring(err), 4)
                        end
                    else
                        notify("Plant", "vector.create không khả dụng trên client này", 4)
                    end
                else
                    debugPrint("⚠️ Không tìm thấy vị trí hợp lệ trong PetArea")
                end
            end
        end
        task.wait(math.random() * (PLANT_INTERVAL_MAX - PLANT_INTERVAL_MIN) + PLANT_INTERVAL_MIN)
    end
end)
