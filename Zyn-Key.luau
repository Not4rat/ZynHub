-- ==================================================================================================================================== --
--   ZYN HUB  v1.4.8 — purge ALL window stacks • NotArat X ZynWare ==================================================================================================================================== --

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║   CONFIG — EDIT FREELY                                                ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local HUB_NAME   = "Zyn Hub"
local WELCOME_PREFIX = "Welcome to"
local AUTHOR     = "NotArat X ZynWare"   -- credit line shown on gate footer + hub author field

local WINDOW_SIZE    = Vector2.new(512, 372)

local KEYS = {
    "zynwareontopfrfr",
}

local GAME_LOADERS = {
    [994732206]  = "loadstring(game:HttpGet("loadstring(game:HttpGet("https://raw.githubusercontent.com/Not4rat/ZynHub/refs/heads/main/Blox-Fruit.luau?token=GHSAT0AAAAAAEOMUPMFHMP62Z26IQT44DJQ2XIXH5A"))(),              -- Blox Fruits Universe
    [2753915549] = "loadstring(game:HttpGet("loadstring(game:HttpGet("https://raw.githubusercontent.com/Not4rat/ZynHub/refs/heads/main/Blox-Fruit.luau?token=GHSAT0AAAAAAEOMUPMFHMP62Z26IQT44DJQ2XIXH5A"))(),              -- Blox Fruits Sea 1
    [4442272183] = "loadstring(game:HttpGet("loadstring(game:HttpGet("https://raw.githubusercontent.com/Not4rat/ZynHub/refs/heads/main/Blox-Fruit.luau?token=GHSAT0AAAAAAEOMUPMFHMP62Z26IQT44DJQ2XIXH5A"))(),              -- Blox Fruits Sea 2
    [7449423635] = "loadstring(game:HttpGet("loadstring(game:HttpGet("https://raw.githubusercontent.com/Not4rat/ZynHub/refs/heads/main/Blox-Fruit.luau?token=GHSAT0AAAAAAEOMUPMFHMP62Z26IQT44DJQ2XIXH5A"))(),              -- Blox Fruits Sea 3
    universal    = Print("This aint Supported"),              -- fallback
}

local LOADER_LABELS = {
    [994732206]  = "Blox Fruits",
    [2753915549] = "Blox Fruits (Sea 1)",
    [4442272183] = "Blox Fruits (Sea 2)",
    [7449423635] = "Blox Fruits (Sea 3)",
}

-- Both key paths currently lead to the Discord (join -> grab key -> return).
-- Update GET_KEY_URL when the dedicated key site is live.
local GET_KEY_URL  = "https://discord.gg/QWB5p4dqye"
local DISCORD_URL  = "https://discord.gg/QWB5p4dqye"

-- QA MODE (Tris testing the wrong-key shake + minimize pill): auto-unlock temporarily OFF.
-- Say the word and I flip this back to true.
local AUTO_UNLOCK_IF_SAVED = false

local THEME = {
    BG            = Color3.fromRGB(12, 12, 12),
    TITLEBAR      = Color3.fromRGB(7, 7, 7),
    ELEMENT       = Color3.fromRGB(27, 27, 27),
    ELEMENT_INPUT = Color3.fromRGB(22, 22, 22),
    ELEMENT_HOVER = Color3.fromRGB(38, 38, 38),
    TEXT          = Color3.fromRGB(235, 235, 235),
    TEXT_DIM      = Color3.fromRGB(205, 205, 205),
    TEXT_FAINT    = Color3.fromRGB(150, 150, 150),
    ACCENT        = Color3.fromRGB(255, 112, 172),
    DANGER        = Color3.fromRGB(240, 84, 108),
    STROKE_WIN    = Color3.fromRGB(34, 34, 34),
    STROKE_SOFT   = Color3.fromRGB(37, 37, 37),
    STROKE_FAINT  = Color3.fromRGB(30, 30, 30),
    GLYPH         = Color3.fromRGB(190, 190, 190),
    GLYPH_HOVER   = Color3.fromRGB(255, 255, 255),
}

-- ╔══════════════════════════════════════════════════════════════════════╝
-- ║   END OF CONFIG — below is engine                                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local T0 = os.clock()
local function mark(label)
    print(("[ZYN] %-24s @ %.2fs"):format(label, os.clock() - T0))
