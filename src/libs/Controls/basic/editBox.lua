--* use ../main.lua
--* use ../ref.lua
--* use ./setupControl.lua

---@class EditBox : Element
---@field params EditBoxParams
---@field handlers EditBoxHandlers
---@field children EditBoxChildren

---@class EditBoxParams : ControlParams
---@field text Ref<string>
---@field defaultText Ref<string>
---@field font Ref<string>
---@field color Ref<ColorSetting>
---@field multiLine Ref<boolean>
---@field maxLength Ref<integer?>
---@field loseFocusOnEnter Ref<boolean>

---@alias OnTextChangedFun fun(self)
---@alias OnInputFun fun(self)

---@class EditBoxHandlers : ControlHandlers
---@field onTextChanged Handlers<OnTextChangedFun>
---@field onEnter Handlers<OnInputFun>
---@field onEscape Handlers<OnInputFun>
---@field onFocusGained Handlers<OnInputFun>
---@field onFocusLost Handlers<OnInputFun>

---@class EditBoxChildren

---@class EditBoxParamsArgs : ControlParamsArgs
---@field text Ref<string>?
---@field defaultText Ref<string>?
---@field font Ref<string>?
---@field color Ref<ColorSetting>?
---@field multiLine Ref<boolean>?
---@field maxLength Ref<integer?>?
---@field loseFocusOnEnter Ref<boolean>?

---@class EditBoxEventsArgs : ControlEventsArgs
---@field onTextChanged Ref<OnTextChangedFun>|Events<OnTextChangedFun>|nil
---@field onEnter Ref<OnInputFun>|Events<OnInputFun>|nil
---@field onEscape Ref<OnInputFun>|Events<OnInputFun>|nil
---@field onFocusGained Ref<OnInputFun>|Events<OnInputFun>|nil
---@field onFocusLost Ref<OnInputFun>|Events<OnInputFun>|nil

---@class EditBoxSlotsArgs

---@param id string
---@param parent Element
---@param args {
---    params: EditBoxParamsArgs?,
---    events: EditBoxEventsArgs?,
---    slots: EditBoxSlotsArgs?,
---}
---@return EditBox
---@nodiscard
function Controls.editBox(id, parent, args)
    if args.params == nil then
        args.params = {}
    end

    if args.params.mouseEnabled == nil then
        args.params.mouseEnabled = Ref(true)
    end

    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_EDITBOX)
    local result = Controls.setupControl(id, e, args) --[[@as EditBox]]

    if args.params.font == nil then
        args.params.font = Ref(Fonts.game)
    end
    args.params.font:use(id .. "-font", function(_, v)
        e:SetFont(v)
    end)

    if args.params.color == nil then
        args.params.color = Ref({ r = 1, g = 1, b = 1, a = 1 })
    end
    args.params.color:use(id .. "-color", function(_, v)
        e:SetColor(v.r, v.g, v.b, v.a)
    end)

    if args.params.text == nil then
        args.params.text = Ref("")
    end
    args.params.text:use(id .. "-text", function(_, v)
        e:SetText(v)
    end)

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

    if args.params.defaultText == nil then
        args.params.defaultText = Ref("")
    end
    args.params.defaultText:use(id .. "-defaultText", function(_, v)
        e:SetDefaultText(v)
    end)

    if args.params.multiLine == nil then
        args.params.multiLine = Ref(false)
    end
    args.params.multiLine:use(id .. "-multiLine", function(_, v)
        e:SetMultiLine(v)
    end)

    if args.params.loseFocusOnEnter == nil then
        args.params.loseFocusOnEnter = Ref(true)
    end

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

    local hook = function(event)
        return function(f, name, order, target)
            e:SetHandler(event, f, name, order, target)
        end
    end

    result.handlers.onTextChanged = MakeHandlers(args.events.onTextChanged, hook("OnTextChanged"))
    result.handlers.onEnter = MakeHandlers(args.events.onEnter, hook("OnEnter"))
    result.handlers.onEscape = MakeHandlers(args.events.onEscape, hook("OnEscape"))
    result.handlers.onFocusGained = MakeHandlers(args.events.onFocusGained, hook("OnFocusGained"))
    result.handlers.onFocusLost = MakeHandlers(args.events.onFocusLost, hook("OnFocusLost"))

    e:SetHandler("OnEscape", function(self)
        self:LoseFocus()
    end, id .. "-builtin-escape")
    e:SetHandler("OnEnter", function(self)
        if not args.params.multiLine:get() and args.params.loseFocusOnEnter:get() then
            self:LoseFocus()
        end
    end, id .. "-builtin-enter")

    return result
end

---@param controlArgs {
---    params: EditBoxParamsArgs?,
---    events: EditBoxEventsArgs?,
---    slots: EditBoxSlotsArgs?,
---}
---@param defaultText string?
---@return function
---@nodiscard
function Controls.Dsl.editBox(controlArgs, defaultText)
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
        if defaultText ~= nil then
            if controlArgs.params.defaultText == nil then
                controlArgs.params.defaultText = Ref(defaultText)
            else
                controlArgs.params.defaultText:set(defaultText)
            end
        end
        local result = Controls.editBox(id, parent, controlArgs)
        return result
    end
end
