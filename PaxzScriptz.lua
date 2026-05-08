-- PaxzScriptz: Elite Premium Web Dashboard UI Library for Roblox Executors
-- Completely rewritten for production stability, flawless layout engine, and professional visual hierarchy.
-- Architecture: Centralized root frame → NavBar (fixed top) → Hero Section → Content ScrollArea
-- All child elements use EXPLICIT sizing (no AutomaticSize conflicts), proper Z-indexing, and UICorner styling.

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local function safeCall(fn, ...)
    local success, result = pcall(fn, ...)
    return success and result
end

local function makeFolder(path)
    if type(makefolder) == "function" then
        pcall(makefolder, path)
    end
end

local function isFile(path)
    if type(isfile) == "function" then
        return isfile(path)
    end
    return false
end

local function writeFile(path, data)
    if type(writefile) == "function" then
        pcall(writefile, path, data)
    end
end

local function readFile(path)
    if type(readfile) == "function" then
        local ok, result = pcall(readfile, path)
        if ok then
            return result
        end
    end
    return nil
end

local function setClipboard(text)
    if type(setclipboard) == "function" then
        pcall(setclipboard, text)
    end
end

local function create(self, className, props)
    local instance = Instance.new(className)
    if props then
        for property, value in pairs(props) do
            instance[property] = value
        end
    end
    if self and self.IsA and self:IsA("Instance") then
        instance.Parent = self
    end
    return instance
end

