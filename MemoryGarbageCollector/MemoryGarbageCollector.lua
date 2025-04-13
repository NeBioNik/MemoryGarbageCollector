MemoryGarbageCollector = {
    name = "MemoryGarbageCollector",
    version = "dev",
    author = "|cbf16b9NeBioNik|r [@BioNik12]",

    fullName = "Memory Garbage Collector",
    shortName = "MGC",
    prefix = "|cbf16b9[MGC]|r",

    chat = nil,

    color = {
        main = "bf16b9",
        grey = "666666",
    },

    config = {}
}

local MGC = MemoryGarbageCollector

-- Cleanup threshold
MGC.maxMemoryUsage = 0

local DEFAULT_SAVED_VARS = {
    autoClear = true,
    refreshRate = 10, -- minutes
    comparisonMethod = 1,
    overflowRelative = 10, -- percent
    overflowAbsolute = 50, -- MB
    showDebugMessages = false,
}

local SF = string.format

-- GetFormattedString
local GFS = function(STR_NAME, ...)
    return SF(GetString(STR_NAME), ...)
end

function MGC:Initialize()
    self.config = ZO_SavedVars:NewAccountWide(self.name .. 'SV', 1, nil, DEFAULT_SAVED_VARS)

    self:InitMenu()

    -- Start with 15 sec delay and calculate starting memory usage.
    zo_callLater(function()
        self:refreshSettings()
    end, 15000)
end

function MGC:InitMenu()
    local LAM = LibAddonMenu2
    local panelName = self.name .. "_LAM"

    local panelData = {
        type = "panel",
        name = self.fullName,
        author = self.author,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "description",
            text = GFS(ADDON_DESCRIPTION),
        },
        {
            type = "divider",
            alpha = 0.4,
        },
        {
            type = "checkbox",
            name = GFS(AUTO_CLEAR),
            tooltip = GFS(AUTO_CLEAR_TOOLTIP),
            getFunc = function()
                return self.config.autoClear
            end,
            setFunc = function(v)
                self.config.autoClear = v
                self:refreshSettings()
            end,
            default = DEFAULT_SAVED_VARS.autoClear,
        },
        {
            type = "slider",
            name = GFS(REFRESH_RATE),
            tooltip = GFS(REFRESH_RATE_TOOLTIP),
            min = 1,
            max = 60,
            decimals = 0,
            disabled = function()
                return not self.config.autoClear
            end,
            getFunc = function()
                return self.config.refreshRate
            end,
            setFunc = function(v)
                self.config.refreshRate = v
                self:refreshSettings()
            end,
            default = DEFAULT_SAVED_VARS.refreshRate,
        },
        {
            type = "dropdown",
            name = GFS(COMPARISON_METHOD),
            tooltip = GFS(COMPARISON_METHOD_TOOLTIP),
            disabled = function()
                return not self.config.autoClear
            end,
            getFunc = function()
                return self.config.comparisonMethod
            end,
            setFunc = function(v)
                self.config.comparisonMethod = v
                self:refreshSettings()
            end,
            choicesValues = { 1, 2 },
            choices = { GFS(OVERFLOW_RELATIVE), GFS(OVERFLOW_ABSOLUTE) },
            default = DEFAULT_SAVED_VARS.comparisonMethod,
        },
        {
            type = "slider",
            name = GFS(OVERFLOW_RELATIVE),
            tooltip = GFS(OVERFLOW_RELATIVE_TOOLTIP),
            min = 5,
            max = 50,
            step = 5,
            decimals = 0,
            disabled = function()
                return not (self.config.autoClear and self.config.comparisonMethod == 1)
            end,
            getFunc = function()
                return self.config.overflowRelative
            end,
            setFunc = function(v)
                self.config.overflowRelative = v
                self:refreshSettings()
            end,
            default = DEFAULT_SAVED_VARS.overflowRelative,
        },
        {
            type = "slider",
            name = GFS(OVERFLOW_ABSOLUTE),
            tooltip = GFS(OVERFLOW_ABSOLUTE_TOOLTIP),
            min = 30,
            max = 500,
            step = 25,
            decimals = 0,
            disabled = function()
                return not (self.config.autoClear and self.config.comparisonMethod == 2)
            end,
            getFunc = function()
                return self.config.overflowAbsolute
            end,
            setFunc = function(v)
                self.config.overflowAbsolute = v
                self:refreshSettings()
            end,
            default = DEFAULT_SAVED_VARS.overflowAbsolute,
        },
        {
            type = "checkbox",
            name = GetString(SI_SETTINGSYSTEMPANEL6),
            tooltip = GetString(SHOW_DEBUG_MESSAGES),
            disabled = function()
                return not self.config.autoClear
            end,
            getFunc = function()
                return self.config.showDebugMessages
            end,
            setFunc = function(v)
                self.config.showDebugMessages = v
                self:refreshSettings()
            end,
            default = DEFAULT_SAVED_VARS.showDebugMessages,
        },
    }

    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
