local _G, _ = _G or getfenv()

local function CheckIfInForm()

    local foundShapeshift = false
    
	if(UnitClass("player") == "Druid") then		
		
        local name, active

        for counter = 1, 20, 1 do

            __, name, active = GetShapeshiftFormInfo(counter);

			if(name == nil)then
				break
			end

			if(active)then
                if(
                   name == "Bear Form" or
                   name == "Dire Bear Form" or
                   name == "Cat Form"
                )then
					foundShapeshift = name
                end
            end

        end
    end

    return foundShapeshift
end

local function ERB_fader(frame, fade_time, fade_in)

    if(fade_time == 0)then
        if(fade_in)then
            frame:Show()
        else
            frame:Hide()
        end

        return
    end

    if(fade_in)then
        frame:SetAlpha(0)
        frame.time=0
    else
        frame:SetAlpha(1)
        frame.time=1
    end
    frame:SetScript("OnUpdate", function()
        this.time = this.time + (arg1/fade_time) * (fade_in and 1 or -1)
        this:SetAlpha( this.time)
        if(this.time >= 1 and fade_in)then
            this:SetAlpha(1)
            this:SetScript("OnUpdate", nil)
        elseif(this.time <= 0 and not(fade_in))then
            this:SetAlpha(0)
            this:SetScript("OnUpdate", nil)
            this:Hide()
        end
    end)

end

function CreateBar(name, type)

    local frame
    frame = CreateFrame("Frame", name, UIParent)
    frame:SetPoint("CENTER",0,(1-type)*25)
    frame:SetWidth(120)
    frame:SetHeight(21)
    frame:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    frame:SetFrameStrata("HIGH")

    frame:SetMovable(true)
    frame:EnableMouse()
    frame:SetClampedToScreen(true)
    frame:SetUserPlaced(true)
    frame:RegisterForDrag("LeftButton")

    frame.background = CreateFrame("Frame", name.."_bg", frame)
    frame.background:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame.background:SetFrameStrata("LOW")

    --frame.bar = CreateFrame("Frame", name.."_bar", frame)
    frame.bar = frame:CreateTexture(name.."_bar", "BACKGROUND")
    frame.bar:SetWidth(frame:GetWidth())
    frame.bar:SetHeight(frame:GetHeight()-5)
    frame.bar:SetTexture("Interface\\AddOns\\ExtraResourceBars\\bars\\bar_1")

    frame.text = frame:CreateFontString("","OVERLAY")
    frame.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "")

    frame:SetScript("OnDragStart", function()
        this:StartMoving()
      end)
    frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)

    return frame
end

