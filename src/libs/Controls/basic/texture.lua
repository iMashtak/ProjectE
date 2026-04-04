--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@class Texture : Control
---@field handlers {
---    onMouseDown: Ref<OnMouseDownFun?>?,
---    onMouseUp: Ref<OnMouseUpFun?>?,
---}
---@field color Ref<ColorSetting>
---@field texture Ref<string>

---@param id string
---@param parent Element
---@param args {
---    anchors: Ref<AnchorSetting[]>?,
---    hidden: Ref<boolean>?,
---    height: Ref<integer?>?,
---    mouseEnabled: Ref<boolean>?,
---    width: Ref<integer?>?,
---    color: Ref<ColorSetting>?,
---    texture: Ref<string>?,
---}
---@return Texture
---@nodiscard
function Controls.texture(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_TEXTURE)
    local result = Controls.setupControl(id, e, args) --[[@as Texture]]

    if args.color == nil then
        args.color = Ref(nil)
        args.color:use(id .. "-color", function(_, v)
            e:SetColor(v.r, v.g, v.b, v.a)
        end, true)
    else
        args.color:use(id .. "-color", function(_, v)
            e:SetColor(v.r, v.g, v.b, v.a)
        end)
    end
    result.color = args.color

    if args.texture == nil then
        args.texture = Ref(nil)
        args.texture:use(id .. "-texture", function(_, v)
            e:SetTexture(v)
        end, true)
    else
        args.texture:use(id .. "-texture", function(_, v)
            e:SetTexture(v)
        end)
    end
    result.texture = args.texture

    local handlers = {
        onMouseDown = Ref(nil),
        onMouseUp = Ref(nil)
    }
    handlers.onMouseDown:use(id .. "-handlers-onMouseDown", function(_, v)
        e:SetHandler("OnMouseDown", v)
    end)
    handlers.onMouseUp:use(id .. "-handlers-onMouseUp", function(_, v)
        e:SetHandler("OnMouseUp", v)
    end)
    result.handlers = handlers

    return result
end
