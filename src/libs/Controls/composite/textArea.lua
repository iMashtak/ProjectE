--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua

---@class TextArea : Element
---@field params TextAreaParams
---@field handlers TextAreaHandlers
---@field children TextAreaChildren

---@class TextAreaParams : ControlParams
---@field text Ref<string>
---@field defaultText Ref<string>
---@field font Ref<string>
---@field color Ref<ColorSetting>
---@field editEnabled Ref<boolean>
---@field copyEnabled Ref<boolean>
---@field newLineEnabled Ref<boolean>
---@field maxLength Ref<integer?>
---@field autoGrow Ref<boolean> # grows control height with text
---@field minHeight Ref<number?> # lower bound of the auto grown height
---@field maxHeight Ref<number?> # upper bound of the auto grown height, text scrolls past it

---@class TextAreaHandlers : ControlHandlers
---@field onTextChanged Handlers<OnTextChangedFun>
---@field onEscape Handlers<OnInputFun>
---@field onFocusGained Handlers<OnInputFun>
---@field onFocusLost Handlers<OnInputFun>

---@class TextAreaChildren

---@class TextAreaParamsArgs : ControlParamsArgs
---@field text Ref<string>?
---@field defaultText Ref<string>?
---@field font Ref<string>?
---@field color Ref<ColorSetting>?
---@field editEnabled Ref<boolean>?
---@field copyEnabled Ref<boolean>?
---@field newLineEnabled Ref<boolean>?
---@field maxLength Ref<integer?>?
---@field autoGrow Ref<boolean>?
---@field minHeight Ref<number?>?
---@field maxHeight Ref<number?>?

---@class TextAreaEventsArgs : ControlEventsArgs
---@field onTextChanged Ref<OnTextChangedFun>|Events<OnTextChangedFun>|nil
---@field onEscape Ref<OnInputFun>|Events<OnInputFun>|nil
---@field onFocusGained Ref<OnInputFun>|Events<OnInputFun>|nil
---@field onFocusLost Ref<OnInputFun>|Events<OnInputFun>|nil

---@class TextAreaSlotsArgs