function ERB_apply_settings(data, frame_name)

    local v = data

    v.frame:Show()
    if(v.hide)then
        v.frame:Hide()
    end

    -- TODO: Make a function of appropiate code and run it in SaveData as well.
    v.frame = _G[frame_name]

    v.frame:SetWidth(v.width)
    v.frame:SetHeight(v.height)

    if(v.under)then
        v.frame:ClearAllPoints()
        v.frame:SetPoint("CENTER", _G[v.under], "CENTER", 0, -(v.height + v.spacing))
        v.frame:EnableMouse(false)
    end

    if(v.barResize == "LEFT")then
        v.frame.bar:SetPoint("LEFT",v.frame,"LEFT",4 + (v.border==4 and -2.5 or 0),0)
    elseif(v.barResize == "RIGHT")then
        v.frame.bar:SetPoint("RIGHT",v.frame,"RIGHT",-4 + (v.border==4 and 2.5 or 0),0)
    elseif(v.barResize == "CENTER")then
        v.frame.bar:SetPoint("CENTER",v.frame,"CENTER",0,0)
    end

    -- Background
    if(v.background)then
        v.frame.background:SetPoint("CENTER",v.frame,"CENTER",0,0)
        v.frame.background:SetWidth(v.frame:GetWidth()-4 + (v.border==4 and 4 or 0) + (v.border==0 and -2 or 0))
        v.frame.background:SetHeight(v.frame:GetHeight()-5 + (v.border==4 and 5 or 0) + (v.border==0 and 2 or 0))
        v.frame.background:SetBackdropColor(unpack(v.backgroundColor))
    end
    -- For border
    if(v.border==0)then
        v.frame:SetBackdrop({
            edgeFile = "",
            edgeSize = 14,
        })
    elseif(v.border==1)then
        v.frame:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 14,
        })
    elseif(v.border==2)then
        v.frame:SetBackdrop({
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 14,
        })
    elseif(v.border==3)then
        v.frame:SetBackdrop({
            edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
            edgeSize = 14,
        })
    elseif(v.border==4)then
        v.frame:SetBackdrop({
            --edgeFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface\\AddOns\\ExtraResourceBars\\border",
            edgeSize = 1.5,
        })
        v.frame:SetBackdropBorderColor(0,0,0,1)
    end

    -- For bar
    v.frame.bar:SetTexture("Interface\\AddOns\\ExtraResourceBars\\bars\\bar_"..v.bar)

    if(v.type==1)then
        unitPower = UnitHealth("player")
        maxPower = UnitHealthMax("player")
    elseif(v.type==2)then
        unitPower = UnitMana("player")
        maxPower = UnitManaMax("player")
    end

    -- gradiant hp
    if(v.type==1 and v.gradiantHP == true)then
        local r,g,b
        local healthPercent = UnitHealth("player") / UnitHealthMax("player");	
        if(healthPercent < 0.5)then
            r = 1
            g = 2*healthPercent
            b = 0
        else
            r = 2*(1 - healthPercent)
            g = 1
            b = 0
        end
        v.frame.bar:SetVertexColor(r, g, b, 1)
    else
        if(v.type==1)then
            v.frame.bar:SetVertexColor(unpack(v.color))
        else
            local form = CheckIfInForm()
            if(form)then
                if(form == "Bear Form" or form == "Dire Bear Form")then
                    v.frame.bar:SetVertexColor(unpack(v.powers.rage))
                elseif(form == "Cat Form")then
                    v.frame.bar:SetVertexColor(unpack(v.powers.energy))
                end
            else
                v.frame.bar:SetVertexColor(unpack(v.powers[v.powers.main]))
            end
        end
    end

    v.frame.bar:SetWidth((v.frame:GetWidth() - 8 + (v.border==4 and 5 or 0)) * (unitPower/maxPower) + 0.000001 )
    if(v.barResize=="CENTER")then
        v.frame.bar:SetTexCoord( (1-(unitPower/maxPower))/2, 1-((1-(unitPower/maxPower))/2) + 0.001, 0, 1)
    elseif(v.barResize=="RIGHT")then
        v.frame.bar:SetTexCoord(1-(unitPower/maxPower) + 0.001, 1, 0, 1)
    else
        v.frame.bar:SetTexCoord(0, (unitPower/maxPower) + 0.001, 0, 1)
    end

    v.frame.bar:SetHeight(v.frame:GetHeight()-5 + (v.border==4 and 3 or 0))
    v.frame.text:SetFont("Fonts\\FRIZQT__.TTF", v.fontSize, "")

    if(v.textAlign == "LEFT")then
        v.frame.text:SetPoint("LEFT",10,0)
    elseif(v.textAlign == "CENTER")then
        v.frame.text:SetPoint("CENTER",0,0)
    elseif(v.textAlign == "RIGHT")then
        v.frame.text:SetPoint("RIGHT",-10,0)
    else
        v.frame.text:SetPoint("CENTER",0,0)
    end

    v.textType = tonumber(v.textType)
    if(v.textType==0)then
        v.frame.text:SetText("")
    elseif(v.textType==1)then
        v.frame.text:SetText(unitPower.." / "..maxPower)
    elseif(v.textType==2)then
        v.frame.text:SetText((string.format("%.0f%%", (unitPower/maxPower)*100)))
    elseif(v.textType==3)then
        v.frame.text:SetText(unitPower.." / "..maxPower.." - "..(string.format("%.0f%%", (unitPower/maxPower)*100)))
    elseif(v.textType==4)then
        v.frame.text:SetText((string.format("%.0f%%", (unitPower/maxPower)*100)) .."  "..unitPower.." / "..maxPower)
    end

    v.frame:SetScript("OnEvent", function()
        
        if(ERB_options[this:GetName()]['only_combat'])then
            -- fade in
            if(event == "PLAYER_REGEN_DISABLED") then
                this:Show()
                ERB_fader(this, ERB_options[this:GetName()]['fade_in_time'], true)
            end
            -- fade out
            if(event == "PLAYER_REGEN_ENABLED")then
                this:Show()
                ERB_fader(this, ERB_options[this:GetName()]['fade_out_time'], false)
            end
        end

        local u = arg1
        local form = false
        if(u == "player")then
            local type = ERB_options[this:GetName()].type
            local textType = ERB_options[this:GetName()].textType
            local unitPower, maxPower, gradiantHP
            if(type==1)then
                gradiantHP = ERB_options[this:GetName()].gradiantHP
                unitPower = UnitHealth("player")
                maxPower = UnitHealthMax("player")
            elseif(type==2)then
                unitPower = UnitMana("player")
                maxPower = UnitManaMax("player")
                form = CheckIfInForm()
                if(form)then
                    if(form == "Bear Form" or form == "Dire Bear Form")then
                        this.bar:SetVertexColor(unpack(ERB_options[this:GetName()].powers.rage))
                    elseif(form == "Cat Form")then
                        this.bar:SetVertexColor(unpack(ERB_options[this:GetName()].powers.energy))
                    end
                else
                    this.bar:SetVertexColor(unpack(ERB_options[this:GetName()].powers[ERB_options[this:GetName()].powers.main]))
                end
            end
            this.bar:SetWidth((this:GetWidth() - 8 + (ERB_options[this:GetName()].border==4 and 5 or 0)) * (unitPower/maxPower) + 0.001)
            if(ERB_options[this:GetName()].barResize=="CENTER")then
                this.bar:SetTexCoord( (1-(unitPower/maxPower))/2, 1-((1-(unitPower/maxPower))/2) + 0.001, 0, 1)
            elseif(ERB_options[this:GetName()].barResize=="RIGHT")then
                this.bar:SetTexCoord(1-(unitPower/maxPower) + 0.001, 1, 0, 1)
            else
                this.bar:SetTexCoord(0, (unitPower/maxPower) + 0.001, 0, 1)
            end

            if(textType==0)then
                this.text:SetText("")
            elseif(textType==1)then
                this.text:SetText(unitPower.." / "..maxPower)
            elseif(textType==2)then
                this.text:SetText((string.format("%.0f%%", (unitPower/maxPower)*100)))
            elseif(textType==3)then
                this.text:SetText(unitPower.." / "..maxPower.."  "..(string.format("%.0f%%", (unitPower/maxPower)*100)))
            elseif(textType==4)then
                this.text:SetText((string.format("%.0f%%", (unitPower/maxPower)*100)) .."  "..unitPower.." / "..maxPower)
            end

            -- gradiant hp
            if(type==1 and gradiantHP == true)then
                local r,g,b
                local healthPercent = UnitHealth("player") / UnitHealthMax("player");	
                if(healthPercent < 0.5)then
                    r = 1
                    g = 2*healthPercent
                    b = 0
                else
                    r = 2*(1 - healthPercent)
                    g = 1
                    b = 0
                end
                this.bar:SetVertexColor(r, g, b, 1)
            end
        end

    end)
    if(v.type==1)then
        v.frame:RegisterEvent("UNIT_HEALTH")
        v.frame:RegisterEvent("UNIT_MAXHEALTH")
    elseif(v.type==2)then
        v.frame:RegisterEvent("UNIT_MANA")
        v.frame:RegisterEvent("UNIT_RAGE")
        v.frame:RegisterEvent("UNIT_MAXRAGE")
        v.frame:RegisterEvent("UNIT_ENERGY")
        v.frame:RegisterEvent("UNIT_MAXENERGY")
        v.frame:RegisterEvent("UNIT_AURA")
    end
    if(v.only_combat)then
        v.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        v.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        _G[frame_name]:Hide()

        -- Fixes added new value
        if(not(ERB_options[frame_name]['fade_in_time']))then
            ERB_options[frame_name]['fade_in_time'] = 0.2
        end
        if(not(ERB_options[frame_name]['fade_out_time']))then
            ERB_options[frame_name]['fade_out_time'] = 0.2
        end
    end

