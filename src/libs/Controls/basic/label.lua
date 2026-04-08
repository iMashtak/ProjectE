--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@class Label : Element
---@field params LabelParams
---@field handlers LabelHandlers
---@field children LabelChildren

---@class LabelParams : ControlParams
---@field font Ref<string>
---@field text Ref<string>

---@class LabelHandlers : ControlHandlers

---@class LabelChildren

---@class LabelParamsArgs : ControlParamsArgs
---@field font Ref<string>?
---@field text Ref<string>?

---@class LabelEventsArgs : ControlEventsArgs

---@class LabelSlotsArgs

---@param id string
---@param parent Element
---@param args {
---    params: LabelParamsArgs?,
---    events: LabelEventsArgs?,
---    slots: LabelSlotsArgs?,
---}
---@return Label
---@nodiscard
function Controls.label(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_LABEL)
    local result = Controls.setupControl(id, e, args) --[[@as Label]]

    if args.params.font == nil then
        args.params.font = Ref(Fonts.game)
    end
    args.params.font:use(id .. "-font", function(_, v)
        e:SetFont(v)
    end)
    result.params.font = args.params.font

    if args.params.text == nil then
        args.params.text = Ref("")
    end
    args.params.text:use(id .. "-text", function(_, v)
        e:SetText(v)
    end)
    result.params.text = args.params.text

    return result
end

---@param controlArgs {
---    params: LabelParamsArgs?,
---    events: LabelEventsArgs?,
---    slots: LabelSlotsArgs?,
---}
---@param text string?
---@param font string?
---@return function
function Controls.Dsl.label(controlArgs, text, font)
    return function(id, parent)
        if controlArgs.params == nil then
            controlArgs.params = {}
        end
        if controlArgs.params.hidden == nil then
            controlArgs.params.hidden = Ref(false)
        end
        if controlArgs.params.anchors == nil then
            controlArgs.params.anchors = Ref({
                { point = TOPLEFT,     target = parent.element, relativePoint = TOPLEFT,     offsetX = 0, offsetY = 0 },
                { point = BOTTOMRIGHT, target = parent.element, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
            })
        end
        if text ~= nil then
            if controlArgs.params.text == nil then
                controlArgs.params.text = Ref(text)
            else
                controlArgs.params.text:set(text)
            end
        end
        if font ~= nil then
            if controlArgs.params.font == nil then
                controlArgs.params.font = Ref(font)
            else
                controlArgs.params.font:set(font)
            end
        end
        local result = Controls.label(id, parent, controlArgs)
        return result
    end
end
