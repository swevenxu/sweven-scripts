local KA = {}

local EXECUTOR = "Unknown"

pcall(function()
    if typeof(syn) == "table" then
        EXECUTOR = "Synapse"
    elseif type(identifyexecutor) == "function" then
        local ok, name = pcall(identifyexecutor)
        if ok and type(name) == "string" and #name > 0 then
            EXECUTOR = name
        end
    elseif type(is_sirhurt_closure) == "function" or is_sirhurt_closure == true then
        EXECUTOR = "SirHurt"
    elseif type(KRNL_LOADED) == "boolean" and KRNL_LOADED then
        EXECUTOR = "KRNL"
    elseif _G and _G.XEN and type(_G.XEN) == "table" then
        EXECUTOR = "Xeno"
    elseif _G and _G.Solara and type(_G.Solara) == "table" then
        EXECUTOR = "Solara"
    elseif type(request) == "function" or type(http) == "table" or type(http_request) == "function" then
        EXECUTOR = EXECUTOR 
    end
end)

local function http_get(url, timeout)
    timeout = timeout or 10
    local body = nil

    
    if typeof(syn) == "table" and type(syn.request) == "function" then
        local ok, res = pcall(syn.request, {Url = url, Method = "GET"})
        if ok and res and (res.Body or res.body) then
            return res.Body or res.body
        end
 end

    
    if type(http) == "table" and type(http.request) == "function" then
        local ok, res = pcall(http.request, {Url = url, Method = "GET"})
        if ok and res and (res.Body or res.body) then
            return res.Body or res.body
        end
    end

    
    if type(http_request) == "function" then
        local ok, res = pcall(http_request, {Url = url, Method = "GET"})
        if ok and res and (res.Body or res.body) then
            return res.Body or res.body
        end
    end

    
    if type(request) == "function" then
        local ok, res = pcall(request, {Url = url, Method = "GET"})
        if ok and res and (res.Body or res.body) then
            return res.Body or res.body
        end
    end

    
    if game and type(game.HttpGet) == "function" then
        local ok, res = pcall(function() return game:HttpGet(url, true) end)
        if ok and res then return res end
    end

    return nil
end

local function safe_load_remote(url)
    local src = http_get(url)
    if not src then
        return nil, "http_get failed for " .. tostring(url)
    end

    local f, lerr = loadstring and loadstring(src) or load(src)
    if not f then
        return nil, "loadstring/load failed: " .. tostring(lerr)
    end

    local ok, result = pcall(f)
    if not ok then
        return nil, "remote chunk error: " .. tostring(result)
    end

    return result, nil
end

local function safe_setclipboard(txt)
    pcall(function()
        if type(setclipboard) == "function" then
            setclipboard(txt)
            return
        elseif typeof(syn) == "table" and type(syn.setclipboard) == "function" then
            syn.setclipboard(txt)
            return
        elseif typeof(clipboard) == "table" and type(clipboard.set) == "function" then
            clipboard.set(txt)
            return
        end
    end)
end

_G.EXECUTOR = EXECUTOR
_G.http_get = http_get
_G.safe_load_remote = safe_load_remote
_G.safe_setclipboard = safe_setclipboard