end

function ERB_Load()
    
    local hp = not(_G["erb_hp"]) and CreateBar("erb_hp", 1) or _G["erb_hp"]
    local pp = not(_G["erb_pp"]) and CreateBar("erb_pp", 2) or _G["erb_pp"]
    
    local dummyFrame = not(_G["erb_dummy_frame"]) and CreateFrame("Frame", "erb_dummy_frame") or _G["erb_dummy_frame"]
    dummyFrame:SetScript("OnEvent", function()

        if(not(ERB_options))then
            ERB_options = {
                erb_hp = {
                    frame = hp,
                    hide = false,
                    barResize = "LEFT",
                    width = 124,
                    height = 21,
                    color = {0,1,0},
                    fontSize = 10,
                    textType = 3,
                    textAlign = "CENTER",
                    gradiantHP = true,
                    under = nil,
                    spacing = 0,
                    bar = 4,
                    border = 3,
                    background = true,
                    backgroundColor = {0,0,0,0.35},
                    type = 1,
                    only_combat = false,
                    fade_in_time = 0.2,
                    fade_out_time = 0.2,
                },
                erb_pp = {
                    frame = pp,
                    hide = false,
                    barResize = "LEFT",
                    width = 124,
                    height = 21,
                    powers = {
                        mana = {0.2,0.2,1},
                        rage = {1,0,0},
                        energy = {1,1,0},
                        main = "mana"
                    },
                    fontSize = 10,
                    textType = 1,
                    textAlign = "CENTER",
                    under = "erb_hp",
                    spacing = 1,
                    bar = 4,
                    border = 3,
                    background = true,
                    backgroundColor = {0,0,0,0.45},
                    type = 2,
                    only_combat = false,
                    fade_in_time = 0.2,
                    fade_out_time = 0.2,
                }
            }
        end

        CONFIG_SETTINGS = {
    
            [1] = {"HP - Hide", "hp_hide", ERB_options.erb_hp.hide, false,                           {"erb_hp", "hide"}},
            [2] = {"HP - Bar resize ", "hp_barResize", ERB_options.erb_hp.barResize, "LEFT",         {"erb_hp", "barResize"}},
            [3] = {"HP - Width", "hp_width", ERB_options.erb_hp.width, 124,                          {"erb_hp", "width"}},
            [4] = {"HP - Height", "hp_height", ERB_options.erb_hp.height, 21,                        {"erb_hp", "height"}},
            [5] = {"HP - Color", "hp_color", ERB_options.erb_hp.color, {0, 1, 0, 1},                 {"erb_hp", "color"}, true},
            [6] = {"HP - Font Size", "hp_fontSize", ERB_options.erb_hp.fontSize, 10,                 {"erb_hp", "fontSize"}},
            [7] = {"HP - Text Type", "hp_textType", ERB_options.erb_hp.textType, 3,                  {"erb_hp", "textType"}},
            [8] = {"HP - Text Align", "hp_textAlign", ERB_options.erb_hp.textAlign, "CENTER",        {"erb_hp", "textAlign"}},
            [9] = {"HP - Gradiant HP", "hp_gradiantHP", ERB_options.erb_hp.gradiantHP, true,         {"erb_hp", "gradiantHP"}},
            [10] = {"HP - Spacing", "hp_spacing", ERB_options.erb_hp.spacing, 0,                     {"erb_hp", "spacing"}},
            [11] = {"HP - Bar", "hp_bar", ERB_options.erb_hp.bar, 4,                                 {"erb_hp", "bar"}},
            [12] = {"HP - Border", "hp_border", ERB_options.erb_hp.border, 3,                        {"erb_hp", "border"}},
            [13] = {"HP - Background", "hp_background", ERB_options.erb_hp.background, true,         {"erb_hp", "background"}},
            [14] = {"HP - Background Color", "hp_backgroundColor", ERB_options.erb_hp.backgroundColor, {0,0,0,0.35}, {"erb_hp", "backgroundColor"}, true},
            [15] = {"HP - Only Combat", "hp_only_combat", ERB_options.erb_hp.only_combat, false,     {"erb_hp", "only_combat"}},
            [16] = {"HP - Fade in Time", "hp_fade_in_time", ERB_options.erb_hp.fade_in_time, 0.2,    {"erb_hp", "fade_in_time"}},
            [17] = {"HP - Fade out time", "hp_fade_out_time", ERB_options.erb_hp.fade_out_time, 0.2, {"erb_hp", "fade_out_time"}},

            [18] = {"PP - Hide", "pp_hide", ERB_options.erb_pp.hide, false,                          {"erb_pp", "hide"}},
            [19] = {"PP - Bar resize ", "pp_barResize", ERB_options.erb_pp.barResize, "LEFT",        {"erb_pp", "barResize"}},
            [20] = {"PP - Width", "pp_width", ERB_options.erb_pp.width, 124,                         {"erb_pp", "width"}},
            [21] = {"PP - Height", "pp_height", ERB_options.erb_pp.height, 21,                       {"erb_pp", "height"}},

            [22] = {"PP - Main power", "pp_color_main",   ERB_options.erb_pp.powers.main, "mana",         {"erb_pp", "main", "powers"}},
            [23] = {"PP - Color Mana", "pp_color_mana",   ERB_options.erb_pp.powers.mana, {0.2,0.2,1},    {"erb_pp", "mana", "powers"}, true},
            [24] = {"PP - Color Rage", "pp_color_rage",   ERB_options.erb_pp.powers.rage, {1,0,0,1},      {"erb_pp", "rage", "powers"}, true},
            [25] = {"PP - Color Energy", "pp_color_energy", ERB_options.erb_pp.powers.energy, {1,1,0,1},  {"erb_pp", "energy", "powers"}, true},

            [26] = {"PP - Font Size", "pp_fontSize", ERB_options.erb_pp.fontSize, 10,                {"erb_pp", "fontSize"}},
            [27] = {"PP - Text Type", "pp_textType", ERB_options.erb_pp.textType, 1,                 {"erb_pp", "textType"}},
            [28] = {"PP - Text Align", "pp_textAlign", ERB_options.erb_pp.textAlign, "CENTER",       {"erb_pp", "textAlign"}},
            [29] = {"PP - Align under frame", "pp_under", ERB_options.erb_pp.under, "erb_hp",        {"erb_pp", "under"}},
            [30] = {"PP - Spacing", "pp_spacing", ERB_options.erb_pp.spacing, 1,                     {"erb_pp", "spacing"}},
            [31] = {"PP - Bar", "pp_bar", ERB_options.erb_pp.bar, 4,                                 {"erb_pp", "bar"}},
            [32] = {"PP - Border", "pp_border", ERB_options.erb_pp.border, 3,                        {"erb_pp", "border"}},
            [33] = {"PP - Background", "pp_background", ERB_options.erb_pp.background, true,         {"erb_pp", "background"}},
            [34] = {"PP - Background Color", "pp_backgroundColor", ERB_options.erb_pp.backgroundColor, {0,0,0,0.45}, {"erb_pp", "backgroundColor"}, true},
            [35] = {"PP - Only Combat", "pp_only_combat", ERB_options.erb_pp.only_combat, false,     {"erb_pp", "only_combat"}},
            [36] = {"PP - Fade in Time", "pp_fade_in_time", ERB_options.erb_pp.fade_in_time, 0.2,    {"erb_pp", "fade_in_time"}},
            [37] = {"PP - Fade out time", "pp_fade_out_time", ERB_options.erb_pp.fade_out_time, 0.2, {"erb_pp", "fade_out_time"}},
        }

        local unitPower, maxPower
        for k,v in pairs(ERB_options) do

            ERB_apply_settings(v, k)

        end

    end)
    dummyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- Settings
