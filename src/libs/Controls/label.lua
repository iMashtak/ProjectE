--* use ./main.lua
--* use ./ref.lua

---@class Label : Element
---@field handlers {onMouseDown: Ref<OnMouseDownFun|nil>?}
---@field hidden Ref<boolean>
---@field text Ref<string>
---@field height Ref<integer>
---@field width Ref<integer>
---@field mouseEnabled Ref<boolean>
---@field anchors Ref<AnchorSetting[]>
---@field font Ref<string>

---@param id string
---@param parent Element
---@param args {
---    hidden: Ref<boolean>?,
---    text: Ref<string>?,
---    height: Ref<integer>?,
---    width: Ref<integer>?,
---    mouseEnabled: Ref<boolean>?,
---    anchors: Ref<AnchorSetting[]>?,
---    font: Ref<string>?}
---@return Label
---@nodiscard
function Controls.label(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_LABEL)

    if args.hidden == nil then
        args.hidden = Ref(true)
    end
    args.hidden:use(id .. "-hidden", function(_, v)
        e:SetHidden(v)
    end)

    if args.text == nil then
        args.text = Ref("")
    end
    args.text:use(id .. "-text", function(_, v)
        e:SetText(v)
    end)

    if args.height == nil then
        args.height = Ref(0)
    end
    args.height:use(id .. "-height", function(_, v)
        e:SetHeight(v)
    end)

    if args.width == nil then
        args.width = Ref(0)
    end
    args.width:use(id .. "-width", function(_, v)
        e:SetWidth(v)
    end)

    if args.mouseEnabled == nil then
        args.mouseEnabled = Ref(false)
    end
    args.mouseEnabled:use(id .. "-mouseEnabled", function(_, v)
        e:SetMouseEnabled(v)
    end)

    if args.anchors == nil then
        args.anchors = Ref({})
    end
    args.anchors:use(id .. "-anchors", function(_, v)
        e:ClearAnchors()
        for _, anchor in ipairs(v) do
            e:SetAnchor(anchor.point, anchor.target, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
        end
    end)

    if args.font == nil then
        args.font = Ref(Fonts.game)
    end
    args.font:use(id .. "-font", function(_, v)
        e:SetFont(v)
    end)

    local handlers = {
        onMouseDown = Ref(nil)
    }
    handlers.onMouseDown:use(id .. "-handler-onMouseDown", function(_, v)
        e:SetHandler("OnMouseDown", v)
    end)

    return {
        element = e,
        handlers = handlers,
        hidden = args.hidden,
        text = args.text,
        height = args.height,
        width = args.width,
        anchors = args.anchors,
        font = args.font,
    }
end
