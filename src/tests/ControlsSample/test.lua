--* use /libs/Controls/ref.lua
--* use /libs/Controls/layout.lua
--* use /libs/Controls/checkbox.lua

local function OnTrigger()
    d("triggered")
    local layout = Controls.layout("E_WINDOW", {
        hidden = Ref(false),
        anchors = Ref({
            { point = TOPLEFT, target = GuiRoot, relativePoint = CENTER, offsetX = 0, offsetY = 0 },
        }),
        height = Ref(100),
        width = Ref(100),
    })
    d("window created")

    -- local label = Controls.label("E_LABEL", layout, {
    --     hidden = Ref(false),
    --     text = Ref("test"),
    --     mouseEnabled = Ref(true),
    --     anchors = Ref(AnchorStyle(layout, "fill")),
    -- })
    -- label.handlers.onMouseDown:set(function(self, button, ctrl, alt, shift, command)
    --     d("clicked")
    --     local current = label.text:get()
    --     label.text:set(current .. "+used")
    -- end)
    -- d("label created")

    local checkbox = Controls.checkbox("E_CHECKBOX", layout, {
        hidden = Ref(false),
        text = Ref("description of checkbox"),
        anchors = Ref(AnchorStyle(layout, "fill")),
    })
    d("checkbox created")
end

local function Initialize(eventCode, addOnName)
    if addOnName ~= "ProjectE" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("E_ControlsSample", EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS["/econtrolssample"] = OnTrigger
end

EVENT_MANAGER:RegisterForEvent("E_ControlsSample", EVENT_ADD_ON_LOADED, Initialize)
