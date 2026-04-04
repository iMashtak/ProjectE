--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua
--* use ./scrollArea.lua

---@class TabPanels : Control
---@field state Ref<string?>
---@field tabNames Ref<string[]>
---@field panels {[string]: ScrollArea}

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

    ---@type {[string]: ScrollArea}
    local panels = {}

    if args.state == nil then
        args.state = Ref(nil)
    end
    args.state:use(id .. "-tabPanels-state", function(old, new)
        if old ~= nil and panels[old] ~= nil then
            panels[old].params.hidden:set(true)
        end
        if new ~= nil and panels[new] ~= nil then
            panels[new].params.hidden:set(false)
        end
    end)
    result.state = args.state

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
