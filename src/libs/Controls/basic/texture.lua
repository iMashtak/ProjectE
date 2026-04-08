--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@class Texture : Element
---@field params TextureParams
---@field handlers TextureHandlers
---@field children TextureChildren

---@class TextureParams : ControlParams
---@field color Ref<ColorSetting>
---@field texture Ref<string>

---@class TextureHandlers : ControlHandlers

---@class TextureChildren

---@class TextureParamsArgs : ControlParamsArgs
---@field color Ref<ColorSetting>?
---@field texture Ref<string>?

---@class TextureEventsArgs : ControlEventsArgs

---@class TextureSlotsArgs

---@param id string
---@param parent Element
---@param args {
---    params: TextureParamsArgs?,
---    events: TextureEventsArgs?,
---    slots: TextureSlotsArgs?,
---}
---@return Texture
---@nodiscard
function Controls.texture(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_TEXTURE)
    local result = Controls.setupControl(id, e, args) --[[@as Texture]]

    if args.params.color == nil then
        args.params.color = Ref(nil)
        args.params.color:use(id .. "-color", function(_, v)
            e:SetColor(v.r, v.g, v.b, v.a)
        end, true)
    else
        args.params.color:use(id .. "-color", function(_, v)
            e:SetColor(v.r, v.g, v.b, v.a)
        end)
    end

    if args.params.texture == nil then
        args.params.texture = Ref(nil)
        args.params.texture:use(id .. "-texture", function(_, v)
            e:SetTexture(v)
        end, true)
    else
        args.params.texture:use(id .. "-texture", function(_, v)
            e:SetTexture(v)
        end)
    end

    return result
end
