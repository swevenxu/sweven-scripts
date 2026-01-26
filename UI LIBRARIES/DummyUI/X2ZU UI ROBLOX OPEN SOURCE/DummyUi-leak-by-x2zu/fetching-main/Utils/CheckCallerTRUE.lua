local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enemies = workspace:WaitForChild("Enemies")

LocalPlayer.CharacterAdded:Connect(function(new)
	Character = new
	HumanoidRootPart = new:WaitForChild("HumanoidRootPart")
	Humanoid = new:WaitForChild("Humanoid")
end)

if game.PlaceId == 2753915549 then
	w1 = true
elseif game.PlaceId == 4442272183 then
	w2 = true
elseif game.PlaceId == 7449423635 then
	w3 = true
end

VerifyEnemie = function(v)
	if type(v) == 'string' then
		return (Enemies:FindFirstChild(v) and Enemies:FindFirstChild(v).Humanoid.Health >= 0) or (ReplicatedStorage:FindFirstChild(v) and ReplicatedStorage:FindFirstChild(v).Humanoid.Health >= 0)
	end
end

return function()
	local Level = LocalPlayer.Data.Level.Value
	if w1 then
		if (Level <= 9) then
			if tostring(LocalPlayer.Team) == "Pirates" then
				return {
					[1] = "Bandit",
					[2] = "BanditQuest1",
					[3] = 1,
					[4] = CFrame.new(1060, 16, 1547),
				}
			else
				return {
					[1] = "Trainee",
					[2] = "MarineQuest",
					[3] = 1,
					[4] = CFrame.new(-2709, 24, 2103),
				}
			end
		elseif (Level >= 10) and (Level <= 14) then
			return {
				[1] = "Monkey",
				[2] = "JungleQuest",
				[3] = 1,
				[4] = CFrame.new(-1601, 36, 153),
			}
		elseif (Level >= 15 and Level <= 29) then
			if VerifyEnemie("The Gorilla King") and (Level >= 25) then
				return {
					[1] = "The Gorilla King",
					[2] = "JungleQuest",
					[3] = 3,
					[4] = CFrame.new(-1601, 36, 153),
				}
			else
				return {
					[1] = "Gorilla",
					[2] = "JungleQuest",
					[3] = 2,
					[4] = CFrame.new(-1601, 36, 153),
				}
			end
		elseif (Level >= 30) and (Level <= 39) then
			return {
				[1] = "Pirate",
				[2] = "BuggyQuest1",
				[3] = 1,
				[4] = CFrame.new(-1140, 4, 3837),
			}
		elseif Level >= 40 and Level <= 59 then
			if VerifyEnemie("Chef") and Level >= 55 then
				return {
					[1] = "Chef",
					[2] = "BuggyQuest1",
					[3] = 3,
					[4] = CFrame.new(-1140, 4, 3827),
				}
			else
				return {
					[1] = "Brute",
					[2] = "BuggyQuest1",
					[3] = 2,
					[4] = CFrame.new(-1140, 4, 3827),
				}
			end
		elseif (Level >= 60 and Level <= 74) then
			return {
				[1] = "Desert Bandit",
				[2] = "DesertQuest",
				[3] = 1,
				[4] = CFrame.new(896, 6, 4390),
			}
		elseif (Level >= 75 and Level <= 89) then
			return {
				[1] = "Desert Officer",
				[2] = "DesertQuest",
				[3] = 2,
				[4] = CFrame.new(896, 6, 4390),
			}
		elseif (Level >= 90 and Level <= 99) then
			return {
				[1] = "Snow Bandit",
				[2] = "SnowQuest",
				[3] = 1,
				[4] = CFrame.new(1386, 87, -1298),
			}
		elseif (Level >= 100 and Level <= 119) then
			if VerifyEnemie("Yeti") and (Level >= 110) then
				return {
					[1] = "Yeti",
					[2] = "SnowQuest",
					[3] = 3,
					[4] = CFrame.new(1386, 87, -1298),
				}
			else
				return {
					[1] = "Snowman",
					[2] = "SnowQuest",
					[3] = 2,
					[4] = CFrame.new(1386, 87, -1298),
				}
			end
		elseif (Level >= 120 and Level <= 149) then
			if VerifyEnemie("Vice Admiral") and Level > 129 then
				return {
					[1] = "Vice Admiral",
					[2] = "MarineQuest2",
					[3] = 2,
					[4] = CFrame.new(-5035, 28, 4324),
				}
			else
				return {
					[1] = "Chief Petty Officer",
					[2] = "MarineQuest2",
					[3] = 1,
					[4] = CFrame.new(-5035, 28, 4324),
				}
			end
		elseif (Level >= 150 and Level <= 174) then
			return {
				[1] = "Sky Bandit",
				[2] = "SkyQuest",
				[3] = 1,
				[4] = CFrame.new(-4842, 717, -2623),
			}
		elseif (Level >= 175 and Level <= 189) then
			return {
				[1] = "Dark Master",
				[2] = "SkyQuest",
				[3] = 2,
				[4] = CFrame.new(-4842, 717, -2623),
			}
		elseif (Level >= 190 and Level <= 209) then
			return {
				[1] = "Prisoner",
				[2] = "PrisonerQuest",
				[3] = 1,
				[4] = CFrame.new(5310, 0, 474),
			}
		elseif (Level >= 210 and Level <= 249) then
			return {
				[1] = "Dangerous Prisoner",
				[2] = "PrisonerQuest",
				[3] = 2,
				[4] = CFrame.new(5310, 0, 474),
			}
		elseif (Level >= 250 and Level <= 274) then
			return {
				[1] = "Toga Warrior",
				[2] = "ColosseumQuest",
				[3] = 1,
				[4] = CFrame.new(-1577, 7, -2984),
			}
		elseif (Level >= 275 and Level <= 299) then
			return {
				[1] = "Gladiator",
				[2] = "ColosseumQuest",
				[3] = 2,
				[4] = CFrame.new(-1577, 7, -2984),
			}
		elseif (Level >= 300 and Level <= 324) then
			return {
				[1] = "Military Soldier",
				[2] = "MagmaQuest",
				[3] = 1,
				[4] = CFrame.new(-5316, 12, 8517),
			}
		elseif (Level >= 325 and Level <= 374) then
			if VerifyEnemie("Magma Admiral") and Level > 349 then
				return {
					[1] = "Magma Admiral",
					[2] = "MagmaQuest",
					[3] = 3,
					[4] = CFrame.new(-5316, 12, 8517),
				}
			else
				return {
					[1] = "Military Spy",
					[2] = "MagmaQuest",
					[3] = 2,
					[4] = CFrame.new(-5316, 12, 8517),
				}
			end
		elseif (Level >= 375 and Level <= 399) then
			if (Vector3.new(61122.65234375, 18.497442245483, 1569.3997802734) - HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
			end
			return {
				[1] = "Fishman Warrior",
				[2] = "FishmanQuest",
				[3] = 1,
				[4] = CFrame.new(61122, 18, 1569),
			}
		elseif (Level >= 400 and Level <= 449) then
			if (Vector3.new(61122.65234375, 18.497442245483, 1569.3997802734) - HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
			end
			if VerifyEnemie("Fishman Lord") and Level > 424 then
				return {
					[1] = "Fishman Lord",
					[2] = "FishmanQuest",
					[3] = 3,
					[4] = CFrame.new(61122, 18, 1569),
				}
			else
				return {
					[1] = "Fishman Commando",
					[2] = "FishmanQuest",
					[3] = 2,
					[4] = CFrame.new(61122, 18, 1569),
				}
			end
		elseif (Level >= 450 and Level <= 474) then
			if (Vector3.new(-7859.09814, 5544.19043, -381.476196) - HumanoidRootPart.Position).Magnitude > 20000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
			end
			return {
				[1] = "God's Guard",
				[2] = "SkyExp1Quest",
				[3] = 1,
				[4] = CFrame.new(-4721, 845, -1953),
			}
		elseif (Level >= 475 and Level <= 524) then
			if (Vector3.new(-7863, 5545, -378) - HumanoidRootPart.Position).Magnitude > 20000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
			end
			if VerifyEnemie("Wysper") and Level > 499 then
				return {
					[1] = "Wysper",
					[2] = "SkyExp1Quest",
					[3] = 3,
					[4] = CFrame.new(-7863, 5545, -378),
				}
			else
				return {
					[1] = "Shanda",
					[2] = "SkyExp1Quest",
					[3] = 2,
					[4] = CFrame.new(-7863, 5545, -378),
				}
			end
		elseif (Level >= 525 and Level <= 549) then
			if (Vector3.new(-7906.81592, 5634.6626, -1411.99194) - HumanoidRootPart.Position).Magnitude > 20000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
			end
			return {
				[1] = "Royal Squad",
				[2] = "SkyExp2Quest",
				[3] = 1,
				[4] = CFrame.new(-7903, 5635, -1410),
			}
		elseif (Level >= 550 and Level <= 624) then
			if (Vector3.new(-7906.81592, 5634.6626, -1411.99194) - HumanoidRootPart.Position).Magnitude > 20000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
			end
			if VerifyEnemie("Thunder God") and Level > 574 then
				return {
					[1] = "Thunder God",
					[2] = "SkyExp2Quest",
					[3] = 3,
					[4] = CFrame.new(-7903, 5635, -1410),
				}
			else
				return {
					[1] = "Royal Soldier",
					[2] = "SkyExp2Quest",
					[3] = 2,
					[4] = CFrame.new(-7903, 5635, -1410),
				}
			end
		elseif (Level >= 625 and Level <= 649) then
			return {
				[1] = "Galley Pirate",
				[2] = "FountainQuest",
				[3] = 1,
				[4] = CFrame.new(5258, 38, 4050),
			}
		elseif (Level >= 650) then
			if VerifyEnemie("Cyborg") and Level > 674 then
				return {
					[1] = "Cyborg",
					[2] = "FountainQuest",
					[3] = 3,
					[4] = CFrame.new(5258, 38, 4050),
				}
			else
				return {
					[1] = "Galley Captain",
					[2] = "FountainQuest",
					[3] = 2,
					[4] = CFrame.new(5258, 38, 4050),
				}
			end
		end
	elseif w2 then
		if (Level >= 700) and (Level <= 724) then
			return {
				[1] = "Raider",
				[2] = "Area1Quest",
				[3] = 1,
				[4] = CFrame.new(-427, 72, 1835),
			}
		elseif (Level >= 725) and (Level <= 774) then
			if VerifyEnemie("Diamond") and (Level > 749) then
				return {
					[1] = "Diamond",
					[2] = "Area1Quest",
					[3] = 3,
					[4] = CFrame.new(-427, 72, 1835),
				}
			else
				return {
					[1] = "Mercenary",
					[2] = "Area1Quest",
					[3] = 2,
					[4] = CFrame.new(-427, 72, 1835),
				}
			end
		elseif (Level >= 775) and (Level <= 799) then
			return {
				[1] = "Swan Pirate",
				[2] = "Area2Quest",
				[3] = 1,
				[4] = CFrame.new(635, 73, 917),
			}
		elseif (Level >= 800) and (Level <= 874) then
			if VerifyEnemie("Jeremy") and (Level > 849) then
				return {
					[1] = "Jeremy",
					[2] = "Area2Quest",
					[3] = 3,
					[4] = CFrame.new(635, 73, 917),
				}
			else
				return {
					[1] = "Factory Staff",
					[2] = "Area2Quest",
					[3] = 2,
					[4] = CFrame.new(635, 73, 917),
				}
			end
		elseif (Level >= 875) and (Level <= 899) then
			return {
				[1] = "Marine Lieutenant",
				[2] = "MarineQuest3",
				[3] = 1,
				[4] = CFrame.new(-2440, 73, -3217),
			}
		elseif (Level >= 900) and (Level <= 949) then
			if VerifyEnemie("Ortibus") and (Level > 924) then
				return {
					[1] = "Ortibus",
					[2] = "MarineQuest3",
					[3] = 3,
					[4] = CFrame.new(-2440, 73, -3217),
				}
			else
				return {
					[1] = "Marine Captain",
					[2] = "MarineQuest3",
					[3] = 2,
					[4] = CFrame.new(-2440, 73, -3217),
				}
			end
		elseif (Level >= 950) and (Level <= 974) then
			return {
				[1] = "Zombie",
				[2] = "ZombieQuest",
				[3] = 1,
				[4] = CFrame.new(-5494, 48, -794),
			}
		elseif (Level >= 975) and (Level <= 999) then
			return {
				[1] = "Vampire",
				[2] = "ZombieQuest",
				[3] = 2,
				[4] = CFrame.new(-5494, 48, -794),
			}
		elseif (Level >= 1000) and (Level <= 1049) then
			return {
				[1] = "Snow Trooper",
				[2] = "SnowMountainQuest",
				[3] = 1,
				[4] = CFrame.new(607, 401, -5370),
			}
		elseif (Level >= 1050) and (Level <= 1099) then
			return {
				[1] = "Winter Warrior",
				[2] = "SnowMountainQuest",
				[3] = 2,
				[4] = CFrame.new(607, 401, -5370),
			}
		elseif (Level >= 1100) and (Level <= 1124) then
			return {
				[1] = "Lab Subordinate",
				[2] = "IceSideQuest",
				[3] = 1,
				[4] = CFrame.new(-6061, 15, -4902),
			}
		elseif (Level >= 1125) and (Level <= 1174) then
			if VerifyEnemie("Smoke Admiral") and (Level > 1149) then
				return {
					[1] = "Smoke Admiral",
					[2] = "IceSideQuest",
					[3] = 3,
					[4] = CFrame.new(-6061, 15, -4902),
				}
			else
				return {
					[1] = "Horned Warrior",
					[2] = "IceSideQuest",
					[3] = 2,
					[4] = CFrame.new(-6061, 15, -4902),
				}
			end
		elseif (Level >= 1175) and (Level <= 1199) then
			return {
				[1] = "Magma Ninja",
				[2] = "FireSideQuest",
				[3] = 1,
				[4] = CFrame.new(-5429, 15, -5297),
			}
		elseif (Level >= 1200) and (Level <= 1249) then
			return {
				[1] = "Lava Pirate",
				[2] = "FireSideQuest",
				[3] = 2,
				[4] = CFrame.new(-5429, 15, -5297),
			}
		elseif (Level >= 1250) and (Level <= 1274) then
			if (Vector3.new(1037.80127, 125.092171, 32911.6016) - HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
			end
			return {
				[1] = "Ship Deckhand",
				[2] = "ShipQuest1",
				[3] = 1,
				[4] = CFrame.new(1040, 125, 32911),
			}
		elseif (Level >= 1275) and (Level <= 1299) then
			if (Vector3.new(1037.80127, 125.092171, 32911.6016) - HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
			end
			return {
				[1] = "Ship Engineer",
				[2] = "ShipQuest1",
				[3] = 2,
				[4] = CFrame.new(1040, 125, 32911),
			}
		elseif (Level >= 1300) and (Level <= 1324) then
			if (Vector3.new(968.80957, 125.092171, 33244.125) - HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
			end
			return {
				[1] = "Ship Steward",
				[2] = "ShipQuest2",
				[3] = 1,
				[4] = CFrame.new(971, 125, 33245),
			}
		elseif (Level >= 1325) and (Level <= 1349) then
			if (Vector3.new(968.80957, 125.092171, 33244.125) - HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
			end
			return {
				[1] = "Ship Officer",
				[2] = "ShipQuest2",
				[3] = 2,
				[4] = CFrame.new(971, 125, 33245),
			}
		elseif (Level >= 1350) and (Level <= 1374) then
			return {
				[1] = "Arctic Warrior",
				[2] = "FrostQuest",
				[3] = 1,
				[4] = CFrame.new(5668, 28, -6484),
			}
		elseif (Level >= 1375) and (Level <= 1424) then
			if VerifyEnemie("Awakened Ice Admiral") and (Level > 1399) then
				return {
					[1] = "Awakened Ice Admiral",
					[2] = "FrostQuest",
					[3] = 3,
					[4] = CFrame.new(5668, 28, -6484),
				}
			else
				return {
					[1] = "Snow Lurker",
					[2] = "FrostQuest",
					[3] = 2,
					[4] = CFrame.new(5668, 28, -6484),
				}
			end
		elseif (Level >= 1425) and (Level <= 1449) then
			return {
				[1] = "Sea Soldier",
				[2] = "ForgottenQuest",
				[3] = 1,
				[4] = CFrame.new(-3054, 236, -10147),
			}
		elseif (Level >= 1450) then
			if VerifyEnemie("Tide Keeper") and (Level > 1474) then
				return {
					[1] = "Tide Keeper",
					[2] = "ForgottenQuest",
					[3] = 3,
					[4] = CFrame.new(-3054, 236, -10147),
				}
			else
				return {
					[1] = "Water Fighter",
					[2] = "ForgottenQuest",
					[3] = 2,
					[4] = CFrame.new(-3054, 236, -10147),
				}
			end
		end
	elseif w3 then
		if (Level >= 1500) and (Level <= 1524) then
			return {
				[1] = "Pirate Millionaire",
				[2] = "PiratePortQuest",
				[3] = 1,
				[4] = CFrame.new(-450, 107, 5950),
			}
		elseif (Level >= 1525) and (Level <= 1574) then
			if VerifyEnemie("Stone") and (Level > 1549) then
				return {
					[1] = "Stone",
					[2] = "PiratePortQuest",
					[3] = 3,
					[4] = CFrame.new(-450, 107, 5950),
				}
			else
				return {
					[1] = "Pistol Billionaire",
					[2] = "PiratePortQuest",
					[3] = 2,
					[4] = CFrame.new(-450, 107, 5950),
				}
			end
		elseif (Level >= 1575) and (Level <= 1599) then
			return {
				[1] = "Dragon Crew Warrior",
				[2] = "DragonCrewQuest",
				[3] = 1,
				[4] = CFrame.new(6735, 126, -711),
			}
		elseif (Level >= 1600) and (Level <= 1624) then
			return {
				[1] = "Dragon Crew Archer",
				[2] = "DragonCrewQuest",
				[3] = 2,
				[4] = CFrame.new(6735, 126, -711),
			}
		elseif (Level >= 1625) and (Level <= 1649) then
			return {
				[1] = "Hydra Enforcer",
				[2] = "VenomCrewQuest",
				[3] = 1,
				[4] = CFrame.new(5446, 601, 749),
			}
		elseif (Level >= 1650) and (Level <= 1699) then
			if VerifyEnemie("Hydra Leader") and (Level > 1674) then
				return {
					[1] = "Hydra Leader",
					[2] = "VenomCrewQuest",
					[3] = 3,
					[4] = CFrame.new(5446, 601, 749),
				}
			else
				return {
					[1] = "Venomous Assailant",
					[2] = "VenomCrewQuest",
					[3] = 2,
					[4] = CFrame.new(5446, 601, 749),
				}
			end
		elseif (Level >= 1700) and (Level <= 1724) then
			return {
				[1] = "Marine Commodore",
				[2] = "MarineTreeIsland",
				[3] = 1,
				[4] = CFrame.new(2179, 28, -6740),
			}
		elseif (Level >= 1725) and (Level <= 1774) then
			if VerifyEnemie("Kilo Admiral") and (Level > 1749) then
				return {
					[1] = "Kilo Admiral",
					[2] = "MarineTreeIsland",
					[3] = 3,
					[4] = CFrame.new(2179, 28, -6740),
				}
			else
				return {
					[1] = "Marine Rear Admiral",
					[2] = "MarineTreeIsland",
					[3] = 2,
					[4] = CFrame.new(2179, 28, -6740),
				}
			end
		elseif (Level >= 1775) and (Level <= 1799) then
			return {
				[1] = "Fishman Raider",
				[2] = "DeepForestIsland3",
				[3] = 1,
				[4] = CFrame.new(-10582, 331, -8757),
			}
		elseif (Level >= 1800) and (Level <= 1824) then
			return {
				[1] = "Fishman Captain",
				[2] = "DeepForestIsland3",
				[3] = 2,
				[4] = CFrame.new(-10583, 331, -8759),
			}
		elseif (Level >= 1825) and (Level <= 1849) then
			return {
				[1] = "Forest Pirate",
				[2] = "DeepForestIsland",
				[3] = 1,
				[4] = CFrame.new(-13232, 332, -7626),
			}
		elseif (Level >= 1850) and (Level <= 1899) then
			if VerifyEnemie("Captain Elephant") and (Level > 1874) then
				return {
					[1] = "Captain Elephant",
					[2] = "DeepForestIsland",
					[3] = 3,
					[4] = CFrame.new(-13232, 332, -7626),
				}
			else
				return {
					[1] = "Mythological Pirate",
					[2] = "DeepForestIsland",
					[3] = 2,
					[4] = CFrame.new(-13232, 332, -7626),
				}
			end
		elseif (Level >= 1900) and (Level <= 1924) then
			return {
				[1] = "Jungle Pirate",
				[2] = "DeepForestIsland2",
				[3] = 1,
				[4] = CFrame.new(-12682, 390, -9902),
			}
		elseif (Level >= 1925) and (Level <= 1974) then
			if VerifyEnemie("Beautiful Pirate") and (Level > 1949) then
				return {
					[1] = "Beautiful Pirate",
					[2] = "DeepForestIsland2",
					[3] = 3,
					[4] = CFrame.new(-12682, 390, -9902),
				}
			else
				return {
					[1] = "Musketeer Pirate",
					[2] = "DeepForestIsland2",
					[3] = 2,
					[4] = CFrame.new(-12682, 390, -9902),
				}
			end
		elseif (Level >= 1975) and (Level <= 1999) then
			return {
				[1] = "Reborn Skeleton",
				[2] = "HauntedQuest1",
				[3] = 1,
				[4] = CFrame.new(-9481, 142, 5566),
			}
		elseif (Level >= 2000) and (Level <= 2024) then
			return {
				[1] = "Living Zombie",
				[2] = "HauntedQuest1",
				[3] = 2,
				[4] = CFrame.new(-9481, 142, 5566),
			}
		elseif (Level >= 2025) and (Level <= 2049) then
			return {
				[1] = "Demonic Soul",
				[2] = "HauntedQuest2",
				[3] = 1,
				[4] = CFrame.new(-9517, 178, 6078),
			}
		elseif (Level >= 2050) and (Level <= 2074) then
			return {
				[1] = "Posessed Mummy",
				[2] = "HauntedQuest2",
				[3] = 2,
				[4] = CFrame.new(-9517, 178, 6078),
			}
		elseif (Level >= 2075) and (Level <= 2099) then
			return {
				[1] = "Peanut Scout",
				[2] = "NutsIslandQuest",
				[3] = 1,
				[4] = CFrame.new(-2105, 37, -10195),
			}
		elseif (Level >= 2100) and (Level <= 2124) then
			return {
				[1] = "Peanut President",
				[2] = "NutsIslandQuest",
				[3] = 2,
				[4] = CFrame.new(-2105, 37, -10195),
			}
		elseif (Level >= 2125) and (Level <= 2149) then
			return {
				[1] = "Ice Cream Chef",
				[2] = "IceCreamIslandQuest",
				[3] = 1,
				[4] = CFrame.new(-819, 64, -10967),
			}
		elseif (Level >= 2150) and (Level <= 2199) then
			if VerifyEnemie("Cake Queen") and (Level > 2174) then
				return {
					[1] = "Cake Queen",
					[2] = "IceCreamIslandQuest",
					[3] = 3,
					[4] = CFrame.new(-819, 64, -10967),
				}
			else
				return {
					[1] = "Ice Cream Commander",
					[2] = "IceCreamIslandQuest",
					[3] = 2,
					[4] = CFrame.new(-819, 64, -10967),
				}
			end
		elseif (Level >= 2200) and (Level <= 2224) then
			return {
				[1] = "Cookie Crafter",
				[2] = "CakeQuest1",
				[3] = 1,
				[4] = CFrame.new(-2022, 36, -12030),
			}
		elseif (Level >= 2225) and (Level <= 2249) then
			return {
				[1] = "Cake Guard",
				[2] = "CakeQuest1",
				[3] = 2,
				[4] = CFrame.new(-2022, 36, -12030),
			}
		elseif (Level >= 2250) and (Level <= 2274) then
			return {
				[1] = "Baking Staff",
				[2] = "CakeQuest2",
				[3] = 1,
				[4] = CFrame.new(-1928, 37, -12840),
			}
		elseif (Level >= 2275) and (Level <= 2299) then
			return {
				[1] = "Head Baker",
				[2] = "CakeQuest2",
				[3] = 2,
				[4] = CFrame.new(-1928, 37, -12840),
			}
		elseif (Level >= 2300) and (Level <= 2324) then
			return {
				[1] = "Cocoa Warrior",
				[2] = "ChocQuest1",
				[3] = 1,
				[4] = CFrame.new(231, 23, -12200),
			}
		elseif (Level >= 2325) and (Level <= 2349) then
			return {
				[1] = "Chocolate Bar Battler",
				[2] = "ChocQuest1",
				[3] = 2,
				[4] = CFrame.new(231, 23, -12200),
			}
		elseif (Level >= 2350) and (Level <= 2374) then
			return {
				[1] = "Sweet Thief",
				[2] = "ChocQuest2",
				[3] = 1,
				[4] = CFrame.new(151, 23, -12774),
			}
		elseif (Level >= 2375) and (Level <= 2400) then
			return {
				[1] = "Candy Rebel",
				[2] = "ChocQuest2",
				[3] = 2,
				[4] = CFrame.new(151, 23, -12774),
			}
		elseif (Level >= 2400) and (Level <= 2424) then
			return {
				[1] = "Candy Pirate",
				[2] = "CandyQuest1",
				[3] = 1,
				[4] = CFrame.new(-1149, 13, -14445),
			}
		elseif (Level >= 2425) and (Level <= 2449) then
			return {
				[1] = "Snow Demon",
				[2] = "CandyQuest1",
				[3] = 2,
				[4] = CFrame.new(-1149, 13, -14445),
				[5] = CFrame.new(-978, 13, -14538)
			}
		elseif (Level >= 2450) and (Level <= 2474) then
			return {
				[1] = "Isle Outlaw",
				[2] = "TikiQuest1",
				[3] = 1,
				[4] = CFrame.new(-16549, 55, -179),
			}
		elseif (Level >= 2475) and (Level <= 2499) then
			return {
				[1] = "Island Boy",
				[2] = "TikiQuest1",
				[3] = 2,
				[4] = CFrame.new(-16549, 55, -179),
			}
		elseif (Level >= 2500) and (Level <= 2549) then
			return {
				[1] = "Isle Champion",
				[2] = "TikiQuest2",
				[3] = 2,
				[4] = CFrame.new(-16541, 54, 1051),
			}
		elseif (Level >= 2550) and (Level <= 2574) then
			return {
				[1] = "Serpent Hunter",
				[2] = "TikiQuest3",
				[3] = 1,
				[4] = CFrame.new(-16665, 104, 1579),
			}
		elseif Level >= 2575 then
			return {
				[1] = "Skull Slayer",
				[2] = "TikiQuest3",
				[3] = 2,
				[4] = CFrame.new(-16665, 104, 1579),
			}
		end
	end
end
