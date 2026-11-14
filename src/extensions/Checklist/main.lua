--* use ../host.lua
--* use /libs/Utils/main.lua
--* use /libs/Controls/main.lua
--* use /libs/Controls/ref.lua
--* use /libs/Controls/basic/setupControl.lua
--* use /libs/Controls/basic/layout.lua
--* use /libs/Controls/basic/backdrop.lua
--* use /libs/Controls/basic/label.lua
--* use /libs/Controls/basic/editBox.lua
--* use /libs/Controls/basic/texture.lua
--* use /libs/Logging/log.lua

local clone = E.Utils.clone

local logger = Logger("/extensions/Checklist/main.lua")

ZO_CreateStringId("SI_CHECKLIST_MENU_NAME", "Checklist")

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
        vars.Checklist = defaults
    end
    local characterId = GetCurrentCharacterId()
    if vars.Checklist.character[characterId] == nil then
        vars.Checklist.character[characterId] = {
            settings = clone(defaultSettings),
            values = clone(defaultValues),
        }
    end
    vars.Checklist = clone(defaults)
    vars.Checklist.character[characterId] = {
        settings = clone(defaultSettings),
        values = clone(defaultValues),
    }
end

local topMenuButtonLayout = {
    descriptor = "ProjectE_Checklist",
    categoryName = SI_CHECKLIST_MENU_NAME,
    callback = function(buttonData)
        logger:info("Checklist top menu button clicked")
    end,
    visible = function(buttonData)
        return true
    end,
    normal = "/ProjectE/assets/checklistup.dds",
    pressed = "/ProjectE/assets/checklistdown.dds",
    highlight = "/ProjectE/assets/checklistover.dds",
    disabled = "/ProjectE/assets/checklistdisabled.dds",
}

local function AddTopMenuButton()
    ZO_MenuBar_AddButton(MAIN_MENU_KEYBOARD.categoryBar, topMenuButtonLayout)
end

local function InitializeExtension(vars)
    MigrateSavedVariables(vars)
    AddTopMenuButton()
end

---@param parent Element
local function InitializeSettings(vars, parent)
end

RegisterExtension("Checklist", InitializeExtension, InitializeSettings)
