local addon = {};
local state;
local mainFrame;
local tickers = {};

WOW_PROJECT_ID = 2;
WOW_PROJECT_CLASSIC = 2;
WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5;
WOW_PROJECT_WRATH_CLASSIC = 11;
WOW_PROJECT_CATACLYSM_CLASSIC = 14;
WOW_PROJECT_MISTS_CLASSIC = 19;

function InCombatLockdown() return state.lockdown; end
function UnitAffectingCombat() return state.combat; end
function UnitExists() return state.target; end
function UnitHealth() return state.health; end
function UnitHealthMax() return state.healthMax; end
function UnitPower() return state.power; end
function UnitPowerMax() return state.powerMax; end
function UnitPowerType() return state.powerType; end
function strsplit(delimiter, text)
    return text:match("^([^" .. delimiter .. "]*)" .. delimiter .. "?(.*)$");
end

SlashCmdList = {};
C_Timer = {
    NewTicker = function(interval, callback)
        assert(interval == 0.10);
        local ticker = { callback = callback };
        function ticker:Cancel() self.cancelled = true; end
        tickers[#tickers + 1] = ticker;
        return ticker;
    end
};

function CreateFrame()
    mainFrame = { events = {} };
    function mainFrame:RegisterEvent(event) self.events[event] = true; end
    function mainFrame:RegisterUnitEvent(event, unit) self.events[event] = true; end
    function mainFrame:UnregisterEvent(event) self.events[event] = nil; end
    function mainFrame:SetScript(script, callback)
        assert(script == "OnEvent");
        self.onEvent = callback;
    end
    return mainFrame;
end

PlayerFrame = {};
function PlayerFrame:SetAlpha(alpha) self.alpha = alpha; end
function PlayerFrame:IsMouseEnabled() return self.mouseEnabled; end
function PlayerFrame:EnableMouse(enabled)
    assert(not state.lockdown, "protected mouse change during combat");
    self.mouseEnabled = enabled;
end
function PlayerFrame:IsMouseOver() return state.mouseover; end

local function loadAddonFile(filename)
    assert(loadfile("PlayerFrameSmartHide/" .. filename))("PlayerFrameSmartHide", addon);
end

local function reset()
    if addon.stopMouseoverTicker then addon.stopMouseoverTicker(); end
    state = {
        target = false, 
        combat = false,
        lockdown = false, 
        mouseover = false,
        health = 100,
        healthMax = 100,
        power = 100,
        powerMax = 100,
        powerType = "MANA",
    };
    PfshOptions = { interactive = false, mouseover = false };
    PlayerFrame.mouseEnabled = true;
    PlayerFrame.alpha = nil;
end

local function expectAlpha(alpha)
    addon.togglePlayerFrame();
    assert(PlayerFrame.alpha == alpha, "unexpected player frame visibility");
end

reset();
loadAddonFile("GlobalsClassic.lua");
loadAddonFile("SlashCommands.lua");
loadAddonFile("Functions.lua");
loadAddonFile("Main.lua");

PfshOptions = nil;
mainFrame.onEvent(mainFrame, "ADDON_LOADED", "AnotherAddon");
assert(PfshOptions == nil);
addon.togglePlayerFrame();
assert(PlayerFrame.alpha == nil);
mainFrame.onEvent(mainFrame, "ADDON_LOADED", "PlayerFrameSmartHide");
assert(PfshOptions.interactive == false and PfshOptions.mouseover == false);
assert(PfshOptions ~= addon.defaults.options);
assert(not mainFrame.events.ADDON_LOADED);
assert(PlayerFrame.alpha == nil);
mainFrame.onEvent(mainFrame, "PLAYER_ENTERING_WORLD");
assert(PlayerFrame.alpha == 0);

PfshOptions = { interactive = true };
mainFrame.onEvent(mainFrame, "ADDON_LOADED", "PlayerFrameSmartHide");
assert(PfshOptions.interactive == true and PfshOptions.mouseover == false);

reset();
expectAlpha(0);
state.target = true;
expectAlpha(1);
state.target = false;
state.combat = true;
expectAlpha(1);
state.combat = false;
expectAlpha(0);
state.lockdown = true;
expectAlpha(1);
state.lockdown = false;
expectAlpha(0);

reset();
PfshOptions.mouseover = true;
local tickerCount = #tickers;
for iteration = 1, 10 do addon.togglePlayerFrame(); end
assert(#tickers == tickerCount + 1, "duplicate mouseover tickers");
local ticker = tickers[#tickers];
state.mouseover = true;
ticker.callback();
assert(PlayerFrame.alpha == 1);
state.mouseover = false;
ticker.callback();
assert(PlayerFrame.alpha == 0);
PfshOptions.mouseover = false;
addon.togglePlayerFrame();
assert(ticker.cancelled);
PfshOptions.mouseover = true;
addon.togglePlayerFrame();
mainFrame.onEvent(mainFrame, "PLAYER_LEAVING_WORLD");
assert(tickers[#tickers].cancelled);
mainFrame.onEvent(mainFrame, "PLAYER_ENTERING_WORLD");
assert(not tickers[#tickers].cancelled);

reset();
SlashCmdList.PLAYERFRAMEHIDE("mouseover on");
assert(PfshOptions.mouseover and not tickers[#tickers].cancelled);
SlashCmdList.PLAYERFRAMEHIDE("mouseover off");
assert(not PfshOptions.mouseover and tickers[#tickers].cancelled);
SlashCmdList.PLAYERFRAMEHIDE("interactive on");
assert(PlayerFrame.mouseEnabled);
SlashCmdList.PLAYERFRAMEHIDE("interactive off");
assert(not PlayerFrame.mouseEnabled);
SlashCmdList.PLAYERFRAMEHIDE("health off");
assert(PfshOptions.health == false);
SlashCmdList.PLAYERFRAMEHIDE("health 90");
assert(PfshOptions.health == 90);
SlashCmdList.PLAYERFRAMEHIDE("power off");
assert(PfshOptions.power == false);
SlashCmdList.PLAYERFRAMEHIDE("power 90");
assert(PfshOptions.power == 90);

for _, filename in ipairs({ "GlobalsClassic.lua", "SlashCommands.lua", "Functions.lua", "Main.lua" }) do
    assert(loadfile("PlayerFrameSmartHide/" .. filename));
end

print("PASS: initialization, targeting, combat lockdown, mouseover lifecycle, slash commands, and Lua syntax");