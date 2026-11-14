--* use ../host.lua
--* use /libs/Utils/main.lua
--* use /libs/Controls/main.lua
--* use /libs/Controls/ref.lua
--* use /libs/Controls/basic/setupControl.lua
--* use /libs/Controls/basic/control.lua
--* use /libs/Controls/basic/layout.lua
--* use /libs/Controls/basic/backdrop.lua
--* use /libs/Controls/basic/label.lua
--* use /libs/Controls/basic/editBox.lua
--* use /libs/Controls/basic/texture.lua
--* use /libs/Controls/composite/scrollArea.lua
--* use /libs/Logging/log.lua

local clone = E.Utils.clone

local logger = Logger("/extensions/Checklist/main.lua")

local BUTTON_DESCRIPTOR = "ProjectE_Checklist"
local SCENE_NAME = "ProjectE_ChecklistScene"

local PANEL_CONTENT_WIDTH = 495

local INPUT_GAP = 12
local ADD_BUTTON_WIDTH = 90
local INPUT_WIDTH = PANEL_CONTENT_WIDTH - ADD_BUTTON_WIDTH - INPUT_GAP

local ROW_WIDTH = 470
local ROW_HEIGHT = 26
local ROW_GAP = 8
local DELETE_BUTTON_WIDTH = 26
local ITEM_TEXT_WIDTH = ROW_WIDTH - DELETE_BUTTON_WIDTH - 6

local MAX_ITEM_LENGTH = 80

local defaultSettings = {
    enabled = true
}

local defaultValues = {}

local defaults = {
    version = 1,
    account = {
        settings = clone(defaultSettings),
        values = clone(defaultValues),
    },
    character = {}
}

local function MigrateSavedVariables(vars)
    if vars.Checklist == nil then
        vars.Checklist = clone(defaults)
    end
    if vars.Checklist.account == nil then
        vars.Checklist.account = {
            settings = clone(defaultSettings),
            values = clone(defaultValues),
        }
    end
    if vars.Checklist.character == nil then
        vars.Checklist.character = {}
    end
    local characterId = GetCurrentCharacterId()
    if vars.Checklist.character[characterId] == nil then
        vars.Checklist.character[characterId] = {
            settings = clone(defaultSettings),
            values = clone(defaultValues),
        }
    end
end

local function AddLocalization()
    ZO_CreateStringId("SI_CHECKLIST_MENU_NAME", "Checklist")
    ZO_CreateStringId("SI_CHECKLIST_TITLE", "Checklist")
    ZO_CreateStringId("SI_CHECKLIST_ADD", "Add")
    ZO_CreateStringId("SI_CHECKLIST_INPUT_DEFAULT", "Add an activity...")
    ZO_CreateStringId("SI_CHECKLIST_EMPTY_TITLE", "Nothing planned yet")
    ZO_CreateStringId("SI_CHECKLIST_EMPTY_DESCRIPTION", "Activities you add will be listed here.")
    ZO_CreateStringId("SI_CHECKLIST_HINT", "Press Enter to add an item. Exit closes the panel.")
end

---@param label Label
local function MakeClickable(label)
    label.element:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    label.element:SetHandler("OnMouseEnter", function(self)
        self:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGBA())
    end)
    label.element:SetHandler("OnMouseExit", function(self)
        self:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    end)
end

---@class ChecklistState
---@field panel ChecklistPanel?
---@field values table?
---@field rows ChecklistItemRow[]

---@class ChecklistItemRow
---@field row Control
---@field text Label
---@field delete Label
---@field item {text: string}?

---@type ChecklistState
local Checklist = {
    rows = {},
}

---@return {text: string}[]
function Checklist:GetItems()
    local values = self.values
    if values.items == nil then
        values.items = {}
    end
    return values.items
end

---@param index integer
---@return ChecklistItemRow
function Checklist:CreateRow(index)
    local id = "E_CHECKLIST_ITEM_" .. tostring(index)

    ---@type ChecklistItemRow
    local entry = {
        row = Controls.control(id, self.panel.list.children.inner, {
            params = {
                hidden = Ref(true),
                width = Ref(ROW_WIDTH),
                height = Ref(ROW_HEIGHT),
                anchors = Ref({}),
            }
        }),
    }

    entry.text = Controls.label(id .. "_TEXT", entry.row, {
        params = {
            hidden = Ref(false),
            text = Ref(""),
            font = Ref("ZoFontGame"),
            width = Ref(ITEM_TEXT_WIDTH),
            height = Ref(ROW_HEIGHT),
            anchors = Ref({
                { point = TOPLEFT, target = entry.row.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 },
            }),
        }
    })
    entry.text.element:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    entry.text.element:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    entry.delete = Controls.label(id .. "_DELETE", entry.row, {
        params = {
            hidden = Ref(false),
            text = Ref("X"),
            font = Ref("ZoFontGame"),
            width = Ref(DELETE_BUTTON_WIDTH),
            height = Ref(ROW_HEIGHT),
            mouseEnabled = Ref(true),
            anchors = Ref({
                { point = TOPRIGHT, target = entry.row.element, relativePoint = TOPRIGHT, offsetX = 0, offsetY = 0 },
            }),
        },
        events = {
            onMouseUp = Ref(function(_, button, upInside)
                if button == 1 and upInside and entry.item ~= nil then
                    self:Remove(entry.item)
                end
            end),
        },
    })
    entry.delete.element:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    entry.delete.element:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    MakeClickable(entry.delete)

    self.rows[index] = entry

    return entry
