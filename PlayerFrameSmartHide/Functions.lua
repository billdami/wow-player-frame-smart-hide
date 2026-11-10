local addonName, addon = ...;
local P = "player";
local mouseoverTicker;

local function isInstanced()
    local inInstance, instanceType = IsInInstance()
    
    if inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "pvp" or instanceType == "arena" or instanceType == "scenario") then
        return true;
    else
        return false;
    end
end

local function getAlphaForHealthAndPowerThresholds()
    local hThreshold = PfshOptions["health"];
    local pThreshold = PfshOptions["power"];
    local hiddenAlpha = PfshOptions["opacity"] or 0;
    local newAlpha = hiddenAlpha;

    if addon.isClassic() then
        if pThreshold then
            local power = UnitPower(P);
            local maxPower = UnitPowerMax(P);
            local pct = (power / maxPower) * 100;
            local powerId, powerType = UnitPowerType(P);
            local doesDecay = addon.decayPowerTypes[powerType];
            if (doesDecay and pct > pThreshold) or (not doesDecay and pct < pThreshold) then
                return 1;
            end
        end

        if hThreshold then
            local hp = UnitHealth(P);
            local maxHP = UnitHealthMax(P);
            local pct = (hp / maxHP) * 100;
            if pct < hThreshold then
               return 1;
            end
        end

        return hiddenAlpha;
    end

    local newPowerAlpha = hiddenAlpha;

    local hideWhenFullCurve = C_CurveUtil.CreateCurve();
    hideWhenFullCurve:SetType(Enum.LuaCurveType.Step);
    hideWhenFullCurve:AddPoint(0.0, 1);
    hideWhenFullCurve:AddPoint(1.0, hiddenAlpha);

    local hideWhenEmptyCurve = C_CurveUtil.CreateCurve();
    hideWhenEmptyCurve:SetType(Enum.LuaCurveType.Step);
    hideWhenEmptyCurve:AddPoint(0.0, hiddenAlpha);
    hideWhenEmptyCurve:AddPoint(1.0, 1);

    if pThreshold then
        local powerId, powerType = UnitPowerType(P);
        local doesDecay = addon.decayPowerTypes[powerType];
        local pCurve = doesDecay and hideWhenEmptyCurve or hideWhenFullCurve;
        newPowerAlpha = UnitPowerPercent(P, nil, false, pCurve)
    end

    if hThreshold then
        newAlpha = UnitHealthPercent(P, true, hideWhenFullCurve);
    end

    return newAlpha, newPowerAlpha;
end

local function isMouseOverPlayerFrame()
    local mouseover = PfshOptions["mouseover"] and true or false;
    if mouseover and PlayerFrame:IsMouseOver() then
        return true;
    else
        return false;
    end
end

local function isFrameVisible(frame)
    return not frame or frame:IsVisible();
end


local function setPlayerFrameInteractivity()
    local interactive = PfshOptions["interactive"] and true or false;

    if not InCombatLockdown() then
        -- TODO not sure if IsVisible() will work with tainted values?
        local isVisible = isFrameVisible(PlayerFrame) and isFrameVisible(PlayerFrame.PlayerFrameContainer) and isFrameVisible(PlayerFrame.PlayerFrameContent);

        if (isVisible or interactive) and not PlayerFrame:IsMouseEnabled() then
            PlayerFrame:EnableMouse(true);
        else
            PlayerFrame:EnableMouse(false);
        end
    end
end

local function getPlayerFrameAlpha()
    -- show the player frame if player is in an instance
    if PfshOptions["instance"] and isInstanced() then return 1; end

    -- show player frame if player has a target
    if PfshOptions["target"] and UnitExists("target") then return 1; end

    -- show player frame if player is in combat
    if InCombatLockdown() or UnitAffectingCombat(P) then return 1; end

    -- show player frame if it is moused over
    if isMouseOverPlayerFrame() then return 1; end

    -- get the alpha based on health and power thresholds
    return getAlphaForHealthAndPowerThresholds()
end

local function updatePlayerFrame(event)
    if not PfshOptions or not PlayerFrame then return; end

    local newAlpha, newPowerAlpha = getPlayerFrameAlpha()
    local childAlpha = newPowerAlpha ~= nil and newPowerAlpha or 1;

    PlayerFrame:SetAlpha(newAlpha);

    if PlayerFrame.PlayerFrameContainer then 
        PlayerFrame.PlayerFrameContainer:SetAlpha(newPowerAlpha);
    else if PlayerFrame.PlayerFrameContent then
        PlayerFrame.PlayerFrameContent:SetAlpha(newPowerAlpha);
    end

    setPlayerFrameInteractivity();
end

addon.stopMouseoverTicker = function()
    if mouseoverTicker then
        mouseoverTicker:Cancel();
        mouseoverTicker = nil;
    end
end

addon.togglePlayerFrame = function(event)
    if not PfshOptions or not PlayerFrame then return; end

    updatePlayerFrame(event);

    if PfshOptions["mouseover"] then
        if not mouseoverTicker then
            mouseoverTicker = C_Timer.NewTicker(0.10, function() updatePlayerFrame("MOUSEOVER"); end);
        end
    else
        addon.stopMouseoverTicker();
    end
end

addon.isClassic = function() 
    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return true; end
	if WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then return true; end
	if WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then return true; end
	if WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then return true; end
	if WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then return true; end
	return false;
end
