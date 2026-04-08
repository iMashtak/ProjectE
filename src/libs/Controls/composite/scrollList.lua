--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua

local font = "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick"

---@class ScrollList : Element
---@field params ScrollListParams
---@field handlers ScrollListHandlers
---@field children ScrollListChildren

---@class ScrollListParams : ControlParams
---@field entries Ref<string[]>

---@class ScrollListHandlers : ControlHandlers
---@field onSelected Handlers<fun(old: {text: string}?, new: {text: string}?)>

---@class ScrollListChildren

---@class ScrollListParamsArgs : ControlParamsArgs
---@field entries Ref<string[]>?

---@class ScrollListEventsArgs : ControlEventsArgs
---@field onSelected Ref<fun(old: {text: string}?, new: {text: string}?)>

---@class ScrollListSlotsArgs

---@param id string
---@param parent Element
---@param args {
---    params: ScrollListParamsArgs?,
---    events: ScrollListEventsArgs?,
---    slots: ScrollListSlotsArgs?,
---}
---@return ScrollList
---@nodiscard
function Controls.scrollList(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as ScrollList]]

    result.handlers.onSelected = MakeHandlers(args.events.onSelected, function(_, _, _, _) end)

    local list = WINDOW_MANAGER:CreateControlFromVirtual(id .. "-scrollList", e, "ZO_ScrollList")

    local function onMouseDown(self, button)
        if button == 1 then
            local data = ZO_ScrollList_GetData(self)
            ZO_ScrollList_SelectData(list, data, self)
        end
    end

    local function onSelected(previouslySelectedData, selectedData, reselectingDuringRebuild)
        if not reselectingDuringRebuild then
            args.events.onSelected:get()(previouslySelectedData, selectedData)
        end
    end

    local function onSetup(control, data)
        control:SetText(data.text)
        if data.index == 1 then
            ZO_ScrollList_SelectData(list, data, control)
        else
            control:SetSelected(false)
        end
    end

    ZO_ScrollList_AddDataType(list, 1, "ZO_SelectableLabel", 28, onSetup)
    ZO_ScrollList_EnableSelection(list, "ZO_ThinListHighlight", onSelected)

    local addonDataType = ZO_ScrollList_GetDataTypeTable(list, 1)
    local rowFactoryOrigin = addonDataType.pool.m_Factory

    local function rowFactory(pool)
        local control = rowFactoryOrigin(pool)
        control:SetHandler("OnMouseDown", onMouseDown)
        control:SetHeight(28)
        control:SetFont(font)
        control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        control:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        return control
    end

    addonDataType.pool.m_Factory = rowFactory

    list:SetAnchor(TOPLEFT, e, TOPLEFT, 0, 0)
    list:SetHeight(e:GetHeight())
    list:SetWidth(e:GetWidth())

    if args.params.entries == nil then
        args.params.entries = Ref({})
    end
    args.params.entries:use(id .. "-entries", function(_, v)
        local entryList = ZO_ScrollList_GetDataList(list)
        ZO_ScrollList_Clear(list)
        for i, str in ipairs(v) do
            entryList[i] = ZO_ScrollList_CreateDataEntry(1, {
                text = str,
                index = i,
            })
        end
        ZO_ScrollList_Commit(list)
        ZO_ScrollList_SelectData(list, { text = v[1], index = 1 }, nil)
        args.events.onSelected:get()(nil, { text = v[1], index = 1 })
    end)

    return result
end
