local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")

local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local LocalScript = PlayerScripts:FindFirstChildOfClass("LocalScript")
while not LocalScript do
	LocalPlayer.PlayerScripts.ChildAdded:Wait()
	LocalScript = PlayerScripts:FindFirstChildOfClass("LocalScript")
end

local HIT_FUNCTION
if getsenv then
	pcall(function()
		local Success, ScriptEnv = pcall(getsenv, LocalScript)
		if Success and ScriptEnv then
			HIT_FUNCTION = ScriptEnv._G.SendHitsToServer
		end
	end)
end

function GetValidTargets(source)
	local targets = {}
	for _, entity in ipairs(source) do
		local humanoid = entity:FindFirstChild("Humanoid")
		local part = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChildOfClass("BasePart")
		if humanoid and part and humanoid.Health > 0 then
			table.insert(targets, {entity, part})
		end
	end
	return targets
end

return function()
	pcall(function()
		local Character = LocalPlayer.Character
		if not Character then return end

		local rootPart = Character:FindFirstChild("HumanoidRootPart")
		local toolEquipped = Character:FindFirstChildOfClass("Tool")
		if not rootPart or not toolEquipped then return end
		local sources = {
			workspace.Enemies:GetChildren(),
			workspace.Characters:GetChildren()
		}
		for _, source in ipairs(sources) do
			for _, enemy in ipairs(source) do
				local enemyHumanoid = enemy:FindFirstChild("Humanoid")
				local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
				if enemyHumanoid and enemyRoot and enemyHumanoid.Health > 0 then
					local distance = (enemyRoot.Position - rootPart.Position).Magnitude
					if distance <= 100 then
						RegisterAttack:FireServer(0)
						RegisterAttack:FireServer(1)
						RegisterAttack:FireServer(2)
						RegisterAttack:FireServer(3)
						RegisterAttack:FireServer(4)
						local targets = GetValidTargets(source)
						if HIT_FUNCTION then
							HIT_FUNCTION(enemyRoot, targets)
						else
							RegisterHit:FireServer(enemyRoot, targets)
						end
					end
				end
			end
		end
	end)
end
