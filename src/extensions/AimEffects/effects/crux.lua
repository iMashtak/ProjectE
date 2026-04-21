--* use ../root.lua
--* use ./crux.xml
--* use /libs/Controls/basic/texture.lua

E.AimEffects.Crux = {}

E.AimEffects.Crux.defaults = {
    previousBarHas = false,
    currentBarHas = false,
    positioning = "bar" -- options: slot, bar
}

local clone = E.Utils.clone

local CRUX_ABILITY_ID = 184220
local CRUX_GENERATION_SKILLS = {
    [183165] = true, -- Runic Jolt
    [183430] = true, -- Runic Sunder
    [186531] = true, -- Runic Embrace
    [185908] = true, -- Cruxweaver Armor

    [186452] = true, -- Tome-Bearer's Inspiration
    [185842] = true, -- Inspired Scholarship
    [183047] = true, -- Recuperative Treatise
    [183006] = true, -- Cephaliarch's Flail
    [185794] = true, -- Runeblades
    [185803] = true, -- Writhing Runeblades
    [182977] = true, -- Escalating Runeblades

    [183261] = true, -- Runemend
    [186189] = true, -- Evolving Runemend
    [186191] = true, -- Audacious Runemend
    [183542] = true, -- Apocryphal Gate
    [186211] = true, -- Fleet-Footed Gate
    [186220] = true, -- Passage Between Worlds
}

local function IsCruxGenerationSkillSlotted()
    for slot = 3, 7 do
        local skillId = GetSlotBoundId(slot)
        if skillId and skillId ~= 0 and CRUX_GENERATION_SKILLS[skillId] == true then
            return true
        end
    end
    return false
end

--#region triangle

---@param cruxLeft Texture
---@param cruxRight Texture
---@param cruxUp Texture
---@param stackCount integer
local function SetCruxesTriangle(cruxLeft, cruxRight, cruxUp, stackCount)
    if stackCount == 0 then
        cruxLeft.params.hidden:set(true)
        cruxRight.params.hidden:set(true)
        cruxUp.params.hidden:set(true)
    end
    if stackCount == 1 then
        cruxLeft.params.hidden:set(false)
        cruxRight.params.hidden:set(true)
        cruxUp.params.hidden:set(true)
    end
    if stackCount == 2 then
        cruxLeft.params.hidden:set(false)
        cruxRight.params.hidden:set(false)
        cruxUp.params.hidden:set(true)
    end
    if stackCount == 3 then
        cruxLeft.params.hidden:set(false)
        cruxRight.params.hidden:set(false)
        cruxUp.params.hidden:set(false)
    end
end

---@param cruxLeft Texture
---@param cruxRight Texture
---@param cruxUp Texture
---@return function
local function OnEffectChangedTriangle(cruxLeft, cruxRight, cruxUp)
    return function(_, changeType, _, _, _, _, _, stackCount)
        if changeType == EFFECT_RESULT_FADED then
            SetCruxesTriangle(cruxLeft, cruxRight, cruxUp, 0)
        else
            SetCruxesTriangle(cruxLeft, cruxRight, cruxUp, stackCount)
        end
    end
end

---@param cruxLeft Texture
---@param cruxRight Texture
---@param cruxUp Texture
---@return function
local function OnPlayerStateChangedTriangle(cruxLeft, cruxRight, cruxUp)
    return function()
        for i = 1, GetNumBuffs("player") do
            local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
            if abilityId == CRUX_ABILITY_ID then
                SetCruxesTriangle(cruxLeft, cruxRight, cruxUp, stackCount)
                return
            end
        end
        SetCruxesTriangle(cruxLeft, cruxRight, cruxUp, 0)
    end
end

---@param layout Layout
---@param suffix string
---@param position any
---@param size integer
---@return Texture
local function CreateCrux(layout, suffix, position, size)
    if ControlsRegistry["E_AIM_EFFECTS_CRUX_TEXTURE_" .. suffix] ~= nil then
        return ControlsRegistry["E_AIM_EFFECTS_CRUX_TEXTURE_" .. suffix] --[[@as Texture]]
    end
    local cruxColor = Ref(Colors["crux"])
    local crux = Controls.texture("E_AIM_EFFECTS_CRUX_TEXTURE_" .. suffix, layout, {
        params = {
            anchors = Ref({
                { point = position, target = layout.element, relativePoint = position, offsetX = 0, offsetY = 0 }
            }),
            height = Ref(size),
            width = Ref(size),
            texture = Ref(Textures.effects.crux),
            color = cruxColor,
        }
    })
    local cruxSmoke = Controls.texture("E_AIM_EFFECTS_CRUX_TEXTURE_SMOKE_" .. suffix, crux, {
        params = {
            hidden = Ref(false),
            anchors = Ref({
                { point = CENTER, target = crux.element, relativePoint = CENTER, offsetX = 0, offsetY = 0 }
            }),
            height = Ref(size * 3),
            width = Ref(size * 3),
            texture = Ref("/art/fx/texture/smoke_billowy_6x6.dds"),
            color = cruxColor,
        }
    })
    local cruxSmokeTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual(
        "E_AIM_EFFECTS_CRUX_SMOKE_ANIMATION",
        cruxSmoke.element
    )
    crux.element:SetHandler("OnHidden", function()
        cruxSmokeTimeline:Stop()
    end)
    crux.element:SetHandler("OnShow", function()
        cruxSmokeTimeline:PlayFromStart()
    end)
    local cruxGlow = Controls.texture("E_AIM_EFFECTS_CRUX_TEXTURE_GLOW_" .. suffix, crux, {
        params = {
            hidden = Ref(false),
            anchors = Ref({
                { point = CENTER, target = crux.element, relativePoint = CENTER, offsetX = 0, offsetY = 0 }
            }),
            height = Ref(size / 2 * 3),
            width = Ref(size / 2 * 3),
            texture = Ref("/art/fx/texture/lensflares_02_2x2.dds"),
            color = cruxColor,
        }
    })
    cruxGlow.element:SetTextureCoords(0, 0.5, 0, 0.5)
    return crux
