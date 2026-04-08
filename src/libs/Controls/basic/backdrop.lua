--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@class Backdrop : Element
---@field params BackdropParams
---@field handlers BackdropHandlers
---@field children BackdropChildren

---@class BackdropParams : ControlParams
---@field centerColor Ref<ColorSetting>
---@field centerTexture Ref<string>
---@field edgeColor Ref<ColorSetting>
---@field edgeSettings Ref<{file: string, width: number, height: number, size: number, padding: number}>

---@class BackdropHandlers : ControlHandlers

---@class BackdropChildren

---@class BackdropParamsArgs : ControlParamsArgs
---@field centerColor Ref<ColorSetting>?
---@field centerTexture Ref<string>?
---@field edgeColor Ref<ColorSetting>?
---@field edgeSettings Ref<{file: string, width: number, height: number, size: number, padding: number}>?

---@class BackdropEventsArgs : ControlEventsArgs

---@class BackdropSlotsArgs

---@param id string
---@param parent Element
---@param args {
---    params: BackdropParamsArgs,
---    events: BackdropEventsArgs,
---    slots: BackdropSlotsArgs,
---}
---@return Backdrop
function Controls.backdrop(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_BACKDROP)
    local result = Controls.setupControl(id, e, args) --[[@as Backdrop]]

    if args.params.centerTexture == nil then
        args.params.centerTexture = Ref(Textures.bg.chatCenter)
    end
    args.params.centerTexture:use(id .. "-centerTexture", function(_, v)
        e:SetCenterTexture(v)
    end)

    if args.params.centerColor == nil then
        args.params.centerColor = Ref(Colors["black"])
    end
    args.params.centerColor:use(id .. "-centerColor", function(_, v)
        e:SetCenterColor(v.r, v.g, v.b, v.a)
    end)

    if args.params.edgeSettings == nil then
        args.params.edgeSettings = Ref({ file = Textures.bg.chatEdge, width = 8, height = 8, size = 8, padding = 0 })
    end
    args.params.edgeSettings:use(id .. "-edgeSettings", function(_, v)
        e:SetEdgeTexture(v.file, v.width, v.height, v.size, v.padding)
    end)

    if args.params.edgeColor == nil then
        args.params.edgeColor = Ref(Colors["black"])
    end
    args.params.edgeColor:use(id .. "-edgeColor", function(_, v)
        e:SetEdgeColor(v.r, v.g, v.b, v.a)
    end)

    return result
end