local a, b
do
    local res, err = safe_load_remote("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    if not res then
        warn(" Failed to load WindUI: "..tostring(err))
        a = false
        b = nil
    else
        local ok, ret = pcall(function() return res end) 
        a = ok
        b = ret
    end
end
themeNames = {
    "RyZenHub",
    "Holly & Gold",
    "Frost & Fir",
    "Ocean Blue",
    "Forest Green",
    "Minimal Light",
    "Retro Purple",
    "Sunset",
    "Neon Pulse",
    "Steel Phantom",
    "Vaporwave",
    "Deep Sea",
    "Sepia Warmth",
    "Monokai Dark",
    "Solarized Light",
    "Cherry Blossom",
    "Charcoal Gold",
    "Icy Mint",
    "Volcano",
    "Amethyst",
    "Pastel Dream",
    "Coffee Shop",
    "Cyberpunk Red",

    "Midnight Sakura",
    "Nordic Ice",
    "Crimson Noir",
    "Aurora Mist",
    "Lilac Haze",
    "Bronze Alloy",
    "Midnight Teal",
    "Sunburst Gold",
    "Plum Velvet",
    "Mint Meadow",
    "Saffron Day",
    "Electric Indigo",
    "Granite Slate",
    "Peach Fuzz",
    "Obsidian",
    "Ginger Spice",
    "Graphite Blue",
    "Lavender Bloom",
    "Mango Tango",
    "Polar Night",
    "Olive Drab",
    "Bubblegum Pop",
    "Steel Blue",
    "Coral Reef",
    "Tobacco Brown",
    "Pewter",
    "Emerald Night",
    "Flamingo Sunset",
}
themeColors = {
    ["Ocean Blue"] = {
        Accent = "#0B5394",
        Dialog = "#0A3D6B",
        Outline = "#6DACEA",
        Text = "#EBF5FF",
        Placeholder = "#85AECF",
        Background = "#051A2E",
        Button = "#1C67A8",
    },
    ["Forest Green"] = {
        Accent = "#1A5E2E",
        Dialog = "#114220",
        Outline = "#8AC79B",
        Text = "#E9FCE9",
        Placeholder = "#79A378",
        Background = "#0A2B14",
        Button = "#2B7A42",
    },
    ["Minimal Light"] = {
        Accent = "#F3F4F6",
        Dialog = "#FFFFFF",
        Outline = "#4B5563",
        Text = "#1F2937",
        Placeholder = "#9CA3AF",
        Background = "#F9FAFB",
        Button = "#E5E7EB",
    },
    ["Retro Purple"] = {
        Accent = "#7E22CE",
        Dialog = "#4A148C",
        Outline = "#F0ABFC",
        Text = "#FDF4FF",
        Placeholder = "#BC8FDD",
        Background = "#2D0557",
        Button = "#9333EA",
        Icon = "#F0ABFC"
     },
    ["Sunset"] = {
        Accent = "#FF8847",
        Dialog = "#CC5500",
        Outline = "#FFD9C0",
        Text = "#FFF7F0",
        Placeholder = "#FFC099",
        Background = "#331A00",
        Button = "#FF7043",
    },
    ["Neon Pulse"] = {
        Accent = "#00FF00",
        Dialog = "#111111",
        Outline = "#00FFFF",
        Text = "#FFFFFF",
        Placeholder = "#008800",
        Background = "#000000",
        Button = "#39FF14",
    },
    ["Steel Phantom"] = {
        Accent = "#404040",
        Dialog = "#262626",
        Outline = "#A3A3A3",
        Text = "#D4D4D4",
        Placeholder = "#737373",
        Background = "#171717",
        Button = "#525252",
    },
    ["Vaporwave"] = {
        Accent = "#FF00FF",
        Dialog = "#1B001B",
        Outline = "#00FFFF",
        Text = "#FFFFFF",
        Placeholder = "#FF69FF",
        Background = "#0A0014",
        Button = "#E75480",
    },
    ["Deep Sea"] = {
        Accent = "#008B8B",
        Dialog = "#005A5A",
        Outline = "#80CBC4",
        Text = "#E0FFFF",
        Placeholder = "#4DB6AC",
        Background = "#003636",
        Button = "#00A3A3",
    },
    ["Sepia Warmth"] = {
        Accent = "#7B3F00",
        Dialog = "#5C3200",
        Outline = "#D2B48C",
        Text = "#F5E8D6",
        Placeholder = "#A98F70",
        Background = "#3D291F",
        Button = "#9D5B18",
    },
    ["Monokai Dark"] = {
        Accent = "#F92672",
        Dialog = "#272822",
        Outline = "#66D9EF",
        Text = "#F8F8F2",
        Placeholder = "#75715E",
        Background = "#1C1E1A",
        Button = "#A6E22E",
    },
    ["Solarized Light"] = {
        Accent = "#268BD2",
        Dialog = "#FDF6E3",
        Outline = "#93A1A1",
        Text = "#586E75",
        Placeholder = "#839496",
        Background = "#EEE8D5",
        Button = "#B58900",
    },
    ["Cherry Blossom"] = {
        Accent = "#F9BCCB",
        Dialog = "#FFFAFD",
        Outline = "#D96985",
        Text = "#4A1429",
        Placeholder = "#C397A3",
        Background = "#FFF7F9",
        Button = "#E68A9F",
    },
    ["Charcoal Gold"] = {
        Accent = "#FFD700",
        Dialog = "#2C2C2C",
        Outline = "#C0C0C0",
        Text = "#F5F5F5",
        Placeholder = "#6E6E6E",
        Background = "#1D1D1D",
        Button = "#B8860B",
    },
    ["Icy Mint"] = {
        Accent = "#40E0D0",
        Dialog = "#F0FFFF",
        Outline = "#81D4FA",
        Text = "#004D40",
        Placeholder = "#B2DFDB",
        Background = "#E0FFFF",
        Button = "#80CBC4",
    },
    ["Amethyst"] = {
        Accent = "#9966CC",
        Dialog = "#36284C",
        Outline = "#CCFF66",
        Text = "#EDE9F2",
        Placeholder = "#8A72A4",
        Background = "#221A33",
        Button = "#7A52AA",
    },
["Aurora Mist"] = {
    Accent = "#6AD3D1",
    Dialog = "#EAF9F8",
    Outline = "#A9E7E6",
    Text = "#05282C",
    Placeholder = "#8FCFCF",
    Background = "#F6FFFE",
    Button = "#3BC9C8",
},

["Lilac Haze"] = {
    Accent = "#C9A7E3",
    Dialog = "#3B2B3F",
    Outline = "#8D6DAF",
    Text = "#F7F3FB",
    Placeholder = "#B99ED2",
    Background = "#241825",
    Button = "#A270D1",
},

["Bronze Alloy"] = {
    Accent = "#B06B2A",
    Dialog = "#2B1F18",
    Outline = "#805334",
    Text = "#F6F0E9",
    Placeholder = "#AF8A6B",
    Background = "#120C08",
    Button = "#8A4B20",
},

["Midnight Teal"] = {
    Accent = "#0FA3A3",
    Dialog = "#071A1A",
    Outline = "#2B6F6F",
    Text = "#E6FFFE",
    Placeholder = "#6FBDBD",
    Background = "#021010",
    Button = "#0E8B8B",
},

["Sunburst Gold"] = {
    Accent = "#FFD166",
    Dialog = "#3B2E12",
    Outline = "#E8C56A",
    Text = "#1B1308",
    Placeholder = "#D7B57A",
    Background = "#FFF7EA",
    Button = "#FFB84C",
},

["Plum Velvet"] = {
    Accent = "#7B2A5A",
    Dialog = "#2A0E1B",
    Outline = "#B0648B",
    Text = "#FFEFF6",
    Placeholder = "#A67A98",
    Background = "#160713",
    Button = "#9B2D5A",
},

["Mint Meadow"] = {
    Accent = "#2EC4B6",
    Dialog = "#E9FFFB",
    Outline = "#8EE2D8",
    Text = "#023033",
    Placeholder = "#90D9CF",
    Background = "#F6FFFE",
    Button = "#24B7A9",
},

["Saffron Day"] = {
    Accent = "#F2A900",
    Dialog = "#FFF6E6",
    Outline = "#E6B94D",
    Text = "#2B1E00",
    Placeholder = "#D9B36F",
    Background = "#FFF9F0",
    Button = "#E08F00",
},

["Electric Indigo"] = {
    Accent = "#5A2DD4",
    Dialog = "#0E0523",
    Outline = "#8C6EF6",
    Text = "#F2EEFF",
    Placeholder = "#9679E6",
    Background = "#050212",
    Button = "#4B22D0",
},

["Granite Slate"] = {
    Accent = "#6B7380",
    Dialog = "#1A1F24",
    Outline = "#9AA3AD",
    Text = "#E9EEF2",
    Placeholder = "#8C95A0",
    Background = "#101316",
    Button = "#4F5964",
},

["Peach Fuzz"] = {
    Accent = "#FFBC9A",
    Dialog = "#FFF4F0",
    Outline = "#FFDDC6",
    Text = "#3A2B24",
    Placeholder = "#D9B7A3",
    Background = "#FFF9F7",
    Button = "#FF9E70",
},

["Obsidian"] = {
    Accent = "#9AD3DE",
    Dialog = "#070708",
    Outline = "#2B2E2F",
    Text = "#E8FFFF",
    Placeholder = "#6F9EA4",
    Background = "#000000",
    Button = "#82C6CF",
},

["Ginger Spice"] = {
    Accent = "#C75B12",
    Dialog = "#2B1208",
    Outline = "#B37A51",
    Text = "#FFF6F0",
    Placeholder = "#C0977D",
    Background = "#130A06",
    Button = "#A9440F",
},

["Graphite Blue"] = {
    Accent = "#2F6B9A",
    Dialog = "#0E1621",
    Outline = "#516D88",
    Text = "#EAF3FA",
    Placeholder = "#7F9FB9",
    Background = "#07121A",
    Button = "#23527A",
},

["Lavender Bloom"] = {
    Accent = "#C7B8FF",
    Dialog = "#F6F3FF",
    Outline = "#B8A9F0",
    Text = "#2B1E3A",
    Placeholder = "#BFB0E8",
    Background = "#FEFCFF",
    Button = "#A68FFF",
},

["Mango Tango"] = {
    Accent = "#FF8C42",
    Dialog = "#332114",
    Outline = "#F6B27F",
    Text = "#FFF8F3",
    Placeholder = "#E0A27A",
    Background = "#1C1209",
    Button = "#FF7B2A",
},

["Polar Night"] = {
    Accent = "#9AD1FF",
    Dialog = "#061226",
    Outline = "#5DAFE3",
    Text = "#EDF8FF",
    Placeholder = "#7FBEE6",
    Background = "#031124",
    Button = "#6BAFE0",
},

["Olive Drab"] = {
    Accent = "#556B2F",
    Dialog = "#FAFBF6",
    Outline = "#8A9B5E",
    Text = "#1F260F",
    Placeholder = "#9AA77A",
    Background = "#F6F7EE",
    Button = "#486022",
},

["Bubblegum Pop"] = {
    Accent = "#FF6FB5",
    Dialog = "#FFF0F8",
    Outline = "#FFA3D9",
    Text = "#2B0D1A",
    Placeholder = "#EFAFCF",
    Background = "#FFF8FB",
    Button = "#FF4F9A",
},

["Steel Blue"] = {
    Accent = "#4A6F8A",
    Dialog = "#12181C",
    Outline = "#6E8EA3",
    Text = "#EAF2F6",
    Placeholder = "#93B0C3",
    Background = "#0A0F12",
    Button = "#3F5F76",
},

["Coral Reef"] = {
    Accent = "#FF6B5C",
    Dialog = "#2B0F0C",
    Outline = "#FF9A88",
    Text = "#FFF4F2",
    Placeholder = "#E09A93",
    Background = "#160805",
    Button = "#FF4F3F",
},

["Tobacco Brown"] = {
    Accent = "#6C4A2E",
    Dialog = "#F7F3EE",
    Outline = "#9A765C",
    Text = "#22140A",
    Placeholder = "#B89B86",
    Background = "#FBF8F6",
    Button = "#5A3E2A",
},

["Pewter"] = {
    Accent = "#9AA0A6",
    Dialog = "#0E1113",
    Outline = "#C0C6CA",
    Text = "#F6F8F9",
    Placeholder = "#8E979D",
    Background = "#0A0D0F",
    Button = "#7E858B",
},
["Midnight Sakura"] = {
    Accent = "#F28DB2",
    Dialog = "#2A0F1E",
    Outline = "#8C3A5B",
    Text = "#FFEAF2",
    Placeholder = "#B97A91",
    Background = "#160810",
    Button = "#C94A76",
},
["Emerald Night"] = {
    Accent = "#00A36C",
    Dialog = "#071912",
    Outline = "#2FA67F",
    Text = "#E9FFF5",
    Placeholder = "#66C19B",
    Background = "#03120C",
    Button = "#008E59",
},
["Nordic Ice"] = {
    Accent = "#88C0D0",
    Dialog = "#2E3440",
    Outline = "#4C566A",
    Text = "#ECEFF4",
    Placeholder = "#81A1C1",
    Background = "#1E222A",
    Button = "#5E81AC",
},
["Flamingo Sunset"] = {
    Accent = "#FF5E7E",
    Dialog = "#2B0A0F",
    Outline = "#FFA3B7",
    Text = "#FFF2F4",
    Placeholder = "#E6A7B3",
    Background = "#140508",
    Button = "#FF3B5B",
},
["Crimson Noir"] = {
    Accent = "#B11226",
    Dialog = "#1A1A1A",
    Outline = "#5C1A1A",
    Text = "#F5F5F5",
    Placeholder = "#8A4A4A",
    Background = "#0D0D0D",
    Button = "#8E0E1B",
},
    ["Pastel Dream"] = {
        Accent = "#FFB3BA",
        Dialog = "#FAF3E0",
        Outline = "#BAE1FF",
        Text = "#333333",
        Placeholder = "#C1B4A5",
        Background = "#FFFFFF",
        Button = "#BAE1FF",
    },
    ["Coffee Shop"] = {
        Accent = "#795548",
        Dialog = "#F5F5DC",
        Outline = "#A1887F",
        Text = "#3E2723",
        Placeholder = "#BCB0A4",
        Background = "#FFF8E1",
        Button = "#D7CCC8",
    },
    ["Cyberpunk Red"] = {
    Accent = "#FF3333",
    Dialog = "#080008",
    Outline = "#33FFFF",
    Text = "#FDFDFD",
    Placeholder = "#771111",
    Background = "#000000",
    Button = "#FF3333",
},
["RyZenHub"] = {
    Accent = "#D4AF37",
    Dialog = "#1A1A1A",
    Outline = "#8C7A2E",
    Text = "#F5F5F5",
    Placeholder = "#9E9E9E",

    
    Background = "#000000",
    BackgroundTransparency = 1,

    Button = "#B8962E",
    Icon = "#FFD966",
},

["Holly & Gold"] = {
    Accent = "#19A14A",       
    Dialog = "#A31F1F",       
    Outline = "#0A5B33",      
    Text = "#FFF7EE",
    Placeholder = "#D0B98C",
    Background = "#0C241A",
    Button = "#ff0000",       
},

["Frost & Fir"] = {
    Accent = "#72E8DD",       
    Dialog = "#9DEDE8",       
    Outline = "#72E8DD",      
    Text = "#042233",         
    Placeholder = "#B9D9EA",  
    Background = "#BEF7F2",   
    Button = "#2E6FA3",       
},

}
for c, d in pairs(themeColors) do
    b:AddTheme({
        Name = c,
        Accent = Color3.fromHex(d.Accent or "#FFFFFF"),
        Dialog = Color3.fromHex(d.Dialog or d.Background or "#000000"),
        Outline = Color3.fromHex(d.Outline or d.Accent or "#FFFFFF"),
        Text = Color3.fromHex(d.Text or "#FFFFFF"),
        Placeholder = Color3.fromHex(d.Placeholder or d.Text or "#AAAAAA"),
        Background = Color3.fromHex(d.Background or "#000000"),
        Button = Color3.fromHex(d.Button or d.Accent or "#FFFFFF"),
        Icon = Color3.fromHex(d.Icon or d.Button or d.Accent or "#FFFFFF"),
    })
end
local function e(f, g, i)
    local j = ""
    for k = 1, #f do
        local l = (k - 1) / (#f - 1)
        local n = g.R + (i.R - g.R) * l
        local o = g.G + (i.G - g.G) * l
        local p = g.B + (i.B - g.B) * l
        local q = string.format("#%02X%02X%02X", n * 255, o * 255, p * 255)
        j = j .. string.format('<font color="%s">%s</font>', q, f:sub(k, k))
    end
    return j
end
local r =
    b:CreateWindow(
    {
        Title = "RyZenHub",
        Icon = "rbxassetid://84501312005643",
        IconThemed = true,
        Author = "Dev • |@Mallo|",
        Size = UDim2.fromOffset(650, 500),
        Resizable = true,
        Transparent = true,
        User = {Enabled = true, Anonymous = False, Callback = function()
                            end}
    }
)

r:Tag({
    Title = "v1.7.4 (MASIVE!)",
    Color = Color3.fromHex("#FFD966"), 
    Radius = 10
})
r:Tag({
    Title = "The Forge Beta",
    Color = Color3.fromHex("#FFD966"), 
    Radius = 10
})
r:SetIconSize(42)
r:EditOpenButton(
    {
        Title = "RyZenHub",
        Icon = "rbxassetid://84501312005643",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
    Color3.fromHex("FFD966"), 
    Color3.fromHex("ffffff")  
),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true
    }
)
r:DisableTopbarButtons({"Close"})
local t = r:Tab({Title = "information", Icon = "info"})
local u = "KG9ADqwT9Q"
local v = "https://discord.com/api/v10/invites/" .. u .. "?with_counts=true&with_expiration=true"
local w
local x = nil
xpcall(
    function()
        w =
            game:GetService("HttpService"):JSONDecode(
            b.Creator.Request({Url = v, Method = "GET", Headers = {["Accept"] = "application/json"}}).Body
        )
    end,
    function(err)
        warn("err fetching discord info: " .. tostring(err))
        x = tostring(err)
        w = nil
    end
)
if w and w.guild then
    local y = {
        Title = w.guild.name,
        Desc = ' <font color="#52525b">•</font> Member Count: ' ..
            tostring(w.approximate_member_count) ..
                '\n <font color="#16a34a">•</font> Online Count: ' .. tostring(w.approximate_presence_count),
        Image = "https://cdn.discordapp.com/icons/" .. w.guild.id .. "/" .. w.guild.icon .. ".png?size=256",
        ImageSize = 42,
        Buttons = {
            {
                Icon = "link",
                Title = "Copy Discord Invite",
                Callback = function()
                    pcall(
                        function()
                            setclipboard("https://discord.gg/" .. u)
                        end
                    )
                end
            },
            {
                Icon = "refresh-cw",
                Title = "Update Info",
                Callback = function()
                    xpcall(
                        function()
                            local z =
                                game:GetService("HttpService"):JSONDecode(
                                b.Creator.Request({Url = v, Method = "GET"}).Body
                            )
                            if z and z.guild then
                                DiscordInfo:SetDesc(
                                    ' <font color="#52525b">•</font> Member Count: ' ..
                                        tostring(z.approximate_member_count) ..
                                            '\n <font color="#16a34a">•</font> Online Count: ' ..
                                                tostring(z.approximate_presence_count)
                                )
                            end
                        end,
                        function(err)
                            warn("err updating discord info: " .. tostring(err))
                        end
                    )
                end
            }
        }
    }
    if w.guild.banner then
        y.Thumbnail = "https://cdn.discordapp.com/banners/" .. w.guild.id .. "/" .. w.guild.banner .. ".png?size=256"
        y.ThumbnailSize = 80
    end
    local DiscordInfo = t:Paragraph(y)
else
    t:Paragraph(
        {
            Title = "Error when receiving information about the Discord server",
            Desc = x or "Unknown error occurred",
            Image = "triangle-alert",
            ImageSize = 26,
            Color = "Red"
        }
    )
end
UpdatesTab = Window:Tab({
    Title = "Updates",
    Icon = "circle-alert",
})

UpdatesTab:Paragraph({
    Title = "V1.7.4",
    Desc = "World 3 compatible\n\nNEW:\nAuto Quest\nAuto Evade\nAuto Parry\nNew pickaxe to buy (World 3)\nNew Shaders\nNew Themes\nNew Loader\n\nMuch more!\n(Im lazy to list them all )",
})

UpdatesTab:Paragraph({
    Title = "Update 1.7.2 Beta",
    Desc = "NEW:\nCompatible with World 2: Forgotten Kingdom\n\nIMPROVED:\nAuto Mine\nAuto Sell\nAuto Buy\n\nADDED:\nAuto Sell Essence\nAuto Sell Runes\nArchangel added to Auto Reroll\nNew pickaxe to buy (World 2)\nNew potions to buy (World 2)\nJoins tab\nVisual tab\nShaders\n\nTELEPORTS:\nWorld 1\nWorld 2\nLow player servers",
})

UpdatesTab:Paragraph({
    Title = "Version Beta!",
    Desc = "More features Coming Soon! If you encounted some bugs join our discord to report it!",
})

if not KA then
    KA = {}
end

KA.Services = {
    rs = game:GetService("ReplicatedStorage"),
    ts = game:GetService("TweenService"),
    plrs = game:GetService("Players"),
    runService = game:GetService("RunService"),
}

KA.AutoQuest = {}

KA.State = {
    auto_quest_en = false,
    current_quest_task = nil,
    last_quest_check_time = 0,
    sel_quest = nil,

    is_farming = false,
    is_mob_farm = false,
    is_mining = false,
    is_atk = false,

    sel_ore = nil,
    sel_mob = nil,
}

KA.Settings = {
    tween_spd = 50,
    y_offset = 0,
    mob_back_distance = 3,
}

KA.Fallback = {
    mode = "None", 
    rock = nil,
    mob = nil,
    active = false,
}

KA.Stuck = {
    death_recovery_en = true,
    stuck_threshold = 5,
    last_position = nil,
    last_move_time = tick(),
}

KA.Tween = {
    current_conn = nil,
    cancelled = false,
}

KA.OreMap = {

["Stone"] = {type = "rock", sources = {"Pebble"}},
["Sand Stone"] = {type = "rock", sources = {"Pebble", "Rock"}},
["Copper"] = {type = "rock", sources = {"Pebble", "Rock", "Boulder"}},
["Iron"] = {type = "rock", sources = {"Pebble", "Rock", "Boulder"}},
["Tin"] = {type = "rock", sources = {"Rock", "Boulder"}},
["Silver"] = {type = "rock", sources = {"Rock", "Boulder"}},
["Gold"] = {type = "rock", sources = {"Boulder"}},
["Mushroomite"] = {type = "rock", sources = {"Rock", "Boulder"}},
["Platinum"] = {type = "rock", sources = {"Boulder"}},
["Bananite"] = {type = "rock", sources = {"Rock", "Boulder"}},
["Cardboardite"] = {type = "rock", sources = {"Rock", "Boulder"}},
["Aite"] = {type = "rock", sources = {"Boulder"}},
["Poopite"] = {type = "rock", sources = {"Pebble", "Rock", "Boulder"}},
["Fichillium"] = {type = "rock", sources = {"Lucky Block"}},

["Cobalt"] = {type = "rock", sources = {"Basalt Rock", "Basalt Core"}},
["Titanium"] = {type = "rock", sources = {"Basalt Rock", "Basalt Core"}},
["Lapis Lazuli"] = {type = "rock", sources = {"Basalt Core", "Basalt Rock"}},
["Volcanic Rock"] = {type = "rock", sources = {"Volcanic Rock"}},
["Quartz"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein"}},
["Amethyst"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein"}},
["Topaz"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein", "Volcanic Rock"}},
["Diamond"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein"}},
["Sapphire"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein"}},
["Cuprite"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein", "Volcanic Rock"}},
["Obsidian"] = {type = "rock", sources = {"Volcanic Rock"}},
["Emerald"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein"}},
["Ruby"] = {type = "rock", sources = {"Basalt Vein"}},
["Rivalite"] = {type = "rock", sources = {"Basalt Vein", "Volcanic Rock"}},
["Uranium"] = {type = "rock", sources = {"Basalt Vein"}},
["Mythril"] = {type = "rock", sources = {"Basalt Vein"}},
["Eye Ore"] = {type = "rock", sources = {"Basalt Rock", "Basalt Core", "Basalt Vein", "Volcanic Rock"}},
["Fireite"] = {type = "rock", sources = {"Volcanic Rock"}},
["Magmaite"] = {type = "rock", sources = {"Volcanic Rock"}},
["Lightite"] = {type = "rock", sources = {"Basalt Vein"}},
["Demonite"] = {type = "rock", sources = {"Volcanic Rock"}},
["Darkryte"] = {type = "rock", sources = {"Volcanic Rock"}},

["Boneite"] = {type = "mob", sources = {"Skeleton Rogue", "Axe Skeleton", "Deathaxe Skeleton"}},
["Dark Boneite"] = {type = "mob", sources = {"Elite Skeleton Rogue", "Reaper", "Elite Deathaxe Skeleton"}},
["Slimite"] = {type = "mob", sources = {"Slime", "Burning Slime"}},

["Magenta Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
["Crimson Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
["Green Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
["Orange Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
["Blue Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
["Rainbow Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
["Arcane Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},

["Tungsten"] = {type = "rock", sources = {"Icy Pebble", "Icy Rock", "Icy Boulder"}},
["Sulfur"] = {type = "rock", sources = {"Icy Pebble", "Icy Rock", "Icy Boulder"}},
["Pumice"] = {type = "rock", sources = {"Icy Pebble", "Icy Rock", "Icy Boulder"}},
["Graphite"] = {type = "rock", sources = {"Icy Pebble", "Icy Rock", "Icy Boulder"}},
["Snowite"] = {type = "rock", sources = {"Icy Pebble", "Icy Rock", "Icy Boulder", "Small Ice Crystal"}},
["Iceite"] = {type = "rock", sources = {"Icy Rock", "Icy Boulder", "Small Ice Crystal", "Medium Ice Crystal", "Large Ice Crystal", "Floating Crystal"}},
["Heavenite"] = {type = "rock", sources = {"Floating Crystal"}},
["Gargantuan"] = {type = "rock", sources = {"Large Ice Crystal"}},

["Prismatic Heart"] = {type = "mob", sources = {"Prismarine Spider"}},
["Yeti Heart"] = {type = "mob", sources = {"Yeti"}},
["Golem Heart"] = {type = "mob", sources = {"Ice Golem Boss"}},

["Galaxite"] = {type = "none", sources = {}},
["Vooite"] = {type = "none", sources = {}},
}

function KA.GetToolActivatedRemote()
    return KA.Services.rs
        :WaitForChild("Shared")
        :WaitForChild("Packages")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("ToolService")
        :WaitForChild("RF")
        :WaitForChild("ToolActivated")
end

pcall(function()
    KA.ToolActivatedEvent = KA.GetToolActivatedRemote()
end)

KA.Cache = {
    RocksByType = {},   
    MobTypes = {},      
    
    AddQueue = {},
    RemoveQueue = {},
    Processing = false,
}

function KA.CacheAddRock(inst)
    if not inst or not inst.Parent then return end
    local name = inst.Name
    if not KA.Cache.RocksByType[name] then
        KA.Cache.RocksByType[name] = {}
    end
    local list = KA.Cache.RocksByType[name]
    for _, v in ipairs(list) do
        if v == inst then return end
    end
    table.insert(list, inst)
end

function KA.CacheRemoveRock(inst)
    if not inst then return end
    local name = inst.Name
    local list = KA.Cache.RocksByType[name]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i] == inst or not list[i].Parent then
            table.remove(list, i)
        end
    end
    if list and #list == 0 then
        KA.Cache.RocksByType[name] = nil
    end
end

function KA.CacheAddMob(inst)
    if not inst or not inst.Parent then return end
    local nm = inst.Name or ""
    local base = nm:gsub("%d+$", "")
    if not KA.Cache.MobTypes[base] then
        KA.Cache.MobTypes[base] = {}
    end
    local list = KA.Cache.MobTypes[base]
    for _, v in ipairs(list) do
        if v == inst then return end
    end
    table.insert(list, inst)
end

function KA.CacheRemoveMob(inst)
    if not inst then return end
    local nm = inst.Name or ""
    local base = nm:gsub("%d+$", "")
    local list = KA.Cache.MobTypes[base]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i] == inst or not list[i].Parent then
            table.remove(list, i)
        end
    end
    if list and #list == 0 then
        KA.Cache.MobTypes[base] = nil
    end
end

function KA.RebuildCachesIncremental()
    
    KA.Cache.RocksByType = {}
    KA.Cache.MobTypes = {}

    local rocksFolder = workspace:FindFirstChild("Rocks")
    local living = workspace:FindFirstChild("Living")

    
    if rocksFolder then
        local desc = rocksFolder:GetDescendants()
        local idx = 1
        local total = #desc
        while idx <= total do
            local limit = math.min(total, idx + 120) 
            for i = idx, limit do
                local d = desc[i]
                if d and d:FindFirstChild("Hitbox") then
                    KA.CacheAddRock(d)
                else
                    local p = d and d.Parent
                    if p and p:FindFirstChild("Hitbox") then
                        KA.CacheAddRock(p)
                    end
                end
            end
            idx = limit + 1
            task.wait() 
        end
    end

    
    if living then
        local kids = living:GetChildren()
        local idx2 = 1
        local total2 = #kids
        while idx2 <= total2 do
            local limit2 = math.min(total2, idx2 + 120)
            for i = idx2, limit2 do
                local ent = kids[i]
                if ent and ent:FindFirstChild("HumanoidRootPart") then
                    KA.CacheAddMob(ent)
                end
            end
            idx2 = limit2 + 1
            task.wait()
        end
    end
end

function KA.QueueAdd(desc)
    if not desc then return end
    table.insert(KA.Cache.AddQueue, desc)
end

function KA.QueueRemove(desc)
    if not desc then return end
    table.insert(KA.Cache.RemoveQueue, desc)
end

if workspace then
    workspace.DescendantAdded:Connect(function(desc)
        pcall(function()
            KA.QueueAdd(desc)
        end)
    end)
    workspace.DescendantRemoving:Connect(function(desc)
        pcall(function()
            KA.QueueRemove(desc)
        end)
    end)
end

task.spawn(function()
    while true do
        task.wait(0.05) 

        
        local processed = 0
        while #KA.Cache.AddQueue > 0 and processed < 80 do
            processed = processed + 1
            local desc = table.remove(KA.Cache.AddQueue, 1)
            pcall(function()
                if desc == nil then return end
                if desc:FindFirstChild("Hitbox") then
                    KA.CacheAddRock(desc)
                else
                    local p = desc.Parent
                    if p and p:FindFirstChild("Hitbox") then
                        KA.CacheAddRock(p)
                    end
                end

                if desc:FindFirstChild("HumanoidRootPart") then
                    KA.CacheAddMob(desc)
                else
                    local p2 = desc.Parent
                    if p2 and p2:FindFirstChild("HumanoidRootPart") then
                        KA.CacheAddMob(p2)
                    end
                end
            end)
        end

        
        local removed = 0
        while #KA.Cache.RemoveQueue > 0 and removed < 80 do
            removed = removed + 1
            local desc = table.remove(KA.Cache.RemoveQueue, 1)
            pcall(function()
                if desc == nil then return end
                if desc:FindFirstChild("Hitbox") or (desc.Name and desc.Name:match("Hitbox")) then
                    local parent = desc.Parent
                    if parent and parent:FindFirstChild("Hitbox") then
                        KA.CacheRemoveRock(parent)
                    else
                        KA.CacheRemoveRock(desc)
                    end
                end

                if desc:FindFirstChild("HumanoidRootPart") or (desc.Name and desc.Name:match("HumanoidRootPart")) then
                    local parent = desc.Parent
                    if parent and parent:FindFirstChild("HumanoidRootPart") then
                        KA.CacheRemoveMob(parent)
                    else
                        KA.CacheRemoveMob(desc)
                    end
                end

                
                KA.CacheRemoveRock(desc)
                KA.CacheRemoveMob(desc)
            end)
        end
    end
end)

task.spawn(function()
    pcall(KA.RebuildCachesIncremental)
end)

function KA.CancelCurrentTween()
    KA.Tween.cancelled = true
    if KA.Tween.current_conn then
        pcall(function()
            KA.Tween.current_conn:Disconnect()
        end)
        KA.Tween.current_conn = nil
    end
end

function KA.GetOreHP(ore)
    local info = ore:FindFirstChild("infoFrame")
    if info and info:FindFirstChild("Frame") and info.Frame:FindFirstChild("rockHP") then
        return tonumber(info.Frame.rockHP.Text:match("[%d%.]+")) or 0
    end
    return nil
end

function KA.GetOreSources(ore_name)
    return KA.OreMap[ore_name] or { type = "none", sources = {} }
end

function KA.FindRocksByHP(rock_types)
    local rocks = {}
    local rocks_folder = workspace:FindFirstChild("Rocks")
    if not rocks_folder then return rocks end

    for _, area in ipairs(rocks_folder:GetChildren()) do
        for _, spawn in ipairs(area:GetChildren()) do
            for _, rock_type in ipairs(rock_types) do
                local rock = spawn:FindFirstChild(rock_type)
                if rock and rock:FindFirstChild("Hitbox") then
                    local hp = KA.GetOreHP(rock)
                    if hp and hp > 0 then
                        table.insert(rocks, { rock = rock, hp = hp, type = rock_type })
                    end
                end
            end
        end
    end

    table.sort(rocks, function(a, b) return a.hp < b.hp end)
    return rocks
end

function KA.GetBestRockForOre(ore_name)
    local source_info = KA.GetOreSources(ore_name)
    if source_info.type ~= "rock" or #source_info.sources == 0 then
        return nil
    end

    local rocks = KA.FindRocksByHP(source_info.sources)
    if #rocks > 0 then
        return rocks[1].type
    end

    return source_info.sources[1]
end

function KA.GetOreInsts(ore_tp)
    local insts = {}
    local rocks = workspace:FindFirstChild("Rocks")
    if not rocks then return insts end
    for _, area in ipairs(rocks:GetChildren()) do
        for _, spwn in ipairs(area:GetChildren()) do
            local ore_fld = spwn:FindFirstChild(ore_tp)
            if ore_fld and ore_fld:FindFirstChild("Hitbox") then
                local hp = KA.GetOreHP(ore_fld)
                if hp and hp > 0 then
                    table.insert(insts, ore_fld)
                end
            end
        end
    end
    return insts
end

function KA.GetMobInsts(mob_tp)
    local insts = {}
    local living = workspace:FindFirstChild("Living")
    if not living then return insts end
    for _, ent in ipairs(living:GetChildren()) do
        if not KA.Services.plrs:FindFirstChild(ent.Name) and ent.Name:gsub("%d+$", "") == mob_tp and ent:FindFirstChild("HumanoidRootPart") then
            local hum = ent:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                table.insert(insts, ent)
            end
        end
    end
    return insts
end

function KA.GetAllOreTypes()
    local ore_set = {}
    local rocks = workspace:FindFirstChild("Rocks")
    if not rocks then return {} end
    for _, area in ipairs(rocks:GetChildren()) do
        for _, spwn in ipairs(area:GetChildren()) do
            for _, ore_fld in ipairs(spwn:GetChildren()) do
                if ore_fld:FindFirstChild("Hitbox") then
                    ore_set[ore_fld.Name] = true
                end
            end
        end
    end
    local ores = {}
    for ore_nm in pairs(ore_set) do
        table.insert(ores, ore_nm)
    end
    table.sort(ores)
    return ores
end

function KA.GetAllMobTypes()
    local mob_set = {}
    local living = workspace:FindFirstChild("Living")
    if not living then return {} end
    for _, ent in ipairs(living:GetChildren()) do
        if not KA.Services.plrs:FindFirstChild(ent.Name) and ent:FindFirstChild("HumanoidRootPart") then
            mob_set[ent.Name:gsub("%d+$", "")] = true
        end
    end
    local mobs = {}
    for mob_nm in pairs(mob_set) do
        table.insert(mobs, mob_nm)
    end
    table.sort(mobs)
    return mobs
end

pcall(function()
    KA.ToolActivatedEvent = KA.GetToolActivatedRemote()
end)

KA.AutoQuest.CustomTween = nil
KA.AutoQuest.CustomMine = nil
KA.AutoQuest.CustomAttack = nil

function KA.TweenToPos(tgt_pos, spd, face_pos)
    if KA.AutoQuest.CustomTween then
        return KA.AutoQuest.CustomTween(tgt_pos, spd)
    end

    KA.CancelCurrentTween()
    KA.Tween.cancelled = false

    local plyr = KA.Services.plrs.LocalPlayer
    local char = plyr and (plyr.Character or plyr.CharacterAdded:Wait())
    local hrp = char and char:WaitForChild("HumanoidRootPart")

    local startPos = hrp and hrp.Position or Vector3.new()
    local dist = (tgt_pos - startPos).Magnitude
    local dur = math.max(dist / (spd or KA.Settings.tween_spd), 0.05)
    local startTime = tick()

    local done = false

    
    KA.Tween.current_conn = KA.Services.runService.Heartbeat:Connect(function()
        if done or KA.Tween.cancelled or not hrp or not hrp.Parent then
            if KA.Tween.current_conn then
                KA.Tween.current_conn:Disconnect()
                KA.Tween.current_conn = nil
            end
            done = true
            return
        end

        local elapsed = tick() - startTime
        local alpha = math.min(elapsed / dur, 1)
        local newPos = startPos:Lerp(tgt_pos, alpha)

        if face_pos then
            hrp.CFrame = CFrame.new(newPos, face_pos)
        else
            hrp.CFrame = CFrame.new(newPos)
        end

        if alpha >= 1 then
            done = true
            if KA.Tween.current_conn then
                KA.Tween.current_conn:Disconnect()
                KA.Tween.current_conn = nil
            end
            hrp.CFrame = face_pos and CFrame.new(tgt_pos, face_pos) or CFrame.new(tgt_pos)
        end
    end)

    while not done and not KA.Tween.cancelled do
        task.wait()
    end
end

function KA.MineOre(ore)
    if KA.AutoQuest.CustomMine then
        return KA.AutoQuest.CustomMine(ore)
    end

    if not ore or not ore:FindFirstChild("Hitbox") then
        return
    end

    local char = KA.Services.plrs.LocalPlayer and KA.Services.plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local target_ore = KA.State.sel_ore

    if hrp and KA.Settings.y_offset ~= 0 then
        local ore_pos = ore.Hitbox.CFrame.Position
        hrp.CFrame = CFrame.new(
            Vector3.new(ore_pos.X, ore_pos.Y + KA.Settings.y_offset, ore_pos.Z),
            ore_pos
        )
        hrp.Anchored = true

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part ~= hrp then
                part.CanCollide = false
            end
        end
    end

    while ore
        and ore.Parent
        and KA.State.is_farming
        and KA.State.sel_ore == target_ore
        and not KA.Tween.cancelled do

        local hp = KA.GetOreHP(ore)
        if not hp or hp <= 0 then
            break
        end

        if KA.ToolActivatedEvent then
            KA.ToolActivatedEvent:InvokeServer("Pickaxe")
        end

        task.wait(0.3)
    end

    if hrp and KA.Settings.y_offset ~= 0 then
        hrp.Anchored = false
    end
end

function KA.AttackMob(mob)
    if KA.AutoQuest.CustomAttack then
        return KA.AutoQuest.CustomAttack(mob)
    end

    if not mob or not mob:FindFirstChild("HumanoidRootPart") then
        return
    end

    local char = KA.Services.plrs.LocalPlayer and KA.Services.plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local target_mob = KA.State.sel_mob

    while mob
        and mob.Parent
        and KA.State.is_mob_farm
        and KA.State.sel_mob == target_mob
        and not KA.Tween.cancelled do

        local hum = mob:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then
            break
        end

        local mobHrp = mob:FindFirstChild("HumanoidRootPart")
        if hrp and mobHrp then
            local mobCF = mobHrp.CFrame

            
            local behindPos =
                mobCF.Position - (mobCF.LookVector * KA.Settings.mob_back_distance)

            
            KA.TweenToPos(behindPos, KA.Settings.tween_spd, mobHrp.Position)
        end

        if KA.ToolActivatedEvent then
            KA.ToolActivatedEvent:InvokeServer("Weapon")
        end

        task.wait(0.25)
    end
end

function KA.GetActiveQuests()
    local quests = {}
    local plyr = KA.Services.plrs.LocalPlayer
    if not plyr then return quests end

    local playerGui = plyr:FindFirstChild("PlayerGui")
    if not playerGui then return quests end

    local main = playerGui:FindFirstChild("Main")
    if not main then return quests end

    local screen = main:FindFirstChild("Screen")
    if not screen then return quests end

    local questsFolder = screen:FindFirstChild("Quests")
    if not questsFolder then return quests end

    local questList = questsFolder:FindFirstChild("List")
    if not questList then return quests end

    for _, child in ipairs(questList:GetChildren()) do
        if child.Name:match("List$") and child:IsA("Frame") then
            local questId = child.Name:gsub("List$", "")
            local tasks = {}

            local titleFrame = questList:FindFirstChild(questId .. "Title")
            local displayName = questId
            if titleFrame then
                local frame = titleFrame:FindFirstChild("Frame")
                local textLabel = frame and frame:FindFirstChild("TextLabel")
                if textLabel then
                    displayName = textLabel.Text
                end
            end

            for _, taskChild in ipairs(child:GetChildren()) do
                if tonumber(taskChild.Name) then
                    local taskMain = taskChild:FindFirstChild("Main")
                    local textLabel = taskMain and taskMain:FindFirstChild("TextLabel")
                    if textLabel and textLabel:IsA("TextLabel") then
                        table.insert(tasks, {
                            text = textLabel.Text,
                            frame = taskChild,
                            index = tonumber(taskChild.Name),
                        })
                    end
                end
            end

            table.sort(tasks, function(a, b) return a.index < b.index end)

            if #tasks > 0 then
                table.insert(quests, {
                    name = questId,
                    displayName = displayName,
                    tasks = tasks,
                })
            end
        end
    end

    if KA.State.sel_quest then
        table.sort(quests, function(a, b)
            if a.name == KA.State.sel_quest then return true end
            if b.name == KA.State.sel_quest then return false end
            return a.name < b.name
        end)
    end

    return quests
end

function KA.ParseTask(text)
    if not text or text == "" then
        return nil
    end

    local action, target, current, required =
        text:match("^%-?%s*(%w+)%s+(.+):%s*(%d+)/(%d+)")

    if not action then
        return nil
    end

    action = action:lower()

    current = tonumber(current)
    required = tonumber(required)

    return {
        action = action,
        target = target,
        current = current,
        required = required,
        completed = current >= required,
    }
end

function KA.RunAutoQuest()
    if not KA.State.auto_quest_en then
        return
    end

    local quests = KA.GetActiveQuests()

    if #quests == 0 then
        if KA.State.current_quest_task ~= "NO_QUESTS" then
            KA.State.current_quest_task = "NO_QUESTS"
                    end
        return
    end

    for _, quest in ipairs(quests) do
        local questLabel = quest.displayName or quest.name

        for _, task in ipairs(quest.tasks) do
            local parsed = KA.ParseTask(task.text)

            if parsed and not parsed.completed then
                local task_id =
                    quest.name .. "_" ..
                    parsed.action .. "_" ..
                    parsed.target .. "_" ..
                    parsed.required

                if KA.State.current_quest_task == task_id then
                    if parsed.action == "mine"
                        or parsed.action == "get"
                        or parsed.action == "collect" then

                        if not KA.State.is_farming then
                            KA.State.is_farming = true
                            KA.State.is_mob_farm = false
                        end

                    elseif parsed.action == "kill" then
                        if not KA.State.is_mob_farm then
                            KA.State.is_mob_farm = true
                            KA.State.is_farming = false
                        end
                    end
                    return
                end

                KA.CancelCurrentTween()
                KA.State.current_quest_task = task_id

                if parsed.action == "purchase" or parsed.action == "buy" then
                    
                elseif parsed.action == "mine" then
                    KA.State.sel_ore = parsed.target
                    KA.State.is_farming = true
                    KA.State.is_mob_farm = false
                                        return

                elseif parsed.action == "get" or parsed.action == "collect" then
                    local source_info = KA.GetOreSources(parsed.target)

                    if parsed.target:lower() == "ore" then
                        KA.State.sel_ore = KA.Fallback.rock or "Pebble"
                        KA.State.is_farming = true
                        KA.State.is_mob_farm = false
                        KA.Fallback.active = true
                                                return
                    end

                    if source_info.type == "rock" then
                        local best_rock = KA.GetBestRockForOre(parsed.target)
                        if best_rock then
                            KA.State.sel_ore = best_rock
                            KA.State.is_farming = true
                            KA.State.is_mob_farm = false
                            KA.Fallback.active = false
                                                        return
                        end

                    elseif source_info.type == "mob" then
                        KA.State.sel_mob = source_info.sources[1]
                        KA.State.is_mob_farm = true
                        KA.State.is_farming = false
                        KA.Fallback.active = false
                                                return
                    end

                    
                    if KA.Fallback.mode == "Farm Rocks" and KA.Fallback.rock then
                        KA.State.sel_ore = KA.Fallback.rock
                        KA.State.is_farming = true
                        KA.State.is_mob_farm = false
                        KA.Fallback.active = true
                                                return

                    elseif KA.Fallback.mode == "Farm Mobs" and KA.Fallback.mob then
                        KA.State.sel_mob = KA.Fallback.mob
                        KA.State.is_mob_farm = true
                        KA.State.is_farming = false
                        KA.Fallback.active = true
                                                return
                    end

                elseif parsed.action == "kill" then
                    KA.State.sel_mob = parsed.target
                    KA.State.is_mob_farm = true
                    KA.State.is_farming = false
                                        return
                end
            end
        end
    end

    if KA.State.current_quest_task ~= "ALL_DONE" then
        KA.State.current_quest_task = "ALL_DONE"
        KA.State.is_farming = false
        KA.State.is_mob_farm = false
            end
end

task.spawn(function()
    while true do
        task.wait(1)

        if KA.Stuck.death_recovery_en
                and KA.State.auto_quest_en
                and (KA.State.is_farming or KA.State.is_mob_farm) then

            local char = KA.Services.plrs.LocalPlayer and KA.Services.plrs.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                local current_pos = hrp.Position

                if KA.Stuck.last_position then
                    local dist = (current_pos - KA.Stuck.last_position).Magnitude
                    if dist > 1 then
                        KA.Stuck.last_move_time = tick()
                    end
                end

                KA.Stuck.last_position = current_pos

                if tick() - KA.Stuck.last_move_time >= KA.Stuck.stuck_threshold then
                    
                    KA.State.current_quest_task = nil
                    KA.State.is_farming = false
                    KA.State.is_mob_farm = false

                    KA.CancelCurrentTween()
                    task.wait(0.5)

                    KA.Stuck.last_move_time = tick()
                end
            end
        else
            KA.Stuck.last_position = nil
            KA.Stuck.last_move_time = tick()
        end
    end
end)

KA.State.last_quest_check_time = 0

task.spawn(function()
    while true do
        task.wait(0.1)

        if KA.State.auto_quest_en and tick() - KA.State.last_quest_check_time >= 0.5 then
            pcall(KA.RunAutoQuest)
            KA.State.last_quest_check_time = tick()
        end

        if KA.State.is_farming and KA.State.sel_ore and not KA.State.is_mining then
            local ores = KA.GetOreInsts(KA.State.sel_ore)
            while #ores > 0 and KA.State.is_farming and KA.State.auto_quest_en do
                local ore = ores[1]
                if not ore or not ore:FindFirstChild("Hitbox") then break end
                KA.State.is_mining = true
                KA.TweenToPos(ore.Hitbox.CFrame.Position, KA.Settings.tween_spd)
                KA.MineOre(ore)
                KA.State.is_mining = false
                ores = KA.GetOreInsts(KA.State.sel_ore)
            end
        end

        if not KA.State.is_farming then
            KA.State.is_mining = false
        end

        if KA.State.is_mob_farm and KA.State.sel_mob and not KA.State.is_atk then
            local mobs = KA.GetMobInsts(KA.State.sel_mob)
            while #mobs > 0 and KA.State.is_mob_farm and KA.State.auto_quest_en do
                local mob = mobs[1]
                if not mob or not mob:FindFirstChild("HumanoidRootPart") then break end
                KA.State.is_atk = true
                KA.TweenToPos(mob.HumanoidRootPart.Position, KA.Settings.tween_spd)
                KA.AttackMob(mob)
                KA.State.is_atk = false
                mobs = KA.GetMobInsts(KA.State.sel_mob)
            end
        end

        if not KA.State.is_mob_farm then
            KA.State.is_atk = false
        end
    end
end)

function KA.AutoQuest.Enable()
    KA.State.auto_quest_en = true
    KA.State.current_quest_task = nil
    KA.State.last_quest_check_time = 0
    end

function KA.AutoQuest.Disable()
    KA.State.auto_quest_en = false
    KA.CancelCurrentTween()

    KA.State.current_quest_task = nil
    KA.State.is_farming = false
    KA.State.is_mob_farm = false
    KA.State.is_mining = false
    KA.State.is_atk = false
    KA.Fallback.active = false

    local char = KA.Services.plrs.LocalPlayer and KA.Services.plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = false end

    end

function KA.AutoQuest.SetFallback(mode, rock, mob)
    KA.Fallback.mode = mode or "None"
    KA.Fallback.rock = rock
    KA.Fallback.mob = mob
    end

function KA.AutoQuest.SetSpeed(speed)
    KA.Settings.tween_spd = speed or 30
end

function KA.AutoQuest.SetOffsets(y)
    KA.Settings.y_offset = y or 0
end

function KA.AutoQuest.SetStuckDetection(enabled, threshold)
    KA.Stuck.death_recovery_en = enabled ~= false
    KA.Stuck.stuck_threshold = threshold or 5
end

function KA.AutoQuest.SetQuest(questId)
    KA.State.sel_quest = questId
    KA.State.current_quest_task = nil
end

function KA.AutoQuest.GetOreTypes()
    return KA.GetAllOreTypes()
end

function KA.AutoQuest.GetMobTypes()
    return KA.GetAllMobTypes()
end

function KA.AutoQuest.IsEnabled()
    return KA.State.auto_quest_en
end

function KA.AutoQuest.IsFarming()
    return KA.State.is_farming
end

function KA.AutoQuest.IsMobFarming()
    return KA.State.is_mob_farm
end

function KA.GetQuestNames()
    local names = {}
    local plyr = KA.Services.plrs.LocalPlayer
    if not plyr then return { "None" } end

    local gui = plyr:FindFirstChild("PlayerGui")
    local main = gui and gui:FindFirstChild("Main")
    local screen = main and main:FindFirstChild("Screen")
    local questsFolder = screen and screen:FindFirstChild("Quests")
    local questList = questsFolder and questsFolder:FindFirstChild("List")
    if not questList then return { "None" } end

    for _, child in ipairs(questList:GetChildren()) do
        if child:IsA("Frame") and child.Name:match("List$") then
            local questId = child.Name:gsub("List$", "")
            local title = questList:FindFirstChild(questId .. "Title")
            local label = questId

            if title then
                local frame = title:FindFirstChild("Frame")
                local txt = frame and frame:FindFirstChild("TextLabel")
                if txt then label = txt.Text end
            end

            table.insert(names, label)
        end
    end

    if #names == 0 then
        return { "None" }
    end

    table.insert(names, 1, "Auto (All)")
    return names
end

function KA.SafeSetDropdownValues(dd, values)
    if not dd then return end
    pcall(function()
        if dd.SetValues then
            dd:SetValues(values)
        elseif dd.SetOptions then
            dd:SetOptions(values)
        elseif dd.Update then
            dd:Update(values)
        else
            dd.Values = values
        end
    end)
end

QuestTab = Window:Tab({
Title = "Quest",
Icon = "scroll",
})

QuestTab:Paragraph({
Title = "Made By @Swev",
Desc = "This feature has been made by @Swev. Special thanks to him!",
})

local StatsParagraph = QuestTab:Paragraph({
Title = "Progress",
Desc = "Loading...",
})

function KA.UpdateStats()
    local ok, err = pcall(function()
        local status = KA.State.auto_quest_en and "Running" or "Disabled"
        local mode = "Idle"

        if KA.State.is_farming then
            mode = "Mining: " .. (KA.State.sel_ore or "N/A")
        end
        if KA.State.is_mob_farm then
            mode = "Killing: " .. (KA.State.sel_mob or "N/A")
        end

        local quests = KA.GetActiveQuests() or {}
        local total_current, total_required = 0, 0

        for _, q in ipairs(quests) do
            for _, t in ipairs(q.tasks or {}) do
                local parsed = KA.ParseTask(t.text)
                if parsed and parsed.current and parsed.required then
                    total_current = total_current + parsed.current
                    total_required = total_required + parsed.required
                end
            end
        end

        local percent = 0
        if total_required > 0 then
            percent = math.clamp(
                math.floor((total_current / total_required) * 100 + 0.5),
                0,
                100
            )
        end

        if KA.State.sel_quest then
            for _, q in ipairs(quests) do
                if q.displayName == KA.State.sel_quest or q.name == KA.State.sel_quest then
                    local c, r = 0, 0
                    for _, t in ipairs(q.tasks or {}) do
                        local p = KA.ParseTask(t.text)
                        if p and p.current and p.required then
                            c = c + p.current
                            r = r + p.required
                        end
                    end
                    if r > 0 then
                        percent = math.clamp(
                            math.floor((c / r) * 100 + 0.5),
                            0,
                            100
                        )
                    end
                    break
                end
            end
        end

        local lines = {
            ("Quest %d%%"):format(percent),
            "Selected: " .. (KA.State.sel_quest or "Auto (All)"),
            "Status: " .. status,
            mode
        }

        if KA.Fallback.active then
            table.insert(lines, "Fallback Active: " .. (KA.Fallback.mode or "None"))
        end

        pcall(function()
            StatsParagraph:SetDesc(table.concat(lines, "\n"))
        end)
    end)

    if not ok then
        pcall(function()
            StatsParagraph:SetDesc("Stats unavailable")
        end)
    end
end

pcall(KA.UpdateStats)

QuestTab:Divider()

QuestDropdown = QuestTab:Dropdown({
Title = "Quest",
Desc = "Select quest or Auto (All)",
Values = KA.GetQuestNames(),
Value = "Auto (All)",
Callback = function(option)
    KA.State.sel_quest = (option ~= "Auto (All)" and option ~= "None") and option or nil
    KA.State.current_quest_task = nil
    KA.UpdateStats()
end
})

QuestTab:Button({
Title = "Refresh Quests",
Desc = "Refresh quest & lists",
Callback = function()
    pcall(function()
        KA.SafeSetDropdownValues(
            QuestDropdown,
            KA.GetQuestNames()
        )
    end)

    WindUI:Notify({
        Title = "Done",
        Content = "Quests refreshed",
        Duration = 2,
        Icon = "refresh-cw"
    })

    KA.UpdateStats()
end

})

QuestTab:Toggle({
Title = "Auto Quest",
Desc = "Toggle AutoQuest on/off",
Value = false,
Callback = function(state)
    if state then
        KA.AutoQuest.Enable()
    else
        KA.AutoQuest.Disable()
    end
    KA.UpdateStats()
end
})
QuestTab:Divider()
QuestTab:Slider({
Title = "Tween Speed",
Desc = "How fast to move into targets",
Step = 1,
Value = { Min = 10, Max = 100, Default = KA.Settings.tween_spd },
Callback = function(v)
    KA.Settings.tween_spd = v
    KA.UpdateStats()
end
})

QuestTab:Slider({
Title = "Mob Distance",
Desc = "How far behind the mob to stand",
Step = 0.5,
Value = { Min = 1.5, Max = 8, Default = KA.Settings.mob_back_distance },
Callback = function(v)
    KA.Settings.mob_back_distance = v
    KA.UpdateStats()
end
})

QuestTab:Slider({
Title = "Y Offset",
Desc = "Vertical offset when mining",
Step = 1,
Value = { Min = -20, Max = 20, Default = KA.Settings.y_offset },
Callback = function(v)
    KA.Settings.y_offset = v
    KA.UpdateStats()
end
})

QuestTab:Toggle({
Title = "Stuck Detection",
Desc = "Enable/disable stuck detection reset",
Value = KA.Stuck.death_recovery_en,
Callback = function(state)
    KA.Stuck.death_recovery_en = state
    KA.UpdateStats()
end
})

QuestTab:Slider({
Title = "Stuck Threshold (sec)",
Desc = "Seconds of no movement before reset",
Step = 1,
Value = { Min = 2, Max = 15, Default = KA.Stuck.stuck_threshold },
Callback = function(v)
    KA.Stuck.stuck_threshold = v
    KA.UpdateStats()
end
})
QuestTab:Divider()
function KA.RefreshUILists()
    pcall(function()
        KA.SafeSetDropdownValues(QuestDropdown, KA.GetQuestNames())
        KA.SafeSetDropdownValues(FallbackRockDropdown, KA.GetAllOreTypes())
        KA.SafeSetDropdownValues(FallbackMobDropdown, KA.GetAllMobTypes())
        KA.UpdateStats()
    end)
end

pcall(function()
    WindUI:Notify({
        Title = "AutoQuest",
        Content = "Loaded",
        Duration = 2,
        Icon = "check"
    })
end)

pcall(function()
    KA.RefreshUILists()
end)

MainTab = Window:Tab({
    Title = "MainFarm",
    Icon = "house"
})

Section = MainTab:Section({
    Title = "Auto Mine",
    Icon = "pickaxe"
})

local svc = {
    Players = game:GetService("Players"),
    RS = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    TweenService = game:GetService("TweenService"),
}

local Player = svc.Players.LocalPlayer
local function getCurrentWorld()
    local w = workspace

    if w:FindFirstChild("Forgotten Kingdom", true) then
        return "World2"
    end

    if w:FindFirstChild("Island3BossArena", true) then
        return "World3"
    end

    if w:FindFirstChild("Stonewake's Cross", true)
        or w:FindFirstChild("Rocks")
        or w:FindFirstChild("Island1CaveStart", true)
    then
        return "World1"
    end

    return "Unknown"
end

local function IsWorld2()
    local ok, w = pcall(getCurrentWorld)
    if not ok then return false end
    return tostring(w) == "World2"
end
local function IsWorld3()
    local ok, w = pcall(getCurrentWorld)
    if not ok then return false end
    return tostring(w) == "World3"
end

Players = svc.Players
ReplicatedStorage = svc.RS
Workspace = svc.Workspace
TweenService = svc.TweenService
HttpService = game:GetService("HttpService")

_G.SkipPlayerDistance = 12 
_G.PickaxesToBuy = _G.PickaxesToBuy or {}

_G.MineTheseOres = _G.MineTheseOres or {}
_G.TweenSpeed = _G.TweenSpeed or 45
_G.FilterByArea = _G.FilterByArea or false
_G.SelectedAreas = _G.SelectedAreas or {}
_G.OreSkipper = _G.OreSkipper or false
_G.NoRockFallback = _G.NoRockFallback or "Wait" 
_G.MineMode = _G.MineMode or "Ores" 
_G._HumanoidRef = nil
_G._CharacterRef = nil
_G.AutoMineVerboseDebug = true
_G.MaxTargetDistance = 400
_G.SearchCacheInterval = 3
_G.SelectedOreType = _G.SelectedOreType or nil
_G.SelectedRockType = _G.SelectedRockType or nil
local RunService = game:GetService("RunService")
local MovingToTarget = false
_G.MineHitInterval = 1 
_G._LastMineHit = 0
local TargetLockedAt = 0
local TARGET_GRACE_TIME = 0 
_G.AutoMine = _G.AutoMine or false
_G.HorizontalUndergroundSpeed = _G.HorizontalUndergroundSpeed or 35

local MineRemote
pcall(function()
if svc.RS and svc.RS:FindFirstChild("Shared") and svc.RS.Shared:FindFirstChild("Packages") then
local ok, v = pcall(function()
return svc.RS.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
end)
if ok and v then MineRemote = v end
end
end)
local function TryMineSafe()
if not MineRemote then
pcall(function()
local rr = svc.RS.Shared and svc.RS.Shared.Packages and svc.RS.Shared.Packages.Knit and svc.RS.Shared.Packages.Knit.Services and svc.RS.Shared.Packages.Knit.Services.ToolService and svc.RS.Shared.Packages.Knit.Services.ToolService.RF and svc.RS.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
if rr then pcall(function() rr:InvokeServer("Pickaxe") end) end
end)
return
end
pcall(function() MineRemote:InvokeServer("Pickaxe") end)
end

local RockDrops = {

Pebble = {"Stone","Sand Stone","Copper","Iron","Poopite"},
Rock = {"Sand Stone","Copper","Iron","Tin","Silver","Poopite","Bananite","Cardboardite","Mushroomite"},
Boulder = {"Copper","Iron","Tin","Silver","Gold","Platinum","Poopite","Bananite","Cardboardite","Mushroomite","Aite"},

["Lucky Block"] = {"Fichillium","Fichilliugeromoriteite"},    

["Basalt Rock"] = {"Silver","Gold","Platinum","Cobalt","Titanium","Lapis Lazuli","Eye Ore"},    
["Basalt Core"] = {    
    "Cobalt","Titanium","Lapis Lazuli","Quartz","Amethyst","Topaz",    
    "Diamond","Sapphire","Cuprite","Emerald","Eye Ore"    
},    
["Basalt Vein"] = {    
    "Quartz","Amethyst","Topaz","Diamond","Sapphire","Cuprite","Emerald",    
    "Ruby","Rivalite","Uranium","Mythril","Eye Ore","Lightite"    
},    

["Volcanic Rock"] = {    
    "Volcanic Rock","Topaz","Cuprite","Rivalite","Obsidian","Eye Ore",    
    "Fireite","Magmaite","Demonite","Darkryte"    
},    

Obsidian = {    
    "Obsidian","Darkryte","Demonite","Fireite","Magmaite","Voidstar"    
},    

Pumice = {    
    "Pumice","Sulfur","Fireite","Magmaite"    
},    

["Earth Crystal"] = {"Blue Crystal","Crimson Crystal","Green Crystal","Magenta Crystal","Orange Crystal","Rainbow Crystal","Arcane Crystal"},    
["Cyan Crystal"]  = {"Blue Crystal","Crimson Crystal","Green Crystal","Magenta Crystal","Orange Crystal","Rainbow Crystal","Arcane Crystal"},    
["Crimson Crystal"] = {"Blue Crystal","Crimson Crystal","Green Crystal","Magenta Crystal","Orange Crystal","Rainbow Crystal","Arcane Crystal"},    
["Violet Crystal"] = {"Blue Crystal","Crimson Crystal","Green Crystal","Magenta Crystal","Orange Crystal","Rainbow Crystal","Arcane Crystal"},    
["Light Crystal"]  = {"Blue Crystal","Crimson Crystal","Green Crystal","Magenta Crystal","Orange Crystal","Rainbow Crystal","Arcane Crystal"},    

["Frost Fossil"] = {    
    "Iceite","Snowite","Frost Fossil","Moltenfrost"    
},    

["Tide Carve"] = {    
    "Aqujade","Larimar","Tide Carve","Galestor"    
},    

Mistvein = {    
    "Mistvein","Neurotite","Aetherit","Etherealite"    
},    

Voidfractal = {    
    "Voidfractal","Voidstar","Darkryte","Neurotite"    
},    

Moltenfrost = {    
    "Moltenfrost","Fireite","Iceite","Crimsonite"    
},    

Gargantuan = {    
    "Gargantuan","Mythril","Uranium","Heavenite"    
},    

Heavenite = {    
    "Heavenite","Sanctis","Lightite","Suryafal"    
}

}

local RockTypeAliases = {
["Icy Pebble"] = "Pebble",
["Icy Rock"]   = "Rock",
["Icy Boulder"]= "Boulder",
["Iceberg"] = "Frost Fossil",
["Small Ice Crystal"] = "Frost Fossil",
["Medium Ice Crystal"] = "Frost Fossil",
["Large Ice Crystal"] = "Frost Fossil",
}

local OreTypesList = {

"Stone","Sand Stone","Copper","Iron","Poopite","Tin","Silver","Bananite","Cardboardite","Mushroomite",

"Gold","Platinum","Aite","Cobalt","Titanium","Tungsten","Uranium","Mythril",    

"Quartz","Amethyst","Topaz","Diamond","Sapphire","Emerald","Ruby","Lapis Lazuli",    
"Blue Crystal","Crimson Crystal","Green Crystal","Magenta Crystal","Orange Crystal",    
"Rainbow Crystal","Arcane Crystal",    

"Fichillium","Fichilliugeromoriteite","Eye Ore","Lightite","Rivalite","Cuprite",    
"Aetherit","Neurotite","Voidfractal","Voidstar","Etherealite","Suryafal",    

"Fireite","Magmaite","Iceite","Snowite","Frost Fossil","Moltenfrost",    

"Demonite","Darkryte","Crimsonite","Sanctis","Mistvein",    

"Malachite","Aqujade","Larimar","Tide Carve","Galestor",    

"Graphite","Sulfur","Pumice","Scheelite","Velchire","Lgarite",    
"Cryptex","Gargantuan","Heavenite","Mosasaursit"

}

local RockTypesList = {

"Pebble",
"Rock",
"Boulder",

"Basalt",    
"Basalt Rock",    
"Basalt Core",    
"Basalt Vein",    

"Volcanic Rock",    
"Lava Rock",    

"Earth Crystal",    
"Cyan Crystal",    
"Crimson Crystal",    
"Violet Crystal",    
"Light Crystal",    
"Floating Crystal",    

"Icy Pebble",    
"Icy Rock",    
"Icy Boulder",    
"Iceberg",    
"Small Ice Crystal",    
"Medium Ice Crystal",    
"Large Ice Crystal",    

"Lucky Block",    
"Heart Of The Island"

}

local RocksFolder = svc.Workspace:FindFirstChild("Rocks")
if not RocksFolder then
warn("Workspace.Rocks not found - adjust zone names or ensure folder exists")
end

local RockZones = {}
local function safeWaitFor(name)
if not RocksFolder then return nil end
local ok, res = pcall(function() return RocksFolder:WaitForChild(name, 2) end)
if ok then return res end
return nil
end
do
local z1 = safeWaitFor("Island1CaveStart")
local z2 = safeWaitFor("Island1CaveMid")
local z3 = safeWaitFor("Island1CaveDeep")
if z1 then table.insert(RockZones, z1) end
if z2 then table.insert(RockZones, z2) end
if z3 then table.insert(RockZones, z3) end
end

local function GetAllMiningAreas()
local list = {}
if not RocksFolder then return list end
for _, child in ipairs(RocksFolder:GetChildren()) do
if child:IsA("Folder") or child:IsA("Model") then
table.insert(list, child.Name)
end
end
return list
end

local function GetActiveZones()
if _G.FilterByArea and _G.SelectedAreas and #_G.SelectedAreas > 0 and RocksFolder then
local zones = {}
for _, name in ipairs(_G.SelectedAreas) do
local z = RocksFolder:FindFirstChild(name)
if z then table.insert(zones, z) end
end
if #zones > 0 then return zones end
end
if #RockZones > 0 then return RockZones end
if RocksFolder then return RocksFolder:GetChildren() end
return {}
end

local function strlower(s) if not s then return "" end return string.lower(tostring(s)) end

local function tableContainsCI(tbl, val)
if not tbl or not val then return false end
local v = strlower(val)
for _, x in ipairs(tbl) do
if strlower(x) == v then return true end
end
return false
end

local function GetBase(obj)
if not obj then return nil end

if typeof(obj) == "Instance" and obj:IsA("BasePart") then    
    return obj    
end    

if typeof(obj) == "Instance" and obj:IsA("Model") then    
    
    local tryNames = {"Hitbox", "OrePosition", "HitBox", "Rock", "Base", "Root"}    
    for _, nm in ipairs(tryNames) do    
        local candidate = obj:FindFirstChild(nm, true)  
        if candidate and candidate:IsA("BasePart") then    
            return candidate    
        end    
    end    

    if obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") then    
        return obj.PrimaryPart    
    end    

    
    for _, d in ipairs(obj:GetDescendants()) do    
        if d and d:IsA("BasePart") then    
            return d    
        end    
    end    
end    

if typeof(obj) == "Instance" then    
    local hb = obj:FindFirstChild("Hitbox")    
    if hb and hb:IsA("BasePart") then    
        return hb    
    end    
    local ore = obj:FindFirstChild("OrePosition")    
    if ore and ore:IsA("BasePart") then    
        return ore    
    end    
end    

return nil

end

local function IsPlayerNearRock(rock, maxDist)
    if not rock then return false end

    local base = GetBase(rock)
    if not base then return false end

    local rockPos = base.Position
    maxDist = maxDist or _G.SkipPlayerDistance

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if (hrp.Position - rockPos).Magnitude <= maxDist then
                    return true
                end
            end
        end
    end

    return false
end
local function OreHealth(obj)
if not obj then return nil end
local ok, hp = pcall(function() return obj:GetAttribute("Health") end)
if ok and type(hp) == "number" then return hp end
local base = GetBase(obj)
if base then
local ok2, hp2 = pcall(function() return base:GetAttribute("Health") end)
if ok2 and type(hp2) == "number" then return hp2 end
local child = base:FindFirstChild("Health")
if child and child.Value ~= nil then return tonumber(child.Value) end
end
local topchild = obj:FindFirstChild("Health")
if topchild and topchild.Value ~= nil then return tonumber(topchild.Value) end
return nil
end

local ok, hasAttr = pcall(function() return target.GetAttributeChangedSignal ~= nil end)    
if ok and target.GetAttributeChangedSignal then    
    conn = target:GetAttributeChangedSignal("Health"):Connect(onHealthChanged)    
else    
    local base = GetBase(target)    
    if base and base.GetAttributeChangedSignal then    
        conn = base:GetAttributeChangedSignal("Health"):Connect(onHealthChanged)    
    end    
end    

pollCancel = false    
task.spawn(function()    
    
    if conn then return end    
    local POLL_INTERVAL = 0.5   
    local POLL_TIMEOUT = 10      
    local elapsed = 0    
    while not pollCancel and CurrentTarget == target and elapsed < POLL_TIMEOUT do    
        local hp = OreHealth(target)    
        if hp and hp <= 0 then    
            onHealthChanged()    
            break    
        end    
        task.wait(POLL_INTERVAL)    
        elapsed = elapsed + POLL_INTERVAL    
    end    
    cleanup()    
end)

local function ImmediateRetarget(excludeTarget)

if _G._AutoMineStabilizer then
_G._AutoMineStabilizer.running = false
_G._AutoMineStabilizer.target = nil
end

_GetClosestCache.last = 0    
pcall(function() _rebuildCandidateCache() end)    

local nextTarget = nil    
local list = _GetClosestCache.list or {}    
for i = 1, #list do    
    local cand = list[i]    
    if cand and cand ~= excludeTarget and cand.Parent and IsValidTarget(cand) then    
        local hp = OreHealth(cand)    
        if hp and hp > 0 then    
            nextTarget = cand    
            break    
        end    
    end    
end    

if nextTarget then    
    CurrentTarget = nextTarget    
    LastTeleported = nil    
    
    pcall(function() TeleportToOnce(CurrentTarget) end)    
else    
    
    CurrentTarget = nil    
    LastTeleported = nil    
    _GetClosestCache.last = 0    
end

end

local function InferRockType(rock)
if not rock then return nil end

local target = rock    
if not target:IsA("Model") then    
    local cur = rock    
    while cur and cur ~= workspace do    
        if cur:IsA("Model") then    
            target = cur    
            break    
        end    
        cur = cur.Parent    
    end    
end    

if not target then return nil end    

local ok, at = pcall(function() return target:GetAttribute("RockType") end)    
if ok and at and RockDrops[tostring(at)] then    
    return tostring(at)    
end    

local ok2, at2 = pcall(function() return target:GetAttribute("Type") end)    
if ok2 and at2 and RockDrops[tostring(at2)] then    
    return tostring(at2)    
end

if RockTypeAliases[target.Name] then
return RockTypeAliases[target.Name]
end

if RockDrops[target.Name] then
return target.Name
end

local lname = strlower(target.Name or "")    
for k, _ in pairs(RockDrops) do    
    if string.find(lname, strlower(k), 1, true) then    
        return k    
    end    
end    

return nil

end

local function RockCanDropSelectedOre(rock)
if not rock then return false end
if not _G.MineTheseOres or #_G.MineTheseOres == 0 then return true end
local rtype = InferRockType(rock)
if not rtype then return false end
local possible = RockDrops[rtype]
if not possible then return false end
for _, sel in ipairs(_G.MineTheseOres) do
for _, p in ipairs(possible) do
if strlower(p) == strlower(sel) then return true end
end
end
return false
end

local function RockMatchesSelectedRockType(rock)
if not rock then return false end
local selection = (_G.MineTheseOres and _G.MineTheseOres[1]) or nil
if not selection then return false end
if strlower(rock.Name or "") == strlower(selection) then return true end
if string.find(strlower(rock.Name or ""), strlower(selection), 1, true) then return true end
local rt = InferRockType(rock)
if rt and strlower(rt) == strlower(selection) then return true end
return false
end
local function IsValidTarget(rock)
    if not rock then return false end

    
    if _G.SkipRocksNearPlayers then
        if IsPlayerNearRock(rock, _G.SkipPlayerDistance) then
            return false
        end
    end

    
    if _G.MineMode == "Ores" then
        if not _G.SelectedOreType then return false end
        return RockCanDropSelectedOre(rock)
    end

    
    if _G.MineMode == "Rocks" then
        if not _G.SelectedRockType then return false end

        local rt = InferRockType(rock)
        if not rt then return false end

        local sel = _G.SelectedRockType:lower()
        local rtl = rt:lower()

        
        if rtl == sel then
            return true
        end

        
        if string.find(rtl, sel, 1, true) then
            return true
        end

        return false
    end

    return false
end

local function DetectRockDrops(rock)
if not rock then return nil end
local detected = {}
local ok, dropsAttr = pcall(function() return rock:GetAttribute("Drops") end)
if ok and dropsAttr then
if type(dropsAttr) == "table" then
for _, v in ipairs(dropsAttr) do table.insert(detected, tostring(v)) end
return detected
elseif type(dropsAttr) == "string" then
table.insert(detected, tostring(dropsAttr)); return detected
end
end

for _, child in ipairs(rock:GetDescendants()) do
if child:IsA("BasePart") or child:IsA("Model") or child:IsA("Folder") then
local cname = child.Name or ""
for _, oreName in ipairs(OreTypesList) do
if strlower(cname) == strlower(oreName) or string.find(strlower(cname), strlower(oreName), 1, true) then
table.insert(detected, cname)
break
end
end
end
end
if #detected == 0 then return nil end
return detected
end

do

local header = MainTab:Section({
Title = "Master",
Icon = "play"
})

local masterToggle = header:Toggle({
Title = "Auto Mine (Master)",
Desc = "Enable / disable the whole auto-miner",
Value = _G.AutoMine,
Callback = function(state)

_G.AutoMine = state

if _G.AutoMine then    
        
        SetNoclip(true)    
        
    else    
        
        CurrentTarget = nil    
        LastTeleported = nil    

        SetFreeze(false)   
        SetNoclip(false)    
    end    

    
    pcall(function()    
        if WindUI then    
            WindUI:Notify({    
                Title = "Auto Mine",    
                Content = state and "Enabled" or "Disabled",    
                Duration = 1.5    
            })    
        end    
    end)    
end

})

_G.LastOreSelection = _G.LastOreSelection or ( (_G.MineTheseOres and (_G.MineMode=="Ores" and _G.MineTheseOres[1]) ) or OreTypesList[1] )
_G.LastRockSelection = _G.LastRockSelection or ( (_G.MineTheseOres and (_G.MineMode=="Rocks" and _G.MineTheseOres[1]) ) or RockTypesList[1] )

local function EnsureSelectionMatchesMode()    
    if _G.MineMode == "Ores" then    
        
        _G.MineTheseOres = { _G.LastOreSelection or OreTypesList[1] }    
        _G.SelectedOreType = _G.LastOreSelection or OreTypesList[1]
    else    
        _G.MineTheseOres = { _G.LastRockSelection or RockTypesList[1] }    
        _G.SelectedRockType = _G.LastRockSelection or RockTypesList[1]
    end    
end    
EnsureSelectionMatchesMode()    

local selectionSection = MainTab:Section({    
    Title = "Selection & Mode",    
    Icon = "settings-2"    
})

local mineTypeDropdown = selectionSection:Dropdown({
Title = "Mine Type",
Desc = "Choose what to mine",
Values = {"Ores", "Rocks"},
Value = _G.MineMode,
Multi = false,
AllowNone = false,
Callback = function(selected)

if tostring(selected) == "Ores" and IsWorld2() then
pcall(function()
if WindUI then
WindUI:Notify({
Title = "World Restriction",
Content = "You can't change to Ores in World 2!",
Duration = 2,
Icon = "alert-triangle"
})
end
end)

        task.spawn(function()    
            pcall(function()    
                if mineTypeDropdown and mineTypeDropdown.SetValue then    
                    mineTypeDropdown:SetValue(_G.MineMode or "Rocks")    
                end    
            end)    
        end)    
        return    
    end    

    
    _G.MineMode = selected    
    if selected == "Ores" then    
        _G.LastOreSelection = _G.LastOreSelection or OreTypesList[1]    
    else    
        _G.LastRockSelection = _G.LastRockSelection or RockTypesList[1]    
    end    
    EnsureSelectionMatchesMode()    
    UpdateSelectionLocks()    
    pcall(function() if WindUI then WindUI:Notify({Title="Mode", Content="Now: "..tostring(selected), Duration=1}) end end)    

    
    CurrentTarget = nil    
    LastTeleported = nil    

    if _G._AutoMineStabilizer then    
        _G._AutoMineStabilizer.running = false    
        _G._AutoMineStabilizer.target = nil    
    end    

    _GetClosestCache.last = 0    

    if _G.AutoMine then    
        SetFreeze(false)    
        task.wait(0.03)    
        SetNoclip(true)    
    end    
end

})

local function NotifyLocked(controlName)    
    pcall(function()    
        if WindUI then    
            WindUI:Notify({    
                Title = "Locked",    
                Content = tostring(controlName) .. " is locked for the current Mine Type.",    
                Duration = 2,    
                Icon = "alert-triangle",    
            })    
        end    
    end)    
end    

local oreDropdown = selectionSection:Dropdown({    
    Title = "Ore Drops",    
    Desc = "Used ONLY when Mine Type  Is Ores",    
    Values = OreTypesList,    
    Value = (_G.MineMode == "Ores") and (_G.LastOreSelection or (_G.MineTheseOres[1] or OreTypesList[1])) or ( _G.LastOreSelection or OreTypesList[1] ),    
    Multi = false,    
    AllowNone = false,    
    Callback = function(selected)    
if _G.MineMode ~= "Ores" then    
    NotifyLocked("Ore Drops")    
    pcall(function()    
        if oreDropdown and oreDropdown.SetValue then    
            oreDropdown:SetValue(_G.LastOreSelection)    
        end    
    end)    
    return    
end    

_G.SelectedOreType = selected
_G.LastOreSelection = selected

_G.MineTheseOres = { selected }

CurrentTarget = nil    
LastTeleported = nil    
_GetClosestCache.last = 0

end
})

local rockDropdown = selectionSection:Dropdown({    
    Title = "Rock Types",    
    Desc = "Used ONLY when Mine Type  Is Rocks",    
    Values = RockTypesList,    
    Value = (_G.MineMode == "Rocks") and (_G.LastRockSelection or (_G.MineTheseOres[1] or RockTypesList[1])) or ( _G.LastRockSelection or RockTypesList[1] ),    
    Multi = false,    
    AllowNone = false,    
    Callback = function(selected)    
if _G.MineMode ~= "Rocks" then    
    NotifyLocked("Rock Types")    
    pcall(function()    
        if rockDropdown and rockDropdown.SetValue then    
            rockDropdown:SetValue(_G.LastRockSelection)    
        end    
    end)    
    return    
end    

_G.SelectedRockType = selected    
_G.LastRockSelection = selected    

CurrentTarget = nil    
LastTeleported = nil    
_GetClosestCache.last = 0

end
})

local optsSection = MainTab:Section({    
    Title = "Options",    
    Icon = "settings"    
})    

local areaDropdown = nil    
local function BuildAreaDropdown()    
    local areas = GetAllMiningAreas()    
    pcall(function() if areaDropdown and areaDropdown.Destroy then areaDropdown:Destroy() end end)    
    areaDropdown = optsSection:Dropdown({    
        Title = "Select Mining Areas",    
        Desc = "Choose which area folders to mine in",    
        Values = areas,    
        Multi = true,    
        AllowNone = true,    
        Value = _G.SelectedAreas,    
        Callback = function(selected)    
            if type(selected) == "table" then _G.SelectedAreas = selected else _G.SelectedAreas = { selected } end    
        end    
    })    
end    

local refreshButton = optsSection:Button({    
    Title = "Refresh Area List",    
    Desc = "Update available mining areas",    
    Callback = function()    
        BuildAreaDropdown()    
        pcall(function() if WindUI then WindUI:Notify({Title="Areas Updated", Content="Mining areas refreshed", Duration=2}) end end)    
    end    
})    

local skipPlayersToggle = optsSection:Toggle({
    Title = "Skip Rocks Near Players",
    Desc = "Avoid player mining rocks",
    Value = _G.SkipRocksNearPlayers,
    Callback = function(v)
        _G.SkipRocksNearPlayers = v
        CurrentTarget = nil
        _GetClosestCache.last = 0
    end
})

local skipDistanceSlider = optsSection:Slider({
    Title = "Player Detection Distance",
    Desc = "How close a player must be to skip a rock",
    Step = 1,
    Value = { Min = 4, Max = 40, Default = _G.SkipPlayerDistance },
    Callback = function(val)
        _G.SkipPlayerDistance = val
        CurrentTarget = nil
        _GetClosestCache.last = 0
    end
})

   
local fallbackDropdown = optsSection:Dropdown({    
    Title = "No Rocks Fallback",    
    Desc = "What to do when no rocks match selection",    
    Values = {"Wait","Switch Area","Disable Auto Mine"},    
    Value = _G.NoRockFallback,    
    Multi = false,    
    AllowNone = false,    
    Callback = function(sel) _G.NoRockFallback = sel end    
})

local speedSlider = optsSection:Slider({
Title = "Move Speed",
Desc = "Adjust how fast you move into the ore (Slower = Safer)",
Step = 1,
Value = { Min = 12, Max = 55, Default = _G.HorizontalUndergroundSpeed or 35 },
Callback = function(value)
_G.HorizontalUndergroundSpeed = math.clamp(value, 12, 55)
end
})

local mineDistanceSlider = optsSection:Slider({
    Title = "Mining Distance",
    Desc = "How far above the rock you mine from (studs)",
    Step = 0.5,
    Value = {
        Min = 1,
        Max = 15,
        Default = _G.AboveOreHeight or 5
    },
    Callback = function(value)
        _G.AboveOreHeight = value

        
        if CurrentTarget then
            LastTeleported = nil
        end
    end
})

function UpdateSelectionLocks()
pcall(function()

if IsWorld2() then

if _G.MineMode == "Ores" then
_G.MineMode = "Rocks"
pcall(function()
if WindUI then
WindUI:Notify({
Title = "World Restriction",
Content = "Ores mode is not allowed in World 2 — switching to Rocks.",
Duration = 2,
Icon = "alert-triangle"
})
end
end)
end

        if oreDropdown and type(oreDropdown) == "table" and oreDropdown.SetEnabled then    
            pcall(function()    
                oreDropdown:SetEnabled(false)    
                if oreDropdown.SetDesc then oreDropdown:SetDesc("Locked — Ores disabled in World 2") end    
                if oreDropdown.SetValue then oreDropdown:SetValue(_G.LastOreSelection or OreTypesList[1]) end    
            end)    
        end    

        
        if rockDropdown and type(rockDropdown) == "table" and rockDropdown.SetEnabled then    
            pcall(function()    
                rockDropdown:SetEnabled(true)    
                if rockDropdown.SetDesc then rockDropdown:SetDesc("Used ONLY when Mine Type = Rocks") end    
            end)    
        end    

        
        if filterButton and type(filterButton) == "table" and filterButton.SetEnabled then pcall(function() filterButton:SetEnabled(true) end) end    
        if areaDropdown and type(areaDropdown) == "table" and areaDropdown.SetEnabled then pcall(function() areaDropdown:SetEnabled(true) end) end    
        if refreshButton and type(refreshButton) == "table" and refreshButton.SetEnabled then pcall(function() refreshButton:SetEnabled(true) end) end    
        if fallbackDropdown and type(fallbackDropdown) == "table" and fallbackDropdown.SetEnabled then pcall(function() fallbackDropdown:SetEnabled(true) end) end    
        if tweenSlider and type(tweenSlider) == "table" and tweenSlider.SetEnabled then pcall(function() tweenSlider:SetEnabled(true) end) end    
        if masterToggle and type(masterToggle) == "table" and masterToggle.SetEnabled then pcall(function() masterToggle:SetEnabled(true) end) end    

        return    
    end    

    
    if _G.MineMode == "Ores" then    
        
        if rockDropdown and type(rockDropdown) == "table" and rockDropdown.SetEnabled then    
            pcall(function()    
                rockDropdown:SetEnabled(false)    
                if rockDropdown.SetDesc then rockDropdown:SetDesc("Locked — switch to Rocks mode to edit") end    
                if rockDropdown.SetValue then rockDropdown:SetValue(_G.LastRockSelection or RockTypesList[1]) end    
            end)    
        end    

        
        if oreDropdown and type(oreDropdown) == "table" and oreDropdown.SetEnabled then    
            pcall(function()    
                oreDropdown:SetEnabled(true)    
                if oreDropdown.SetDesc then oreDropdown:SetDesc("Used ONLY when Mine Type = Ores") end    
            end)    
        end    

        if oreSkipperButton and type(oreSkipperButton) == "table" and oreSkipperButton.SetEnabled then pcall(function() oreSkipperButton:SetEnabled(true) end) end    

        if filterButton and type(filterButton) == "table" and filterButton.SetEnabled then pcall(function() filterButton:SetEnabled(true) end) end    
        if areaDropdown and type(areaDropdown) == "table" and areaDropdown.SetEnabled then pcall(function() areaDropdown:SetEnabled(true) end) end    
        if refreshButton and type(refreshButton) == "table" and refreshButton.SetEnabled then pcall(function() refreshButton:SetEnabled(true) end) end    
        if fallbackDropdown and type(fallbackDropdown) == "table" and fallbackDropdown.SetEnabled then pcall(function() fallbackDropdown:SetEnabled(true) end) end    
        if tweenSlider and type(tweenSlider) == "table" and tweenSlider.SetEnabled then pcall(function() tweenSlider:SetEnabled(true) end) end    
        if masterToggle and type(masterToggle) == "table" and masterToggle.SetEnabled then pcall(function() masterToggle:SetEnabled(true) end) end    
    else    
        
        if oreDropdown and type(oreDropdown) == "table" and oreDropdown.SetEnabled then    
            pcall(function()    
                oreDropdown:SetEnabled(false)    
                if oreDropdown.SetDesc then oreDropdown:SetDesc("Locked — switch to Ores mode to edit") end    
                if oreDropdown.SetValue then oreDropdown:SetValue(_G.LastOreSelection or OreTypesList[1]) end    
            end)    
        end    

        if oreSkipperButton and type(oreSkipperButton) == "table" and oreSkipperButton.SetEnabled then    
            pcall(function() oreSkipperButton:SetEnabled(false) end)    
        end    

        if rockDropdown and type(rockDropdown) == "table" and rockDropdown.SetEnabled then    
            pcall(function()    
                rockDropdown:SetEnabled(true)    
                if rockDropdown.SetDesc then rockDropdown:SetDesc("Used ONLY when Mine Type = Rocks") end    
            end)    
        end    

        if filterButton and type(filterButton) == "table" and filterButton.SetEnabled then pcall(function() filterButton:SetEnabled(true) end) end    
        if areaDropdown and type(areaDropdown) == "table" and areaDropdown.SetEnabled then pcall(function() areaDropdown:SetEnabled(true) end) end    
        if refreshButton and type(refreshButton) == "table" and refreshButton.SetEnabled then pcall(function() refreshButton:SetEnabled(true) end) end    
        if fallbackDropdown and type(fallbackDropdown) == "table" and fallbackDropdown.SetEnabled then pcall(function() fallbackDropdown:SetEnabled(true) end) end    
        if tweenSlider and type(tweenSlider) == "table" and tweenSlider.SetEnabled then pcall(function() tweenSlider:SetEnabled(true) end) end    
        if masterToggle and type(masterToggle) == "table" and masterToggle.SetEnabled then pcall(function() masterToggle:SetEnabled(true) end) end    
    end    
end)

end
task.spawn(function()

for i = 1, 10 do
if getCurrentWorld() ~= "Unknown" then break end
task.wait(0.5)
end

UpdateSelectionLocks()

end)

task.spawn(function()
local lastWorld = nil
while true do
local ok, w = pcall(getCurrentWorld)
local world = (ok and w) and tostring(w) or "Unknown"
if world ~= lastWorld then
lastWorld = world
pcall(UpdateSelectionLocks)
end
task.wait(1.0) 
end
end)

BuildAreaDropdown()    
UpdateSelectionLocks()    

function _G.ForceRebuildAutoMineUI()    
    BuildAreaDropdown()    
    UpdateSelectionLocks()    
end

end

do

local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

Player.CharacterAdded:Connect(function()
task.wait()
Character = Player.Character
Root = Character:WaitForChild("HumanoidRootPart")
end)
local function SetNoclip(state)
local char = Player.Character
if not char then return end
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide ~= nil then
part.CanCollide = not state
end
end
end
local FreezeActive = false

local function SetFreeze(state)
if FreezeActive == state then return end
FreezeActive = state

local char = Player.Character    
if not char then return end    
local hum = char:FindFirstChildOfClass("Humanoid")    
local root = char:FindFirstChild("HumanoidRootPart")    
if not hum or not root then return end    

if state then    
    
    hum.WalkSpeed = 0    
    hum.JumpPower = 0    
    hum.AutoRotate = false    

    
    pcall(function()    
        root.AssemblyLinearVelocity = Vector3.zero    
        root.RotVelocity = Vector3.zero    
    end)    

    
    SetNoclip(true)    
else    
    
    hum.WalkSpeed = DEFAULT_WALK    
    hum.JumpPower = DEFAULT_JUMP    
    hum.AutoRotate = true    
    pcall(function() hum.PlatformStand = false end)    

    pcall(function()    
        root.AssemblyLinearVelocity = Vector3.zero    
        root.RotVelocity = Vector3.zero    
    end)    

    
    
end

end

local LastTeleported = nil
local TELEPORT_DISTANCE = 10

local LastCandidateSeen = 0
local LastNoRockNotify = LastNoRockNotify or 0

_G.AboveOreHeight = _G.AboveOreHeight or 5

_G._AutoMineStabilizer = _G._AutoMineStabilizer or {
running = false,
target = nil
}

local function MoveToTarget(target)
    
    if not _G.AutoMine then return end
    if not target or not target.Parent then return end
    if not Root or not Root.Parent then return end

    
    if _G._AutoMineStabilizer and _G._AutoMineStabilizer.running then
        return
    end

    
    _G._AutoMineStabilizer.running = true
    _G._AutoMineStabilizer.target = target

    
    local function cancelled()
        return not _G.AutoMine
            or not (_G._AutoMineStabilizer and _G._AutoMineStabilizer.running)
            or _G._AutoMineStabilizer.target ~= target
    end

    if cancelled() then
        _G._AutoMineStabilizer.running = false
        _G._AutoMineStabilizer.target = nil
        return
    end

    
    SetNoclip(true)

    local base = GetBase(target)
    if not base then
        _G._AutoMineStabilizer.running = false
        _G._AutoMineStabilizer.target = nil
        return
    end

    
    local SPEED = math.clamp(_G.HorizontalUndergroundSpeed or 35, 12, 55)
    local ABOVE_HEIGHT = _G.AboveOreHeight or 7

    local orePos = base.Position

    
    local targetPos = Vector3.new(
        orePos.X,
        orePos.Y + ABOVE_HEIGHT,
        orePos.Z
    )

    
    while _G.AutoMine and target and target.Parent do
        if cancelled() then
            _G._AutoMineStabilizer.running = false
            _G._AutoMineStabilizer.target = nil
            return
        end

        local pos = Root.Position
        local delta = targetPos - pos
        local dist = delta.Magnitude

        if dist <= 0.35 then
            break
        end

        local dt = RunService.Heartbeat:Wait()
        if cancelled() then
            _G._AutoMineStabilizer.running = false
            _G._AutoMineStabilizer.target = nil
            return
        end

        local step = math.min(dist, SPEED * dt)
        local nextPos = pos + delta.Unit * step

        
        Root.CFrame = CFrame.lookAt(nextPos, orePos)
    end

Root.Anchored = true

while _G.AutoMine and target and target.Parent do
    if cancelled() then break end

    local hp = OreHealth(target)
    if not hp or hp <= 0 then break end

    
    Root.CFrame = CFrame.new(targetPos, orePos)

    RunService.Heartbeat:Wait()
end

Root.Anchored = false

_G._AutoMineStabilizer.running = false
_G._AutoMineStabilizer.target = nil

    if cancelled() then
        _G._AutoMineStabilizer.running = false
        _G._AutoMineStabilizer.target = nil
        return
    end

    
    local hp_now = OreHealth(target)
    if not target or not target.Parent or not hp_now or hp_now <= 0 then
        _G._AutoMineStabilizer.running = false
        _G._AutoMineStabilizer.target = nil
        return
    end

    
    _G._AutoMineStabilizer.running = false
    _G._AutoMineStabilizer.target = nil
end

local function TeleportToOnce(target)
if not target then return end

if _G._AutoMineStabilizer and _G._AutoMineStabilizer.running then    
    
    if _G._AutoMineStabilizer.target == target then    
        return    
    else    
        return    
    end    
end    

if LastTeleported == target then return end    
LastTeleported = target    

task.spawn(function()    
    pcall(function()    
        if MoveHeadToTarget then    
            MoveHeadToTarget(target)    
        else    
            MoveToTarget(target) 
        end    
    end)    
end)

end

_GetClosestCache = _GetClosestCache or {
list = {},
last = 0,
interval = 0
}

local function _find_preferred_model_for_part(part, zone)
if not part then return nil end
local p = part.Parent
while p and p ~= zone and p ~= workspace do
if p:IsA("Model") then
local lname = (p.Name or ""):lower()
if lname ~= "spawnlocation" and lname ~= "spawn" then
return p
end
end
p = p.Parent
end
return nil
end

local MAX_DESCENDANTS_PER_ZONE = 550
local SAMPLE_STEP = 6
local CULL_EXTRA = 50

local function GetWorld2RockHitbox(inst)
if not inst then return nil end
local cur = inst
while cur and cur ~= workspace do
if cur:IsA("Model") and cur.Name == "Rock" then
local hit = cur:FindFirstChild("Hitbox")
if hit and hit:IsA("BasePart") then return hit end
return nil
end
cur = cur.Parent
end
return nil
end

local function IsMineableRock(cand)
if not cand then return false end

if cand:IsA("Model") then
if cand:FindFirstChild("Hitbox", true) then return true end
if cand:FindFirstChild("OrePosition", true) then return true end

local lname = (cand.Name or ""):lower()
if lname:match("rock") or lname:match("ore") then return true end
end

if cand:IsA("BasePart") then
local name = (cand.Name or ""):lower()
if name:match("hitbox") or name:match("oreposition") or name:match("ore") then
return true
end
end
return false
end

local MAX_DESCENDANTS_PER_ZONE = 1200
local SAMPLE_STEP = 3
local CULL_EXTRA = 50

local RunService = game:GetService("RunService")
local ITEMS_PER_TICK = 250
local FLUSH_INTERVAL = 0.45

local incrementalState, incrementalConn = nil, nil

local function makeIncrementalState()
    local okRoot, rootPos = pcall(function()
        return Root and Root.Position
    end)

    local rootPosition = (okRoot and rootPos) or Vector3.new(0, 0, 0)
    local maxDist = (_G.MaxTargetDistance or 300) + CULL_EXTRA
    local maxDistSq = maxDist * maxDist

    local isWorld2 = false
    pcall(function()
        if workspace and workspace:FindFirstChild("CurrentWorld") then
            isWorld2 = tostring(workspace.CurrentWorld.Value) == "2"
        end
    end)

    return {
        zones = GetActiveZones() or {},
        zIndex = 1,
        descList = nil,
        descIndex = 1,
        newList = {},
        seen = {},
        lastFlush = tick(),
        rootPosition = rootPosition,
        maxDistSq = maxDistSq,
        isWorld2 = isWorld2,
        MAX_DESC = isWorld2 and 400 or MAX_DESCENDANTS_PER_ZONE,
        STEP = isWorld2 and 8 or SAMPLE_STEP,
    }
end

local function publishCacheIfNeeded(s, force)
    if force or (tick() - s.lastFlush) >= FLUSH_INTERVAL then
        _GetClosestCache.list = s.newList
        _GetClosestCache.last = tick()
        _GetClosestCache.interval = math.max(_G.SearchCacheInterval or 0.25, 0.15)
        if #s.newList > 0 then
            LastCandidateSeen = tick()
        end
        s.lastFlush = tick()
    end
end

local function startIncrementalCache()
    if incrementalConn then return end
    incrementalState = makeIncrementalState()

    incrementalConn = RunService.Heartbeat:Connect(function()
        local s = incrementalState
        if not s then return end

        
        pcall(function()
            if Root then s.rootPosition = Root.Position end
        end)

        local processed = 0
        while processed < ITEMS_PER_TICK do
            if s.zIndex > #s.zones then
                publishCacheIfNeeded(s, true)
                s.zones = GetActiveZones() or {}
                s.zIndex = 1
                s.descList = nil
                s.descIndex = 1
                s.newList = {}
                s.seen = {}
                s.lastFlush = tick()
                break
            end

            local zone = s.zones[s.zIndex]
            if not zone then
                s.zIndex += 1
                processed += 1
            else
                if not s.descList then
                    local children = {}
                    pcall(function() children = zone:GetChildren() end)

                    if #children <= 200 then
                        local desc = {}
                        pcall(function() desc = zone:GetDescendants() end)
                        if #desc > s.MAX_DESC then
                            local sampled = {}
                            for i = 1, #desc, s.STEP do
                                sampled[#sampled + 1] = desc[i]
                            end
                            s.descList = sampled
                        else
                            s.descList = desc
                        end
                    else
                        s.descList = children
                    end
                    s.descIndex = 1
                end

                local desc = s.descList
                if s.descIndex > #desc then
                    s.zIndex += 1
                    s.descList = nil
                else
                    local cand = desc[s.descIndex]
                    s.descIndex += 1
                    processed += 1

                    if cand and cand.ClassName ~= "SpawnLocation" then
                        local maybeMineable = false
                        local isMineableRock = false

                        local okMine, mineCheck = pcall(function()
                            return IsMineableRock and IsMineableRock(cand)
                        end)

                        if okMine and mineCheck then
                            maybeMineable = true
                            isMineableRock = true
                        else
                            local okAttr, hp = pcall(function()
                                if cand.GetAttribute then
                                    return cand:GetAttribute("HP")
                                end
                            end)

                            
                            if okAttr and type(hp) == "number" and hp > 0 then
                                maybeMineable = true
                            end
                        end

                        if maybeMineable then
                            local candPos
                            if cand:IsA("BasePart") then
                                pcall(function() candPos = cand.Position end)
                            elseif cand:IsA("Model") then
                                pcall(function()
                                    local p = cand.PrimaryPart or (GetBase and GetBase(cand))
                                    if p then candPos = p.Position end
                                end)
                            end

                            if candPos then
                                local dx = s.rootPosition.X - candPos.X
                                local dy = s.rootPosition.Y - candPos.Y
                                local dz = s.rootPosition.Z - candPos.Z
                                if dx*dx + dy*dy + dz*dz <= s.maxDistSq then
                                    if not s.seen[cand] then
                                        s.seen[cand] = true
                                        s.newList[#s.newList + 1] = cand
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        publishCacheIfNeeded(s, false)
    end)
end

local function stopIncrementalCache()
    if incrementalConn then
        incrementalConn:Disconnect()
        incrementalConn = nil
        incrementalState = nil
    end
end

startIncrementalCache()

local function GetClosestTarget()
local now = tick()
if now - (_GetClosestCache.last or 0) > (_GetClosestCache.interval or 0.15) then
pcall(function() _rebuildCandidateCache() end)
end

local nearest = nil    
local bestDistSq = math.huge    

if not (Root and Root.Parent) then return nil end    
local okRoot, rootPos = pcall(function() return Root.Position end)    
if not okRoot or not rootPos then return nil end    

local maxDist = (_G.MaxTargetDistance or 300)    
local maxDistSq = maxDist * maxDist    

local candidates = _GetClosestCache.list or {}    
for i = 1, #candidates do    
    local cand = candidates[i]    
    if cand and cand.Parent then    
        local base = GetBase(cand)    
        if base and base.Position then    
            if IsValidTarget(cand) then    
                local hp = OreHealth(cand)    
                if hp and hp > 0 then    
                    local dx = rootPos.X - base.Position.X    
                    local dy = rootPos.Y - base.Position.Y    
                    local dz = rootPos.Z - base.Position.Z    
                    local d2 = dx*dx + dy*dy + dz*dz    
                    if d2 <= maxDistSq and d2 < bestDistSq then    
                        bestDistSq = d2    
                        nearest = cand    
                    end    
                end    
            end    
        end    
    end    
end

if not nearest then
_GetClosestCache.last = 0
end
return nearest
end

local function SwitchToNextArea()
local all = GetAllMiningAreas()
if #all == 0 then return false end
local candidates = {}
for _, name in ipairs(all) do
local found = false
for _, s in ipairs(_G.SelectedAreas) do if strlower(s) == strlower(name) then found = true break end end
if not found then table.insert(candidates, name) end
end
local pick = nil
if #candidates > 0 then pick = candidates[math.random(1,#candidates)] else pick = all[math.random(1,#all)] end
_G.SelectedAreas = { pick }
_G.FilterByArea = true
pcall(function() if WindUI then WindUI:Notify({Title="Switched Area", Content="Now mining: "..tostring(pick), Duration=2}) end end)
return true
end

task.spawn(function()
while true do
task.wait()
if _G.AutoMine then
SetNoclip(true)
end
end
end)

task.spawn(function()
while true do
task.wait()
if _G.AutoMine then

SetNoclip(true)

        if CurrentTarget then    
            SetFreeze(true)    
        end    
    end    
end

end)

local CurrentTarget = nil

task.spawn(function()
while true do
task.wait() 

if not _G.AutoMine then
CurrentTarget = nil
LastTeleported = nil
SetNoclip(false)         
continue
end

SetNoclip(true)

    if not (Character and Character.Parent and Root and Root.Parent) then    
        Character = Player.Character or Player.CharacterAdded:Wait()    
        Root = Character:FindFirstChild("HumanoidRootPart")    
        continue    
    end

local valid = false
if CurrentTarget and CurrentTarget.Parent and IsValidTarget(CurrentTarget) then
local base = GetBase(CurrentTarget)
local hp = OreHealth(CurrentTarget)

if base and hp and hp > 0 then    
    valid = true    
else    
    
    CurrentTarget = nil    
    LastTeleported = nil    
    _GetClosestCache.last = 0    
end

end

    if not valid then

CurrentTarget = GetClosestTarget()
LastTeleported = nil
TargetLockedAt = tick()
end

if CurrentTarget then
local base = GetBase(CurrentTarget)
if base then
local ok, rootPos = pcall(function() return Root.Position end)
if ok and rootPos then
local dist = (rootPos - base.Position).Magnitude
if (not LastTeleported) or dist > TELEPORT_DISTANCE then
TeleportToOnce(CurrentTarget)
end
else
TeleportToOnce(CurrentTarget)
end
else
CurrentTarget = nil
LastTeleported = nil
end
else
end
end
end)

RunService.Heartbeat:Connect(function()
if not _G.AutoMine then return end
if not CurrentTarget then return end

local hp = OreHealth(CurrentTarget)    

if hp and hp > 0 then
    SetFreeze(true)    
else    
    
    SetFreeze(false)    

    
    if _G._AutoMineStabilizer then    
        _G._AutoMineStabilizer.running = false    
        _G._AutoMineStabilizer.target = nil    
    end    

    local deadTarget = CurrentTarget    
    KA.State.skipped_rocks[deadTarget] = nil
    CurrentTarget = nil    
    LastTeleported = nil    

    
    _GetClosestCache.last = 0    

    
    local nextTarget = GetClosestTarget()    
    if nextTarget and nextTarget ~= deadTarget then    
        CurrentTarget = nextTarget    
        TeleportToOnce(CurrentTarget)    
    end    

    return    
end    

local now = tick()    
if now - _G._LastMineHit < _G.MineHitInterval then return end    
_G._LastMineHit = now    

TryMineSafe()

end)

Window:Divider()

repeat task.wait(0.13) until game:IsLoaded()

KA.Players = game:GetService("Players")
KA.ReplicatedStorage = game:GetService("ReplicatedStorage")
KA.TweenService = game:GetService("TweenService")
KA.workspace = workspace

KA.player = KA.Players.LocalPlayer
repeat task.wait() until KA.player
repeat task.wait() until KA.player:FindFirstChild("PlayerGui")

KA.playerGui = KA.player.PlayerGui

local ForgeTab = Window:Tab({
Title = "Forge",
Icon = "anvil"
})

function KA.safeFindRF(path)
local node = KA.ReplicatedStorage
for i = 1, #path do
if node == nil then
return nil
end
node = node:FindFirstChild(path[i])
end
return node
end

function KA.tryRequireControllerModule(name)
local controllers = KA.ReplicatedStorage:FindFirstChild("Controllers")
if controllers ~= nil then
local forgeController = controllers:FindFirstChild("ForgeController")
if forgeController ~= nil then
local mod = forgeController:FindFirstChild(name)
if mod ~= nil then
if mod:IsA("ModuleScript") then
local ok, m = pcall(require, mod)
if ok then
if type(m) == "table" then
return m, mod
end
end
end
end
end
end

local shared = KA.ReplicatedStorage:FindFirstChild("Shared")  
if shared ~= nil then  
    local sharedControllers = shared:FindFirstChild("Controllers")  
    if sharedControllers ~= nil then  
        local forgeController = sharedControllers:FindFirstChild("ForgeController")  
        if forgeController ~= nil then  
            local mod = forgeController:FindFirstChild(name)  
            if mod ~= nil then  
                if mod:IsA("ModuleScript") then  
                    local ok, m = pcall(require, mod)  
                    if ok then  
                        if type(m) == "table" then  
                            return m, mod  
                        end  
                    end  
                end  
            end  
        end  
    end  
end  

return nil, nil

end

KA.patchedModules = {}

function KA.safePatch(name, overrideFunc)
local moduleTable, _ = KA.tryRequireControllerModule(name)
if moduleTable == nil then
return false, "module_not_found"
end

if KA.patchedModules[name] == nil then  
    KA.patchedModules[name] = moduleTable.Start  
end  

moduleTable.Start = function(...)  
    local ok, res = pcall(function()  
        return overrideFunc(moduleTable)  
    end)  

    if ok then  
        return res  
    else  
        warn("Patch override error for", name, res)  
        local orig = KA.patchedModules[name]  
        if orig ~= nil then  
            return orig  
        end  
        return nil  
    end  
end  

return true

end

function KA.restorePatch(name)
local moduleTable, _ = KA.tryRequireControllerModule(name)
if moduleTable == nil then
return false
end

local orig = KA.patchedModules[name]  
if orig ~= nil then  
    moduleTable.Start = orig  
    KA.patchedModules[name] = nil  
    return true  
end  

return false

end

function KA.meltAutoComplete(_, _, data)
local gui = KA.playerGui:FindFirstChild("Forge")
if gui ~= nil then
local melt = gui:FindFirstChild("MeltMinigame")
if melt ~= nil then
pcall(function()
melt.Visible = true
local bar = melt:FindFirstChild("Bar", true)
if bar ~= nil then
if bar:IsA("Frame") then
KA.TweenService:Create(
bar,
TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
{ Size = UDim2.fromScale(1, bar.Size.Y.Scale) }
):Play()
end
end
task.wait(0.28)
melt.Visible = false
end)
else
task.wait(0.25)
end
else
task.wait(0.25)
end

local clientTime = workspace:GetServerTimeNow()  
if data ~= nil then  
    if data.StartTime ~= nil then  
        clientTime = data.StartTime  
    end  
end  

return clientTime, true

end

function KA.pourAutoComplete(_, _, data)
local gui = KA.playerGui:FindFirstChild("Forge")
if gui ~= nil then
local pour = gui:FindFirstChild("PourMinigame")
if pour ~= nil then
pcall(function()
pour.Visible = true
local timer = pour:FindFirstChild("Timer")
if timer ~= nil then
local bar = timer:FindFirstChild("Bar")
if bar ~= nil then
if bar:IsA("Frame") then
KA.TweenService:Create(
bar,
TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
{ Size = UDim2.fromScale(1, bar.Size.Y.Scale) }
):Play()
end
end
end
task.wait(0.28)
pour.Visible = false
end)
else
task.wait(0.25)
end
else
task.wait(0.25)
end

local clientTime = workspace:GetServerTimeNow()  
if data ~= nil then  
    if data.StartTime ~= nil then  
        clientTime = data.StartTime  
    end  
end  

return clientTime

end

ForgeTab:Button({
Title = "Open Forge UI",
Callback = function()
local ProximityRF = KA.safeFindRF({"Shared","Packages","Knit","Services","ProximityService","RF","Forge"})
if ProximityRF == nil then
ProximityRF = KA.safeFindRF({"Controllers","ForgeController","RF","Forge"})
end

local StartForgeRF = KA.safeFindRF({"Shared","Packages","Knit","Services","ForgeService","RF","StartForge"})  
    if StartForgeRF == nil then  
        StartForgeRF = KA.safeFindRF({"Controllers","ForgeController","RF","StartForge"})  
    end  

    local proximity = KA.workspace:FindFirstChild("Proximity")  
    if proximity == nil then  
        warn("[Forge Helper] forge object not found in workspace.Proximity")  
        return  
    end  

    local forgeObject = proximity:FindFirstChild("Forge")  
    if forgeObject == nil then  
        warn("[Forge Helper] forge object not found in workspace.Proximity")  
        return  
    end  

    if ProximityRF ~= nil then  
        pcall(function()  
            ProximityRF:InvokeServer(forgeObject)  
        end)  
        task.wait(0.12)  
    end  

    if StartForgeRF ~= nil then  
        pcall(function()  
            StartForgeRF:InvokeServer(forgeObject)  
        end)  
    end  

      
end

})

ForgeTab:Divider()

KA.meltEnabled = false
KA.pourEnabled = false
KA.AutoHammerEnabled = false
KA.HammerPerfectEnabled = false
KA._orig_Hammer_CreateNote = nil

ForgeTab:Toggle({
Title = "Complete Melt",
Desc = "Melt minigame will auto-complete",
Type = "Checkbox",
Value = false,
Callback = function(state)
KA.meltEnabled = state
if state then
local ok, err = KA.safePatch("MeltMinigame", KA.meltAutoComplete)
if ok then
else
warn("[Forge Helper] Unable to patch MeltMinigame:", err)
end
else
if KA.restorePatch("MeltMinigame") then
end
end
end
})

ForgeTab:Toggle({
Title = "Complete Pour",
Desc = "Pour minigame will auto-complete",
Type = "Checkbox",
Value = false,
Callback = function(state)
KA.pourEnabled = state
if state then
local ok, err = KA.safePatch("PourMinigame", KA.pourAutoComplete)
if ok then
else
warn("[Forge Helper] Unable to patch PourMinigame:", err)
end
else
if KA.restorePatch("PourMinigame") then
end
end
end
})

ForgeTab:Toggle({
Title = "Auto Hammer",
Desc = "Automatically completes hammer minigame",
Type = "Checkbox",
Value = false,
Callback = function(state)
KA.AutoHammerEnabled = state
end
})

task.spawn(function()
while true do
task.wait(0.05)

if KA.AutoHammerEnabled then  
        local forgeGui = KA.playerGui:FindFirstChild("Forge")  
        if forgeGui ~= nil then  
            local hammerUI = forgeGui:FindFirstChild("HammerMinigame")  
            if hammerUI ~= nil then  
                if hammerUI.Visible then  
                    local debris = KA.workspace:FindFirstChild("Debris")  
                    if debris ~= nil then  
                        local children = debris:GetChildren()  
                        for i = 1, #children do  
                            local obj = children[i]  
                            local cd = obj:FindFirstChild("ClickDetector")  
                            if cd ~= nil then  
                                pcall(function()  
                                    fireclickdetector(cd)  
                                end)  
                            end  
                        end  
                    end  
                end  
            end  
        end  
    end  
end

end)

ForgeTab:Toggle({
Title = "Auto-Perfect Hammer",
Desc = "Automatically 'perfect' hammer minigame",
Type = "Checkbox",
Value = false,
Callback = function(state)
KA.HammerPerfectEnabled = state

local moduleTable = nil  
    moduleTable = select(1, KA.tryRequireControllerModule("HammerMinigame"))  

    if moduleTable == nil then  
        warn("[Forge Helper] HammerMinigame module not found.")  
        return  
    end  

    if state then  
        if KA._orig_Hammer_CreateNote == nil then  
            KA._orig_Hammer_CreateNote = moduleTable.CreateNote  
        end  

        moduleTable.CreateNote = function(_, noteData, ...)  
            local Lifetime = 1  
            if noteData ~= nil then  
                if noteData.Lifetime ~= nil then  
                    Lifetime = noteData.Lifetime  
                end  
            end  
            local perfectDelay = Lifetime * 25 / 44  
            task.wait(perfectDelay)  
            return true  
        end  

          
    else  
        if KA._orig_Hammer_CreateNote ~= nil then  
            moduleTable.CreateNote = KA._orig_Hammer_CreateNote  
            KA._orig_Hammer_CreateNote = nil  
              
        end  
    end  
end

})

local SellTab = Window:Tab({
Title = "AutoSell",
Icon = "circle-dollar-sign"
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
if not player then warn("AutoSell: No LocalPlayer available.") end

local function safeWaitFor(parent, name, timeout)
    timeout = timeout or 6
    local start = tick()
    while tick() - start <= timeout do
        local v = parent:FindFirstChild(name)
        if v then return v end
        task.wait(0.05)
    end
    return nil
end

local Knit, RS
pcall(function()
    RS = ReplicatedStorage
    local Shared = safeWaitFor(RS, "Shared", 1)
    if Shared then
        local Packages = Shared:FindFirstChild("Packages")
        if Packages and Packages:FindFirstChild("Knit") then
            Knit = require(Packages.Knit)
        end
    end
end)

local EquipmentsModule = nil
pcall(function()
    if RS and RS:FindFirstChild("Shared") and RS.Shared:FindFirstChild("Data") then
        local Data = RS.Shared.Data
        if Data:FindFirstChild("Equipments") then
            EquipmentsModule = require(Data.Equipments)
        end
    end
end)

_G.AutoSellWeaponsEnabled = _G.AutoSellWeaponsEnabled or false
_G.UseSellAnywhereIfAvailable = _G.UseSellAnywhereIfAvailable or false
_G.ChunkSellLimit = _G.ChunkSellLimit or 25
_G.SellDelayMs = _G.SellDelayMs or 80
_G.WeaponTypesToSell = _G.WeaponTypesToSell or {} 
_G.SellBelowPrice = _G.SellBelowPrice or 0

_G.AutoSellEnabled = _G.AutoSellEnabled or false 
_G.ItemsToSell = _G.ItemsToSell or {}
_G.SellAmount = _G.SellAmount or 1
_G.SellDelayMs = _G.SellDelayMs or 70

_G.WEAPON_TYPE_OPTIONS = {
    "Dagger","Falchion Knife","Gladius Dagger","Hook","Falchion","Gladius","Cutlass","Rapier","Chaos","Ironhand",
    "Boxing Gloves","Relevator","Uchigatana","Tachi","Crusader Sword","Long Sword","Double Battle Axe","Scythe",
    "Reaper","Hammer","Great Sword","Dragon Slayer","Skull Crusher","Comically Large Spoon"
}

local Replica = nil
local function ensureReplica()
    if Replica then return Replica end
    if Knit then
        local ok, ctrl = pcall(function() return Knit.GetController and Knit.GetController("PlayerController") end)
        if ok and ctrl then
            pcall(function() Replica = ctrl.Replica end)
        end
    end
    return Replica
end

local function notify(tbl)
    local ok
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify(tbl)
            ok = true
        elseif Window and Window.Notify then
            Window:Notify(tbl)
            ok = true
        else
                        ok = true
        end
    end)
    return ok
end
local world = getCurrentWorld()

if world == "World2" then
    notify({
        Title = "World Check",
        Content = "You are in Forgotten Kingdom (World 2)",
        Duration = 3
    })

elseif world == "World3" then
    notify({
        Title = "World Check",
        Content = "You are in Frostspire Expanse (World 3)",
        Duration = 3
    })

elseif world == "World1" then
    notify({
        Title = "World Check",
        Content = "You are in Stonewake's Cross (Main World)",
        Duration = 3
    })

else
    notify({
        Title = "World Check",
        Content = "World could not be detected",
        Duration = 3
    })
end
local function getDialogueRunCommand()
    return game:GetService("ReplicatedStorage")
        :WaitForChild("Shared")
        :WaitForChild("Packages")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("DialogueService")
        :WaitForChild("RF")
        :WaitForChild("RunCommand")
end

local function sendSellBasketDirect(basket)
    if not basket or next(basket) == nil then
        return false
    end

    local run = getDialogueRunCommand()
    local ok = pcall(function()
        run:InvokeServer("SellConfirm", {
            ["Basket"] = basket
        })
    end)

    return ok
end

local function buildWeaponBasket()
    local rep = ensureReplica()
    if not rep or not rep.Data or not rep.Data.Inventory or not rep.Data.Inventory.Equipments then
        return {}
    end

    local basket = {}
    local count = 0

    for _, item in pairs(rep.Data.Inventory.Equipments) do
        if type(item) == "table" then
            local guid = item.GUID or item.Name
            local typ = item.Type or item.Name

            
            local kind = nil
            if EquipmentsModule and typeof(EquipmentsModule.GetItemType) == "function" then
                pcall(function() kind = EquipmentsModule:GetItemType(typ) end)
            end

            local isWeapon = (kind == "Weapon") or (tostring(typ):lower():match("sword") or tostring(typ):lower():match("dagger") or tostring(typ):lower():match("axe") or tostring(typ):lower():match("scythe") or tostring(typ):lower():match("hammer"))

            if isWeapon then
                local passesType = true
                if _G.WeaponTypesToSell and #_G.WeaponTypesToSell > 0 then
                    passesType = false
                    for _, want in ipairs(_G.WeaponTypesToSell) do
                        if tostring(typ):lower():match(tostring(want):lower()) or tostring(item.Name):lower():match(tostring(want):lower()) then
                            passesType = true
                            break
                        end
                    end
                end

                if passesType then
                    
                    local priceOk = true
                    if _G.SellBelowPrice and _G.SellBelowPrice > 0 and EquipmentsModule and typeof(EquipmentsModule.CalculatePrice) == "function" then
                        local okp, p = pcall(function() return EquipmentsModule:CalculatePrice(item) end)
                        local price = (okp and p) or 0
                        if price >= _G.SellBelowPrice then priceOk = false end
                    end

                    if priceOk and guid and not basket[guid] then
                        basket[guid] = true
                        count = count + 1
                        if _G.ChunkSellLimit and count >= _G.ChunkSellLimit then break end
                    end
                end
            end
        end
    end

    return basket
end

local function buildOreBasket(itemsToSell, amount)
    amount = amount or 1
    if not itemsToSell or #itemsToSell == 0 then return {} end
    local basket = {}
    for _, name in ipairs(itemsToSell) do
        if name and name ~= "" then
            basket[tostring(name)] = amount
        end
    end
    return basket
end

local autoCoroutineWeapons
local function startAutoSellWeapons_NoTP()
    if autoCoroutineWeapons then return end
    autoCoroutineWeapons = coroutine.create(function()
        while _G.AutoSellWeaponsEnabled do
            ensureReplica()
            local basket = buildWeaponBasket()

            if not basket or not next(basket) then
                _G.AutoSellWeaponsEnabled = false
                break
            end

            
            sendSellBasketDirect(basket)

            task.wait(((_G.SellDelayMs or 80) / 1000) + 0.12)
        end
        autoCoroutineWeapons = nil
    end)
    coroutine.resume(autoCoroutineWeapons)
end

_G.StartAutoSellWeapons = function()
    _G.AutoSellWeaponsEnabled = true
    startAutoSellWeapons_NoTP()
end

local autoCoroutineOres
local function startAutoSellLoop_NoTP()
    if autoCoroutineOres then return end
    autoCoroutineOres = coroutine.create(function()
        while _G.AutoSellEnabled do
            if not (_G.ItemsToSell and #_G.ItemsToSell > 0) then
                task.wait(0.5)
                continue
            end

            local basket = buildOreBasket(_G.ItemsToSell, _G.SellAmount)
            if not basket or not next(basket) then
                task.wait(0.5)
                continue
            end

            
            sendSellBasketDirect(basket)

            task.wait(((_G.SellDelayMs or 70) / 1000) + 0.12)
        end
        autoCoroutineOres = nil
    end)
    coroutine.resume(autoCoroutineOres)
end

_G.StartAutoSellLoop = startAutoSellLoop_NoTP

local RunService = game:GetService("RunService")

local function tweenHRPTo(cframe, speed)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    speed = speed or 30
    local start = hrp.CFrame
    local dist = (start.Position - cframe.Position).Magnitude
    local t = dist / speed
    local elapsed = 0

    while elapsed < t do
        local dt = RunService.Heartbeat:Wait()
        elapsed += dt
        local alpha = math.clamp(elapsed / t, 0, 1)
        hrp.CFrame = start:Lerp(cframe, alpha)
    end
    hrp.CFrame = cframe
    return true
end

local function loadShopManager()
    local proxRF = RS.Shared.Packages.Knit.Services.ProximityService.RF.Dialogue

    local marbles = workspace.Proximity:FindFirstChild("Marbles")
    local greedy = workspace.Proximity:FindFirstChild("Greedy Cey")
    if not marbles or not greedy then
        notify({Title="Shop Manager",Content="NPC report to discord IMMEDIATELY!",Duration=3})
        return
    end

    local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation", true)

    
    tweenHRPTo(marbles:GetPivot(), 35)
    proxRF:InvokeServer(marbles)
    task.wait(2)

    
    tweenHRPTo(greedy:GetPivot(), 35)
    proxRF:InvokeServer(greedy)
    task.wait(1)

    
    if spawnLocation then
        tweenHRPTo(spawnLocation.CFrame + Vector3.new(0,3,0), 40)
    end

    notify({Title="Shop Manager",Content="Shop manager loaded successfully U can now use the auto sell :)",Duration=3})
end

SellTab:Section({ 
    Title = "Shop Loader",
     Icon = "loader",
})

SellTab:Button({
    Title = "Load Shop Manager",
    Desc = "Use this first to load both shops in order for auto sell to work",
    Locked = false,
    Callback = function()
        task.spawn(loadShopManager)
    end
})

SellTab:Section({ 
    Title = "Weapons",
     Icon = "swords",
})

    
    SellTab:Toggle({
        Title = "Auto Sell Weapons",
        Desc = "Automatically sells weapons.",
        Value = _G.AutoSellWeaponsEnabled,
        Callback = function(v)
            _G.AutoSellWeaponsEnabled = v
            if v then startAutoSellWeapons_NoTP() end
        end
    })

    
        SellTab:Dropdown({
            Title = "Weapon Types to Sell",
            Desc = "Leave empty to sell all weapons. Pick types to restrict.",
            Values = _G.WEAPON_TYPE_OPTIONS,
            Multi = true,
            Value = _G.WeaponTypesToSell or {},
            Callback = function(selected)
                _G.WeaponTypesToSell = selected or {}
            end
        })

    SellTab:Input({
        Title = "Sell below price (0 = disabled)",
        Desc = "Only sell items with price",
        Value = tostring(_G.SellBelowPrice or 0),
        Type = "Input",
        Placeholder = "0",
        Callback = function(s)
            local n = tonumber(s)
            _G.SellBelowPrice = (n and n >= 0) and n or 0
        end
    })

    SellTab:Slider({
        Title = "Chunk limit",
        Desc = "Max items to sell",
        Value = {Min = 5, Max = 100, Default = _G.ChunkSellLimit},
        Step = 1,
        Callback = function(v) _G.ChunkSellLimit = v end
    })

    SellTab:Slider({
        Title = "Sell delay (ms)",
        Desc = "Delay between sells",
        Value = {Min = 20, Max = 1000, Default = _G.SellDelayMs},
        Step = 5,
        Callback = function(v) _G.SellDelayMs = v end
    })

    
    SellTab:Section({ Title = "Ores", Icon = "pickaxe" })

    
    local ItemList = _G.AutoSellItemList or {
        "Aite","Amethyst","Arcane Crystal ore","Bananite","Blue Crystal ore","Boneite","Cardboardite","Cobalt",
        "Copper","Crimson Crystal ore","Cuprite","Dark Boneite","Darkryte","Demonite","Diamond","Emerald","Eye Ore",
        "Fichillium","Fireite","Gold","Green Crystal ore","Iron","Lapis Lazuli","Lightite","Magmaite","Magenta Crystal ore",
        "Mushroomite","Mythril","Obsidian","Orange Crystal ore","Platinum","Poopite","Quartz","Rainbow Crystal ore",
        "Rivalite","Ruby","Sand Stone","Sapphire","Silver","Slimite","Stone","Tin","Titanium","Topaz","Uranium","Volcanic Rock"
    }

    SellTab:Dropdown({
        Title = "Select Items to Sell",
        Desc = "Choose items to autosell",
        Values = ItemList,
        Multi = true,
        Value = _G.ItemsToSell or {},
        Callback = function(selected)
            _G.ItemsToSell = selected or {}
            pcall(function()  end)
        end
    })

    SellTab:Input({
        Title = "Amount to sell (per item)",
        Desc = "How many items to sell (You must have the exact amount of item in your inventory for it to work!)",
        Value = tostring(_G.SellAmount or 1),
        InputIcon = "bird",
        Type = "Input",
        Placeholder = "Enter number (e.g. 1)",
        Callback = function(input)
            local n = tonumber(input)
            if n and n > 0 then
                _G.SellAmount = math.floor(n)
            else
                _G.SellAmount = 1
            end
                    end
    })

    SellTab:Slider({
        Title = "Sell delay (ms)",
        Desc = "Delay between each individual sell (milliseconds).",
        Step = 1,
        Value = { Min = 20, Max = 120, Default = _G.SellDelayMs },
        Callback = function(value) _G.SellDelayMs = value end
    })

    SellTab:Toggle({
        Title = "Auto Sell",
        Desc = "Automatically Sells Your Chosen Items!",
        Value = _G.AutoSellEnabled,
        Callback = function(state)
            _G.AutoSellEnabled = state
            if state then startAutoSellLoop_NoTP() end
        end
    })

_G.RunesToSell = _G.RunesToSell or {
    { Name = "Flame Spark",       Rarity = "Rare" },
    { Name = "Frost Speck",       Rarity = "Rare" },
    { Name = "Frost Speck II",    Rarity = "Rare" },
    { Name = "Miner Shard",       Rarity = "Rare" },
    { Name = "Miner Shard 2",     Rarity = "Rare" },
    { Name = "Miner Shard II",    Rarity = "Rare" },
    { Name = "Blast Chip",        Rarity = "Rare" },
    { Name = "Briar Notch",       Rarity = "Rare" },
    { Name = "Chill Dust",        Rarity = "Rare" },
    { Name = "Chill Dust II",     Rarity = "Rare" },
    { Name = "Developer Sigil",   Rarity = "Rare" },
    { Name = "Drain Edge",        Rarity = "Rare" },
    { Name = "Rage Mark",         Rarity = "Rare" },
    { Name = "Rot Stitch",        Rarity = "Rare" },
    { Name = "Venom Crumb",       Rarity = "Rare" },
    { Name = "Ward Patch",        Rarity = "Rare" },
}

_G.EssencesToSell = _G.EssencesToSell or {
    { Name = "Tiny Essence",      Rarity = "Common" },
    { Name = "Small Essence",     Rarity = "Common" },
    { Name = "Medium Essence",    Rarity = "Uncommon" },
    { Name = "Large Essence",     Rarity = "Uncommon" },
    { Name = "Greater Essence",   Rarity = "Rare" },
    { Name = "Superior Essence",  Rarity = "Epic" },
    { Name = "Epic Essence",      Rarity = "Epic" },
    { Name = "Legendary Essence", Rarity = "Legendary" },
    { Name = "Mythical Essence",  Rarity = "Mythic" },
}

_G.SellDelayMs = _G.SellDelayMs or 70
_G.SellAmount = _G.SellAmount or 1
_G.ChunkSellLimit = _G.ChunkSellLimit or 12

_G.RuneSellAmount = _G.RuneSellAmount or _G.SellAmount
_G.EssenceSellAmount = _G.EssenceSellAmount or _G.SellAmount
_G.RuneChunkLimit = _G.RuneChunkLimit or _G.ChunkSellLimit
_G.EssenceChunkLimit = _G.EssenceChunkLimit or _G.ChunkSellLimit

_G.AutoSellRunesEnabled = _G.AutoSellRunesEnabled or false
_G.AutoSellEssencesEnabled = _G.AutoSellEssencesEnabled or false

local function tableToNameList(tbl)
    local out = {}
    for _, v in ipairs(tbl or {}) do
        if type(v) == "table" and v.Name then
            table.insert(out, tostring(v.Name))
        elseif type(v) == "string" then
            table.insert(out, tostring(v))
        end
    end
    return out
end

local function buildNamedBasketChunk(names, amount, startIdx, chunkSize)
    amount = amount or 1
    startIdx = math.max(1, startIdx or 1)
    chunkSize = math.max(1, chunkSize or #names)
    local basket = {}
    if not names or #names == 0 then return basket end

    local n = #names
    for i = 0, chunkSize - 1 do
        local idx = startIdx + i
        if idx > n then break end
        local name = names[idx]
        if name and name ~= "" then
            basket[tostring(name)] = amount
        end
    end

    return basket
end

local autoCoroutineRunes
local function startAutoSellRunes_NoTP()
    if autoCoroutineRunes then return end
    autoCoroutineRunes = coroutine.create(function()
        local idx = 1
        while _G.AutoSellRunesEnabled do
            local names = {}
            if _G.RunesSelected and #_G.RunesSelected > 0 then
                names = _G.RunesSelected
            else
                names = tableToNameList(_G.RunesToSell)
            end

            if not names or #names == 0 then
                task.wait(0.5)
                continue
            end

            local chunk = _G.RuneChunkLimit or _G.ChunkSellLimit or 12
            local amount = _G.RuneSellAmount or _G.SellAmount or 1

            if idx > #names then idx = 1 end
            local basket = buildNamedBasketChunk(names, amount, idx, chunk)

            if not basket or next(basket) == nil then
                task.wait(0.5)
                continue
            end

            pcall(function() sendSellBasketDirect(basket) end)

            
            idx = idx + chunk
            if idx > #names then idx = 1 end

            task.wait(((_G.SellDelayMs or 70) / 1000) + 0.12)
        end
        autoCoroutineRunes = nil
    end)
    coroutine.resume(autoCoroutineRunes)
end

_G.StartAutoSellRunes = function()
    _G.AutoSellRunesEnabled = true
    startAutoSellRunes_NoTP()
end

local autoCoroutineEssences
local function startAutoSellEssences_NoTP()
    if autoCoroutineEssences then return end
    autoCoroutineEssences = coroutine.create(function()
        local idx = 1
        while _G.AutoSellEssencesEnabled do
            local names = {}
            if _G.EssencesSelected and #_G.EssencesSelected > 0 then
                names = _G.EssencesSelected
            else
                names = tableToNameList(_G.EssencesToSell)
            end

            if not names or #names == 0 then
                task.wait(0.5)
                continue
            end

            local chunk = _G.EssenceChunkLimit or _G.ChunkSellLimit or 12
            local amount = _G.EssenceSellAmount or _G.SellAmount or 1

            if idx > #names then idx = 1 end
            local basket = buildNamedBasketChunk(names, amount, idx, chunk)

            if not basket or next(basket) == nil then
                task.wait(0.5)
                continue
            end

            pcall(function() sendSellBasketDirect(basket) end)

            
            idx = idx + chunk
            if idx > #names then idx = 1 end

            task.wait(((_G.SellDelayMs or 70) / 1000) + 0.12)
        end
        autoCoroutineEssences = nil
    end)
    coroutine.resume(autoCoroutineEssences)
end

_G.StartAutoSellEssences = function()
    _G.AutoSellEssencesEnabled = true
    startAutoSellEssences_NoTP()
end
local function extractNames(tbl)
    local list = {}
    for _, v in ipairs(tbl or {}) do
        if v.Name then
            table.insert(list, v.Name)
        end
    end
    return list
end

if SellTab and type(SellTab) == "table" then
    
    SellTab:Section({ Title = "Runes", Icon = "star" })
    local runeValues = tableToNameList(_G.RunesToSell)
    SellTab:Dropdown({
    Title = "Runes to Sell",
    Values = extractNames(_G.RunesToSell), 
    Multi = true,
    Value = _G.RunesSelected or {},
    Callback = function(v)
        _G.RunesSelected = v
    end
})

    SellTab:Input({
        Title = "Amount to sell (per item)",
        Desc = "How many runes to sell",
        Value = tostring(_G.RuneSellAmount or _G.SellAmount or 1),
        Placeholder = "1",
        Callback = function(input)
            local n = tonumber(input)
            if n and n > 0 then _G.RuneSellAmount = math.floor(n) else _G.RuneSellAmount = (_G.SellAmount or 1) end
        end
    })

    SellTab:Toggle({
        Title = "Auto Sell Runes",
        Desc = "Automatically sells runes",
        Value = _G.AutoSellRunesEnabled,
        Callback = function(v)
            _G.AutoSellRunesEnabled = v
            if v then startAutoSellRunes_NoTP() end
        end
    })

    
    SellTab:Section({ Title = "Essences", Icon = "flask-conical" })
    local essValues = tableToNameList(_G.EssencesToSell)
    SellTab:Dropdown({
    Title = "Essences to Sell",
    Values = extractNames(_G.EssencesToSell), 
    Multi = true,
    Value = _G.EssencesSelected or {},
    Callback = function(v)
        _G.EssencesSelected = v
    end
})

    SellTab:Input({
        Title = "Amount to sell (per item)",
        Desc = "how many essence to sell",
        Value = tostring(_G.EssenceSellAmount or _G.SellAmount or 1),
        Placeholder = "1",
        Callback = function(input)
            local n = tonumber(input)
            if n and n > 0 then _G.EssenceSellAmount = math.floor(n) else _G.EssenceSellAmount = (_G.SellAmount or 1) end
        end
    })

    SellTab:Toggle({
        Title = "Auto Sell Essences",
        Desc = "Automatically sells essences",
        Value = _G.AutoSellEssencesEnabled,
        Callback = function(v)
            _G.AutoSellEssencesEnabled = v
            if v then startAutoSellEssences_NoTP() end
        end
    })
end

local MobsTab = Window:Tab({
 Title = "Mobs",
 Icon = "sword"
})

local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local ENEMIES_MODULE_PATH = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Enemies")
local LIVING_FOLDER = workspace:WaitForChild("Living")
local ASSETS_MOBS = nil
pcall(function() ASSETS_MOBS = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Mobs") end)

local ToolRF = nil
pcall(function()
    ToolRF = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF
end)
local Enemies = require(ENEMIES_MODULE_PATH)

local selectedNames = {}
local targetType = "Nearest"
local autoAttackEnabled = false

local attackInterval = 0.14
local maxTargetDistance = 200
local AutoKite = true
local HoldBlockMode = false

local attackLoopThread = nil
local stopAttackLoop = false

local followTask = nil
local activeTween = nil
local currentFollowTarget = nil
local followConnection = nil
local LAST_GOAL_CF = nil
local GOAL_EPSILON = 0.30

local MAX_GLIDE_DIST = 240
local GLIDE_SPEED = 14
local GLIDE_STEP_MIN = 0.08
local GLIDE_STEP_MAX = 1.2
local GLIDE_CLOSE_THRESHOLD = 0.9

local AUTO_KILL_HEIGHT = 1.6
local AUTO_KILL_DISTANCE = 3.5
local AUTO_KITE_POSITION = "Behind"

local TWEEN_SPEED_FACTOR = 1.3

local NoClipDuringFollow = true
local noclipActive = false
local noclipOriginalStates = {}
local noclipConnection = nil

local function playerCharacter() return LocalPlayer and LocalPlayer.Character end
local function playerHRP()
    local c = playerCharacter()
    return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
end
local function playerHumanoid()
    local c = playerCharacter()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function safeInvokeToolActivated()
    if ToolRF and ToolRF.ToolActivated then
        pcall(function() ToolRF.ToolActivated:InvokeServer("Weapon") end)
    end
end

local function parseSliderValue(v, fallback)
    fallback = fallback or 0
    if type(v) == "number" then return v end
    if type(v) == "table" then
        if v.Value and type(v.Value) == "number" then return v.Value end
        if v.Default and type(v.Default) == "number" then return v.Default end
        for _,val in pairs(v) do
            if type(val) == "number" then return val end
        end
    end
    return fallback
end

local function findBestTarget()
    local hrp = playerHRP()
    if not hrp then return nil end
    local best, bestMetric, bestHum = nil, math.huge, nil
    for _, mob in pairs(LIVING_FOLDER:GetChildren()) do
        if mob and mob:IsA("Model") then
            local allowed = (next(selectedNames) == nil)
            if not allowed then
                for k,_ in pairs(selectedNames) do
                    if mob.Name and mob.Name:lower():find(k:lower()) then allowed = true; break end
                end
            end
            if not allowed then continue end

            local mHRP = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
            local hum = mob:FindFirstChildOfClass("Humanoid")
            if mHRP and hum and hum.Health and hum.Health > 0 then
                local dist = (mHRP.Position - hrp.Position).Magnitude
                if dist <= maxTargetDistance then
                    if targetType == "Nearest" then
                        if dist < bestMetric then best = mob; bestMetric = dist; bestHum = hum end
                    else
                        if not best or hum.Health < bestHum.Health then best = mob; bestHum = hum; bestMetric = hum.Health end
                    end
                end
            end
        end
    end
    return best
end

local function enableNoClipForCharacter()
    if noclipActive then return end
    local char = playerCharacter()
    if not char then return end

    noclipOriginalStates = {}

    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            noclipOriginalStates[part] = part.CanCollide
        end
    end

    noclipConnection = RunService.Heartbeat:Connect(function()
        local c = playerCharacter()
        if not c then return end

        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)

    noclipActive = true
end

local function disableNoClipForCharacter()
    if not noclipActive then return end

    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    for part, original in pairs(noclipOriginalStates) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = original
            end)
        end
    end

    noclipOriginalStates = {}
    noclipActive = false
end

local function computeGoalCFrameForTarget(targetHRP, distance, height)
    distance = math.max(0, tonumber(distance) or 0)

    local lookVec = targetHRP.CFrame.LookVector

    if AUTO_KITE_POSITION == "Behind" then
        local pos = targetHRP.Position - lookVec * distance + Vector3.new(0, height, 0)
        return CFrame.new(pos, targetHRP.Position)

    elseif AUTO_KITE_POSITION == "InFront" then
        local pos = targetHRP.Position + lookVec * distance + Vector3.new(0, height, 0)
        return CFrame.new(pos, targetHRP.Position)

    else
        
        local pos = targetHRP.Position - lookVec * distance + Vector3.new(0, height, 0)
        return CFrame.new(pos, targetHRP.Position)
    end
end

local function stopActiveTween()
    if activeTween then
        pcall(function()
            if typeof(activeTween.Cancel) == "function" then
                activeTween:Cancel()
            end
        end)
        activeTween = nil
    end

    if followConnection then
        pcall(function() followConnection:Disconnect() end)
        followConnection = nil
    end

    LAST_GOAL_CF = nil
end

local function applyFollowTweenNow()
    if not currentFollowTarget or not currentFollowTarget.Parent then return end
    local hrp = playerHRP()
    local tHRP = currentFollowTarget:FindFirstChild("HumanoidRootPart") or currentFollowTarget.PrimaryPart
    if not hrp or not tHRP then return end

    local goalCFrame = computeGoalCFrameForTarget(tHRP, AUTO_KILL_DISTANCE, AUTO_KILL_HEIGHT)
    local dist = (goalCFrame.Position - hrp.Position).Magnitude
    if dist > MAX_GLIDE_DIST then return end

    
    local immediateAlpha = 0.6
    pcall(function()
        hrp.CFrame = hrp.CFrame:Lerp(goalCFrame, math.clamp(immediateAlpha, 0, 1))
    end)

    LAST_GOAL_CF = goalCFrame
end

local function restartFollowIfActive()
    stopActiveTween()
    applyFollowTweenNow()
end

function startFollow(target, distanceOverride)
    if not target or not target.Parent then return end
    local distance = tonumber(distanceOverride) or AUTO_KILL_DISTANCE

    if followTask then
        pcall(function() task.cancel(followTask) end)
        followTask = nil
    end
    if followConnection then
        pcall(function() followConnection:Disconnect() end)
        followConnection = nil
    end

    currentFollowTarget = target

    followTask = task.spawn(function()
        if NoClipDuringFollow then enableNoClipForCharacter() end

        LAST_GOAL_CF = nil

        
        followConnection = RunService.Heartbeat:Connect(function(dt)
            if not autoAttackEnabled or not AutoKite or not currentFollowTarget or not currentFollowTarget.Parent then
                if followConnection then pcall(function() followConnection:Disconnect() end) end
                followConnection = nil
                return
            end

            local hrp = playerHRP()
            local tHRP = currentFollowTarget and (currentFollowTarget:FindFirstChild("HumanoidRootPart") or currentFollowTarget.PrimaryPart)
            local targetHum = currentFollowTarget and currentFollowTarget:FindFirstChildOfClass("Humanoid")

            if not hrp or not tHRP or not targetHum or (targetHum and targetHum.Health <= 0) then
                if followConnection then pcall(function() followConnection:Disconnect() end) end
                followConnection = nil
                return
            end

            local goalCFrame = computeGoalCFrameForTarget(tHRP, distance, AUTO_KILL_HEIGHT)
            local dist = (goalCFrame.Position - hrp.Position).Magnitude

            if dist > MAX_GLIDE_DIST then
                return
            end

            
            if LAST_GOAL_CF then
                if (LAST_GOAL_CF.Position - goalCFrame.Position).Magnitude >= GOAL_EPSILON then
                    LAST_GOAL_CF = goalCFrame
                end
            else
                LAST_GOAL_CF = goalCFrame
            end

            
            
            local denom = math.max(0.05, tonumber(TWEEN_SPEED_FACTOR) or 1)
            local speed = GLIDE_SPEED / denom
            local fraction = 0
            if dist > 0.001 then
                fraction = math.clamp((speed * dt) / math.max(dist, 0.01), 0, 0.45)
            else
                fraction = 0.45
            end

            
            if dist <= GLIDE_CLOSE_THRESHOLD then
                pcall(function() hrp.CFrame = goalCFrame end)
                return
            end

            local ok, err = pcall(function()
                hrp.CFrame = hrp.CFrame:Lerp(goalCFrame, fraction)
            end)
            if not ok then
                
                if followConnection then pcall(function() followConnection:Disconnect() end) end
                followConnection = nil
            end
        end)

        
        while autoAttackEnabled and AutoKite and currentFollowTarget and currentFollowTarget.Parent
          and (currentFollowTarget:FindFirstChildOfClass("Humanoid") and currentFollowTarget:FindFirstChildOfClass("Humanoid").Health > 0) do
            if not followConnection then break end
            task.wait(0.12)
        end

        if NoClipDuringFollow then disableNoClipForCharacter() end
        stopActiveTween()
        followTask = nil
        currentFollowTarget = nil
    end)
end

function stopFollow()
    if followTask then
        pcall(function() task.cancel(followTask) end)
        followTask = nil
    end
    if followConnection then
        pcall(function() followConnection:Disconnect() end)
        followConnection = nil
    end
    if NoClipDuringFollow then disableNoClipForCharacter() end
    stopActiveTween()
    currentFollowTarget = nil
end

local function startAttackLoop()
    if attackLoopThread then return end
    stopAttackLoop = false
    attackLoopThread = task.spawn(function()
        while autoAttackEnabled and not stopAttackLoop do
            local target = findBestTarget()
            if not target then task.wait(0.28); continue end

            local hrp = playerHRP()
            local hum = playerHumanoid()
            if not hrp or not hum then task.wait(0.4); continue end

            local mHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
            local targetHum = target:FindFirstChildOfClass("Humanoid")
            if not mHRP or not targetHum then task.wait(0.2); continue end

            if AutoKite then
                startFollow(target, AUTO_KILL_DISTANCE)
            end

            while autoAttackEnabled and targetHum and targetHum.Health > 0 and target.Parent and not stopAttackLoop do
                if not hrp or not hum then break end

                if AutoKite and (not followTask or currentFollowTarget ~= target) then
                    startFollow(target, AUTO_KILL_DISTANCE)
                end

                safeInvokeToolActivated()
                task.wait(math.max(0.02, tonumber(attackInterval) or 0.14))
            end

            stopFollow()
            task.wait(0.18)
        end
        attackLoopThread = nil
    end)
end

local function stopAttackLoopFn()
    stopAttackLoop = true
    if attackLoopThread then
        pcall(function() task.cancel(attackLoopThread) end)
        attackLoopThread = nil
    end
    stopFollow()
end

local dropdownValues = {}
for key, v in pairs(Enemies) do
    local icon = nil
    pcall(function()
        if ASSETS_MOBS and ASSETS_MOBS:FindFirstChild(key) then
            local asset = ASSETS_MOBS:FindFirstChild(key)
            if asset:FindFirstChild("Icon") and asset.Icon:IsA("StringValue") then
                icon = asset.Icon.Value
            elseif asset:FindFirstChild("Icon") and type(asset.Icon.Value) == "string" then
                icon = asset.Icon.Value
            end
        end
    end)
    if not icon and type(v) == "table" and v.Slot and v.Slot.Icon then icon = v.Slot.Icon end
    table.insert(dropdownValues, { Title = key, Icon = icon or "bird" })
end
table.sort(dropdownValues, function(a,b) return a.Title < b.Title end)

MobsTab:Dropdown({
    Title = "Select Mobs",
    Desc = "Select mobs to farm",
    Values = dropdownValues,
    Value = {},
    Multi = true,
    Callback = function(option)
        if type(option) == "table" then
            selectedNames = {}
            for _,v in ipairs(option) do
                if type(v) == "table" and v.Title then selectedNames[v.Title] = true end
            end
            local list = {}
            for n,_ in pairs(selectedNames) do table.insert(list, n) end
                    else
            local name = option and option.Title or tostring(option)
            if selectedNames[name] then selectedNames[name] = nil;             else selectedNames[name] = true;  end
        end
    end
})

MobsTab:Dropdown({
    Title = "Target Type",
    Desc = "Nearest / LowestHealth",
    Values = { {Title="Nearest"}, {Title="LowestHealth"} },
    Value = {Title="Nearest"},
    Callback = function(option) targetType = option.Title  end
})

MobsTab:Divider()

MobsTab:Toggle({
Title = "Auto Attack",
Desc = " automatic attack" ,
Icon = "bird",
Type = "Checkbox",
Value = false,
Callback = function(state)
    
    if state and next(selectedNames) == nil then
        WindUI:Notify({
            Title = "Auto Attack Blocked",
            Content = "You must select at least one mob before enabling Auto Attack.",
            Duration = 3,
            Icon = "bird",
        })

        
        autoAttackEnabled = false
        stopAttackLoopFn()
        stopFollow()
        return
    end

    autoAttackEnabled = state
    
    if state then
        startAttackLoop()
    else
        stopAttackLoopFn()
        stopFollow()
    end
end
})

MobsTab:Toggle({
    Title = "AutoFollow  Mobs",
    Desc = "will go to mobs.",
    Icon = "house",
    Type = "Checkbox",
    Value = AutoKite,
    Callback = function(state) AutoKite = state  end
})

MobsTab:Toggle({
    Title = "NoClip During Follow",
    Desc = "When ON, temporarily disables collisions while the script is moving you (avoid getting stuck).",
    Value = NoClipDuringFollow,
    Callback = function(state) NoClipDuringFollow = state;  end
})

MobsTab:Dropdown({
    Title = "Auto Follow osition",
    Desc = "Where to position relative to the mob",
    Values = { {Title="Behind"}, {Title="InFront"} },
    Value = {Title=AUTO_KITE_POSITION},
    Callback = function(option)
        local val = option and option.Title or tostring(option)
        AUTO_KITE_POSITION = val

        
        restartFollowIfActive()
            end
})

MobsTab:Slider({
    Title = "How Far (Distance Offset)",
    Desc = "0 = no offset, higher = further from mob",
    Value = {
        Min = 0,
        Max = 14,
        Default = AUTO_KILL_DISTANCE
    },
    Step = 0.1,
    Callback = function(v)
        AUTO_KILL_DISTANCE = tonumber(v) or 0
        restartFollowIfActive()
            end
})

MobsTab:Slider({
    Title = "Movement Speed",
    Desc = "Lower = Faster, Higher = Slower (Recommend to set it to 0.20!)",
    Value = { Min = 0.05, Max = 2.5, Default = 0.20 },
    Step = 0.05,
    Callback = function(v)
        TWEEN_SPEED_FACTOR = tonumber(v)
            end
})

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F8 then
        autoAttackEnabled = false
        stopAttackLoopFn()
        stopFollow()
        warn("Auto routines halted (F8).")
    end
end)

LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer:IsDescendantOf(game) then
        stopAttackLoopFn()
        stopFollow()
    end
end)
MobsTab:Divider()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

_G.AutoEvade = _G.AutoEvade ~= false
_G.EvadeTriggerDistance = _G.EvadeTriggerDistance or 22 

_G.AutoParry = _G.AutoParry ~= false
_G.ParryTriggerDistance = _G.ParryTriggerDistance or 22 

local EVADE_DISTANCE = 18
local EVADE_COOLDOWN = 0.35
_G.ParryDelay = _G.ParryDelay or 0.5
local PARRY_COOLDOWN = 0.05
local PARRY_DELAY = 0.12  

local ToolService
pcall(function()
	ToolService = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService
end)

local DangerousAnimations = {}

local function Normalize(id)
	return tostring(id):gsub("rbxassetid://", "")
end

local function AddAnim(anim)
	if anim and anim:IsA("Animation") then
		DangerousAnimations[Normalize(anim.AnimationId)] = true
	end
end

local A = ReplicatedStorage.Assets.Animations

AddAnim(A.Zombie.Hit1)
AddAnim(A.Zombie.Hit2)

AddAnim(A.Yeti.GetParriedNpc)
AddAnim(A.Yeti.Hit1)
AddAnim(A.Yeti.Hit2)
AddAnim(A.Yeti.Roar)

AddAnim(A.Slime.Hit1)

AddAnim(A["Skeleton Rogue"].Hit1)
AddAnim(A["Skeleton Rogue"].Hit2)

AddAnim(A.Reaper.CircleSlash)
AddAnim(A.Reaper.Hit1)
AddAnim(A.Reaper.Hit2)
AddAnim(A.Reaper.Hit3)
AddAnim(A.Reaper.parry)
AddAnim(A.Reaper.parryAttempt)

AddAnim(A.Rapier.Hit1)
AddAnim(A.Rapier.Hit2)
AddAnim(A.Rapier.Hit3)
AddAnim(A.Rapier.Hit4)
AddAnim(A.Rapier.Hit5)
AddAnim(A.Rapier.block)
AddAnim(A.Rapier.getParried)
AddAnim(A.Rapier.m2)
AddAnim(A.Rapier.parry)
AddAnim(A.Rapier.parryAttempt)

AddAnim(A["Prismarine Spider"].Bombardment)
AddAnim(A["Prismarine Spider"].Hit1)
AddAnim(A["Prismarine Spider"].Hit2)
AddAnim(A["Prismarine Spider"].Roar)
AddAnim(A["Prismarine Spider"].Slam)

AddAnim(A["Mini Demonic Spider"].Hit1)
AddAnim(A["Mini Demonic Spider"].Hit2)

AddAnim(A.Golem.Ground)
AddAnim(A.Golem.Hit1)
AddAnim(A.Golem.Hit2)
AddAnim(A.Golem.JumpDive)
AddAnim(A.Golem.Stomp)

AddAnim(A["Elite Orc"].GetParriedNpc)
AddAnim(A["Elite Orc"].Hit1)
AddAnim(A["Elite Orc"].Hit2)
AddAnim(A["Elite Orc"].Skill1)
AddAnim(A["Elite Orc"].Skill2)

AddAnim(A["Diamond Spider"].Hit1)
AddAnim(A["Diamond Spider"].Hit2)
AddAnim(A["Diamond Spider"].Spit)

AddAnim(A["Demonic Spider"].Hit1)
AddAnim(A["Demonic Spider"].Hit2)
AddAnim(A["Demonic Spider"].Spit)

AddAnim(A["Demonic Queen Spider"].Bombardment)
AddAnim(A["Demonic Queen Spider"].Hit1)
AddAnim(A["Demonic Queen Spider"].Hit2)
AddAnim(A["Demonic Queen Spider"].Roar)
AddAnim(A["Demonic Queen Spider"].Slam)

AddAnim(A["Delver Zombie"].Hit1)
AddAnim(A["Delver Zombie"].Hit2)

AddAnim(A["Deathaxe Skeleton"].Hit1)
AddAnim(A["Deathaxe Skeleton"].Hit2)

AddAnim(A["Crystal Spider"].Hit1)
AddAnim(A["Crystal Spider"].Hit2)

AddAnim(A["Crystal Golem"].GetParriedNpc)
AddAnim(A["Crystal Golem"].Hit1)
AddAnim(A["Crystal Golem"].Hit2)
AddAnim(A["Crystal Golem"].Whirlwind)

AddAnim(A["Common Orc"].Hit1)
AddAnim(A["Common Orc"].Hit2)
AddAnim(A["Common Orc"].MaceSwing)

AddAnim(A["Brute Zombie"].Hit1)
AddAnim(A["Brute Zombie"].Hit2)

AddAnim(A["Blight Pyromancer"].Fireball)
AddAnim(A["Blight Pyromancer"].Summon)

AddAnim(A["Axe Skeleton"].Hit1)
AddAnim(A["Axe Skeleton"].Hit2)

local lastEvade = 0

local function Evade(enemyRoot)
	if not _G.AutoEvade then return end
	if tick() - lastEvade < EVADE_COOLDOWN then return end
	lastEvade = tick()

	local char = Player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or not enemyRoot then return end

	local dir = (hrp.Position - enemyRoot.Position)
	if dir.Magnitude < 1 then
		dir = hrp.CFrame.LookVector
	end

	local evadePos = hrp.Position + dir.Unit * EVADE_DISTANCE
	hrp.CFrame = CFrame.new(evadePos, enemyRoot.Position)
end

local lastParry = 0

local function Parry()
	if not _G.AutoParry then return end
	if tick() - lastParry < PARRY_COOLDOWN then return end
	lastParry = tick()

	task.delay(_G.ParryDelay, function()
		pcall(function()
			ToolService.RF.StartBlock:InvokeServer()
		end)

		task.delay(0.05, function()
			pcall(function()
				ToolService.RF.StopBlock:InvokeServer()
			end)
		end)
	end)
end

local HookedMobs = {}

local function HookMob(mob)
	if HookedMobs[mob] then return end
	HookedMobs[mob] = true

	local humanoid = mob:FindFirstChildOfClass("Humanoid")
	local animController = mob:FindFirstChildOfClass("AnimationController")

	local animator
	if humanoid then
		animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end
	elseif animController then
		animator = animController:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = animController
		end
	end

	if not animator then return end

	local root =
		mob:FindFirstChild("HumanoidRootPart")
		or mob.PrimaryPart
		or mob:FindFirstChildWhichIsA("BasePart")

	if not root then return end

	animator.AnimationPlayed:Connect(function(track)
		
		if not (_G.AutoEvade or _G.AutoParry) then return end

		local anim = track.Animation
		if not anim then return end

		local animId = Normalize(anim.AnimationId)
		if not DangerousAnimations[animId] then return end

		local char = Player.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local dist = (hrp.Position - root.Position).Magnitude

		
		if _G.AutoParry and dist <= _G.ParryTriggerDistance then
			Parry()
		end

		
		if _G.AutoEvade and dist <= _G.EvadeTriggerDistance then
			Evade(root)
		end
	end)
end

task.spawn(function()
	while true do
		if _G.AutoEvade or _G.AutoParry then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("Model") and obj ~= Player.Character then
					if obj:FindFirstChildOfClass("Humanoid")
					or obj:FindFirstChildOfClass("AnimationController") then
						HookMob(obj)
					end
				end
			end
		end
		task.wait(1)
	end
end)

MobsTab:Toggle({
	Title = "Auto Evade",
	Desc = "Automatically dodge nearby mob attacks",
	Value = _G.AutoEvade,
	Callback = function(v)
		_G.AutoEvade = v
	end
})

MobsTab:Slider({
	Title = "Evade Trigger Distance",
	Desc = "Only dodge mobs within this range",

	Step = 1,
	Value = {
		Min = 20,
		Max = 120,
		Default = 22,
	},

	Callback = function(value)
		_G.EvadeTriggerDistance = value
	end
})
MobsTab:Divider()

MobsTab:Toggle({
	Title = "Auto Parry",
	Desc = "Automatically parry nearby mob attacks (MUST HAVE WEAPON EQUIPPED!)",
	Value = _G.AutoParry,
	Callback = function(v)
		_G.AutoParry = v
	end
})

MobsTab:Slider({
	Title = "Parry Trigger Distance",
	Desc = "Only parry mobs within this range",

	Step = 1,
	Value = {
		Min = 10,
		Max = 120,
		Default = 22,
	},

	Callback = function(value)
		_G.ParryTriggerDistance = value
	end
})
MobsTab:Slider({
	Title = "Parry Delay",
	Desc = "Delay before blocking (seconds)",
	Step = 0.01,
	Value = {
		Min = 0,
		Max = 1,
		Default = 0.3,
	},
	Callback = function(v)
		_G.ParryDelay = v
	end
})
                   

local Window = Window or {} 

_G.Players = game:GetService("Players")
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.RunService = game:GetService("RunService")
_G.TweenService = game:GetService("TweenService")
_G.UserInputService = game:GetService("UserInputService")

_G._POTION_POS_WORLD1 = {
    A = Vector3.new(-164.4535369873047, 28.127897262573242, 123.30853271484375),
    B = Vector3.new(-141.32115173339844, 28.473960876464844, 111.4219741821289),
}
_G._POTION_POS_WORLD2 = {
    
    A = Vector3.new(-83.55, 22.15, -45.26),
    B = Vector3.new(-105.76, 22.18, -40.61),
}

_G._POTION_POS_WORLD3 = {
    A = Vector3.new(158.12, 18.92, 55.04),
    B = Vector3.new(131.84, 19.00, 48.70),
}

_G.POTION_OPTIONS = {
    "AttackDamagePotion1",
    "HealthPotion1",
    "MinerPotion1",
    "MovementSpeedPotion1",
    "LuckPotion1",
}

_G.POTION_BUY_POS_A = _G._POTION_POS_WORLD1.A
_G.POTION_BUY_POS_B = _G._POTION_POS_WORLD1.B

_G.AutoBuyPotionsEnabled = false            
_G.PotionToBuy = _G.POTION_OPTIONS[1]       
_G.PotionBuyAmount = 3                      
_G.PotionBuyDelay = 0.6                     
_G.PotionTweenTime = 0.65                   
_G.PotionNoClipDuringTween = true           
_G.PotionVerbose = false                    

_G.PurchaseRemote = nil
_G.PurchaseRemotePathChecked = false

_G._AutoBuyCoroutine = nil
_G._AutoBuyCancel = false
_G._AutoBuyActiveTween = nil
_G._AutoBuyNoClipParts = {}                 

_G.AutoDrinkPotionsEnabled = false
_G.AutoDrinkSelectedPotions = { "HealthPotion1" } 
_G.AutoDrinkDelay = 0.8            
_G.AutoDrinkToolRF = nil           
_G.AutoDrinkCancel = false
_G._AutoDrinkCoroutine = nil

_G.AutoDrinkHealthEnabled = false
_G.AutoDrinkHealthThreshold = 45   

function _G.GetCurrentWorld()
    local w = workspace
    
    if w:FindFirstChild("Forgotten Kingdom", true) then
        return "World2"
    end
    
    if w:FindFirstChild("Island3BossArena", true) then
        return "World3"
    end
    if w:FindFirstChild("Stonewake's Cross", true) then
        return "World1"
    end
    return "Unknown"
end

function _G.UpdatePotionConfigForWorld(worldName)
    worldName = worldName or _G.GetCurrentWorld()
    local changed = false

    if worldName == "World2" then
        
        if _G.POTION_BUY_POS_A ~= _G._POTION_POS_WORLD2.A then
            _G.POTION_BUY_POS_A = _G._POTION_POS_WORLD2.A
            changed = true
        end
        if _G.POTION_BUY_POS_B ~= _G._POTION_POS_WORLD2.B then
            _G.POTION_BUY_POS_B = _G._POTION_POS_WORLD2.B
            changed = true
        end

        
        local present = false
        for _, name in ipairs(_G.POTION_OPTIONS) do
            if name == "HealthPotion2" then
                present = true
                break
            end
        end
        if not present then
            table.insert(_G.POTION_OPTIONS, 2, "HealthPotion2")
            changed = true
        end

    elseif worldName == "World3" then
        
        if _G.POTION_BUY_POS_A ~= _G._POTION_POS_WORLD3.A then
            _G.POTION_BUY_POS_A = _G._POTION_POS_WORLD3.A
            changed = true
        end
        if _G.POTION_BUY_POS_B ~= _G._POTION_POS_WORLD3.B then
            _G.POTION_BUY_POS_B = _G._POTION_POS_WORLD3.B
            changed = true
        end

        
        local present = false
        for _, name in ipairs(_G.POTION_OPTIONS) do
            if name == "HealthPotion2" then
                present = true
                break
            end
        end
        if not present then
            table.insert(_G.POTION_OPTIONS, 2, "HealthPotion2")
            changed = true
        end

    else
        
        if _G.POTION_BUY_POS_A ~= _G._POTION_POS_WORLD1.A then
            _G.POTION_BUY_POS_A = _G._POTION_POS_WORLD1.A
            changed = true
        end
        if _G.POTION_BUY_POS_B ~= _G._POTION_POS_WORLD1.B then
            _G.POTION_BUY_POS_B = _G._POTION_POS_WORLD1.B
            changed = true
        end

        
        for i = #_G.POTION_OPTIONS, 1, -1 do
            if _G.POTION_OPTIONS[i] == "HealthPotion2" then
                table.remove(_G.POTION_OPTIONS, i)
                changed = true
            end
        end

        
        local valid = false
        for _, name in ipairs(_G.POTION_OPTIONS) do
            if name == _G.PotionToBuy then
                valid = true
                break
            end
        end
        if not valid then
            _G.PotionToBuy = _G.POTION_OPTIONS[1]
            changed = true
        end
    end

    if changed and _G.PotionVerbose then
                for i, name in ipairs(_G.POTION_OPTIONS) do
                    end
            end

    return changed
end

_G.ForcePotionWorldRefresh = function()
    local world = _G.GetCurrentWorld()
    local changed = _G.UpdatePotionConfigForWorld(world)
    if changed then
            else
        if _G.PotionVerbose then  end
    end
end

_G.PotionWorldAutoDetect = true
if _G.PotionWorldAutoDetect then
    task.spawn(function()
        local last = nil
        while true do
            local ok, world = pcall(_G.GetCurrentWorld)
            if not ok then world = "Unknown" end
            if world ~= last then
                pcall(function() _G.UpdatePotionConfigForWorld(world) end)
                last = world
            end
            task.wait(3) 
        end
    end)
end

function _G.EnablePotionNoClip()
    if not _G.PotionNoClipDuringTween then return end
    local char = _G.Players.LocalPlayer and _G.Players.LocalPlayer.Character
    if not char then return end
    _G._AutoBuyNoClipParts = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            _G._AutoBuyNoClipParts[p] = p.CanCollide
            p.CanCollide = false
        end
    end
end
function _G.DisablePotionNoClip()
    local char = _G.Players.LocalPlayer and _G.Players.LocalPlayer.Character
    if not char then _G._AutoBuyNoClipParts = {} return end
    for part, original in pairs(_G._AutoBuyNoClipParts) do
        if part and part.Parent then
            pcall(function() part.CanCollide = original end)
        end
    end
    _G._AutoBuyNoClipParts = {}
end

function _G.CancelAutoBuyTween()
    if _G._AutoBuyActiveTween then
        pcall(function() _G._AutoBuyActiveTween:Cancel() end)
        _G._AutoBuyActiveTween = nil
    end
end

function _G.TweenHRPTo(vec3pos)
    local char = _G.Players.LocalPlayer and _G.Players.LocalPlayer.Character
    if not char then return false, "no-character" end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not hrp then return false, "no-hrp" end

    
    local goalCFrame = CFrame.new(vec3pos, vec3pos + Vector3.new(0,0,1))
    
    if _G.PotionNoClipDuringTween then _G.EnablePotionNoClip() end

    local tweenTime = math.max(0.02, tonumber(_G.PotionTweenTime) or 0.6)
    local ok, t = pcall(function()
        local info = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        return _G.TweenService:Create(hrp, info, { CFrame = goalCFrame })
    end)
    if not ok or not t then
        if _G.PotionNoClipDuringTween then _G.DisablePotionNoClip() end
        return false, "tween-create-failed"
    end
    _G._AutoBuyActiveTween = t
    pcall(function() t:Play() end)
    
    local done = false
    local conn
    conn = t.Completed:Connect(function() done = true end)
    
    local start = tick()
    while not done and tick() - start < (tweenTime + 0.25) do
        if _G._AutoBuyCancel or not _G.AutoBuyPotionsEnabled then
            pcall(function() t:Cancel() end)
            break
        end
        task.wait(0.02)
    end
    pcall(function() conn:Disconnect() end)
    _G._AutoBuyActiveTween = nil
    if _G.PotionNoClipDuringTween then _G.DisablePotionNoClip() end
    return done, done and "completed" or "cancelled"
end

function _G.TryPurchase(potionName, amount)
    local purchase = _G.FindPurchaseRemote and _G.FindPurchaseRemote() or nil
    if not purchase then
        
        if not _G.PurchaseRemotePathChecked then
            _G.FindPurchaseRemote = _G.FindPurchaseRemote or function()
                if _G.PurchaseRemotePathChecked and _G.PurchaseRemote then return _G.PurchaseRemote end
                _G.PurchaseRemotePathChecked = true
                local ok, svc = pcall(function()
                    local knit = _G.ReplicatedStorage:FindFirstChild("Shared") and
                                  _G.ReplicatedStorage.Shared:FindFirstChild("Packages") and
                                  _G.ReplicatedStorage.Shared.Packages:FindFirstChild("Knit")
                    if not knit then return nil end
                    local services = knit:FindFirstChild("Services")
                    if not services then return nil end
                    local prox = services:FindFirstChild("ProximityService")
                    if not prox then return nil end
                    local rf = prox:FindFirstChild("RF")
                    if not rf then return nil end
                    return rf:FindFirstChild("Purchase")
                end)
                if ok and svc then
                    _G.PurchaseRemote = svc
                    return svc
                end
                local ok2, maybe = pcall(function()
                    return _G.ReplicatedStorage.Shared.Packages.Knit.Services.ProximityService.RF.Purchase
                end)
                if ok2 and maybe then
                    _G.PurchaseRemote = maybe
                    return maybe
                end
                _G.PurchaseRemote = nil
                return nil
            end
        end
        purchase = _G.FindPurchaseRemote and _G.FindPurchaseRemote() or nil
    end
    if not purchase then return false, "no-purchase-remote" end
    local ok, res = pcall(function()
        return purchase:InvokeServer(potionName, amount)
    end)
    if ok then
        return true, res
    else
        return false, res
    end
end

function _G.StartAutoBuyPotions()
    if _G._AutoBuyCoroutine then return end
    _G.AutoBuyPotionsEnabled = true
    if type(_G.PotionToBuy) ~= "table" then
        _G.PotionToBuy = { _G.PotionToBuy }
    end
    _G._AutoBuyCancel = false
    _G._AutoBuyCoroutine = task.spawn(function()
        while _G.AutoBuyPotionsEnabled and not _G._AutoBuyCancel do
            
            local okA, infoA = _G.TweenHRPTo(_G.POTION_BUY_POS_A)
            if _G.PotionVerbose then  end
            if _G._AutoBuyCancel then break end

            
            local attempts = 0
            while not _G._AutoBuyCancel do
                attempts = attempts + 1
                local success = false

                for _, potion in ipairs(_G.PotionToBuy) do
                    local ok, res = _G.TryPurchase(potion, tonumber(_G.PotionBuyAmount) or 1)
                    if _G.PotionVerbose then
                                            end
                    if ok then
                        success = true
                    end
                end

                if success then break end
                if _G.PotionVerbose then  end
                if ok then break end
                task.wait( math.max(0.05, tonumber(_G.PotionBuyDelay) or 0.6) )
                if attempts >= 60 then
                    if _G.PotionVerbose then warn("AutoBuyPotions: giving up after many attempts, will continue loop.") end
                    break
                end
            end

            if _G._AutoBuyCancel then break end

            task.wait(0.12) 

            
            local okB, infoB = _G.TweenHRPTo(_G.POTION_BUY_POS_B)
            if _G.PotionVerbose then  end
            if _G._AutoBuyCancel then break end

            
            local attempts2 = 0
            while not _G._AutoBuyCancel do
                attempts2 = attempts2 + 1
                local success = false

                for _, potion in ipairs(_G.PotionToBuy) do
                    local ok, res = _G.TryPurchase(potion, tonumber(_G.PotionBuyAmount) or 1)
                    if _G.PotionVerbose then
                                            end
                    if ok then
                        success = true
                    end
                end

                if success then break end
                if _G.PotionVerbose then  end
                if ok then break end
                task.wait( math.max(0.05, tonumber(_G.PotionBuyDelay) or 0.6) )
                if attempts2 >= 60 then
                    if _G.PotionVerbose then warn("AutoBuyPotions: giving up after many attempts (B), continuing loop.") end
                    break
                end
            end

            
            task.wait(0.18)
        end

        
        _G._AutoBuyCoroutine = nil
        _G._AutoBuyCancel = false
        _G.AutoBuyPotionsEnabled = false
        _G.CancelAutoBuyTween()
        _G.DisablePotionNoClip()
        if _G.PotionVerbose then  end
    end)
end

function _G.StopAutoBuyPotions()
    _G._AutoBuyCancel = true
    _G.AutoBuyPotionsEnabled = false
    _G.CancelAutoBuyTween()
    _G.DisablePotionNoClip()
    _G._AutoBuyCoroutine = nil
end

function _G.FindToolServiceRF()
    if _G.AutoDrinkToolRF then return _G.AutoDrinkToolRF end
    local ok, rf = pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local knit = rep:FindFirstChild("Shared") and rep.Shared:FindFirstChild("Packages") and rep.Shared.Packages:FindFirstChild("Knit")
        if knit and knit:FindFirstChild("Services") and knit.Services:FindFirstChild("ToolService") then
            local svc = knit.Services.ToolService
            local rfNode = svc:FindFirstChild("RF")
            if rfNode and rfNode:FindFirstChild("ToolActivated") then
                return rfNode.ToolActivated
            end
        end
        local ok2, maybe = pcall(function() return rep.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated end)
        if ok2 and maybe then return maybe end
        return nil
    end)
    if ok and rf then _G.AutoDrinkToolRF = rf; return rf end
    return nil
end

function _G.TryDrinkPotion(potionName)
    if not potionName then return false, "no-name" end
    local rf = _G.FindToolServiceRF()
    if not rf then return false, "no-ToolActivated-remote" end
    local ok, res = pcall(function()
        return rf:InvokeServer(potionName)
    end)
    return ok, res
end

local function _parseSlider(v, fallback)
    fallback = fallback or 0
    if type(v) == "number" then return v end
    if type(v) == "table" then
        if v.Value and type(v.Value) == "number" then return v.Value end
        if v.Default and type(v.Default) == "number" then return v.Default end
    end
    return fallback
end

function _G.StartAutoDrinkLoop()
    if _G._AutoDrinkCoroutine then return end
    _G.AutoDrinkPotionsEnabled = true
    _G.AutoDrinkCancel = false
    _G._AutoDrinkCoroutine = task.spawn(function()
        while _G.AutoDrinkPotionsEnabled and not _G.AutoDrinkCancel do
            local hum = (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character) and (game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
            if type(_G.AutoDrinkSelectedPotions) == "table" and #_G.AutoDrinkSelectedPotions > 0 then
                for _, pot in ipairs(_G.AutoDrinkSelectedPotions) do
                    if _G.AutoDrinkCancel or not _G.AutoDrinkPotionsEnabled then break end
                    local name = tostring(pot)
                    local ok, res = _G.TryDrinkPotion(name)
                    task.wait(math.max(0.05, tonumber(_G.AutoDrinkDelay) or 0.8))
                end
            else
                task.wait(0.25)
            end
        end
        _G._AutoDrinkCoroutine = nil
        _G.AutoDrinkCancel = false
        _G.AutoDrinkPotionsEnabled = false
    end)
end

function _G.StopAutoDrinkLoop()
    _G.AutoDrinkCancel = true
    _G.AutoDrinkPotionsEnabled = false
    _G._AutoDrinkCoroutine = nil
end

_G._AutoDrinkHealthCoroutine = nil

function _G.StartAutoDrinkHealthLoop()
    if _G._AutoDrinkHealthCoroutine then return end
    _G._AutoDrinkHealthCoroutine = task.spawn(function()
        while _G.AutoDrinkHealthEnabled do
            local plr = game:GetService("Players").LocalPlayer
            local char = plr and plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hum and hum.Health > 0 then
                local pct = (hum.Health / hum.MaxHealth) * 100
                if pct <= (_G.AutoDrinkHealthThreshold or 45) then
                    _G.TryDrinkPotion("HealthPotion1")
_G.TryDrinkPotion("HealthPotion2")
                    task.wait(math.max(0.15, _G.AutoDrinkDelay or 0.8))
            end
            end

            task.wait(0.15)
        end
        _G._AutoDrinkHealthCoroutine = nil
    end)
end

function _G.StopAutoDrinkHealthLoop()
    _G.AutoDrinkHealthEnabled = false
end

local BuyTab = Window:Tab({
    Title = "Potions",
    Icon = "hand-coins"
})

local Section = BuyTab:Section({
    Title = "Potions",
    Icon = "milk"
})

local function BuildPotionDropdownValues()
    local out = {}
    for _, name in ipairs(_G.POTION_OPTIONS or {}) do table.insert(out, { Title = name }) end
    return out
end

BuyTab:Dropdown({
    Title = "Potion",
    Desc = "Select potion to buy",
    Values = BuildPotionDropdownValues(),
    Value = { Title = _G.PotionToBuy },
    Multi = true,
    Callback = function(opt)
        if type(opt) == "table" and opt[1] then
            _G.PotionToBuy = {}
            for _, v in ipairs(opt) do
                table.insert(_G.PotionToBuy, v.Title)
            end
                    else
            _G.PotionToBuy = { tostring(opt.Title or opt) }
                    end
    end
})

BuyTab:Input({
    Title = "How much to buy",
    Desc = "Number of potions to buy",
    Value = tostring(_G.PotionBuyAmount),
    Type = "Input",
    Placeholder = "3",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then _G.PotionBuyAmount = math.floor(n) else _G.PotionBuyAmount = 1 end
            end
})

BuyTab:Toggle({
    Title = "Enable Auto Buy Potions",
    Desc = "A Witch!!!",
    Value = false,
    Callback = function(v)
        if v then
            _G.StartAutoBuyPotions()
        else
            _G.StopAutoBuyPotions()
        end
    end
})

BuyTab:Slider({
    Title = "Buy Delay",
    Desc = "Delay between purchase attempts when buying",
    Value = { Min = 0.05, Max = 3.0, Default = _G.PotionBuyDelay },
    Step = 0.05,
    Callback = function(v)
        _G.PotionBuyDelay = tonumber((type(v) == "table" and v.Default) or v) or _G.PotionBuyDelay
            end
})

BuyTab:Slider({
    Title = "Tween speed",
    Desc = "Recommend to set it to 2!",
    Value = { Min = 0.08, Max = 3.5, Default = _G.PotionTweenTime },
    Step = 0.02,
    Callback = function(v)
        _G.PotionTweenTime = tonumber((type(v) == "table" and v.Default) or v) or _G.PotionTweenTime
        _G.CancelAutoBuyTween()
            end
})

BuyTab:Toggle({
    Title = "NoClip",
    Desc = "Disable collisions while auto buying (recommended)",
    Value = _G.PotionNoClipDuringTween,
    Callback = function(v) _G.PotionNoClipDuringTween = v;  end
})

BuyTab:Divider()

BuyTab:Dropdown({
    Title = "Auto-Drink Potions (multi)",
    Desc = "Potions that the auto-drink loop will attempt to use (order matters).",
    Values = BuildPotionDropdownValues(),
    Value = {},
    Multi = true,
    Callback = function(option)
        if type(option) == "table" then
            local sels = {}
            if #option > 0 then
                for _, v in ipairs(option) do
                    if type(v) == "table" and v.Title then table.insert(sels, v.Title) end
                end
            elseif option.Title then
                table.insert(sels, option.Title)
            end
            _G.AutoDrinkSelectedPotions = sels
        else
            _G.AutoDrinkSelectedPotions = { tostring(option) }
        end
            end
})

BuyTab:Toggle({
    Title = "Auto Drink Potions",
    Desc = "Enable/Disable auto drinking of selected potions.",
    Value = false,
    Callback = function(v)
        if v then _G.StartAutoDrinkLoop() else _G.StopAutoDrinkLoop() end
    end
})

BuyTab:Divider()

BuyTab:Toggle({
    Title = "Auto Drink Health Potions",
    Desc = "When enabled, automatically drinks HealthPotion1 if health% is below threshold.",
    Value = _G.AutoDrinkHealthEnabled or false,
    Callback = function(v)
        _G.AutoDrinkHealthEnabled = v
        if v then
            _G.StartAutoDrinkHealthLoop()
        end
    end
})

BuyTab:Slider({
    Title = "Health % Threshold (auto drink)",
    Desc = "Auto  heal when below this slider",
    Value = { Min = 1, Max = 90, Default = _G.AutoDrinkHealthThreshold or 45 },
    Step = 1,
    Callback = function(v)
        local val = _parseSlider(v, _G.AutoDrinkHealthThreshold or 45)
        _G.AutoDrinkHealthThreshold = math.clamp(tonumber(val) or 45, 1, 95)
    end
})

BuyTab:Slider({
    Title = "Auto-Drink Delay (s)",
    Desc = "Delay between drink attempts (per potion).",
    Value = { Min = 0.05, Max = 3.0, Default = _G.AutoDrinkDelay },
    Step = 0.05,
    Callback = function(v)
        _G.AutoDrinkDelay = tonumber((type(v) == "table" and v.Default) or v) or _G.AutoDrinkDelay
            end
})

_G.EnableAutoDrink = function() _G.StartAutoDrinkLoop(); _G.AutoDrinkPotionsEnabled = true end
_G.DisableAutoDrink = function() _G.StopAutoDrinkLoop() end

_G.AutoBuyPotionsQuickStart = function(potionName, amount, tweenTime, buyDelay)
    _G.PotionToBuy = potionName or _G.PotionToBuy
    _G.PotionBuyAmount = amount or _G.PotionBuyAmount
    _G.PotionTweenTime = tweenTime or _G.PotionTweenTime
    _G.PotionBuyDelay = buyDelay or _G.PotionBuyDelay
    _G.StartAutoBuyPotions()
end

pcall(function() _G.ForcePotionWorldRefresh() end)

local PickTab = Window:Tab({
    Title = "Pickaxe",
    Icon = "pickaxe"
})

Section = PickTab:Section({
    Title = "Pickaxe",
    Icon = "pickaxe"
})

_G.Players = _G.Players or game:GetService("Players")

local TweenService = game:GetService("TweenService") 
local ReplicatedStorage = _G.ReplicatedStorage or game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function shallowCopyArray(src)
    local out = {}
    if not src then return out end
    for i = 1, #src do out[i] = src[i] end
    return out
end

local function findPurchaseRemote()
    if _G.PurchaseRemote then return _G.PurchaseRemote end
    local ok, r = pcall(function()
        return ReplicatedStorage.Shared.Packages.Knit.Services.ProximityService.RF.Purchase
    end)
    if ok and r then _G.PurchaseRemote = r; return r end
    return nil
end

_G.PickaxeToBuy = _G.PickaxeToBuy or "Bronze Pickaxe"
_G.PickaxeTweenTime = _G.PickaxeTweenTime or 0.9     
_G.PickaxeBuyDelay = _G.PickaxeBuyDelay or 0.5       
_G.PickaxeNoClipDuringMove = (_G.PickaxeNoClipDuringMove == nil) and true or _G.PickaxeNoClipDuringMove
_G.PickaxeAutoBuyEnabled = false                     
_G.PickaxeMaxSpeed = _G.PickaxeMaxSpeed or 40        

_G._PickaxeLoopThread = nil
_G._PickaxeStopFlag = false
_G._PickaxeNoClipCache = {}

_G.PickaxesToBuy = _G.PickaxesToBuy or { _G.PickaxeToBuy }
_G.PickaxeBuyPositions = _G.PickaxeBuyPositions or {}

local DEFAULT_A = Vector3.new(-77.69940185546875, 28.74167823791504, 82.46420288085938)
local DEFAULT_B = Vector3.new(-101.85641479492188, 29.606250762939453, 104.2210693359375)
local ARCANE_POS = Vector3.new(232.31741333007812, -6.772843360900879, -339.8232421875)
local STONEWAKE_POS = Vector3.new(-33.792579650878906, -0.10066017508506775, -270.7460021972656)

local PICKAXE_WORLD2_LIST = {
    "Cobalt Pickaxe",
    "Lightite Pickaxe",
    "Titanium Pickaxe",
    "Uranium Pickaxe",
    "Mythril Pickaxe",
}

local PICKAXE_WORLD2_POSITIONS = {
    Vector3.new(-136.75, 23.01, -102.17),
    Vector3.new(-141.00, 23.15, -111.37),
    Vector3.new(-171.42, 25.10, -110.11),
}

local PICKAXE_WORLD3_LIST = {
    "Tungsten Pickaxe",
    "Aqua Pickaxe",
    "Mist Pickaxe",
    "Snow Pickaxe",
    "Frost Pickaxe",
    "Void Pickaxe",
}

local PICKAXE_WORLD3_POSITIONS = {
    Vector3.new(184.40, 18.90, 38.37),
    Vector3.new(189.10, 19.26, 3.48),
}

local function enableNoClip()
    if _G._PickaxeNoClipCache and next(_G._PickaxeNoClipCache) then return end
    local char = _G.Players.LocalPlayer and _G.Players.LocalPlayer.Character
    if not char then return end
    _G._PickaxeNoClipCache = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            _G._PickaxeNoClipCache[p] = p.CanCollide
            p.CanCollide = false
        end
    end
end
local function disableNoClip()
    for part, orig in pairs(_G._PickaxeNoClipCache or {}) do
        if part and part.Parent then
            pcall(function() part.CanCollide = orig end)
        end
    end
    _G._PickaxeNoClipCache = {}
end

local function detectWorld()
    
    if type(_G.GetCurrentWorld) == "function" then
        local ok, w = pcall(_G.GetCurrentWorld)
        if ok and w then return w end
    end
    if type(getCurrentWorld) == "function" then
        local ok, w = pcall(getCurrentWorld)
        if ok and w then return w end
    end
    
    local w = workspace
    if w:FindFirstChild("Forgotten Kingdom", true) then
        return "World2"
    end
    
    if w:FindFirstChild("Island3BossArena", true) then
        return "World3"
    end
    if w:FindFirstChild("Stonewake's Cross", true) then
        return "World1"
    end
    return "Unknown"
end

local function UpdatePickaxeWorldConfig()
    local world = detectWorld()
    if world == "World2" then
        _G.PickaxesToBuy = shallowCopyArray(PICKAXE_WORLD2_LIST)
        _G.PickaxeBuyPositions = shallowCopyArray(PICKAXE_WORLD2_POSITIONS)

    elseif world == "World3" then
        
        _G.PickaxesToBuy = shallowCopyArray(PICKAXE_WORLD3_LIST)
        _G.PickaxeBuyPositions = shallowCopyArray(PICKAXE_WORLD3_POSITIONS)

    else
        
        _G.PickaxesToBuy = { tostring(_G.PickaxeToBuy or "Bronze Pickaxe") }
        _G.PickaxeBuyPositions = { DEFAULT_A, DEFAULT_B }
    end
    
    if _G.PotionVerbose or _G.AutoMineVerboseDebug then
                for i,name in ipairs(_G.PickaxesToBuy) do  end
        for i,pos in ipairs(_G.PickaxeBuyPositions) do  end
    end
end

pcall(UpdatePickaxeWorldConfig)

task.spawn(function()
    local last = nil
    while true do
        local ok, world = pcall(detectWorld)
        if not ok then world = nil end
        if world and world ~= last then
            pcall(UpdatePickaxeWorldConfig)
            last = world
        end
        task.wait(3)
    end
end)

local function moveToPosition(targetVec3, desiredDuration)
    local player = _G.Players.LocalPlayer
    if not player then return false, "no-player" end
    local char = player.Character
    if not char then return false, "no-char" end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not hrp then return false, "no-hrp" end

    
    desiredDuration = math.max(0.02, tonumber(desiredDuration) or _G.PickaxeTweenTime or 0.8)
    local startPos = hrp.Position
    local targetPos = targetVec3
    local totalDelta = targetPos - startPos
    local totalDist = totalDelta.Magnitude
    if totalDist <= 0.9 then
        
        pcall(function() hrp.CFrame = CFrame.new(targetPos) end)
        return true, "snap"
    end

    
    local maxSpeed = tonumber(_G.PickaxeMaxSpeed) or 40
    local neededSpeed = totalDist / desiredDuration
    if neededSpeed > maxSpeed then
        desiredDuration = totalDist / maxSpeed
    end

    local elapsed = 0
    local startCFrame = hrp.CFrame
    local startTime = tick()

    if _G.PickaxeNoClipDuringMove then enableNoClip() end

    local conn
    local ok = true
    conn = RunService.Heartbeat:Connect(function(dt)
        if _G._PickaxeStopFlag or not _G.PickaxeAutoBuyEnabled then
            ok = false
            return
        end
        elapsed = elapsed + dt
        local alpha = math.clamp(elapsed / desiredDuration, 0, 1)
        
        local newPos = startPos:Lerp(targetPos, alpha)
        
        local forward = (targetPos - startPos).Unit
        if forward.Magnitude == 0 then forward = Vector3.new(0,0,1) end
        local newCFrame = CFrame.new(newPos, newPos + forward)
        pcall(function() hrp.CFrame = newCFrame end)
        if alpha >= 1 then
            
            ok = ok and true
            
            pcall(function() conn:Disconnect() end)
        end
    end)

    
    local waited = 0
    while waited < (desiredDuration + 0.5) do
        if not _G.PickaxeAutoBuyEnabled or _G._PickaxeStopFlag then
            if conn and conn.Connected then pcall(function() conn:Disconnect() end) end
            disableNoClip()
            return false, "cancelled"
        end
        
        if (hrp.Position - targetPos).Magnitude <= 1.0 then
            break
        end
        task.wait(0.02)
        waited = waited + 0.02
    end

    if conn and conn.Connected then pcall(function() conn:Disconnect() end) end
    if _G.PickaxeNoClipDuringMove then disableNoClip() end
    
    pcall(function() hrp.CFrame = CFrame.new(targetPos) end)
    return true, "arrived"
end

local function callPurchaseRemote(name)
    local remote = findPurchaseRemote()
    if not remote then
        warn("Pickaxe purchase remote not found")
        return false
    end
    local ok, res = pcall(function()
        return remote:InvokeServer(name, 1)
    end)
    return ok, res
end

_G.World2Pickaxes = {
    "Cobalt Pickaxe",
    "Lightite Pickaxe",
    "Titanium Pickaxe",
    "Uranium Pickaxe",
    "Mythril Pickaxe",
}

_G.World3Pickaxes = {
    "Tungsten Pickaxe",
    "Aqua Pickaxe",
    "Mist Pickaxe",
    "Snow Pickaxe",
    "Frost Pickaxe",
    "Void Pickaxe",
}

local function startPickaxeLoop()
    if _G._PickaxeLoopThread then return end
    _G._PickaxeStopFlag = false

    _G._PickaxeLoopThread = task.spawn(function()
        while _G.PickaxeAutoBuyEnabled and not _G._PickaxeStopFlag do
            local selected = tostring(_G.PickaxeToBuy or "Bronze Pickaxe")
            local world = (type(detectWorld) == "function" and detectWorld()) or "Unknown"

            
            
            
            if world == "World2" then
                
                local positions = (_G.PickaxeBuyPositions and #_G.PickaxeBuyPositions > 0) and _G.PickaxeBuyPositions or (PICKAXE_WORLD2_POSITIONS or {})

                
                local allowed = false
                local worldList = _G.World2Pickaxes or PICKAXE_WORLD2_LIST or {}
                for _, p in ipairs(worldList) do
                    if p == selected then allowed = true; break end
                end

                if not allowed then
                                        task.wait(0.6)
                else
                    for _, pos in ipairs(positions) do
                        if _G._PickaxeStopFlag or not _G.PickaxeAutoBuyEnabled then break end
                        local ok = moveToPosition(pos, _G.PickaxeTweenTime)
                        if ok then
                            
                            pcall(callPurchaseRemote, selected)
                            task.wait(0.12)
                        end
                        task.wait(_G.PickaxeBuyDelay or 0.5)
                    end
                end

            elseif world == "World3" then
                
                local positions = (_G.PickaxeBuyPositions and #_G.PickaxeBuyPositions > 0) and _G.PickaxeBuyPositions or (PICKAXE_WORLD3_POSITIONS or {})

                
                local allowed = false
                local worldList = _G.World3Pickaxes or PICKAXE_WORLD3_LIST or {}
                for _, p in ipairs(worldList) do
                    if p == selected then allowed = true; break end
                end

                if not allowed then
                                        task.wait(0.6)
                else
                    for _, pos in ipairs(positions) do
                        if _G._PickaxeStopFlag or not _G.PickaxeAutoBuyEnabled then break end
                        local ok = moveToPosition(pos, _G.PickaxeTweenTime)
                        if ok then
                            pcall(callPurchaseRemote, selected)
                            task.wait(0.12)
                        end
                        task.wait(_G.PickaxeBuyDelay or 0.5)
                    end
                end

            else
                
                local lower = selected:lower()

                if lower:find("arcane") then
                    local ok = moveToPosition(ARCANE_POS, _G.PickaxeTweenTime)
                    if ok then
                        pcall(callPurchaseRemote, selected)
                    end
                    task.wait(_G.PickaxeBuyDelay)

                elseif lower:find("stonewake") then
                    local ok = moveToPosition(STONEWAKE_POS, _G.PickaxeTweenTime)
                    if ok then
                        pcall(callPurchaseRemote, selected)
                    end
                    task.wait(_G.PickaxeBuyDelay)

                else
                    
                    local okA = moveToPosition(DEFAULT_A, _G.PickaxeTweenTime)
                    if okA then
                        pcall(callPurchaseRemote, selected)
                    end

                    task.wait(_G.PickaxeBuyDelay)
                    if not _G.PickaxeAutoBuyEnabled or _G._PickaxeStopFlag then break end

                    local okB = moveToPosition(DEFAULT_B, _G.PickaxeTweenTime)
                    if okB then
                        pcall(callPurchaseRemote, selected)
                    end

                    task.wait(_G.PickaxeBuyDelay)
                end
            end

            task.wait(0.12)
        end

        _G._PickaxeLoopThread = nil
        _G._PickaxeStopFlag = false
    end)
end

local function stopPickaxeLoop()
    _G._PickaxeStopFlag = true
    _G.PickaxeAutoBuyEnabled = false
    if _G._PickaxeLoopThread then
        
    end
end

if PickTab then
    
    
local function BuildPickaxeDropdownValues()
    local out = {}

    
    local world = "Unknown"
    if type(detectWorld) == "function" then
        local ok, w = pcall(detectWorld)
        if ok and w then world = w end
    elseif type(getCurrentWorld) == "function" then
        local ok, w = pcall(getCurrentWorld)
        if ok and w then world = w end
    end

    if world == "World2" then
        
        local source = _G.World2Pickaxes or PICKAXE_WORLD2_LIST or {
            "Cobalt Pickaxe",
            "Lightite Pickaxe",
            "Titanium Pickaxe",
            "Uranium Pickaxe",
            "Mythril Pickaxe",
        }
        for _, name in ipairs(source) do table.insert(out, { Title = name }) end

    elseif world == "World3" then
        
        local source = _G.World3Pickaxes or PICKAXE_WORLD3_LIST or {
            "Tungsten Pickaxe",
            "Aqua Pickaxe",
            "Mist Pickaxe",
            "Snow Pickaxe",
            "Frost Pickaxe",
            "Void Pickaxe",
        }
        for _, name in ipairs(source) do table.insert(out, { Title = name }) end

    else
        
        local source = {
            "Bronze Pickaxe",
            "Iron Pickaxe",
            "Gold Pickaxe",
            "Platinum Pickaxe",
            "Arcane Pickaxe",
            "Stonewake's Pickaxe",
            
        }
        for _, name in ipairs(source) do table.insert(out, { Title = name }) end
    end

    return out
end

    PickTab:Dropdown({
    Title = "Pickaxe",
    Desc = "Choose which pickaxe to auto buy",
    Values = BuildPickaxeDropdownValues(),
    Value = { Title = _G.PickaxeToBuy },
    Callback = function(opt)
        local chosen = nil
        if type(opt) == "table" and opt.Title then
            chosen = opt.Title
        else
            chosen = tostring(opt)
        end
        _G.PickaxeToBuy = chosen
                
        _G.PickaxesToBuy = { _G.PickaxeToBuy }
    end
})

    PickTab:Toggle({
        Title = "Auto Buy Pickaxe",
        Desc = "MINECRAFTTTTT!!!!",
        Value = _G.PickaxeAutoBuyEnabled,
        Callback = function(v)
            _G.PickaxeAutoBuyEnabled = v
            if v then
                startPickaxeLoop()
            else
                stopPickaxeLoop()
            end
                    end
    })

    PickTab:Divider()

    PickTab:Slider({
        Title = "Tween Speed",
        Desc = "How fast to move (higher = slower)",
        Value = { Min = 0.08, Max = 4.0, Default = _G.PickaxeTweenTime },
        Step = 0.02,
        Callback = function(v)
            local val = (type(v) == "table" and v.Default) or v
            _G.PickaxeTweenTime = tonumber(val) or _G.PickaxeTweenTime
                    end
    })

    PickTab:Slider({
        Title = "Pickaxe Buy Delay ",
        Desc = "Wait after moving",
        Value = { Min = 0.05, Max = 3.0, Default = _G.PickaxeBuyDelay },
        Step = 0.02,
        Callback = function(v)
            local val = (type(v) == "table" and v.Default) or v
            _G.PickaxeBuyDelay = tonumber(val) or _G.PickaxeBuyDelay
                    end
    })

    PickTab:Toggle({
        Title = "NoClip During Move",
        Desc = "Recommended!",
        Value = _G.PickaxeNoClipDuringMove,
        Callback = function(v)
            _G.PickaxeNoClipDuringMove = v
                    end
    })
end

_G.RaceTab = Window:Tab({
    Title = "Races",
    Icon = "list-check"
})
_G.Section = _G.RaceTab:Section({
    Title = "Reroll race",
    Icon = "refresh-ccw"
})

if _G.__AUTO_REROLL_LOADED then
    return
end
_G.__AUTO_REROLL_LOADED = true

_G.Players = game:GetService("Players")
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.RunService = game:GetService("RunService")

_G.RACE_OPTIONS = {
    "Archangel",
    "Angel",
    "Demon",
    "Developer",
    "Dragonborn",
    "Elf",
    "Goblin",
    "Golem",
    "Minotaur",
    "Orc",
    "Orc Lord",
    "Shadow",
    "Undead",
    "Zombie",
    "Human",
    "Dwarf"
}

_G.RerollTargets = _G.RerollTargets or { "Angel" }
_G.RerollDelay = tonumber(_G.RerollDelay) or 0.6
_G.RerollDetectTimeout = tonumber(_G.RerollDetectTimeout) or 3.0
_G.RerollMaxAttempts = tonumber(_G.RerollMaxAttempts) or 0
_G.RerollNotifyOnSuccess = (_G.RerollNotifyOnSuccess == nil) and true or _G.RerollNotifyOnSuccess
_G.RerollAutoStart = _G.RerollAutoStart or false

_G.AutoRerollRaceEnabled = _G.AutoRerollRaceEnabled or false
_G._RerollStatus = _G._RerollStatus or "Idle"
_G._RerollAttemptCount = _G._RerollAttemptCount or 0
_G._RerollLastResult = _G._RerollLastResult or "n/a"
_G._RerollLastTime = _G._RerollLastTime or 0

_G.__AUTO_REROLL_HANDLES = _G.__AUTO_REROLL_HANDLES or {}
_G.handles = _G.__AUTO_REROLL_HANDLES

_G.StatsParagraph = _G.StatsParagraph or nil
_G.RarityParagraph = _G.RarityParagraph or nil

function findRerollRemote()
    if _G.RaceRerollRemote then return _G.RaceRerollRemote end
    local ok, rf = pcall(function()
        return _G.ReplicatedStorage.Shared.Packages.Knit.Services.RaceService.RF.Reroll
    end)
    if ok and rf then
        _G.RaceRerollRemote = rf
        return rf
    end
    
    pcall(function()
        local shared = _G.ReplicatedStorage:FindFirstChild("Shared")
        if not shared then return end
        local pkgs = shared:FindFirstChild("Packages")
        if not pkgs then return end
        local knit = pkgs:FindFirstChild("Knit")
        if not knit then return end
        local services = knit:FindFirstChild("Services")
        if not services then return end
        local raceSrv = services:FindFirstChild("RaceService")
        if not raceSrv then return end
        local rf = raceSrv:FindFirstChild("RF")
        if not rf then return end
        local reroll = rf:FindFirstChild("Reroll")
        if reroll then _G.RaceRerollRemote = reroll end
    end)
    return _G.RaceRerollRemote
end

function getPlayerRaceFolder()
    local plr = _G.Players.LocalPlayer
    if not plr then return nil end
    local living = workspace:FindFirstChild("Living")
    if not living then return nil end
    local charNode = living:FindFirstChild(plr.Name)
    if not charNode then
        for _, v in ipairs(living:GetChildren()) do
            if v.Name == plr.Name then charNode = v; break end
        end
    end
    if not charNode then return nil end
    local rf = charNode:FindFirstChild("RaceFolder") or charNode:FindFirstChild("Race")
    return rf
end

function getCurrentRace()
    local rf = getPlayerRaceFolder()
    if not rf then return nil end
    for _, child in ipairs(rf:GetChildren()) do
        if child:IsA("StringValue") or child:IsA("ObjectValue") or child:IsA("ValueBase") then
            if child.Value and tostring(child.Value) ~= "" then return tostring(child.Value) end
        else
            if child.Name and child.Name ~= "" then return child.Name end
        end
    end
    return nil
end

function isDesiredRace(current)
    if not current then return false end
    local curLower = tostring(current):lower()
    for _, t in ipairs(_G.RerollTargets or {}) do
        if type(t) == "string" and curLower == tostring(t):lower() then
            return true
        end
    end
    return false
end

function updateStatsParagraph()
    if not _G.StatsParagraph then return end
    local cur = getCurrentRace() or "Unknown"
    local targets = (_G.RerollTargets and #_G.RerollTargets > 0) and table.concat(_G.RerollTargets, ", ") or "None"
    local desc = ("Current Race: %s\nDesired: %s\nAttempts: %d\nStatus: %s\nLast Result: %s\nLast Time: %s"):
        format(cur, targets, (_G._RerollAttemptCount or 0), (_G._RerollStatus or "Idle"), tostring(_G._RerollLastResult or "n/a"), (_G._RerollLastTime==0 and "n/a" or os.date("%X", _G._RerollLastTime)))
    pcall(function() _G.StatsParagraph:SetDesc(desc) end)
end

function attemptRerollOnce()
    local remote = findRerollRemote()
    if not remote then
        _G._RerollStatus = "No remote"
        return false, "no-remote"
    end

    local ok, res = pcall(function() return remote:InvokeServer() end)
    if ok then
        _G._RerollLastResult = "Invoked"
        _G._RerollLastTime = os.time()
        return true, res
    else
        _G._RerollLastResult = ("Error: %s"):format(tostring(res))
        _G._RerollLastTime = os.time()
        return false, res
    end
end

function waitForRaceChange(timeout)
    local deadline = tick() + (timeout or _G.RerollDetectTimeout or 3)
    local initial = getCurrentRace()
    while tick() < deadline do
        if _G.handles._RerollStop then return nil, "stopped" end
        local cur = getCurrentRace()
        if cur and cur ~= initial then
            return cur, "changed"
        end
        task.wait(0.12)
    end
    return nil, "timeout"
end

_G.handles._RerollThread = _G.handles._RerollThread or nil
_G.handles._StatsUpdater = _G.handles._StatsUpdater or nil
_G.handles._RerollStop = false

function startRerollLoop()
    if _G.handles._RerollThread then return end
    _G.handles._RerollStop = false
    _G._RerollAttemptCount = 0
    _G._RerollStatus = "Running"
    updateStatsParagraph()

    if WindUI and _G.RerollNotifyOnSuccess then
        pcall(function() WindUI:Notify({ Title = "Reroll", Content = "Started rerolling for "..table.concat(_G.RerollTargets, ", "), Duration = 3, Icon = "refresh-ccw" }) end)
    end

    _G.handles._RerollThread = task.spawn(function()
        while not _G.handles._RerollStop do
            if (_G.RerollMaxAttempts or 0) > 0 and (_G._RerollAttemptCount or 0) >= (_G.RerollMaxAttempts or 0) then
                _G._RerollStatus = "Max attempts reached"
                break
            end

            _G._RerollAttemptCount = (_G._RerollAttemptCount or 0) + 1
            _G._RerollStatus = "Invoking"
            updateStatsParagraph()
            local ok, res = attemptRerollOnce()

            _G._RerollStatus = "Waiting for result"
            updateStatsParagraph()
            local newRace, why = waitForRaceChange(_G.RerollDetectTimeout)
            if newRace then
                _G._RerollLastResult = "Got "..tostring(newRace)
                _G._RerollLastTime = os.time()
                _G._RerollStatus = "Got "..tostring(newRace)
                updateStatsParagraph()

                if isDesiredRace(newRace) then
                    
                    if WindUI and _G.RerollNotifyOnSuccess then
                        pcall(function() WindUI:Notify({ Title = "Success", Content = "Acquired "..tostring(newRace).." after "..tostring(_G._RerollAttemptCount).." rerolls", Duration = 4, Icon = "star" }) end)
                    end
                    _G.handles._RerollStop = true
                    _G.AutoRerollRaceEnabled = false
                    break
                else
                    _G._RerollStatus = "Not desired: "..tostring(newRace)
                    updateStatsParagraph()
                end
            else
                _G._RerollStatus = "No change ("..tostring(why)..")"
                updateStatsParagraph()
            end

            local delay = tonumber(_G.RerollDelay) or 0.6
            for i = 1, math.max(1, math.floor((delay / 0.12))) do
                if _G.handles._RerollStop then break end
                task.wait(0.12)
            end
        end

        _G._RerollStatus = "Stopped"
        updateStatsParagraph()
        _G.handles._RerollThread = nil
        _G.handles._RerollStop = false
    end)
end

function stopRerollLoop()
    _G.handles._RerollStop = true
    _G._RerollStatus = "Stopping"
    updateStatsParagraph()
end

if _G.RaceTab then
    
    if not _G._RaceUIBuilt then
        
        _G.StatsParagraph = _G.RaceTab:Paragraph({ Title = "Reroll Statistics", Desc = "Idle" })
        _G.RarityParagraph = _G.RaceTab:Paragraph({
            Title = "Race Rarities",
            Desc =
    "Human – 25%\n" ..
    "Elf – 15%\n" ..
    "Zombie – 14%\n" ..
    "Goblin – 10.5%\n" ..
    "Undead – 9%\n" ..
    "Orc – 8%\n" ..
    "Dwarf – 7%\n" ..
    "Shadow – 6%\n" ..
    "Minotaur – 1.75%\n" ..
    "Dragonborn – 1.5%\n" ..
    "Golem – 1.25%\n" ..
    "Angel – 0.5%\n" ..
    "Demon – 0.5%\n" ..
    "Archangel – 0.1%"
})
        
        function onDropdownChanged(opt)
            local sels = {}
            if type(opt) == "table" then
                if #opt > 0 then
                    for _, v in ipairs(opt) do if type(v) == "table" and v.Title then table.insert(sels, v.Title) end end
                elseif opt.Title then
                    table.insert(sels, opt.Title)
                end
            elseif type(opt) == "string" then
                table.insert(sels, opt)
            end
            _G.RerollTargets = sels
            updateStatsParagraph()
        end

        function onToggleAutoReroll(state)
            if state then
                if not _G.RerollTargets or #_G.RerollTargets == 0 then
                    _G.RerollTargets = { _G.RACE_OPTIONS[1] }
                end
                local cur = getCurrentRace()
                if cur and isDesiredRace(cur) then
                    if WindUI then
                        pcall(function() WindUI:Notify({ Title = "Reroll", Content = "You already have "..tostring(cur)..". Reroll not started.", Duration = 3, Icon = "info" }) end)
                    end
                    _G.AutoRerollRaceEnabled = false
                    updateStatsParagraph()
                    return
                end
                _G.AutoRerollRaceEnabled = true
                startRerollLoop()
            else
                _G.AutoRerollRaceEnabled = false
                stopRerollLoop()
            end
            updateStatsParagraph()
        end

        function onDelayChanged(v)
            _G.RerollDelay = tonumber((type(v)=="table" and v.Default) or v) or _G.RerollDelay
        end

        function onDetectTimeoutChanged(v)
            _G.RerollDetectTimeout = tonumber((type(v)=="table" and v.Default) or v) or _G.RerollDetectTimeout
        end

        function onMaxAttemptsChanged(v)
            _G.RerollMaxAttempts = tonumber((type(v)=="table" and v.Default) or v) or _G.RerollMaxAttempts
        end

        function onNotifyToggle(v)
            _G.RerollNotifyOnSuccess = v
        end

        
        _G.RaceTab:Dropdown({
            Title = "Pick Desired Race(s)",
            Desc = "choose race.",
            Values = (function()
                local out = {}
                for _, r in ipairs(_G.RACE_OPTIONS) do table.insert(out, { Title = r }) end
                return out
            end)(),
            Value = {},
            Multi = true,
            Callback = onDropdownChanged
        })

        _G.RaceTab:Toggle({
            Title = "Auto Reroll Race",
            Desc = "pls pls angel or demon :((",
            Value = _G.AutoRerollRaceEnabled or false,
            Callback = onToggleAutoReroll
        })

        _G.RaceTab:Slider({
            Title = "Reroll Delay",
            Desc = "Delay between reroll attempts",
            Value = { Min = 0.2, Max = 3.5, Default = _G.RerollDelay },
            Step = 0.05,
            Callback = onDelayChanged
        })

        _G.RaceTab:Slider({
            Title = "Detect Timeout (s)",
            Desc = "how long timeout",
            Value = { Min = 0.2, Max = 6.0, Default = _G.RerollDetectTimeout },
            Step = 0.05,
            Callback = onDetectTimeoutChanged
        })

        _G.RaceTab:Slider({
            Title = "Max Attempts (0 = unlimited)",
            Desc = "Maximum number of rerolls before stopping automatically (0 = unlimited).",
            Value = { Min = 0, Max = 500, Default = _G.RerollMaxAttempts },
            Step = 1,
            Callback = onMaxAttemptsChanged
        })

        _G.RaceTab:Toggle({
            Title = "Notify On Success",
            Desc = "notify when u get the race u want.",
            Value = _G.RerollNotifyOnSuccess,
            Callback = onNotifyToggle
        })

        _G.RaceTab:Divider()

        _G._RaceUIBuilt = true
    else
        
    end
end

if _G.RerollAutoStart then
    if not _G.RerollTargets or #_G.RerollTargets==0 then _G.RerollTargets = {_G.RACE_OPTIONS[1]} end
    startRerollLoop()
end

if _G.handles._StatsUpdater then
    
    pcall(function() task.cancel(_G.handles._StatsUpdater) end)
    _G.handles._StatsUpdater = nil
end

_G.handles._StatsUpdater = task.spawn(function()
    while true do
        updateStatsParagraph()
        task.wait(0.8)
    end
end)
                   

local S = S or {}
S._moveId = 0
S.services = {
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players"),
}
S.TP_SPEED = S.TP_SPEED or 70

local NPCS = {
    "Aida","Amber","AttackDamagePotion1","Azuk","Barakkulf","Captain Rowan",
    "Cobalt Pickaxe","Demonic Pickaxe","DemoniteCaveDoor","Enhancer","Farmer",
    "Fisher","Goblin King","GoblinCaveDoor","GoblinCaveKey","Greedy Cey",
    "Gurak","HealthPotion2","Henry","Isaac","Lightite Pickaxe","Line",
    "LuckPotion1","Magma Pickaxe","Malik","Marbles","Maria","Masked Stranger",
    "Miner Fred","MinerPotion1","Monke","MovementSpeedPotion1","Mythril Pickaxe",
    "Rhateus","Runemaker","Sensei Moro 2","SimpleLantern","Skal","Titanium Pickaxe",
    "TomoCat","Uranium Pickaxe","Walter","Wizard","Forge",
}
local STRUCTURES = {
    "Enhancer Shop","Forge Station","Gem Buyer","Pick Axe Seller","Potion Shop",
    "Quest Board","Runemaker Shop","Weapon Seller Shop","Wizard Tower",
}

S._activeMoveConn = nil
S._activeMoveCancel = false

if not S.Notify then
    S.Notify = function(title, body, dur)
        dur = dur or 2
        local ok = false
        pcall(function()
            if type(WindUI) == "table" and type(WindUI.Notify) == "function" then
                WindUI:Notify({ Title = title, Content = body, Duration = dur })
                ok = true
            end
        end)
        if not ok then
            warn(("%s: %s"):format(tostring(title), tostring(body)))
        end
    end
end

S.ResolveToPart = function(obj)
    if not obj or typeof(obj) ~= "Instance" then return nil end

    if obj:IsA("BasePart") then
        return obj
    end

    if obj:IsA("Model") then
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if hrp and typeof(hrp) == "Instance" and hrp:IsA("BasePart") then
            return hrp
        end
        if obj.PrimaryPart and typeof(obj.PrimaryPart) == "Instance" and obj.PrimaryPart:IsA("BasePart") then
            return obj.PrimaryPart
        end
    end

    for _, d in ipairs(obj:GetDescendants()) do
        if typeof(d) == "Instance" and d:IsA("BasePart") then
            return d
        end
    end

    return nil
end

S.GetHRP = function()
    local p = S.services.Players.LocalPlayer
    if not p then return nil end
    local c = p.Character
    if not c then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if hrp and typeof(hrp) == "Instance" and hrp:IsA("BasePart") then
        return hrp
    end
    if c.PrimaryPart and typeof(c.PrimaryPart) == "Instance" and c.PrimaryPart:IsA("BasePart") then
        return c.PrimaryPart
    end
    return nil
end

S.CancelActiveMove = function()
    if S._activeMoveConn then
        pcall(function() S._activeMoveConn:Disconnect() end)
        S._activeMoveConn = nil
        S._activeMoveCancel = true
    end
end

S.RunServiceMoveTo = function(HRP, targetCFrame, duration, onComplete)
    
    S._moveId = (S._moveId or 0) + 1
    local myMoveId = S._moveId

    
    if S._activeMoveConn then
        S._activeMoveConn:Disconnect()
        S._activeMoveConn = nil
    end

    if not HRP or not HRP.Parent then
        if onComplete then pcall(onComplete) end
        return
    end

    duration = math.max(duration or 0.1, 0.1)

    local startCF = HRP.CFrame
    local startTime = tick()

    S._activeMoveConn = S.services.RunService.Heartbeat:Connect(function()
        
        if myMoveId ~= S._moveId then
            if S._activeMoveConn then
                S._activeMoveConn:Disconnect()
                S._activeMoveConn = nil
            end
            return
        end

        if not HRP.Parent then
            if S._activeMoveConn then
                S._activeMoveConn:Disconnect()
                S._activeMoveConn = nil
            end
            return
        end

        local alpha = math.clamp((tick() - startTime) / duration, 0, 1)
        HRP.CFrame = startCF:Lerp(targetCFrame, alpha)

        if alpha >= 1 then
            HRP.CFrame = targetCFrame
            if S._activeMoveConn then
                S._activeMoveConn:Disconnect()
                S._activeMoveConn = nil
            end
            if onComplete then pcall(onComplete) end
        end
    end)
end

S.TeleportToPosition = function(position, label)
    if typeof(position) ~= "Vector3" then return end
    local hrp = S.GetHRP()
    if not hrp then
        S.Notify("TP Failed", "Character not ready")
        return
    end
    local dist = (hrp.Position - position).Magnitude
    local dur = math.max(dist / math.max(tonumber(S.TP_SPEED) or 70, 1), 0.02)
    S.Notify("Teleporting", "Going to " .. (label or "location"))
    local goalCF = CFrame.new(position + Vector3.new(0, 3, 0), position)
    S.RunServiceMoveTo(hrp, goalCF, dur, function() S.Notify("Arrived", label or "location") end)
end

local function TeleportToNPC(name)
    if not name then return end
    local model = workspace:FindFirstChild(name, true)

    if not model then
        S.Notify("Teleport Failed", name .. " does not exist might be in world 2")
        return
    end

    local part = S.ResolveToPart(model)
    if not part then
        S.Notify("Teleport Failed", name .. " has no valid part")
        return
    end

    local hrp = S.GetHRP()
    if not hrp then
        S.Notify("Teleport Failed", "Character not ready")
        return
    end

    local dist = (hrp.Position - part.Position).Magnitude
    local dur = math.max(dist / math.max(tonumber(S.TP_SPEED) or 70, 1), 0.02)
    S.Notify("Teleporting", "Going to " .. name)
    local goalCF = part.CFrame + Vector3.new(0, 3, 0)
    S.RunServiceMoveTo(hrp, goalCF, dur, function() S.Notify("Arrived", tostring(name)) end)
end

local function TeleportToStructure(name)
    if not name then return end
    local shops = workspace:FindFirstChild("Shops")
    local model = nil
    if shops then
        model = shops:FindFirstChild(name)
    end
    
    if not model then
        model = workspace:FindFirstChild(name, true)
    end

    if not model then
        S.Notify("Teleport Failed", name .. " does not exist might be in world 2")
        return
    end

    local part = S.ResolveToPart(model)
    if not part then
        S.Notify("Teleport Failed", name .. " has no valid part")
        return
    end

    local hrp = S.GetHRP()
    if not hrp then
        S.Notify("Teleport Failed", "Character not ready")
        return
    end

    local dist = (hrp.Position - part.Position).Magnitude
    local dur = math.max(dist / math.max(tonumber(S.TP_SPEED) or 70, 1), 0.02)
    S.Notify("Teleporting", "Going to " .. name)
    local goalCF = part.CFrame + Vector3.new(0, 3, 0)
    S.RunServiceMoveTo(hrp, goalCF, dur, function() S.Notify("Arrived", tostring(name)) end)
end

local TeleportTab = (type(Window) == "table" and Window.Tab)
    and Window:Tab({ Title = "Teleport", Icon = "circle" }) or nil

if TeleportTab then

    
    
    
    local StructureSection = TeleportTab:Section({ Title = "Structures" })
    for _, name in ipairs(STRUCTURES) do
        StructureSection:Button({
            Title = name,
            Desc = "Teleport to structure",
            Callback = function()
                TeleportToStructure(name)
            end
        })
    end

    
    
    
    local NPCSection = TeleportTab:Section({ Title = "NPCs" })
    for _, name in ipairs(NPCS) do
        NPCSection:Button({
            Title = name,
            Desc = "Teleport to NPC",
            Callback = function()
                TeleportToNPC(name)
            end
        })
    end

    
    
    
    local SettingsSection = TeleportTab:Section({ Title = "Teleport Settings" })
    SettingsSection:Slider({
        Title = "Tween Speed",
        Desc = "Studs/sec",
        Step = 1,
        Value = { Min = 20, Max = 120, Default = tonumber(S.TP_SPEED) or 70 },
        Callback = function(v)
            S.TP_SPEED = tonumber((type(v) == "table" and v.Default) or v) or S.TP_SPEED
        end
    })

    SettingsSection:Button({
        Title = "Cancel This Teleport",
        Desc = "cancel tp",
        Callback = function()
            S.CancelActiveMove()
            S.Notify("Teleport", "Active teleport cancelled (this helper).")
        end
    })

end

_G.MyTeleportHelper = S

CordTab = Window:Tab({
    Title = "Coordinates",
    Icon = "compass"
})

Players = game:GetService("Players")
StarterGui = game:GetService("StarterGui")
RunService = game:GetService("RunService")
HttpService = game:GetService("HttpService") 
TweenService = game:GetService("TweenService")

LocalPlayer = Players.LocalPlayer
SavedPositions = {}
SelectedPosition = nil
ShowCoordinates = false
CurrentCoordinates = Vector3.new(0,0,0) 

TWEEN_SPEED = 70 

WindUI = WindUI 

function Notify(title, text, duration)
    duration = duration or 3
    if WindUI and type(WindUI.Notify) == "function" then
        pcall(function()
            WindUI:Notify({
                Title = title,
                Content = text,
                Duration = duration,
                Icon = "rbxassetid://84501312005643",
            })
        end)
    else
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration
        })
    end
end

coordGui = nil
coordLabel = nil
coordConnection = nil

function ToggleCoordinates(enabled)
    if type(enabled) == "boolean" then
        ShowCoordinates = enabled
    else
        ShowCoordinates = not ShowCoordinates
    end

    if ShowCoordinates then  
        if not coordGui then  
            coordGui = Instance.new("ScreenGui")  
            coordGui.Name = "CoordsGUI"  
            coordGui.ResetOnSpawn = false  
            coordGui.Parent = game.CoreGui  

            coordLabel = Instance.new("TextLabel")  
            coordLabel.Size = UDim2.new(0, 220, 0, 36)  
            coordLabel.Position = UDim2.new(0, 10, 0, 10)  
            coordLabel.BackgroundTransparency = 0.4  
            coordLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  
            coordLabel.BorderSizePixel = 0  
            coordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  
            coordLabel.TextScaled = true  
            coordLabel.Font = Enum.Font.SourceSansSemibold  
            coordLabel.Text = "X: 0.0  Y: 0.0  Z: 0.0"  
            coordLabel.Parent = coordGui  
        end  

        if not coordConnection then  
            coordConnection = RunService.RenderStepped:Connect(function()  
                char = LocalPlayer.Character  
                root = char and char:FindFirstChild("HumanoidRootPart")  
                if root then  
                    p = root.Position  
                    CurrentCoordinates = p  
                    coordLabel.Text = string.format("X: %.2f  Y: %.2f  Z: %.2f", p.X, p.Y, p.Z)  
                    coordLabel.Visible = true  
                else  
                    coordLabel.Text = "No character"  
                end  
            end)  
        end  
    else  
        if coordConnection then  
            coordConnection:Disconnect()  
            coordConnection = nil  
        end  
        if coordGui then  
            coordGui:Destroy()  
            coordGui = nil  
            coordLabel = nil  
        end  
    end
end

function RefreshDropdownValues(dropdown)
    if not dropdown then return end
    keys = {}
    for k in pairs(SavedPositions) do table.insert(keys, k) end
    table.sort(keys)
    dropdown:Refresh(keys)
end

function SavePosition(name, dropdown)
    name = tostring(name or ""):gsub("^%s*(.-)%s*$", "%1")
    if name == "" then
        return Notify("Error", "Please enter a name for the coordinate!", 3)
    end

    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
    root = char and char:FindFirstChild("HumanoidRootPart")  
    if not root then  
        return Notify("Error", "HumanoidRootPart not found!", 3)  
    end  

    pos = root.Position  
    SavedPositions[name] = root.CFrame  
    Notify("Saved", string.format("'%s' saved at X: %.2f Y: %.2f Z: %.2f", name, pos.X, pos.Y, pos.Z), 3)  
    RefreshDropdownValues(dropdown)
end

function TweenToCFrame(targetCFrame, displayName)
    if not targetCFrame then
        Notify("TP Failed", "Invalid target CFrame.", 3)
        return
    end

    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        WindUI:Notify({
    Title = "Arrived",
    Content = "You have arrived at " .. tostring(displayName or "position"),
    Duration = 3
})
        return
    end

    
    currentPos = root.Position
    
    targetPos = targetCFrame.p or targetCFrame.Position or (targetCFrame:ToWorldSpace(CFrame.new()).p)
    distance = (currentPos - targetPos).Magnitude

    if TWEEN_SPEED == nil or TWEEN_SPEED <= 0 then TWEEN_SPEED = 1 end
    duration = distance / TWEEN_SPEED
    if duration < 0.02 then duration = 0.02 end

    tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    
    finalCFrame = targetCFrame * CFrame.new(0, 3, 0)
    tween = TweenService:Create(root, tweenInfo, {CFrame = finalCFrame})

    BIND_NAME = "TweenToCFrame_" .. tostring(math.random(1, 1000000))
    RunService:BindToRenderStep(BIND_NAME, Enum.RenderPriority.Character.Value, function() end)

    Notify("Teleporting", "Going to " .. tostring(displayName or "position") .. " (speed: " .. tostring(TWEEN_SPEED) .. ")", 2)

    tween.Completed:Connect(function()
        pcall(function() RunService:UnbindFromRenderStep(BIND_NAME) end)
        Notify("Arrived", "You have arrived at " .. tostring(displayName or "position"), 3)
    end)

    tween:Play()
end

function TeleportToSaved()
    if not SelectedPosition or not SavedPositions[SelectedPosition] then
        return Notify("Error", "Select a saved position first!", 3)
    end

    TweenToCFrame(SavedPositions[SelectedPosition], SelectedPosition)
end

function DeleteSaved(dropdown)
    if not SelectedPosition or not SavedPositions[SelectedPosition] then
        return Notify("Error", "Select a saved position first!", 3)
    end

    SavedPositions[SelectedPosition] = nil  
    Notify("Deleted", "Deleted coordinate '" .. SelectedPosition .. "'", 2)  
    SelectedPosition = nil  
    RefreshDropdownValues(dropdown)
end

function CopyCoordinates()
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        pos = root.Position
        coordText = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
        
        pcall(function() setclipboard(coordText) end)
        Notify("Copied", "Copied current coordinates to clipboard: " .. coordText, 3)
    else
        Notify("Error", "Couldn't find HumanoidRootPart.", 3)
    end
end

coordinateName = ""

CordTab:Toggle({
    Title = "Show Coordinates",
    Desc = "Display your current coordinates on screen",
    Default = false,
    Callback = function(val) ToggleCoordinates(val) end
})

CordTab:Space()

nameInput = CordTab:Input({
    Title = "Coordinate Name",
    Desc = "Enter a name to save your position",
    Value = "",
    InputIcon = "bird",
    Type = "Input",
    Placeholder = "Enter coordinate name...",
    Callback = function(input)
        coordinateName = tostring(input or "")
    end
})

CordTab:Button({
    Title = "Save Current Position",
    Desc = "Saves your current position with name",
    Callback = function()
        SavePosition(coordinateName, Dropdown)
    end
})

CordTab:Space()

TweenSpeedSlider = CordTab:Slider({
    Title = "Tween Speed",
    Desc = "set your tween speed (recommended to keep it slow)",
    Step = 1,
    Value = {
        Min = 10,
        Max = 300,
        Default = TWEEN_SPEED,
    },
    Callback = function(value)
        TWEEN_SPEED = value
    end
})

CordTab:Button({
    Title = "Copy Current Coordinates",
    Desc = "Copy your current coordinates",
    Callback = CopyCoordinates
})

CordTab:Space()

Dropdown = CordTab:Dropdown({
    Title = "Saved Positions",
    Desc = "Select a saved position",
    Values = {},
    Callback = function(selected)
        SelectedPosition = selected
    end
})

CordTab:Space()

CordTab:Button({
    Title = "Tween to Saved Position",
    Desc = "Tween to the selected saved position",
    Callback = TeleportToSaved
})

CordTab:Button({
    Title = "Delete Selected Position",
    Desc = "Deletes the selected saved position",
    Callback = function()
        DeleteSaved(Dropdown)
    end
})

Window:Divider()

MiscTab = Window:Tab({
 Title = "Misc",
 Icon = "cog"
})

MiscTab:Dropdown(
    {
        Title = "Select Theme",
        Values = themeNames,
        Value = "RyZenHub",
        Callback = function(selectedTheme)
            WindUI:SetTheme(selectedTheme)
        end
    }
)

MiscTab:Toggle(
    {
        Title = "Transparent Window",
        Desc = "Toggle UI transparency on or off",
        Default = false, 
        Callback = function(state)
            if state then
                Window:ToggleTransparency(true)
            else
                Window:ToggleTransparency(false)
            end
        end
    }
)

MiscTab:Divider()

MiscTab:Button({
    Title = "Check Current World",
    Desc = "Shows which world you're in",
    Locked = false,
    Callback = function()
        local world = getCurrentWorld()

        if world == "World2" then
            notify({
                Title = "World Check",
                Content = "You are in Forgotten Kingdom (World 2)",
                Duration = 3
            })

        elseif world == "World3" then
            notify({
                Title = "World Check",
                Content = "You are in Frostspire Expanse (World 3)",
                Duration = 3
            })

        elseif world == "World1" then
            notify({
                Title = "World Check",
                Content = "You are in Stonewake's Cross (Main World)",
                Duration = 3
            })

        else
            notify({
                Title = "World Check",
                Content = "World could not be detected",
                Duration = 3
            })
        end
    end
})
MiscTab:Divider()
Players = game:GetService("Players")
bV = game:GetService("RunService")
SPIN_ENABLED = SPIN_ENABLED or false
SPIN_SPEED = SPIN_SPEED or 200
SPIN_MULTIPLIER = SPIN_MULTIPLIER or 1
d5 = Players.LocalPlayer
hrp = nil
hum = nil
SPIN_BAV = SPIN_BAV or nil
SPIN_PREV_AUTOROTATE = SPIN_PREV_AUTOROTATE or nil
_SPIN_LAST_SPEED = _SPIN_LAST_SPEED or nil
function SPIN_UPDATE_REFS()
    if d5 and d5.Character then
        hrp = d5.Character:FindFirstChild("HumanoidRootPart")
        hum = d5.Character:FindFirstChildOfClass("Humanoid")
    else
        hrp = nil
        hum = nil
    end
end
SPIN_UPDATE_REFS()
d5.CharacterAdded:Connect(
    function()
        task.wait(0.12)
        SPIN_UPDATE_REFS()
    end
)
function SPIN_CREATE_BAV()
    if not hrp then
        return
    end
    if SPIN_BAV and SPIN_BAV.Parent == hrp then
        return
    end
    if SPIN_BAV then
        pcall(
            function()
                SPIN_BAV:Destroy()
            end
        )
        SPIN_BAV = nil
    end
    SPIN_BAV = Instance.new("BodyAngularVelocity")
    SPIN_BAV.Name = "RyZen_Spin_BAV"
    SPIN_BAV.MaxTorque = Vector3.new(0, 9e9, 0)
    SPIN_BAV.AngularVelocity =
        Vector3.new(0, math.rad(math.clamp((SPIN_SPEED or 200) * (SPIN_MULTIPLIER or 1), 0, 360000)), 0)
    SPIN_BAV.Parent = hrp
    _SPIN_LAST_SPEED = SPIN_SPEED
end
function SPIN_DESTROY_BAV()
    if SPIN_BAV then
        pcall(
            function()
                SPIN_BAV:Destroy()
            end
        )
        SPIN_BAV = nil
    end
    _SPIN_LAST_SPEED = nil
end
MiscTab:Toggle(
    {
        Flag = "AutoTab",
        Title = "Spin",
        Desc = "Enable character spinning",
        Default = SPIN_ENABLED,
        Callback = function(U)
            SPIN_ENABLED = U
        end
    }
)
MiscTab:Slider(
    {
        Flag = "AutoTab",
        Title = "Spin Speed",
        Desc = "max to become a helicopter.",
        Value = {Min = 10, Max = 2000, Default = SPIN_SPEED},
        Step = 1,
        Callback = function(V)
            SPIN_SPEED = math.max(0, V)
            if SPIN_BAV and SPIN_BAV.Parent then
                SPIN_BAV.AngularVelocity =
                    Vector3.new(0, math.rad(math.clamp(SPIN_SPEED * (SPIN_MULTIPLIER or 1), 0, 360000)), 0)
                _SPIN_LAST_SPEED = SPIN_SPEED
            end
        end
    }
)
bV.Heartbeat:Connect(
    function()
        if not hrp or not hum then
            SPIN_UPDATE_REFS()
        end
        if SPIN_ENABLED then
            if hum and hrp then
                if SPIN_PREV_AUTOROTATE == nil then
                    SPIN_PREV_AUTOROTATE = hum.AutoRotate
                end
                pcall(
                    function()
                        hum.AutoRotate = false
                    end
                )
                if not SPIN_BAV or SPIN_BAV.Parent ~= hrp then
                    SPIN_CREATE_BAV()
                end
                if SPIN_BAV and _SPIN_LAST_SPEED ~= SPIN_SPEED then
                    SPIN_BAV.AngularVelocity =
                        Vector3.new(0, math.rad(math.clamp(SPIN_SPEED * (SPIN_MULTIPLIER or 1), 0, 360000)), 0)
                    _SPIN_LAST_SPEED = SPIN_SPEED
                end
            else
                SPIN_DESTROY_BAV()
            end
        else
            if hum and SPIN_PREV_AUTOROTATE ~= nil then
                pcall(
                    function()
                        hum.AutoRotate = SPIN_PREV_AUTOROTATE
                    end
                )
                SPIN_PREV_AUTOROTATE = nil
            end
            SPIN_DESTROY_BAV()
        end
    end
)
Players.LocalPlayer.CharacterAdded:Connect(
    function(char)
        task.wait(0.12)
        SPIN_UPDATE_REFS()
        if SPIN_ENABLED then
            SPIN_CREATE_BAV()
        else
            SPIN_DESTROY_BAV()
        end
    end
)

MiscTab:Toggle(
    {
        Flag = "AutoTab",
        Title = "Infinite Jump",
        Desc = "you can go to heaven with this!",
        Default = false,
        Callback = function(U)
            INFINITE_JUMP = U
        end
    }
)
game:GetService("UserInputService").JumpRequest:Connect(
    function()
        if INFINITE_JUMP then
            d5 = game:GetService("Players").LocalPlayer
            if d5 and d5.Character then
                humanoid = d5.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
)

MiscTab:Divider()

if not NOTIFY then
    function NOTIFY(c2, ea, c3)
        if b then
            b:Notify({Title = c2, Content = ea, Duration = c3 or 3, Icon = "rbxassetid://84501312005643"})
        else
            warn("[" .. tostring(c2) .. "] " .. tostring(ea))
        end
    end
end
if
    Players and Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui") and
        Players.LocalPlayer.PlayerGui:FindFirstChild("RyZenHubAFK")
 then
    Players.LocalPlayer.PlayerGui.RyZenHubAFK:Destroy()
end
ANTI_AFK_ENABLED = false
ANTI_AFK_TIME = 0
AFK_GUI = nil
AFK_Frame = nil
AFK_Timer = nil
AFK_CopyBtn = nil
AFK_Close = nil
AFK_MinBtn = nil
AFK_DRAGGING = false
AFK_DRAG_INPUT = nil
AFK_DRAG_OFFSET_X = 0
AFK_DRAG_OFFSET_Y = 0
AFK_CONN_INPUT_BEGAN = AFK_CONN_INPUT_BEGAN
AFK_CONN_INPUT_CHANGED = AFK_CONN_INPUT_CHANGED
AFK_CONN_INPUT_ENDED = AFK_CONN_INPUT_ENDED
ANTI_AFK_IDLED_CONN = ANTI_AFK_IDLED_CONN
ANTI_AFK_HEART_CONN = ANTI_AFK_HEART_CONN
AFK_MINIMIZED = false
Players = game:GetService("Players")
UserInputService = game:GetService("UserInputService")
bV = game:GetService("RunService")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
function FORMAT_TIME(eb)
    h = math.floor(eb / 3600)
    m = math.floor(eb % 3600 / 60)
    s = eb % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end
function CREATE_AFK_GUI()
    if AFK_GUI and AFK_GUI.Parent then
        return
    end
    if Players.LocalPlayer.PlayerGui:FindFirstChild("RyZenHubAFK") then
        Players.LocalPlayer.PlayerGui.RyZenHubAFK:Destroy()
    end
    AFK_GUI = Instance.new("ScreenGui")
    AFK_GUI.Name = "RyZenHubAFK"
    AFK_GUI.ResetOnSpawn = false
    AFK_GUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    AFK_Frame = Instance.new("Frame")
    AFK_Frame.Name = "AFKFrame"
    AFK_Frame.Size = UDim2.new(0, 240, 0, 100)
    AFK_Frame.Position = UDim2.new(0.7, 0, 0.08, 0)
    AFK_Frame.BackgroundTransparency = 0
    AFK_Frame.BorderSizePixel = 0
    AFK_Frame.Parent = AFK_GUI
    AFK_Gradient = Instance.new("UIGradient")
    AFK_Gradient.Color =
        ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 30, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }
    AFK_Gradient.Rotation = 45
    AFK_Gradient.Parent = AFK_Frame
    AFK_Round = Instance.new("UICorner")
    AFK_Round.CornerRadius = UDim.new(0, 10)
    AFK_Round.Parent = AFK_Frame
    AFK_Title = Instance.new("TextLabel")
    AFK_Title.Name = "Title"
    AFK_Title.Size = UDim2.new(1, -80, 0, 24)
    AFK_Title.Position = UDim2.new(0, 10, 0, 6)
    AFK_Title.BackgroundTransparency = 1
    AFK_Title.Text = "RyZen Hub AFK"
    AFK_Title.TextColor3 = Color3.fromRGB(200, 230, 255)
    AFK_Title.Font = Enum.Font.SourceSansBold
    AFK_Title.TextSize = 16
    AFK_Title.TextXAlignment = Enum.TextXAlignment.Left
    AFK_Title.Parent = AFK_Frame
    AFK_Timer = Instance.new("TextLabel")
    AFK_Timer.Name = "Timer"
    AFK_Timer.Size = UDim2.new(0, 140, 0, 36)
    AFK_Timer.Position = UDim2.new(0, 50, 0, 32)
    AFK_Timer.BackgroundTransparency = 1
    AFK_Timer.Text = FORMAT_TIME(ANTI_AFK_TIME)
    AFK_Timer.TextColor3 = Color3.fromRGB(230, 250, 255)
    AFK_Timer.Font = Enum.Font.SourceSansBold
    AFK_Timer.TextSize = 22
    AFK_Timer.TextXAlignment = Enum.TextXAlignment.Center
    AFK_Timer.Parent = AFK_Frame
    AFK_CopyBtn = Instance.new("TextButton")
    AFK_CopyBtn.Name = "CopyButton"
    AFK_CopyBtn.Size = UDim2.new(0, 90, 0, 26)
    AFK_CopyBtn.Position = UDim2.new(1, -10, 1, -10)
    AFK_CopyBtn.AnchorPoint = Vector2.new(1, 1)
    AFK_CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    AFK_CopyBtn.BorderSizePixel = 0
    AFK_CopyBtn.Text = "Copy Time"
    AFK_CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AFK_CopyBtn.Font = Enum.Font.SourceSansBold
    AFK_CopyBtn.TextSize = 14
    AFK_CopyBtn.Parent = AFK_Frame
    AFK_MinBtn = Instance.new("TextButton")
    AFK_MinBtn.Name = "MinBtn"
    AFK_MinBtn.Size = UDim2.new(0, 26, 0, 22)
    AFK_MinBtn.Position = UDim2.new(1, -56, 0, 6)
    AFK_MinBtn.BackgroundTransparency = 0.5
    AFK_MinBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    AFK_MinBtn.Text = "_"
    AFK_MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AFK_MinBtn.Font = Enum.Font.SourceSansBold
    AFK_MinBtn.TextSize = 18
    AFK_MinBtn.Parent = AFK_Frame
    AFK_Close = Instance.new("TextButton")
    AFK_Close.Name = "CloseBtn"
    AFK_Close.Size = UDim2.new(0, 22, 0, 22)
    AFK_Close.Position = UDim2.new(1, -28, 0, 6)
    AFK_Close.BackgroundTransparency = 0.5
    AFK_Close.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    AFK_Close.Text = "X"
    AFK_Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    AFK_Close.Font = Enum.Font.SourceSansBold
    AFK_Close.TextSize = 14
    AFK_Close.Parent = AFK_Frame
    AFK_CopyBtn.MouseButton1Click:Connect(
        function()
            pcall(
                function()
                    setclipboard(FORMAT_TIME(ANTI_AFK_TIME))
                    NOTIFY("Anti-AFK", "Copied " .. FORMAT_TIME(ANTI_AFK_TIME) .. " to clipboard!", 2)
                end
            )
        end
    )
    AFK_Close.MouseButton1Click:Connect(
        function()
            ANTI_AFK_ENABLED = false
            DESTROY_AFK_GUI()
            NOTIFY("Anti-AFK", "Disabled and UI removed", 2)
        end
    )
    AFK_MinBtn.MouseButton1Click:Connect(
        function()
            AFK_MINIMIZED = not AFK_MINIMIZED
            if AFK_MINIMIZED then
                AFK_Frame.Size = UDim2.new(0, 160, 0, 34)
                AFK_Timer.Visible = false
                AFK_CopyBtn.Visible = false
                AFK_Title.Text = "RyZen Hub AFK (min)"
            else
                AFK_Frame.Size = UDim2.new(0, 240, 0, 100)
                AFK_Timer.Visible = true
                AFK_CopyBtn.Visible = true
                AFK_Title.Text = "RyZen Hub AFK"
            end
        end
    )
    AFK_CONN_INPUT_BEGAN =
        AFK_Frame.InputBegan:Connect(
        function(ai)
            if ai.UserInputType == Enum.UserInputType.MouseButton1 or ai.UserInputType == Enum.UserInputType.Touch then
                AFK_DRAGGING = true
                AFK_DRAG_INPUT = ai
                if ai.UserInputType == Enum.UserInputType.MouseButton1 then
                    pos = UserInputService:GetMouseLocation()
                else
                    pos = ai.Position
                end
                AFK_DRAG_OFFSET_X = pos.X - AFK_Frame.AbsolutePosition.X
                AFK_DRAG_OFFSET_Y = pos.Y - AFK_Frame.AbsolutePosition.Y
            end
        end
    )
    AFK_CONN_INPUT_CHANGED =
        UserInputService.InputChanged:Connect(
        function(ai)
            if AFK_DRAGGING and AFK_DRAG_INPUT then
                if
                    ai == AFK_DRAG_INPUT or ai.UserInputType == Enum.UserInputType.MouseMovement or
                        ai.UserInputType == Enum.UserInputType.Touch
                 then
                    if
                        ai.UserInputType == Enum.UserInputType.MouseMovement or
                            ai.UserInputType == Enum.UserInputType.MouseButton1
                     then
                        pos = UserInputService:GetMouseLocation()
                    else
                        pos = ai.Position
                    end
                    newX = pos.X - AFK_DRAG_OFFSET_X
                    newY = pos.Y - AFK_DRAG_OFFSET_Y
                    cam = Workspace.CurrentCamera
                    if cam then
                        vs = cam.ViewportSize
                        if newX < 0 then
                            newX = 0
                        end
                        if newY < 0 then
                            newY = 0
                        end
                        maxX = vs.X - AFK_Frame.AbsoluteSize.X
                        maxY = vs.Y - AFK_Frame.AbsoluteSize.Y
                        if newX > maxX then
                            newX = maxX
                        end
                        if newY > maxY then
                            newY = maxY
                        end
                    end
                    AFK_Frame.Position = UDim2.new(0, newX, 0, newY)
                end
            end
        end
    )
    AFK_CONN_INPUT_ENDED =
        AFK_Frame.InputEnded:Connect(
        function(ai)
            if AFK_DRAG_INPUT and ai == AFK_DRAG_INPUT then
                AFK_DRAGGING = false
                AFK_DRAG_INPUT = nil
            end
        end
    )
    AFK_GUI.Enabled = true
end
function DESTROY_AFK_GUI()
    if AFK_CONN_INPUT_CHANGED then
        AFK_CONN_INPUT_CHANGED:Disconnect()
        AFK_CONN_INPUT_CHANGED = nil
    end
    if AFK_CONN_INPUT_ENDED then
        AFK_CONN_INPUT_ENDED:Disconnect()
        AFK_CONN_INPUT_ENDED = nil
    end
    if AFK_CONN_INPUT_BEGAN then
        AFK_CONN_INPUT_BEGAN:Disconnect()
        AFK_CONN_INPUT_BEGAN = nil
    end
    if AFK_GUI and AFK_GUI.Parent then
        AFK_GUI:Destroy()
    end
    AFK_GUI = nil
    AFK_Frame = nil
    AFK_Timer = nil
    AFK_CopyBtn = nil
    AFK_Close = nil
    AFK_MinBtn = nil
    AFK_DRAGGING = false
    AFK_DRAG_INPUT = nil
    if ANTI_AFK_HEART_CONN then
        ANTI_AFK_HEART_CONN:Disconnect()
        ANTI_AFK_HEART_CONN = nil
    end
end
if not ANTI_AFK_IDLED_CONN then
    ANTI_AFK_IDLED_CONN =
        Players.LocalPlayer.Idled:Connect(
        function()
            if ANTI_AFK_ENABLED then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end
        end
    )
end
function START_AFK_TIMER_LOOP()
    if ANTI_AFK_HEART_CONN then
        return
    end
    if AFK_Timer then
        AFK_Timer.Text = FORMAT_TIME(ANTI_AFK_TIME)
    end
    accumulator = 0
    ANTI_AFK_HEART_CONN =
        bV.Heartbeat:Connect(
        function(ec)
            if not ANTI_AFK_ENABLED then
                return
            end
            accumulator = accumulator + ec
            while accumulator >= 1 do
                accumulator = accumulator - 1
                ANTI_AFK_TIME = ANTI_AFK_TIME + 1
                if AFK_Timer then
                    AFK_Timer.Text = FORMAT_TIME(ANTI_AFK_TIME)
                end
            end
        end
    )
end
function STOP_AFK_TIMER_LOOP()
    if ANTI_AFK_HEART_CONN then
        ANTI_AFK_HEART_CONN:Disconnect()
        ANTI_AFK_HEART_CONN = nil
    end
end
if MiscTab then
    MiscTab:Toggle(
        {
            Flag = "AutoTab",
            Title = "Anti-AFK",
            Desc = "Avoid being kicked while afk",
            Default = false,
            Callback = function(U)
                ANTI_AFK_ENABLED = U
                if ANTI_AFK_ENABLED then
                    ANTI_AFK_TIME = 0
                    CREATE_AFK_GUI()
                    START_AFK_TIMER_LOOP()
                    NOTIFY("Anti-AFK", "Enabled", 2)
                else
                    ANTI_AFK_ENABLED = false
                    STOP_AFK_TIMER_LOOP()
                    DESTROY_AFK_GUI()
                    NOTIFY("Anti-AFK", "Disabled and UI removed", 2)
                end
            end
        }
    )
else
    NOTIFY("Anti-AFK", "Tab not found — set ANTI_AFK_ENABLED = true to enable", 3)
end
if MiscTab then
    MiscTab:Toggle(
        {
            Flag = "AutoTab",
            Title = "Freeze Character",
            Desc = "Freeze/unfreeze your character in place",
            Default = false,
            Callback = function(U)
                d5 = game:GetService("Players").LocalPlayer
                if not d5 then
                    return
                end
                char = d5.Character or d5.CharacterAdded:Wait()
                hrp = char:WaitForChild("HumanoidRootPart")
                humanoid = char:FindFirstChildOfClass("Humanoid")
                if U then
                    hrp.Anchored = true
                    if humanoid then
                        humanoid.PlatformStand = true
                    end
                else
                    hrp.Anchored = false
                    if humanoid then
                        humanoid.PlatformStand = false
                    end
                end
            end
        }
    )
end
    MiscTab:Toggle(
        {
            Flag = "AutoTab",
            Title = "Freeze Character",
            Desc = "Freeze/unfreeze your character in place",
            Default = false,
            Callback = function(U)
                d5 = game:GetService("Players").LocalPlayer
                if not d5 then
                    return
                end
                char = d5.Character or d5.CharacterAdded:Wait()
                hrp = char:WaitForChild("HumanoidRootPart")
                humanoid = char:FindFirstChildOfClass("Humanoid")
                if U then
                    hrp.Anchored = true
                    if humanoid then
                        humanoid.PlatformStand = true
                    end
                else
                    hrp.Anchored = false
                    if humanoid then
                        humanoid.PlatformStand = false
                    end
                end
            end
        }
    )
end

local JoinsTab = Window:Tab({
    Title = "Joins",
    Icon = "users"
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

_G.JoinJobId = _G.JoinJobId or ""
_G.MaxPlayersThreshold = _G.MaxPlayersThreshold or 4 

JoinsTab:Input({
    Title = "Join Job ID",
    Desc = "Paste a server instance id (job id) to join directly",
    Value = tostring(_G.JoinJobId),
    Type = "Input",
    Placeholder = "Enter Job ID",
    Callback = function(input) _G.JoinJobId = tostring(input or "") end
})

JoinsTab:Button({
    Title = "Join Job",
    Desc = "Teleport to the server instance specified by Job ID",
    Callback = function()
        local jobId = tostring(_G.JoinJobId or "")
        if jobId == "" then
            notify({Title = "Joins", Content = "No Job ID provided", Duration = 2})
            return
        end
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, Players.LocalPlayer)
        end)
        if not ok then
            notify({Title = "Joins", Content = "Join Job failed: "..tostring(err), Duration = 3})
        end
    end
})

JoinsTab:Button({
    Title = "Rejoin",
    Desc = "Rejoin the current place",
    Callback = function()
        pcall(function() TeleportService:Teleport(game.PlaceId) end)
    end
})

JoinsTab:Divider()

local function invokeTeleportToIsland(islandName)
    if not islandName then return end
    local ok, rf = pcall(function()
        return ReplicatedStorage
            and ReplicatedStorage:FindFirstChild("Shared")
            and ReplicatedStorage.Shared:FindFirstChild("Packages")
            and ReplicatedStorage.Shared.Packages:FindFirstChild("Knit")
            and ReplicatedStorage.Shared.Packages.Knit:FindFirstChild("Services")
            and ReplicatedStorage.Shared.Packages.Knit.Services:FindFirstChild("PortalService")
            and ReplicatedStorage.Shared.Packages.Knit.Services.PortalService:FindFirstChild("RF")
            and ReplicatedStorage.Shared.Packages.Knit.Services.PortalService.RF:FindFirstChild("TeleportToIsland")
    end)
    if ok and rf and rf.InvokeServer then
        pcall(function()
            rf:InvokeServer(islandName)
            notify({Title="Joins", Content="Teleport attempted: "..tostring(islandName), Duration=2})
        end)
    else
        notify({Title="Joins", Content="Teleport remote not found", Duration=2})
    end
end

JoinsTab:Button({
    Title = "Teleport to World 1 (Stonewake's Cross)",
    Desc = "Teleport to world 1",
    Callback = function() invokeTeleportToIsland("Stonewake's Cross") end
})

JoinsTab:Button({
    Title = "Teleport to World 2 (Forgotten Kingdom)",
    Desc = "Teleport to world 2",
    Callback = function() invokeTeleportToIsland("Forgotten Kingdom") end
})
JoinsTab:Button({
    Title = "Teleport to World 3 (Frostspire Expanse)",
    Desc = "Teleport to world 3",
    Callback = function()
        invokeTeleportToIsland("Frostspire Expanse")
    end
})
JoinsTab:Space()

JoinsTab:Input({
    Title = "Max players to join",
    Desc = "how many playersyou wanna join",
    Value = tostring(_G.MaxPlayersThreshold),
    Type = "Input",
    Placeholder = "e.g. 4",
    Callback = function(input)
        local n = tonumber(input)
        if n then _G.MaxPlayersThreshold = n end
    end
})

local function findAndJoinLowPlayerServer(maxPlayers)
    maxPlayers = tonumber(maxPlayers) or 4

    
    local requestFunc

local ok = pcall(function()
    HttpService:GetAsync("https://example.com")
end)

if ok then
    requestFunc = function(url)
        return HttpService:GetAsync(url)
    end
else
    
    if syn and syn.request then
        requestFunc = function(url)
            return syn.request({Url = url, Method = "GET"}).Body
        end
    elseif http_request then
        requestFunc = function(url)
            return http_request({Url = url, Method = "GET"}).Body
        end
    elseif request then
        requestFunc = function(url)
            return request({Url = url, Method = "GET"}).Body
        end
    end
end
    if not requestFunc then
        notify({Title="Joins", Content="HTTP access unavailable. Can't search servers.", Duration=4})
        return
    end

    local base = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
    local cursor = nil

    repeat
        local url = base
        if cursor then
            url = url .. "&cursor=" .. HttpService:UrlEncode(tostring(cursor))
        end

        local ok, body = pcall(function() return requestFunc(url) end)
        if not ok or not body then break end

        local success, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not success or type(data) ~= "table" then break end

        for _, server in ipairs(data.data or {}) do
            
            local playing = tonumber(server.playing) or 0
            local serverId = tostring(server.id or server.uuid or "")
            
            local curJob = tostring(game.JobId or "")
            if serverId ~= "" and serverId ~= curJob and playing <= maxPlayers then
                
                local ok2, err2 = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, Players.LocalPlayer)
                end)
                if not ok2 then
                    notify({Title="Joins", Content="Teleport failed: "..tostring(err2), Duration=3})
                end
                return true
            end
        end

        cursor = data.nextPageCursor
    until not cursor

    notify({Title="Joins", Content="No low-player server found (<= "..tostring(maxPlayers)..")", Duration=4})
    return false
end

JoinsTab:Button({
    Title = "join low players server",
    Desc = "join low players server based on the input you've typed",
    Callback = function()
        spawn(function() 
            findAndJoinLowPlayerServer(_G.MaxPlayersThreshold)
        end)
    end
})
VisualTab = Window:Tab({Title = "Visuals", Icon = "scan"})
ad = VisualTab:Section({Title = "Performance", Icon = "circle-alert"})

Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
Players = game:GetService("Players")
RunService = game:GetService("RunService")

RemoveFogEnabled = false
UltraLowEnabled = false
FullBrightEnabled = false

function ApplyVisualSettings()
    
    pcall(function()
        if RemoveFogEnabled then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = 1000
            Lighting.FogStart = 0
        end
    end)

    
    pcall(function()
        if FullBrightEnabled then
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        else
            Lighting.Ambient = Color3.fromRGB(128,128,128)
            Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        end
    end)
end

_G.LowGraphicsEnabled = _G.LowGraphicsEnabled or false
_G.LowGraphics_Connections = _G.LowGraphics_Connections or {}
_G.LowGraphics_Original = _G.LowGraphics_Original or {}
_G.LowGraphics_ScanQueue = _G.LowGraphics_ScanQueue or {}
_G.LowGraphics_ProcessBatch = _G.LowGraphics_ProcessBatch or 15      
_G.LowGraphics_ProcessDelay = _G.LowGraphics_ProcessDelay or 0.06   
_G.LowGraphics_HeavyScanInterval = _G.LowGraphics_HeavyScanInterval or 30 

Players = game:GetService("Players")
Lighting = game:GetService("Lighting")
MaterialService = game:GetService("MaterialService")
RunService = game:GetService("RunService")
Workspace = game:GetService("Workspace")

ME = Players.LocalPlayer

if not _G.LowGraphics_Original._saved then
    pcall(function()
        _G.LowGraphics_Original.GlobalShadows = Lighting.GlobalShadows
        _G.LowGraphics_Original.ShadowSoftness = Lighting.ShadowSoftness
        _G.LowGraphics_Original.FogEnd = Lighting.FogEnd
        _G.LowGraphics_Original.FogStart = Lighting.FogStart
        _G.LowGraphics_Original.Ambient = Lighting.Ambient
        _G.LowGraphics_Original.OutdoorAmbient = Lighting.OutdoorAmbient
        if settings() and settings().Rendering then
            _G.LowGraphics_Original.QualityLevel = settings().Rendering.QualityLevel
            _G.LowGraphics_Original.MeshDetail = settings().Rendering.MeshPartDetailLevel
        end
    end)
    _G.LowGraphics_Original._saved = true
end

function ShouldAffect(inst)
    if not inst then return false end
    if ME and ME.Character and (_G.Settings and _G.Settings.Players and _G.Settings.Players["Ignore Me"]) and inst:IsDescendantOf(ME.Character) then
        return false
    end
    if _G.Settings and _G.Settings.Players and _G.Settings.Players["Ignore Others"] then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= ME and p.Character and inst:IsDescendantOf(p.Character) then
                return false
            end
        end
    end
    if _G.Ignore and type(_G.Ignore) == "table" and #_G.Ignore > 0 then
        for _, ig in ipairs(_G.Ignore) do
            if ig and inst:IsDescendantOf(ig) then
                return false
            end
        end
    end
    return true
end

function ApplyToInstance(inst)
    if not inst then return end
    if not ShouldAffect(inst) then return end

    pcall(function()
        
        if inst:IsA("MeshPart") or inst:IsA("SpecialMesh") or inst:IsA("DataModelMesh") then
            if _G.Settings and _G.Settings.MeshParts and _G.Settings.MeshParts.LowerQuality then
                if inst:IsA("MeshPart") then
                    inst.RenderFidelity = Enum.RenderFidelity.Performance
                end
                inst.Reflectance = 0
                inst.Material = Enum.Material.Plastic
            end
            if _G.Settings and _G.Settings.MeshParts and _G.Settings.MeshParts.Invisible then
                if inst:IsA("MeshPart") then
                    inst.Transparency = 1
                    inst.RenderFidelity = Enum.RenderFidelity.Performance
                end
                inst.Reflectance = 0
                inst.Material = Enum.Material.Plastic
            end
            if _G.Settings and _G.Settings.MeshParts and _G.Settings.MeshParts.NoTexture then
                if rawget(inst, "TextureID") ~= nil then pcall(function() inst.TextureID = "" end) end
            end
            if _G.Settings and _G.Settings.MeshParts and _G.Settings.MeshParts.NoMesh then
                if rawget(inst, "MeshId") ~= nil then pcall(function() inst.MeshId = "" end) end
            end
            if _G.Settings and _G.Settings.MeshParts and _G.Settings.MeshParts.Destroy then
                pcall(function() inst:Destroy() end)
            end
            return
        end

        
        if inst:IsA("Decal") or inst:IsA("Texture") or inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            if _G.Settings and _G.Settings.Images and _G.Settings.Images.Invisible then
                pcall(function() inst.Transparency = 1 end)
            end
            if _G.Settings and _G.Settings.Images and _G.Settings.Images.Destroy then
                pcall(function() inst:Destroy() end)
            end
            return
        end

        
        if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") or inst:IsA("Beam") then
            if _G.Settings and ((_G.Settings.Particles and _G.Settings.Particles.Invisible) or (_G.Settings.Other and _G.Settings.Other["Invisible Particles"])) then
                pcall(function() inst.Enabled = false end)
            end
            if _G.Settings and ((_G.Settings.Particles and _G.Settings.Particles.Destroy) or (_G.Settings.Other and _G.Settings.Other["No Particles"])) then
                pcall(function() inst:Destroy() end)
            end
            return
        end

        
        if inst:IsA("PostEffect") then
            if _G.Settings and ((_G.Settings.Other and _G.Settings.Other["No Camera Effects"]) or _G.Settings["No Camera Effects"]) then
                pcall(function() inst.Enabled = false end)
            end
            return
        end

        
        if inst:IsA("Explosion") then
            if _G.Settings and _G.Settings.Explosions and _G.Settings.Explosions.Smaller then
                pcall(function()
                    inst.BlastPressure = 1
                    inst.BlastRadius = 1
                end)
            end
            if _G.Settings and _G.Settings.Explosions and _G.Settings.Explosions.Invisible then
                pcall(function()
                    inst.BlastPressure = 1
                    inst.BlastRadius = 1
                    if inst.Visible ~= nil then inst.Visible = false end
                end)
            end
            if _G.Settings and _G.Settings.Explosions and _G.Settings.Explosions.Destroy then
                pcall(function() inst:Destroy() end)
            end
            return
        end

        
        if inst:IsA("Clothing") or inst:IsA("SurfaceAppearance") or inst:IsA("BaseWrap") then
            if _G.Settings and ((_G.Settings.Other and _G.Settings.Other["No Clothes"]) or _G.Settings["No Clothes"]) then
                pcall(function() inst:Destroy() end)
            end
            return
        end

        
        if inst:IsA("TextLabel") and inst:IsDescendantOf(Workspace) then
            if _G.Settings and ((_G.Settings.TextLabels and _G.Settings.TextLabels.LowerQuality) or (_G.Settings.Other and _G.Settings.Other["Lower Quality TextLabels"])) then
                pcall(function()
                    inst.Font = Enum.Font.SourceSans
                    inst.TextScaled = false
                    inst.RichText = false
                    inst.TextSize = 14
                end)
            end
            if _G.Settings and ((_G.Settings.TextLabels and _G.Settings.TextLabels.Invisible) or (_G.Settings.Other and _G.Settings.Other["Invisible TextLabels"])) then
                pcall(function() inst.Visible = false end)
            end
            if _G.Settings and ((_G.Settings.TextLabels and _G.Settings.TextLabels.Destroy) or (_G.Settings.Other and _G.Settings.Other["No TextLabels"])) then
                pcall(function() inst:Destroy() end)
            end
            return
        end

        
        if inst:IsA("BasePart") then
            if _G.Settings and ((_G.Settings.Other and _G.Settings.Other["Low Quality Parts"]) or _G.Settings["Low Quality Parts"]) then
                pcall(function()
                    inst.Material = Enum.Material.Plastic
                    inst.Reflectance = 0
                end)
            end
            return
        end

        
        if inst:IsA("Model") then
            if _G.Settings and ((_G.Settings.Other and _G.Settings.Other["Low Quality Models"]) or _G.Settings["Low Quality Models"]) then
                pcall(function() inst.LevelOfDetail = 1 end)
            end
            return
        end
    end)
end

function EnqueueForProcessing(inst)
    if not inst then return end
    if not _G.LowGraphics_ScanQueue then _G.LowGraphics_ScanQueue = {} end
    
    if #_G.LowGraphics_ScanQueue >= 5000 then return end
    table.insert(_G.LowGraphics_ScanQueue, inst)
end

if _G.LowGraphics_Connections.Processor then
    pcall(function() _G.LowGraphics_Connections.Processor:Disconnect() end)
    _G.LowGraphics_Connections.Processor = nil
end

_G.LowGraphics_Connections.Processor =
    RunService.Heartbeat:Connect(function()
        if not _G.LowGraphicsEnabled then return end
        if not _G.LowGraphics_Connections._lastProcess or (tick() - _G.LowGraphics_Connections._lastProcess) >= (_G.LowGraphics_ProcessDelay or 0.06) then
            _G.LowGraphics_Connections._lastProcess = tick()
            for i = 1, (_G.LowGraphics_ProcessBatch or 15) do
                if not _G.LowGraphics_ScanQueue or #_G.LowGraphics_ScanQueue == 0 then break end
                local inst = table.remove(_G.LowGraphics_ScanQueue, 1)
                pcall(function() ApplyToInstance(inst) end)
            end
        end
    end)

if _G.LowGraphics_Connections.DescendantAdded then
    pcall(function() _G.LowGraphics_Connections.DescendantAdded:Disconnect() end)
    _G.LowGraphics_Connections.DescendantAdded = nil
end

_G.LowGraphics_Connections.DescendantAdded =
    game.DescendantAdded:Connect(function(inst)
        if not _G.LowGraphicsEnabled then return end
        task.wait(_G.LoadedWait or 0.75)
        pcall(function() EnqueueForProcessing(inst) end)
    end)

function DoInitialBatchedScan()
    if not _G.LowGraphicsEnabled then return end
    pcall(function()
        local all = game:GetDescendants()
        for _, v in ipairs(all) do
            EnqueueForProcessing(v)
            
            if #_G.LowGraphics_ScanQueue >= 2000 then
                task.wait(0.05)
            end
        end
    end)
end

if _G.LowGraphics_Connections.HeavyScanner then
    pcall(function() _G.LowGraphics_Connections.HeavyScanner:Disconnect() end)
    _G.LowGraphics_Connections.HeavyScanner = nil
end

_G.LowGraphics_Connections.HeavyScanner =
    RunService.Heartbeat:Connect(function()
        if not _G.LowGraphicsEnabled then return end
        if not _G.LowGraphics_Connections._lastHeavy or (tick() - _G.LowGraphics_Connections._lastHeavy) > (_G.LowGraphics_HeavyScanInterval or 30) then
            _G.LowGraphics_Connections._lastHeavy = tick()
            
            pcall(function() DoInitialBatchedScan() end)
        end
    end)

function ApplyLightingForLowGraphics()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 0
        Lighting.Ambient = Color3.fromRGB(128,128,128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        if sethiddenproperty then pcall(function() sethiddenproperty(Lighting, "Technology", 2) end) end
    end)

    pcall(function()
        if settings() and settings().Rendering then
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end
    end)

    pcall(function()
        local Terrain = Workspace:FindFirstChildOfClass("Terrain")
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
            if sethiddenproperty then pcall(function() sethiddenproperty(Terrain, "Decoration", false) end) end
        end
    end)
end

function RestoreLighting()
    pcall(function()
        if _G.LowGraphics_Original.GlobalShadows ~= nil then Lighting.GlobalShadows = _G.LowGraphics_Original.GlobalShadows end
        if _G.LowGraphics_Original.ShadowSoftness ~= nil then Lighting.ShadowSoftness = _G.LowGraphics_Original.ShadowSoftness end
        if _G.LowGraphics_Original.FogEnd ~= nil then Lighting.FogEnd = _G.LowGraphics_Original.FogEnd end
        if _G.LowGraphics_Original.FogStart ~= nil then Lighting.FogStart = _G.LowGraphics_Original.FogStart end
        if _G.LowGraphics_Original.Ambient ~= nil then Lighting.Ambient = _G.LowGraphics_Original.Ambient end
        if _G.LowGraphics_Original.OutdoorAmbient ~= nil then Lighting.OutdoorAmbient = _G.LowGraphics_Original.OutdoorAmbient end
        if _G.LowGraphics_Original.QualityLevel ~= nil and settings() and settings().Rendering then
            settings().Rendering.QualityLevel = _G.LowGraphics_Original.QualityLevel
        end
        if _G.LowGraphics_Original.MeshDetail ~= nil and settings() and settings().Rendering then
            settings().Rendering.MeshPartDetailLevel = _G.LowGraphics_Original.MeshDetail
        end
    end)
end

function EnableLowGraphics()
    if _G.LowGraphicsEnabled then return end
    _G.LowGraphicsEnabled = true
    ApplyLightingForLowGraphics()
    DoInitialBatchedScan()
end

function DisableLowGraphics()
    if not _G.LowGraphicsEnabled then return end
    _G.LowGraphicsEnabled = false
    RestoreLighting()
    
    _G.LowGraphics_ScanQueue = {}
end

function ToggleLowGraphics(state)
    if state == nil then state = not _G.LowGraphicsEnabled end
    if state then EnableLowGraphics() else DisableLowGraphics() end
end

pcall(function()
    if _G.LowGraphicsEnabled then
        EnableLowGraphics()
    end
end)

function DisableLowGraphics()
    if not _G.LowGraphicsEnabled then return end
    _G.LowGraphicsEnabled = false

    Lighting.GlobalShadows = _G.LowGraphics_Original.GlobalShadows
    Lighting.ShadowSoftness = _G.LowGraphics_Original.ShadowSoftness
    Lighting.FogEnd = _G.LowGraphics_Original.FogEnd

    settings().Rendering.QualityLevel = _G.LowGraphics_Original.QualityLevel
    settings().Rendering.MeshPartDetailLevel = _G.LowGraphics_Original.MeshDetail

    if _G.LowGraphics_Connections.DescendantAdded then
        _G.LowGraphics_Connections.DescendantAdded:Disconnect()
        _G.LowGraphics_Connections.DescendantAdded = nil
    end
end

VisualTab:Toggle({
    Flag = "AutoTab",
    Title = "Remove Fog",
    Desc = "Toggle to remove all fog",
    Icon = "eye",
    Type = "Checkbox",
    Value = false,
    Callback = function(U)
        RemoveFogEnabled = U
        ApplyVisualSettings()
    end
})

VisualTab:Toggle({
    Flag = "AutoTab",
    Title = "Full Bright",
    Desc = "I Can See Everything!",
    Icon = "sun",
    Type = "Checkbox",
    Value = false,
    Callback = function(U)
        FullBrightEnabled = U
        ApplyVisualSettings()
    end
})

spawn(function()
    while true do
        pcall(function()
            if RemoveFogEnabled or UltraLowEnabled or FullBrightEnabled then
                ApplyVisualSettings()
            end
        end)
        task.wait(0.6)
    end
end)

VisualTab:Toggle({
    Title = "Low Graphics",
    Desc = "Boost FPS",
    Icon = "Moon",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            EnableLowGraphics()
        else
            DisableLowGraphics()
        end
    end
})

VisualTab:Toggle(
{
Flag = "AutoTab",
Title = "Black Screen",
Desc = "Toggle black screen (if you're eyes are burning)",
Icon = "moon",
Type = "Checkbox",
Value = false,
Callback = function(U)
if U then
if not Players.LocalPlayer.PlayerGui:FindFirstChild("BlackScreen") then
overlay = Instance.new("ScreenGui")
overlay.Name = "BlackScreen"
overlay.ResetOnSpawn = false
overlay.IgnoreGuiInset = true
overlay.Parent = Players.LocalPlayer.PlayerGui
frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.1
frame.ZIndex = 999
frame.Parent = overlay
end
else
overlay = Players.LocalPlayer.PlayerGui:FindFirstChild("BlackScreen")
if overlay then
overlay:Destroy()
end
end
end
}
)

VisualTab:Button({
    Flag = "AutoTab",
    Title = "Restore Graphics",
    Desc = "Restores default graphics settings",
    Icon = "refresh",
    Callback = function()
        RemoveFogEnabled = false
        EnableLowGraphics = false
        FullBrightEnabled = false
        ApplyVisualSettings()
        overlay = Players.LocalPlayer.PlayerGui:FindFirstChild("BlackScreen")
        if overlay then
            overlay:Destroy()
        end
    end
})

KA = KA or {}
KA.shader = KA.shader or {}

KA.Lighting = game:GetService("Lighting")
KA.RunService = game:GetService("RunService")
shaderTab = Window:Tab({ Title = "Shaders", Icon = "palette" })
shaderSection = shaderTab:Section({ Title = "Visual Shaders", Icon = "eye" })

KA.shader.enabled = KA.shader.enabled or false
KA.shader.current = KA.shader.current or "Yuletide Glow"
KA.shader.effects = KA.shader.effects or {}
KA.shader.customColors = KA.shader.customColors or {} 
KA.shader._originalLighting = KA.shader._originalLighting or {
    FogColor = KA.Lighting.FogColor,
    FogStart = KA.Lighting.FogStart,
    FogEnd = KA.Lighting.FogEnd,
    Ambient = KA.Lighting.Ambient,
    Brightness = KA.Lighting.Brightness,
    Atmosphere = nil
}
pcall(function()
    local atmos = KA.Lighting:FindFirstChildOfClass("Atmosphere")
    if atmos then
        KA.shader._originalLighting.Atmosphere = {
            Density = atmos.Density,
            Offset = atmos.Offset,
            Color = atmos.Color,
            Haze = atmos.Haze
        }
    end
end)

function KA.shader.safeDestroy(obj)
    pcall(function()
        if type(obj) == "table" and obj.Destroy then
            obj:Destroy()
        elseif typeof(obj) == "Instance" then
            if obj.Parent then obj.Parent = nil end
            if obj.Destroy then obj:Destroy() end
        end
    end)
end

function KA.shader:clear()
    for _, eff in ipairs(self.effects) do
        pcall(function() KA.shader.safeDestroy(eff) end)
    end
    self.effects = {}

    
    pcall(function()
        KA.Lighting.FogColor = KA.shader._originalLighting.FogColor
        KA.Lighting.FogStart = KA.shader._originalLighting.FogStart
        KA.Lighting.FogEnd = KA.shader._originalLighting.FogEnd
        KA.Lighting.Ambient = KA.shader._originalLighting.Ambient
        KA.Lighting.Brightness = KA.shader._originalLighting.Brightness
        local origAtm = KA.shader._originalLighting.Atmosphere
        if origAtm then
            local atmos = KA.Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
            atmos.Parent = KA.Lighting
            atmos.Density = origAtm.Density
            atmos.Offset = origAtm.Offset
            atmos.Color = origAtm.Color
            atmos.Haze = origAtm.Haze
        end
    end)
end

function KA.shader.newColorCorrection(opts)
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = opts.Name or "CC_Effect"
    cc.Saturation = (opts.Saturation ~= nil) and opts.Saturation or 0
    cc.Contrast = (opts.Contrast ~= nil) and opts.Contrast or 0
    cc.Brightness = (opts.Brightness ~= nil) and opts.Brightness or 0
    if opts.TintColor then pcall(function() cc.TintColor = opts.TintColor end) end
    return cc
end

function KA.shader.createFogGradient(colors, transitionTime, affectAmbient, ambientFactor)
    transitionTime = transitionTime or 6
    affectAmbient = (affectAmbient == nil) and true or affectAmbient
    ambientFactor = ambientFactor or 0.45

    local running = true
    local obj = {}

    local cols = {}
    for _, c in ipairs(colors) do
        if typeof(c) == "Color3" then table.insert(cols, c) end
    end
    if #cols == 0 then
        function obj.Destroy() running = false end
        return obj
    end

    local index, nextIndex, timeElapsed = 1, 2, 0
    task.spawn(function()
        while running and KA.RunService:IsRunning() do
            local dt = task.wait()
            if not dt then dt = 0.033 end
            timeElapsed = timeElapsed + dt
            local t = math.clamp(timeElapsed / transitionTime, 0, 1)
            local c0, c1 = cols[index], cols[nextIndex]
            local lerpColor = c0:Lerp(c1, t)
            pcall(function()
                KA.Lighting.FogColor = lerpColor
                if affectAmbient then
                    local ambient = lerpColor:Lerp(Color3.new(0,0,0), 1 - ambientFactor)
                    KA.Lighting.Ambient = ambient
                end
            end)
            if timeElapsed >= transitionTime then
                timeElapsed = 0
                index = index % #cols + 1
                nextIndex = index % #cols + 1
            end
        end
    end)

    function obj.Destroy() running = false end
    return obj
end

function KA.shader.createTintGradient(ccInstance, colors, transitionTime)
    if not ccInstance or not ccInstance:IsA("ColorCorrectionEffect") then
        return { Destroy = function() end }
    end
    transitionTime = transitionTime or 6
    local running = true
    local obj = {}
    local cols = {}
    for _, c in ipairs(colors) do if typeof(c) == "Color3" then table.insert(cols, c) end end
    if #cols == 0 then function obj.Destroy() running = false end return obj end

    local index, nextIndex, timeElapsed = 1, 2, 0
    task.spawn(function()
        while running and KA.RunService:IsRunning() do
            local dt = task.wait()
            if not dt then dt = 0.033 end
            timeElapsed = timeElapsed + dt
            local t = math.clamp(timeElapsed / transitionTime, 0, 1)
            local c0, c1 = cols[index], cols[nextIndex]
            pcall(function() ccInstance.TintColor = c0:Lerp(c1, t) end)
            if timeElapsed >= transitionTime then
                timeElapsed = 0
                index = index % #cols + 1
                nextIndex = index % #cols + 1
            end
        end
    end)

    function obj.Destroy() running = false end
    return obj
end

function KA.shader.createPropertyPulse(instance, propName, baseValue, amplitude, speed)
    if not instance then return { Destroy = function() end } end
    local running = true
    local obj = {}
    local t0 = tick()
    task.spawn(function()
        while running and KA.RunService:IsRunning() do
            local dt = task.wait()
            local t = (tick() - t0) * speed
            local factor = math.sin(t) * 0.5 + 0.5 
            local value = baseValue + (factor - 0.5) * 2 * amplitude
            pcall(function()
                instance[propName] = value
            end)
        end
    end)
    function obj.Destroy() running = false end
    return obj
end

KA.shader.settings = KA.shader.settings or {
    globalSpeed = 1.0,             
    ambientFactor = 0.45,          
    bloomMult = 1.0,
    blurMult = 1.0,
    sunMult = 1.0,
    animateFog = true,
    animateTint = true,
    animateEffects = true,
    presetSpeedOverrides = {},     
}

function KA.shader.effectiveTransitionTime(baseTime, presetName)
    local mult = 1 / math.max(0.01, KA.shader.settings.globalSpeed or 1)
    local override = KA.shader.settings.presetSpeedOverrides[presetName] or 1
    return math.clamp(baseTime * mult / override, 0.1, 120)
end

function KA.shader.presetColorsFor(name, defaultColors)
    KA.shader.customColors[name] = KA.shader.customColors[name] or defaultColors
    return KA.shader.customColors[name]
end

KA.shader.presets = {
    ["Yuletide Glow"] = function()
        local name = "Yuletide Glow"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(255, 245, 235),
            Color3.fromRGB(255, 220, 200),
            Color3.fromRGB(245, 255, 235),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = 0.35, Contrast = 0.15, Brightness = 0.05, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.5 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 24
        bloom.Threshold = 0.7

        pcall(function()
            KA.Lighting.FogStart = 0
            KA.Lighting.FogEnd = 2200
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.45))
        end)

        local effs = { cc, bloom }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(6, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(6, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, math.max(0.08, bloom.Intensity * 0.25), 1.0))
        end

        return effs
    end,

    ["Silent Snowfall"] = function()
        local name = "Silent Snowfall"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(235, 245, 255),
            Color3.fromRGB(220, 235, 255),
            Color3.fromRGB(245, 250, 255),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = -0.15, Contrast = 0.05, Brightness = -0.02, TintColor = colors[1] })
        local blur = Instance.new("BlurEffect")
        blur.Size = 2.5 * (KA.shader.settings.blurMult or 1)

        pcall(function()
            KA.Lighting.FogStart = 50
            KA.Lighting.FogEnd = 700
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.45))
        end)

        local effs = { cc, blur }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(8, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(8, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.3, blur.Size * 0.25), 0.8))
        end

        return effs
    end,

    ["Aurora Flux"] = function()
        local name = "Aurora Flux"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(60, 200, 200),
            Color3.fromRGB(120, 220, 140),
            Color3.fromRGB(160, 140, 255),
            Color3.fromRGB(120, 200, 255),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = 0.55, Contrast = 0.08, Brightness = 0.02, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.6 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 30
        bloom.Threshold = 0.65
        local sun = Instance.new("SunRaysEffect")
        sun.Intensity = 0.18 * (KA.shader.settings.sunMult or 1)
        sun.Spread = 0.3

        pcall(function()
            KA.Lighting.FogStart = 0
            KA.Lighting.FogEnd = 3000
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(60,90,110)
            KA.Lighting.Brightness = math.max(0.8, KA.Lighting.Brightness or 1)
        end)

        local effs = { cc, bloom, sun }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(6, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(6, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.3, 0.9))
            table.insert(effs, KA.shader.createPropertyPulse(sun, "Intensity", sun.Intensity, sun.Intensity * 0.25, 0.7))
        end

        return effs
    end,

    ["Void Ripple"] = function()
        local name = "Void Ripple"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(30, 8, 20),
            Color3.fromRGB(60, 10, 40),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = -0.5, Contrast = 0.7, Brightness = -0.25, TintColor = colors[1] })
        local blur = Instance.new("BlurEffect")
        blur.Size = 3.8 * (KA.shader.settings.blurMult or 1)

        pcall(function()
            KA.Lighting.FogStart = 0
            KA.Lighting.FogEnd = 600
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(10, 8, 12)
        end)

        local effs = { cc, blur }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(5.5, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(5.5, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.6, blur.Size * 0.3), 0.6))
        end

        return effs
    end,

    ["Chromatic Fracture"] = function()
        local name = "Chromatic Fracture"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(255,200,220),
            Color3.fromRGB(180,120,240),
            Color3.fromRGB(220,160,200),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = 0.9, Contrast = 0.25, Brightness = 0.03, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.55 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 18
        bloom.Threshold = 0.6
        local blur = Instance.new("BlurEffect")
        blur.Size = 1.6 * (KA.shader.settings.blurMult or 1)

        pcall(function()
            KA.Lighting.FogStart = 50
            KA.Lighting.FogEnd = 1500
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(100, 80, 120)
        end)

        local effs = { cc, bloom, blur }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(7, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(7, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.25, 1.1))
            table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.4, blur.Size * 0.25), 0.9))
        end

        return effs
    end,

    ["Neon Pulse Field"] = function()
        local name = "Neon Pulse Field"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(0,255,200),
            Color3.fromRGB(120,0,255),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = 1.0, Contrast = 0.15, Brightness = 0.08, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.9 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 40
        bloom.Threshold = 0.55

        pcall(function()
            KA.Lighting.FogStart = 0
            KA.Lighting.FogEnd = 1200
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(8, 22, 20)
        end)

        local effs = { cc, bloom }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(3.5, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(3.5, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.4, 1.6))
        end

        return effs
    end,

    ["Solar Bloom"] = function()
        local name = "Solar Bloom"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(255,210,140),
            Color3.fromRGB(255,240,200),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = 0.25, Contrast = 0.12, Brightness = 0.12, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.7 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 36
        bloom.Threshold = 0.75
        local sun = Instance.new("SunRaysEffect")
        sun.Intensity = 0.22 * (KA.shader.settings.sunMult or 1)
        sun.Spread = 0.35

        pcall(function()
            KA.Lighting.FogStart = 200
            KA.Lighting.FogEnd = 1800
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.45))
        end)

        local effs = { cc, bloom, sun }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(5, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(5, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.25, 0.85))
            table.insert(effs, KA.shader.createPropertyPulse(sun, "Intensity", sun.Intensity, sun.Intensity * 0.2, 0.7))
        end

        return effs
    end,

