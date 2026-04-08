--* use ../host.lua
--* use /libs/Controls/main.lua
--* use /libs/Controls/ref.lua
--* use /libs/Logging/log.lua
--* use /libs/Controls/basic/label.lua
--* use /libs/Controls/composite/table.lua

local logger = Logger("/extensions/Currency/main.lua")

local defaults = {
    version = 1,
    amounts = {},
    settings = {
        enabled = true,
        ordering = {
            "money",
            "telvar",
        }
    },
}

local function MigrateSavedVariables(vars)
    if vars.Currency == nil then
        vars.Currency = defaults
        return
    end
    if vars.Currency.amounts == nil then
        vars.Currency.amounts = defaults.amounts
    end
    if vars.Currency.settings == nil then
        vars.Currency.settings = defaults.settings
    end
    vars.Currency.settings = defaults.settings
end

local function InitializeMoney(vars, characterId, parent)
    local moneyAmount = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    vars.Currency.amounts[characterId].money = moneyAmount
    local moneyIconText = zo_iconFormat(GetCurrencyKeyboardIcon(CURT_MONEY), 16, 16)
    local function moneyText()
        local total = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
        for _, data in pairs(vars.Currency.amounts) do
            if data.money ~= nil then
                total = total + data.money
            end
        end
        return moneyIconText .. " " .. tostring(total)
    end
    local function moneyTooltipText()
        local bankedMoney = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
        local result = moneyIconText .. " " .. tostring(bankedMoney) .. " (bank)"
        local idAndName = {}
        for id, data in pairs(vars.global.characters) do
            idAndName[#idAndName + 1] = { id = id, name = data.name }
        end
        table.sort(idAndName, function(a, b) return a.name < b.name end)
        for _, item in ipairs(idAndName) do
            local id = item.id
            local data = vars.Currency.amounts[id]
            local name = vars.global.characters[id].name
            if data.money ~= nil then
                result = result .. "\n" .. moneyIconText .. " " .. tostring(data.money) .. " (" .. name .. ")"
            end
        end
        return result
    end
    local money = Controls.label("E_CURRENCY_MONEY", parent, {
        params = {
            text = Ref(moneyText()),
            mouseEnabled = Ref(true)
        }
    })
    EVENT_MANAGER:RegisterForEvent("E_CURRENCY_EVENT_MONEY_UPDATE", EVENT_MONEY_UPDATE, function(_, new, _, _)
        vars.Currency.amounts[characterId].money = new
        money.params.text:set(moneyText())
    end)
    money.element:SetHandler("OnMouseEnter", function(control)
        ZO_Tooltips_ShowTextTooltip(control, TOP, moneyTooltipText())
    end)
    money.element:SetHandler("OnMouseExit", function(_)
        ZO_Tooltips_HideTextTooltip()
    end)
    return money
end

local function InitializeTelvar(vars, characterId, parent)
    local telvarAmount = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
    vars.Currency.amounts[characterId].telvar = telvarAmount
    local telvarIconText = zo_iconFormat(GetCurrencyKeyboardIcon(CURT_TELVAR_STONES), 16, 16)
    local function telvarText()
        local total = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_BANK)
        for _, data in pairs(vars.Currency.amounts) do
            if data.telvar ~= nil then
                total = total + data.telvar
            end
        end
        return telvarIconText .. " " .. tostring(total)
    end
    local function telvarTooltipText()
        local bankedTelvar = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_BANK)
        local result = telvarIconText .. " " .. tostring(bankedTelvar) .. " (bank)"
        local idAndName = {}
        for id, data in pairs(vars.global.characters) do
            idAndName[#idAndName + 1] = { id = id, name = data.name }
        end
        table.sort(idAndName, function(a, b) return a.name < b.name end)
        for _, item in ipairs(idAndName) do
            local id = item.id
            local data = vars.Currency.amounts[id]
            local name = vars.global.characters[id].name
            if data.telvar ~= nil then
                result = result .. "\n" .. telvarIconText .. " " .. tostring(data.telvar) .. " (" .. name .. ")"
            end
        end
        return result
    end
    local telvar = Controls.label("E_CURRENCY_TELVAR", parent, {
        params = {
            text = Ref(telvarText()),
            mouseEnabled = Ref(true)
        }
    })
    EVENT_MANAGER:RegisterForEvent("E_CURRENCY_EVENT_TELVAR_STONE_UPDATE", EVENT_TELVAR_STONE_UPDATE,
        function(_, new, _, _)
            vars.Currency.amounts[characterId].telvar = new
            telvar.params.text:set(telvarText())
        end)
    telvar.element:SetHandler("OnMouseEnter", function(control)
        ZO_Tooltips_ShowTextTooltip(control, TOP, telvarTooltipText())
    end)
    telvar.element:SetHandler("OnMouseExit", function(_)
        ZO_Tooltips_HideTextTooltip()
    end)
    return telvar
end

---@param vars any
---@param initialPoint any
---@param target any
---@param initialRelativePoint any
---@param initialOffsetX any
---@param initialOffsetY any
---@param money Label
---@param telvar Label
local function PositionCurrencies(
    vars, initialPoint, target, initialRelativePoint, initialOffsetX, initialOffsetY,
    money, telvar
)
    local previous = target
    for i, item in ipairs(vars.Currency.settings.ordering) do
        local point = nil
        local relativePoint = nil
        local offsetX = nil
        local offsetY = nil
        if i == 1 then
            point = initialPoint
            relativePoint = initialRelativePoint
            offsetX = initialOffsetX
            offsetY = initialOffsetY
        else
            point = BOTTOMLEFT
            relativePoint = BOTTOMRIGHT
            offsetX = 10
            offsetY = 0
        end
        if item == "money" then
            money.params.hidden:set(false)
            money.params.anchors:set({
                { point = point, target = previous.element, relativePoint = relativePoint, offsetX = offsetX, offsetY = offsetY },
            })
            previous = money
        end
        if item == "telvar" then
            telvar.params.hidden:set(false)
            telvar.params.anchors:set({
                { point = point, target = previous.element, relativePoint = relativePoint, offsetX = offsetX, offsetY = offsetY },
            })
            previous = telvar
        end
    end
end

local function InitializeExtension(vars)
    MigrateSavedVariables(vars)

    local characterId = GetCurrentCharacterId()
    if vars.Currency.amounts[characterId] == nil then
        vars.Currency.amounts[characterId] = {}
    end
    local layout = Controls.layout("E_CURRENCY_LAYOUT", {
        params = {
            hidden = Ref(not vars.Currency.settings.enabled)
        }
    })
    layout.element:SetHandler("OnShow", function()
        if not vars.Currency.settings.enabled then
            layout.params.hidden:set(true)
        end
    end)

    local money = InitializeMoney(vars, characterId, layout)
    local telvar = InitializeTelvar(vars, characterId, layout)
    if ZO_PerformanceMeters:IsHidden() then
        PositionCurrencies(vars, BOTTOMLEFT, { element = GuiRoot }, BOTTOMLEFT, 0, -2, money, telvar)
    else
        PositionCurrencies(
            vars, LEFT, { element = ZO_PerformanceMeters }, LEFT, ZO_PerformanceMeters:GetWidth(), 0,
            money, telvar
        )
    end
    ZO_PerformanceMeters:SetHandler("OnHide", function()
        PositionCurrencies(vars, BOTTOMLEFT, { element = GuiRoot }, BOTTOMLEFT, 0, -2, money, telvar)
    end, "E_CURRENCY_PERFORMANCE_METERS_ON_HIDE")
    ZO_PerformanceMeters:SetHandler("OnShow", function()
        PositionCurrencies(
            vars, LEFT, { element = ZO_PerformanceMeters }, LEFT, ZO_PerformanceMeters:GetWidth(), 0,
            money, telvar
        )
    end, "E_CURRENCY_PERFORMANCE_METERS_ON_SHOW")
    local fragment = ZO_HUDFadeSceneFragment:New(layout.element, nil, 0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
end

---@param parent Element
local function InitializeSettings(vars, parent)
    local table = Controls.Dsl.table
    local row = Controls.Dsl.row
    local column = Controls.Dsl.column
    local label = Controls.Dsl.label
    local tableF = table(
        {
            params = {
                hidden = Ref(false),
                anchors = Ref({
                    { point = TOPLEFT, target = parent.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 }
                }),
                width = Ref(600)
            }
        },
        row({},
            column({}, label({}, "Currency Extension"))
        ),
        row({},
            column({}, label({}, "Enabled")),
            column({}, function(id, p)
                local state = Ref(vars.Currency.settings.enabled)
                state:use(id .. "-state", function(_, v)
                    vars.Currency.settings.enabled = v
                end)
                local checkbox = Controls.label(id, p, {
                    params = {
                        hidden = Ref(false),
                        anchors = Ref({
                            { point = TOPLEFT,     target = p.element, relativePoint = TOPLEFT,     offsetX = 0, offsetY = 0 },
                            { point = BOTTOMRIGHT, target = p.element, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
                        }),
                        text = RefC(id .. "-text", { state }, function(ok)
                            if ok then
                                return zo_iconFormat(Textures.icons.checkbox.checked, 23, 23)
                            else
                                return zo_iconFormat(Textures.icons.checkbox.unchecked, 23, 23)
                            end
                        end),
                        mouseEnabled = Ref(true),
                    },
                    events = {
                        onMouseDown = Ref(function(self, button, ctrl, alt, shift, command)
                            state:set(not state:get())
                        end)
                    }
                })
                return checkbox
            end)
        )
    )
    local result = tableF("E_CURRENCY_SETTINGS", parent)
end

RegisterExtension("Currency", InitializeExtension, InitializeSettings)