local CONFIG_FRAME_NAME = "erb_config"
local NR_OF_COLUMNS = 4
local INPUT_HEIGHT = 40
local INPUT_WIDTH = 150
local SPACING_X = 18
local SPACING_Y = 45

local function CustomColorPicker(target_frame)

	function ShowColorPicker(r, g, b, a, changedCallback)
		ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
		ColorPickerFrame.previousValues = {r,g,b,a};
		ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback;
		ColorPickerFrame:SetColorRGB(r,g,b,a);
		ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
		ColorPickerFrame:Show();
	end

	ColorPickerFrame:Show()
	ColorPickerFrame:SetFrameStrata("DIALOG")

	local function myColorCallback(restore)
		local newR, newG, newB, newA;
		if restore then
		 -- The user bailed, we extract the old color from the table created by ShowColorPicker.
		 newR, newG, newB, newA = unpack(restore);
		else
		 -- Something changed
		 newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
		end
		
		-- Update our internal storage.
		r, g, b, a = newR, newG, newB, newA;
		
		-- And update any UI elements that use this color...
        target_frame.r = math.floor(r * 1000 + 0.5) / 1000
        target_frame.g = math.floor(g * 1000 + 0.5) / 1000
        target_frame.b = math.floor(b * 1000 + 0.5) / 1000
        target_frame.a = math.floor(a * 1000 + 0.5) / 1000
        target_frame:SetTextColor(target_frame.r,target_frame.g,target_frame.b,target_frame.a)
        target_frame:SetText("{"..target_frame.r..", "..target_frame.g..", "..target_frame.b..", "..target_frame.a.."}")
	end
	r, g, b, a = 1, 1, 0, 1
	ShowColorPicker(r, g, b, a, myColorCallback);
