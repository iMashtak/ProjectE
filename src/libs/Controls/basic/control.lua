--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@param id string
---@param parent Element
---@param args {
---    params: ControlParamsArgs?,
---    events: ControlEventsArgs?,
---    slots: table?,
---}
---@return Control
---@nodiscard
function Controls.control(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    return Controls.setupControl(id, e, args) --[[@as Control]]
end