["Echo Distortion"] = function()
        local name = "Echo Distortion"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(120,120,140),
            Color3.fromRGB(140,120,150),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = -0.1, Contrast = 0.4, Brightness = -0.05, TintColor = colors[1] })
        local blur = Instance.new("BlurEffect")
        blur.Size = 5 * (KA.shader.settings.blurMult or 1)
        local dof = Instance.new("DepthOfFieldEffect")
        pcall(function()
            dof.FocusDistance = 50
            dof.InFocusRadius = 20
            dof.NearIntensity = 0.18
            dof.FarIntensity = 0.22
        end)

        pcall(function()
            KA.Lighting.FogStart = 10
            KA.Lighting.FogEnd = 900
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(80,80,90)
        end)

        local effs = { cc, blur, dof }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(6.5, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(6, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, math.max(0.08, bloom.Intensity * 0.25), 1.0))
        end

        return effs
    end,

    ["Silent Snowfall"] = function()
        local name = "Silent Snowfall"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(235, 245, 255),
            Color3.fromRGB(220, 235, 255),
            Color3.fromRGB(245, 250, 255),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = -0.15, Contrast = 0.05, Brightness = -0.02, TintColor = colors[1] })
        local blur = Instance.new("BlurEffect")
        blur.Size = 2.5 * (KA.shader.settings.blurMult or 1)

        pcall(function()
            KA.Lighting.FogStart = 50
            KA.Lighting.FogEnd = 700
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.45))
        end)

        local effs = { cc, blur }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(8, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(8, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.3, blur.Size * 0.25), 0.8))
        end

        return effs
    end,

    ["Aurora Flux"] = function()
        local name = "Aurora Flux"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(60, 200, 200),
            Color3.fromRGB(120, 220, 140),
            Color3.fromRGB(160, 140, 255),
            Color3.fromRGB(120, 200, 255),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = 0.55, Contrast = 0.08, Brightness = 0.02, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.6 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 30
        bloom.Threshold = 0.65
        local sun = Instance.new("SunRaysEffect")
        sun.Intensity = 0.18 * (KA.shader.settings.sunMult or 1)
        sun.Spread = 0.3

        pcall(function()
            KA.Lighting.FogStart = 0
            KA.Lighting.FogEnd = 3000
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(60,90,110)
            KA.Lighting.Brightness = math.max(0.8, KA.Lighting.Brightness or 1)
        end)

        local effs = { cc, bloom, sun }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(6, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(6, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.3, 0.9))
            table.insert(effs, KA.shader.createPropertyPulse(sun, "Intensity", sun.Intensity, sun.Intensity * 0.25, 0.7))
        end

        return effs
    end,

    ["Void Ripple"] = function()
        local name = "Void Ripple"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(30, 8, 20),
            Color3.fromRGB(60, 10, 40),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = -0.5, Contrast = 0.7, Brightness = -0.25, TintColor = colors[1] })
        local blur = Instance.new("BlurEffect")
        blur.Size = 3.8 * (KA.shader.settings.blurMult or 1)

        pcall(function()
            KA.Lighting.FogStart = 0
            KA.Lighting.FogEnd = 600
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(10, 8, 12)
        end)

        local effs = { cc, blur }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(5.5, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(5.5, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.6, blur.Size * 0.3), 0.6))
        end

        return effs
    end,

    ["Chromatic Fracture"] = function()
        local name = "Chromatic Fracture"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(255,200,220),
            Color3.fromRGB(180,120,240),
            Color3.fromRGB(220,160,200),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = 0.9, Contrast = 0.25, Brightness = 0.03, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.55 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 18
        bloom.Threshold = 0.6
        local blur = Instance.new("BlurEffect")
        blur.Size = 1.6 * (KA.shader.settings.blurMult or 1)

        pcall(function()
            KA.Lighting.FogStart = 50
            KA.Lighting.FogEnd = 1500
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(100, 80, 120)
        end)

        local effs = { cc, bloom, blur }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(7, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(7, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.25, 1.1))
            table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.4, blur.Size * 0.25), 0.9))
        end

        return effs
    end,

    ["Neon Pulse Field"] = function()
        local name = "Neon Pulse Field"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(0,255,200),
            Color3.fromRGB(120,0,255),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = 1.0, Contrast = 0.15, Brightness = 0.08, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.9 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 40
        bloom.Threshold = 0.55

        pcall(function()
            KA.Lighting.FogStart = 0
            KA.Lighting.FogEnd = 1200
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(8, 22, 20)
        end)

        local effs = { cc, bloom }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(3.5, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(3.5, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.4, 1.6))
        end

        return effs
    end,

    ["Solar Bloom"] = function()
        local name = "Solar Bloom"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(255,210,140),
            Color3.fromRGB(255,240,200),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = 0.25, Contrast = 0.12, Brightness = 0.12, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.7 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 36
        bloom.Threshold = 0.75
        local sun = Instance.new("SunRaysEffect")
        sun.Intensity = 0.22 * (KA.shader.settings.sunMult or 1)
        sun.Spread = 0.35

        pcall(function()
            KA.Lighting.FogStart = 200
            KA.Lighting.FogEnd = 1800
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.45))
        end)

        local effs = { cc, bloom, sun }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(5, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(5, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.25, 0.85))
            table.insert(effs, KA.shader.createPropertyPulse(sun, "Intensity", sun.Intensity, sun.Intensity * 0.2, 0.7))
        end

        return effs
    end,