end

function Checklist:Refresh()
    local items = self:GetItems()
    local panel = self.panel
    local previous = nil

    for i, item in ipairs(items) do
        local entry = self.rows[i] or self:CreateRow(i)
        entry.item = item
        entry.row.params.hidden:set(false)
        entry.text.params.text:set(item.text)

        if previous == nil then
            entry.row.params.anchors:set({
                { point = TOPLEFT, target = panel.list.children.inner.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 },
            })
        else
            entry.row.params.anchors:set({
                { point = TOPLEFT, target = previous.row.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = ROW_GAP },
            })
        end

        previous = entry
    end

    for i = #items + 1, #self.rows do
        self.rows[i].item = nil
        self.rows[i].row.params.hidden:set(true)
    end

    local isEmpty = #items == 0
    panel.emptyTitle.params.hidden:set(not isEmpty)
    panel.description.params.hidden:set(not isEmpty)
end

function Checklist:AddFromInput()
    local panel = self.panel
    local input = panel.input

    local text = input.params.text:get()
    text = text:match("^%s*(.-)%s*$")

    if text ~= "" then
        local items = self:GetItems()
        table.insert(items, 1, { text = text })
        input.params.text:set("")
        self:Refresh()
    end

    input.element:TakeFocus()
end

---@param item {text: string}
function Checklist:Remove(item)
    local items = self:GetItems()
    for i = 1, #items do
        if items[i] == item then
            table.remove(items, i)
            break
        end
    end
    self:Refresh()
end

---@class ChecklistPanel
---@field layout Layout
---@field title Label
---@field input EditBox
---@field addButton Label
---@field list ScrollArea
---@field emptyTitle Label
---@field description Label
---@field hint Label

---@return ChecklistPanel
local function CreatePanel()
    local layout = Controls.layout("E_CHECKLIST_PANEL", {
        params = {
            anchors = Ref({
                { point = TOPLEFT,     target = ZO_SharedRightPanelBackground, relativePoint = TOPLEFT,     offsetX = 40,  offsetY = 60 },
                { point = BOTTOMRIGHT, target = ZO_SharedRightPanelBackground, relativePoint = BOTTOMRIGHT, offsetX = -40, offsetY = -40 },
            }),
        }
    })

    local title = Controls.label("E_CHECKLIST_PANEL_TITLE", layout, {
        params = {
            hidden = Ref(false),
            font = Ref("ZoFontHeader3"),
            text = Ref(GetString(SI_CHECKLIST_TITLE)),
            anchors = Ref({
                { point = TOPLEFT, target = layout.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 },
            }),
        }
    })

    local inputRow = Controls.control("E_CHECKLIST_INPUT_ROW", layout, {
        params = {
            hidden = Ref(false),
            width = Ref(PANEL_CONTENT_WIDTH),
            height = Ref(ROW_HEIGHT),
            anchors = Ref({
                { point = TOPLEFT, target = title.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = 24 },
            }),
        }
    })

    local input = Controls.editBox("E_CHECKLIST_INPUT", inputRow, {
        params = {
            hidden = Ref(false),
            width = Ref(INPUT_WIDTH),
            height = Ref(ROW_HEIGHT),
            font = Ref("ZoFontGame"),
            defaultText = Ref(GetString(SI_CHECKLIST_INPUT_DEFAULT)),
            maxLength = Ref(MAX_ITEM_LENGTH),
            loseFocusOnEnter = Ref(false),
            anchors = Ref({
                { point = TOPLEFT, target = inputRow.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 },
            }),
        },
        events = {
            onEnter = Ref(function()
                Checklist:AddFromInput()
            end),
        },
    })

    local addButton = Controls.label("E_CHECKLIST_ADD", inputRow, {
        params = {
            hidden = Ref(false),
            text = Ref(GetString(SI_CHECKLIST_ADD)),
            font = Ref("ZoFontGame"),
            width = Ref(ADD_BUTTON_WIDTH),
            height = Ref(ROW_HEIGHT),
            mouseEnabled = Ref(true),
            anchors = Ref({
                { point = TOPLEFT, target = input.element, relativePoint = TOPRIGHT, offsetX = INPUT_GAP, offsetY = 0 },
            }),
        },
        events = {
            onMouseUp = Ref(function(_, button, upInside)
                if button == 1 and upInside then
                    Checklist:AddFromInput()
                end
            end),
        },
    })
    addButton.element:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    addButton.element:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    MakeClickable(addButton)

    local list = Controls.scrollArea("E_CHECKLIST_LIST", layout, {
        params = {
            hidden = Ref(false),
            anchors = Ref({
                { point = TOPLEFT, target = inputRow.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = 22 },
                { point = BOTTOMRIGHT, target = layout.element, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = -36 },
            }),
        },
    })

    local emptyTitle = Controls.label("E_CHECKLIST_PANEL_EMPTY_TITLE", layout, {
        params = {
            hidden = Ref(false),
            font = Ref("ZoFontGameLargeBold"),
            text = Ref(GetString(SI_CHECKLIST_EMPTY_TITLE)),
            anchors = Ref({
                { point = TOPLEFT, target = inputRow.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = 28 },
            }),
        }
    })

    local description = Controls.label("E_CHECKLIST_PANEL_DESCRIPTION", layout, {
        params = {
            hidden = Ref(false),
            font = Ref("ZoFontGame"),
            text = Ref(GetString(SI_CHECKLIST_EMPTY_DESCRIPTION)),
            width = Ref(PANEL_CONTENT_WIDTH),
            anchors = Ref({
                { point = TOPLEFT, target = emptyTitle.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = 10 },
            }),
        }
    })
    description.element:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    description.element:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())

    local hint = Controls.label("E_CHECKLIST_PANEL_HINT", layout, {
        params = {
            hidden = Ref(false),
            font = Ref("ZoFontGameSmall"),
            text = Ref(GetString(SI_CHECKLIST_HINT)),
            width = Ref(PANEL_CONTENT_WIDTH),
            anchors = Ref({
                { point = BOTTOMLEFT, target = layout.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = 0 },
            }),
        }
    })
    hint.element:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    hint.element:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())

    return {
        layout = layout,
        title = title,
        input = input,
        addButton = addButton,
        list = list,
        emptyTitle = emptyTitle,
        description = description,
        hint = hint,
    }
