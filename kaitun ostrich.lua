


-- ===================== CONFIG =====================
local SCAN_INTERVAL       = 0.5      -- giây, chu kỳ quét hatch
local MAX_SCAN_RADIUS     = 200      -- bán kính tìm egg để hatch
local TELEPORT_OFFSET_Z   = 2        -- lệch +Z local của egg khi teleport
local USE_LOCAL_Z         = true     -- true: +Z theo local egg; false: +Z theo world
local ANNOUNCE            = true     -- gửi notification
local PLANT_INTERVAL_MIN  = 0.5      -- khoảng nghỉ giữa 2 lần trồng (random)
local PLANT_INTERVAL_MAX  = 1.0
local MAX_ACTIVE_EGGS     = 8        -- giới hạn số trứng bạn sở hữu đang tồn tại (tránh spam)

-- Thứ tự ưu tiên dùng khi chọn tool để trồng
local eggPriority = {
    "Common Egg",
    "Uncommon Egg",
    "Rare Egg",
    "Rare Summer Egg",
    "Legendary Egg",
    "Mythical Egg",
    "Bug Egg",
    "Fall Egg"
}

-- ===================== SERVICES / MODULES =====================
local Players            = game:GetService("Players")
local ReplicatedStore    = game:GetService("ReplicatedStorage") -- giữ đúng tên biến bạn dùng trước đó
local CollectionService  = game:GetService("CollectionService")
local RunService         = game:GetService("RunService")
local StarterGui         = game:GetService("StarterGui")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local hrp       = character:WaitForChild("HumanoidRootPart")

local PetEggService = ReplicatedStore:WaitForChild("GameEvents"):WaitForChild("PetEggService")

-- Bạn đã có sẵn các module này:
local GetFarm      = require(ReplicatedStore.Modules.GetFarm)
local Manhattan2D  = require(ReplicatedStore.Code.Manhattan2D)
local PetsService  = require(ReplicatedStore.Modules.PetServices.PetsService)

-- ===================== UTILS =====================
local function debugPrint(...)
	print("[AutoEgg]", ...)
end

local function notify(title, text, dur)
	if not ANNOUNCE then return end
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = dur or 3
		})
	end)
end

local function refreshCharacterRefs()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid  = character:WaitForChild("Humanoid")
	hrp       = character:WaitForChild("HumanoidRootPart")
end

local function dist(a: Vector3, b: Vector3)
	return (a - b).Magnitude
end

-- ===================== getValidCFrame (bạn cung cấp) =====================
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

-- ===================== Tool parsing & selection =====================
-- Parse "Legendary Egg x12" -> baseName="Legendary Egg", count=12
local function parseToolName(name: string): (string, number)
	local base, cnt = name:match("^%s*(.-)%s+x(%d+)%s*$")
	if base and cnt then
		base = base:gsub("^%s+", ""):gsub("%s+$", "")
		return base, tonumber(cnt)
	end
	name = name:gsub("^%s+", ""):gsub("%s+$", "")
	return name, 1
end

-- Trả về: bestToolInstance, baseName, count
local function getTool()
	local char = player.Character or player.CharacterAdded:Wait()

	-- Thu thập tool từ cả Backpack và Character (đang equip)
	local candidates = {}
	local function collect(container)
		for _, tool in ipairs(container:GetChildren()) do
			if tool:IsA("Tool") then
				local base, count = parseToolName(tool.Name)
				table.insert(candidates, {
					inst = tool,
					base = base,
					count = count,
					parent = container
				})
			end
		end
	end
	collect(player.Backpack)
	collect(char)

	-- Tool đang equip (nếu có)
	local equipped = nil
	for _, t in ipairs(candidates) do
		if t.parent == char then
			equipped = t
			break
		end
	end

	-- Duyệt theo thứ tự ưu tiên
	for _, want in ipairs(eggPriority) do
		-- 1) Nếu đã equip đúng loại ưu tiên -> dùng luôn
		if equipped and equipped.base == want then
			debugPrint(("✅ Tool đang equip: %s (x%d)"):format(equipped.inst.Name, equipped.count))
			return equipped.inst, equipped.base, equipped.count
		end
		-- 2) Nếu chưa, chọn tool cùng loại có count lớn nhất (ở Backpack/Character)
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

-- ===================== Egg state helpers =====================
local function isShowTimePassed(egg: Instance)
	local st = egg:GetAttribute("ShowTime")
	if st == nil then return true end
	return st <= workspace:GetServerTimeNow()
end

local function isReadyToHatch(egg: Instance)
	if not egg:IsDescendantOf(workspace) then return false end
	if egg:GetAttribute("OWNER") ~= player.Name then return false end
	if egg:GetAttribute("READY") ~= true then return false end
	if not isShowTimePassed(egg) then return false end
	local tth = egg:GetAttribute("TimeToHatch")
	if typeof(tth) ~= "number" then return false end
	if tth > 0 then return false end
	return true
