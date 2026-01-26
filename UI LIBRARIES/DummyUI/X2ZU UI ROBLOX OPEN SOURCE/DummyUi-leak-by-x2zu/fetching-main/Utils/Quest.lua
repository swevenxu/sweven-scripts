local _id : number = game.PlaceId

if _id == 2753915549 then
	w1 = true
elseif _id == 4442272183 then
	w2 = true
elseif _id == 7449423635 then
	w3 = true
end

return function()
	local lv = game:GetService("Players").LocalPlayer.Data.Level.Value
	if w1 then
		if lv >= 1 and lv <= 9 then
			if tostring(game.Players.LocalPlayer.Team) == "Marines" then
				return {
					[1] = "Trainee",
					[2] = 1,
					[3] = "MarineQuest",
					[4] = CFrame.new(-2711.635498046875, 24.834863662719727, 2104.212890625),
				}
			elseif tostring(game.Players.LocalPlayer.Team) == "Pirates" then
				return {
					[1] = "Bandit",
					[2] = 1,
					[3] = "BanditQuest1",
					[4] = CFrame.new(1059.37195, 15.4495068, 1550.4231),
				}
			end
		elseif lv >= 10 and lv <= 14 then
			return {
				[1] = "Monkey",
				[2] = 1,
				[3] = "JungleQuest",
				[4] = CFrame.new(-1598.08911, 35.5501175, 153.377838),
			}
		elseif lv >= 15 and lv <= 29 then
			return {
				[1] = "Gorilla",
				[2] = 2,
				[3] = "JungleQuest",
				[4] = CFrame.new(-1598.08911, 35.5501175, 153.377838),
			}
		elseif lv >= 30 and lv <= 39 then
			return {
				[1] = "Pirate",
				[2] = 1,
				[3] = "BuggyQuest1",
				[4] = CFrame.new(-1141.07483, 4.10001802, 3831.5498),
			}
		elseif lv >= 40 and lv <= 59 then
			return {
				[1] = "Brute",
				[2] = 2,
				[3] = "BuggyQuest1",
				[4] = CFrame.new(-1141.07483, 4.10001802, 3831.5498),
			}
		elseif lv >= 60 and lv <= 74 then
			return {
				[1] = "Desert Bandit",
				[2] = 1,
				[3] = "DesertQuest",
				[4] = CFrame.new(894.488647, 5.14000702, 4392.43359),
			}
		elseif lv >= 75 and lv <= 89 then
			return {
				[1] = "Desert Officer",
				[2] = 2,
				[3] = "DesertQuest",
				[4] = CFrame.new(894.488647, 5.14000702, 4392.43359),
			}
		elseif lv >= 90 and lv <= 99 then
			return {
				[1] = "Snow Bandit",
				[2] = 1,
				[3] = "SnowQuest",
				[4] = CFrame.new(1389.74451, 88.1519318, -1298.90796),
			}
		elseif lv >= 100 and lv <= 119 then
			return {
				[1] = "Snowman",
				[2] = 2,
				[3] = "SnowQuest",
				[4] = CFrame.new(1389.74451, 88.1519318, -1298.90796),
			}
		elseif lv >= 120 and lv <= 149 then
			return {
				[1] = "Chief Petty Officer",
				[2] = 1,
				[3] = "MarineQuest2",
				[4] = CFrame.new(-5039.58643, 27.3500385, 4324.68018),
			}
		elseif lv >= 150 and lv <= 174 then
			return {
				[1] = "Sky Bandit",
				[2] = 1,
				[3] = "SkyQuest",
				[4] = CFrame.new(-4839.53027, 716.368591, -2619.44165),
			}
		elseif lv >= 175 and lv <= 189 then
			return {
				[1] = "Dark Master",
				[2] = 2,
				[3] = "SkyQuest",
				[4] = CFrame.new(-4839.53027, 716.368591, -2619.44165),
			}
		elseif lv >= 190 and lv <= 209 then
			return {
				[1] = "Prisoner",
				[2] = 1,
				[3] = "PrisonerQuest",
				[4] = CFrame.new(5308.93115, 1.65517521, 475.120514),
			}
		elseif lv >= 210 and lv <= 249 then
			return {
				[1] = "Dangerous Prisoner",
				[2] = 2,
				[3] = "PrisonerQuest",
				[4] = CFrame.new(5308.93115, 1.65517521, 475.120514),
			}
		elseif lv >= 250 and lv <= 274 then
			return {
				[1] = "Toga Warrior",
				[2] = 1,
				[3] = "ColosseumQuest",
				[4] = CFrame.new(-1580.04663, 6.35000277, -2986.47534),
			}
		elseif lv >= 275 and lv <= 299 then
			return {
				[1] = "Gladiator",
				[2] = 2,
				[3] = "ColosseumQuest",
				[4] = CFrame.new(-1580.04663, 6.35000277, -2986.47534),
			}
		elseif lv >= 300 and lv <= 324 then
			return {
				[1] = "Military Soldier",
				[2] = 1,
				[3] = "MagmaQuest",
				[4] = CFrame.new(-5313.37012, 10.9500084, 8515.29395),
			}
		elseif lv >= 325 and lv <= 374 then
			return {
				[1] = "Military Spy",
				[2] = 2,
				[3] = "MagmaQuest",
				[4] = CFrame.new(-5313.37012, 10.9500084, 8515.29395),
			}
		elseif lv >= 375 and lv <= 399 then
			if (Vector3.new(61122.65234375, 18.497442245483, 1569.3997802734) - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
			end
			return {
				[1] = "Fishman Warrior",
				[2] = 1,
				[3] = "FishmanQuest",
				[4] = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734),
			}
		elseif lv >= 400 and lv <= 449 then
			if (Vector3.new(61122.65234375, 18.497442245483, 1569.3997802734) - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
			end
			return {
				[1] = "Fishman Commando",
				[2] = 2,
				[3] = "FishmanQuest",
				[4] = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734),
			}
		elseif lv >= 450 and lv <= 474 then
			if (Vector3.new(-7859.09814, 5544.19043, -381.476196) - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 20000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
			end
			return {
				[1] = "God's Guard",
				[2] = 1,
				[3] = "SkyExp1Quest",
				[4] = CFrame.new(-7859.09814, 5544.19043, -381.476196),
			}
		elseif lv >= 475 and lv <= 524 then
			if (Vector3.new(-7863, 5545, -378) - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 20000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
			end
			return {
				[1] = "Shanda",
				[2] = 2,
				[3] = "SkyExp1Quest",
				[4] = CFrame.new(-7859.09814, 5544.19043, -381.476196),
			}
		elseif lv >= 525 and lv <= 549 then
			if (Vector3.new(-7906.81592, 5634.6626, -1411.99194) - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 20000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
			end
			return {
				[1] = "Royal Squad",
				[2] = 1,
				[3] = "SkyExp2Quest",
				[4] = CFrame.new(-7906.81592, 5634.6626, -1411.99194),
			}
		elseif lv >= 550 and lv <= 624 then
			if (Vector3.new(-7906.81592, 5634.6626, -1411.99194) - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 20000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
			end
			return {
				[1] = "Royal Soldier",
				[2] = 2,
				[3] = "SkyExp2Quest",
				[4] = CFrame.new(-7906.81592, 5634.6626, -1411.99194),
			}
		elseif lv >= 625 and lv <= 649 then
			return {
				[1] = "Galley Pirate",
				[2] = 1,
				[3] = "FountainQuest",
				[4] = CFrame.new(5259.81982, 37.3500175, 4050.0293),
			}
		elseif lv >= 650 then
			return {
				[1] = "Galley Captain",
				[2] = 2,
				[3] = "FountainQuest",
				[4] = CFrame.new(5259.81982, 37.3500175, 4050.0293),
			}
		end
	elseif w2 then
		if lv >= 700 and lv <= 724 then
			return {
				[1] = "Raider",
				[2] = 1,
				[3] = "Area1Quest",
				[4] = CFrame.new(-429.543518, 71.7699966, 1836.18188)
			}
		elseif lv >= 725 and lv <= 774 then
			return {
				[1] = "Mercenary",
				[2] = 2,
				[3] = "Area1Quest",
				[4] = CFrame.new(-429.543518, 71.7699966, 1836.18188)
			}
		elseif lv >= 775 and lv <= 799 then
			return {
				[1] = "Swan Pirate",
				[2] = 1,
				[3] = "Area2Quest",
				[4] = CFrame.new(638.43811, 71.769989, 918.282898)
			}
		elseif lv >= 800 and lv <= 874 then
			return {
				[1] = "Factory Staff",
				[2] = 2,
				[3] = "Area2Quest",
				[4] = CFrame.new(632.698608, 73.1055908, 918.666321)
			}
		elseif lv >= 875 and lv <= 899 then
			return {
				[1] = "Marine Lieutenant",
				[2] = 1,
				[3] = "MarineQuest3",
				[4] = CFrame.new(-2440.79639, 71.7140732, -3216.06812)
			}
		elseif lv >= 900 and lv <= 949 then
			return {
				[1] = "Marine Captain",
				[2] = 2,
				[3] = "MarineQuest3",
				[4] = CFrame.new(-2440.79639, 71.7140732, -3216.06812)
			}
		elseif lv >= 950 and lv <= 974 then
			return {
				[1] = "Zombie",
				[2] = 1,
				[3] = "ZombieQuest",
				[4] = CFrame.new(-5497.06152, 47.5923004, -795.237061)
			}
		elseif lv >= 975 and lv <= 999 then
			return {
				[1] = "Vampire",
				[2] = 2,
				[3] = "ZombieQuest",
				[4] = CFrame.new(-5497.06152, 47.5923004, -795.237061)
			}
		elseif lv >= 1000 and lv <= 1049 then
			return {
				[1] = "Snow Trooper",
				[2] = 1,
				[3] = "SnowMountainQuest",
				[4] = CFrame.new(609.858826, 400.119904, -5372.25928)
			}
		elseif lv >= 1050 and lv <= 1099 then
			return {
				[1] = "Winter Warrior",
				[2] = 2,
				[3] = "SnowMountainQuest",
				[4] = CFrame.new(609.858826, 400.119904, -5372.25928)
			}
		elseif lv >= 1100 and lv <= 1124 then
			return {
				[1] = "Lab Subordinate",
				[2] = 1,
				[3] = "IceSideQuest",
				[4] = CFrame.new(-6064.06885, 15.2422857, -4902.97852)
			}
		elseif lv >= 1125 and lv <= 1174 then
			return {
				[1] = "Horned Warrior",
				[2] = 2,
				[3] = "IceSideQuest",
				[4] = CFrame.new(-6064.06885, 15.2422857, -4902.97852)
			}
		elseif lv >= 1175 and lv <= 1199 then
			return {
				[1] = "Magma Ninja",
				[2] = 1,
				[3] = "FireSideQuest",
				[4] = CFrame.new(-5428.03174, 15.0622921, -5299.43457)
			}
		elseif lv >= 1200 and lv <= 1249 then
			return {
				[1] = "Lava Pirate",
				[2] = 2,
				[3] = "FireSideQuest",
				[4] = CFrame.new(-5428.03174, 15.0622921, -5299.43457)
			}
		elseif lv >= 1250 and lv <= 1274 then
			if (Vector3.new(1037.80127, 125.092171, 32911.6016) - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
			end
			return {
				[1] = "Ship Deckhand",
				[2] = 1,
				[3] = "ShipQuest1",
				[4] = CFrame.new(1037.80127, 125.092171, 32911.6016)
			}
		elseif lv >= 1275 and lv <= 1299 then
			if (Vector3.new(1037.80127, 125.092171, 32911.6016) - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
			end
			return {
				[1] = "Ship Engineer",
				[2] = 2,
				[3] = "ShipQuest1",
				[4] = CFrame.new(1037.80127, 125.092171, 32911.6016)
			}
		elseif lv >= 1300 and lv <= 1324 then
			if (Vector3.new(968.80957, 125.092171, 33244.125) - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
			end
			return {
				[1] = "Ship Steward",
				[2] = 1,
				[3] = "ShipQuest2",
				[4] = CFrame.new(968.80957, 125.092171, 33244.125)
			}
		elseif lv >= 1325 and lv <= 1349 then
			if (Vector3.new(968.80957, 125.092171, 33244.125) - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
			end
			return {
				[1] = "Ship Officer",
				[2] = 2,
				[3] = "ShipQuest2",
				[4] = CFrame.new(968.80957, 125.092171, 33244.125)
			}
		elseif lv >= 1350 and lv <= 1374 then
			return {
				[1] = "Arctic Warrior",
				[2] = 1,
				[3] = "FrostQuest",
				[4] = CFrame.new(5667.6582, 26.7997818, -6486.08984)
			}
		elseif lv >= 1375 and lv <= 1424 then
			return {
				[1] = "Snow Lurker",
				[2] = 2,
				[3] = "FrostQuest",
				[4] = CFrame.new(5667.6582, 26.7997818, -6486.08984)
			}
		elseif lv >= 1425 and lv <= 1449 then
			return {
				[1] = "Sea Soldier",
				[2] = 1,
				[3] = "ForgottenQuest",
				[4] = CFrame.new(-3055, 240, -10145)
			}
		elseif lv >= 1450 then
			return {
				[1] = "Water Fighter",
				[2] = 2,
				[3] = "ForgottenQuest",
				[4] = CFrame.new(-3055, 240, -10145)
			}
		end
	elseif w3 then
		if lv >= 1500 and lv <= 1524 then
			return {
				[1] = "Pirate Millionaire",
				[2] = 1,
				[3] = "PiratePortQuest",
				[4] = CFrame.new(-449.1593017578125, 108.6176528930664, 5948.00146484375)
			}
		elseif lv >= 1525 and lv <= 1574 then
			return {
				[1] = "Pistol Billionaire",
				[2] = 2,
				[3] = "PiratePortQuest",
				[4] = CFrame.new(-449.1593017578125, 108.6176528930664, 5948.00146484375)
			}
		elseif lv >= 1575 and lv <= 1599 then
			return {
				[1] = "Dragon Crew Warrior",
				[2] = 1,
				[3] = "DragonCrewQuest",
				[4] = CFrame.new(6737.77685546875, 127.42920684814453, -713.2312622070312)
			}
		elseif lv >= 1600 and lv <= 1624 then 
			return {
				[1] = "Dragon Crew Archer",
				[2] = 2,
				[3] = "DragonCrewQuest",
				[4] = CFrame.new(6737.77685546875, 127.42920684814453, -713.2312622070312)
			}
		elseif lv >= 1625 and lv <= 1649 then
			return {
				[1] = "Hydra Enforcer",
				[2] = 1,
				[3] = "VenomCrewQuest",
				[4] = CFrame.new(5212.94140625, 1004.1171875, 755.6657104492188)
			}
		elseif lv >= 1650 and lv <= 1699 then 
			return {
				[1] = "Venomous Assailant",
				[2] = 2,
				[3] = "VenomCrewQuest",
				[4] = CFrame.new(5212.94140625, 1004.1171875, 755.6657104492188)
			}
		elseif lv >= 1700 and lv <= 1724 then
			return {
				[1] = "Marine Commodore",
				[2] = 1,
				[3] = "MarineTreeIsland",
				[4] = CFrame.new(2484.0673828125, 74.28215026855469, -6786.64453125)
			}
		elseif lv >= 1725 and lv <= 1774 then
			return {
				[1] = "Marine Rear Admiral",
				[2] = 2,
				[3] = "MarineTreeIsland",
				[4] = CFrame.new(2484.0673828125, 74.28215026855469, -6786.64453125)
			}
		elseif lv >= 1775 and lv <= 1799 then
			return {
				[1] = "Fishman Raider",
				[2] = 1,
				[3] = "DeepForestIsland3",
				[4] = CFrame.new(-10581.6563, 330.872955, -8761.18652)
			}
		elseif lv >= 1800 and lv <= 1824 then
			return {
				[1] = "Fishman Captain",
				[2] = 2,
				[3] = "DeepForestIsland3",
				[4] = CFrame.new(-10581.6563, 330.872955, -8761.18652)
			}
		elseif lv >= 1825 and lv <= 1849 then
			return {
				[1] = "Forest Pirate",
				[2] = 1,
				[3] = "DeepForestIsland",
				[4] = CFrame.new(-13234.04, 331.488495, -7625.40137)
			}
		elseif lv >= 1850 and lv <= 1899 then
			return {
				[1] = "Mythological Pirate",
				[2] = 2,
				[3] = "DeepForestIsland",
				[4] = CFrame.new(-13234.04, 331.488495, -7625.40137)
			}
		elseif lv >= 1900 and lv <= 1924 then
			return {
				[1] = "Jungle Pirate",
				[2] = 1,
				[3] = "DeepForestIsland2",
				[4] = CFrame.new(-12680.3818, 389.971039, -9902.01953)
			}
		elseif lv >= 1925 and lv <= 1974 then
			return {
				[1] = "Musketeer Pirate",
				[2] = 2,
				[3] = "DeepForestIsland2",
				[4] = CFrame.new(-12680.3818, 389.971039, -9902.01953)
			}
		elseif lv >= 1975 and lv <= 1999 then
			return {
				[1] = "Reborn Skeleton",
				[2] = 1,
				[3] = "HauntedQuest1",
				[4] = CFrame.new(-9479.2168, 141.215088, 5566.09277)
			}
		elseif lv >= 2000 and lv <= 2024 then
			return {
				[1] = "Living Zombie",
				[2] = 2,
				[3] = "HauntedQuest1",
				[4] = CFrame.new(-9479.2168, 141.215088, 5566.09277)
			}
		elseif lv >= 2025 and lv <= 2049 then
			return {
				[1] = "Demonic Soul",
				[2] = 1,
				[3] = "HauntedQuest2",
				[4] = CFrame.new(-9516.99316, 172.017181, 6078.46533)
			}
		elseif lv >= 2050 and lv <= 2074 then
			return {
				[1] = "Posessed Mummy",
				[2] = 2,
				[3] = "HauntedQuest2",
				[4] = CFrame.new(-9516.99316, 172.017181, 6078.46533)
			}
		elseif lv >= 2075 and lv <= 2099 then
			return {
				[1] = "Peanut Scout",
				[2] = 1,
				[3] = "NutsIslandQuest",
				[4] = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875)
			}
		elseif lv >= 2100 and lv <= 2124 then
			return {
				[1] = "Peanut President",
				[2] = 2,
				[3] = "NutsIslandQuest",
				[4] = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875)
			}
		elseif lv >= 2125 and lv <= 2149 then
			return {
				[1] = "Ice Cream Chef",
				[2] = 1,
				[3] = "IceCreamIslandQuest",
				[4] = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438)
			}
		elseif lv >= 2150 and lv <= 2199 then
			return {
				[1] = "Ice Cream Commander",
				[2] = 2,
				[3] = "IceCreamIslandQuest",
				[4] = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438)
			}
		elseif lv >= 2200 and lv <= 2224 then
			return {
				[1] = "Cookie Crafter",
				[2] = 1,
				[3] = "CakeQuest1",
				[4] = CFrame.new(-2021.32007, 37.7982254, -12028.7295)
			}
		elseif lv >= 2225 and lv <= 2249 then
			return {
				[1] = "Cake Guard",
				[2] = 2,
				[3] = "CakeQuest1",
				[4] = CFrame.new(-2021.32007, 37.7982254, -12028.7295)
			}
		elseif lv >= 2250 and lv <= 2274 then
			return {
				[1] = "Baking Staff",
				[2] = 1,
				[3] = "CakeQuest2",
				[4] = CFrame.new(-1927.91602, 37.7981339, -12842.5391)
			}
		elseif lv >= 2275 and lv <= 2299 then
			return {
				[1] = "Head Baker",
				[2] = 2,
				[3] = "CakeQuest2",
				[4] = CFrame.new(-1927.91602, 37.7981339, -12842.5391)
			}
		elseif lv >= 2300 and lv <= 2324 then
			return {
				[1] = "Cocoa Warrior",
				[2] = 1,
				[3] = "ChocQuest1",
				[4] = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
			}
		elseif lv >= 2325 and lv <= 2349 then
			return {
				[1] = "Chocolate Bar Battler",
				[2] = 2,
				[3] = "ChocQuest1",
				[4] = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
			}
		elseif lv >= 2350 and lv <= 2374 then
			return {
				[1] = "Sweet Thief",
				[2] = 1,
				[3] = "ChocQuest2",
				[4] = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
			}
		elseif lv >= 2375 and lv <= 2399 then
			return {
				[1] = "Candy Rebel",
				[2] = 2,
				[3] = "ChocQuest2",
				[4] = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
			}
		elseif lv >= 2400 and lv <= 2424 then
			return {
				[1] = "Candy Pirate",
				[2] = 1,
				[3] = "CandyQuest1",
				[4] = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
			}
		elseif lv >= 2425 and lv <= 2449 then
			return {
				[1] = "Snow Demon",
				[2] = 2,
				[3] = "CandyQuest1",
				[4] = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
			}
		elseif lv >= 2450 and lv <= 2474 then
			return {
				[1] = "Isle Outlaw",
				[2] = 1,
				[3] = "TikiQuest1",
				[4] = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812)
			}
		elseif lv >= 2475 and lv <= 2499 then
			return {
				[1] = "Island Boy",
				[2] = 2,
				[3] = "TikiQuest1",
				[4] = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812)
			}
		elseif lv >= 2500 and lv <= 2524 then
			return {
				[1] = "Sun-kissed Warrior",
				[2] = 1,
				[3] = "TikiQuest1",
				[4] = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625)
			}
		elseif lv >= 2525 and lv <= 2549 then
			return {
				[1] = "Isle Champion",
				[2] = 2,
				[3] = "TikiQuest2",
				[4] = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625)
			}
		elseif lv >= 2550 and lv <= 2574 then
			return {
				[1] = "Serpent Hunter",
				[2] = 1,
				[3] = "TikiQuest3",
				[4] = CFrame.new(-16666.5703125, 105.2913818359375, 1576.6925048828125)
			}
		elseif lv >= 2575 then
			return {
				[1] = "Skull Slayer",
				[2] = 2,
				[3] = "TikiQuest3",
				[4] = CFrame.new(-16666.5703125, 105.2913818359375, 1576.6925048828125)
			}
		end
	end
end