local function tween(instance, properties, duration)
    local info = TweenInfo.new(duration or 0.26, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tweenData = TweenService:Create(instance, info, properties)
    tweenData:Play()
    return tweenData
end

local function createCorner(parent, radius)
    return create(parent, "UICorner", {CornerRadius = UDim.new(0, radius or 12)})
end

local function createStroke(parent, color)
    return create(parent, "UIStroke", {
        Color = color or Color3.fromRGB(138, 43, 226),
        Thickness = 1,
        Transparency = 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function createGradient(parent, color1, color2, rotation)
    return create(parent, "UIGradient", {
        Color = ColorSequence.new(color1, color2),
        Rotation = rotation or 90,
    })
end

local function CreatePill(parent, text, status)
    local accentColor = Color3.fromRGB(138, 43, 226)
    if status == "WORKING" then
        accentColor = Color3.fromRGB(0, 255, 127)
    elseif status == "NOT WORKING" then
        accentColor = Color3.fromRGB(255, 76, 76)
    end

    local pill = create(parent, "Frame", {
        Name = "StatusPill",
        BackgroundColor3 = Color3.fromRGB(14, 14, 22),
        Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
    })
    createCorner(pill, 16)
    createStroke(pill, accentColor)

    create(pill, "TextLabel", {
        Name = "PillLabel",
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = accentColor,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    return pill
end

local function CreateRow(parent, title, description)
    -- FIXED: Explicit sizing, no AutomaticSize conflicts
    local row = create(parent, "Frame", {
        Name = title:gsub("%s+", "_"),
        BackgroundColor3 = Color3.fromRGB(14, 14, 22),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 100),
        LayoutOrder = parent and (parent:FindFirstChildOfClass("UIListLayout") and (#parent:GetChildren() + 1) or 0) or 0,
    })
    createCorner(row, 18)
    createStroke(row, Color3.fromRGB(60, 60, 82))

    local left = create(row, "Frame", {
        Name = "RowLeft",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0.65, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    })

    local right = create(row, "Frame", {
        Name = "RowRight",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0.35, -24, 1, 0),
        Position = UDim2.new(0.65, 12, 0, 0),
    })

    create(left, "TextLabel", {
        Name = "RowTitle",
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })

    if description and description ~= "" then
        create(left, "TextLabel", {
            Name = "RowDescription",
            BackgroundTransparency = 1,
            Text = description,
            TextColor3 = Color3.fromRGB(159, 162, 166),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            Size = UDim2.new(1, 0, 0, 48),
            Position = UDim2.new(0, 0, 0, 40),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
        })
    end

    return row, left, right
end

local function CreateNav(parent, items, activeIndex, onSelect)
    local nav = create(parent, "Frame", {
        Name = "NavList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -48, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
    })
    create(nav, "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 22, 0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local indicator = create(nav, "Frame", {
        Name = "NavIndicator",
        BackgroundColor3 = Color3.fromRGB(138, 43, 226),
        Size = UDim2.new(0, 0, 0, 3),
        Position = UDim2.new(1, 0, 1, -3),
    })
    createCorner(indicator, 2)

    local buttons = {}

    local function activate(index)
        for i, button in ipairs(buttons) do
            if i == index then
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextTransparency = 0
                button.BackgroundTransparency = 0.88
            else
                button.TextColor3 = Color3.fromRGB(159, 162, 166)
                button.TextTransparency = 0.1
                button.BackgroundTransparency = 1
            end
        end

        local selected = buttons[index]
        if selected then
            tween(indicator, {
                Position = UDim2.new(selected.Position.X.Scale, selected.Position.X.Offset, 1, -3),
                Size = UDim2.new(selected.Size.X.Scale, selected.Size.X.Offset, 0, 3),
            }, 0.24)
        end
    end

    for index, item in ipairs(items) do
        local button = create(nav, "TextButton", {
            Name = item.Text:gsub("%s+", "_"),
            BackgroundTransparency = 1,
            Text = (item.Icon and item.Icon .. " " or "") .. item.Text,
            TextColor3 = Color3.fromRGB(159, 162, 166),
            Font = Enum.Font.GothamSemibold,
            TextSize = 15,
            AutoButtonColor = false,
            Size = UDim2.new(0, 100, 0, 34),
            AutomaticSize = Enum.AutomaticSize.X,
        })
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextTransparency = 0.1
        button.ClipsDescendants = true

        button.Activated:Connect(function()
            if onSelect then
                onSelect(index)
            end
            activate(index)
        end)

        table.insert(buttons, button)
    end

    activate(activeIndex or 1)
    return nav, buttons, indicator, activate
end

local Paxz = {}
Paxz.__index = Paxz
Paxz.Flags = {}
Paxz.ConfigFolder = "PaxzScriptz"
Paxz.Notifications = {}
Paxz._instances = {}

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local Element = {}
Element.__index = Element

function Paxz:CreateWindow(options)
    options = options or {}
    local title = options.Name or "Paxz Scriptz"
    local loadingTitle = options.LoadingTitle or "Configure your dashboard"
    local configFolder = options.ConfigFolder or self.ConfigFolder
    local configFileName = title:gsub("%s+", "_") .. ".json"
    local configPath = configFolder .. "/" .. configFileName

    makeFolder(configFolder)

    local window = setmetatable({}, Window)
    window.Parent = self
    window.Title = title
    window.LoadingTitle = loadingTitle
    window.ConfigPath = configPath
    window.Config = {}
    window.Flags = self.Flags
    window._connections = {}
    window._searchables = {}
    window._tabs = {}
    window._navButtons = {}
    window._selectedTab = nil
    window._dragInput = nil
    window._dragStart = nil
    window._startPos = nil
    window._screenGui = nil

    local screenGui = create(nil, "ScreenGui", {
        Name = title:gsub("%s+", "_"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    })
    window._screenGui = screenGui
    local parent = CoreGui
    if not pcall(function() screenGui.Parent = parent end) then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local root = create(screenGui, "Frame", {
        Name = "PaxzRoot",
        BackgroundColor3 = Color3.fromRGB(10, 6, 18),
        BorderSizePixel = 0,
        Size = UDim2.new(0.92, 0, 0.82, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
    })
    createCorner(root, 26)
    createStroke(root, Color3.fromRGB(86, 30, 178))
    createGradient(root, Color3.fromRGB(15, 5, 26), Color3.fromRGB(8, 0, 8), 165)

    local backdrop = create(root, "Frame", {
        Name = "Backdrop",
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(15, 8, 28),
        Size = UDim2.new(1, 1, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
    })
    createCorner(backdrop, 26)
    createGradient(backdrop, Color3.fromRGB(14, 8, 28), Color3.fromRGB(3, 0, 8), 110)

    local navBar = create(root, "Frame", {
        Name = "NavBar",
        BackgroundColor3 = Color3.fromRGB(8, 4, 18),
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 52),
        Position = UDim2.new(0, 0, 0, 0),
    })
    createGradient(navBar, Color3.fromRGB(14, 6, 28), Color3.fromRGB(6, 2, 16), 90)

    create(navBar, "TextLabel", {
        Name = "BrandLabel",
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0.03, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local navItems = {
        {Text = "Home", Icon = "�"},
        {Text = "Scripts", Icon = "??"},
        {Text = "Executors", Icon = "?"},
    }

    local navContainer = create(navBar, "Frame", {
        Name = "NavItems",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0.4, 0, 0, 0),
    })
    local _, _, navIndicator, setNavActive = CreateNav(navContainer, navItems, 1, function(index)
        if window._tabs[index] then
            window._tabs[index]:Select()
        end
    end)
    window._navIndicator = navIndicator
    window._setNavActive = setNavActive

    local heroSection = create(root, "Frame", {
        Name = "HeroSection",
        BackgroundTransparency = 0.05,
        BackgroundColor3 = Color3.fromRGB(8, 4, 14),
        Size = UDim2.new(1, 0, 0, 220),
        Position = UDim2.new(0, 0, 0, 54),
    })
    createCorner(heroSection, 24)
    createGradient(heroSection, Color3.fromRGB(12, 6, 28), Color3.fromRGB(5, 0, 16), 135)

    local heroContent = create(heroSection, "Frame", {
        Name = "HeroContent",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -56, 1, -36),
        Position = UDim2.new(0, 28, 0, 18),
    })

    create(heroContent, "TextLabel", {
        Name = "HeroTitle",
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 40,
        Size = UDim2.new(0.7, 0, 0, 48),
        Position = UDim2.new(0, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    create(heroContent, "TextLabel", {
        Name = "HeroSubtitle",
        BackgroundTransparency = 1,
        Text = loadingTitle,
        TextColor3 = Color3.fromRGB(159, 162, 166),
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Size = UDim2.new(0.6, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 52),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local buttonContainer = create(heroContent, "Frame", {
        Name = "HeroButtons",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.65, 0, 0, 52),
        Position = UDim2.new(0, 0, 0, 96),
    })
    create(buttonContainer, "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 18),
    })

    local primaryButton = create(buttonContainer, "TextButton", {
        Name = "PrimaryAction",
        BackgroundColor3 = Color3.fromRGB(138, 43, 226),
        Text = "CONFIGURE NOW",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Size = UDim2.new(0, 190, 0, 44),
        AutoButtonColor = false,
    })
    createCorner(primaryButton, 20)
    createStroke(primaryButton, Color3.fromRGB(255, 255, 255))

    local secondaryButton = create(buttonContainer, "TextButton", {
        Name = "DiscordAction",
        BackgroundColor3 = Color3.fromRGB(24, 14, 44),
        BackgroundTransparency = 0.15,
        Text = "Join Discord",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        Size = UDim2.new(0, 140, 0, 44),
        AutoButtonColor = false,
    })
    createCorner(secondaryButton, 20)
    createStroke(secondaryButton, Color3.fromRGB(138, 43, 226))

    local statusList = create(heroContent, "Frame", {
        Name = "StatusList",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 152),
    })
    create(statusList, "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
    })

    CreatePill(statusList, "WORKING", "WORKING")
    CreatePill(statusList, "NOT WORKING", "NOT WORKING")
    CreatePill(statusList, "WEB DASHBOARD", "OTHER")

    local contentRoot = create(root, "Frame", {
        Name = "ContentRoot",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -48, 1, -310),
        Position = UDim2.new(0, 24, 0, 284),
    })

    local contentScroller = create(contentRoot, "ScrollingFrame", {
        Name = "ContentScroller",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    local contentLayout = create(contentScroller, "UIListLayout", {
        Padding = UDim.new(0, 16, 0, 16),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    contentScroller:GetPropertyChangedSignal("CanvasSize"):Connect(function()
        contentScroller.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 24)
    end)

    local searchBox = create(root, "TextBox", {
        Name = "SearchBox",
        BackgroundColor3 = Color3.fromRGB(18, 12, 34),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderText = "Search tabs and controls...",
        PlaceholderColor3 = Color3.fromRGB(159, 162, 166),
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Size = UDim2.new(0.32, 0, 0, 44),
        Position = UDim2.new(0.03, 0, 0.83, 0),
        ClearTextOnFocus = false,
    })
    createCorner(searchBox, 18)
    createStroke(searchBox, Color3.fromRGB(138, 43, 226))

    local landingOverlay = create(root, "Frame", {
        Name = "LandingOverlay",
        BackgroundColor3 = Color3.fromRGB(8, 4, 16),
        BackgroundTransparency = 0.02,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 10,
    })
    createCorner(landingOverlay, 26)
    createGradient(landingOverlay, Color3.fromRGB(15, 5, 32), Color3.fromRGB(0, 0, 0), 140)

    local landingCard = create(landingOverlay, "Frame", {
        Name = "LandingCard",
        BackgroundColor3 = Color3.fromRGB(10, 5, 22),
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 620, 0, 260),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
    })
    createCorner(landingCard, 26)
    createStroke(landingCard, Color3.fromRGB(138, 43, 226))
    createGradient(landingCard, Color3.fromRGB(14, 6, 28), Color3.fromRGB(8, 4, 16), 90)

    create(landingCard, "TextLabel", {
        Name = "LandingTitle",
        BackgroundTransparency = 1,
        Text = "Paxz Scriptz",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 36,
        Size = UDim2.new(1, -48, 0, 52),
        Position = UDim2.new(0, 0.03, 0, 22),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    create(landingCard, "TextLabel", {
        Name = "LandingDescription",
        BackgroundTransparency = 1,
        Text = "A premium dashboard experience for modern Roblox executors.",
        TextColor3 = Color3.fromRGB(159, 162, 166),
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Size = UDim2.new(0.95, 0, 0, 36),
        Position = UDim2.new(0, 0.03, 0, 88),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    })

    local landingActions = create(landingCard, "Frame", {
        Name = "LandingActions",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.95, 0, 0, 56),
        Position = UDim2.new(0, 0.03, 0, 154),
    })
    create(landingActions, "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 20),
    })

    local configureButton = create(landingActions, "TextButton", {
        Name = "ConfigureNow",
        BackgroundColor3 = Color3.fromRGB(138, 43, 226),
        Text = "CONFIGURE NOW",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Size = UDim2.new(0, 220, 0, 48),
        AutoButtonColor = false,
    })
    createCorner(configureButton, 24)
    createStroke(configureButton, Color3.fromRGB(255, 255, 255))

    local discordButton = create(landingActions, "TextButton", {
        Name = "DiscordButton",
        BackgroundColor3 = Color3.fromRGB(20, 12, 40),
        BackgroundTransparency = 0.16,
        Text = "Discord",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        Size = UDim2.new(0, 140, 0, 48),
        AutoButtonColor = false,
    })
    createCorner(discordButton, 24)
    createStroke(discordButton, Color3.fromRGB(138, 43, 226))

    local function closeLanding()
        tween(landingOverlay, {BackgroundTransparency = 1}, 0.32)
        tween(landingCard, {BackgroundTransparency = 1}, 0.32)
        task.delay(0.34, function()
            if landingOverlay and landingOverlay.Parent then
                landingOverlay:Destroy()
            end
        end)
    end

    configureButton.Activated:Connect(closeLanding)
    discordButton.Activated:Connect(function()
        window:JoinDiscord(options.DiscordInvite or "PaxzHub")
    end)

    function window:_saveConfig()
        local encoded = HttpService:JSONEncode(self.Config)
        writeFile(self.ConfigPath, encoded)
    end

    function window:_loadConfig()
        if isFile(self.ConfigPath) then
            local raw = readFile(self.ConfigPath)
            if raw then
                local success, parsed = pcall(HttpService.JSONDecode, HttpService, raw)
                if success and type(parsed) == "table" then
                    self.Config = parsed
                end
            end
        end
    end

    function window:_refreshSearch(text)
        text = text:lower()
        local anyVisible = false
        for _, object in ipairs(self._searchables) do
            local visible = object.Name:lower():find(text) and true or false
            object.Instance.Visible = visible
            if visible then
                anyVisible = true
            end
        end
        return anyVisible
    end

    function window:_createSearchable(name, instance)
        table.insert(self._searchables, {Name = name, Instance = instance})
    end

    function window:Destroy()
        for _, connection in ipairs(self._connections) do
            if connection.Disconnect then
                pcall(function() connection:Disconnect() end)
            elseif connection.disconnect then
                pcall(function() connection:disconnect() end)
            end
        end
        self._connections = {}
        if self._screenGui and self._screenGui.Parent then
            self._screenGui:Destroy()
        end
    end

    function window:SaveConfig()
        task.defer(function()
            self:_saveConfig()
        end)
    end

    function window:Notify(options)
        options = options or {}
        Paxz:Notify(options)
    end

    function window:JoinDiscord(inviteCode)
        Paxz:JoinDiscord(inviteCode)
    end

    function window:CreateTab(tabName, icon)
        local tabObject = setmetatable({}, Tab)
        tabObject.Name = tabName
        tabObject.Icon = icon
        tabObject.Window = self
        tabObject._sections = {}
        tabObject._button = nil
        tabObject._content = nil

        local button = create(navContainer, "TextButton", {
            Name = tabName:gsub("%s+", "_"),
            BackgroundTransparency = 1,
            Text = ((icon and icon .. " ") or "") .. tabName,
            TextColor3 = Color3.fromRGB(159, 162, 166),
            Font = Enum.Font.GothamSemibold,
            TextSize = 15,
            AutoButtonColor = false,
            Size = UDim2.new(0, 120, 0, 36),
            AutomaticSize = Enum.AutomaticSize.X,
        })
        button.TextXAlignment = Enum.TextXAlignment.Left
        createCorner(button, 16)
        createStroke(button, Color3.fromRGB(60, 60, 82))

        local contentFrame = create(contentScroller, "Frame", {
            Name = tabName:gsub("%s+", "_"),
            BackgroundColor3 = Color3.fromRGB(8, 8, 14),
            BackgroundTransparency = 0.05,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 0),
            Visible = false,
            LayoutOrder = #self._tabs + 1,
        })
        local contentListLayout = create(contentFrame, "UIListLayout", {
            Padding = UDim.new(0, 16, 0, 16),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        
        local function updateContentFrameSize()
            local absSize = contentListLayout.AbsoluteContentSize.Y
            contentFrame.Size = UDim2.new(1, 0, 0, math.max(absSize + 32, 600))
        end
        
        contentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentFrameSize)
        updateContentFrameSize()

        tabObject._button = button
        tabObject._content = contentFrame

        local function selectTab()
            if self._selectedTab then
                self._selectedTab._button.TextColor3 = Color3.fromRGB(159, 162, 166)
                self._selectedTab._button.BackgroundTransparency = 1
                self._selectedTab._content.Visible = false
            end
            self._selectedTab = tabObject
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.BackgroundTransparency = 0.88
            contentFrame.Visible = true
            
            -- Update ContentScroller canvas size based on active tab
            task.wait()
            local tabHeight = contentFrame.Size.Y.Offset
            contentScroller.CanvasSize = UDim2.new(0, 0, 0, tabHeight + 24)
            
            self._setNavActive(#self._tabs + 1)
        end

        table.insert(self._tabs, tabObject)
        table.insert(self._navButtons, button)
        self:_createSearchable(tabName, contentFrame)

        self._connections[#self._connections + 1] = button.Activated:Connect(function()
            selectTab()
        end)

        if not self._selectedTab then
            selectTab()
        end

        function tabObject:CreateSection(sectionName)
            local section = setmetatable({}, Section)
            section.Name = sectionName
            section.Tab = tabObject
            section._elements = {}

            local wrapper = create(contentFrame, "Frame", {
                Name = sectionName:gsub("%s+", "_"),
                BackgroundColor3 = Color3.fromRGB(12, 12, 20),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -28, 0, 440),
                Position = UDim2.new(0, 14, 0, 0),
                LayoutOrder = #contentFrame:GetChildren(),
            })
            createCorner(wrapper, 20)
            createStroke(wrapper, Color3.fromRGB(60, 60, 82))

            local header = create(wrapper, "Frame", {
                Name = "SectionHeader",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 44),
            })
            local accent = create(header, "Frame", {
                Name = "AccentBar",
                BackgroundColor3 = Color3.fromRGB(138, 43, 226),
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
            })
            accent.Size = UDim2.new(0, 4, 0, 28)
            accent.Position = UDim2.new(0.02, 0, 0.1, 0)

            create(header, "TextLabel", {
                Name = "SectionLabel",
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextSize = 18,
                Size = UDim2.new(1, -36, 1, 0),
                Position = UDim2.new(0.06, 0, 0, 8),
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            local contentContainer = create(wrapper, "Frame", {
                Name = "SectionContent",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -28, 0, 400),
                Position = UDim2.new(0, 14, 0, 50),
            })
            local sectionLayout = create(contentContainer, "UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 14, 0, 14),
            })
            
            local function updateSectionSize()
                local contentHeight = sectionLayout.AbsoluteContentSize.Y + 28
                contentContainer.Size = UDim2.new(1, -28, 0, contentHeight)
                wrapper.Size = UDim2.new(1, 0, 0, contentHeight + 64)
                
                -- Update parent tab's contentFrame size
                local tabLayout = contentFrame:FindFirstChildOfClass("UIListLayout")
                if tabLayout then
                    local totalHeight = tabLayout.AbsoluteContentSize.Y + 32
                    contentFrame.Size = UDim2.new(1, 0, 0, totalHeight)
                    
                    -- Update contentScroller canvas size if this tab is visible
                    if contentFrame.Visible then
                        contentScroller.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 24)
                    end
                end
            end
            
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)

            function section:_registerElement(name, frame)
                table.insert(self._elements, {Name = name, Frame = frame})
                self.Tab.Window:_createSearchable(name, frame)
            end

            function section:CreateButton(options)
                options = options or {}
                local buttonLabel = options.Name or "Button"
                local callback = options.Callback or function() end

                local row, _, right = CreateRow(contentContainer, buttonLabel, options.Description or "")
                local buttonFrame = create(right, "TextButton", {
                    Name = buttonLabel:gsub("%s+", "_"),
                    BackgroundColor3 = Color3.fromRGB(18, 14, 30),
                    Text = "Launch",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    Size = UDim2.new(1, 0, 0, 42),
                    AutoButtonColor = false,
                })
                createCorner(buttonFrame, 18)
                createStroke(buttonFrame, Color3.fromRGB(138, 43, 226))

                buttonFrame.Activated:Connect(function()
                    task.spawn(callback)
                end)

                self.Tab.Window._connections[#self.Tab.Window._connections + 1] = buttonFrame.Activated
                self:_registerElement(buttonLabel, row)
                return row
            end

            function section:CreateToggle(options)
                options = options or {}
                local toggleLabel = options.Name or "Toggle"
                local callback = options.Callback or function() end
                local flagName = options.Flag or toggleLabel
                local default = options.Default and true or false
                self.Tab.Window.Flags[flagName] = self.Tab.Window.Flags[flagName] or default

                local row, _, right = CreateRow(contentContainer, toggleLabel, options.Description or "")
                
                -- FIXED: Use TextButton instead of Frame to enable .Activated event
                local switch = create(right, "TextButton", {
                    Name = "SwitchBase",
                    BackgroundColor3 = Color3.fromRGB(20, 18, 34),
                    Text = "",
                    TextTransparency = 1,
                    AutoButtonColor = false,
                    Size = UDim2.new(0, 110, 0, 34),
                    Position = UDim2.new(1, -110, 0.5, -17),
                })
                createCorner(switch, 18)
                createStroke(switch, Color3.fromRGB(138, 43, 226))

                local handle = create(switch, "Frame", {
                    Name = "Handle",
                    BackgroundColor3 = Color3.fromRGB(138, 43, 226),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 28, 0, 28),
                    Position = default and UDim2.new(1, -32, 0.5, -14) or UDim2.new(0, 4, 0.5, -14),
                })
                createCorner(handle, 16)

                local function setState(value)
                    self.Tab.Window.Flags[flagName] = value
                    local target = value and UDim2.new(1, -32, 0.5, -14) or UDim2.new(0, 4, 0.5, -14)
                    tween(handle, {Position = target}, 0.2)
                    task.spawn(callback, value)
                    self.Tab.Window:SaveConfig()
                end

                local function toggleState()
                    setState(not self.Tab.Window.Flags[flagName])
                end

                switch.Activated:Connect(toggleState)
                switch.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        toggleState()
                    end
                end)

                self:_registerElement(toggleLabel, row)
                if default then
                    setState(default)
                end
                return row
            end

            function section:CreateSlider(options)
                options = options or {}
                local sliderLabel = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local increment = options.Increment or 1
                local callback = options.Callback or function() end
                local flagName = options.Flag or sliderLabel
                local value = self.Tab.Window.Config[flagName] or default
                value = math.clamp(value, min, max)
                self.Tab.Window.Config[flagName] = value

                local row, _, right = CreateRow(contentContainer, sliderLabel, options.Description or "")
                local track = create(right, "Frame", {
                    Name = "SliderTrack",
                    BackgroundColor3 = Color3.fromRGB(20, 18, 34),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -12, 0, 8),
                    Position = UDim2.new(0, 6, 0, 32),
                })
                createCorner(track, 4)
                createStroke(track, Color3.fromRGB(60, 60, 84))

                local fill = create(track, "Frame", {
                    Name = "SliderFill",
                    BackgroundColor3 = Color3.fromRGB(138, 43, 226),
                    BorderSizePixel = 0,
                    Size = UDim2.new((value - min) / math.max(1, max - min), 0, 1, 0),
                })
                createCorner(fill, 4)

                local handle = create(track, "Frame", {
                    Name = "SliderHandle",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new((value - min) / math.max(1, max - min), -9, 0.5, -9),
                })
                createCorner(handle, 9)
                createStroke(handle, Color3.fromRGB(138, 43, 226))

                local valueLabel = create(right, "TextLabel", {
                    Name = "SliderValue",
                    BackgroundTransparency = 1,
                    Text = tostring(math.floor(value)),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 8),
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local dragging = false
                local dragInput

                local function updateValue(input)
                    if not dragging or not track or not track.Parent then
                        return
                    end
                    local relative = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                    local newValue = min + ((relative / track.AbsoluteSize.X) * (max - min))
                    newValue = math.clamp(math.floor(newValue / increment + 0.5) * increment, min, max)
                    value = newValue
                    self.Tab.Window.Config[flagName] = value
                    valueLabel.Text = tostring(math.floor(value))
                    local alpha = (value - min) / math.max(1, max - min)
                    fill.Size = UDim2.new(alpha, 0, 1, 0)
                    handle.Position = UDim2.new(alpha, -9, 0.5, -9)
                    task.spawn(callback, value)
                    self.Tab.Window:SaveConfig()
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragInput = input
                        updateValue(input)
                    end
                end)
                track.InputEnded:Connect(function(input)
                    if input == dragInput then
                        dragging = false
                        dragInput = nil
                    end
                end)
                self.Tab.Window._connections[#self.Tab.Window._connections + 1] = UserInputService.InputChanged:Connect(function(input)
                    if dragging and input == dragInput then
                        updateValue(input)
                    end
                end)

                self:_registerElement(sliderLabel, row)
                return row
            end

            function section:CreateDropdown(options)
                options = options or {}
                local title = options.Name or "Dropdown"
                local items = options.Items or {}
                local multi = options.Multi and true or false
                local callback = options.Callback or function() end
                local flagName = options.Flag or title
                local selections = self.Tab.Window.Config[flagName] or (multi and {} or nil)
                if multi and type(selections) ~= "table" then
                    selections = {}
                end
                self.Tab.Window.Config[flagName] = selections

                local row, _, right = CreateRow(contentContainer, title, options.Description or "")
                local selectedLabel = create(right, "TextLabel", {
                    Name = "SelectedLabel",
                    BackgroundTransparency = 1,
                    Text = multi and "Select options..." or "Choose an option...",
                    TextColor3 = Color3.fromRGB(159, 162, 166),
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 8),
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                create(right, "TextLabel", {
                    Name = "DropdownArrow",
                    BackgroundTransparency = 1,
                    Text = "?",
                    TextColor3 = Color3.fromRGB(138, 43, 226),
                    Font = Enum.Font.GothamBold,
                    TextSize = 16,
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -24, 0, 8),
                    TextXAlignment = Enum.TextXAlignment.Center,
                })

                local listFrame = create(right, "Frame", {
                    Name = "DropdownList",
                    BackgroundColor3 = Color3.fromRGB(14, 14, 22),
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 10),
                    Visible = false,
                    ClipsDescendants = true,
                })
                createCorner(listFrame, 14)
                createStroke(listFrame, Color3.fromRGB(60, 60, 82))
                create(listFrame, "UIListLayout", {
                    Padding = UDim.new(0, 6, 0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                local function updateSelectedLabel()
                    if multi then
                        if #selections == 0 then
                            selectedLabel.Text = "Select options..."
                        else
                            selectedLabel.Text = table.concat(selections, ", ")
                        end
                    else
                        selectedLabel.Text = selections or "Choose an option..."
                    end
                end

                local function setSelection(value)
                    if multi then
                        local exists = false
                        for index, stored in ipairs(selections) do
                            if stored == value then
                                table.remove(selections, index)
                                exists = true
                                break
                            end
                        end
                        if not exists then
                            table.insert(selections, value)
                        end
                    else
                        selections = value
                        listFrame.Visible = false
                    end
                    self.Tab.Window.Config[flagName] = multi and selections or selections
                    updateSelectedLabel()
                    task.spawn(callback, selections)
                    self.Tab.Window:SaveConfig()
                end

                for _, option in ipairs(items) do
                    local item = create(listFrame, "TextButton", {
                        Name = option:gsub("%s+", "_"),
                        BackgroundColor3 = Color3.fromRGB(18, 18, 26),
                        Text = option,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        Size = UDim2.new(1, 0, 0, 34),
                        AutoButtonColor = false,
                    })
                    createCorner(item, 12)
                    createStroke(item, Color3.fromRGB(60, 60, 82))
                    item.Activated:Connect(function()
                        setSelection(option)
                    end)
                end

                local listLayout = listFrame:FindFirstChildOfClass("UIListLayout")
                if listLayout then
                    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        listFrame.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
                    end)
                end

                right.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        listFrame.Visible = not listFrame.Visible
                    end
                end)

                updateSelectedLabel()
                self:_registerElement(title, row)
                return row
            end

            function section:CreateKeybind(options)
                options = options or {}
                local name = options.Name or "Keybind"
                local callback = options.Callback or function() end
                local flagName = options.Flag or name
                local key = self.Tab.Window.Config[flagName] or "None"

                local row, _, right = CreateRow(contentContainer, name, options.Description or "")
                local keyLabel = create(right, "TextLabel", {
                    Name = "KeybindValue",
                    BackgroundTransparency = 1,
                    Text = key,
                    TextColor3 = Color3.fromRGB(138, 43, 226),
                    Font = Enum.Font.GothamBold,
                    TextSize = 16,
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 8),
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
                create(right, "TextLabel", {
                    Name = "KeybindPrompt",
                    BackgroundTransparency = 1,
                    Text = "Click to bind",
                    TextColor3 = Color3.fromRGB(159, 162, 166),
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 36),
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local waitingForInput = false
                row.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if waitingForInput then
                            return
                        end
                        waitingForInput = true
                        local promptLabel = row:FindFirstChild("KeybindPrompt")
                        if promptLabel then
                            promptLabel.Text = "Press any key..."
                        end
                        local connection
                        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if gameProcessed then return end
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                key = input.KeyCode.Name
                            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                                key = input.UserInputType.Name
                            else
                                return
                            end
                            self.Tab.Window.Config[flagName] = key
                            keyLabel.Text = tostring(key)
                            if promptLabel then
                                promptLabel.Text = "Click to bind"
                            end
                            task.spawn(callback, key)
                            self.Tab.Window:SaveConfig()
                            waitingForInput = false
                            if connection then
                                connection:Disconnect()
                            end
                        end)
                        table.insert(self.Tab.Window._connections, connection)
                    end
                end)

                self:_registerElement(name, row)
                return row
            end

            function section:CreateTextBox(options)
                options = options or {}
                local name = options.Name or "TextBox"
                local placeholder = options.Placeholder or "Enter text..."
                local callback = options.Callback or function() end
                local flagName = options.Flag or name
                local clearOnFocus = options.ClearOnFocus and true or false
                local numbersOnly = options.NumbersOnly and true or false
                local default = self.Tab.Window.Config[flagName] or ""

                local row, _, right = CreateRow(contentContainer, name, options.Description or "")
                local textbox = create(right, "TextBox", {
                    Name = "InputBox",
                    BackgroundColor3 = Color3.fromRGB(16, 16, 24),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = default,
                    PlaceholderText = placeholder,
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    Size = UDim2.new(1, 0, 0, 34),
                    Position = UDim2.new(0, 0, 0, 8),
                    ClearTextOnFocus = false,
                })
                createCorner(textbox, 14)
                createStroke(textbox, Color3.fromRGB(60, 60, 82))

                local function validate(text)
                    if numbersOnly then
                        if not tonumber(text) then
                            textbox.TextColor3 = Color3.fromRGB(255, 120, 120)
                            return false
                        end
                    end
                    textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    return true
                end

                textbox.Focused:Connect(function()
                    if clearOnFocus then
                        textbox.Text = ""
                    end
                end)

                textbox:GetPropertyChangedSignal("Text"):Connect(function()
                    local valid = validate(textbox.Text)
                    if valid then
                        self.Tab.Window.Config[flagName] = textbox.Text
                        task.spawn(callback, textbox.Text)
                        self.Tab.Window:SaveConfig()
                    end
                end)

                self:_registerElement(name, row)
                return row
            end

            function section:CreateColorPicker(options)
                options = options or {}
                local name = options.Name or "Color Picker"
                local callback = options.Callback or function() end
                local flagName = options.Flag or name
                local defaultColor = self.Tab.Window.Config[flagName] or Color3.fromRGB(138, 43, 226)

                local row, _, right = CreateRow(contentContainer, name, options.Description or "")
                local preview = create(right, "Frame", {
                    Name = "Preview",
                    BackgroundColor3 = defaultColor,
                    Size = UDim2.new(0, 34, 0, 34),
                    Position = UDim2.new(1, -48, 0, 8),
                })
                createCorner(preview, 14)
                createStroke(preview, Color3.fromRGB(138, 43, 226))

                local openButton = create(right, "TextButton", {
                    Name = "OpenPicker",
                    BackgroundColor3 = Color3.fromRGB(18, 18, 28),
                    Text = "Pick",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    Size = UDim2.new(0, 90, 0, 34),
                    Position = UDim2.new(1, -148, 0, 8),
                    AutoButtonColor = false,
                })
                createCorner(openButton, 14)
                createStroke(openButton, Color3.fromRGB(138, 43, 226))

                local pickerPanel = create(contentContainer, "Frame", {
                    Name = "PickerPanel",
                    BackgroundColor3 = Color3.fromRGB(14, 14, 22),
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Visible = false,
                    ClipsDescendants = true,
                })
                createCorner(pickerPanel, 18)
                createStroke(pickerPanel, Color3.fromRGB(60, 60, 82))
                local pickerLayout = create(pickerPanel, "UIListLayout", {
                    Padding = UDim.new(0, 8, 0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
                pickerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    pickerPanel.Size = UDim2.new(1, 0, 0, pickerLayout.AbsoluteContentSize.Y + 16)
                end)

                local colorSamples = {
                    Color3.fromRGB(138, 43, 226),
                    Color3.fromRGB(0, 255, 127),
                    Color3.fromRGB(255, 76, 76),
                    Color3.fromRGB(0, 170, 255),
                }

                for _, colorOption in ipairs(colorSamples) do
                    local sample = create(pickerPanel, "TextButton", {
                        Name = "ColorOption",
                        BackgroundColor3 = colorOption,
                        Text = "",
                        Size = UDim2.new(0, 72, 0, 40),
                        AutoButtonColor = false,
                    })
                    createCorner(sample, 14)
                    createStroke(sample, Color3.fromRGB(255, 255, 255))
                    sample.Activated:Connect(function()
                        preview.BackgroundColor3 = colorOption
                        self.Tab.Window.Config[flagName] = colorOption
                        task.spawn(callback, colorOption)
                        self.Tab.Window:SaveConfig()
                    end)
                end

                openButton.Activated:Connect(function()
                    pickerPanel.Visible = not pickerPanel.Visible
                end)

                self:_registerElement(name, row)
                return row
            end

            function section:CreateSection(name)
                return self:CreateButton({Name = name, Callback = function() end})
            end

            return section
        end

        return tabObject
    end

    function self:Notify(options)
        options = options or {}
        local title = options.Title or "Notification"
        local content = options.Content or "No content provided"
        local duration = options.Duration or 4

        local notifContainer = screenGui:FindFirstChild("NotificationRoot")
        if not notifContainer then
            notifContainer = create(screenGui, "Frame", {
                Name = "NotificationRoot",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 320, 0, 0),
                Position = UDim2.new(1, -360, 1, -28),
                AnchorPoint = Vector2.new(1, 1),
            })
        end

        local notification = create(notifContainer, "Frame", {
            Name = "Notification",
            BackgroundColor3 = Color3.fromRGB(12, 12, 18),
            BackgroundTransparency = 0.04,
            Size = UDim2.new(1, 0, 0, 94),
            Position = UDim2.new(0, 0, 0, notifContainer.AbsoluteSize.Y + 12),
            ClipsDescendants = true,
        })
        createCorner(notification, 18)
        createStroke(notification, Color3.fromRGB(138, 43, 226))
        createGradient(notification, Color3.fromRGB(20, 12, 40), Color3.fromRGB(6, 6, 16), 130)

        create(notification, "TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            Size = UDim2.new(1, -24, 0, 24),
            Position = UDim2.new(0, 0.03, 0, 10),
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        create(notification, "TextLabel", {
            Name = "Content",
            BackgroundTransparency = 1,
            Text = content,
            TextColor3 = Color3.fromRGB(159, 162, 166),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            Size = UDim2.new(1, -24, 0, 40),
            Position = UDim2.new(0, 0.03, 0, 32),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        notifContainer.Size = UDim2.new(0, 320, 0, notifContainer.AbsoluteSize.Y + 104)
        tween(notification, {Position = UDim2.new(0, 0, 0, notifContainer.AbsoluteSize.Y - 100)}, 0.28)

        task.delay(duration, function()
            tween(notification, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.24)
            task.wait(0.26)
            if notification and notification.Parent then
                notification:Destroy()
            end
            notifContainer.Size = UDim2.new(0, 320, 0, notifContainer.AbsoluteSize.Y - 100)
        end)
    end

    function self:JoinDiscord(inviteCode)
        local invite = string.format("https://discord.gg/%s", inviteCode)
        setClipboard(invite)
        self:Notify({
            Title = "Discord Link Copied",
            Content = invite,
            Duration = 4,
        })
    end

    function window:_initializeDragging()
        local dragRoot = navBar
        local function update(input)
            local delta = input.Position - window._dragStart
            root.Position = UDim2.new(0, window._startPos.X + delta.X, 0, window._startPos.Y + delta.Y)
        end

        window._connections[#window._connections + 1] = dragRoot.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                window._dragInput = input
                window._dragStart = input.Position
                window._startPos = {X = root.AbsolutePosition.X, Y = root.AbsolutePosition.Y}
            end
        end)

        window._connections[#window._connections + 1] = UserInputService.InputChanged:Connect(function(input)
            if input == window._dragInput then
                update(input)
            end
        end)

        window._connections[#window._connections + 1] = UserInputService.InputEnded:Connect(function(input)
            if input == window._dragInput then
                window._dragInput = nil
            end
        end)
    end

    window._connections[#window._connections + 1] = searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = searchBox.Text or ""
        window:_refreshSearch(text)
    end)

    window:_loadConfig()
    window:_initializeDragging()

    task.spawn(function()
        local steps = {0.18, 0.45, 0.72, 1}
        for _, progress in ipairs(steps) do
            tween(landingCard, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.28)
            task.wait(0.1)
        end
    end)

    table.insert(self._instances, window)
    return window
end

function Paxz:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or "No content provided"
    local duration = options.Duration or 4

    if not self.NotificationsRoot and self._instances[1] and self._instances[1]._screenGui then
        self.NotificationsRoot = create(self._instances[1]._screenGui, "Frame", {
            Name = "GlobalNotificationRoot",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 340, 0, 0),
            Position = UDim2.new(1, -360, 1, -20),
            AnchorPoint = Vector2.new(1, 1),
        })
    end

    local container = self.NotificationsRoot
    if container then
        local notification = create(container, "Frame", {
            Name = "Notification",
            BackgroundColor3 = Color3.fromRGB(14, 14, 22),
            BackgroundTransparency = 0.04,
            Size = UDim2.new(1, 0, 0, 88),
            Position = UDim2.new(0, 0, 0, container.AbsoluteSize.Y + 12),
        })
        createCorner(notification, 18)
        createStroke(notification, Color3.fromRGB(138, 43, 226))
        createGradient(notification, Color3.fromRGB(20, 12, 40), Color3.fromRGB(6, 6, 16), 130)

        create(notification, "TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            Size = UDim2.new(1, -24, 0, 24),
            Position = UDim2.new(0, 0.03, 0, 10),
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        create(notification, "TextLabel", {
            Name = "Content",
            BackgroundTransparency = 1,
            Text = content,
            TextColor3 = Color3.fromRGB(159, 162, 166),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            Size = UDim2.new(1, -24, 0, 40),
            Position = UDim2.new(0, 0.03, 0, 32),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        container.Size = UDim2.new(0, 340, 0, container.AbsoluteSize.Y + 100)
        tween(notification, {Position = UDim2.new(0, 0, 0, container.AbsoluteSize.Y - 100)}, 0.28)

        task.delay(duration, function()
            tween(notification, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.24)
            task.wait(0.26)
            if notification and notification.Parent then
                notification:Destroy()
            end
            container.Size = UDim2.new(0, 340, 0, container.AbsoluteSize.Y - 100)
        end)
    end
end

function Paxz:JoinDiscord(inviteCode)
    local invite = string.format("https://discord.gg/%s", inviteCode)
    setClipboard(invite)
    self:Notify({
        Title = "Discord Link Copied",
        Content = invite,
        Duration = 4,
    })
end

Paxz.CreatePill = CreatePill
Paxz.CreateRow = CreateRow
Paxz.CreateNav = CreateNav

return Paxz
