local E, L, V, P, G = unpack(ElvUI)
local S, AS = E:GetModule('Skins'), E:GetModule('AddOnSkins')
local _G, ipairs, strfind, unpack = _G, ipairs, strfind, unpack

if not AS:IsAddonLODorEnabled('AwesomeCVar') then return end

local sections = { "Nameplates", "Camera", "Interaction", "Other" }

local function HandleMiniCheck(checkbox, region)
    checkbox:Size(16)
    region:SetTexture(E.Media.Textures.Melli)
    region:SetVertexColor(unpack(E.media.rgbvaluecolor))
end

local function HandleCheckBox(cb)
    S:ForEachCheckboxTextureRegion(cb, HandleMiniCheck)
end

S:AddCallbackForAddon('AwesomeCVar', 'AwesomeCVar', function()
    if not E.private.addOnSkins.AwesomeCVar then return end

    local frame = _G.AwesomeCVarFrame
    frame:StripTextures()
    frame:CreateBackdrop('Transparent')

    S:SetUIPanelWindowInfo(frame, 'width')
    S:SetBackdropHitRect(frame)
    S:HandleCloseButton(_G.AwesomeCVarFrameClose, frame.backdrop)

    S:HandleButton(_G.AwesomeCVarDefaultsButton)
    S:HandleButton(_G.AwesomeCVarOkayButton)
    S:HandleButton(_G.AwesomeCVarCloseButton)

    -- Panels, Tabs, Scrollbars, and ScrollFrames
    for _, name in ipairs(sections) do
        local panel = _G["AwesomeCVarFramePanel_"..name]
        if panel then panel:SetTemplate('Transparent') end

        local tab = _G["AwesomeCVarFrame_"..name.."Tab"]
        if tab then
            S:HandleTab(tab, nil, 'Transparent')
            tab:Height(tab:GetHeight() + 4)
        end

        local scrollbar = _G["AwesomeCVarScrollFrame_"..name.."ScrollBar"]
        if scrollbar then
            S:HandleScrollBar(scrollbar)
        end

        local scrollFrame = _G["AwesomeCVarScrollFrame_"..name]
        if scrollFrame then
            local content = scrollFrame:GetScrollChild()
            if content then
                for _, child in ipairs({ content:GetChildren() }) do
                    for _, sub in ipairs({ child:GetChildren() }) do
                        local t, subName = sub:GetObjectType(), sub:GetName()
                        if t == 'CheckButton' then
                            if strfind(subName, 'Radio') then
                                S:HandleRadioButton(sub)
                            else
                                HandleCheckBox(sub)
                                S:HandleButton(sub)
                                S:SetBackdropBorderColor(sub)
                            end
                        elseif t == 'Button' then
                            S:HandleButton(sub)
                        elseif t == 'Slider' then
                            S:HandleSliderFrame(sub)
                        end
                    end
                end
            end
        end
    end

    -- Popups
    for _, popup in ipairs({
        _G.AwesomeCVarReloadPopup,
        _G.AwesomeCVarDefaultConfirmationPopup
    }) do
        if popup then
            popup:StripTextures()
            popup:SetTemplate('Transparent')
            for _, child in ipairs({ popup:GetChildren() }) do
                if child:GetObjectType() == 'Button' then
                    S:HandleButton(child)
                end
            end
        end
    end
end)