end

--#endregion triangle

--#region progress

---@param bar Texture
---@param maxWidth integer
---@param stackCount integer
local function SetCruxesProgress(bar, maxWidth, stackCount)
    if stackCount == 0 then
        bar.params.width:set(0)
    else
        local targetWidth = maxWidth / 3 * stackCount
        bar.params.width:set(targetWidth)
    end
end

---@param bar Texture
---@param maxWidth integer
---@return function
local function OnEffectChangedProgress(bar, maxWidth)
    return function(_, changeType, _, _, _, _, _, stackCount)
        if changeType == EFFECT_RESULT_FADED then
            SetCruxesProgress(bar, maxWidth, 0)
        else
            SetCruxesProgress(bar, maxWidth, stackCount)
        end
    end
end

---@param bar Texture
---@param maxWidth integer
---@return function
local function OnPlayerStateChangedProgress(bar, maxWidth)
    return function()
        for i = 1, GetNumBuffs("player") do
            local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
            if abilityId == CRUX_ABILITY_ID then
                SetCruxesProgress(bar, maxWidth, stackCount)
                return
            end
        end
        SetCruxesProgress(bar, maxWidth, 0)
    end
end

local function CreateCruxBarControl(parent)
    if ControlsRegistry["E_AIM_EFFECTS_CRUX_PROGRESS_BAR"] ~= nil then
        ControlsRegistry["E_AIM_EFFECTS_CRUX_PROGRESS_BAR"].element:SetHidden(false)
        return
            ControlsRegistry["E_AIM_EFFECTS_CRUX_PROGRESS_BAR"],
            ControlsRegistry["E_AIM_EFFECTS_CRUX_TEXTURE_PROGRESS"] --[[@as Texture]],
            ControlsRegistry["E_AIM_EFFECTS_CRUX_TEXTURE_BAR"] --[[@as Texture]]
    end
    local size = 20
    local e = WINDOW_MANAGER:CreateControl("E_AIM_EFFECTS_CRUX_PROGRESS_BAR", parent.element, CT_CONTROL)
    e:SetHidden(false)
    e:SetWidth(parent.element:GetWidth())
    e:SetHeight(size / 2 * 3)
    e:ClearAnchors()
    e:SetAnchor(BOTTOMLEFT, parent.element, TOPLEFT, 0, 0)
    local container = { element = e }
    ControlsRegistry["E_AIM_EFFECTS_CRUX_PROGRESS_BAR"] = container
    local crux = CreateCrux(container, "PROGRESS", LEFT, size)
    crux.params.hidden:set(false)
    local totalBarColor = clone(Colors["black"])
    totalBarColor.a = 0.3
    local totalBar = Controls.texture("E_AIM_EFFECTS_CRUX_TEXTURE_TOTAL_BAR", container, {
        params = {
            hidden = Ref(false),
            anchors = Ref({
                { point = LEFT, target = crux.element, relativePoint = RIGHT, offsetX = 0, offsetY = 0 }
            }),
            height = Ref(12),
            width = Ref(container.element:GetWidth() - crux.element:GetWidth()),
            color = Ref(totalBarColor),
            texture = Ref("/ProjectE/assets/bar_grainy.dds")
        }
    })
    local bar = Controls.texture("E_AIM_EFFECTS_CRUX_TEXTURE_BAR", container, {
        params = {
            hidden = Ref(false),
            anchors = Ref({
                { point = LEFT, target = crux.element, relativePoint = RIGHT, offsetX = 0, offsetY = 0 }
            }),
            height = Ref(12),
            width = Ref(0),
            color = Ref(Colors["crux"]),
            texture = Ref("/ProjectE/assets/bar_grainy.dds")
        }
    })
    return container, crux, bar
end

--#endregion progress