end
mark("boot")

local WindUI = nil

-- Drop EVERY window stack WindUI ever parked. WindUI creates ScreenGuis named
-- "WindUI", "WindUI/Notifications", "WindUI/Dropdowns", "WindUI/Tooltips" --
-- and when two sessions stack, ALL of them share names, so FindFirstChild
-- only ever killed the first of each pair. Loop every child instead.
local function purgeWindowStacks()
    local n = 0
    local rg = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
    if rg then
        for _, c in ipairs(rg:GetChildren()) do
            if c:IsA("ScreenGui") and c.Name:sub(1, 6) == "WindUI" then
                pcall(function() c:Destroy() end)
                n += 1
            end
        end
    end
    return n
end

-- GHOST SWEEP v3: name-based purges first (they catch everything), then the
-- text climb as a last net for anything else carrying our mark.
do
    local gateShells, marked = 0, 0
    local bases = {}
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then table.insert(bases, hui) end
    local cg = game:GetService("CoreGui")
    table.insert(bases, cg)
    local plr = game:GetService("Players").LocalPlayer
    if plr and plr:FindFirstChild("PlayerGui") then table.insert(bases, plr.PlayerGui) end
    local robloxGui = cg:FindFirstChild("RobloxGui")
    if robloxGui then table.insert(bases, robloxGui) end

    -- 1) stale gate shells: one ZynHubGate ScreenGui survives per boot-history
    for _, base in ipairs(bases) do
        for _, c in ipairs(base:GetChildren()) do
            if c:IsA("ScreenGui") and c.Name == "ZynHubGate" then
                pcall(function() c:Destroy() end)
                gateShells += 1
            end
        end
    end

    -- 2) every WindUI window stack, all duplicate pairs included
    local windowStacks = purgeWindowStacks()

    -- 3) text climb for other leftovers carrying our mark
    local seen = {}
    for _, base in ipairs(bases) do
        for _, d in ipairs(base:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text
            and (d.Text:find(HUB_NAME, 1, true) or d.Text:find("ZynHub", 1, true) or d.Text:find("Key is distributed", 1, true)) then
                local node = d
                -- Climb through GuiObjects AND Folders: WindUI nests Folder inside Folder,
                -- so stopping at a Folder boundary used to leave the window shell alive.
                while node.Parent and (node.Parent:IsA("GuiObject") or node.Parent:IsA("Folder")) do
                    node = node.Parent
                end
                if (node:IsA("GuiObject") or node:IsA("Folder")) and not seen[node] then
                    seen[node] = true
                    pcall(function() node:Destroy() end)
                    marked += 1
                end
            end
        end
    end
    print(("[ZYN] ghost sweep v3: purged %d gate shell(s), %d window stack(s), %d marked frame(s)"):format(gateShells, windowStacks, marked))
end

local MarketplaceService = game:GetService("MarketplaceService")
local gameName = ("unknown place %d"):format(game.PlaceId)
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
    if info and info.Name and #info.Name > 0 then gameName = info.Name end
end)
mark("game detected: " .. gameName)

local function resolveLoader()
    if GAME_LOADERS[game.GameId] then
        local label = LOADER_LABELS[game.GameId] or ("universe %d"):format(game.GameId)
        return ("universe %d"):format(game.GameId), GAME_LOADERS[game.GameId], label
    end
    if GAME_LOADERS[game.PlaceId] then
        local label = LOADER_LABELS[game.PlaceId] or ("place %d"):format(game.PlaceId)
        return ("place %d"):format(game.PlaceId), GAME_LOADERS[game.PlaceId], label
    end
    if GAME_LOADERS["universal"] then
        return "universal", GAME_LOADERS["universal"], "Universal"
    end
    return "none", nil, "Nothing configured"
end

local bucket, loaderURL, loaderLabel = resolveLoader()
print(("[ZYN] loader bucket: %s -> %s"):format(bucket, tostring(loaderURL or "(nil)")))

