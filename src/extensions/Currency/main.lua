--* use ../host.lua
--* use /libs/Controls/main.lua
--* use /libs/Controls/ref.lua
--* use /libs/Logging/log.lua
--* use /libs/Controls/basic/label.lua

local logger = Logger("/extensions/Currency/main.lua")

local defaults = {
    version = 1,
    amounts = {},
}

local function MigrateSavedVariables(vars)
    if vars.Currency == nil then
        vars.Currency = defaults
        return
    end
end

local function InitializeExtension(vars)
    MigrateSavedVariables(vars)

    local characterId = GetCurrentCharacterId()

    local moneyAmount = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    vars.Currency.amounts[characterId] = {
        money = moneyAmount
    }
    local moneyIconText = zo_iconFormat(GetCurrencyKeyboardIcon(CURT_MONEY), 16, 16)
    local function moneyText()
        local total = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
        for _, data in pairs(vars.Currency.amounts) do
            total = total + data.money
        end
        return moneyIconText .. " " .. tostring(total)
    end
    local function moneyTooltipText()
        local result = moneyIconText
            .. " " .. tostring(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)) .. " (bank)"
        local idAndName = {}
        for id, data in pairs(vars.global.characters) do
            idAndName[#idAndName + 1] = { id = id, name = data.name }
        end
        table.sort(idAndName, function(a, b) return a.name < b.name end)
        for _, item in ipairs(idAndName) do
            local id = item.id
            local data = vars.Currency.amounts[id]
            local name = vars.global.characters[id].name
            result = result .. "\n" .. moneyIconText .. " " .. tostring(data.money) .. " (" .. name .. ")"
        end
        return result
    end
    local money = Controls.label("E_CURRENCY_MONEY", { element = ZO_PerformanceMeters }, {
        hidden = Ref(false),
        anchors = Ref({
            { point = LEFT, target = ZO_PerformanceMeters, relativePoint = LEFT, offsetX = ZO_PerformanceMeters:GetWidth(), offsetY = 0 },
        }),
        text = Ref(moneyText()),
        mouseEnabled = Ref(true)
    })
    EVENT_MANAGER:RegisterForEvent("E_CURRENCY_EVENT_MONEY_UPDATE", EVENT_MONEY_UPDATE, function(_, new, _, _)
        vars.Currency.amounts[characterId].money = new
        money.text:set(moneyText())
    end)
    money.element:SetHandler("OnMouseEnter",
        function(control) ZO_Tooltips_ShowTextTooltip(control, TOP, moneyTooltipText()) end)
    money.element:SetHandler("OnMouseExit", function(_) ZO_Tooltips_HideTextTooltip() end)
end

---@param parent Element
local function InitializeSettings(vars, parent)

end

RegisterExtension("Currency", InitializeExtension, InitializeSettings)