end

function MGC:refreshSettings()
    MGC:calcMaxMemory()
    MGC:setRefreshTimer()
end

function MGC:setRefreshTimer()
    local eventName = MGC.name .. "_Auto"
    EVENT_MANAGER:UnregisterForUpdate(eventName)

    if MGC.config.autoClear == true then
        local refreshSeconds = MGC.config.refreshRate * 60 * 1000 -- min to seconds
        EVENT_MANAGER:RegisterForUpdate(eventName, refreshSeconds, function()
            MGC:checkGarbage()
        end)
    end
end

function MGC:calcMaxMemory(memory)
    if not memory then
        memory = self:currentMemory()
    end

    local max = 1024
    if self.config.comparisonMethod == 1 then
        max = memory * (1 + self.config.overflowRelative / 100)
    else
        max = memory + self.config.overflowAbsolute
    end

    -- Round to 5 MB
    max = math.ceil(max / 5) * 5

    self:sendDebugMessage(GFS(MEMORY_INIT_MAX, max))
    self.maxMemoryUsage = max
end

function MGC:currentMemory()
    return math.ceil(collectgarbage("count") / 1024)
end

function MGC:checkGarbage()
    if IsUnitInCombat("player") then
        return
    end

    local limit = self.maxMemoryUsage or 1024;
    local current = self:currentMemory()

    -- Check currently used memory for overflow limit.
    self:sendDebugMessage(GFS(MEMORY_OVERFLOW_DEBUG, current, limit))
    if current <= limit then
        return
    end

    -- Run garbage collect when overflow is reached.
    collectgarbage("collect")

    local after = self:currentMemory()
    self:calcMaxMemory(after)

    self:chatMessage(GFS(MEMORY_OVERFLOW_REACHED, current, after, current - after))
end

-- Send message to game chat
function MGC:chatMessage(message)
    if LibChatMessage then
        if not self.chat then
            self.chat = LibChatMessage(self.shortName, self.shortName)
        end

        local formatted = SF("|c%s[%s]|r %s", self.color.grey, GetTimeString(), message)
        self.chat:SetTagColor(self.color.main):Printf(formatted)
    else
        local formatted = SF("%s |c%s[%s]|r %s", self.prefix, self.color.grey, GetTimeString(), message)
        CHAT_SYSTEM:AddMessage(formatted)
    end
end

-- Send debug message to game chat
function MGC:sendDebugMessage(message)
    if self.config.showDebugMessages then
        self:chatMessage(message)
    end
end

function MGC.OnAddOnLoaded(_, addonName)
    if addonName ~= MGC.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(MGC.name, EVENT_ADD_ON_LOADED)

    MGC:Initialize()
end

EVENT_MANAGER:RegisterForEvent(MGC.name, EVENT_ADD_ON_LOADED, MGC.OnAddOnLoaded)