end

local function teleportNearEgg(egg: Instance, offsetZ: number)
	local pivot = egg:GetPivot()
	local destCF
	if USE_LOCAL_Z then
		destCF = pivot * CFrame.new(0, 0, offsetZ)
	else
		destCF = CFrame.new(pivot.Position + Vector3.new(0, 0, offsetZ))
	end
	local lookAt = CFrame.new(destCF.Position, pivot.Position)
	pcall(function() humanoid.Sit = false end)
	pcall(function() hrp.Anchored = false end)
	hrp.CFrame = lookAt
end

local hatchedByUUID: {[string]: boolean} = {}
local function getUUID(egg: Instance)
	return egg:GetAttribute("OBJECT_UUID") or tostring(egg)
end

local function countActiveOwnedEggs()
	local cnt = 0
	for _, egg in ipairs(CollectionService:GetTagged("PetEggServer")) do
		if egg:GetAttribute("OWNER") == player.Name then
			-- coi là "đang trồng" nếu còn thời gian > 0 hoặc chưa READY
			local tth = egg:GetAttribute("TimeToHatch")
			if (typeof(tth) == "number" and tth > 0) or egg:GetAttribute("READY") ~= true then
				cnt += 1
			end
		end
	end
	return cnt
end

-- ===================== WORKER 1: AUTO HATCH =====================
task.spawn(function()
	notify("Auto Hatch", "Đang bật tự động mở trứng…", 3)
	while true do
		task.wait(SCAN_INTERVAL)

		if not character or not character.Parent then
			refreshCharacterRefs()
		end

		-- Lọc trứng đủ điều kiện quanh bạn
		local near = {}
		for _, egg in ipairs(CollectionService:GetTagged("PetEggServer")) do
			if isReadyToHatch(egg) then
				local d = dist(hrp.Position, egg:GetPivot().Position)
				if d <= MAX_SCAN_RADIUS then
					table.insert(near, {inst = egg, d = d})
				end
			end
		end
		table.sort(near, function(a, b) return a.d < b.d end)

		for _, item in ipairs(near) do
			local egg = item.inst
			local uuid = getUUID(egg)
			if not hatchedByUUID[uuid] then
				teleportNearEgg(egg, TELEPORT_OFFSET_Z)
				-- kiểm lại trước khi gọi remote
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

-- ===================== WORKER 2: AUTO PLANT =====================
task.spawn(function()
	notify("Auto Plant", "Đang bật tự động trồng trứng…", 3)
	while true do
		-- hạn chế số lượng egg đang tồn tại để tránh spam/anti-cheat
		local active = countActiveOwnedEggs()
		if active < MAX_ACTIVE_EGGS then
			-- Lấy tool theo ưu tiên (đã xử lý cả Backpack+Character và tránh nhầm Common/Uncommon)
			local tool, baseName, count = getTool()
			if tool then
				-- Nếu tool chưa ở Character thì equip, còn đang equip sẵn thì khỏi
				if tool.Parent ~= character then
					pcall(function() humanoid:EquipTool(tool) end)
					debugPrint(("Equip tool: %s"):format(tool.Name))
				else
					debugPrint(("Tool đã equip: %s"):format(tool.Name))
				end

				-- Lấy vị trí hợp lệ trong PetArea rồi gửi CreateEgg
				local cf = getValidCFrame()
				if cf then
					local pos = cf.Position
					local v3arg
					local okCreateArg, errCreateArg = pcall(function()
						-- Nhiều game yêu cầu vector.create; nếu không có global này sẽ fail -> báo lỗi
						v3arg = vector.create(pos.X, pos.Y, pos.Z)
					end)
					if okCreateArg and v3arg then
						local ok, err = pcall(function()
							PetEggService:FireServer("CreateEgg", v3arg)
						end)
						if ok then
							notify("Plant", ("Trồng '%s' tại (%.1f, %.1f, %.1f)"):format(baseName or "Egg", pos.X, pos.Y, pos.Z), 2)
						else
							notify("Plant", "CreateEgg lỗi: "..tostring(err), 4)
						end
					else
						notify("Plant", "vector.create không tồn tại trên client này", 4)
					end
				else
					debugPrint("⚠️ Không tìm thấy vị trí hợp lệ trong PetArea")
				end
			else
				-- Không có tool để trồng -> im lặng đợi lần sau
			end
		end

		task.wait(math.random() * (PLANT_INTERVAL_MAX - PLANT_INTERVAL_MIN) + PLANT_INTERVAL_MIN)
	end
end)

-- ===================== HANDLE RESPAWN =====================
player.CharacterAdded:Connect(function()
	task.wait(0.2)
	refreshCharacterRefs()
end)
