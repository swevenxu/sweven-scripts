local Executor = string.upper(identifyexecutor())
local Blacklist_Executor = table.find({"SOLARA", "XENO"}, Executor)
local hookmetamethod = (not Blacklist_Executor and hookmetamethod) or (function(...) return ... end)
local hookfunction = (not Blacklist_Executor and hookfunction) or (function(...) return ... end)
local islclosure = (not Blacklist_Executor and islclosure) or (function(...) return ... end)
local sethiddenproperty = sethiddenproperty or (function(...) return ... end)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
task.delay(2, function()
	if Blacklist_Executor then
		--if not _G.UnlockXeno then
		--	LocalPlayer:Kick("Current Executor is Not Support: " .. tostring(identifyexecutor()))
		--end
	else
		if hookfunction and not islclosure(hookfunction) then
			pcall(function()
				hookfunction(require(ReplicatedStorage:WaitForChild("Effect").Container.Death), function()
					
				end)
				hookfunction(require(ReplicatedStorage:WaitForChild("Effect").Container.Respawn), function()
					
				end)
				hookfunction(require(ReplicatedStorage:WaitForChild("Effect").Container.RaceAwakenings.CyborgDrone), function()
					
				end)
				hookfunction(require(ReplicatedStorage:WaitForChild("GuideModule")).ChangeDisplayedNPC, function()
					return
				end)
			end)
		end
		if require then
			pcall(function()
				local Camera = require(ReplicatedStorage:WaitForChild("Util").CameraShaker)
				Camera:Stop()
			end)
		end
	end
end)
