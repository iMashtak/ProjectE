--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua
--* use ./scrollArea.lua

---@class TabPanels : Element
---@field params TabPanelsParams
---@field handlers TabPanelsHandlers
---@field children TabPanelsChildren

---@class TabPanelsParams : ControlParams
---@field state Ref<string|nil>
---@field tabNames Ref<string[]>

---@class TabPanelsHandlers : ControlHandlers

---@class TabPanelsChildren
---@field panels {[string]: ScrollArea}

---@class TabPanelsParamsArgs : ControlParamsArgs
---@field state Ref<string|nil>?
---@field tabNames Ref<string[]>?

---@class TabPanelsEventsArgs : ControlEventsArgs

---@class TabPanelsSlotsArgs

---@param id string
---@param parent Element
---@param args {
---    params: TabPanelsParamsArgs?,
---    events: TabPanelsEventsArgs?,
---    slots: TabPanelsSlotsArgs?,
---}
---@return TabPanels
---@nodiscard
function Controls.tabPanels(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as TabPanels]]

    ---@type {[string]: ScrollArea}
    local panels = {}

    if args.params.state == nil then
        args.params.state = Ref(nil)
    end
    args.params.state:use(id .. "-tabPanels-state", function(old, new)
        if old ~= nil and panels[old] ~= nil then
            panels[old].params.hidden:set(true)
        end
        if new ~= nil and panels[new] ~= nil then
            panels[new].params.hidden:set(false)
        end
    end)

    local function createPanel(name)
        local panel = Controls.scrollArea(id .. "-panel-" .. name, result, {
            params = {
                anchors = Ref({
                    { point = TOPLEFT,     target = result.element, relativePoint = TOPLEFT,     offsetX = 0, offsetY = 0 },
                    { point = BOTTOMRIGHT, target = result.element, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
                })
            },
        })
        return panel
    end

    if args.params.tabNames == nil then
        args.params.tabNames = Ref({})
    end
    args.params.tabNames:use(id .. "-tabNames", function(_, v)
        -- TODO ineffective
        for _, name in ipairs(v) do
            if panels[name] == nil then
                panels[name] = createPanel(name)
            end
        end
    end)

    result.children.panels = panels

    return result
end
