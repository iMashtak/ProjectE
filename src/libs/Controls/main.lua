Controls = {}

---@class Element
---@field element any

---@type {[string]: Element}
ControlsRegistry = {}

---@alias AnchorSetting {point: any, target: any, relativePoint: any, offsetX: integer, offsetY: integer}
---@alias ColorSetting {r: number, g: number, b: number, a: number}

---@alias OnMouseDownFun fun(self, button, ctrl, alt, shift, command)

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
    }
}

---@type {[string]: ColorSetting}
Colors = {
    ["black"] = { r = 1, g = 1, b = 1, a = 0 }
}
