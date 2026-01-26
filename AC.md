# Anti-Cheat Detection Best Practices

A collection of techniques and methods for identifying and analyzing anti-cheat systems in Roblox games.

---

## Table of Contents

1. [Executor Compatibility](#executor-compatibility)
2. [Detection Methods](#detection-methods)
3. [Common Anti-Cheat Patterns](#common-anti-cheat-patterns)
4. [Obfuscation Detection](#obfuscation-detection)
5. [Known AC Systems](#known-ac-systems)
6. [Scanning Techniques](#scanning-techniques)
7. [Dynamic Analysis](#dynamic-analysis)
8. [Bypass Strategies](#bypass-strategies)
9. [Advanced Techniques](#advanced-techniques)
10. [Anti-Anti-Cheat Detection](#anti-anti-cheat-detection)
11. [Scanning Workflow](#scanning-workflow)
12. [Failure & Recovery](#failure--recovery)
13. [Red Flags & Indicators](#red-flags--indicators)
14. [Tools & Scripts](#tools--scripts)

---

## Executor Compatibility

Understanding which functions work on which executors is critical for reliable AC analysis.

### Function Availability Matrix

| Function | Synapse X | Fluxus | KRNL | Script-Ware | Solara | Delta |
|----------|-----------|--------|------|-------------|--------|-------|
| `hookfunction` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `hookmetamethod` | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ |
| `newcclosure` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `getrawmetatable` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `setreadonly` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `getconnections` | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |
| `decompile` | ✅ | ⚠️ | ✅ | ✅ | ❌ | ❌ |
| `getgc` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `getupvalue/setupvalue` | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |
| `getconstant/setconstant` | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ |
| `getinfo` (debug) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `checkcaller` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `getnamecallmethod` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `iscclosure` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `getscriptclosure` | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ |
| `clonefunction` | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |

**Legend:** ✅ Full support | ⚠️ Partial/buggy | ❌ Not available

### Executor-Specific Globals

```lua
-- Detect which executor is running
local function getExecutor()
    if syn then return "Synapse X" end
    if fluxus then return "Fluxus" end
    if KRNL_LOADED then return "KRNL" end
    if Solara then return "Solara" end
    if Delta then return "Delta" end
    if getexecutorname then return getexecutorname() end
    return "Unknown"
end
```

### Compatibility Wrapper

```lua
-- Universal hook function that works across executors
local function universalHook(func, hook)
    if hookmetamethod and type(func) == "userdata" then
        return hookmetamethod(func, "__call", hook)
    elseif hookfunction then
        return hookfunction(func, newcclosure and newcclosure(hook) or hook)
    else
        error("No hook function available")
    end
end

-- Safe decompile with fallback
local function safeDecompile(script)
    if decompile then
        local success, source = pcall(decompile, script)
        if success then return source end
    end
    
    if getscriptbytecode then
        local success, bytecode = pcall(getscriptbytecode, script)
        if success then return "[BYTECODE] " .. #bytecode .. " bytes" end
    end
    
    return nil
end

-- Safe getconnections
local function safeGetConnections(signal)
    if not getconnections then
        return {}
    end
    
    local success, conns = pcall(getconnections, signal)
    return success and conns or {}
end
```

### Executor Behavior Differences

#### hookfunction vs hookmetamethod
```lua
-- hookfunction: Replaces function directly
-- Works on: Lua functions, C functions (with newcclosure)
hookfunction(print, newcclosure(function(...)
    -- Custom implementation
end))

-- hookmetamethod: Hooks metamethods on userdata
-- More powerful but less compatible
hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    -- Custom implementation
end))
```

#### Connection Object Differences
```lua
-- Synapse/KRNL: Full connection info
local conn = getconnections(event)[1]
conn.Function -- The actual function
conn.Thread   -- The thread (Synapse only)
conn.Fire     -- Can fire the connection
conn:Disable() -- Disable connection
conn:Enable()  -- Re-enable connection

-- Fluxus/Others: Limited info
local conn = getconnections(event)[1]
conn.Function -- May be nil or limited
conn:Disable() -- Usually works
```

---

## Detection Methods

### Script Analysis

#### Finding AC Scripts
```lua
-- Search for anti-cheat keywords in script names
local keywords = {"anti", "cheat", "exploit", "security", "guard", "protect", "detect", "ban", "kick", "validate"}

for _, obj in pairs(game:GetDescendants()) do
    if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
        local name = obj.Name:lower()
        for _, keyword in pairs(keywords) do
            if name:find(keyword) then
                print("[FOUND] " .. obj:GetFullName())
            end
        end
    end
end
```

#### Decompiling & Analyzing Scripts
```lua
-- Get script source (requires executor with decompiler)
local source = decompile(script)

-- Look for these patterns in decompiled code:
-- 1. RemoteEvent:FireServer() calls with player data
-- 2. Heartbeat/RenderStepped connections
-- 3. GetPropertyChangedSignal on HumanoidRootPart
-- 4. Magnitude calculations between positions
-- 5. raycast() calls for collision detection
```

#### Tracing Script Origins
```lua
-- Find where a script was required from
local oldRequire = require
require = function(module)
    print("[REQUIRE] " .. tostring(module) .. " from " .. debug.traceback())
    return oldRequire(module)
end
```

### Memory Scanning

#### Detecting Integrity Checks
```lua
-- Monitor for scripts checking their own source
local oldGetfenv = getfenv
getfenv = newcclosure(function(...)
    print("[GETFENV CALLED] " .. debug.traceback())
    return oldGetfenv(...)
end)

-- Monitor string manipulation (often used for hash checks)
local oldSub = string.sub
string.sub = newcclosure(function(str, ...)
    if #str > 1000 then -- Likely checking script source
        print("[LARGE STRING.SUB] Possible integrity check")
    end
    return oldSub(str, ...)
end)
```

#### Metamethod Hook Detection
```lua
-- Check if game's metamethods are hooked
local mt = getrawmetatable(game)
print("__index type:", type(rawget(mt, "__index")))
print("__namecall type:", type(rawget(mt, "__namecall")))

-- Compare against known original references
-- Hooked functions often return "function" instead of expected behavior
```

### Network Analysis

#### Remote Event Monitoring
```lua
-- Hook all RemoteEvent communications
local oldFireServer = Instance.new("RemoteEvent").FireServer
hookfunction(oldFireServer, function(self, ...)
    local args = {...}
    print("[FIRE SERVER]", self:GetFullName())
    for i, v in pairs(args) do
        print("  Arg " .. i .. ":", typeof(v), v)
    end
    return oldFireServer(self, ...)
end)
```

#### Remote Spy Implementation
```lua
-- Comprehensive remote spy
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" or method == "InvokeServer" then
        print(string.format("[%s] %s", method, self:GetFullName()))
        for i, v in ipairs(args) do
            print(string.format("  [%d] %s: %s", i, typeof(v), tostring(v)))
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
```

---

## Common Anti-Cheat Patterns

### Client-Side Checks

#### Speed Detection
```lua
-- How ACs detect speed hacks:
-- They track position over time and calculate velocity

-- Detection code pattern:
local lastPos = HRP.Position
local lastTime = tick()

RunService.Heartbeat:Connect(function()
    local currentPos = HRP.Position
    local currentTime = tick()
    local delta = (currentPos - lastPos).Magnitude
    local timeDelta = currentTime - lastTime
    local speed = delta / timeDelta
    
    if speed > MAX_ALLOWED_SPEED then
        -- Flag player
    end
    
    lastPos = currentPos
    lastTime = currentTime
end)
```

#### Teleport Detection
```lua
-- Pattern: Large position changes in single frame
-- Detection threshold usually 50-100 studs

-- They check:
-- 1. Position delta per frame
-- 2. No valid path between points (raycast)
-- 3. Humanoid state wasn't jumping/falling
```

#### Fly Detection
```lua
-- Patterns ACs use:
-- 1. Check if player Y position stays constant while not on ground
-- 2. Monitor HumanoidState for abnormal Flying state
-- 3. Raycast downward - if no hit within X studs, flag

-- Detection code pattern:
local function isGrounded()
    local ray = workspace:Raycast(HRP.Position, Vector3.new(0, -10, 0), params)
    return ray ~= nil
end

if not isGrounded() and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
    -- Suspicious
end
```

#### Noclip Detection
```lua
-- Pattern: Player inside solid parts

-- Detection methods:
-- 1. GetPartsInPart() on player hitbox
-- 2. Raycast from last valid position to current
-- 3. Check CanCollide parts overlapping character

local parts = workspace:GetPartsInPart(character.HumanoidRootPart)
for _, part in pairs(parts) do
    if part.CanCollide and not part:IsDescendantOf(character) then
        -- Player is inside a solid part
    end
end
```

### Server-Side Validation

#### Movement Sanity Checks
```lua
-- Server validates client-reported positions
-- They compare against:
-- 1. Physics simulation limits
-- 2. Time since last update
-- 3. Maximum possible distance traveled

-- Red flags on server:
-- - Position updates faster than Heartbeat
-- - Distance exceeds walkspeed * deltaTime * buffer
-- - Y position changes without jump input
```

#### Action Rate Limiting
```lua
-- Pattern: Track remote calls per second
local playerCalls = {}

RemoteEvent.OnServerEvent:Connect(function(player, ...)
    playerCalls[player] = (playerCalls[player] or 0) + 1
    
    if playerCalls[player] > MAX_CALLS_PER_SECOND then
        -- Kick or flag player
    end
end)

-- Reset counts periodically
while true do
    wait(1)
    playerCalls = {}
end
```

### Environment Checks

#### Executor Detection Methods
```lua
-- ACs check for executor-specific globals:
local suspiciousGlobals = {
    "syn", "fluxus", "KRNL", "getexecutorname",
    "hookfunction", "hookmetamethod", "newcclosure",
    "getrawmetatable", "setreadonly", "checkcaller",
    "getcallingscript", "getgenv", "getrenv", "getreg",
    "getgc", "getinstances", "getnilinstances", "fireclickdetector",
    "firetouchinterest", "getconnections", "setupvalue", "getupvalue"
}

for _, global in pairs(suspiciousGlobals) do
    if getfenv()[global] or _G[global] or shared[global] then
        -- Executor detected
    end
end
```

#### Function Identity Checks
```lua
-- ACs compare function references to detect hooks

-- They store original references at start:
local originalPrint = print
local originalWarn = warn

-- Then periodically check:
if print ~= originalPrint then
    -- Function was hooked
end

-- Or check function info:
local info = debug.info(print, "s")
if info ~= "[C]" then
    -- Not a C function anymore, was hooked
end
```

#### Callstack Analysis
```lua
-- ACs analyze the call stack for anomalies
-- They look for:
-- 1. Calls originating from nil/unknown scripts
-- 2. Unusual stack depth
-- 3. Missing expected callers

local function validateCaller()
    local caller = getcallingscript()
    if caller == nil then
        -- Called from executor
    end
    
    local stack = debug.traceback()
    if stack:find("hookfunction") or stack:find("newcclosure") then
        -- Hooked call detected
    end
end
```

---

## Obfuscation Detection

Many anti-cheats use obfuscation to hide their logic. Recognizing obfuscation patterns helps identify AC code.

### Common Obfuscator Signatures

#### Prometheus (Your Obfuscator)
```lua
-- Indicators of Prometheus obfuscation:
-- 1. VMify creates a custom VM with bytecode
-- 2. EncryptStrings produces encoded string tables
-- 3. ConstantArray moves constants to arrays
-- 4. WrapInFunction wraps code in anonymous functions

-- Detection patterns:
local prometheusPatterns = {
    "local%s+[IlO1]+%s*=%s*{",           -- Il naming (mangled)
    "string%.char%s*%(%s*%d+%s*%)",       -- String encryption
    "bit32%.bxor",                         -- XOR operations (encryption)
    "function%s*%(%s*%.%.%.%s*%)",        -- Vararg wrapper functions
    "while%s+true%s+do%s+local",          -- VM loop pattern
}
```

#### Luraph
```lua
-- Luraph signatures:
local luraphPatterns = {
    "LPH_OBFUSCATED",                     -- Watermark
    "LPH_CRASH",                          -- Anti-tamper
    "LPH_JIT_MAX",                        -- JIT hint
    "local%s+v%d+%s*=%s*{",               -- Variable naming v1, v2, v3
    "select%s*%(%s*[\"']#[\"']",          -- Heavy use of select
}
```

#### IronBrew / IronBrew 2
```lua
-- IronBrew VM patterns:
local ironbrewPatterns = {
    "local%s+[A-Za-z_]+%s*=%s*string%.byte",
    "local%s+[A-Za-z_]+%s*=%s*string%.char", 
    "local%s+[A-Za-z_]+%s*=%s*string%.sub",
    "local%s+[A-Za-z_]+%s*=%s*table%.concat",
    "bit32%.extract",                      -- Bytecode extraction
    "for%s+[A-Za-z_]+%s*=%s*1%s*,%s*#",   -- Instruction loop
}
```

#### Moonsec
```lua
-- Moonsec patterns:
local moonsecPatterns = {
    "getfenv%s*%(%s*0%s*%)",              -- Environment manipulation
    "setfenv%s*%(%s*1",                   -- Sandboxing
    "string%.gsub%s*%([^,]+,%s*[\"'].[\"'],%s*function", -- String decryption
}
```

### Obfuscation Detection Script
```lua
local function detectObfuscation(source)
    local detected = {}
    
    local obfuscators = {
        Prometheus = {
            "local%s+[IlO1]+%s*=%s*{",
            "bit32%.bxor",
            "string%.char%s*%(%s*%d+%s*%)",
        },
        Luraph = {
            "LPH_OBFUSCATED",
            "LPH_CRASH",
            "select%s*%(%s*[\"']#[\"']",
        },
        IronBrew = {
            "bit32%.extract",
            "string%.byte%s*%([^,]+,%s*%d+%s*,%s*%d+%s*%)",
        },
        Moonsec = {
            "getfenv%s*%(%s*0%s*%)",
            "setfenv%s*%(%s*1",
        },
        PSU = {
            "PSU_OBFUSCATED",
            "getfenv%s*%(%s*%)",
        }
    }
    
    for name, patterns in pairs(obfuscators) do
        local matches = 0
        for _, pattern in ipairs(patterns) do
            if source:find(pattern) then
                matches = matches + 1
            end
        end
        if matches >= 2 then
            table.insert(detected, {name = name, confidence = matches / #patterns})
        end
    end
    
    return detected
end
```

### VM Detection
```lua
-- Detect if code is running inside a Lua VM obfuscator
local function detectVM()
    local indicators = {
        vmLoop = false,
        customOpcodes = false,
        stackManipulation = false
    }
    
    -- Check for unusually deep call stacks (VM interpreters)
    local depth = 0
    local info = debug.info
    while info(depth, "f") do
        depth = depth + 1
    end
    
    if depth > 50 then
        indicators.vmLoop = true
    end
    
    -- Check for VM-specific upvalues
    local gc = getgc(false)
    for _, v in pairs(gc) do
        if type(v) == "function" then
            for i = 1, 100 do
                local success, name, val = pcall(getupvalue, v, i)
                if not success then break end
                
                if name and (name:find("opcode") or name:find("instruction") or name:find("bytecode")) then
                    indicators.customOpcodes = true
                end
                
                if name and (name:find("stack") or name:find("registers")) then
                    indicators.stackManipulation = true
                end
            end
        end
    end
    
    return indicators
end
```

### Deobfuscation Hints
```lua
-- Extract readable strings from obfuscated code
local function extractStrings(source)
    local strings = {}
    
    -- Find string literals
    for str in source:gmatch([["([^"]+)"]]) do
        if #str > 3 and not str:match("^%d+$") then
            table.insert(strings, str)
        end
    end
    
    for str in source:gmatch([['([^']+)']]) do
        if #str > 3 and not str:match("^%d+$") then
            table.insert(strings, str)
        end
    end
    
    return strings
end

-- Find function names even in obfuscated code
local function extractFunctionCalls(source)
    local calls = {}
    
    -- Standard calls
    for call in source:gmatch("([%w_]+)%s*%(") do
        calls[call] = (calls[call] or 0) + 1
    end
    
    -- Method calls
    for call in source:gmatch(":([%w_]+)%s*%(") do
        calls[call] = (calls[call] or 0) + 1
    end
    
    return calls
end
```

---

## Known AC Systems

### Byfron (Hyperion)

Roblox's official kernel-level anti-cheat.

**Characteristics:**
- Runs at kernel level (ring 0)
- Cannot be bypassed from Lua alone
- Detects DLL injection, memory manipulation
- Updated frequently by Roblox

**Detection Scope:**
- External cheat software
- Memory editing tools
- Injectors and executors
- Debugging tools attached to Roblox

**What It Doesn't Detect:**
- Pure Lua script behavior (that's left to game devs)
- Exploits that work within executor sandboxes
- Game-specific logic exploits

**Status:** Active on Windows, being rolled out to other platforms

---

### Custom Game Anti-Cheats

#### Movement-Based ACs
```lua
-- Common in: Combat games, racing games
-- Checks: Speed, teleport, fly, noclip

-- Typical implementation:
-- 1. Heartbeat loop tracking position
-- 2. Magnitude checks between frames
-- 3. Raycast for ground detection
-- 4. Server-side position validation

-- Bypass difficulty: Easy-Medium
-- Most rely on client-side checks that can be hooked
```

#### Economy-Based ACs
```lua
-- Common in: Simulators, trading games
-- Checks: Item duplication, value manipulation, trade validation

-- Typical implementation:
-- 1. Server authoritative inventory
-- 2. Transaction logging
-- 3. Rate limiting on trades/purchases
-- 4. Value sanity checks

-- Bypass difficulty: Hard
-- Most logic is server-side
```

#### Combat-Based ACs
```lua
-- Common in: Fighting games, shooters
-- Checks: Damage values, hit registration, cooldowns

-- Typical implementation:
-- 1. Server-side damage calculation
-- 2. Cooldown tracking per ability
-- 3. Range/line-of-sight validation
-- 4. Animation state verification

-- Bypass difficulty: Medium-Hard
-- Mix of client and server validation
```

### Commercial AC Solutions

#### Adonis Admin
```lua
-- Not primarily an AC, but has AC features
-- Detects: Executor globals, speed hacks, fly

-- Common remotes:
-- "Adonis_AdminEvent"
-- "Adonis_AdminFunction"

-- Bypass: Block/spoof these remotes
```

#### SimpleSpy Detection
```lua
-- Some games detect SimpleSpy
-- They look for:
-- - Extra connections on remotes
-- - Specific hook patterns
-- - SimpleSpy's global variables

-- Counter: Use custom remote spy
```

### AC Identification Script
```lua
local function identifyAC()
    local results = {
        type = "Unknown",
        confidence = 0,
        indicators = {}
    }
    
    -- Check for Adonis
    if game:GetService("ReplicatedStorage"):FindFirstChild("Adonis_AdminEvent") then
        results.type = "Adonis"
        results.confidence = 0.9
        table.insert(results.indicators, "Adonis remote found")
    end
    
    -- Check for HD Admin
    if game:GetService("ReplicatedStorage"):FindFirstChild("HDAdminClient") then
        results.type = "HD Admin"
        results.confidence = 0.9
        table.insert(results.indicators, "HD Admin module found")
    end
    
    -- Check for custom AC by remote patterns
    local acRemotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("anti") or name:find("cheat") or name:find("security") or name:find("valid") then
                table.insert(acRemotes, obj:GetFullName())
            end
        end
    end
    
    if #acRemotes > 0 then
        results.type = "Custom AC"
        results.confidence = 0.7
        results.indicators = acRemotes
    end
    
    -- Check connection count (high count = likely AC)
    local heartbeatConns = #safeGetConnections(game:GetService("RunService").Heartbeat)
    if heartbeatConns > 10 then
        table.insert(results.indicators, "High Heartbeat connections: " .. heartbeatConns)
        results.confidence = math.min(results.confidence + 0.1, 1)
    end
    
    return results
end
```

---

## Scanning Techniques

### Comprehensive Game Scanner
```lua
-- Full game environment scan
local function scanGame()
    local results = {
        remotes = {},
        scripts = {},
        connections = {},
        suspiciousPatterns = {}
    }
    
    -- Scan all instances
    for _, obj in pairs(game:GetDescendants()) do
        -- Find remotes
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(results.remotes, {
                name = obj.Name,
                path = obj:GetFullName(),
                type = obj.ClassName
            })
        end
        
        -- Find scripts
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local info = {
                name = obj.Name,
                path = obj:GetFullName(),
                type = obj.ClassName
            }
            
            -- Try to get source
            pcall(function()
                info.source = decompile(obj)
                
                -- Check for AC patterns
                if info.source then
                    if info.source:find("Heartbeat") then
                        info.hasHeartbeat = true
                    end
                    if info.source:find("FireServer") then
                        info.firesRemotes = true
                    end
                    if info.source:find("kick") or info.source:find("Kick") then
                        info.canKick = true
                    end
                end
            end)
            
            table.insert(results.scripts, info)
        end
    end
    
    -- Scan connections
    for _, event in pairs({
        game:GetService("RunService").Heartbeat,
        game:GetService("RunService").RenderStepped,
        game:GetService("RunService").Stepped
    }) do
        for _, conn in pairs(getconnections(event)) do
            table.insert(results.connections, {
                event = tostring(event),
                func = tostring(conn.Function),
                enabled = conn.Enabled
            })
        end
    end
    
    return results
end
```

### Connection Scanner
```lua
-- Scan all active connections for suspicious activity
local function scanConnections()
    local services = {
        RunService = {"Heartbeat", "RenderStepped", "Stepped"},
        Players = {"PlayerAdded", "PlayerRemoving"},
        UserInputService = {"InputBegan", "InputEnded"}
    }
    
    for serviceName, events in pairs(services) do
        local service = game:GetService(serviceName)
        for _, eventName in pairs(events) do
            local event = service[eventName]
            local connections = getconnections(event)
            
            print(string.format("[%s.%s] %d connections", serviceName, eventName, #connections))
            
            for i, conn in pairs(connections) do
                -- Try to identify the script
                local info = debug.info(conn.Function, "sln")
                print(string.format("  [%d] %s", i, info or "unknown"))
            end
        end
    end
end
```

### Module Scanner
```lua
-- Scan loaded modules for AC code
local function scanModules()
    local modules = {}
    
    -- Get all modules from registry
    for _, v in pairs(getreg()) do
        if typeof(v) == "function" then
            local info = debug.info(v, "s")
            if info and not modules[info] then
                modules[info] = true
            end
        end
    end
    
    -- Get all module scripts
    for _, obj in pairs(getinstances()) do
        if obj:IsA("ModuleScript") then
            local success, source = pcall(decompile, obj)
            if success and source then
                -- Check for AC indicators
                local indicators = {
                    "exploit", "cheat", "hack", "ban", "kick",
                    "magnitude", "raycast", "Heartbeat", "sanity"
                }
                
                for _, indicator in pairs(indicators) do
                    if source:lower():find(indicator) then
                        print(string.format("[MODULE] %s contains '%s'", obj:GetFullName(), indicator))
                    end
                end
            end
        end
    end
end
```

---

## Dynamic Analysis

Real-time monitoring and analysis techniques to understand AC behavior as it runs.

### Memory Diffing

#### Before/After AC Load Comparison
```lua
-- Capture game state before AC initializes
local function captureState()
    local state = {
        connections = {},
        remotes = {},
        globals = {},
        instances = {}
    }
    
    -- Capture connections
    for _, event in pairs({RunService.Heartbeat, RunService.RenderStepped, RunService.Stepped}) do
        state.connections[tostring(event)] = #safeGetConnections(event)
    end
    
    -- Capture remotes
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            state.remotes[obj:GetFullName()] = true
        end
    end
    
    -- Capture global state
    for k, v in pairs(getgenv()) do
        state.globals[k] = typeof(v)
    end
    
    -- Instance count
    state.instances.total = #game:GetDescendants()
    
    return state
end

-- Compare two states to find differences
local function diffStates(before, after)
    local diff = {
        newConnections = {},
        newRemotes = {},
        newGlobals = {},
        instanceDelta = 0
    }
    
    -- Connection diff
    for event, count in pairs(after.connections) do
        local beforeCount = before.connections[event] or 0
        if count > beforeCount then
            diff.newConnections[event] = count - beforeCount
        end
    end
    
    -- Remote diff
    for remote in pairs(after.remotes) do
        if not before.remotes[remote] then
            table.insert(diff.newRemotes, remote)
        end
    end
    
    -- Global diff
    for k, v in pairs(after.globals) do
        if not before.globals[k] then
            diff.newGlobals[k] = v
        end
    end
    
    diff.instanceDelta = after.instances.total - before.instances.total
    
    return diff
end

-- Usage:
-- local before = captureState()
-- wait(5) -- Let AC initialize
-- local after = captureState()
-- local changes = diffStates(before, after)
```

### Connection Monitoring Over Time
```lua
-- Track connection changes in real-time
local function monitorConnections(duration)
    local events = {
        RunService.Heartbeat,
        RunService.RenderStepped,
        RunService.Stepped
    }
    
    local history = {}
    local startTime = tick()
    
    while tick() - startTime < duration do
        local snapshot = {
            time = tick() - startTime,
            counts = {}
        }
        
        for _, event in pairs(events) do
            local name = tostring(event):match("Signal (%w+)")
            snapshot.counts[name] = #safeGetConnections(event)
        end
        
        table.insert(history, snapshot)
        task.wait(0.5)
    end
    
    -- Analyze for patterns
    print("=== Connection History ===")
    for _, snap in pairs(history) do
        local str = string.format("[%.1fs] ", snap.time)
        for name, count in pairs(snap.counts) do
            str = str .. string.format("%s:%d ", name, count)
        end
        print(str)
    end
    
    return history
end
```

### Runtime Behavior Analysis
```lua
-- Monitor function call frequency
local function profileFunction(func, name)
    local callCount = 0
    local totalTime = 0
    local lastCall = tick()
    local intervals = {}
    
    return function(...)
        local now = tick()
        table.insert(intervals, now - lastCall)
        lastCall = now
        
        callCount = callCount + 1
        local start = tick()
        local results = {func(...)}
        totalTime = totalTime + (tick() - start)
        
        -- Periodic report
        if callCount % 100 == 0 then
            local avgInterval = 0
            for _, v in pairs(intervals) do avgInterval = avgInterval + v end
            avgInterval = avgInterval / #intervals
            
            print(string.format("[%s] Calls: %d, Avg time: %.4fms, Avg interval: %.4fs",
                name, callCount, (totalTime/callCount)*1000, avgInterval))
        end
        
        return unpack(results)
    end
end

-- Usage: Hook an AC function to profile it
-- acFunction = profileFunction(acFunction, "AntiCheat")
```

### Remote Traffic Analysis
```lua
-- Analyze patterns in remote communications
local RemoteAnalyzer = {
    history = {},
    patterns = {}
}

function RemoteAnalyzer:start()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" or method == "InvokeServer" then
            table.insert(self.history, {
                time = tick(),
                remote = self.Name,
                path = self:GetFullName(),
                method = method,
                argCount = select("#", ...),
                argTypes = self:getArgTypes(...)
            })
            
            -- Keep history manageable
            if #self.history > 1000 then
                table.remove(self.history, 1)
            end
        end
        
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

function RemoteAnalyzer:getArgTypes(...)
    local types = {}
    for i = 1, select("#", ...) do
        table.insert(types, typeof(select(i, ...)))
    end
    return types
end

function RemoteAnalyzer:analyze()
    local remoteCounts = {}
    local remoteIntervals = {}
    
    for i, entry in ipairs(self.history) do
        -- Count per remote
        remoteCounts[entry.remote] = (remoteCounts[entry.remote] or 0) + 1
        
        -- Calculate intervals
        if i > 1 and self.history[i-1].remote == entry.remote then
            local interval = entry.time - self.history[i-1].time
            remoteIntervals[entry.remote] = remoteIntervals[entry.remote] or {}
            table.insert(remoteIntervals[entry.remote], interval)
        end
    end
    
    print("=== Remote Analysis ===")
    for remote, count in pairs(remoteCounts) do
        local avgInterval = "N/A"
        if remoteIntervals[remote] and #remoteIntervals[remote] > 0 then
            local sum = 0
            for _, v in pairs(remoteIntervals[remote]) do sum = sum + v end
            avgInterval = string.format("%.3fs", sum / #remoteIntervals[remote])
        end
        
        print(string.format("%s: %d calls, avg interval: %s", remote, count, avgInterval))
        
        -- Flag suspicious patterns
        if count > 50 and avgInterval ~= "N/A" then
            print("  ^ SUSPICIOUS: High frequency remote, likely AC")
        end
    end
end
```

### Script Execution Tracing
```lua
-- Trace what scripts are running and when
local function traceScriptExecution()
    local executed = {}
    
    -- Hook require to track module loading
    local oldRequire = require
    require = function(module)
        local path = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
        table.insert(executed, {
            time = tick(),
            type = "require",
            path = path
        })
        print("[REQUIRE] " .. path)
        return oldRequire(module)
    end
    
    -- Track script additions
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            table.insert(executed, {
                time = tick(),
                type = "added",
                path = obj:GetFullName(),
                class = obj.ClassName
            })
            print("[SCRIPT ADDED] " .. obj:GetFullName())
        end
    end)
    
    return executed
end
```

### Upvalue/Constant Watching
```lua
-- Monitor changes to function upvalues over time
local function watchUpvalues(func, interval)
    local previousUpvalues = {}
    
    -- Initial capture
    for i = 1, 50 do
        local success, name, value = pcall(getupvalue, func, i)
        if not success then break end
        previousUpvalues[i] = {name = name, value = value}
    end
    
    -- Monitor loop
    task.spawn(function()
        while true do
            task.wait(interval or 1)
            
            for i = 1, 50 do
                local success, name, value = pcall(getupvalue, func, i)
                if not success then break end
                
                local prev = previousUpvalues[i]
                if prev and prev.value ~= value then
                    print(string.format("[UPVALUE CHANGED] %s: %s -> %s",
                        name or ("upvalue_" .. i),
                        tostring(prev.value),
                        tostring(value)))
                    previousUpvalues[i] = {name = name, value = value}
                end
            end
        end
    end)
end
```

---

## Bypass Strategies

### Hook-Based Bypasses

#### Namecall Hook (Block AC Remotes)
```lua
-- Block specific remotes from firing
local blockedRemotes = {"AntiCheat", "ValidatePlayer", "ReportExploit"}

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if method == "FireServer" or method == "InvokeServer" then
        for _, blocked in pairs(blockedRemotes) do
            if self.Name:find(blocked) then
                return -- Block the call
            end
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
```

#### Spoof Player Properties
```lua
-- Spoof position/velocity readings
local mt = getrawmetatable(game)
local oldIndex = mt.__index

setreadonly(mt, false)
mt.__index = newcclosure(function(self, key)
    -- Spoof HRP position to safe value
    if self.Name == "HumanoidRootPart" and key == "Position" then
        return safePosition -- Return a "safe" position
    end
    
    -- Spoof velocity
    if self.Name == "HumanoidRootPart" and key == "Velocity" then
        return Vector3.new(0, 0, 0)
    end
    
    return oldIndex(self, key)
end)
setreadonly(mt, true)
```

#### Block Kick/Ban Functions
```lua
-- Prevent kick attempts
local Player = game:GetService("Players").LocalPlayer
local oldKick = Player.Kick

hookfunction(oldKick, function(self, ...)
    if self == Player then
        warn("[BLOCKED] Kick attempt:", ...)
        return -- Block the kick
    end
    return oldKick(self, ...)
end)
```

### Connection-Based Bypasses

#### Disable AC Connections
```lua
-- Find and disable anti-cheat heartbeat connections
for _, conn in pairs(getconnections(game:GetService("RunService").Heartbeat)) do
    local info = debug.info(conn.Function, "s")
    
    -- Disable connections from suspicious scripts
    if info and (info:find("Anti") or info:find("Security")) then
        conn:Disable()
        print("[DISABLED] Connection from:", info)
    end
end
```

#### Replace Connection Functions
```lua
-- Replace the function in an AC connection with a dummy
for _, conn in pairs(getconnections(RunService.Heartbeat)) do
    local func = conn.Function
    
    -- Check if this looks like an AC function
    local source = debug.info(func, "s")
    if source and source:lower():find("cheat") then
        -- Replace with empty function
        conn:Disable()
        
        -- Or replace the function entirely
        hookfunction(func, function() end)
    end
end
```

### Environment Spoofing

#### Hide Executor Globals
```lua
-- Create a clean environment that hides executor functions
local cleanEnv = setmetatable({}, {
    __index = function(self, key)
        -- Hide executor-specific globals
        local hidden = {
            "syn", "fluxus", "hookfunction", "hookmetamethod",
            "newcclosure", "getrawmetatable", "setreadonly"
        }
        
        for _, h in pairs(hidden) do
            if key == h then
                return nil
            end
        end
        
        return getfenv()[key]
    end
})

-- Run AC checks in clean environment
setfenv(acCheckFunction, cleanEnv)
```

#### Spoof Checkcaller
```lua
-- Make executor calls appear as game calls
local oldCheckcaller = checkcaller
checkcaller = newcclosure(function()
    return false -- Always report as game caller
end)
```

---

## Advanced Techniques

### Timing-Based Analysis

#### Measure AC Check Intervals
```lua
-- Determine how often the AC runs checks
local lastDetection = tick()
local intervals = {}

-- Hook a known AC function
hookfunction(acFunction, function(...)
    local now = tick()
    table.insert(intervals, now - lastDetection)
    lastDetection = now
    
    -- Calculate average interval
    if #intervals > 10 then
        local sum = 0
        for _, v in pairs(intervals) do sum = sum + v end
        print("Average AC interval:", sum / #intervals)
    end
    
    return originalFunction(...)
end)
```

#### Race Condition Exploitation
```lua
-- Execute during AC "blind spots"
local function executeWhenSafe()
    -- ACs often check on Heartbeat
    -- Execute immediately after their check runs
    
    local acConnection = findACConnection()
    local originalFunc = acConnection.Function
    
    hookfunction(originalFunc, function(...)
        local result = originalFunc(...)
        
        -- AC just finished checking, safe to execute
        task.defer(function()
            -- Your code here runs in the "safe window"
        end)
        
        return result
    end)
end
```

### Reverse Engineering AC Logic

#### Extract AC Configuration
```lua
-- Find AC thresholds and limits
local function extractACConfig()
    local config = {}
    
    -- Scan upvalues of AC functions
    for _, conn in pairs(getconnections(RunService.Heartbeat)) do
        local func = conn.Function
        
        for i = 1, 50 do
            local success, name, value = pcall(getupvalue, func, i)
            if not success then break end
            
            if name and (name:find("MAX") or name:find("THRESHOLD") or name:find("LIMIT")) then
                config[name] = value
                print(string.format("[CONFIG] %s = %s", name, tostring(value)))
            end
        end
    end
    
    return config
end
```

#### Map AC Remote Protocol
```lua
-- Understand what data the AC sends to server
local acData = {}

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if (method == "FireServer" or method == "InvokeServer") and self.Name:find("AC") then
        table.insert(acData, {
            remote = self.Name,
            args = args,
            time = tick()
        })
        
        -- Analyze patterns
        if #acData > 20 then
            analyzeACProtocol(acData)
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
```

### Persistence & Stealth

#### Survive Script Reloads
```lua
-- Store state in persistent location
_G.__BYPASS_STATE = _G.__BYPASS_STATE or {
    initialized = false,
    hooks = {},
    originalFunctions = {}
}

if not _G.__BYPASS_STATE.initialized then
    -- First run - set up hooks
    _G.__BYPASS_STATE.initialized = true
    -- ... setup code
end
```

#### Anti-Detection for Your Hooks
```lua
-- Make your hooks harder to detect
local function stealthHook(func, hook)
    local hooked = hookfunction(func, newcclosure(function(...)
        -- Check if AC is trying to detect us
        local caller = getcallingscript()
        local stack = debug.traceback()
        
        if stack:find("Anti") or stack:find("Security") then
            -- AC is checking, return original behavior
            return func(...)
        end
        
        return hook(...)
    end))
    
    return hooked
end
```

---

## Anti-Anti-Cheat Detection

Modern ACs try to detect if you're analyzing them. These techniques help you scan passively without triggering alerts.

### Detection Vectors ACs Use Against You

#### Hook Detection
```lua
-- ACs detect hooks by:
-- 1. Comparing function references
-- 2. Checking function source info
-- 3. Monitoring call patterns

-- How they check:
local originalPrint = print
task.spawn(function()
    while true do
        task.wait(5)
        
        -- Reference comparison
        if print ~= originalPrint then
            -- DETECTED: print was hooked
        end
        
        -- Source check
        local info = debug.info(print, "s")
        if info ~= "[C]" then
            -- DETECTED: print is no longer a C function
        end
        
        -- Check for newcclosure wrapper
        if not iscclosure(print) then
            -- DETECTED: print was replaced with Lua function
        end
    end
end)
```

#### Global Scanning
```lua
-- ACs periodically scan for executor globals
local function acGlobalScan()
    local suspicious = {
        "syn", "fluxus", "KRNL", "getgenv", "getrawmetatable",
        "hookfunction", "newcclosure", "getconnections"
    }
    
    for _, name in pairs(suspicious) do
        if rawget(_G, name) or rawget(getfenv(), name) or rawget(shared, name) then
            -- DETECTED
        end
    end
    
    -- Check getreg for executor traces
    for _, v in pairs(getreg()) do
        if type(v) == "function" then
            local src = debug.info(v, "s")
            if src and src:find("exploit") then
                -- DETECTED
            end
        end
    end
end
```

#### Behavior Analysis
```lua
-- ACs look for suspicious behavior patterns:
-- 1. Too many getconnections calls
-- 2. Decompile attempts
-- 3. Rapid metatable access
-- 4. Unusual debug library usage

-- They might track:
local suspiciousActions = 0
local oldGetconnections = getconnections

getconnections = function(...)
    suspiciousActions = suspiciousActions + 1
    if suspiciousActions > 10 then
        -- Flag player as using executor
    end
    return oldGetconnections(...)
end
```

### Stealth Scanning Techniques

#### Passive Remote Monitoring
```lua
-- Instead of hooking (detectable), use BindableEvents
local function passiveRemoteSpy()
    -- Don't hook namecall - ACs detect that
    -- Instead, monitor from a different angle
    
    local remotes = {}
    
    -- Just catalog remotes without hooking
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            remotes[obj] = {
                name = obj.Name,
                path = obj:GetFullName(),
                parent = obj.Parent and obj.Parent.Name or "nil"
            }
        end
    end
    
    -- Watch for new remotes passively
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            remotes[obj] = {
                name = obj.Name,
                path = obj:GetFullName(),
                added = tick()
            }
        end
    end)
    
    return remotes
end
```

#### Delayed/Randomized Scanning
```lua
-- Don't scan immediately - ACs watch for instant scans on join
local function stealthScan()
    -- Random delay between 10-30 seconds
    task.wait(math.random(10, 30))
    
    -- Scan in chunks with random delays
    local descendants = game:GetDescendants()
    local chunkSize = 100
    
    for i = 1, #descendants, chunkSize do
        for j = i, math.min(i + chunkSize - 1, #descendants) do
            local obj = descendants[j]
            -- Process object
        end
        
        -- Random delay between chunks
        task.wait(math.random() * 0.5)
    end
end
```

#### Clone-Based Analysis
```lua
-- Analyze copies instead of originals (less detectable)
local function safeAnalyze(func)
    -- Clone the function first
    local cloned = clonefunction(func)
    
    -- Analyze the clone
    local upvalues = {}
    for i = 1, 50 do
        local success, name, value = pcall(getupvalue, cloned, i)
        if not success then break end
        upvalues[i] = {name = name, value = value, type = typeof(value)}
    end
    
    return upvalues
end
```

#### Non-Invasive Connection Analysis
```lua
-- Get connection info without disabling/modifying
local function analyzeConnectionsSafely()
    local analysis = {}
    
    local events = {
        {service = "RunService", event = "Heartbeat"},
        {service = "RunService", event = "RenderStepped"},
        {service = "RunService", event = "Stepped"},
        {service = "UserInputService", event = "InputBegan"},
    }
    
    for _, e in pairs(events) do
        local service = game:GetService(e.service)
        local connections = safeGetConnections(service[e.event])
        
        analysis[e.service .. "." .. e.event] = {
            count = #connections,
            -- Don't access .Function directly - some ACs trap that
            hasConnections = #connections > 0
        }
    end
    
    return analysis
end
```

### Hiding Your Presence

#### Clean Environment Wrapper
```lua
-- Execute your code in a clean environment
local function executeClean(code)
    local env = setmetatable({}, {
        __index = function(_, key)
            -- Hide executor globals
            local hidden = {"syn", "fluxus", "hookfunction", "getrawmetatable"}
            for _, h in pairs(hidden) do
                if key == h then return nil end
            end
            return getfenv()[key]
        end,
        __newindex = function(_, key, value)
            rawset(getfenv(), key, value)
        end
    })
    
    local func = setfenv(loadstring(code), env)
    return func()
end
```

#### Checkcaller Spoofing
```lua
-- Make your calls appear to come from game scripts
local function spoofedCall(func, ...)
    -- Some executors support this
    if setthreadidentity then
        local oldIdentity = getthreadidentity()
        setthreadidentity(2) -- Game script identity
        local result = {func(...)}
        setthreadidentity(oldIdentity)
        return unpack(result)
    end
    
    return func(...)
end
```

#### Timing Obfuscation
```lua
-- Make your scans look like normal game activity
local function obfuscatedScan()
    local results = {}
    
    -- Mimic human-like timing
    local function humanDelay()
        task.wait(math.random(100, 500) / 1000)
    end
    
    -- Don't scan everything at once
    local toScan = game:GetDescendants()
    local scanned = 0
    
    for _, obj in pairs(toScan) do
        scanned = scanned + 1
        
        -- Process
        if obj:IsA("LocalScript") then
            table.insert(results, obj:GetFullName())
        end
        
        -- Occasional delays to look natural
        if scanned % 50 == 0 then
            humanDelay()
        end
    end
    
    return results
end
```

---

## Scanning Workflow

A structured approach to analyzing anti-cheat systems.

### Phase 1: Passive Reconnaissance

```
┌─────────────────────────────────────────────────────┐
│                 PHASE 1: RECON                      │
│                 (No hooks, no modifications)        │
├─────────────────────────────────────────────────────┤
│ 1. Join game normally                               │
│ 2. Wait 30+ seconds for everything to load          │
│ 3. Count connections (don't analyze yet)            │
│ 4. List all remotes (names only)                    │
│ 5. Note any kicks/bans/warnings                     │
└─────────────────────────────────────────────────────┘
```

```lua
-- Phase 1 Script
local function phase1Recon()
    print("=== PHASE 1: PASSIVE RECON ===")
    
    task.wait(30) -- Let game fully load
    
    local report = {
        connectionCounts = {},
        remoteCount = 0,
        scriptCount = 0,
        suspiciousNames = {}
    }
    
    -- Connection counts only
    report.connectionCounts.Heartbeat = #safeGetConnections(game:GetService("RunService").Heartbeat)
    report.connectionCounts.RenderStepped = #safeGetConnections(game:GetService("RunService").RenderStepped)
    
    -- Count remotes and scripts
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            report.remoteCount = report.remoteCount + 1
            
            local name = obj.Name:lower()
            if name:find("anti") or name:find("cheat") or name:find("valid") or name:find("security") then
                table.insert(report.suspiciousNames, obj:GetFullName())
            end
        end
        
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            report.scriptCount = report.scriptCount + 1
        end
    end
    
    return report
end
```

### Phase 2: Active Scanning

```
┌─────────────────────────────────────────────────────┐
│                 PHASE 2: ACTIVE SCAN                │
│                 (Light analysis)                    │
├─────────────────────────────────────────────────────┤
│ 1. Set up remote spy (lightweight)                  │
│ 2. Decompile suspicious scripts                     │
│ 3. Analyze connection functions                     │
│ 4. Map remote protocol                              │
│ 5. Identify AC type                                 │
└─────────────────────────────────────────────────────┘
```

```lua
-- Phase 2 Script
local function phase2ActiveScan(phase1Report)
    print("=== PHASE 2: ACTIVE SCAN ===")
    
    local analysis = {
        acType = "Unknown",
        remoteProtocol = {},
        suspiciousScripts = {},
        heartbeatFunctions = {}
    }
    
    -- Analyze suspicious remotes from Phase 1
    for _, path in pairs(phase1Report.suspiciousNames) do
        local obj = game
        for part in path:gmatch("[^%.]+") do
            obj = obj:FindFirstChild(part)
            if not obj then break end
        end
        
        if obj then
            analysis.remoteProtocol[obj.Name] = {
                path = path,
                type = obj.ClassName
            }
        end
    end
    
    -- Try to identify AC type
    analysis.acType = identifyAC().type
    
    -- Analyze heartbeat connections
    for i, conn in pairs(safeGetConnections(game:GetService("RunService").Heartbeat)) do
        if conn.Function then
            local info = debug.info(conn.Function, "sln")
            table.insert(analysis.heartbeatFunctions, info or "unknown")
        end
    end
    
    return analysis
end
```

### Phase 3: Deep Analysis

```
┌─────────────────────────────────────────────────────┐
│                 PHASE 3: DEEP ANALYSIS              │
│                 (Full investigation)                │
├─────────────────────────────────────────────────────┤
│ 1. Decompile AC scripts                             │
│ 2. Extract thresholds/limits                        │
│ 3. Map full remote protocol                         │
│ 4. Identify all detection methods                   │
│ 5. Document findings                                │
└─────────────────────────────────────────────────────┘
```

```lua
-- Phase 3 Script
local function phase3DeepAnalysis(phase2Analysis)
    print("=== PHASE 3: DEEP ANALYSIS ===")
    
    local deepReport = {
        detectionMethods = {},
        thresholds = {},
        bypassPossibilities = {}
    }
    
    -- Decompile and analyze suspicious scripts
    for _, obj in pairs(getinstances()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local source = safeDecompile(obj)
            if source then
                -- Check for detection patterns
                local patterns = {
                    {pattern = "magnitude", method = "Speed/Teleport Detection"},
                    {pattern = "Raycast.-HumanoidRootPart", method = "Fly Detection"},
                    {pattern = "GetPartsInPart", method = "Noclip Detection"},
                    {pattern = "getfenv", method = "Environment Check"},
                    {pattern = "hookfunction", method = "Hook Detection"},
                }
                
                for _, p in pairs(patterns) do
                    if source:find(p.pattern) then
                        table.insert(deepReport.detectionMethods, {
                            method = p.method,
                            script = obj:GetFullName()
                        })
                    end
                end
                
                -- Extract thresholds
                for name, value in source:gmatch("local%s+([A-Z_]+)%s*=%s*(%d+)") do
                    if name:find("MAX") or name:find("THRESHOLD") or name:find("LIMIT") then
                        deepReport.thresholds[name] = tonumber(value)
                    end
                end
            end
        end
    end
    
    return deepReport
end
```

### Decision Tree

```
                    ┌─────────────────┐
                    │   Start Scan    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Phase 1 Recon   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
      ┌───────▼───────┐     │      ┌───────▼───────┐
      │ Got kicked?   │     │      │ > 10 Heartbeat│
      │               │     │      │ connections?  │
      └───────┬───────┘     │      └───────┬───────┘
              │             │              │
         YES  │        NO   │         YES  │  NO
              │             │              │
      ┌───────▼───────┐     │      ┌───────▼───────┐
      │ AC detected   │     │      │ Likely has AC │
      │ executor on   │     │      │ Continue to   │
      │ join - use    │     │      │ Phase 2       │
      │ stealth mode  │     │      └───────────────┘
      └───────────────┘     │
                            │
                   ┌────────▼────────┐
                   │ AC remotes      │
                   │ found?          │
                   └────────┬────────┘
                            │
               YES          │          NO
                ┌───────────┴───────────┐
                │                       │
        ┌───────▼───────┐       ┌───────▼───────┐
        │ Custom AC     │       │ Minimal/No AC │
        │ Deep analysis │       │ Safe to       │
        │ needed        │       │ proceed       │
        └───────────────┘       └───────────────┘
```

### Quick Assessment Script
```lua
-- Run this first to decide approach
local function quickAssess()
    local assessment = {
        risk = "LOW",
        approach = "standard",
        notes = {}
    }
    
    -- Check for immediate executor detection
    if game:GetService("Players").LocalPlayer:FindFirstChild("ACFlag") then
        assessment.risk = "HIGH"
        assessment.approach = "stealth"
        table.insert(assessment.notes, "Player flagged on join")
    end
    
    -- Check connection density
    local hbConns = #safeGetConnections(game:GetService("RunService").Heartbeat)
    if hbConns > 15 then
        assessment.risk = "HIGH"
        table.insert(assessment.notes, "High connection count: " .. hbConns)
    elseif hbConns > 8 then
        assessment.risk = "MEDIUM"
    end
    
    -- Check for known AC remotes
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("anticheat") then
            assessment.risk = "HIGH"
            assessment.approach = "careful"
            table.insert(assessment.notes, "Direct AC remote found: " .. obj.Name)
            break
        end
    end
    
    print("=== QUICK ASSESSMENT ===")
    print("Risk Level:", assessment.risk)
    print("Approach:", assessment.approach)
    for _, note in pairs(assessment.notes) do
        print("- " .. note)
    end
    
    return assessment
end
```

---

## Failure & Recovery

What to do when things go wrong.

### Detection Symptoms

| Symptom | Likely Cause | Severity |
|---------|--------------|----------|
| Instant kick on join | Executor detected by Byfron or game | Critical |
| Kick after 10-30 seconds | Script behavior flagged | High |
| Kick when using feature | Specific action detected | Medium |
| Warning message | Soft detection, not banned yet | Low |
| Teleported to spawn | Position validation failed | Low |
| Actions not working | Server rejecting requests | Medium |

### Recovery Procedures

#### After Getting Kicked
```lua
-- DON'T immediately rejoin and try again
-- DO wait and analyze what happened

-- 1. Document what you were doing
local lastActions = {
    -- "Enabled speed hack",
    -- "Fired remote X",
    -- "Hooked function Y"
}

-- 2. Check if it was timing-based
-- Did you get kicked:
-- - Immediately on join? (Executor detection)
-- - After specific action? (Action detection)
-- - After random time? (Periodic scan)

-- 3. Rejoin with minimal script first
-- Just observe, don't modify anything
```

#### Avoiding Bans
```lua
-- If you suspect you're flagged but not banned:

-- 1. Stop all modifications immediately
local function emergencyStop()
    -- Restore all hooks
    if _G.__ORIGINAL_FUNCTIONS then
        for name, func in pairs(_G.__ORIGINAL_FUNCTIONS) do
            getgenv()[name] = func
        end
    end
    
    -- Disable all custom connections
    if _G.__CUSTOM_CONNECTIONS then
        for _, conn in pairs(_G.__CUSTOM_CONNECTIONS) do
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Clear executor globals
    for _, name in pairs({"syn", "fluxus", "KRNL"}) do
        getgenv()[name] = nil
    end
end

-- 2. Play normally for a while
-- Some ACs track "suspicion score" that decays over time

-- 3. Use alt account for testing
```

#### Safe Testing Practices
```lua
-- Always test on alt accounts first
local function isSafeToTest()
    local player = game:GetService("Players").LocalPlayer
    
    -- Check account age
    local accountAge = player.AccountAge
    if accountAge > 365 then
        warn("WARNING: Account is over 1 year old. Use alt instead!")
        return false
    end
    
    -- Check for valuable items (game-specific)
    -- Add your own checks here
    
    return true
end

-- Test in private servers when possible
local function isPrivateServer()
    local privateServerId = game.PrivateServerId
    return privateServerId ~= "" and privateServerId ~= nil
end
```

### Debugging Failed Bypasses

#### Why Your Bypass Didn't Work
```lua
-- Common reasons bypasses fail:

-- 1. Wrong hook type
-- Problem: Used hookfunction when hookmetamethod was needed
-- Solution: Try both, check executor compatibility

-- 2. AC runs before your script
-- Problem: AC already cached original functions
-- Solution: Hook earlier, or target the cached references

-- 3. Server-side validation
-- Problem: Client bypass works but server rejects
-- Solution: Understand server protocol, can't bypass pure server checks

-- 4. Multiple detection layers
-- Problem: Bypassed one check but another caught you
-- Solution: Map ALL detection methods before bypassing

-- 5. Timing issues
-- Problem: Your code runs at wrong time
-- Solution: Use proper yielding, defer execution
```

#### Diagnostic Script
```lua
local function diagnoseFailure()
    local diagnosis = {
        issues = {},
        suggestions = {}
    }
    
    -- Check if hooks are intact
    local mt = getrawmetatable(game)
    if not mt then
        table.insert(diagnosis.issues, "Cannot get metatable - executor issue")
        table.insert(diagnosis.suggestions, "Try different executor")
    end
    
    -- Check if connections are working
    local testConn
    local testFired = false
    testConn = game:GetService("RunService").Heartbeat:Connect(function()
        testFired = true
        testConn:Disconnect()
    end)
    task.wait(0.1)
    
    if not testFired then
        table.insert(diagnosis.issues, "Heartbeat connection not firing")
        table.insert(diagnosis.suggestions, "Game may be blocking connections")
    end
    
    -- Check executor functionality
    local tests = {
        {"hookfunction", hookfunction},
        {"newcclosure", newcclosure},
        {"getconnections", getconnections},
        {"getrawmetatable", getrawmetatable},
    }
    
    for _, test in pairs(tests) do
        if not test[2] then
            table.insert(diagnosis.issues, test[1] .. " not available")
            table.insert(diagnosis.suggestions, "Use executor with " .. test[1] .. " support")
        end
    end
    
    print("=== DIAGNOSIS ===")
    print("Issues found:", #diagnosis.issues)
    for _, issue in pairs(diagnosis.issues) do
        print("  ❌ " .. issue)
    end
    print("Suggestions:")
    for _, sug in pairs(diagnosis.suggestions) do
        print("  💡 " .. sug)
    end
    
    return diagnosis
end
```

### Logging for Post-Mortem

```lua
-- Always log what you're doing for analysis later
local ACLogger = {
    logs = {},
    startTime = tick()
}

function ACLogger:log(category, message, data)
    table.insert(self.logs, {
        time = tick() - self.startTime,
        category = category,
        message = message,
        data = data
    })
end

function ACLogger:export()
    local output = "=== AC Analysis Log ===\n"
    output = output .. "Duration: " .. (tick() - self.startTime) .. "s\n\n"
    
    for _, entry in ipairs(self.logs) do
        output = output .. string.format("[%.2fs] [%s] %s\n",
            entry.time, entry.category, entry.message)
        if entry.data then
            output = output .. "  Data: " .. tostring(entry.data) .. "\n"
        end
    end
    
    -- Save to file if possible
    if writefile then
        writefile("ac_log_" .. os.time() .. ".txt", output)
    end
    
    return output
end

-- Usage throughout your scripts:
-- ACLogger:log("SCAN", "Found suspicious remote", remoteName)
-- ACLogger:log("HOOK", "Hooked __namecall", nil)
-- ACLogger:log("DETECT", "Got kicked", kickMessage)
```

---

## Red Flags & Indicators

### Code Patterns That Indicate AC

| Pattern | Likelihood | Description |
|---------|------------|-------------|
| `Heartbeat:Connect` + `magnitude` | High | Speed/teleport detection |
| `GetPartsInPart` on character | High | Noclip detection |
| `Raycast` + `HumanoidRootPart` | High | Fly/ground detection |
| `FireServer` in Heartbeat | High | Server-side validation |
| `getfenv` / `setfenv` | Medium | Environment checks |
| `debug.traceback` | Medium | Callstack analysis |
| `loadstring` check | Medium | Executor detection |
| Hash/checksum functions | Medium | Integrity verification |
| `string.dump` | Low-Medium | Function serialization check |
| Obfuscated variable names | Low | May hide AC logic |

### Suspicious Remote Names

```lua
local suspiciousRemotes = {
    -- Direct indicators
    "AntiCheat", "AntiExploit", "Security", "Validate",
    "Report", "Flag", "Ban", "Kick", "Check",
    
    -- Obfuscated (common patterns)
    "AC", "AE", "SEC", "VAL", "RPT",
    
    -- Generic (context-dependent)
    "Sync", "Update", "Verify", "Confirm", "Process"
}
```

### Behavioral Indicators

- **High-frequency remote calls** - AC reporting data every frame
- **Remotes with encoded/encrypted arguments** - Hiding AC data
- **Multiple Heartbeat connections** - Different checks running
- **Connections that disable on error** - Self-protecting AC
- **Scripts that re-require themselves** - Self-healing AC

---

## Tools & Scripts

| Tool | Location | Purpose |
|------|----------|---------|
| Full Scanner | `DEBUG/DECOMPILER/full_scanner.lua` | Comprehensive game scanning |
| Scanner | `GAMES/THE FORGE/scanner.lua` | Game-specific scanning |

### Quick Reference Scripts

#### One-Liner Remote Spy
```lua
for _,v in pairs(getgc(true)) do if typeof(v)=="table" and rawget(v,"FireServer") then hookfunction(v.FireServer,function(s,...)print(s,...)return s:FireServer(...)end)end end
```

#### One-Liner Connection Counter
```lua
print("Heartbeat:",#getconnections(game:GetService("RunService").Heartbeat),"RenderStepped:",#getconnections(game:GetService("RunService").RenderStepped))
```

#### One-Liner Executor Check Bypass
```lua
for _,g in pairs({"syn","fluxus","KRNL"}) do getgenv()[g]=nil end
```

---

## Game-Specific Notes

### 99 Nights
- *Add notes here*

### Deadly Delivery
- *Add notes here*

### The Forge
- *Add notes here*

---

## Contributing

When adding new techniques:
1. Document the method clearly
2. Include code examples where possible
3. Note which games/ACs it applies to
4. Mark if it's patched or still working
5. Add detection difficulty rating (Easy/Medium/Hard)
6. Include counter-detection methods if known

### Template for New Techniques
```markdown
### Technique Name
**Category:** Detection/Bypass/Analysis
**Difficulty:** Easy/Medium/Hard
**Status:** Working/Patched/Game-Specific

**Description:**
Brief explanation of what this technique does.

**Code:**
\`\`\`lua
-- Implementation here
\`\`\`

**Notes:**
- Any caveats or special considerations
- Games where this works/doesn't work
```

---

*Last Updated: 2026-01-12*

---

## Document Stats

- **Total Sections:** 14
- **Code Examples:** 50+
- **Techniques Covered:** 100+

### Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-12 | Initial release |
| 2.0 | 2026-01-12 | Added: Executor Compatibility, Obfuscation Detection, Known AC Systems, Dynamic Analysis, Anti-Anti-Cheat Detection, Scanning Workflow, Failure & Recovery |
