--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua
--* use ./scrollList.lua

---@class Tabs : Element
---@field params TabsParams
---@field handlers TabsHandlers
---@field children TabsChildren

---@class TabsParams : ControlParams
---@field state Ref<string|nil>
---@field tabNames Ref<string[]>

---@class TabsHandlers : ControlHandlers

---@class TabsChildren

---@class TabsParamsArgs : ControlParamsArgs
---@field state Ref<string|nil>?
---@field tabNames Ref<string[]>?

---@class TabsEventsArgs : ControlEventsArgs

---@class TabsSlotsArgs

---@param id string
---@param parent Element
---@param args {
---    params: TabsParamsArgs?,
---    events: TabsEventsArgs?,
---    slots: TabsSlotsArgs?,
---}
---@return Tabs
---@nodiscard
function Controls.tabs(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as Tabs]]

    if args.params.state == nil then
        args.params.state = Ref(nil)
    end
    if args.params.tabNames == nil then
        args.params.tabNames = Ref({})
    end

    local scroll = Controls.scrollList(id .. "-scroll", result, {
        params = {
            anchors = Ref({
                { point = TOPLEFT, result.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 }
            }),
            hidden = Ref(false),
            height = result.params.height,
            width = result.params.width,
            entries = args.params.tabNames,
        },
        events = {
            onSelected = Ref(function(_, new)
                if new == nil then
                    args.params.state:set(nil)
                else
                    args.params.state:set(new.text)
                end
            end),
        }
    })

    return result
end