["Echo Distortion"] = function()
        local name = "Echo Distortion"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(120,120,140),
            Color3.fromRGB(140,120,150),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = -0.1, Contrast = 0.4, Brightness = -0.05, TintColor = colors[1] })
        local blur = Instance.new("BlurEffect")
        blur.Size = 5 * (KA.shader.settings.blurMult or 1)
        local dof = Instance.new("DepthOfFieldEffect")
        pcall(function()
            dof.FocusDistance = 50
            dof.InFocusRadius = 20
            dof.NearIntensity = 0.18
            dof.FarIntensity = 0.22
        end)

        pcall(function()
            KA.Lighting.FogStart = 10
            KA.Lighting.FogEnd = 900
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(80,80,90)
        end)

        local effs = { cc, blur, dof }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(6.5, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(6.5, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, blur.Size * 0.25, 0.5))
        end

        return effs
    end,

    ["Crystal Refraction"] = function()
        local name = "Crystal Refraction"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(200,235,255),
            Color3.fromRGB(180,220,245),
            Color3.fromRGB(210,240,255),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = 0.65, Contrast = 0.05, Brightness = 0.06, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.45 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 22
        bloom.Threshold = 0.7

        pcall(function()
            KA.Lighting.FogStart = 0
            KA.Lighting.FogEnd = 2500
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(140,160,175)
        end)

        local effs = { cc, bloom }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(7.5, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(7.5, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.2, 0.7))
        end

        return effs
    end,

    ["Obsidian Heatwave"] = function()
        local name = "Obsidian Heatwave"
        local colors = KA.shader.presetColorsFor(name, {
            Color3.fromRGB(120,60,70),
            Color3.fromRGB(190,100,80),
        })
        local cc = KA.shader.newColorCorrection({ Saturation = -0.25, Contrast = 0.6, Brightness = -0.08, TintColor = colors[1] })
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.35 * (KA.shader.settings.bloomMult or 1)
        bloom.Size = 16
        bloom.Threshold = 0.85
        local blur = Instance.new("BlurEffect")
        blur.Size = 1.8 * (KA.shader.settings.blurMult or 1)

        pcall(function()
            KA.Lighting.FogStart = 0
            KA.Lighting.FogEnd = 900
            KA.Lighting.FogColor = colors[1]
            KA.Lighting.Ambient = Color3.fromRGB(80,50,50)
        end)

        local effs = { cc, bloom, blur }
        if KA.shader.settings.animateFog then
            table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(6.2, name), true, KA.shader.settings.ambientFactor))
        end
        if KA.shader.settings.animateTint then
            table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(6.2, name)))
        end
        if KA.shader.settings.animateEffects then
            table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.2, 0.6))
            table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, blur.Size * 0.2, 0.6))
        end

        return effs
    end,
}

