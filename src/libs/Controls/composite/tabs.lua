--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua
--* use ../basic/label.lua

---@class Tabs : Control
---@field state Ref<string?>
---@field tabNames Ref<string[]>

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
---@return Tabs
function Controls.tabs(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as Tabs]]

    ---@type {[string]: Label}
    local tabControls = {}

    if args.state == nil then
        args.state = Ref(nil)
    end
    result.state = args.state

    local function createTab(name)
        local tab = Controls.label(id .. "-tab-" .. name, result, {
            hidden = Ref(false),
            height = Ref(32),
            width = Ref(e:GetWidth()),
            mouseEnabled = Ref(true),
            text = Ref(name),
        })
        tab.handlers.onMouseDown:set(function(self, button, ctrl, alt, shift, command)
            args.state:set(name)
        end)
        return tab
    end

    if args.tabNames == nil then
        args.tabNames = Ref({})
    end
    args.tabNames:use(id .. "-tabNames", function(_, v)
        if #tabControls < #v then
            for i = 1, #tabControls do
                tabControls[v[i]].text:set(v[i])
                tabControls[v[i]].hidden:set(false)
            end
            for i = #tabControls + 1, #v do
                local tab = createTab(v[i])
                tabControls[v[i]] = tab
            end
        elseif #tabControls > #v then
            for i = 1, #v do
                tabControls[v[i]].text:set(v[i])
            end
            for i = #v + 1, #tabControls do
                tabControls[v[i]].hidden:set(true)
            end
        end
        ---@type Label?
        local previous = nil
        for _, name in ipairs(v) do
            local tab = tabControls[name]
            if previous == nil then
                tab.anchors:set({
                    { point = TOPLEFT, target = e, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 }
                })
            else
                tab.anchors:set({
                    { point = TOPLEFT, target = previous.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = 0 }
                })
            end
            previous = tab
        end
    end)
    result.tabNames = args.tabNames

    return result
end
