--* use ./main.lua
--* use ./ref.lua

---@class Card
---@field hidden Ref<boolean>
---@field centerTexture Ref<string>
---@field centerColor Ref<ColorSetting>
---@field edgeSettings Ref<{file: string, width: number, height: number, size: number, padding: number}>
---@field edgeColor Ref<ColorSetting>
---@field anchors Ref<AnchorSetting[]>

---@param id string
---@param parent Element
---@param args {
---    hidden: Ref<boolean>?,
---    centerTexture: Ref<string>?,
---    centerColor: Ref<ColorSetting>,
---    edgeSettings: Ref<{file: string, width: number, height: number, size: number, padding: number}>?,
---    edgeColor: Ref<ColorSetting>?,
---    anchors: Ref<AnchorSetting[]>?,}
---@return Card
function Controls.card(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_BACKDROP)

    if args.hidden == nil then
        args.hidden = Ref(true)
    end
    args.hidden:use(id .. "-hidden", function(_, v)
        e:SetHidden(v)
    end)

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

    if args.anchors == nil then
        args.anchors = Ref({})
    end
    args.anchors:use(id .. "-anchors", function(_, v)
        e:ClearAnchors()
        for _, anchor in ipairs(v) do
            e:SetAnchor(anchor.point, anchor.target, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
        end
    end)

    return {
        element = e,
        hidden = args.hidden,
        centerTexture = args.centerTexture,
        centerColor = args.centerColor,
        edgeSettings = args.edgeSettings,
        edgeColor = args.edgeColor,
        anchors = args.anchors,
    }
end
