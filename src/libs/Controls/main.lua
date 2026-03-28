Controls = {}

---@class Element
---@field element any

---@alias AnchorSetting {point: any, target: any, relativePoint: any, offsetX: integer, offsetY: integer}

---@alias OnMouseDownFun fun(self, button, ctrl, alt, shift, command)

Fonts = {
    game = "ZoFontGame",
}

---@param target Element
---@param style string
---@return AnchorSetting[]
function AnchorStyle(target, style)
    if style == "fill" then
        return {
            { point = TOPLEFT,     target = target.element, relativePoint = TOPLEFT,     offsetX = 0, offsetY = 0 },
            { point = BOTTOMRIGHT, target = target.element, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
        }
    end
    return {}
end
