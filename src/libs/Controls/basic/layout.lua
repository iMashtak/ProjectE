--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@class Layout : Element
---@field params LayoutParams
---@field handlers LayoutHandlers
---@field children LayoutChildren

---@class LayoutParams : ControlParams

---@class LayoutHandlers : ControlHandlers

---@class LayoutChildren

---@class LayoutParamsArgs : ControlParamsArgs

---@class LayoutEventsArgs : ControlEventsArgs

---@class LayoutSlotsArgs

---@param id string
---@param args {
---    params: LayoutParamsArgs?,
---    events: LayoutEventsArgs?,
---    slots: LayoutSlotsArgs?,
---}
---@return Layout
---@nodiscard
function Controls.layout(id, args)
    local e = WINDOW_MANAGER:CreateTopLevelWindow(id)
    local result = Controls.setupControl(id, e, args) --[[@as Layout]]
    return result
end
