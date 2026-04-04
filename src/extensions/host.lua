--* use /libs/Controls/main.lua
--* use /libs/Controls/basic/layout.lua
--* use /libs/Controls/basic/backdrop.lua
--* use /libs/Controls/composite/tabs.lua
--* use /libs/Controls/composite/tabPanels.lua

---@alias Extension {name: string, initializeExtension: fun(), initializeSettings: fun(parent: Element)}

---@type Extension[]
local Extensions = {}

---@param name string
---@param initializeExtension fun()
---@param initializeSettings fun(parent: Element)
function RegisterExtension(name, initializeExtension, initializeSettings)
    Extensions[#Extensions + 1] = {
        name = name,
        initializeExtension = initializeExtension,
        initializeSettings = initializeSettings,
    }
end

local function Initialize(_, addOnName)
    if addOnName ~= "ProjectE" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("E_EXTENSIONS", EVENT_ADD_ON_LOADED)

    local tabNames = {}
    for _, ext in ipairs(Extensions) do
        ext.initializeExtension()
        tabNames[#tabNames + 1] = ext.name
    end
    table.sort(tabNames)

    local layout = Controls.layout("E_EXTENSIONS_SETTINGS_LAYOUT", {
        anchors = Ref({
            { point = LEFT, target = GuiRoot, relativePoint = LEFT, offsetX = 300, offsetY = 0 },
        }),
        height = Ref(1000),
        width = Ref(900),
    })
    local bg = Controls.backdrop("E_EXTENSIONS_SETTINGS_BG", layout, {
        hidden = Ref(false),
        anchors = Ref({
            { point = TOPLEFT,     target = layout.element, relativePoint = TOPLEFT,     offsetX = 0, offsetY = 0 },
            { point = BOTTOMRIGHT, target = layout.element, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
        }),
        edgeSettings = Ref({ file = Textures.bg.chatEdge, width = 1, height = 1, size = 1, padding = 0 })
    })
    local tabs = Controls.tabs("E_EXTENSIONS_SETTINGS_TABS", bg, {
        hidden = Ref(false),
        height = layout.height,
        width = RefC("E_EXTENSIONS_SETTINGS_TABS_WIDTH", { layout.width }, function(width)
            return width / 3
        end),
        anchors = Ref({
            { point = TOPLEFT, target = bg.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 }
        }),
        tabNames = Ref(tabNames),
    })
    local panels = Controls.tabPanels("E_EXTENSIONS_SETTINGS_TAB_PANELS", bg, {
        hidden = Ref(false),
        height = layout.height,
        width = RefC("E_EXTENSIONS_SETTINGS_TAB_PANELS_WIDTH", { layout.width }, function(width)
            return width / 3 * 2
        end),
        anchors = Ref({
            { point = TOPLEFT, target = tabs.element, relativePoint = TOPRIGHT, offsetX = 0, offsetY = 0 }
        }),
        state = tabs.state,
        tabNames = tabs.tabNames,
    })
    tabs.state:set(tabs.state:get() --[[@as string]])
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

    for _, ext in ipairs(Extensions) do
        ext.initializeSettings(panels.panels[ext.name].children.inner)
    end
end

EVENT_MANAGER:RegisterForEvent("E_EXTENSIONS", EVENT_ADD_ON_LOADED, Initialize)
