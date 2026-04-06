---@alias LogLevel "trace" | "debug" | "info" | "warn" | "error" | "off"

L = {}

local logLevelNumbering = {
    ["trace"] = 1,
    ["debug"] = 2,
    ["info"] = 3,
    ["warn"] = 4,
    ["error"] = 5,
    ["off"] = 6,
}

local function startsWith(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

---@type {root: LogLevel, loggers: {[string]: LogLevel}}
LogLevelSettings = {
    root = "off",
    loggers = {
        ["/tests/"] = "trace",
        ["/extensions/"] = "trace",
        ["/libs/"] = "trace",
    },
}

---@alias LogMessage string | fun(): string

---@class Logger
---@field log fun(self: Logger, level: LogLevel, message: LogMessage)
---@field error fun(self: Logger, message: LogMessage)
---@field warn fun(self: Logger, message: LogMessage)
---@field info fun(self: Logger, message: LogMessage)
---@field debug fun(self: Logger, message: LogMessage)
---@field trace fun(self: Logger, message: LogMessage)

---@param name string
---@return Logger
function Logger(name)
    local self = {}

    local function log(level, message)
        local m = message
        if type(message) == "function" then
            m = message()
        end
        L[#L + 1] = level .. " [" .. name .. "] " .. m
        d(level .. " [" .. name .. "] " .. m)
    end

    ---@param level LogLevel
    ---@param message LogMessage
    function self:log(level, message)
        local selectedLevel = LogLevelSettings.root
        for definedLogger, definedLevel in pairs(LogLevelSettings.loggers) do
            if startsWith(name, definedLogger) then
                selectedLevel = definedLevel
            end
        end
        local number = logLevelNumbering[level]
        local selectedNumber = logLevelNumbering[selectedLevel]
        if selectedNumber <= number then
            log(level, message)
        end
    end

    ---@param message LogMessage
    function self:error(message)
        self:log("error", message)
    end

    ---@param message LogMessage
    function self:warn(message)
        self:log("warn", message)
    end

    ---@param message LogMessage
    function self:info(message)
        self:log("info", message)
    end

    ---@param message LogMessage
    function self:debug(message)
        self:log("debug", message)
    end

    ---@param message LogMessage
    function self:trace(message)
        self:log("trace", message)
    end

    return self
end