KA.shader.presets["Golden Hour Meadow"] = function()
    local name = "Golden Hour Meadow"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(252, 182, 84),  
        Color3.fromRGB(219, 141, 72),  
        Color3.fromRGB(243, 215, 176), 
    })
    local cc = KA.shader.newColorCorrection({
        Saturation = 0.35,
        Contrast = 0.12,
        Brightness = 0.05,
        TintColor = colors[1]
    })
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.58 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 28
    bloom.Threshold = 0.68
    local sun = Instance.new("SunRaysEffect")
    sun.Intensity = 0.18 * (KA.shader.settings.sunMult or 1)
    sun.Spread = 0.32

    pcall(function()
        KA.Lighting.FogStart = 0
        KA.Lighting.FogEnd = 1200
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.5))
        KA.Lighting.Brightness = math.max(0.9, KA.Lighting.Brightness or 1)
    end)

    local effs = { cc, bloom, sun }
    if KA.shader.settings.animateFog then
        table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(7.5, name), true, KA.shader.settings.ambientFactor))
    end
    if KA.shader.settings.animateTint then
        table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(7.5, name)))
    end
    if KA.shader.settings.animateEffects then
        table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.20, 0.9))
        table.insert(effs, KA.shader.createPropertyPulse(sun, "Intensity", sun.Intensity, sun.Intensity * 0.18, 0.6))
    end

    return effs
