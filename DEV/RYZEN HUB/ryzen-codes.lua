local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
	Title = "Codes",
	TabWidth = 160,
	Size = UDim2.fromOffset(350, 250),
	Acrylic = false,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
	Main = Window:AddTab({Title = "Main", Icon = "gift"})
}

-- fetch codes from wiki
local function fetch_codes_from_wiki()
	local codes = {}
	print("[CodeRedeem] Fetching wiki page...")
	
	local success, result = pcall(function()
		return game:HttpGet("https://forge-roblox.fandom.com/wiki/Codes")
	end)
	
	if not success then
		print("[CodeRedeem] HttpGet failed: " .. tostring(result))
		return codes, "Failed to fetch wiki"
	end
	
	if not result then
		print("[CodeRedeem] Empty response from wiki")
		return codes, "Empty response"
	end
	
	print("[CodeRedeem] Got response, length: " .. #result)
	
	-- find active codes section
	local list_start = result:find("List of Codes")
	local expired_start = result:lower():find("these codes are ones that were used before")
	
	print("[CodeRedeem] List start pos: " .. tostring(list_start))
	print("[CodeRedeem] Expired start pos: " .. tostring(expired_start))
	
	if not list_start then
		print("[CodeRedeem] Could not find 'List of Codes' section")
		return codes, "Could not parse wiki"
	end
	
	local active_section = result:sub(list_start, expired_start or #result)
	print("[CodeRedeem] Active section length: " .. #active_section)
	
	-- parse table cells
	for td_content in active_section:gmatch("<td[^>]*>%s*([^<]+)%s*</td>") do
		local trimmed = td_content:match("^%s*(.-)%s*$")
		print("[CodeRedeem] Found TD content: '" .. trimmed .. "'")
		
		if trimmed and #trimmed >= 4 and #trimmed <= 20 and trimmed:match("^[A-Z0-9!]+$") then
			if not trimmed:match("^%d+$") then
				print("[CodeRedeem] Potential code: " .. trimmed)
				table.insert(codes, trimmed)
			end
		end
	end
	
	-- fallback line parsing
	if #codes == 0 then
		print("[CodeRedeem] TD parsing found nothing, trying line-by-line...")
		for line in active_section:gmatch("[^\n]+") do
			local code = line:match("^%s*([A-Z][A-Z0-9!]+)%s*$")
			if code and #code >= 4 and #code <= 20 then
				print("[CodeRedeem] Line match: " .. code)
				table.insert(codes, code)
			end
		end
	end
	
	print("[CodeRedeem] Total codes found: " .. #codes)
	for i, c in ipairs(codes) do
		print("[CodeRedeem] Code " .. i .. ": " .. c)
	end
	
	return codes, nil
end

-- redeem single code
local function redeem_code(code)
	print("[CodeRedeem] Attempting to redeem: " .. code)
	local success, result = pcall(function()
		local args = {code}
		return game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("CodeService"):WaitForChild("RF"):WaitForChild("RedeemCode"):InvokeServer(unpack(args))
	end)
	print("[CodeRedeem] Result for " .. code .. ": success=" .. tostring(success) .. ", result=" .. tostring(result))
	
	-- dump table contents if result is a table
	if type(result) == "table" then
		print("[CodeRedeem] Table contents for " .. code .. ":")
		for k, v in pairs(result) do
			print("  " .. tostring(k) .. " = " .. tostring(v))
		end
	end
	
	return success, result
end

-- redeem all from wiki
local function redeem_all_codes()
	local codes, err = fetch_codes_from_wiki()
	
	if err then return "Error: " .. err end
	if #codes == 0 then return "No active codes found" end
	
	local redeemed, failed, already_used = 0, 0, 0
	
	for _, code in ipairs(codes) do
		local success, result = redeem_code(code)
		task.wait(0.5)
		
		-- debug: log exact type and value
		print("[CodeRedeem] Code: " .. code .. " | pcall success: " .. tostring(success) .. " | result type: " .. type(result) .. " | result value: " .. tostring(result))
		
		if success then
			-- server returns a table with Success and Message fields
			if type(result) == "table" then
				if result.Success == true then
					redeemed = redeemed + 1
				elseif result.Message then
					local msg = result.Message:lower()
					if msg:find("already") or msg:find("used") or msg:find("claimed") or msg:find("redeemed") then
						already_used = already_used + 1
					else
						-- expired, invalid, etc
						failed = failed + 1
					end
				else
					failed = failed + 1
				end
			elseif result == nil or result == true then
				redeemed = redeemed + 1
			elseif type(result) == "string" then
				local lower = result:lower()
				if lower:find("success") then
					redeemed = redeemed + 1
				elseif lower:find("already") or lower:find("used") or lower:find("claimed") or lower:find("redeemed") then
					already_used = already_used + 1
				else
					failed = failed + 1
				end
			else
				failed = failed + 1
			end
		else
			failed = failed + 1
		end
	end
	
	local msg = "Found " .. #codes .. " codes. "
	if redeemed > 0 then msg = msg .. redeemed .. " redeemed! " end
	if already_used > 0 then msg = msg .. already_used .. " already claimed. " end
	if failed > 0 then msg = msg .. failed .. " failed/expired. " end
	
	return msg
end

-- ui
Tabs.Main:AddButton({
	Title = "Redeem All Codes",
	Description = "from wiki",
	Callback = function()
		Fluent:Notify({Title = "Fetching...", Content = "grabbing codes", Duration = 2})
		local result = redeem_all_codes()
		Fluent:Notify({Title = "Done", Content = result, Duration = 5})
	end
})

Tabs.Main:AddInput("ManualCode", {
	Title = "Code",
	Placeholder = "code here"
})

Tabs.Main:AddButton({
	Title = "Redeem",
	Description = "manual",
	Callback = function()
		local code = Fluent.Options.ManualCode.Value
		if not code or code == "" then
			Fluent:Notify({Title = "bruh", Content = "enter a code", Duration = 3})
			return
		end
		local success, result = redeem_code(code)
		local msg = success and tostring(result) or "failed"
		Fluent:Notify({Title = code, Content = msg, Duration = 5})
	end
})

Window:SelectTab(1)
