--* use ./root.lua
--* use ../host.lua
--* use /libs/Controls/basic/label.lua
--* use /libs/Controls/basic/control.lua
--* use /libs/Controls/basic/layout.lua
--* use /libs/Controls/basic/editBox.lua
--* use /libs/Controls/composite/scrollArea.lua

local clone = E.Utils.clone

local logger = Logger("/extensions/Checklist/main.lua")

local defaultSettings = {
    enabled = true
}

local defaultValues = {
    notes = {},
    counter = 0,
}

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
    else
        local vs = vars.Checklist.character[characterId].values
        if vs.notes == nil then
            vs.notes = {}
        end
        if vs.counter == nil then
            vs.counter = 0
        end
    end
end

---@class Note
---@field text string
---@field id integer

---@param notes Ref<Note[]>
---@param counter Ref<integer>
---@param text string
local function AddNote(notes, counter, text)
    if text == "" then
        return
    end
    local id = counter:get() + 1
    counter:set(id)
    local notesInner = notes:get()
    ---@type Note
    local note = {
        text = text,
        id = id
    }
    table.insert(notesInner, 1, note)
    notes:set(notesInner)
end

---@param notes Ref<Note[]>
---@param note Note
---@param rows {item: Control, text: Label, delete: Label}[]
---@param index integer
local function RemoveNote(notes, note, rows, index)
    local notesInner = notes:get()
    for i = 1, #notesInner do
        if notesInner[i].id == note.id then
            table.remove(notesInner, i)
            break
        end
    end
    rows[index].item.params.hidden:set(true)
    table.remove(rows, index)
    notes:set(notesInner)
end

---@param panel {area: ScrollArea, rows: {item: Control, text: Label, delete: Label}[]}
---@param index integer
local function CreateNoteRow(panel, index)
    local baseId = "E_CHECKLIST_PANEL_NOTE_ROW_" .. tostring(index)
    if ControlsRegistry[baseId .. "-container"] ~= nil then
        return {
            item = ControlsRegistry[baseId .. "-container"],
            text = ControlsRegistry[baseId .. "-text"],
            delete = ControlsRegistry[baseId .. "-delete"]
        }
    end
    local item = Controls.control(baseId .. "-container", panel.area.children.inner, {
        params = {
            hidden = Ref(true),
            width = Ref(495),
            anchors = Ref({})
        }
    })
    local text = Controls.textArea(baseId .. "-text", item, {
        params = {
            hidden = Ref(false),
            autoGrow = Ref(true),
            maxHeight = Ref(100),
            anchors = Ref({
                { point = TOPLEFT,  target = item.element, relativePoint = TOPLEFT,  offsetX = 26, offsetY = 0 },
                { point = TOPRIGHT, target = item.element, relativePoint = TOPRIGHT, offsetX = 0,  offsetY = 0 }
            })
        }
    })
    text.params.height:use(baseId .. "-sync-height", function(_, v)
        item.params.height:set(v)
    end)
    local delete = Controls.label(baseId .. "-delete", item, {
        params = {
            hidden = Ref(false),
            text = Ref("X"),
            mouseEnabled = Ref(true),
            anchors = Ref({
                { point = TOPLEFT, target = item.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 }
            })
        }
    })
    return {
        item = item,
        text = text,
        delete = delete
    }
end