end

KA.shader.presets["Sunlit Keep"] = function()
    local name = "Sunlit Keep"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(238, 172, 92),  
        Color3.fromRGB(168, 103, 62),  
        Color3.fromRGB(96, 62, 46),    
    })
    local cc = KA.shader.newColorCorrection({
        Saturation = 0.28,
        Contrast = 0.18,
        Brightness = 0.06,
        TintColor = colors[1]
    })
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.64 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 34
    bloom.Threshold = 0.66
    local dof = Instance.new("DepthOfFieldEffect")
    pcall(function()
        dof.FocusDistance = 60
        dof.InFocusRadius = 22
        dof.NearIntensity = 0.12
        dof.FarIntensity = 0.18
    end)

    pcall(function()
        KA.Lighting.FogStart = 80
        KA.Lighting.FogEnd = 2000
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = colors[2]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.5))
    end)

    local effs = { cc, bloom, dof }
    if KA.shader.settings.animateFog then
        table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(8.5, name), true, KA.shader.settings.ambientFactor))
    end
    if KA.shader.settings.animateTint then
        table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(8.5, name)))
    end
    if KA.shader.settings.animateEffects then
        table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.22, 0.85))
    end

    return effs
end

KA.shader.presets["Warm Sepia Tapestry"] = function()
    local name = "Warm Sepia Tapestry"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(207, 155, 102), 
        Color3.fromRGB(159, 107, 70),  
        Color3.fromRGB(236, 212, 183), 
    })
    local cc = KA.shader.newColorCorrection({
        Saturation = 0.02,
        Contrast = 0.20,
        Brightness = 0.02,
        TintColor = colors[1]
    })
    local blur = Instance.new("BlurEffect")
    blur.Size = 2.0 * (KA.shader.settings.blurMult or 1)

    pcall(function()
        KA.Lighting.FogStart = 10
        KA.Lighting.FogEnd = 1300
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.5))
    end)

    local effs = { cc, blur }
    if KA.shader.settings.animateFog then
        table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(9, name), true, KA.shader.settings.ambientFactor))
    end
    if KA.shader.settings.animateTint then
        table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(9, name)))
    end
    if KA.shader.settings.animateEffects then
        table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.4, blur.Size * 0.2), 0.5))
    end

    return effs
