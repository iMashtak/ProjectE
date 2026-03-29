--* use ./main.lua
--* use ./ref.lua

---@class Icon : Element
---@field handlers {onMouseDown: Ref<OnMouseDownFun|nil>?}
---@field hidden Ref<boolean>
---@field height Ref<integer>
---@field width Ref<integer>
---@field anchors Ref<AnchorSetting[]>
---@field texture Ref<string>
---@field mouseEnabled Ref<boolean>

---@param id string
---@param parent Element
---@param args {hidden: Ref<boolean>?, height: Ref<integer>?, width: Ref<integer>?, anchors: Ref<AnchorSetting[]>?, texture: Ref<string>?, mouseEnabled: Ref<boolean>?}
---@return Icon
---@nodiscard
function Controls.icon(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_TEXTURE)

    if args.hidden == nil then
        args.hidden = Ref(true)
    end
    args.hidden:use(id .. "-hidden", function(_, v)
        e:SetHidden(v)
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

    if args.anchors == nil then
        args.anchors = Ref({})
    end
    args.anchors:use(id .. "-anchors", function(_, v)
        e:ClearAnchors()
        for _, anchor in ipairs(v) do
            e:SetAnchor(anchor.point, anchor.target, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
        end
    end)

    if args.texture == nil then
        args.texture = Ref(Textures.icons.missing)
    end
    args.texture:use(id .. "-texture", function(_, v)
        e:SetTexture(v)
    end)

    if args.mouseEnabled == nil then
        args.mouseEnabled = Ref(false)
    end
    args.mouseEnabled:use(id .. "-mouseEnabled", function(_, v)
        e:SetMouseEnabled(v)
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
        height = args.height,
        width = args.width,
        anchors = args.anchors,
        texture = args.texture,
        mouseEnabled = args.mouseEnabled,
    }
end
