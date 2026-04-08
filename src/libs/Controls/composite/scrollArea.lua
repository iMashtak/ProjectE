--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua

---@class ScrollAreaParams : ControlParams

---@class ScrollAreaHandlers : ControlHandlers

---@class ScrollAreaChildren
---@field inner Element

---@class ScrollArea : Element
---@field params ScrollAreaParams
---@field handlers ScrollAreaHandlers
---@field children ScrollAreaChildren

---@class ScrollAreaParamsArgs : ControlParamsArgs

---@class ScrollAreaEventsArgs : ControlEventsArgs

---@class ScrollAreaSlotsArgs
---@field content fun(parent: Element)?

---@param id string
---@param parent Element
---@param args {
---    params: ScrollAreaParamsArgs?,
---    events: ScrollAreaEventsArgs?,
---    slots: ScrollAreaSlotsArgs?,
---}
---@return ScrollArea
function Controls.scrollArea(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as ScrollArea]]

    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual(id .. "-scrollContainer", e, "ZO_ScrollContainer")
    scrollContainer:ClearAnchors()
    scrollContainer:SetAnchor(TOPLEFT, e, TOPLEFT, 0, 0)
    scrollContainer:SetAnchor(BOTTOMRIGHT, e, BOTTOMRIGHT, 0, 0)
    local inner = GetControl(scrollContainer, "ScrollChild")
    inner:SetResizeToFitPadding(0, 0)

    if args.slots.content ~= nil then
        args.slots.content(inner)
    end

    result.children.inner = { element = inner }

    return result
end
