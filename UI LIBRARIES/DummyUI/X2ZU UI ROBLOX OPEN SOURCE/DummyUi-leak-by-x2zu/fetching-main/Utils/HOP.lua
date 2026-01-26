local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

return function(low: boolean)
	local lowz = low or false
	if lowz then
		local maxplayers = math.huge
		local goodserver
		local gamelink = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

		local function serversearch(data)
			for _, v in pairs(data) do
				if typeof(v) == "table" and v.playing and v.playing < maxplayers then
					if v.id ~= game.JobId then
						maxplayers = v.playing
						goodserver = v.id
					end
				end
			end
		end

		local function getservers()
			local done = false
			while not done do
				local response = HttpService:JSONDecode(game:HttpGet(gamelink))
				serversearch(response.data)

				if response.nextPageCursor then
					gamelink = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. response.nextPageCursor
				else
					done = true
				end
			end
		end

		getservers()

		if not goodserver then
			return warn("No suitable server found.")
		end

		local playerCount = #Players:GetPlayers()
		if playerCount - 4 == maxplayers then
			return warn("It has same number of players (except you)")
		elseif goodserver == game.JobId then
			return warn("Your current server is the most empty server atm")
		end

		TeleportService:TeleportToPlaceInstance(game.PlaceId, goodserver)

	else
		local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

		local function listServers(cursor)
			local url = api .. ((cursor and "&cursor=" .. cursor) or "")
			local response = HttpService:JSONDecode(game:HttpGet(url))
			return response
		end

		local Server, Next
		repeat
			local result = listServers(Next)
			Server = result.data[1]
			Next = result.nextPageCursor
		until Server

		if Server then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, Players.LocalPlayer)
		else
			warn("No servers found to hop to.")
		end
	end
end
