--* use /libs/Controls/ref.lua
--* use /libs/Controls/layout.lua

local function OnTrigger()
    d("triggered")
    local layout = Controls.layout("E_WINDOW", {
        hidden = Ref(false),
        dimensions = Ref({x = 100, y = 100})
    })
    layout.element:ClearAnchors()
    layout.element:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    layout.element:SetHidden(false)
    d("window created")

    local button = WINDOW_MANAGER:CreateControl("E_BUTTON", layout.element, CT_TEXTURE)
    button:SetDimensions(100, 100)
    button:ClearAnchors()
    button:SetAnchor(CENTER, layout.element, CENTER, 0, 0)
    button:SetTexture("/esoui/art/cadwell/checkboxicon_checked.dds")
    button:SetHidden(false)
    button:SetMouseEnabled(true)
    button:SetHandler(
        "OnMouseDown",
        function(self, button, ctrl, alt, shift)
            d("clicked")
            layout.element.SetHidden(true)
        end
    )
end

local function Initialize(eventCode, addOnName)
    if addOnName ~= "ProjectE" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("E_ControlsSample", EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS["/econtrolssample"] = OnTrigger
end

EVENT_MANAGER:RegisterForEvent("E_ControlsSample", EVENT_ADD_ON_LOADED, Initialize)
