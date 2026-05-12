local E, L, V, P, G = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')
local _G = _G
local ipairs = ipairs
local strfind = strfind
local unpack = unpack

if not AS:IsAddonLODorEnabled('AwesomeCVar') then return end

local sections = { 'Nameplates', 'Camera', 'Interaction', 'Text to Speech', 'Other' }

local function HandleMiniCheck(checkbox, region)
    checkbox:Size(16)
    region:SetTexture(E.Media.Textures.Melli)
    region:SetVertexColor(unpack(E.media.rgbvaluecolor))
end

local function HandleCheckBox(cb)
    S:ForEachCheckboxTextureRegion(cb, HandleMiniCheck)
end

-- Skins a single widget; returns true if it handled it
local function SkinWidget(widget)
    local t = widget:GetObjectType()
    local wName = widget:GetName()

    if t == 'CheckButton' then
        if wName and strfind(wName, 'Radio') then
            S:HandleRadioButton(widget)
        else
            HandleCheckBox(widget)
            S:HandleButton(widget)
            S:SetBackdropBorderColor(widget)
        end
        return true
    elseif t == 'Button' then
        S:HandleButton(widget)
        return true
    elseif t == 'Slider' then
        S:HandleSliderFrame(widget)
        return true
    elseif t == 'Frame' and wName and strfind(wName, 'Dropdown') then
        -- UIDropDownMenuTemplate frame: e.g. AwesomeCVar_ttsVoiceDropdown
		    local dd = _G['AwesomeCVar_ttsVoiceDropdown']
			if dd then
				dd:StripTextures()
				if not dd.backdrop then
					dd:CreateBackdrop('Transparent')
					dd.backdrop:Point('TOPLEFT', 20, -4)
					dd.backdrop:Point('BOTTOMRIGHT', -6, 4)
				end
				local ddBtn = _G['AwesomeCVar_ttsVoiceDropdownButton']
				if ddBtn and not ddBtn.isSkinned then
					ddBtn:ClearAllPoints()
					ddBtn:Point('RIGHT', dd, 'RIGHT', -10, 0)
					S:HandleNextPrevButton(ddBtn, 'down')
				end
				local ddText = _G['AwesomeCVar_ttsVoiceDropdownText']
				if ddText then
					ddText:ClearAllPoints()
					if ddBtn then
						ddText:Point('RIGHT', ddBtn, 'LEFT', -2, 0)
					end
				end
			end
        return true
    end
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

    -- Hook dropdown list popup skinning globally (only needs calling once)
    S:SkinDropDownMenu('DropDownList')

    for _, name in ipairs(sections) do
        local panel = _G['AwesomeCVarFramePanel_'..name]
        if panel then panel:SetTemplate('Transparent') end

        local tab = _G['AwesomeCVarFrame_'..name..'Tab']
        if tab then
            S:HandleTab(tab, nil, 'Transparent')
            tab:Height(tab:GetHeight() + 4)
        end

        local scrollbar = _G['AwesomeCVarScrollFrame_'..name..'ScrollBar']
        if scrollbar then S:HandleScrollBar(scrollbar) end

        local scrollFrame = _G['AwesomeCVarScrollFrame_'..name]
        if scrollFrame then
            local content = scrollFrame:GetScrollChild()
            if content then
                for _, child in ipairs({ content:GetChildren() }) do   -- child = control frame
                    for _, sub in ipairs({ child:GetChildren() }) do   -- sub = widgetFrame
                        if not SkinWidget(sub) and sub:GetObjectType() == 'Frame' then
                            for _, widget in ipairs({ sub:GetChildren() }) do  -- widget = actual widget
                                SkinWidget(widget)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Popups
    for _, popup in ipairs({
        _G.AwesomeCVarReloadPopup,
        _G.AwesomeCVarDefaultConfirmationPopup,
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