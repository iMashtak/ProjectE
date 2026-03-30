--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@class Backdrop : Control
---@field centerColor Ref<ColorSetting>
---@field centerTexture Ref<string>
---@field edgeColor Ref<ColorSetting>
---@field edgeSettings Ref<{file: string, width: number, height: number, size: number, padding: number}>

---@param id string
---@param parent Element
---@param args {
---    anchors: Ref<AnchorSetting[]>?,
---    hidden: Ref<boolean>?,
---    height: Ref<integer?>?,
---    mouseEnabled: Ref<boolean>?,
---    width: Ref<integer?>?,
---    centerColor: Ref<ColorSetting>,
---    centerTexture: Ref<string>?,
---    edgeColor: Ref<ColorSetting>?,
---    edgeSettings: Ref<{file: string, width: number, height: number, size: number, padding: number}>?,
---}
---@return Backdrop
function Controls.backdrop(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_BACKDROP)
    local result = Controls.setupControl(id, e, args) --[[@as Backdrop]]

    if args.centerTexture == nil then
        args.centerTexture = Ref(Textures.bg.chatCenter)
    end
    args.centerTexture:use(id .. "-centerTexture", function(_, v)
        e:SetCenterTexture(v)
    end)

    if args.centerColor == nil then
        args.centerColor = Ref(Colors["black"])
    end
    args.centerColor:use(id .. "-centerColor", function(_, v)
        e:SetCenterColor(v.r, v.g, v.b, v.a)
    end)

    if args.edgeSettings == nil then
        args.edgeSettings = Ref({ file = Textures.bg.chatEdge, width = 8, height = 8, size = 8, padding = 0 })
    end
    args.edgeSettings:use(id .. "-edgeSettings", function(_, v)
        e:SetEdgeTexture(v.file, v.width, v.height, v.size, v.padding)
    end)

    if args.edgeColor == nil then
        args.edgeColor = Ref(Colors["black"])
    end
    args.edgeColor:use(id .. "-edgeColor", function(_, v)
        e:SetEdgeColor(v.r, v.g, v.b, v.a)
    end)

    return result
end
