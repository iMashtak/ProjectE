--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@class Layout : Control

---@param id string
---@param args {
---    anchors: Ref<AnchorSetting[]>?,
---    hidden: Ref<boolean>?,
---    height: Ref<integer?>?,
---    mouseEnabled: Ref<boolean>?,
---    width: Ref<integer?>?,
---}
---@return Layout
---@nodiscard
function Controls.layout(id, args)
    local e = WINDOW_MANAGER:CreateTopLevelWindow(id)
    local result = Controls.setupControl(id, e, args) --[[@as Layout]]
    ControlsRegistry[id] = result
    return result
end
