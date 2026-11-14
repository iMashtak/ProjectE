--* use ./root.lua
--* use ../host.lua
--* use /libs/Controls/basic/layout.lua
--* use ./effects/crux.lua
--* use ./effects/ulfsild.lua

local clone = E.Utils.clone

local logger = Logger("/extensions/AimEffects/main.lua")

local defaultSettings = {
    enabled = true
}

local defaultValues = {
    crux = E.AimEffects.Crux.defaults,
    ulfsild = E.AimEffects.Ulfsild.defaults,
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
    if vars.AimEffects == nil then
        vars.AimEffects = defaults
    end
    local characterId = GetCurrentCharacterId()
    if vars.AimEffects.character[characterId] == nil then
        vars.AimEffects.character[characterId] = {
            settings = clone(defaultSettings),
            values = clone(defaultValues),
        }
    end
    vars.AimEffects = clone(defaults)
    vars.AimEffects.character[characterId] = {
        settings = clone(defaultSettings),
        values = clone(defaultValues),
    }
end

local function InitializeExtension(vars)
    MigrateSavedVariables(vars)
    local layout = Controls.layout("E_AIM_EFFECTS_LAYOUT", {
        params = {
            hidden = Ref(true),
            anchors = Ref({
                { point = CENTER, target = GuiRoot, relativePoint = CENTER, offsetX = 0, offsetY = 0 }
            }),
            height = Ref(128),
            width = Ref(128),
        }
    })
    local characterId = GetCurrentCharacterId()
    E.AimEffects.Crux.Initialize(vars.AimEffects.character[characterId].values.crux, layout)
    E.AimEffects.Ulfsild.Initialize(vars.AimEffects.character[characterId].values.ulfsild, layout)
    local fragment = ZO_HUDFadeSceneFragment:New(layout.element, nil, 0)
    do
        local inCombat = IsUnitInCombat("player")
        if inCombat then
            layout.params.hidden:set(false)
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)
        end
    end
    EVENT_MANAGER:RegisterForEvent(
        "E_AIM_EFFECTS_LAYOUT_EVENT_PLAYER_COMBAT_STATE",
        EVENT_PLAYER_COMBAT_STATE,
        function(_, inCombat)
            if inCombat then
                layout.params.hidden:set(false)
                HUD_SCENE:AddFragment(fragment)
                HUD_UI_SCENE:AddFragment(fragment)
            else
                HUD_SCENE:RemoveFragment(fragment)
                HUD_UI_SCENE:RemoveFragment(fragment)
                layout.params.hidden:set(true)
            end
        end
    )
end

local function InitializeSettings(vars, parent)
end

RegisterExtension("Aim Effects", InitializeExtension, InitializeSettings)