end

local function CreateInputField(text, name, column, row, data, isColor)
    
    local currentEditBox

    if(not _G[CONFIG_FRAME_NAME..name])then
        currentEditBox = CreateFrame("EditBox", CONFIG_FRAME_NAME.."_"..name, _G[CONFIG_FRAME_NAME], "InputBoxTemplate")
        currentEditBox.text = currentEditBox:CreateFontString("", "OVERLAY");
        currentEditBox:SetScript("OnEnterPressed", function()
          
        end)
    end
    currentEditBox:SetHeight(40)
    currentEditBox:SetWidth(INPUT_WIDTH)
    currentEditBox:SetPoint(
        "TOPLEFT",
        24 + ((INPUT_WIDTH + SPACING_X) * (column)),
        -20 - (row * SPACING_Y)
    )
    currentEditBox:SetAutoFocus(false)
    currentEditBox:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    currentEditBox.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
    currentEditBox.text:SetPoint("TOPLEFT", -3, 4)
    currentEditBox.text:SetText(text)
    if(type(data) == "table")then
        
        local table_string = ""
        for kk,vv in pairs(data)do
            table_string = table_string .. tostring(vv) .. ", "
        end
        table_string =  string.sub(table_string, 1, -3)
        currentEditBox:SetText("{"..table_string.."}")
        currentEditBox:SetTextColor(unpack(data))
    else
        currentEditBox:SetText(tostring(data))
    end

    currentEditBox:Show()
    currentEditBox.text:Show()

    if(isColor)then
        currentEditBox:SetScript("OnMouseUp", function() 
            CustomColorPicker(currentEditBox)
        end)
    end
