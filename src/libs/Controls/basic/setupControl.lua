--* use ../main.lua
--* use ../ref.lua

---@class Control : Element
---@field anchors Ref<AnchorSetting[]>
---@field hidden Ref<boolean>
---@field height Ref<integer?>
---@field mouseEnabled Ref<boolean>
---@field width Ref<integer?>

---@param id string
---@param e any
---@param args {
---    anchors: Ref<AnchorSetting[]>?,
---    hidden: Ref<boolean>?,
---    height: Ref<integer?>?,
---    mouseEnabled: Ref<boolean>?,
---    width: Ref<integer?>?,
---}
---@return Control
function Controls.setupControl(id, e, args)
    if args.anchors == nil then
        args.anchors = Ref({})
    end
    args.anchors:use(id .. "-anchors", function(_, v)
        e:ClearAnchors()
        for _, anchor in ipairs(v) do
            e:SetAnchor(anchor.point, anchor.target, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
        end
    end)

    if args.hidden == nil then
        args.hidden = Ref(true)
    end
    args.hidden:use(id .. "-hidden", function(_, v)
        e:SetHidden(v)
    end)

    if args.height == nil then
        args.height = Ref(nil)
        args.height:use(id .. "-height", function(_, v)
            e:SetHeight(v)
        end, true)
    else
        args.height:use(id .. "-height", function(_, v)
            e:SetHeight(v)
        end)
    end

    if args.mouseEnabled == nil then
        args.mouseEnabled = Ref(false)
    end
    args.mouseEnabled:use(id .. "-mouseEnabled", function(_, v)
        e:SetMouseEnabled(v)
    end)

    if args.width == nil then
        args.width = Ref(nil)
        args.width:use(id .. "-width", function(_, v)
            e:SetWidth(v)
        end, true)
    else
        args.width:use(id .. "-width", function(_, v)
            e:SetWidth(v)
        end)
    end

    return {
        element = e,
        anchors = args.anchors,
        hidden = args.hidden,
        height = args.height,
        width = args.width,
    }
end
