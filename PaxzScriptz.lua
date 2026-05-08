-- PaxzScriptz: High-performance Roblox UI Framework for modern executors
-- Designed for Rayfield + Cyberpunk visual language, mobile-compatible interactions,
-- and modular OOP structure using metatables for memory efficiency.

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

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
    if self and self:IsA and self:IsA("Instance") then
        instance.Parent = self
    end
    return instance
end

local function tween(instance, properties, duration)
    local info = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tweenData = TweenService:Create(instance, info, properties)
    tweenData:Play()
    return tweenData
end

local function createStroke(parent, color)
    return create(parent, "UIStroke", {
        Color = color or Color3.fromRGB(160, 32, 240),
        Thickness = 1,
        Transparency = 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

local function createCorner(parent, radius)
    return create(parent, "UICorner", {CornerRadius = UDim.new(0, radius or 8)})
end

local function createGradient(parent, color1, color2, rotation)
    return create(parent, "UIGradient", {
        Color = ColorSequence.new(color1, color2),
        Rotation = rotation or 90
    })
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

local function applyButtonEffects(button)
    local defaultScale = button.Size
    local hoverScale = UDim2.new(defaultScale.X.Scale, defaultScale.X.Offset + 4, defaultScale.Y.Scale, defaultScale.Y.Offset + 4)

    local function onEnter()
        tween(button, {Size = hoverScale}, 0.15)
    end
    local function onLeave()
        tween(button, {Size = defaultScale}, 0.15)
    end
    button.MouseEnter:Connect(onEnter)
    button.MouseLeave:Connect(onLeave)
    button.TouchTap:Connect(onEnter)
    return button
end

function Paxz:CreateWindow(options)
    options = options or {}
    local title = options.Name or "PaxzScriptz"
    local loadingTitle = options.LoadingTitle or "Initializing PaxzScriptz"
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
    window._selectedTab = nil
    window._isDragging = false
    window._dragInput = nil
    window._dragStart = nil
    window._startPos = nil
    window._screenGui = nil
    window._notificationQueue = {}

    -- Create UI root
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

    -- Main window container
    local root = create(screenGui, "Frame", {
        Name = "PaxzRoot",
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 850, 0, 520),
        Position = UDim2.new(0.5, -425, 0.5, -260),
        AnchorPoint = Vector2.new(0.5, 0.5),
    })
    createCorner(root, 16)
    createStroke(root, Color3.fromRGB(160, 32, 240))

    local header = create(root, "Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 72),
        Position = UDim2.new(0, 0, 0, 0),
    })
    local headerBg = create(header, "Frame", {
        Name = "HeaderBg",
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
    })
    createCorner(headerBg, 16)
    createStroke(headerBg, Color3.fromRGB(0, 255, 255))
    createGradient(headerBg, Color3.fromRGB(24, 0, 60), Color3.fromRGB(10, 10, 10), 135)

    local titleLabel = create(header, "TextLabel", {
        Name = "TitleLabel",
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(0.45, 0, 0.5, 0),
        Position = UDim2.new(0.025, 0, 0.15, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local subtitleLabel = create(header, "TextLabel", {
        Name = "SubtitleLabel",
        BackgroundTransparency = 1,
        Text = loadingTitle,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextTransparency = 0.3,
        TextScaled = false,
        Font = Enum.Font.Gotham,
        TextSize = 17,
        Size = UDim2.new(0.35, 0, 0.3, 0),
        Position = UDim2.new(0.025, 0, 0.55, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local searchBox = create(header, "TextBox", {
        Name = "SearchBox",
        BackgroundColor3 = Color3.fromRGB(22, 20, 40),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextTransparency = 0.2,
        PlaceholderText = "Search tabs and controls...",
        PlaceholderColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Size = UDim2.new(0.4, 0, 0.45, 0),
        Position = UDim2.new(0.55, 0, 0.25, 0),
        ClearTextOnFocus = false,
    })
    createCorner(searchBox, 12)
    createStroke(searchBox, Color3.fromRGB(0, 255, 255))

    local content = create(root, "Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -72),
        Position = UDim2.new(0, 0, 0, 72),
    })

    local leftPanel = create(content, "Frame", {
        Name = "LeftPanel",
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        Size = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(0, 260, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
    })
    createCorner(leftPanel, 16)
    createStroke(leftPanel, Color3.fromRGB(160, 32, 240))

    local tabList = create(leftPanel, "ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
    })
    local tabLayout = create(tabList, "UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    tabList:GetPropertyChangedSignal("CanvasSize"):Connect(function()
        tabList.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 12)
    end)

    local tabIndicator = create(leftPanel, "Frame", {
        Name = "TabIndicator",
        BackgroundColor3 = Color3.fromRGB(160, 32, 240),
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 0),
    })
    createCorner(tabIndicator, 4)

    local tabContent = create(content, "Frame", {
        Name = "TabContent",
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        Size = UDim2.new(1, -280, 1, 0),
        Position = UDim2.new(0, 280, 0, 0),
    })
    createCorner(tabContent, 16)
    createStroke(tabContent, Color3.fromRGB(0, 255, 255))
    local contentLayout = create(tabContent, "UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- Loading overlay
    local loadingOverlay = create(root, "Frame", {
        Name = "LoadingOverlay",
        BackgroundColor3 = Color3.fromRGB(6, 6, 6),
        BackgroundTransparency = 0.1,
        Size = UDim2.new(1, 1, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 10,
    })
    createCorner(loadingOverlay, 16)

    local loadingCenter = create(loadingOverlay, "Frame", {
        Name = "LoadingCenter",
        BackgroundColor3 = Color3.fromRGB(20, 10, 40),
        Size = UDim2.new(0, 0, 0, 120),
        Position = UDim2.new(0.5, 0, 0.4, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
    })
    loadingCenter.Size = UDim2.new(0, 460, 0, 120)
    createCorner(loadingCenter, 16)
    createStroke(loadingCenter, Color3.fromRGB(160, 32, 240))

    local loadingText = create(loadingCenter, "TextLabel", {
        Name = "LoadingText",
        BackgroundTransparency = 1,
        Text = loadingTitle,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 0, 0.15, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local loadingBar = create(loadingCenter, "Frame", {
        Name = "LoadingBar",
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Size = UDim2.new(1, -24, 0, 22),
        Position = UDim2.new(0, 0, 0.6, 0),
    })
    createCorner(loadingBar, 12)
    createStroke(loadingBar, Color3.fromRGB(0, 255, 255))

    local loadingProgress = create(loadingBar, "Frame", {
        Name = "LoadingProgress",
        BackgroundColor3 = Color3.fromRGB(160, 32, 240),
        Size = UDim2.new(0, 0, 1, 0),
    })
    createCorner(loadingProgress, 12)

    local function registerConnection(signal)
        table.insert(window._connections, signal)
        return signal
    end

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

    function window:CreateTab(tabName, imageId)
        local tabObject = setmetatable({}, Tab)
        tabObject.Name = tabName
        tabObject.Window = self
        tabObject._sections = {}
        tabObject._button = nil
        tabObject._content = nil

        local button = create(tabList, "TextButton", {
            Name = tabName:gsub("%s+", "_"),
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            Text = " " .. tabName,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 48),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ClipsDescendants = true,
        })
        createCorner(button, 12)
        createStroke(button, Color3.fromRGB(0, 255, 255))
        local icon = create(button, "ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Image = imageId or "",
            Size = UDim2.new(0, 0, 0, 32),
            Position = UDim2.new(0, 12, 0.5, -16),
            ScaleType = Enum.ScaleType.Fit,
        })
        if imageId then
            icon.Size = UDim2.new(0, 0, 0, 32)
        end
        local textPadding = create(button, "UIPadding", {PaddingLeft = UDim.new(0, 52, 0, 0)})

        local contentFrame = create(tabContent, "ScrollingFrame", {
            Name = tabName:gsub("%s+", "_"),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 1, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 8,
            Visible = false,
        })
        local layout = create(contentFrame, "UIListLayout", {
            Padding = UDim.new(0, 14),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        contentFrame:GetPropertyChangedSignal("CanvasSize"):Connect(function()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        tabObject._button = button
        tabObject._content = contentFrame
        tabObject._indicator = tabIndicator

        local function selectTab()
            if self._selectedTab then
                self._selectedTab._button.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                self._selectedTab._button.TextTransparency = 0.2
                self._selectedTab._content.Visible = false
            end
            self._selectedTab = tabObject
            button.BackgroundColor3 = Color3.fromRGB(30, 10, 90)
            button.TextTransparency = 0
            contentFrame.Visible = true
            tween(tabIndicator, {Position = UDim2.new(0, 0, 0, button.AbsolutePosition.Y - tabList.AbsolutePosition.Y)}, 0.2)
        end

        table.insert(self._tabs, tabObject)
        self._createSearchable(tabName, button)

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
                BackgroundColor3 = Color3.fromRGB(14, 14, 14),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ClipsDescendants = true,
            })
            createCorner(wrapper, 14)
            createStroke(wrapper, Color3.fromRGB(160, 32, 240))

            local header = create(wrapper, "Frame", {
                Name = "SectionHeader",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 42),
            })
            local sectionLabel = create(header, "TextLabel", {
                Name = "SectionLabel",
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamSemibold,
                TextSize = 18,
                Size = UDim2.new(1, -24, 1, -8),
                Position = UDim2.new(0, 12, 0, 8),
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            local contentContainer = create(wrapper, "Frame", {
                Name = "SectionContent",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            local sectionLayout = create(contentContainer, "UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
            })
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                contentContainer.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y)
            end)

            function section:_registerElement(name, frame)
                table.insert(self._elements, {Name = name, Frame = frame})
                self.Tab.Window._createSearchable(name, frame)
            end

            function section:CreateButton(options)
                options = options or {}
                local buttonLabel = options.Name or "Button"
                local callback = options.Callback or function() end

                local buttonFrame = create(contentContainer, "TextButton", {
                    Name = buttonLabel:gsub("%s+", "_"),
                    BackgroundColor3 = Color3.fromRGB(20, 10, 40),
                    Text = buttonLabel,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 17,
                    Size = UDim2.new(1, 0, 0, 48),
                    AutoButtonColor = false,
                })
                createCorner(buttonFrame, 12)
                createStroke(buttonFrame, Color3.fromRGB(0, 255, 255))
                createGradient(buttonFrame, Color3.fromRGB(80, 10, 140), Color3.fromRGB(20, 10, 40), 180)

                applyButtonEffects(buttonFrame)

                local conn = buttonFrame.Activated:Connect(function()
                    task.spawn(callback)
                end)
                table.insert(self.Tab.Window._connections, conn)
                self:_registerElement(buttonLabel, buttonFrame)
                return buttonFrame
            end

            function section:CreateToggle(options)
                options = options or {}
                local toggleLabel = options.Name or "Toggle"
                local callback = options.Callback or function() end
                local flagName = options.Flag or toggleLabel
                local default = options.Default and true or false
                self.Tab.Window.Flags[flagName] = self.Tab.Window.Flags[flagName] or default

                local wrapperFrame = create(contentContainer, "Frame", {
                    Name = toggleLabel:gsub("%s+", "_"),
                    BackgroundColor3 = Color3.fromRGB(20, 10, 40),
                    Size = UDim2.new(1, 0, 0, 54),
                })
                createCorner(wrapperFrame, 12)
                createStroke(wrapperFrame, Color3.fromRGB(0, 255, 255))

                local label = create(wrapperFrame, "TextLabel", {
                    Name = "ToggleText",
                    BackgroundTransparency = 1,
                    Text = toggleLabel,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 17,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Position = UDim2.new(0.03, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                local switch = create(wrapperFrame, "Frame", {
                    Name = "Switch",
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Size = UDim2.new(0, 0, 0, 24),
                    Position = UDim2.new(0.75, 0, 0.5, -12),
                })
                switch.Size = UDim2.new(0, 54, 0, 24)
                createCorner(switch, 12)
                createStroke(switch, Color3.fromRGB(160, 32, 240))

                local handle = create(switch, "Frame", {
                    Name = "Handle",
                    BackgroundColor3 = Color3.fromRGB(160, 32, 240),
                    Size = UDim2.new(0, 0, 0, 20),
                    Position = UDim2.new(default and 1 or 0, default and -20 or 4, 0.5, -10),
                })
                createCorner(handle, 12)
                local glow = create(handle, "UIStroke", {
                    Color = Color3.fromRGB(0, 255, 255),
                    Thickness = 1,
                    Transparency = 0.3,
                })

                local function setState(value)
                    self.Tab.Window.Flags[flagName] = value
                    local pos = value and UDim2.new(1, -20, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
                    tween(handle, {Position = pos}, 0.18)
                    tween(handle, {BackgroundColor3 = value and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(160, 32, 240)}, 0.18)
                    task.spawn(callback, value)
                    self.Tab.Window:SaveConfig()
                end

                local function toggleState()
                    setState(not self.Tab.Window.Flags[flagName])
                end

                wrapperFrame.Activated:Connect(toggleState)
                wrapperFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        toggleState()
                    end
                end)

                self:_registerElement(toggleLabel, wrapperFrame)
                if default then
                    setState(default)
                end
                return wrapperFrame
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

                local frame = create(contentContainer, "Frame", {
                    Name = sliderLabel:gsub("%s+", "_"),
                    BackgroundColor3 = Color3.fromRGB(20, 10, 40),
                    Size = UDim2.new(1, 0, 0, 82),
                })
                createCorner(frame, 12)
                createStroke(frame, Color3.fromRGB(0, 255, 255))

                local title = create(frame, "TextLabel", {
                    Name = "SliderName",
                    BackgroundTransparency = 1,
                    Text = sliderLabel,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 17,
                    Size = UDim2.new(0.7, 0, 0, 26),
                    Position = UDim2.new(0.03, 0, 0.05, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                local valueLabel = create(frame, "TextLabel", {
                    Name = "SliderValue",
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    Size = UDim2.new(0.25, -12, 0, 24),
                    Position = UDim2.new(0.72, 0, 0.05, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local track = create(frame, "Frame", {
                    Name = "Track",
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Size = UDim2.new(0.94, 0, 0, 14),
                    Position = UDim2.new(0.03, 0, 0.45, 0),
                })
                createCorner(track, 12)
                createStroke(track, Color3.fromRGB(160, 32, 240))

                local fill = create(track, "Frame", {
                    Name = "Fill",
                    BackgroundColor3 = Color3.fromRGB(160, 32, 240),
                    Size = UDim2.new((value - min) / math.max(1, max - min), 0, 1, 0),
                })
                createCorner(fill, 12)

                local handle = create(track, "Frame", {
                    Name = "Handle",
                    BackgroundColor3 = Color3.fromRGB(0, 255, 255),
                    Size = UDim2.new(0, 0, 0, 22),
                    Position = UDim2.new((value - min) / math.max(1, max - min), -11, 0.5, -11),
                })
                createCorner(handle, 12)
                createStroke(handle, Color3.fromRGB(255, 255, 255))

                local function setSlider(newValue)
                    newValue = math.clamp(math.floor(newValue / increment + 0.5) * increment, min, max)
                    value = newValue
                    self.Tab.Window.Config[flagName] = value
                    valueLabel.Text = tostring(value)
                    local alpha = (value - min) / math.max(1, max - min)
                    fill:TweenSize(UDim2.new(alpha, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.12, true)
                    handle:TweenPosition(UDim2.new(alpha, -11, 0.5, -11), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.12, true)
                    task.spawn(callback, value)
                    self.Tab.Window:SaveConfig()
                end

                local dragging = false
                local dragInput = nil
                local function onInputChanged(input)
                    if input == dragInput and dragging then
                        local relative = input.Position.X - track.AbsolutePosition.X
                        local newValue = min + ((relative / track.AbsoluteSize.X) * (max - min))
                        setSlider(newValue)
                    end
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragInput = input
                        onInputChanged(input)
                    end
                end)
                track.InputEnded:Connect(function(input)
                    if input == dragInput then
                        dragging = false
                        dragInput = nil
                    end
                end)
                self.Tab.Window._connections[#self.Tab.Window._connections + 1] = UserInputService.InputChanged:Connect(onInputChanged)
                frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragInput = input
                        onInputChanged(input)
                    end
                end)

                self:_registerElement(sliderLabel, frame)
                setSlider(value)
                return frame
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

                local wrapper = create(contentContainer, "Frame", {
                    Name = title:gsub("%s+", "_"),
                    BackgroundColor3 = Color3.fromRGB(20, 10, 40),
                    Size = UDim2.new(1, 0, 0, 52),
                    ClipsDescendants = true,
                })
                createCorner(wrapper, 12)
                createStroke(wrapper, Color3.fromRGB(0, 255, 255))

                local label = create(wrapper, "TextLabel", {
                    Name = "DropdownLabel",
                    BackgroundTransparency = 1,
                    Text = title,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 17,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Position = UDim2.new(0.03, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local selectedLabel = create(wrapper, "TextLabel", {
                    Name = "SelectedLabel",
                    BackgroundTransparency = 1,
                    Text = multi and "Select options..." or "Choose an option...",
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Position = UDim2.new(0.65, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local indicator = create(wrapper, "ImageLabel", {
                    Name = "Indicator",
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://3926305904",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0.95, -18, 0.5, -8),
                    ImageColor3 = Color3.fromRGB(160, 32, 240),
                })

                local listFrame = create(wrapper, "Frame", {
                    Name = "ListFrame",
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 6),
                    Visible = false,
                    ClipsDescendants = true,
                })
                createCorner(listFrame, 12)
                createStroke(listFrame, Color3.fromRGB(0, 255, 255))
                local listLayout = create(listFrame, "UIListLayout", {Padding = UDim.new(0, 4, 0, 4)})

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
                        self.Tab.Window.Config[flagName] = value
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
                        BackgroundColor3 = Color3.fromRGB(20, 10, 40),
                        Text = option,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Font = Enum.Font.Gotham,
                        TextSize = 15,
                        Size = UDim2.new(1, -12, 0, 34),
                        Position = UDim2.new(0, 0, 0, 0),
                        AutoButtonColor = false,
                    })
                    createCorner(item, 10)
                    createStroke(item, Color3.fromRGB(160, 32, 240))

                    item.Activated:Connect(function()
                        setSelection(option)
                    end)
                end

                listFrame:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    listFrame.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
                end)

                wrapper.Activated:Connect(function()
                    listFrame.Visible = not listFrame.Visible
                end)
                wrapper.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        listFrame.Visible = not listFrame.Visible
                    end
                end)

                updateSelectedLabel()
                self:_registerElement(title, wrapper)
                return wrapper
            end

            function section:CreateKeybind(options)
                options = options or {}
                local name = options.Name or "Keybind"
                local callback = options.Callback or function() end
                local flagName = options.Flag or name
                local key = self.Tab.Window.Config[flagName] or "None"

                local frame = create(contentContainer, "Frame", {
                    Name = name:gsub("%s+", "_"),
                    BackgroundColor3 = Color3.fromRGB(20, 10, 40),
                    Size = UDim2.new(1, 0, 0, 56),
                })
                createCorner(frame, 12)
                createStroke(frame, Color3.fromRGB(0, 255, 255))

                local label = create(frame, "TextLabel", {
                    Name = "KeybindLabel",
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 17,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Position = UDim2.new(0.03, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                local keyLabel = create(frame, "TextLabel", {
                    Name = "KeybindValue",
                    BackgroundTransparency = 1,
                    Text = key,
                    TextColor3 = Color3.fromRGB(160, 32, 240),
                    Font = Enum.Font.GothamBold,
                    TextSize = 16,
                    Size = UDim2.new(0.35, -16, 0, 28),
                    Position = UDim2.new(0.62, 0, 0.2, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
                local prompt = create(frame, "TextLabel", {
                    Name = "KeybindPrompt",
                    BackgroundTransparency = 1,
                    Text = "Click to bind",
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    Font = Enum.Font.GothamItalic,
                    TextSize = 14,
                    Size = UDim2.new(0.35, -16, 0, 24),
                    Position = UDim2.new(0.62, 0, 0.55, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local waitingForInput = false
                local function updateKeybind(newKey)
                    key = newKey
                    self.Tab.Window.Config[flagName] = key
                    keyLabel.Text = tostring(key)
                    prompt.Text = "Press any key"
                    task.spawn(callback, key)
                    self.Tab.Window:SaveConfig()
                end

                frame.Activated:Connect(function()
                    if waitingForInput then
                        return
                    end
                    waitingForInput = true
                    prompt.Text = "Press any key..."
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            updateKeybind(input.KeyCode.Name)
                            waitingForInput = false
                            if connection then connection:Disconnect() end
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                            updateKeybind(input.UserInputType.Name)
                            waitingForInput = false
                            if connection then connection:Disconnect() end
                        end
                    end)
                    table.insert(self.Tab.Window._connections, connection)
                end)

                self:_registerElement(name, frame)
                return frame
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

                local frame = create(contentContainer, "Frame", {
                    Name = name:gsub("%s+", "_"),
                    BackgroundColor3 = Color3.fromRGB(20, 10, 40),
                    Size = UDim2.new(1, 0, 0, 60),
                })
                createCorner(frame, 12)
                createStroke(frame, Color3.fromRGB(0, 255, 255))

                local label = create(frame, "TextLabel", {
                    Name = "TextBoxLabel",
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 17,
                    Size = UDim2.new(1, -20, 0, 24),
                    Position = UDim2.new(0.03, 0, 0.05, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local textbox = create(frame, "TextBox", {
                    Name = "InputBox",
                    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = default,
                    PlaceholderText = placeholder,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    Size = UDim2.new(1, -24, 0, 28),
                    Position = UDim2.new(0.03, 0, 0.45, 0),
                    ClearTextOnFocus = false,
                })
                createCorner(textbox, 10)
                createStroke(textbox, Color3.fromRGB(160, 32, 240))

                local function validate(text)
                    if numbersOnly then
                        local numeric = tonumber(text)
                        if not numeric then
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

                self:_registerElement(name, frame)
                return frame
            end

            function section:CreateColorPicker(options)
                options = options or {}
                local name = options.Name or "ColorPicker"
                local callback = options.Callback or function() end
                local flagName = options.Flag or name
                local default = self.Tab.Window.Config[flagName] or Color3.fromRGB(160, 32, 240)

                local frame = create(contentContainer, "Frame", {
                    Name = name:gsub("%s+", "_"),
                    BackgroundColor3 = Color3.fromRGB(20, 10, 40),
                    Size = UDim2.new(1, 0, 0, 120),
                })
                createCorner(frame, 12)
                createStroke(frame, Color3.fromRGB(0, 255, 255))

                local label = create(frame, "TextLabel", {
                    Name = "PickerLabel",
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 17,
                    Size = UDim2.new(1, -24, 0, 24),
                    Position = UDim2.new(0.03, 0, 0.03, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local preview = create(frame, "Frame", {
                    Name = "Preview",
                    BackgroundColor3 = default,
                    Size = UDim2.new(0, 0, 0, 60),
                    Position = UDim2.new(0.03, 0, 0.35, 0),
                })
                preview.Size = UDim2.new(0, 0, 0, 60)
                preview.Size = UDim2.new(0, 100, 0, 60)
                createCorner(preview, 14)
                createStroke(preview, Color3.fromRGB(160, 32, 240))

                local openButton = create(frame, "TextButton", {
                    Name = "OpenPicker",
                    BackgroundColor3 = Color3.fromRGB(30, 20, 60),
                    Text = "Open Picker",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    Size = UDim2.new(0, 140, 0, 34),
                    Position = UDim2.new(0.5, 0, 0.45, 0),
                    AutoButtonColor = false,
                })
                createCorner(openButton, 12)
                createStroke(openButton, Color3.fromRGB(0, 255, 255))

                local pickerPanel = create(frame, "Frame", {
                    Name = "PickerPanel",
                    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 6),
                    Visible = false,
                    ClipsDescendants = true,
                })
                createCorner(pickerPanel, 14)
                createStroke(pickerPanel, Color3.fromRGB(0, 255, 255))

                local hueBar = create(pickerPanel, "Frame", {
                    Name = "HueBar",
                    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
                    Size = UDim2.new(0.92, 0, 0, 26),
                    Position = UDim2.new(0.04, 0, 0.1, 0),
                })
                createCorner(hueBar, 12)
                local hueGradient = createGradient(hueBar, Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), 0)
                hueGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                }

                local saturationBox = create(pickerPanel, "Frame", {
                    Name = "SaturationBox",
                    BackgroundColor3 = Color3.fromRGB(255, 0, 255),
                    Size = UDim2.new(0.92, 0, 0, 110),
                    Position = UDim2.new(0.04, 0, 0.35, 0),
                })
                createCorner(saturationBox, 14)
                local satGradient = createGradient(saturationBox, Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0), 0)

                local hueHandle = create(hueBar, "Frame", {
                    Name = "HueHandle",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(0, 0, 0, 28),
                    Position = UDim2.new(0, -14, 0.5, -14),
                })
                createCorner(hueHandle, 14)
                createStroke(hueHandle, Color3.fromRGB(160, 32, 240))

                local satHandle = create(saturationBox, "Frame", {
                    Name = "SatHandle",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(0, 0, 0, 28),
                    Position = UDim2.new(0, -14, 0, -14),
                })
                createCorner(satHandle, 14)
                createStroke(satHandle, Color3.fromRGB(160, 32, 240))

                local currentHue = 0
                local currentSaturation = 1
                local currentValue = 1

                local function toColor3(h, s, v)
                    local color = Color3.fromHSV(h, s, v)
                    preview.BackgroundColor3 = color
                    self.Tab.Window.Config[flagName] = color
                    task.spawn(callback, color)
                    self.Tab.Window:SaveConfig()
                end

                local function updateFromHue(position)
                    currentHue = math.clamp(position / hueBar.AbsoluteSize.X, 0, 1)
                    toColor3(currentHue, currentSaturation, currentValue)
                    hueHandle.Position = UDim2.new(currentHue, -14, 0.5, -14)
                end

                local function updateFromSaturation(position)
                    currentSaturation = math.clamp(position / saturationBox.AbsoluteSize.X, 0, 1)
                    toColor3(currentHue, currentSaturation, currentValue)
                    satHandle.Position = UDim2.new(currentSaturation, -14, 0, -14)
                end

                local function beginDrag(input, bar, callback)
                    local connection
                    connection = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            if connection then connection:Disconnect() end
                        end
                    end)
                    self.Tab.Window._connections[#self.Tab.Window._connections + 1] = connection
                end

                local function dragBar(input, bar, updater)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        local relative = input.Position.X - bar.AbsolutePosition.X
                        updater(relative)
                    end
                end

                hueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragBar(input, hueBar, updateFromHue)
                        local conn = UserInputService.InputChanged:Connect(function(update)
                            if update.UserInputType == input.UserInputType then
                                dragBar(update, hueBar, updateFromHue)
                            end
                        end)
                        local endConn
                        endConn = UserInputService.InputEnded:Connect(function(update)
                            if update == input then
                                if conn then conn:Disconnect() end
                                if endConn then endConn:Disconnect() end
                            end
                        end)
                        table.insert(self.Tab.Window._connections, conn)
                        table.insert(self.Tab.Window._connections, endConn)
                    end
                end)

                saturationBox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragBar(input, saturationBox, updateFromSaturation)
                        local conn = UserInputService.InputChanged:Connect(function(update)
                            if update.UserInputType == input.UserInputType then
                                dragBar(update, saturationBox, updateFromSaturation)
                            end
                        end)
                        local endConn
                        endConn = UserInputService.InputEnded:Connect(function(update)
                            if update == input then
                                if conn then conn:Disconnect() end
                                if endConn then endConn:Disconnect() end
                            end
                        end)
                        table.insert(self.Tab.Window._connections, conn)
                        table.insert(self.Tab.Window._connections, endConn)
                    end
                end)

                openButton.Activated:Connect(function()
                    pickerPanel.Visible = not pickerPanel.Visible
                end)
                openButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        pickerPanel.Visible = not pickerPanel.Visible
                    end
                end)

                self:_registerElement(name, frame)
                toColor3(default.R, default.G, default.B)
                return frame
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
        local image = options.Image or ""

        local notifContainer = screenGui:FindFirstChild("NotificationRoot")
        if not notifContainer then
            notifContainer = create(screenGui, "Frame", {
                Name = "NotificationRoot",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 320, 0, 0),
                Position = UDim2.new(1, -340, 1, -20),
                AnchorPoint = Vector2.new(1, 1),
            })
        end

        local notification = create(notifContainer, "Frame", {
            Name = "Notification",
            BackgroundColor3 = Color3.fromRGB(24, 0, 60),
            Size = UDim2.new(1, 0, 0, 90),
            Position = UDim2.new(0, 0, 0, notifContainer.AbsoluteSize.Y + 8),
            ClipsDescendants = true,
        })
        createCorner(notification, 16)
        createStroke(notification, Color3.fromRGB(160, 32, 240))
        createGradient(notification, Color3.fromRGB(40, 0, 120), Color3.fromRGB(0, 0, 20), 135)

        if image ~= "" then
            create(notification, "ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Image = image,
                Size = UDim2.new(0, 0, 0, 48),
                Position = UDim2.new(0.03, 0, 0.1, 0),
                ScaleType = Enum.ScaleType.Fit,
            })
        end

        local titleLabel = create(notification, "TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 17,
            Size = UDim2.new(1, -24, 0, 24),
            Position = UDim2.new(0.03, 0, 0.1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local contentLabel = create(notification, "TextLabel", {
            Name = "Content",
            BackgroundTransparency = 1,
            Text = content,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextTransparency = 0.2,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            Size = UDim2.new(1, -24, 0, 40),
            Position = UDim2.new(0.03, 0, 0.35, 0),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        notifContainer.Size = UDim2.new(0, 320, 0, notifContainer.AbsoluteSize.Y + 98)
        tween(notification, {Position = UDim2.new(0, 0, 0, notifContainer.AbsoluteSize.Y - 98)}, 0.25)

        task.delay(duration, function()
            tween(notification, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.25)
            task.wait(0.25)
            if notification and notification.Parent then
                notification:Destroy()
            end
            notifContainer.Size = UDim2.new(0, 320, 0, notifContainer.AbsoluteSize.Y - 98)
        end)
    end

    function self:JoinDiscord(inviteCode)
        local invite = string.format("https://discord.gg/%s", inviteCode)
        setClipboard(invite)
        self:Notify({
            Title = "Discord Link Copied",
            Content = "Discord invite copied to clipboard: " .. invite,
            Duration = 5,
        })
    end

    function window:_initializeDragging()
        local dragRoot = header
        local function update(input)
            local delta = input.Position - window._dragStart
            root.Position = UDim2.new(0, window._startPos.X + delta.X, 0, window._startPos.Y + delta.Y)
        end

        self._connections[#self._connections + 1] = dragRoot.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                self._dragInput = input
                self._dragStart = input.Position
                self._startPos = {X = root.AbsolutePosition.X, Y = root.AbsolutePosition.Y}
                self._isDragging = true
            end
        end)

        self._connections[#self._connections + 1] = UserInputService.InputChanged:Connect(function(input)
            if input == self._dragInput and self._isDragging then
                update(input)
            end
        end)

        self._connections[#self._connections + 1] = UserInputService.InputEnded:Connect(function(input)
            if input == self._dragInput then
                self._dragInput = nil
                self._isDragging = false
            end
        end)
    end

    self._connections[#self._connections + 1] = searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = searchBox.Text or ""
        self:_refreshSearch(text)
    end)

    self._loadConfig(self)
    self:_initializeDragging()

    task.spawn(function()
        local increments = {0.15, 0.4, 0.7, 1}
        for index, progress in ipairs(increments) do
            tween(loadingProgress, {Size = UDim2.new(progress, 0, 1, 0)}, 0.35)
            loadingText.Text = loadingTitle .. "  (" .. math.floor(progress * 100) .. "%)"
            task.wait(0.32)
        end
        task.wait(0.3)
        tween(loadingOverlay, {BackgroundTransparency = 1}, 0.25)
        task.wait(0.25)
        loadingOverlay:Destroy()
    end)

    table.insert(self._instances, window)
    return window
end

return Paxz
