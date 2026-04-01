--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua

---@class TabPanels : Control
---@field state Ref<string?>
---@field tabNames Ref<string[]>
---@field panels {[string]: Control}

---@param id string
---@param parent Element
---@param args {
---    anchors: Ref<AnchorSetting[]>?,
---    hidden: Ref<boolean>?,
---    height: Ref<integer?>?,
---    mouseEnabled: Ref<boolean>?,
---    width: Ref<integer?>?,
---    state: Ref<string>?,
---    tabNames: Ref<string[]>?,
---}
---@return TabPanels
function Controls.tabPanels(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as TabPanels]]

    ---@type {[string]: Control}
    local panels = {}

    if args.state == nil then
        args.state = Ref(nil)
    end
    args.state:use(id .. "-tabPanels-state", function(old, new)
        if old ~= nil and panels[old] ~= nil then
            panels[old].hidden:set(true)
        end
        if new ~= nil and panels[new] ~= nil then
            panels[new].hidden:set(false)
        end
    end)
    result.state = args.state

    local function createPanel(name)
        local panelControl = WINDOW_MANAGER:CreateControl(id .. "-panel-" .. name, parent.element, CT_CONTROL)
        local panel = Controls.setupControl(id .. "-panel-" .. name, panelControl, {
            anchors = Ref({
                { point = TOPLEFT,     target = e, relativePoint = TOPLEFT,     offsetX = 0, offsetY = 0 },
                { point = BOTTOMRIGHT, target = e, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
            })
        })
        return panel
    end

    if args.tabNames == nil then
        args.tabNames = Ref({})
    end
    args.tabNames:use(id .. "-tabNames", function(_, v)
        -- TODO ineffective
        for _, name in ipairs(v) do
            if panels[name] == nil then
                panels[name] = createPanel(name)
            end
        end
    end)
    result.tabNames = args.tabNames

    result.panels = panels
    return result
end
