--* use ../root.lua
--* use ./ulfsild.xml
--* use /libs/Controls/basic/texture.lua

E.AimEffects.Ulfsild = {}

E.AimEffects.Ulfsild.defaults = {
    previousBarHas = false,
    currentBarHas = false,
    positioning = "slot"
}

local clone = E.Utils.clone

local logger = Logger("/extensions/AimEffects/effects/ulfsild.lua")

local ULFSILD_CRAFTED_ABILITY_ID = 9
local ULFSILD_ABILITY_IDS = {
    [217528] = true,
    [222285] = true,
    [222678] = true,
    [240148] = true,
    [240149] = true,
    [240150] = true,
}

local function IsUlfsildSkillSlotted()
    for slot = 3, 7 do
        local skillId = GetSlotBoundId(slot)
        logger:info(tostring(slot) .. ": " .. tostring(skillId))
        if skillId and skillId == ULFSILD_CRAFTED_ABILITY_ID then
            return true
        end
    end
    return false
end

local function CreateUlfsild(parent, position, size)
    if ControlsRegistry["E_AIM_EFFECTS_ULFSILD_TEXTURE"] ~= nil then
        return ControlsRegistry["E_AIM_EFFECTS_ULFSILD_TEXTURE"] --[[@as Texture]]
    end
    local ulfsildColor = Ref(Colors["ulfsild"])
    local ulfsild = Controls.texture("E_AIM_EFFECTS_ULFSILD_TEXTURE", parent, {
        params = {
            anchors = Ref({
                { point = position, target = parent.element, relativePoint = position, offsetX = 0, offsetY = 0 }
            }),
            height = Ref(size),
            width = Ref(size),
            texture = Ref(Textures.effects.ulfsild),
        }
    })
    local ulfsildSmoke = Controls.texture("E_AIM_EFFECTS_ULFSILD_TEXTURE_SMOKE", ulfsild, {
        params = {
            hidden = Ref(false),
            anchors = Ref({
                { point = CENTER, target = ulfsild.element, relativePoint = CENTER, offsetX = 0, offsetY = 0 }
            }),
            height = Ref(size * 3),
            width = Ref(size * 3),
            texture = Ref("/art/fx/texture/smoke_billowy_6x6.dds"),
            color = ulfsildColor,
        }
    })
    local ulfsildSmokeTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual(
        "E_AIM_EFFECTS_ULFSILD_SMOKE_ANIMATION",
        ulfsildSmoke.element
    )
    ulfsild.element:SetHandler("OnHidden", function()
        ulfsildSmokeTimeline:Stop()
    end)
    ulfsild.element:SetHandler("OnShow", function()
        ulfsildSmokeTimeline:PlayFromStart()
    end)
    local ulfsildGlow = Controls.texture("E_AIM_EFFECTS_ULFSILD_TEXTURE_GLOW", ulfsild, {
        params = {
            hidden = Ref(false),
            anchors = Ref({
                { point = CENTER, target = ulfsild.element, relativePoint = CENTER, offsetX = 0, offsetY = 0 }
            }),
            height = Ref(size / 2 * 3),
            width = Ref(size / 2 * 3),
            texture = Ref("/art/fx/texture/lensflares_02_2x2.dds"),
            color = ulfsildColor,
        }
    })
    ulfsildGlow.element:SetTextureCoords(0, 0.5, 0, 0.5)
    return ulfsild
end

local function OnPlayerStateChanged(ulfsild)
    return function()
        for i = 1, GetNumBuffs("player") do
            local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
            if ULFSILD_ABILITY_IDS[abilityId] == true then
                ulfsild.params.hidden:set(false)
                return
            end
        end
        ulfsild.params.hidden:set(true)
    end
end

local function Unregister()
    if ControlsRegistry["E_AIM_EFFECTS_ULFSILD_TEXTURE"] ~= nil then
        ControlsRegistry["E_AIM_EFFECTS_ULFSILD_TEXTURE"].element:SetHidden(true)
    end
    EVENT_MANAGER:UnregisterForEvent("E_AIM_EFFECTS_ULFSILD_EVENT_EFFECT_CHANGED", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("E_AIM_EFFECTS_ULFSILD_EVENT_PLAYER_DEAD", EVENT_PLAYER_DEAD)
    EVENT_MANAGER:UnregisterForEvent("E_AIM_EFFECTS_ULFSILD_EVENT_PLAYER_ALIVE", EVENT_PLAYER_ALIVE)
    EVENT_MANAGER:UnregisterForEvent("E_AIM_EFFECTS_ULFSILD_EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent("E_AIM_EFFECTS_ULFSILD_EVENT_ZONE_UPDATE", EVENT_ZONE_UPDATE)
end

local function Reload(vars, parent)
    Unregister()
    if (not vars.previousBarHas) and (not vars.currentBarHas) then
        return
    end
    if vars.positioning == "slot" then
        local ulfsild = CreateUlfsild(parent, TOP, 32)
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_ULFSILD_EVENT_EFFECT_CHANGED",
            EVENT_EFFECT_CHANGED,
            function(_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId, _)
                if ULFSILD_ABILITY_IDS[abilityId] ~= true then
                    return
                end
                if changeType == EFFECT_RESULT_FADED then
                    ulfsild.params.hidden:set(true)
                else
                    ulfsild.params.hidden:set(false)
                end
            end
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_ULFSILD_EVENT_PLAYER_DEAD",
            EVENT_PLAYER_DEAD,
            OnPlayerStateChanged(ulfsild)
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_ULFSILD_EVENT_PLAYER_ALIVE",
            EVENT_PLAYER_ALIVE,
            OnPlayerStateChanged(ulfsild)
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_ULFSILD_EVENT_PLAYER_ACTIVATED",
            EVENT_PLAYER_ACTIVATED,
            OnPlayerStateChanged(ulfsild)
        )
        EVENT_MANAGER:RegisterForEvent(
            "E_AIM_EFFECTS_ULFSILD_EVENT_ZONE_UPDATE",
            EVENT_ZONE_UPDATE,
            OnPlayerStateChanged(ulfsild)
        )
    end
end

function E.AimEffects.Ulfsild.Initialize(vars, parent)
    do
        local has = IsUlfsildSkillSlotted()
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
                local has = skillId == ULFSILD_CRAFTED_ABILITY_ID
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
                local has = IsUlfsildSkillSlotted()
                vars.previousBarHas = vars.currentBarHas
                vars.currentBarHas = has
                Reload(vars, parent)
            end
        end
    )
end
