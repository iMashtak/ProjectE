--* use ./main.lua
--* use ./ref.lua

---@class Layout : Element
---@field hidden Ref<boolean>
---@field dimensions Ref<{x: integer, y: integer}>

---@param id string
---@param args {hidden: Ref<boolean>?, dimensions: Ref<{x: integer, y: integer}>?}
---@return Layout
---@nodiscard
function Controls.layout(id, args)
    local window = WINDOW_MANAGER:CreateTopLevelWindow(id)

    if args.hidden == nil then
        args.hidden = NewRef(true)
    end
    args.hidden:use(id .. "-hidden", function(_, new)
        window:SetHidden(new)
    end)

    if args.dimensions == nil then
        args.dimensions = NewRef({ x = 0, y = 0 })
    end
    args.dimensions:use(id .. "-dimensions", function(_, new)
        window:SetDimensions(new.x, new.y)
    end)

    return {
        element = window,
        hidden = args.hidden,
        dimensions = args.dimensions,
    }
end
