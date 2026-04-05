--* use ../host.lua
--* use /libs/Controls/main.lua
--* use /libs/Controls/ref.lua
--* use /libs/Logging/log.lua
--* use /libs/Controls/basic/label.lua

local logger = Logger("/extensions/Currency/main.lua")

local function InitializeExtension()
    local moneyAmount = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    local moneyIconText = zo_iconFormat(GetCurrencyKeyboardIcon(CURT_MONEY), 16, 16)
    local function moneyTooltipText()
        return moneyIconText .. " " .. tostring(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)) .. " (in bank)"
    end
    local money = Controls.label("E_CURRENCY_MONEY", { element = ZO_PerformanceMeters }, {
        hidden = Ref(false),
        anchors = Ref({
            { point = LEFT, target = ZO_PerformanceMeters, relativePoint = LEFT, offsetX = ZO_PerformanceMeters:GetWidth(), offsetY = 0 },
        }),
        text = Ref(moneyIconText .. " " .. tostring(moneyAmount)),
        mouseEnabled = Ref(true)
    })
    EVENT_MANAGER:RegisterForEvent("E_CURRENCY_EVENT_MONEY_UPDATE", EVENT_MONEY_UPDATE, function(_, new, _, _)
        money.text:set(moneyIconText .. " " .. tostring(new))
    end)
    money.element:SetHandler("OnMouseEnter", function(control) ZO_Tooltips_ShowTextTooltip(control, TOP, moneyTooltipText()) end)
    money.element:SetHandler("OnMouseExit", function(_) ZO_Tooltips_HideTextTooltip() end)
end

---@param parent Element
local function InitializeSettings(parent)

end

RegisterExtension("Currency", InitializeExtension, InitializeSettings)