local function Unregister()
    if ControlsRegistry["E_AIM_EFFECTS_CRUX_PROGRESS_BAR"] ~= nil then
        ControlsRegistry["E_AIM_EFFECTS_CRUX_PROGRESS_BAR"].element:SetHidden(true)
    end
    if ControlsRegistry["E_AIM_EFFECTS_CRUX_TEXTURE_UP"] ~= nil then
        ControlsRegistry["E_AIM_EFFECTS_CRUX_TEXTURE_UP"].element:SetHidden(true)
    end
    if ControlsRegistry["E_AIM_EFFECTS_CRUX_TEXTURE_LEFT"] ~= nil then
        ControlsRegistry["E_AIM_EFFECTS_CRUX_TEXTURE_LEFT"].element:SetHidden(true)
    end
    if ControlsRegistry["E_AIM_EFFECTS_CRUX_TEXTURE_RIGHT"] ~= nil then
        ControlsRegistry["E_AIM_EFFECTS_CRUX_TEXTURE_RIGHT"].element:SetHidden(true)
    end
    EVENT_MANAGER:UnregisterForEvent("E_AIM_EFFECTS_CRUX_EVENT_EFFECT_CHANGED", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("E_AIM_EFFECTS_CRUX_EVENT_PLAYER_DEAD", EVENT_PLAYER_DEAD)
    EVENT_MANAGER:UnregisterForEvent("E_AIM_EFFECTS_CRUX_EVENT_PLAYER_ALIVE", EVENT_PLAYER_ALIVE)
    EVENT_MANAGER:UnregisterForEvent("E_AIM_EFFECTS_CRUX_EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent("E_AIM_EFFECTS_CRUX_EVENT_ZONE_UPDATE", EVENT_ZONE_UPDATE)
end

local function Reload(vars, parent)
    Unregister()
    if (not vars.previousBarHas) and (not vars.currentBarHas) then
        return
    end
    if vars.positioning == "slot" then
        local cruxLeft = CreateCrux(parent, "LEFT", LEFT, 32)
        local cruxRight = CreateCrux(parent, "RIGHT", RIGHT, 32)
        local cruxUp = CreateCrux(parent, "UP", TOP, 32)
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_EFFECT_CHANGED",
            EVENT_EFFECT_CHANGED,
            OnEffectChangedTriangle(cruxLeft, cruxRight, cruxUp)
        )
        EVENT_MANAGER:AddFilterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_EFFECT_CHANGED",
            EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, CRUX_ABILITY_ID,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_PLAYER_DEAD",
            EVENT_PLAYER_DEAD,
            OnPlayerStateChangedTriangle(cruxLeft, cruxRight, cruxUp)
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_PLAYER_ALIVE",
            EVENT_PLAYER_ALIVE,
            OnPlayerStateChangedTriangle(cruxLeft, cruxRight, cruxUp)
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_PLAYER_ACTIVATED",
            EVENT_PLAYER_ACTIVATED,
            OnPlayerStateChangedTriangle(cruxLeft, cruxRight, cruxUp)
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_ZONE_UPDATE",
            EVENT_ZONE_UPDATE,
            OnPlayerStateChangedTriangle(cruxLeft, cruxRight, cruxUp)
        )
    elseif vars.positioning == "bar" then
        local container, crux, bar = CreateCruxBarControl(parent)
        local maxWidth = container.element:GetWidth() - crux.element:GetWidth()
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_EFFECT_CHANGED",
            EVENT_EFFECT_CHANGED,
            OnEffectChangedProgress(bar, maxWidth)
        )
        EVENT_MANAGER:AddFilterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_EFFECT_CHANGED",
            EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, CRUX_ABILITY_ID,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_PLAYER_DEAD",
            EVENT_PLAYER_DEAD,
            OnPlayerStateChangedProgress(bar, maxWidth)
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_PLAYER_ALIVE",
            EVENT_PLAYER_ALIVE,
            OnPlayerStateChangedProgress(bar, maxWidth)
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_PLAYER_ACTIVATED",
            EVENT_PLAYER_ACTIVATED,
            OnPlayerStateChangedProgress(bar, maxWidth)
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_CRUX_EVENT_ZONE_UPDATE",
            EVENT_ZONE_UPDATE,
            OnPlayerStateChangedProgress(bar, maxWidth)
        )
    end
end

function E.AimEffects.Crux.Initialize(vars, parent)
    do
        local has = IsCruxGenerationSkillSlotted()
        vars.currentBarHas = has
    end
    Reload(vars, parent)
    ACTION_BAR_ASSIGNMENT_MANAGER:RegisterCallback(
        "SlotUpdated",
        function(_, slotIndex, _)
            if slotIndex < 3 or slotIndex > 7 then
                return
            end
            zo_callLater(function()
                local skillId = GetSlotBoundId(slotIndex)
                local has = CRUX_GENERATION_SKILLS[skillId] == true
                vars.currentBarHas = has
                Reload(vars, parent)
            end, 1000)
        end
    )
    EVENT_MANAGER:RegisterForEvent(
        "E_AIM_EFFECTS_CRUX_EVENT_ACTION_SLOTS_FULL_UPDATE",
        EVENT_ACTION_SLOTS_FULL_UPDATE,
        function(_, isHotbarSwap)
            if isHotbarSwap then
                local has = IsCruxGenerationSkillSlotted()
                vars.previousBarHas = vars.currentBarHas
                vars.currentBarHas = has
                Reload(vars, parent)
            end
        end
    )
end