end

local function SaveData()
    for k,v in pairs(CONFIG_SETTINGS)do

        local frame = _G[CONFIG_FRAME_NAME.."_"..v[2]]
        local input_data = frame:GetText()
        if(input_data == "" or input_data == "nil")then
            input_data = nil
        end

        if(v[6])then
            input_data = loadstring("return " .. input_data)()
            if(v[5][3])then
                ERB_options[v[5][1]][v[5][3]][v[5][2]] = input_data
            else
                ERB_options[v[5][1]][v[5][2]] = input_data
            end
        else
            if(input_data == "false")then
                if(v[5][3])then
                    ERB_options[v[5][1]][v[5][3]][v[5][2]] = false
                else
                    ERB_options[v[5][1]][v[5][2]] = false
                end
            elseif(input_data == "true")then
                if(v[5][3])then
                    ERB_options[v[5][1]][v[5][3]][v[5][2]] = true
                else
                    ERB_options[v[5][1]][v[5][2]] = true
                end
            else
                if(v[5][3])then
                    ERB_options[v[5][1]][v[5][3]][v[5][2]] = tonumber(input_data) or input_data
                else
                    ERB_options[v[5][1]][v[5][2]] = tonumber(input_data) or input_data
                end
            end
        end

    end

    for k,v in pairs(ERB_options) do
        ERB_apply_settings(v, k)
    end
