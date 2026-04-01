--* use /libs/Logging/log.lua
--* use /libs/Controls/ref.lua
--* use /libs/Controls/basic/layout.lua
--* use /libs/Controls/composite/checkbox.lua

local logger = Logger("/tests/ControlsSample/test.lua")

local function Initialize(_, addOnName)
    if addOnName ~= "ProjectE" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("E_ControlsSample", EVENT_ADD_ON_LOADED)
    if ControlsRegistry["E_WINDOW"] ~= nil then
        logger:trace("opening existing window")
        local layout = ControlsRegistry["E_WINDOW"] --[[@as Layout]]
        layout.hidden:set(false)
        return
    end
    local layout = Controls.layout("E_WINDOW", {
        anchors = Ref({
            { point = LEFT, target = GuiRoot, relativePoint = LEFT, offsetX = 365, offsetY = 120 },
        }),
        height = Ref(1000),
        width = Ref(900),
    })
    local bg = Controls.backdrop("E_BG", layout, {
        hidden = Ref(false),
        anchors = Ref({
            { point = TOPLEFT,     target = layout.element, relativePoint = TOPLEFT,     offsetX = 0, offsetY = 0 },
            { point = BOTTOMRIGHT, target = layout.element, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
        }),
    })
    local checkbox = Controls.checkbox("E_CHECKBOX", bg, {
        hidden = Ref(false),
        anchors = Ref({
            { point = TOPLEFT,  target = layout.element, relativePoint = TOPLEFT,  offsetX = 0, offsetY = 0 },
            { point = TOPRIGHT, target = layout.element, relativePoint = TOPRIGHT, offsetX = 0, offsetY = 0 },
        }),
        height = Ref(50)
    })
    checkbox.state:use("E_CHECKBOX_TEXT", function(_, v)
        if v then
            checkbox.text:set("enabled")
        else
            checkbox.text:set("disabled")
        end
    end)
    local scene = ZO_FadeSceneFragment:New(layout.element, true, 100)
    scene:RegisterCallback("StateChange", function(_, newState)
        if (newState == SCENE_FRAGMENT_SHOWN) then
            PushActionLayerByName("OptionsWindow")
        elseif (newState == SCENE_FRAGMENT_HIDDEN) then
            RemoveActionLayerByName("OptionsWindow")
        end
    end)
    ZO_GameMenu_AddSettingPanel({
        id = "E_SETTINGS",
        name = "ProjectE",
        callback = function()
            SCENE_MANAGER:AddFragment(scene)
        end,
        unselectedCallback = function()
            SCENE_MANAGER:RemoveFragment(scene)
        end,
    })
end

-- EVENT_MANAGER:RegisterForEvent("E_ControlsSample", EVENT_ADD_ON_LOADED, Initialize)
