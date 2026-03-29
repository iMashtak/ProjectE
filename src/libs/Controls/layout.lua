--* use ./main.lua
--* use ./ref.lua

---@class Layout : Element
---@field hidden Ref<boolean>
---@field height Ref<integer>
---@field width Ref<integer>
---@field anchors Ref<AnchorSetting[]>

---@param id string
---@param args {hidden: Ref<boolean>?, height: Ref<integer>?, width: Ref<integer>?, anchors: Ref<AnchorSetting[]>?}
---@return Layout
---@nodiscard
function Controls.layout(id, args)
    local e = WINDOW_MANAGER:CreateTopLevelWindow(id)

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
    args.anchors:use(id .. "-anchors", function (_, v)
        e:ClearAnchors()
        for _, anchor in ipairs(v) do
            e:SetAnchor(anchor.point, anchor.target, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
        end
    end)

    local result = {
        element = e,
        hidden = args.hidden,
        height = args.height,
        width = args.width,
    }
    ControlsRegistry[id] = result
    return result
end