---@param panel {area: ScrollArea, rows: {item: Control, text: Label, delete: Label}[]}
---@param notes Ref<Note[]>
local function RefreshNotes(panel, notes)
    logger:info("refresh called, notes len = " .. tostring(#notes:get()))
    local previous = nil
    for i, note in ipairs(notes:get()) do
        local row = panel.rows[i]
        if row == nil then
            row = CreateNoteRow(panel, i)
            panel.rows[i] = row
        end
        row.item.params.hidden:set(false)
        row.text.params.text:set(note.text)
        row.delete.handlers.onMouseUp:free("DELETE_NOTE")
        row.delete.handlers.onMouseUp:add("DELETE_NOTE", Ref(function(_, button, upInside)
            if button == 1 and upInside then
                RemoveNote(notes, note, panel.rows, i)
                RefreshNotes(panel, notes)
            end
        end))
        if previous == nil then
            row.item.params.anchors:set({
                { point = TOPLEFT, target = panel.area.children.inner.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 }
            })
        else
            row.item.params.anchors:set({
                { point = TOPLEFT, target = previous.item.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = 8 }
            })
        end
        previous = row
    end
end

---@param notes Ref<Note[]>
---@param counter Ref<integer>
---@return Layout, EditBox, {area: ScrollArea, rows: Element[]}
local function CreatePanel(notes, counter)
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
            font = Ref(Fonts.h3),
            text = Ref("Notes"),
            anchors = Ref({
                { point = TOPLEFT, target = layout.element, relativePoint = TOPLEFT, offsetX = 0, offsetY = 0 },
            }),
        }
    })
    local input = Controls.editBox("E_CHECKLIST_PANEL_INPUT", layout, {
        params = {
            hidden = Ref(false),
            width = Ref(495),
            height = Ref(100),
            font = Ref(Fonts.game),
            defaultText = Ref("Some info to note..."),
            loseFocusOnEnter = Ref(false),
            multiLine = Ref(true),
            mouseEnabled = Ref(true),
            anchors = Ref({
                { point = TOPLEFT, target = title.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = 0 },
            }),
        }
    })
    input.handlers.onMouseUp:add("E_CHECKLIST_PANEL_INPUT_CLICK", Ref(function()
        input.element:TakeFocus()
    end))
    local submit = Controls.label("E_CHECKLIST_PANEL_SUBMIT", layout, {
        params = {
            hidden = Ref(false),
            font = Ref(Fonts.game),
            text = Ref("Add"),
            height = Ref(26),
            mouseEnabled = Ref(true),
            anchors = Ref({
                { point = TOPLEFT, target = input.element, relativePoint = BOTTOMLEFT, offsetX = 0, offsetY = 0 },
            })
        }
    })
    local notesArea = Controls.scrollArea("E_CHECKLIST_PANEL_NOTES_AREA", layout, {
        params = {
            hidden = Ref(false),
            anchors = Ref({
                { point = TOPLEFT,     target = submit.element, relativePoint = BOTTOMLEFT,  offsetX = 0, offsetY = 0 },
                { point = BOTTOMRIGHT, target = layout.element, relativePoint = BOTTOMRIGHT, offsetX = 0, offsetY = 0 },
            })
        }
    })
    local panel = {
        area = notesArea,
        rows = {}
    }
    submit.handlers.onMouseUp:add("E_CHECKLIST_PANEL_SUBMIT_CLICK",
        Ref(function()
            AddNote(notes, counter, input.params.text:get())
            input.params.text:set("")
            RefreshNotes(panel, notes)
        end))
    return layout, input, panel
end

local BUTTON_DESCRIPTOR = "ProjectE_Checklist"
local SCENE_NAME = "ProjectE_ChecklistScene"

local function ToggleChecklistScene()
    if SCENE_MANAGER:IsShowing(SCENE_NAME) or SCENE_MANAGER:IsShowingNext(SCENE_NAME) then
        SCENE_MANAGER:ShowBaseScene()
    else
        SCENE_MANAGER:Show(SCENE_NAME)
    end
end

local isMenuBarSelectionSyncing = false

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

local function CreateScene(layout, input)
    local scene = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)

    scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    scene:AddFragment(RIGHT_PANEL_BG_FRAGMENT)
    scene:AddFragment(MAIN_MENU_KEYBOARD.categoryBarFragment)
    scene:AddFragment(ZO_FadeSceneFragment:New(layout.element, false, 0))

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            SelectMenuBarButton()
        elseif newState == SCENE_SHOWN then
            input.element:TakeFocus()
        elseif newState == SCENE_HIDING then
            input.element:LoseFocus()
        elseif newState == SCENE_HIDDEN then
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
    local characterId = GetCurrentCharacterId()
    local notes = Ref(vars.Checklist.character[characterId].values.notes)
    notes:use("E_CHECKLIST_NOTES_VARS_SYNC", function(_, v)
        vars.Checklist.character[characterId].values.notes = v
    end, true)
    local counter = Ref(vars.Checklist.character[characterId].values.counter)
    counter:use("E_CHECKLIST_COUNTER_VARS_SYNC", function(_, v)
        vars.Checklist.character[characterId].values.counter = v
    end, true)
    local layout, input, panel = CreatePanel(notes, counter)
    CreateScene(layout, input)
    AddTopMenuButton()
    RefreshNotes(panel, notes)
end

---@param parent Element
local function InitializeSettings(vars, parent)
end

RegisterExtension("Checklist", InitializeExtension, InitializeSettings)
