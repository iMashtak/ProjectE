--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua

-- TODO move

---@class ControlParams
---@field anchors Ref<AnchorSetting[]>
---@field height Ref<integer?>
---@field hidden Ref<boolean>
---@field mouseEnabled Ref<boolean>
---@field width Ref<integer?>

---@class ControlParamsArgs
---@field anchors Ref<AnchorSetting[]>?
---@field height Ref<integer?>?
---@field hidden Ref<boolean>?
---@field mouseEnabled Ref<boolean>?
---@field width Ref<integer?>?

-- decl --

---@class ScrollAreaParams : ControlParams

---@class ScrollAreaHandlers

---@class ScrollAreaChildren
---@field inner Element

---@class ScrollArea : Element
---@field params ScrollAreaParams
---@field handlers ScrollAreaHandlers
---@field children ScrollAreaChildren

-- impl --

---@class ScrollAreaParamsArgs : ControlParamsArgs

---@class ScrollAreaEventsArgs

---@class ScrollAreaSlotsArgs
---@field content fun(parent: Element)?

---@param id string
---@param parent Element
---@param args {
---    params: ScrollAreaParamsArgs,
---    events: ScrollAreaEventsArgs,
---    slots: ScrollAreaSlotsArgs,
---}
---@return ScrollArea
function Controls.scrollArea(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local ec = Controls.setupControl(id, e, args.params)

    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual(id .. "-scrollContainer", e, "ZO_ScrollContainer")
    scrollContainer:ClearAnchors()
    scrollContainer:SetAnchor(TOPLEFT, e, TOPLEFT, 0, 0)
    scrollContainer:SetAnchor(BOTTOMRIGHT, e, BOTTOMRIGHT, 0, 0)
    local inner = GetControl(scrollContainer, "ScrollChild")
    inner:SetResizeToFitPadding(0, 0)

    if args.slots ~= nil then
        if args.slots.content ~= nil then
            args.slots.content(inner)
        end
    end

    local result = {
        element = ec.element,
        params = {
            anchors = ec.anchors,
            height = ec.height,
            hidden = ec.hidden,
            mouseEnabled = ec.mouseEnabled,
            width = ec.width,
        },
        handlers = {},
        children = {
            inner = { element = inner }
        },
    } --[[@as ScrollArea]]
    return result
end