end

local isMenuBarSelectionSyncing = false

local function ToggleChecklistScene()
    if SCENE_MANAGER:IsShowing(SCENE_NAME) or SCENE_MANAGER:IsShowingNext(SCENE_NAME) then
        SCENE_MANAGER:ShowBaseScene()
    else
        SCENE_MANAGER:Show(SCENE_NAME)
    end
end

local function SelectMenuBarButton()
    isMenuBarSelectionSyncing = true
    ZO_MenuBar_SelectDescriptor(MAIN_MENU_KEYBOARD.categoryBar, BUTTON_DESCRIPTOR, true)
    isMenuBarSelectionSyncing = false
end

local function ClearMenuBarSelection()
    if ZO_MenuBar_GetSelectedDescriptor(MAIN_MENU_KEYBOARD.categoryBar) ~= BUTTON_DESCRIPTOR then
        return
    end
    isMenuBarSelectionSyncing = true
    ZO_MenuBar_ClearSelection(MAIN_MENU_KEYBOARD.categoryBar)
    isMenuBarSelectionSyncing = false
end

---@param panel ChecklistPanel
local function CreateScene(panel)
    local scene = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)

    scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    scene:AddFragment(RIGHT_PANEL_BG_FRAGMENT)
    scene:AddFragment(MAIN_MENU_KEYBOARD.categoryBarFragment)
    scene:AddFragment(ZO_FadeSceneFragment:New(panel.layout.element, false, 0))

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            logger:info("Checklist panel opened")
            SelectMenuBarButton()
        elseif newState == SCENE_SHOWN then
            panel.input.element:TakeFocus()
        elseif newState == SCENE_HIDING then
            panel.input.element:LoseFocus()
        elseif newState == SCENE_HIDDEN then
            logger:info("Checklist panel closed")
            ClearMenuBarSelection()
        end
    end)

    return scene
end

local function AddTopMenuButton()
    ZO_MenuBar_AddButton(MAIN_MENU_KEYBOARD.categoryBar, {
        descriptor = BUTTON_DESCRIPTOR,
        categoryName = SI_CHECKLIST_MENU_NAME,
        callback = function(buttonData)
            if isMenuBarSelectionSyncing then
                return
            end
            ToggleChecklistScene()
        end,
        visible = function(buttonData)
            return true
        end,
        normal = "/ProjectE/assets/checklistup.dds",
        pressed = "/ProjectE/assets/checklistdown.dds",
        highlight = "/ProjectE/assets/checklistover.dds",
        disabled = "/ProjectE/assets/checklistdisabled.dds",
    })
end

local function InitializeExtension(vars)
    MigrateSavedVariables(vars)

    AddLocalization()

    local characterId = GetCurrentCharacterId()
    Checklist.values = vars.Checklist.character[characterId].values
    if Checklist.values.items == nil then
        Checklist.values.items = {}
    end

    Checklist.panel = CreatePanel()
    CreateScene(Checklist.panel)
    AddTopMenuButton()

    Checklist:Refresh()

    SLASH_COMMANDS["/checklist"] = ToggleChecklistScene
end

---@param parent Element
local function InitializeSettings(vars, parent)
end

RegisterExtension("Checklist", InitializeExtension, InitializeSettings)
