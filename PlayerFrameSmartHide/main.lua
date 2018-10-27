local function showPlayerFrame()
    PlayerFrame:SetAlpha(1);
end

local function hidePlayerFrame()
    PlayerFrame:SetAlpha(0);
end

local function togglePlayerFrame(self, event, ...)
    -- show player frame if player has a target
    if UnitExists("target") then return showPlayerFrame(); end

    -- show player frame if player is in combat
    if UnitAffectingCombat("player") then return showPlayerFrame(); end

    -- show player frame if player health is < 100%
    if UnitHealth("player") < UnitHealthMax("player") then return showPlayerFrame(); end

    -- otherwise, hide the player frame
    return hidePlayerFrame();
end

-- addon entry point
local mainFrame = CreateFrame("FRAME", "pfshMain");
mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
mainFrame:RegisterEvent("PLAYER_LEAVING_WORLD");
mainFrame:RegisterEvent("PLAYER_ENTER_COMBAT");
mainFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
mainFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
mainFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
mainFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
mainFrame:RegisterUnitEvent("UNIT_HEALTH", "player");
mainFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player");
mainFrame:SetScript("OnEvent", togglePlayerFrame);
