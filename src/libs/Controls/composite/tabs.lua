--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua
--* use ../basic/label.lua
--* use ./scrollList.lua

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

    if args.state == nil then
        args.state = Ref(nil)
    end
    result.state = args.state
    if args.tabNames == nil then
        args.tabNames = Ref({})
    end
    result.tabNames = args.tabNames

    local scroll = Controls.scrollList(id .. "-scroll", result, {
        anchors = Ref({
            { point = TOPLEFT, result.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 }
        }),
        hidden = Ref(false),
        height = result.height,
        width = result.width,
        onSelected = Ref(function (_, new)
            args.state:set(new.text)
        end),
        entries = args.tabNames,
    })

    return result
end