end

local function ResetData()
    for k,v in pairs(CONFIG_SETTINGS)do

        local frame = _G[CONFIG_FRAME_NAME.."_"..v[2]]

        if( type(v[4]) == "table" ) then
            local table_string = ""
            for kk,vv in pairs(v[4])do
                table_string = table_string .. tostring(vv) .. ", "
            end
            table_string =  string.sub(table_string, 1, -3)
            frame:SetText("{"..table_string.."}")
        else
            frame:SetText(tostring(v[4]))
        end

    end
end

-- Generate config frame
SLASH_ERB1 = "/erb"
SlashCmdList["ERB"] = function(self, txt)
    local config_frame
    -- Create config frame if it doesn't exist
    if(not(_G[CONFIG_FRAME_NAME]))then
        
        local count_settings = 0
        for _ in pairs(CONFIG_SETTINGS) do
            count_settings = count_settings + 1
        end

        config_frame = CreateFrame("frame", CONFIG_FRAME_NAME, UIParent)
        config_frame:SetWidth(24*2 + (NR_OF_COLUMNS * INPUT_WIDTH) + (SPACING_X * (NR_OF_COLUMNS - 1)))
        config_frame:SetHeight(40 + ((count_settings/NR_OF_COLUMNS) * INPUT_HEIGHT) + (INPUT_HEIGHT + SPACING_Y))
        config_frame:SetPoint("CENTER", 0, 0)
        config_frame:EnableMouse(true)
        config_frame:SetMovable(true)
        config_frame:RegisterForDrag("LeftButton")
        config_frame:SetScript("OnDragStart", function()
            this:StartMoving()
        end)
        config_frame:SetScript("OnDragStop", function()
            this:StopMovingOrSizing()
        end)

        config_frame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            edgeSize = 24,
            insets={left=8, right=8, top=8, bottom=8}
        })
        config_frame:SetBackdropColor(
            0.4,
            0.4,
            0.4
        )

        local close_button = CreateFrame("Button", CONFIG_FRAME_NAME.."_close_button", config_frame, "UIPanelCloseButton")
        close_button:SetPoint("TOPRIGHT", 7, 7)

        local save_button = CreateFrame("Button", CONFIG_FRAME_NAME.."_save_button", config_frame, "OptionsButtonTemplate")
        save_button:SetPoint("BOTTOMRIGHT", -15, 14)
        save_button:SetText("Save")
        save_button:SetScript("OnClick", function()
            SaveData()
        end)

        local reset_button = CreateFrame("Button", CONFIG_FRAME_NAME.."_reset_button", config_frame, "OptionsButtonTemplate")
        reset_button:SetPoint("BOTTOMLEFT", 15, 14)
        reset_button:SetText("Reset")
        reset_button:SetScript("OnClick", function()
            ResetData()
        end)

        local reload_button = CreateFrame("Button", CONFIG_FRAME_NAME.."_reload_button", config_frame, "OptionsButtonTemplate")
        reload_button:SetPoint("BOTTOMLEFT", 115, 14)
        reload_button:SetText("Reload UI")
        reload_button:SetScript("OnClick", function()
            ReloadUI()
        end)

        local column, row = 0, 0

        for k,v in pairs(CONFIG_SETTINGS) do
            
            CreateInputField(v[1], v[2], column, row, v[3], v[6])

            if(column > (NR_OF_COLUMNS - 2))then
                column = 0
                row = row + 1
            else
                column = column + 1
            end
        end

    else
        _G[CONFIG_FRAME_NAME]:Show()
    end

end
