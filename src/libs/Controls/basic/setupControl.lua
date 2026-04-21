--* use ../main.lua
--* use ../ref.lua

---@class Control : Element
---@field params ControlParams
---@field handlers ControlHandlers
---@field children table

---@class ControlParams
---@field anchors Ref<AnchorSetting[]>
---@field height Ref<integer?>
---@field hidden Ref<boolean>
---@field mouseEnabled Ref<boolean>
---@field width Ref<integer?>

---@class ControlHandlers
---@field onMouseDown Handlers<OnMouseDownFun>
---@field onMouseUp Handlers<OnMouseUpFun>

---@class ControlParamsArgs
---@field anchors Ref<AnchorSetting[]>?
---@field height Ref<integer?>?
---@field hidden Ref<boolean>?
---@field mouseEnabled Ref<boolean>?
---@field width Ref<integer?>?

---@class ControlEventsArgs
---@field onMouseDown Ref<OnMouseDownFun>|Events<OnMouseDownFun>|nil
---@field onMouseUp Ref<OnMouseUpFun>|Events<OnMouseUpFun>|nil

---@param id string
---@param e any
---@param args {
---    params: ControlParamsArgs?,
---    events: ControlEventsArgs?,
---    slots: table?,
---}
---@return Control
function Controls.setupControl(id, e, args)
    if args.params == nil then
        args.params = {}
    end
    if args.events == nil then
        args.events = {}
    end
    if args.slots == nil then
        args.slots = {}
    end

    if args.params.anchors == nil then
        args.params.anchors = Ref({})
    end
    args.params.anchors:use(id .. "-anchors", function(_, v)
        e:ClearAnchors()
        for _, anchor in ipairs(v) do
            e:SetAnchor(anchor.point, anchor.target, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
        end
    end)

    if args.params.height == nil then
        args.params.height = Ref(nil)
        args.params.height:use(id .. "-height", function(_, v)
            e:SetHeight(v)
        end, true)
    else
        args.params.height:use(id .. "-height", function(_, v)
            e:SetHeight(v)
        end)
    end

    if args.params.hidden == nil then
        args.params.hidden = Ref(true)
    end
    args.params.hidden:use(id .. "-hidden", function(_, v)
        e:SetHidden(v)
    end)

    if args.params.mouseEnabled == nil then
        args.params.mouseEnabled = Ref(false)
    end
    args.params.mouseEnabled:use(id .. "-mouseEnabled", function(_, v)
        e:SetMouseEnabled(v)
    end)

    if args.params.width == nil then
        args.params.width = Ref(nil)
        args.params.width:use(id .. "-width", function(_, v)
            e:SetWidth(v)
        end, true)
    else
        args.params.width:use(id .. "-width", function(_, v)
            e:SetWidth(v)
        end)
    end

    local result = {
        element = e,
        params = args.params,
        handlers = {},
        children = {},
    }
    ControlsRegistry[id] = result

    local hook = function(event)
        return function(f, name, order, target)
            e:SetHandler(event, f, name, order, target)
        end
    end

    result.handlers.onMouseDown = MakeHandlers(args.events.onMouseDown, hook("OnMouseDown"))
    result.handlers.onMouseUp = MakeHandlers(args.events.onMouseUp, hook("OnMouseUp"))

    return result
end
