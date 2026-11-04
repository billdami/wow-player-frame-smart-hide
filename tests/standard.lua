local addon = {};
local state;
local mainFrame;
local tickers = {};

function InCombatLockdown() return state.lockdown; end
function UnitAffectingCombat() return state.combat; end
function UnitExists() return state.target; end
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
        target = false, combat = false,
        lockdown = false, mouseover = false
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
loadAddonFile("Globals.lua");
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

for _, filename in ipairs({ "Globals.lua", "SlashCommands.lua", "Functions.lua", "Main.lua" }) do
    assert(loadfile("PlayerFrameSmartHide/" .. filename));
end

print("PASS: initialization, targeting, combat lockdown, mouseover lifecycle, slash commands, and Lua syntax");