local function runLoader()
    if not loaderURL then
        if WindUI then
            WindUI:Notify({ Title = HUB_NAME, Content = ("No loader configured for u%d / p%d"):format(game.GameId, game.PlaceId), Icon = "map-pin", Duration = 6 })
        end
        return
    end
    if WindUI then
        WindUI:Notify({ Title = HUB_NAME, Content = ("[%s • %s] firing loader for %s..."):format(bucket, loaderLabel, gameName), Icon = "download", Duration = 3 })
    end
    print(("[ZYN] running %s loader from %s"):format(bucket, loaderURL))
    task.spawn(function()
        local ok, first, second = pcall(function()
            local src
            if loaderURL:match("^https?://") then
                src = game:HttpGet(loaderURL)
            elseif isfile and isfile(loaderURL) then
                src = readfile(loaderURL)
            elseif isfile and isfile("Scripts/MCP/" .. loaderURL) then
                src = readfile("Scripts/MCP/" .. loaderURL)
            else
                src = game:HttpGet(loaderURL)
            end
            if type(src) ~= "string" then
                error("no body received", 0)
            end
            local head = src:sub(1, 80)
            -- BYTE GUARD: refuse to compile obvious non-script responses
            if #src < 12
            or src:sub(1, 1) == "<"
            or src:find("404", 1, true)
            or src:find("Not Found", 1, true)
            or src:find("<html", 1, true)
            or src:find("<!DOCTYPE", 1, true) then
                return nil, ("placeholder/non-script body (%d bytes): %s"):format(#src, head:sub(1, 40))
            end
            local fn, parseErr = loadstring(src, "==ZYNLOADER==")
            if not fn then
                return nil, ("script has Luau errors: %s"):format(tostring(parseErr))
            end
            fn()
            return true, nil
        end)
        if not ok then
            -- genuine runtime error from executing a loaded script (or HttpGet failure)
            local msg = "network/runtime error: " .. tostring(first)
            print("[ZYN] " .. msg)
            if WindUI then
                WindUI:Notify({ Title = "Loader failed", Content = msg .. (" (%s)"):format(loaderURL), Icon = "triangle-alert", Duration = 7 })
            end
        elseif first == nil then
            -- byte-guard rejected the body: one soft toast, zero console garbage
            local msg = tostring(second or "empty body") .. " — paste the real URL in CONFIG"
            print("[ZYN] byte guard: " .. msg)
            if WindUI then
                WindUI:Notify({ Title = "Loader skipped", Content = msg, Icon = "shield-off", Duration = 6 })
            end
        else
            print("[ZYN] loader finished cleanly")
        end
    end)
end

local function trim(s) return s and s:match("^%s*(.-)%s*$") or "" end

local function keyAccepted(entered)
    local t = trim(entered)
    for _, valid in ipairs(KEYS) do
        if t == trim(valid) then return true end
    end
    return false
end

local KEY_FILE = "ZynHub/key.txt"
local function saveKey(k)
    pcall(function()
        if type(writefile) == "function" then
            if type(isfolder) == "function" and not isfolder("ZynHub") then makefolder("ZynHub") end
            writefile(KEY_FILE, k)
            print("[ZYN] key saved to", KEY_FILE)
        end
    end)
end

local function loadSavedKey()
    local ok, saved = pcall(function()
        if type(isfile) == "function" and isfile(KEY_FILE) then
            return readfile(KEY_FILE)
        end
        return nil
    end)
    if ok then return saved end
    return nil
end

local function openHub()
    -- Never stack: drop every old window shell before building a fresh one,
    -- so the byline/title/theme are always whatever the current file says.
    local old = purgeWindowStacks()
    if old > 0 then print(("[ZYN] unlock purged %d old window stack(s)"):format(old)) end
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    mark("hub library ready")

    local Window = WindUI:CreateWindow({
        Title = HUB_NAME,
        Icon = "key-round",
        Author = ("%s • made by %s"):format(gameName, AUTHOR),
        Folder = "ZynHub",
        Size = UDim2.fromOffset(460, 330),
        Theme = "Dark",
        Transparent = true,
        ToggleKey = Enum.KeyCode.RightShift,
    })
    mark("hub window created")

    local Status = Window:Tab({ Title = "Status", Icon = "info" })
    Status:Paragraph({
        Title = "Detected Game",
        Desc = ("%s\nGame (universe) ID: %d\nPlace ID: %d"):format(gameName, game.GameId, game.PlaceId),
    })
    Status:Paragraph({
        Title = "Loader Bucket",
        Desc = bucket == "none" and "No bucket matched and no universal set." or ("%s (%s)"):format(bucket, loaderLabel),
    })
    Status:Paragraph({
        Title = "Script That Will Run",
        Desc = loaderURL and ("%s\n\nChange it in the CONFIG block of ZynHub-KeyGate.luau"):format(loaderURL) or "No URL resolved — check GAME_LOADERS.",
    })
    Status:Paragraph({
        Title = "Key",
        Desc = ("%d accepted. Future sessions auto-unlock."):format(#KEYS),
    })
    Status:Button({ Title = "Re-run Loader", Desc = "Fires the resolved loadstring again", Icon = "rotate-cw", Callback = runLoader })

    mark("gate ARMED")
    task.spawn(WindUI.Notify, WindUI, {
        Title = ("%s armed"):format(HUB_NAME),
        Content = ('"%s" detected • bucket: %s'):format(gameName, bucket),
        Icon = "key-round",
        Duration = 4,
    })
end

local function buildPrompt()
    local TS = game:GetService("TweenService")
    local UIS = game:GetService("UserInputService")

    local function makeCorner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius)
        c.Parent = parent
    end

    local function makeStroke(parent, color, thickness)
        local s = Instance.new("UIStroke")
        s.Color = color
        s.Thickness = thickness
        s.Parent = parent
        return s
    end

    local function makeHover(btn, base, hover)
        btn.MouseEnter:Connect(function()
            TS:Create(btn, TweenInfo.new(0.14), { BackgroundColor3 = hover }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TS:Create(btn, TweenInfo.new(0.18), { BackgroundColor3 = base }):Play()
        end)
    end

    local function drawDash(parent, colorHex)
        local bar = Instance.new("Frame")
        bar.Size = UDim2.fromOffset(9, 2)
        bar.AnchorPoint = Vector2.new(0.5, 0.5)
        bar.Position = UDim2.fromScale(0.5, 0.5)
        bar.BackgroundColor3 = colorHex
        bar.BorderSizePixel = 0
        bar.ZIndex = 4
        bar.Parent = parent
        makeCorner(bar, 1)
        return bar
    end

    local function drawX(parent, colorHex)
        local bars = {}
        for _, rot in ipairs({ 45, -45 }) do
            local bar = Instance.new("Frame")
            bar.Size = UDim2.fromOffset(11, 1)
            bar.AnchorPoint = Vector2.new(0.5, 0.5)
            bar.Position = UDim2.fromScale(0.5, 0.5)
            bar.Rotation = rot
            bar.BackgroundColor3 = colorHex
            bar.BorderSizePixel = 0
            bar.ZIndex = 4
            bar.Parent = parent
            table.insert(bars, bar)
        end
        return bars
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZynHubGate"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 900
    local ok, hui = pcall(function() return gethui() end)
    ScreenGui.Parent = (ok and hui) and hui or game:GetService("CoreGui")

    local Root = Instance.new("Frame")
    Root.Name = "Prompt"
    Root.Size = UDim2.fromOffset(WINDOW_SIZE.X, WINDOW_SIZE.Y)
    Root.Position = UDim2.new(0.5, -WINDOW_SIZE.X / 2, 0.5, -WINDOW_SIZE.Y / 2)
    Root.BackgroundColor3 = THEME.BG
    Root.BorderSizePixel = 0
    Root.ZIndex = 2
    Root.Parent = ScreenGui
    makeCorner(Root, 9)
    makeStroke(Root, THEME.STROKE_WIN, 1)

    local Strip = Instance.new("Frame")
    Strip.Name = "Strip"
    Strip.Size = UDim2.new(1, 0, 0, 22)
    Strip.BackgroundColor3 = THEME.TITLEBAR
    Strip.BorderSizePixel = 0
    Strip.ZIndex = 3
    Strip.Parent = Root
    makeCorner(Strip, 6)

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 22)
    TitleBar.BackgroundTransparency = 1
    TitleBar.ZIndex = 5
    TitleBar.Parent = Root

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.fromOffset(220, 18)
    TitleText.Position = UDim2.new(0, 9, 0, 2)
    TitleText.BackgroundTransparency = 1
    TitleText.ZIndex = 5
    TitleText.Font = Enum.Font.Gotham
    TitleText.TextSize = 12
    TitleText.TextColor3 = Color3.fromRGB(210, 210, 210)
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Text = HUB_NAME
    TitleText.Parent = TitleBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.fromOffset(28, 18)
    MinBtn.Position = UDim2.new(1, -60, 0, 2)
    MinBtn.BackgroundTransparency = 1
    MinBtn.AutoButtonColor = false
    MinBtn.BorderSizePixel = 0
    MinBtn.ZIndex = 6
    MinBtn.Parent = TitleBar
    local minGlyph = drawDash(MinBtn, THEME.GLYPH)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.fromOffset(28, 18)
    CloseBtn.Position = UDim2.new(1, -32, 0, 2)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.AutoButtonColor = false
    CloseBtn.BorderSizePixel = 0
    CloseBtn.ZIndex = 6
    CloseBtn.Parent = TitleBar
    local xGlyphs = drawX(CloseBtn, THEME.GLYPH)

    MinBtn.MouseEnter:Connect(function()
        TS:Create(minGlyph, TweenInfo.new(0.12), { BackgroundColor3 = THEME.GLYPH_HOVER }):Play()
    end)
    MinBtn.MouseLeave:Connect(function()
        TS:Create(minGlyph, TweenInfo.new(0.16), { BackgroundColor3 = THEME.GLYPH }):Play()
    end)
    CloseBtn.MouseEnter:Connect(function()
        for _, b in ipairs(xGlyphs) do
            TS:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = THEME.DANGER }):Play()
        end
    end)
    CloseBtn.MouseLeave:Connect(function()
        for _, b in ipairs(xGlyphs) do
            TS:Create(b, TweenInfo.new(0.16), { BackgroundColor3 = THEME.GLYPH }):Play()
        end
    end)

    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Root.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local Welcome = Instance.new("TextLabel")
    Welcome.Size = UDim2.new(1, 0, 0, 20)
    Welcome.Position = UDim2.new(0, 0, 0, 92)
    Welcome.BackgroundTransparency = 1
    Welcome.ZIndex = 3
    Welcome.Font = Enum.Font.GothamBold
    Welcome.TextSize = 15
    Welcome.TextColor3 = Color3.fromRGB(224, 224, 224)
    Welcome.Text = WELCOME_PREFIX
    Welcome.Parent = Root

    local HubName = Instance.new("TextLabel")
    HubName.Size = UDim2.new(1, 0, 0, 42)
    HubName.Position = UDim2.new(0, 0, 0, 114)
    HubName.BackgroundTransparency = 1
    HubName.ZIndex = 3
    HubName.Font = Enum.Font.GothamBlack
    HubName.TextSize = 30
    HubName.TextColor3 = Color3.new(1, 1, 1)
    HubName.Text = HUB_NAME
    HubName.Parent = Root

    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.fromOffset(330, 36)
    KeyBox.Position = UDim2.new(0.5, -165, 0, 186)
    KeyBox.BackgroundColor3 = THEME.ELEMENT_INPUT
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.TextSize = 14
    KeyBox.TextColor3 = THEME.TEXT
    KeyBox.PlaceholderColor3 = THEME.TEXT_FAINT
    KeyBox.PlaceholderText = ""
    KeyBox.ClearTextOnFocus = false
    KeyBox.Text = ""
    KeyBox.BorderSizePixel = 0
    KeyBox.ZIndex = 3
    KeyBox.Parent = Root
    makeCorner(KeyBox, 5)
    local BoxStroke = makeStroke(KeyBox, THEME.STROKE_SOFT, 1)

    local ErrorLabel = Instance.new("TextLabel")
    ErrorLabel.Size = UDim2.new(1, 0, 0, 16)
    ErrorLabel.Position = UDim2.new(0, 0, 0, 228)
    ErrorLabel.BackgroundTransparency = 1
    ErrorLabel.ZIndex = 3
    ErrorLabel.Font = Enum.Font.Gotham
    ErrorLabel.TextSize = 12
    ErrorLabel.TextColor3 = THEME.DANGER
    ErrorLabel.TextTransparency = 1
    ErrorLabel.Text = "Wrong key — try again"
    ErrorLabel.Parent = Root

    local function makeBtn(text, x, y, w, baseColor, hoverColor)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(w, 34)
        b.Position = UDim2.new(0, x, 0, y)
        b.BackgroundColor3 = baseColor or THEME.ELEMENT
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.fromRGB(214, 214, 214)
        b.Text = text
        b.AutoButtonColor = false
        b.BorderSizePixel = 0
        b.ZIndex = 3
        b.Parent = Root
        makeCorner(b, 5)
        makeStroke(b, THEME.STROKE_FAINT, 1)
        makeHover(b, baseColor or THEME.ELEMENT, hoverColor or THEME.ELEMENT_HOVER)
        return b
    end

    local half = math.floor(WINDOW_SIZE.X / 2)
    local SubmitBtn = makeBtn("Submit", half + 6, 252, 118)
    local GetKeyBtn = nil
    if GET_KEY_URL ~= "" then
        GetKeyBtn = makeBtn("Get Key", half - 124, 252, 118)
    else
        SubmitBtn.Position = UDim2.new(0.5, -59, 0, 252)
    end

    local function copyText(text)
        local ok, fns = pcall(function()
            return { getfenv().setclipboard, getfenv().toclipboard, getfenv()["copyClipboard"] }
        end)
        if not ok or type(fns) ~= "table" then return false end
        for _, f in ipairs(fns) do
            if type(f) == "function" then
                local okc = pcall(f, text)
                if okc then return true end
            end
        end
        return false
    end

    if GetKeyBtn then
        GetKeyBtn.MouseButton1Click:Connect(function()
            if copyText(GET_KEY_URL) then
                mark("get key — copied " .. GET_KEY_URL)
                ErrorLabel.Text = "Link copied — paste it in your browser"
                ErrorLabel.TextColor3 = THEME.TEXT_DIM
                TS:Create(ErrorLabel, TweenInfo.new(0.16), { TextTransparency = 0 }):Play()
            else
                mark("get key — no clipboard function")
                ErrorLabel.Text = ("Get key: %s"):format(GET_KEY_URL)
                ErrorLabel.TextColor3 = THEME.TEXT_DIM
                TS:Create(ErrorLabel, TweenInfo.new(0.16), { TextTransparency = 0 }):Play()
            end
            task.delay(3.5, function() TS:Create(ErrorLabel, TweenInfo.new(0.6), { TextTransparency = 1 }):Play() end)
        end)
    end

    if DISCORD_URL ~= "" then
        local DiscordBtn = makeBtn("Join Discord Server", math.floor((WINDOW_SIZE.X - 330) / 2), 298, 330)
        DiscordBtn.MouseButton1Click:Connect(function()
            if copyText(DISCORD_URL) then
                ErrorLabel.Text = "Discord invite copied — paste it in your browser"
                ErrorLabel.TextColor3 = THEME.TEXT_DIM
                TS:Create(ErrorLabel, TweenInfo.new(0.16), { TextTransparency = 0 }):Play()
                task.delay(3, function() TS:Create(ErrorLabel, TweenInfo.new(0.6), { TextTransparency = 1 }):Play() end)
            else
                ErrorLabel.Text = ("Discord: %s"):format(DISCORD_URL)
                ErrorLabel.TextColor3 = THEME.TEXT_DIM
                TS:Create(ErrorLabel, TweenInfo.new(0.16), { TextTransparency = 0 }):Play()
                task.delay(4, function() TS:Create(ErrorLabel, TweenInfo.new(0.6), { TextTransparency = 1 }):Play() end)
            end
        end)
    end

    local unlocked = false

    -- ANCHORED SHAKE: every beat holds the base position and jitters ONLY the offset,
    -- so the box never teleports or slides — it just shivers in place.
    local SHAKE_BASE_X, SHAKE_BASE_Y = -165, 186
    local function shakeBox()
        task.spawn(function()
            for _, dX in ipairs({ 12, -12, 9, -9, 5, 0 }) do
                TS:Create(KeyBox, TweenInfo.new(0.05, Enum.EasingStyle.Linear), { Position = UDim2.new(0.5, SHAKE_BASE_X + dX, 0, SHAKE_BASE_Y) }):Play()
                task.wait(0.05)
            end
            TS:Create(KeyBox, TweenInfo.new(0.08, Enum.EasingStyle.Quint), { Position = UDim2.new(0.5, SHAKE_BASE_X, 0, SHAKE_BASE_Y) }):Play()
        end)
    end

    local function trySubmit()
        local val = KeyBox.Text
        if keyAccepted(val) then
            if not unlocked then
                unlocked = true
                saveKey(trim(val))
                mark("key accepted — opening hub")
                TS:Create(Root, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { Position = UDim2.new(0.5, -WINDOW_SIZE.X / 2, 0.5, -WINDOW_SIZE.Y / 2 - 26) }):Play()
                for _, d in ipairs(Root:GetDescendants()) do
                    if d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("TextButton") then
                        TS:Create(d, TweenInfo.new(0.35, Enum.EasingStyle.Quint), { TextTransparency = 0.4 }):Play()
                    end
                end
                task.delay(0.3, function()
                    ScreenGui:Destroy()
                    openHub()
                end)
            end
        else
            ErrorLabel.TextColor3 = THEME.DANGER
            ErrorLabel.Text = "Wrong key — try again"
            TS:Create(ErrorLabel, TweenInfo.new(0.16), { TextTransparency = 0 }):Play()
            TS:Create(BoxStroke, TweenInfo.new(0.16), { Color = THEME.DANGER }):Play()
            task.delay(0.45, function()
                TS:Create(BoxStroke, TweenInfo.new(0.4), { Color = THEME.STROKE_SOFT }):Play()
            end)
            shakeBox()
        end
    end

    SubmitBtn.MouseButton1Click:Connect(trySubmit)
    KeyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then trySubmit() end
    end)

    MinBtn.MouseButton1Click:Connect(function()
        Root.Visible = false
        local pill = Instance.new("TextButton")
        pill.Name = "ZynHubPill"
        pill.ZIndex = 50
        pill.Size = UDim2.fromOffset(96, 32)
        -- Docked top-middle of the screen, independent of where the card was dragged
        pill.Position = UDim2.new(0.5, -48, 0, 12)
        pill.BackgroundColor3 = THEME.TITLEBAR
        pill.Font = Enum.Font.GothamBold
        pill.TextSize = 14
        pill.TextColor3 = THEME.TEXT_DIM
        pill.Text = HUB_NAME
        pill.AutoButtonColor = false
        pill.BorderSizePixel = 0
        pill.Parent = ScreenGui
        makeCorner(pill, 8)
        makeStroke(pill, THEME.STROKE_WIN, 1)
        local pd, ds, sp
        pill.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                pd = true
                ds = input.Position
                sp = pill.Position
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if pd and input.UserInputType == Enum.UserInputType.MouseMovement then
                pill.Position = UDim2.new(sp.X.Scale, sp.X.Offset + input.Position.X - ds.X, sp.Y.Scale, sp.Y.Offset + input.Position.Y - ds.Y)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then pd = false end
        end)
        pill.MouseButton1Click:Connect(function()
            pill:Destroy()
            Root.Visible = true
        end)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        print("[ZYN] gate closed — rejoin to recall it")
        ScreenGui:Destroy()
    end)

    -- quiet credit line under the Discord button
    local Credit = Instance.new("TextLabel")
    Credit.Size = UDim2.new(1, 0, 0, 16)
    Credit.Position = UDim2.new(0, 0, 0, 340)
    Credit.BackgroundTransparency = 1
    Credit.ZIndex = 3
    Credit.Font = Enum.Font.Gotham
    Credit.TextSize = 11
    Credit.TextColor3 = Color3.fromRGB(120, 120, 120)
    Credit.Text = ("made by %s"):format(AUTHOR)
    Credit.Parent = Root

    mark("prompt rendered")
end

local savedKey = loadSavedKey()
if AUTO_UNLOCK_IF_SAVED and savedKey and keyAccepted(savedKey) then
    print("[ZYN] saved key validated — auto-unlock, skipping prompt")
    openHub()
else
    buildPrompt()
    print(("[ZYN] gate live — %d key(s) accepted"):format(#KEYS))
end