---@param id string
---@param parent Element
---@param args {
---    params: TextAreaParamsArgs?,
---    events: TextAreaEventsArgs?,
---    slots: TextAreaSlotsArgs?,
---}
---@return TextArea
---@nodiscard
function Controls.textArea(id, parent, args)
    if args.params == nil then
        args.params = {}
    end

    if args.params.mouseEnabled == nil then
        args.params.mouseEnabled = Ref(true)
    end

    local e = WINDOW_MANAGER:CreateControlFromVirtual(id, parent.element, "ZO_DefaultEditMultiLineForBackdrop")
    local result = Controls.setupControl(id, e, args) --[[@as TextArea]]

    if args.params.autoGrow == nil then
        args.params.autoGrow = Ref(false)
    end
    if args.params.minHeight == nil then
        args.params.minHeight = Ref(nil)
    end
    if args.params.maxHeight == nil then
        args.params.maxHeight = Ref(nil)
    end

    --- Measures how tall the text is when laid out with the current font and width.
    ---@return number
    local function MeasureTextHeight()
        local text = e:GetText() or ""
        local width = e:GetWidth()
        if width ~= nil and width > 0 then
            local _, textHeight = ZO_LabelUtils_GetTextDimensions(text, e:GetFont(), width)
            if textHeight ~= nil and textHeight > 0 then
                return textHeight
            end
        end
        -- control is not laid out yet, so wrapping is unknown and only explicit line breaks are counted
        local lines = select(2, text:gsub("\n", "")) + 1
        return lines * e:GetFontHeight()
    end

    --- Fits the control height to its text, keeping it between minHeight and maxHeight.
    local function RefreshHeight()
        if not args.params.autoGrow:get() then
            return
        end

        local height = MeasureTextHeight()
        local minHeight = args.params.minHeight:get()
        local maxHeight = args.params.maxHeight:get()
        if minHeight ~= nil then
            height = math.max(height, minHeight)
        end
        if maxHeight ~= nil then
            height = math.min(height, maxHeight)
        end
        args.params.height:set(height)
    end

    e:SetHandler("OnMouseDown", function(control)
        control:TakeFocus()
    end, id .. "-builtin-focus")

    args.params.autoGrow:use(id .. "-autoGrow", function()
        RefreshHeight()
    end)
    args.params.minHeight:use(id .. "-autoGrow-minHeight", function()
        RefreshHeight()
    end)
    args.params.maxHeight:use(id .. "-autoGrow-maxHeight", function()
        RefreshHeight()
    end)

    -- width changes rewrap the text, measuring on the next frame so the new layout is already applied
    args.params.width:use(id .. "-autoGrow-width", function()
        if args.params.autoGrow:get() then
            zo_callLater(RefreshHeight, 0)
        end
    end)

    e:SetHandler("OnEffectivelyShown", function()
        RefreshHeight()
    end, id .. "-autoGrow-shown")

    if args.params.font == nil then
        args.params.font = Ref(Fonts.game)
    end
    args.params.font:use(id .. "-font", function(_, v)
        e:SetFont(v)
        RefreshHeight()
    end)

    if args.params.color == nil then
        args.params.color = Ref({ r = 1, g = 1, b = 1, a = 1 })
    end
    args.params.color:use(id .. "-color", function(_, v)
        e:SetColor(v.r, v.g, v.b, v.a)
    end)

    if args.params.defaultText == nil then
        args.params.defaultText = Ref("")
    end
    args.params.defaultText:use(id .. "-defaultText", function(_, v)
        e:SetDefaultText(v)
    end)

    if args.params.editEnabled == nil then
        args.params.editEnabled = Ref(false)
    end
    args.params.editEnabled:use(id .. "-editEnabled", function(_, v)
        e:SetEditEnabled(v)
    end)

    if args.params.copyEnabled == nil then
        args.params.copyEnabled = Ref(true)
    end
    args.params.copyEnabled:use(id .. "-copyEnabled", function(_, v)
        e:SetCopyEnabled(v)
    end)

    if args.params.newLineEnabled == nil then
        args.params.newLineEnabled = Ref(true)
    end
    args.params.newLineEnabled:use(id .. "-newLineEnabled", function(_, v)
        e:SetNewLineEnabled(v)
    end)

    if args.params.maxLength == nil then
        args.params.maxLength = Ref(nil)
        args.params.maxLength:use(id .. "-maxLength", function(_, v)
            if v ~= nil then
                e:SetMaxInputChars(v)
            end
        end, true)
    else
        args.params.maxLength:use(id .. "-maxLength", function(_, v)
            e:SetMaxInputChars(v)
        end)
    end

    if args.params.text == nil then
        args.params.text = Ref("")
    end
    args.params.text:use(id .. "-text", function(_, v)
        e:SetText(v)
        RefreshHeight()
    end)

    local hook = function(event)
        return function(f, name, order, target)
            e:SetHandler(event, f, name, order, target)
        end
    end

    result.handlers.onTextChanged = MakeHandlers(args.events.onTextChanged, hook("OnTextChanged"))
    result.handlers.onEscape = MakeHandlers(args.events.onEscape, hook("OnEscape"))
    result.handlers.onFocusGained = MakeHandlers(args.events.onFocusGained, hook("OnFocusGained"))
    result.handlers.onFocusLost = MakeHandlers(args.events.onFocusLost, hook("OnFocusLost"))

    local syncing = false
    e:SetHandler("OnTextChanged", function(self)
        if syncing then
            return
        end
        local v = self:GetText()
        if v ~= args.params.text:get() then
            syncing = true
            args.params.text:set(v)
            syncing = false
        end
    end, id .. "-sync")

    e:SetHandler("OnEscape", function(self)
        self:LoseFocus()
    end, id .. "-builtin-escape")

    return result
end

---@param controlArgs {
---    params: TextAreaParamsArgs?,
---    events: TextAreaEventsArgs?,
---    slots: TextAreaSlotsArgs?,
---}
---@param text string?
---@return function
---@nodiscard
function Controls.Dsl.textArea(controlArgs, text)
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
        local result = Controls.textArea(id, parent, controlArgs)
        return result
    end
end
