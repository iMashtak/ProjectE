--* use ../main.lua
--* use ../ref.lua
--* use ../basic/setupControl.lua
--* use /libs/Logging/log.lua

local logger = Logger("/libs/Controls/composite/table.lua")

---@class Table : Element
---@field params TableParams
---@field handlers TableHandlers
---@field children TableChildren

---@class TableParams : ControlParams

---@class TableHandlers : ControlHandlers

---@class TableChildren
---@field rows Row[]

---@class TableParamsArgs : ControlParamsArgs

---@class TableEventsArgs : ControlEventsArgs

---@class TableSlotsArgs
---@field rows fun(parent: Element): Row[]

---@param id string
---@param parent Element
---@param args {
---    params: TableParamsArgs?,
---    events: TableEventsArgs?,
---    slots: TableSlotsArgs?,
---}
---@return Table
function Controls.table(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as Table]]

    local rows = args.slots.rows(result)
    local previous = result --[[@as Element]]
    for i, row in ipairs(rows) do
        row.children.columns[1].params.height:use(id .. "-firstColumnHeight", function (_, v)
            row.params.height:set(v)
        end)
        if i == 1 then
            row.params.anchors:set({
                { point = TOPLEFT, target = e, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 },
            })
        else
            row.params.anchors:set({
                { point = TOPLEFT, target = previous.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = 0 },
            })
        end
        previous = row
    end
    result.children.rows = rows

    return result
end

-- Row --

---@class Row : Element
---@field params RowParams
---@field handlers RowHandlers
---@field children RowChildren

---@class RowParams : ControlParams

---@class RowHandlers : ControlHandlers

---@class RowChildren
---@field columns Column[]

---@class RowParamsArgs : ControlParamsArgs

---@class RowEventsArgs : ControlEventsArgs

---@class RowSlotsArgs
---@field columns fun(parent: Element): Column[]

---@param id string
---@param parent Element
---@param args {
---    params: RowParamsArgs?,
---    events: RowEventsArgs?,
---    slots: RowSlotsArgs?,
---}
---@return Row
function Controls.row(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as Row]]

    local columns = args.slots.columns(result)

    local columnHeights = {}
    for _, column in ipairs(columns) do
        columnHeights[#columnHeights + 1] = column.params.height
    end
    local maxHeight = RefC(id .. "-maxHeight", columnHeights, function(...)
        return math.max(...)
    end)
    maxHeight:use(id .. "-height", function (_, v)
        result.params.height:set(v)
    end)

    local columnWidth = RefC(id .. "-width", { result.params.width }, function(width)
        return width / #columns
    end)

    local previous = result --[[@as Element]]
    for i, column in ipairs(columns) do
        columnWidth:use(id .. "-columnWidth-" .. tostring(i), function(_, v)
            column.params.width:set(v)
        end)
        if i == 1 then
            column.params.anchors:set({
                { point = TOPLEFT, target = e, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 },
            })
        else
            column.params.anchors:set({
                { point = TOPLEFT, target = previous.element, relativePoint = TOPRIGHT, offsetX = 0, offsetY = 0 },
            })
        end
        previous = column
    end
    result.children.columns = columns

    return result
end

-- Column --

---@class Column : Element
---@field params ColumnParams
---@field handlers ColumnHandlers
---@field children ColumnChildren

---@class ColumnParams : ControlParams

---@class ColumnHandlers : ControlHandlers

---@class ColumnChildren
---@field content Element

---@class ColumnParamsArgs : ControlParamsArgs

---@class ColumnEventsArgs : ControlEventsArgs

---@class ColumnSlotsArgs
---@field content fun(parent: Element): Element

---@param id string
---@param parent Element
---@param args {
---    params: ColumnParamsArgs?,
---    events: ColumnEventsArgs?,
---    slots: ColumnSlotsArgs?,
---}
---@return Column
function Controls.column(id, parent, args)
    local e = WINDOW_MANAGER:CreateControl(id, parent.element, CT_CONTROL)
    local result = Controls.setupControl(id, e, args) --[[@as Column]]

    local content = args.slots.content(result)
    content.element:ClearAnchors()
    content.element:SetAnchor(TOPLEFT, e, TOPLEFT, 0, 0)
    result.params.height:set(content.element:GetHeight())

    result.children.content = content

    return result
end

-- DSL --

---@param controlArgs {
---    params: TableParamsArgs?,
---    events: TableEventsArgs?,
---    slots: TableSlotsArgs?,
---}
---@param ... fun(id: string, p: Element): Row
---@return function
function Controls.Dsl.table(controlArgs, ...)
    local args = { ... }
    return function(id, parent)
        if controlArgs.slots == nil then
            ---@diagnostic disable-next-line: missing-fields
            controlArgs.slots = {}
        end
        controlArgs.slots.rows = function(p)
            local rows = {}
            for i, rowF in ipairs(args) do
                local row = rowF(id .. "-row-" .. tostring(i), p)
                rows[#rows + 1] = row
            end
            return rows
        end
        local result = Controls.table(id, parent, controlArgs)
        return result
    end
end

---@param controlArgs {
---    params: RowParamsArgs?,
---    events: RowEventsArgs?,
---    slots: RowSlotsArgs?,
---}
---@param ... fun(id: string, p: Element): Column
---@return function
function Controls.Dsl.row(controlArgs, ...)
    local args = { ... }
    return function(id, parent)
        if controlArgs.params == nil then
            controlArgs.params = {}
        end
        if controlArgs.params.hidden == nil then
            controlArgs.params.hidden = Ref(false)
        end
        if controlArgs.params.width == nil then
            controlArgs.params.width = parent.params.width
        end
        if controlArgs.slots == nil then
            ---@diagnostic disable-next-line: missing-fields
            controlArgs.slots = {}
        end
        controlArgs.slots.columns = function(p)
            local columns = {}
            for i, columnF in ipairs(args) do
                local column = columnF(id .. "-column-" .. tostring(i), p)
                columns[#columns + 1] = column
            end
            return columns
        end
        local result = Controls.row(id, parent, controlArgs)
        return result
    end
end

---@param controlArgs {
---    params: ColumnParamsArgs?,
---    events: ColumnEventsArgs?,
---    slots: ColumnSlotsArgs?,
---}
---@param slot fun(id: string, p: Element): Element
---@return function
function Controls.Dsl.column(controlArgs, slot)
    return function(id, parent)
        if controlArgs.params == nil then
            controlArgs.params = {}
        end
        if controlArgs.params.hidden == nil then
            controlArgs.params.hidden = Ref(false)
        end
        if controlArgs.slots == nil then
            ---@diagnostic disable-next-line: missing-fields
            controlArgs.slots = {}
        end
        controlArgs.slots.content = function(p)
            return slot(id .. "-slot", p)
        end
        local result = Controls.column(id, parent, controlArgs)
        return result
    end
end
