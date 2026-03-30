--* use /libs/Logging/log.lua
--* use /libs/Controls/ref.lua
--* use /libs/Controls/basic/layout.lua
--* use /libs/Controls/composite/checkbox.lua

local logger = Logger("/tests/ControlsSample/test.lua")

local function OnTrigger()
    logger:trace("triggered")
    if ControlsRegistry["E_WINDOW"] ~= nil then
        logger:trace("opening existing window")
        local layout = ControlsRegistry["E_WINDOW"] --[[@as Layout]]
        layout.hidden:set(false)
        return
    end
    local layout = Controls.layout("E_WINDOW", {
        hidden = Ref(false),
        anchors = Ref({
            { point = TOPLEFT, target = GuiRoot, relativePoint = CENTER, offsetX = 0, offsetY = 0 },
        }),
        height = Ref(100),
        width = Ref(100),
    })
    logger:trace("window created")

    local checkbox = Controls.checkbox("E_CHECKBOX", layout, {
        hidden = Ref(false),
        anchors = Ref({
            { point = TOPLEFT,     target = layout.element, relativePoint = TOPLEFT,     offsetX = 0, offsetY = 0 },
            { point = BOTTOMRIGHT, target = layout.element, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
        }),
    })
    checkbox.state:use("E_CHECKBOX-state", function (_, v)
        if v then
            checkbox.text:set("enabled")
        else
            checkbox.text:set("disabled")
        end
    end)
    logger:trace("checkbox created")
end

local function Initialize(_, addOnName)
    if addOnName ~= "ProjectE" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("E_ControlsSample", EVENT_ADD_ON_LOADED)
    ZO_GameMenu_AddSettingPanel({
        id = "E_SETTINGS",
        name = "ProjectE",
        longname = "ProjectE Settings",
        callback = function()
            OnTrigger()
        end,
        unselectedCallback = function()
            local layout = ControlsRegistry["E_WINDOW"] --[[@as Layout]]
            if layout == nil then return end
            layout.hidden:set(true)
        end,
    })
end

EVENT_MANAGER:RegisterForEvent("E_ControlsSample", EVENT_ADD_ON_LOADED, Initialize)
