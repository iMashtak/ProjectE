--* use /libs/Controls/main.lua
--* use /libs/Controls/ref.lua
--* use /libs/Logging/log.lua
--* use /libs/Controls/basic/layout.lua
--* use /libs/Controls/basic/texture.lua

local logger = Logger("/extensions/Crux/main.lua")
local CRUX_ABILITY_ID = 184220

---@param cruxLeft Texture
---@param cruxRight Texture
---@param cruxUp Texture
---@param stackCount integer
local function SetCruxes(cruxLeft, cruxRight, cruxUp, stackCount)
    if stackCount == 0 then
        cruxLeft.hidden:set(true)
        cruxRight.hidden:set(true)
        cruxUp.hidden:set(true)
    end
    if stackCount == 1 then
        cruxLeft.hidden:set(false)
        cruxRight.hidden:set(true)
        cruxUp.hidden:set(true)
    end
    if stackCount == 2 then
        cruxLeft.hidden:set(false)
        cruxRight.hidden:set(false)
        cruxUp.hidden:set(true)
    end
    if stackCount == 3 then
        cruxLeft.hidden:set(false)
        cruxRight.hidden:set(false)
        cruxUp.hidden:set(false)
    end
end

---@param cruxLeft Texture
---@param cruxRight Texture
---@param cruxUp Texture
---@return function
local function OnEffectChanged(cruxLeft, cruxRight, cruxUp)
    return function(_, changeType, _, _, _, _, _, stackCount)
        if changeType == EFFECT_RESULT_FADED then
            SetCruxes(cruxLeft, cruxRight, cruxUp, 0)
        else
            SetCruxes(cruxLeft, cruxRight, cruxUp, stackCount)
        end
    end
end

---@param cruxLeft Texture
---@param cruxRight Texture
---@param cruxUp Texture
---@return function
local function OnPlayerStateChanged(cruxLeft, cruxRight, cruxUp)
    return function()
        for i = 1, GetNumBuffs("player") do
            local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
            if abilityId == CRUX_ABILITY_ID then
                SetCruxes(cruxLeft, cruxRight, cruxUp, stackCount)
                return
            end
        end
        SetCruxes(cruxLeft, cruxRight, cruxUp, 0)
    end
end

local function Initialize(_, addOnName)
    if addOnName ~= "ProjectE" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("E_CRUX", EVENT_ADD_ON_LOADED)

    if ControlsRegistry["E_CRUX_LAYOUT"] ~= nil then
        local layout = ControlsRegistry["E_CRUX_LAYOUT"] --[[@as Layout]]
        layout.hidden:set(false)
        return
    end

    local layout = Controls.layout("E_CRUX_LAYOUT", {
        hidden = Ref(false),
        anchors = Ref({
            { point = CENTER, target = GuiRoot, relativePoint = CENTER, offsetX = 0, offsetY = 0 }
        }),
        height = Ref(128),
        width = Ref(128),
    })
    local cruxLeft = Controls.texture("E_CRUX_TEXTURE_LEFT", layout, {
        anchors = Ref({
            { point = LEFT, target = layout.element, relativePoint = LEFT, offsetX = 0, offsetY = 0 }
        }),
        height = Ref(32),
        width = Ref(32),
        texture = Ref(Textures.effects.crux),
        color = Ref(Colors["crux"]),
    })
    local cruxRight = Controls.texture("E_CRUX_TEXTURE_RIGHT", layout, {
        anchors = Ref({
            { point = RIGHT, target = layout.element, relativePoint = RIGHT, offsetX = 0, offsetY = 0 }
        }),
        height = Ref(32),
        width = Ref(32),
        texture = Ref(Textures.effects.crux),
        color = Ref(Colors["crux"]),
    })
    local cruxUp = Controls.texture("E_CRUX_TEXTURE_UP", layout, {
        anchors = Ref({
            { point = TOP, target = layout.element, relativePoint = TOP, offsetX = 0, offsetY = 0 }
        }),
        height = Ref(32),
        width = Ref(32),
        texture = Ref(Textures.effects.crux),
        color = Ref(Colors["crux"]),
    })

    EVENT_MANAGER:RegisterForEvent(
        "E_CRUX_EVENT_EFFECT_CHANGED",
        EVENT_EFFECT_CHANGED,
        OnEffectChanged(cruxLeft, cruxRight, cruxUp)
    )
    EVENT_MANAGER:AddFilterForEvent(
        "E_CRUX_EVENT_EFFECT_CHANGED",
        EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, CRUX_ABILITY_ID,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    )
    EVENT_MANAGER:RegisterForEvent(
        "E_CRUX_EVENT_PLAYER_DEAD",
        EVENT_PLAYER_DEAD,
        OnPlayerStateChanged(cruxLeft, cruxRight, cruxUp)
    )
    EVENT_MANAGER:RegisterForEvent(
        "E_CRUX_EVENT_PLAYER_ALIVE",
        EVENT_PLAYER_ALIVE,
        OnPlayerStateChanged(cruxLeft, cruxRight, cruxUp)
    )
    EVENT_MANAGER:RegisterForEvent(
        "E_CRUX_EVENT_PLAYER_ACTIVATED",
        EVENT_PLAYER_ACTIVATED,
        OnPlayerStateChanged(cruxLeft, cruxRight, cruxUp)
    )
    EVENT_MANAGER:RegisterForEvent(
        "E_CRUX_EVENT_ZONE_UPDATE",
        EVENT_ZONE_UPDATE,
        OnPlayerStateChanged(cruxLeft, cruxRight, cruxUp)
    )
end

EVENT_MANAGER:RegisterForEvent("E_CRUX", EVENT_ADD_ON_LOADED, Initialize)
