--[[
================================================================================
    ROBLOX UI LIBRARY - UNIVERSAL ENGINE v2.5.0
    Modular, Multi-Theme Dynamic UI Framework for Roblox
    Supports 80+ distinct design themes with runtime customization.
================================================================================
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UniversalLibrary = {
    Version = "2.5.0",
    ActiveWindows = {},
    DefaultTheme = {
        Name = "Universal Matrix Cyber",
        Background = Color3.fromRGB(12, 14, 20),
        BackgroundTransparency = 0,
        Surface = Color3.fromRGB(22, 26, 38),
        SurfaceTransparency = 0,
        SurfaceHover = Color3.fromRGB(32, 38, 54),
        Primary = Color3.fromRGB(0, 240, 255),
        PrimaryGlow = Color3.fromRGB(0, 240, 255),
        Secondary = Color3.fromRGB(255, 0, 127),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(140, 155, 180),
        Border = Color3.fromRGB(0, 240, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        Danger = Color3.fromRGB(255, 50, 70),
        Success = Color3.fromRGB(0, 255, 128),
        Radius = 8,
        BorderWidth = 1.5,
        Font = Enum.Font.SciFi,
        EasingStyle = Enum.EasingStyle.Back,
        EasingDirection = Enum.EasingDirection.Out,
        TweenDuration = 0.25
    }
}

-- ScreenGui initialization
local function GetScreenGui()
    local existing = PlayerGui:FindFirstChild("RobloxUniversalUI_Host")
    if existing then return existing end

    local gui = Instance.new("ScreenGui")
    gui.Name = "RobloxUniversalUI_Host"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 100

    pcall(function()
        gui.Parent = CoreGui
    end)
    if not gui.Parent or gui.Parent ~= CoreGui then
        gui.Parent = PlayerGui
    end

    return gui
end

local ScreenGui = GetScreenGui()

-- Quick Tween Utility
local function Tween(instance, properties, duration, style, direction)
    local tInfo = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(instance, tInfo, properties)
    t:Play()
    return t
end

-- Corner Radius Utility
local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

-- Stroke Utility
local function AddStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color or Color3.fromRGB(0, 240, 255)
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

-- Toast Notification Container
local NotifyContainer = Instance.new("Frame")
NotifyContainer.Name = "NotifyContainer"
NotifyContainer.Size = UDim2.new(0, 320, 1, -40)
NotifyContainer.Position = UDim2.new(1, -340, 0, 20)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.ZIndex = 999
NotifyContainer.Parent = ScreenGui

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.Padding = UDim.new(0, 8)
NotifyLayout.Parent = NotifyContainer

function UniversalLibrary:Notify(config)
    config = typeof(config) == "table" and config or { Title = "Notification", Content = tostring(config) }
    local title = config.Title or "Notice"
    local content = config.Content or ""
    local duration = config.Duration or 4
    local notifyType = config.Type or "info"

    local accentColor = self.DefaultTheme.Primary
    if notifyType == "success" then accentColor = self.DefaultTheme.Success
    elseif notifyType == "danger" then accentColor = self.DefaultTheme.Danger
    elseif notifyType == "warning" then accentColor = self.DefaultTheme.Secondary end

    local Toast = Instance.new("Frame")
    Toast.Name = "Toast"
    Toast.Size = UDim2.new(1, 0, 0, 68)
    Toast.BackgroundColor3 = self.DefaultTheme.Surface
    Toast.BackgroundTransparency = 1
    Toast.ClipsDescendants = true
    Toast.Parent = NotifyContainer

    AddCorner(Toast, self.DefaultTheme.Radius)
    local stroke = AddStroke(Toast, accentColor, 1.5)
    stroke.Transparency = 1

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 4, 1, 0)
    Bar.BackgroundColor3 = accentColor
    Bar.BorderSizePixel = 0
    Bar.Parent = Toast

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Text = title
    TitleLbl.Font = self.DefaultTheme.Font
    TitleLbl.TextSize = 14
    TitleLbl.TextColor3 = self.DefaultTheme.Text
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Position = UDim2.new(0, 16, 0, 8)
    TitleLbl.Size = UDim2.new(1, -26, 0, 20)
    TitleLbl.Parent = Toast

    local DescLbl = Instance.new("TextLabel")
    DescLbl.Text = content
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.TextSize = 12
    DescLbl.TextColor3 = self.DefaultTheme.TextDim
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.TextWrapped = true
    DescLbl.BackgroundTransparency = 1
    DescLbl.Position = UDim2.new(0, 16, 0, 28)
    DescLbl.Size = UDim2.new(1, -26, 0, 32)
    DescLbl.Parent = Toast

    Tween(Toast, { BackgroundTransparency = self.DefaultTheme.SurfaceTransparency }, 0.25)
    Tween(stroke, { Transparency = 0 }, 0.25)

    task.delay(duration, function()
        if Toast and Toast.Parent then
            local f = Tween(Toast, { BackgroundTransparency = 1 }, 0.25)
            Tween(stroke, { Transparency = 1 }, 0.25)
            Tween(TitleLbl, { TextTransparency = 1 }, 0.2)
            Tween(DescLbl, { TextTransparency = 1 }, 0.2)
            f.Completed:Connect(function()
                Toast:Destroy()
            end)
        end
    end)
end

function UniversalLibrary:CreateWindow(config)
    config = config or {}
    local theme = config.Theme or self.DefaultTheme
    local title = config.Title or "Roblox UI Library"
    local subtitle = config.Subtitle or "Universal Edition"
    local size = config.Size or UDim2.new(0, 560, 0, 420)

    local Win = Instance.new("CanvasGroup")
    Win.Name = "Window_" .. title
    Win.Size = size
    Win.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    Win.BackgroundColor3 = theme.Background
    Win.BackgroundTransparency = theme.BackgroundTransparency or 0
    Win.ClipsDescendants = true
    Win.Parent = ScreenGui

    AddCorner(Win, theme.Radius + 2)
    AddStroke(Win, theme.Border, theme.BorderWidth or 1.5)

    -- Header Bar
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 48)
    Header.BackgroundColor3 = theme.Surface
    Header.BackgroundTransparency = theme.SurfaceTransparency or 0
    Header.BorderSizePixel = 0
    Header.Parent = Win

    local HeaderDiv = Instance.new("Frame")
    HeaderDiv.Size = UDim2.new(1, 0, 0, 1)
    HeaderDiv.Position = UDim2.new(0, 0, 1, -1)
    HeaderDiv.BackgroundColor3 = theme.Border
    HeaderDiv.BackgroundTransparency = 0.6
    HeaderDiv.BorderSizePixel = 0
    HeaderDiv.Parent = Header

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Text = title
    TitleLbl.Font = theme.Font
    TitleLbl.TextSize = 15
    TitleLbl.TextColor3 = theme.Primary
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Position = UDim2.new(0, 16, 0, 6)
    TitleLbl.Size = UDim2.new(0.6, 0, 0, 20)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Parent = Header

    local SubtitleLbl = Instance.new("TextLabel")
    SubtitleLbl.Text = subtitle
    SubtitleLbl.Font = Enum.Font.Gotham
    SubtitleLbl.TextSize = 11
    SubtitleLbl.TextColor3 = theme.TextDim
    SubtitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLbl.Position = UDim2.new(0, 16, 0, 26)
    SubtitleLbl.Size = UDim2.new(0.6, 0, 0, 16)
    SubtitleLbl.BackgroundTransparency = 1
    SubtitleLbl.Parent = Header

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -38, 0, 9)
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.TextColor3 = theme.TextDim
    CloseBtn.BackgroundColor3 = theme.Surface
    CloseBtn.Parent = Header
    AddCorner(CloseBtn, 6)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = theme.Danger, TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = theme.Surface, TextColor3 = theme.TextDim }, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Win, { Size = UDim2.new(0, 0, 0, 0) }, 0.25).Completed:Connect(function()
            Win:Destroy()
        end)
    end)

    -- Dragging
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Win.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Win.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Sidebar & Tab Container
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, -48)
    Sidebar.Position = UDim2.new(0, 0, 0, 48)
    Sidebar.BackgroundColor3 = theme.Surface
    Sidebar.BackgroundTransparency = 0.6
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Win

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SideLayout.Padding = UDim.new(0, 6)
    SideLayout.Parent = Sidebar

    local SidePad = Instance.new("UIPadding")
    SidePad.PaddingTop = UDim.new(0, 10)
    SidePad.PaddingLeft = UDim.new(0, 8)
    SidePad.PaddingRight = UDim.new(0, 8)
    SidePad.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -140, 1, -48)
    ContentArea.Position = UDim2.new(0, 140, 0, 48)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Win

    local WinObject = { Tabs = {} }

    function WinObject:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.Text = "  " .. name
        TabBtn.Font = theme.Font
        TabBtn.TextSize = 13
        TabBtn.TextColor3 = theme.TextDim
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.BackgroundColor3 = theme.Surface
        TabBtn.BackgroundTransparency = 1
        TabBtn.Parent = Sidebar
        AddCorner(TabBtn, theme.Radius - 2)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = theme.Primary
        Page.Visible = false
        Page.Parent = ContentArea

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop = UDim.new(0, 12)
        PagePad.PaddingLeft = UDim.new(0, 14)
        PagePad.PaddingRight = UDim.new(0, 14)
        PagePad.PaddingBottom = UDim.new(0, 12)
        PagePad.Parent = Page

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 24)
        end)

        local function Select()
            for _, t in pairs(WinObject.Tabs) do
                Tween(t.Btn, { BackgroundTransparency = 1, TextColor3 = theme.TextDim }, 0.2)
                t.Page.Visible = false
            end
            Tween(TabBtn, { BackgroundTransparency = 0.2, TextColor3 = theme.Primary, BackgroundColor3 = theme.SurfaceHover }, 0.2)
            Page.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(Select)

        table.insert(WinObject.Tabs, { Btn = TabBtn, Page = Page })
        if #WinObject.Tabs == 1 then Select() end

        local Elements = {}

        function Elements:CreateButton(opt)
            opt = opt or {}
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 38)
            btn.BackgroundColor3 = theme.Surface
            btn.Text = opt.Name or "Button"
            btn.Font = theme.Font
            btn.TextSize = 13
            btn.TextColor3 = theme.Text
            btn.Parent = Page
            AddCorner(btn, theme.Radius - 2)
            local str = AddStroke(btn, theme.Border, 1)

            btn.MouseButton1Click:Connect(function()
                Tween(btn, { Size = UDim2.new(1, -4, 0, 36) }, 0.08).Completed:Connect(function()
                    Tween(btn, { Size = UDim2.new(1, 0, 0, 38) }, 0.1)
                end)
                if opt.Callback then pcall(opt.Callback) end
            end)
            return btn
        end

        function Elements:CreateToggle(opt)
            opt = opt or {}
            local state = opt.Default or false
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 42)
            card.BackgroundColor3 = theme.Surface
            card.Parent = Page
            AddCorner(card, theme.Radius - 2)
            AddStroke(card, theme.Border, 1)

            local lbl = Instance.new("TextLabel")
            lbl.Text = opt.Name or "Toggle"
            lbl.Font = theme.Font
            lbl.TextSize = 13
            lbl.TextColor3 = theme.Text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.Size = UDim2.new(1, -64, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Parent = card

            local sw = Instance.new("TextButton")
            sw.Text = ""
            sw.Size = UDim2.new(0, 40, 0, 20)
            sw.Position = UDim2.new(1, -50, 0.5, -10)
            sw.BackgroundColor3 = state and theme.Primary or theme.SurfaceHover
            sw.Parent = card
            AddCorner(sw, 10)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.Parent = sw
            AddCorner(knob, 7)

            sw.MouseButton1Click:Connect(function()
                state = not state
                Tween(knob, { Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.2)
                Tween(sw, { BackgroundColor3 = state and theme.Primary or theme.SurfaceHover }, 0.2)
                if opt.Callback then pcall(opt.Callback, state) end
            end)
        end

        function Elements:CreateSlider(opt)
            opt = opt or {}
            local min = opt.Min or 0
            local max = opt.Max or 100
            local cur = opt.Default or min
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 50)
            card.BackgroundColor3 = theme.Surface
            card.Parent = Page
            AddCorner(card, theme.Radius - 2)
            AddStroke(card, theme.Border, 1)

            local lbl = Instance.new("TextLabel")
            lbl.Text = opt.Name or "Slider"
            lbl.Font = theme.Font
            lbl.TextSize = 13
            lbl.TextColor3 = theme.Text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Position = UDim2.new(0, 12, 0, 6)
            lbl.Size = UDim2.new(0.7, 0, 0, 16)
            lbl.BackgroundTransparency = 1
            lbl.Parent = card

            local valLbl = Instance.new("TextLabel")
            valLbl.Text = tostring(cur)
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 13
            valLbl.TextColor3 = theme.Primary
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Position = UDim2.new(0.7, 0, 0, 6)
            valLbl.Size = UDim2.new(0.3, -12, 0, 16)
            valLbl.BackgroundTransparency = 1
            valLbl.Parent = card

            local bar = Instance.new("TextButton")
            bar.Text = ""
            bar.Size = UDim2.new(1, -24, 0, 5)
            bar.Position = UDim2.new(0, 12, 0, 32)
            bar.BackgroundColor3 = theme.SurfaceHover
            bar.Parent = card
            AddCorner(bar, 3)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((cur - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = theme.Primary
            fill.BorderSizePixel = 0
            fill.Parent = bar
            AddCorner(fill, 3)

            local dragging = false
            local function Update(input)
                local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pct)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                valLbl.Text = tostring(val)
                if opt.Callback then pcall(opt.Callback, val) end
            end

            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(input)
                end
            end)
        end

        return Elements
    end

    return WinObject
end

return UniversalLibrary
