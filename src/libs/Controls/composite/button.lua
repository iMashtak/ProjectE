--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua
--* use ../basic/label.lua

---@class Button : Element
---@field params ButtonParams
---@field handlers ButtonHandlers
---@field children ButtonChildren

---@class ButtonParams : ControlParams
---@field label Ref<string>

---@class ButtonHandlers : ControlHandlers
---@field onClick Handlers<fun()>

---@class ButtonChildren

---@class ButtonParamsArgs : ControlParamsArgs
---@field label Ref<string>?

---@class ButtonEventsArgs : ControlEventsArgs
---@field onClick Ref<fun()>

---@class ButtonSlotsArgs

---@param id string
---@param parent Element
---@param args {
---    params: ButtonParamsArgs?,
---    events: ButtonEventsArgs?,
---    slots: ButtonSlotsArgs?,
---}
---@return Button
---@nodiscard
function Controls.button(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as Button]]

    local _ = Controls.label(id .. "-button-label", result, {
        params = {
            text = args.params.label
        }
    })

    result.params.mouseEnabled:set(true)
    result.handlers.onMouseUp:add(
        id .. "-onClick",
        Ref(function(self, button, upInside, ctrl, alt, shift, command)
            args.events.onClick:get()()
        end)
    )

    return result
end
