--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@class Label : Control
---@field handlers {
---    onMouseDown: Ref<OnMouseDownFun|nil>?,
---}
---@field text Ref<string>
---@field font Ref<string>

---@param id string
---@param parent Element
---@param args {
---    anchors: Ref<AnchorSetting[]>?,
---    hidden: Ref<boolean>?,
---    height: Ref<integer?>?,
---    mouseEnabled: Ref<boolean>?,
---    width: Ref<integer?>?,
---    text: Ref<string>?,
---    font: Ref<string>?,
---}
---@return Label
---@nodiscard
function Controls.label(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_LABEL)
    local result = Controls.setupControl(id, e, args) --[[@as Label]]

    if args.text == nil then
        args.text = Ref("")
    end
    args.text:use(id .. "-text", function(_, v)
        e:SetText(v)
    end)
    result.text = args.text

    if args.font == nil then
        args.font = Ref(Fonts.game)
    end
    args.font:use(id .. "-font", function(_, v)
        e:SetFont(v)
    end)
    result.font = args.font

    local handlers = {
        onMouseDown = Ref(nil)
    }
    handlers.onMouseDown:use(id .. "-handlers-onMouseDown", function(_, v)
        e:SetHandler("OnMouseDown", v)
    end)
    result.handlers = handlers

    return result
end
