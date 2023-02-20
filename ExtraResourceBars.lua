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

function ERB_Load()
    
    local hp = CreateBar("erb_hp", 1)
    local pp = CreateBar("erb_pp", 2)
    
    local dummyFrame = CreateFrame("Frame", nil)
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


        local unitPower, maxPower
        for k,v in pairs(ERB_options) do

            if(v.hide)then
                v.frame:Hide()
            end

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
                _G[k]:Hide()

                -- Fixes added new value
                if(not(ERB_options[k]['fade_in_time']))then
                    ERB_options[k]['fade_in_time'] = 0.2
                end
                if(not(ERB_options[k]['fade_out_time']))then
                    ERB_options[k]['fade_out_time'] = 0.2
                end
            end

        end

    end)
    dummyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

end