end

KA.shader.presets["Olden Library — Golden"] = function()
    local name = "Olden Library — Golden"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(215, 178, 124), 
        Color3.fromRGB(130, 86, 56),   
        Color3.fromRGB(88, 64, 52),    
    })
    local cc = KA.shader.newColorCorrection({
        Saturation = 0.18,
        Contrast = 0.10,
        Brightness = 0.03,
        TintColor = colors[1]
    })
    local dof = Instance.new("DepthOfFieldEffect")
    pcall(function()
        dof.FocusDistance = 55
        dof.InFocusRadius = 16
        dof.NearIntensity = 0.10
        dof.FarIntensity = 0.16
    end)
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.44 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 22
    bloom.Threshold = 0.74

    pcall(function()
        KA.Lighting.FogStart = 18
        KA.Lighting.FogEnd = 900
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = colors[3]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.5))
    end)

    local effs = { cc, dof, bloom }
    if KA.shader.settings.animateFog then
        table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(7, name), true, KA.shader.settings.ambientFactor))
    end
    if KA.shader.settings.animateTint then
        table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(7, name)))
    end
    if KA.shader.settings.animateEffects then
        table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.18, 0.7))
    end

    return effs
end

KA.shader.presets["Gilded Bastion"] = function()
    local name = "Gilded Bastion"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(225, 160, 88),  
        Color3.fromRGB(156, 98, 56),   
        Color3.fromRGB(100, 70, 50),   
    })
    local cc = KA.shader.newColorCorrection({
        Saturation = 0.40,
        Contrast = 0.14,
        Brightness = 0.04,
        TintColor = colors[1]
    })
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.54 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 30
    bloom.Threshold = 0.70
    local blur = Instance.new("BlurEffect")
    blur.Size = 1.4 * (KA.shader.settings.blurMult or 1)

    pcall(function()
        KA.Lighting.FogStart = 0
        KA.Lighting.FogEnd = 1100
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = colors[2]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.5))
    end)

    local effs = { cc, bloom, blur }
    if KA.shader.settings.animateFog then
        table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(6, name), true, KA.shader.settings.ambientFactor))
    end
    if KA.shader.settings.animateTint then
        table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(6, name)))
    end
    if KA.shader.settings.animateEffects then
        table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.20, 1.0))
        table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.25, blur.Size * 0.18), 0.6))
    end

    return effs
