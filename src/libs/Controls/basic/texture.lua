--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@class Texture : Control
---@field handlers {
---    onMouseDown: Ref<OnMouseDownFun|nil>?,
---}
---@field texture Ref<string>

---@param id string
---@param parent Element
---@param args {
---    anchors: Ref<AnchorSetting[]>?,
---    hidden: Ref<boolean>?,
---    height: Ref<integer?>?,
---    mouseEnabled: Ref<boolean>?,
---    width: Ref<integer?>?,
---    texture: Ref<string>?,
---}
---@return Texture
---@nodiscard
function Controls.texture(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_TEXTURE)
    local result = Controls.setupControl(id, e, args) --[[@as Texture]]

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
        onMouseDown = Ref(nil)
    }
    handlers.onMouseDown:use(id .. "-handlers-onMouseDown", function(_, v)
        e:SetHandler("OnMouseDown", v)
    end)
    result.handlers = handlers

    return result
end
