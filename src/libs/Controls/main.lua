Controls = {}

---@class Element
---@field element any

---@type {[string]: Element}
ControlsRegistry = {}

---@alias AnchorSetting {point: any, target: any, relativePoint: any, offsetX: integer, offsetY: integer}
---@alias ColorSetting {r: number, g: number, b: number, a: number}

---@alias OnMouseDownFun fun(self, button, ctrl, alt, shift, command)
---@alias OnMouseUpFun fun(self, button, upInside, ctrl, alt, shift, command)

Fonts = {
    game = "ZoFontGame",
}

Textures = {
    icons = {
        missing = "/esoui/art/icons/icon_missing.dds",
        checkbox = {
            checked = "/esoui/art/cadwell/checkboxicon_checked.dds",
            unchecked = "/esoui/art/cadwell/checkboxicon_unchecked.dds",
        }
    },
    bg = {
        chatCenter = "/esoui/art/chatwindow/chat_bg_center.dds",
        chatEdge = "/esoui/art/chatwindow/chat_bg_edge.dds"
    },
    effects = {
        crux = "/art/fx/texture/arcanist_trianglerune_01.dds"
    },
    plus = {
        pointplus = "/esoui/art/tutorial/pointsplus_up.dds",
        zoomplus = "/esoui/art/tutorial/minimap_zoomplus_up.dds"
    },
    minus = {
        pointminus = "/esoui/art/tutorial/pointsminus_up.dds",
        zoomminus = "/esoui/art/tutorial/minimap_zoomminus_up.dds"
    }
}

---@type {[string]: ColorSetting}
Colors = {
    ["black"] = { r = 0, g = 0, b = 0, a = 1 },
    ["crux"] = { r = 0.6445, g = 1, b = 0.4219, a = 1 },
}