end

KA.shader.presets["Cinematic Golden Hour"] = function()
    local name = "Cinematic Golden Hour"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(255,176,72), 
        Color3.fromRGB(220,125,60), 
        Color3.fromRGB(245,220,180), 
    })
    local cc = KA.shader.newColorCorrection({ Saturation = 0.42, Contrast = 0.14, Brightness = 0.06, TintColor = colors[1] })
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.78 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 36
    bloom.Threshold = 0.62
    local sun = Instance.new("SunRaysEffect")
    sun.Intensity = 0.26 * (KA.shader.settings.sunMult or 1)
    sun.Spread = 0.36
    local dof = Instance.new("DepthOfFieldEffect")
    pcall(function()
        dof.FocusDistance = 65
        dof.InFocusRadius = 20
        dof.NearIntensity = 0.10
        dof.FarIntensity = 0.18
    end)

    pcall(function()
        KA.Lighting.FogStart = 0
        KA.Lighting.FogEnd = 1300
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.5))
        KA.Lighting.Brightness = math.max(0.95, KA.Lighting.Brightness or 1)
    end)

    local effs = { cc, bloom, sun, dof }
    if KA.shader.settings.animateFog then table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(7.0, name), true, KA.shader.settings.ambientFactor)) end
    if KA.shader.settings.animateTint then table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(7.0, name))) end
    if KA.shader.settings.animateEffects then
        table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.20, 0.8))
        table.insert(effs, KA.shader.createPropertyPulse(sun, "Intensity", sun.Intensity, sun.Intensity * 0.18, 0.6))
    end
    return effs
end

KA.shader.presets["Ethereal Bloom"] = function()
    local name = "Ethereal Bloom"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(255,210,185),
        Color3.fromRGB(240,185,160),
        Color3.fromRGB(255,235,220),
    })
    local cc = KA.shader.newColorCorrection({ Saturation = 0.28, Contrast = 0.08, Brightness = 0.08, TintColor = colors[1] })
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.9 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 44
    bloom.Threshold = 0.72
    local blur = Instance.new("BlurEffect")
    blur.Size = 2.8 * (KA.shader.settings.blurMult or 1)

    pcall(function()
        KA.Lighting.FogStart = 0
        KA.Lighting.FogEnd = 900
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.55))
    end)

    local effs = { cc, bloom, blur }
    if KA.shader.settings.animateFog then table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(6.5, name), true, KA.shader.settings.ambientFactor)) end
    if KA.shader.settings.animateTint then table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(6.5, name))) end
    if KA.shader.settings.animateEffects then
        table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.30, 1.1))
        table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.5, blur.Size * 0.25), 0.9))
    end
    return effs
end

KA.shader.presets["Vintage Film"] = function()
    local name = "Vintage Film"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(210,170,120),
        Color3.fromRGB(150,110,80),
        Color3.fromRGB(235,215,190),
    })
    local cc = KA.shader.newColorCorrection({ Saturation = -0.05, Contrast = 0.32, Brightness = -0.02, TintColor = colors[1] })
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.36 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 22
    bloom.Threshold = 0.78
    local blur = Instance.new("BlurEffect")
    blur.Size = 1.2 * (KA.shader.settings.blurMult or 1)

    pcall(function()
        KA.Lighting.FogStart = 20
        KA.Lighting.FogEnd = 1400
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = Color3.fromRGB(80,70,60)
    end)

    local effs = { cc, bloom, blur }
    if KA.shader.settings.animateFog then table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(9.0, name), true, KA.shader.settings.ambientFactor)) end
    if KA.shader.settings.animateTint then table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(9.0, name))) end
    if KA.shader.settings.animateEffects then table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.3, blur.Size * 0.2), 0.5)) end
    return effs
end

KA.shader.presets["Volcanic Twilight"] = function()
    local name = "Volcanic Twilight"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(200,80,45),  
        Color3.fromRGB(90,30,28),   
        Color3.fromRGB(120,60,36),  
    })
    local cc = KA.shader.newColorCorrection({ Saturation = 0.1, Contrast = 0.48, Brightness = -0.08, TintColor = colors[1] })
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.42 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 20
    bloom.Threshold = 0.6
    local blur = Instance.new("BlurEffect")
    blur.Size = 3.6 * (KA.shader.settings.blurMult or 1)

    pcall(function()
        KA.Lighting.FogStart = 0
        KA.Lighting.FogEnd = 700
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = Color3.fromRGB(40,32,30)
    end)

    local effs = { cc, bloom, blur }
    if KA.shader.settings.animateFog then table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(5.5, name), true, KA.shader.settings.ambientFactor)) end
    if KA.shader.settings.animateTint then table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(5.5, name))) end
    if KA.shader.settings.animateEffects then
        table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.6, blur.Size * 0.28), 0.7))
    end
    return effs
end

KA.shader.presets["Crystal Clarity"] = function()
    local name = "Crystal Clarity"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(200,230,245), 
        Color3.fromRGB(170,200,220), 
        Color3.fromRGB(90,110,125),   
    })
    local cc = KA.shader.newColorCorrection({ Saturation = 0.28, Contrast = 0.22, Brightness = 0.06, TintColor = colors[1] })
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.44 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 18
    bloom.Threshold = 0.7
    local dof = Instance.new("DepthOfFieldEffect")
    pcall(function()
        dof.FocusDistance = 72
        dof.InFocusRadius = 14
        dof.NearIntensity = 0.08
        dof.FarIntensity = 0.12
    end)
    pcall(function()
        KA.Lighting.FogStart = 0
        KA.Lighting.FogEnd = 2000
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = Color3.fromRGB(95,110,120)
    end)

    local effs = { cc, bloom, dof }
    if KA.shader.settings.animateFog then table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(10.0, name), true, KA.shader.settings.ambientFactor)) end
    if KA.shader.settings.animateTint then table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(10.0, name))) end
    return effs
end

KA.shader.presets["Nocturne Glow"] = function()
    local name = "Nocturne Glow"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(36,58,80),
        Color3.fromRGB(72,96,120),
        Color3.fromRGB(18,28,40),
    })
    local cc = KA.shader.newColorCorrection({ Saturation = 0.65, Contrast = 0.12, Brightness = -0.06, TintColor = colors[1] })
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.9 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 46
    bloom.Threshold = 0.56
    local sun = Instance.new("SunRaysEffect")
    sun.Intensity = 0.12 * (KA.shader.settings.sunMult or 1)
    sun.Spread = 0.22

    pcall(function()
        KA.Lighting.FogStart = 0
        KA.Lighting.FogEnd = 900
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 0.85)
        KA.Lighting.Brightness = math.min(0.9, KA.Lighting.Brightness or 1)
    end)

    local effs = { cc, bloom, sun }
    if KA.shader.settings.animateFog then table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(6.8, name), true, KA.shader.settings.ambientFactor)) end
    if KA.shader.settings.animateTint then table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(6.8, name))) end
    if KA.shader.settings.animateEffects then table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.35, 1.3)) end
    return effs
end

KA.shader.presets["Painterly Pastel"] = function()
    local name = "Painterly Pastel"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(255,198,170),
        Color3.fromRGB(220,170,150),
        Color3.fromRGB(245,230,215),
    })
    local cc = KA.shader.newColorCorrection({ Saturation = 0.6, Contrast = 0.05, Brightness = 0.06, TintColor = colors[1] })
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.5 * (KA.shader.settings.bloomMult or 1)
    bloom.Size = 30
    bloom.Threshold = 0.72
    local blur = Instance.new("BlurEffect")
    blur.Size = 2.0 * (KA.shader.settings.blurMult or 1)

    pcall(function()
        KA.Lighting.FogStart = 0
        KA.Lighting.FogEnd = 1400
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = colors[1]:Lerp(Color3.new(0,0,0), 1 - (KA.shader.settings.ambientFactor or 0.5))
    end)

    local effs = { cc, bloom, blur }
    if KA.shader.settings.animateFog then table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(7.8, name), true, KA.shader.settings.ambientFactor)) end
    if KA.shader.settings.animateTint then table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(7.8, name))) end
    if KA.shader.settings.animateEffects then
        table.insert(effs, KA.shader.createPropertyPulse(bloom, "Intensity", bloom.Intensity, bloom.Intensity * 0.18, 0.75))
    end
    return effs
end

KA.shader.presets["High-Contrast Noir"] = function()
    local name = "High-Contrast Noir"
    local colors = KA.shader.presetColorsFor(name, {
        Color3.fromRGB(32,32,32),
        Color3.fromRGB(10,10,12),
        Color3.fromRGB(68,64,60),
    })
    local cc = KA.shader.newColorCorrection({ Saturation = -0.35, Contrast = 0.75, Brightness = -0.18, TintColor = colors[1] })
    local blur = Instance.new("BlurEffect")
    blur.Size = 1.0 * (KA.shader.settings.blurMult or 1)
    pcall(function()
        KA.Lighting.FogStart = 0
        KA.Lighting.FogEnd = 600
        KA.Lighting.FogColor = colors[1]
        KA.Lighting.Ambient = Color3.fromRGB(10,10,12)
        KA.Lighting.Brightness = math.max(0.6, KA.Lighting.Brightness or 1)
    end)

    local effs = { cc, blur }
    if KA.shader.settings.animateFog then table.insert(effs, KA.shader.createFogGradient(colors, KA.shader.effectiveTransitionTime(5.0, name), true, KA.shader.settings.ambientFactor)) end
    if KA.shader.settings.animateTint then table.insert(effs, KA.shader.createTintGradient(cc, colors, KA.shader.effectiveTransitionTime(5.0, name))) end
    if KA.shader.settings.animateEffects then table.insert(effs, KA.shader.createPropertyPulse(blur, "Size", blur.Size, math.max(0.25, blur.Size * 0.18), 0.5)) end
    return effs
end

function KA.shader:apply(name)
    self:clear()
    local preset = self.presets[name]
    if not preset then return end
    local effects = preset()
    for _, eff in ipairs(effects) do
        pcall(function()
            if typeof(eff) == "Instance" or (type(eff) == "table" and eff.ClassName) then
                eff.Parent = KA.Lighting
                table.insert(self.effects, eff)
            else
                table.insert(self.effects, eff)
            end
        end)
    end
    self.current = name
end

KA = KA or {}
KA.shader = KA.shader or {}

KA.shader.settings = KA.shader.settings or {
    globalSpeed = 1.0,
    ambientFactor = 0.45,
    bloomMult = 1.0,
    blurMult = 1.0,
    sunMult = 1.0,
    animateFog = true,
    animateTint = true,
    animateEffects = true,
    presetSpeedOverrides = {},
}

if typeof(KA.shader.settings) ~= "table" then KA.shader.settings = {} end
if typeof(KA.shader.settings.presetSpeedOverrides) ~= "table" then KA.shader.settings.presetSpeedOverrides = {} end

KA.shader.customColors = KA.shader.customColors or {}
KA.shader.effects = KA.shader.effects or {}
KA.shader.enabled = KA.shader.enabled or false
KA.shader.current = KA.shader.current or "Yuletide Glow"
KA.shader.editTarget = KA.shader.editTarget or KA.shader.current

presetNames = {}
for n, _ in pairs(KA.shader.presets or {}) do
    table.insert(presetNames, n)
end
table.sort(presetNames)

shaderSection:Dropdown({
    Title = "Shader Preset",
    Desc = "Select a visual shader preset",
    Values = presetNames,
    Value = KA.shader.current,
    Multi = false,
    Callback = function(value)
        KA.shader.current = value
        if KA.shader.enabled then KA.shader:apply(value) end
    end
})

shaderSection:Toggle({
    Title = "Enable Shader",
    Desc = "Apply the selected shader preset",
    Value = KA.shader.enabled,
    Callback = function(state)
        KA.shader.enabled = state
        if state then
            KA.shader:apply(KA.shader.current or presetNames[1])
        else
            KA.shader:clear()
        end
    end
})

settingsSection = shaderTab:Section({ Title = "Shader Settings", Icon = "settings" })

function KA.shader.addSlider(opts)
    pcall(function() settingsSection:Slider(opts) end)
end

KA.shader.addSlider({
    Title = "Global Animation Speed",
    Desc = "Higher = faster; affects all gradient cycles",
    Step = 0.05,
    Value = {
        Min = 0.2,
        Max = 3,
        Default = KA.shader.settings.globalSpeed or 1.0,
    },
    Callback = function(v)
        KA.shader.settings.globalSpeed = v
        if KA.shader.enabled then KA.shader:apply(KA.shader.current) end
    end
})

KA.shader.addSlider({
    Title = "Ambient Influence",
    Desc = "How much ambient follows fog color",
    Step = 0.01,
    Value = {
        Min = 0,
        Max = 1,
        Default = KA.shader.settings.ambientFactor or 0.45,
    },
    Callback = function(v)
        KA.shader.settings.ambientFactor = v
        if KA.shader.enabled then KA.shader:apply(KA.shader.current) end
    end
})

KA.shader.addSlider({
    Title = "Bloom Multiplier",
    Desc = "Scale bloom intensity globally",
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 3,
        Default = KA.shader.settings.bloomMult or 1.0,
    },
    Callback = function(v)
        KA.shader.settings.bloomMult = v
        if KA.shader.enabled then KA.shader:apply(KA.shader.current) end
    end
})

KA.shader.addSlider({
    Title = "Blur Multiplier",
    Desc = "Scale blur sizes globally",
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 3,
        Default = KA.shader.settings.blurMult or 1.0,
    },
    Callback = function(v)
        KA.shader.settings.blurMult = v
        if KA.shader.enabled then KA.shader:apply(KA.shader.current) end
    end
})

KA.shader.addSlider({
    Title = "Sun/Bloom Multiplier",
    Desc = "Scale sun/bloom intensity",
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 3,
        Default = KA.shader.settings.sunMult or 1.0,
    },
    Callback = function(v)
        KA.shader.settings.sunMult = v
        if KA.shader.enabled then KA.shader:apply(KA.shader.current) end
    end
})
settingsSection:Divider()

settingsSection:Toggle({
    Title = "Animate Fog",
    Desc = "Enable fog color gradients",
    Value = KA.shader.settings.animateFog,
    Callback = function(v)
        KA.shader.settings.animateFog = v
        if KA.shader.enabled then KA.shader:apply(KA.shader.current) end
    end
})

settingsSection:Toggle({
    Title = "Animate Tint",
    Desc = "Animate ColorCorrection tint",
    Value = KA.shader.settings.animateTint,
    Callback = function(v)
        KA.shader.settings.animateTint = v
        if KA.shader.enabled then KA.shader:apply(KA.shader.current) end
    end
})

settingsSection:Toggle({
    Title = "Animate Effects",
    Desc = "Pulse bloom/blur/sun values",
    Value = KA.shader.settings.animateEffects,
    Callback = function(v)
        KA.shader.settings.animateEffects = v
        if KA.shader.enabled then KA.shader:apply(KA.shader.current) end
    end
})
settingsSection:Divider()

KA.shader.editTarget = KA.shader.editTarget or KA.shader.current
settingsSection:Dropdown({
    Title = "Preset to Edit",
    Desc = "Choose which shader to edit",
    Values = presetNames,
    Value = KA.shader.editTarget,
    Multi = false,
    Callback = function(v) KA.shader.editTarget = v end
})

settingsSection:Slider({
    Title = "Preset Speed Override",
    Desc = "Multiplier applied to this shaders anim speed",
    Step = 0.05,
    Value = {
        Min = 0.1,
        Max = 3,
        Default = (KA.shader.settings.presetSpeedOverrides and KA.shader.settings.presetSpeedOverrides[KA.shader.current]) or 1,
    },
    Callback = function(v)
        KA.shader.settings.presetSpeedOverrides = KA.shader.settings.presetSpeedOverrides or {}
        KA.shader.settings.presetSpeedOverrides[KA.shader.editTarget] = v
        if KA.shader.enabled then KA.shader:apply(KA.shader.current) end
    end
})

settingsSection:Divider()

pcall(function()
    if script and KA.shader and KA.shader.effects and #KA.shader.effects > 0 and KA.shader.clear then
        KA.shader:clear()
    end
end)

ContTab = Window:Tab({
    Title = "Contributors",
    Icon  = "hand-heart",
})

ContTab:Paragraph({
    Title = " Contributors",
    Desc  = "Lovely devs who worked hard to make this script happen.\nBig thanks to everyone involved! ",
})

ContTab:Divider()

ContTab:Paragraph({
    Title = " @marsh_mall00w",
    Desc  = "Main Developer\n• Core systems\n• Script architecture\n• Optimization",
})

ContTab:Divider()

ContTab:Paragraph({
    Title = " @swvn.xu",
    Desc  = "Helper Developer\n• Features support\n• Bug fixes\n• Testing",
})

ContTab:Divider()

ContTab:Paragraph({
    Title = " Thank You!",
    Desc  = "This project wouldn’t be possible without these amazing people ",
})

return AutoQuest

-- end of script
