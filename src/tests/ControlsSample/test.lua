--* use /libs/Logging/log.lua
--* use /libs/Controls/ref.lua
--* use /libs/Controls/layout.lua
--* use /libs/Controls/checkbox.lua
--* use /libs/Logging/log.lua

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
        text = Ref("description of checkbox"),
        anchors = Ref({
            { point = TOPLEFT,     target = layout.element, relativePoint = TOPLEFT,     offsetX = 0, offsetY = 0 },
            { point = BOTTOMRIGHT, target = layout.element, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
        }),
    })
    logger:trace("checkbox created")
end

local function Initialize(eventCode, addOnName)
    if addOnName ~= "ProjectE" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("E_ControlsSample", EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS["/econtrolssample"] = OnTrigger
end

EVENT_MANAGER:RegisterForEvent("E_ControlsSample", EVENT_ADD_ON_LOADED, Initialize)
