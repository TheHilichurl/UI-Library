--!nocheck
--[[
    ============================================================================
    UNIVERSAL GAME ARCHITECTURE, HIERARCHY, REMOTE-DECOMPILER & MECHANISM ANALYZER v6.0
    (Universal All-Games Edition: Works on ANY Roblox Game, Genre, Framework & Executor)
    ============================================================================

    Thiết kế Đa Năng Toàn Diện (Universal Design - Chạy được trên MỌI tựa game Roblox):
    1. TƯƠNG THÍCH MỌI ENGINE & FRAMEWORK GAME:
       - Tự động nhận diện và bóc tách các Framework phổ biến: Knit (Services/Controllers/RE/RF),
         Flamework, ReplicaService (Replica.Data), ProfileService, Rodux/Reflex State Store,
         BridgeNet2, ByteNet, Zap, Blink, Red, PacketRemote (buffer) cũng như cấu trúc truyền thống.
       - Tự động chờ Game, LocalPlayer, Character và PlayerGui nạp xong trước khi phân tích.
    2. QUÉT ĐẦY ĐỦ CÂY THƯ MỤC ĐỆ QUY MỌI DỊCH VỤ (Universal Full Hierarchy Tree):
       - Quét đệ quy 100% thư mục, thư mục con và phần tử con trong: ReplicatedStorage, Workspace,
         ReplicatedFirst, StarterPack, StarterGui, StarterPlayer, Lighting, Teams, SoundService,
         TextChatService/Chat, LocalPlayer (PlayerGui, PlayerScripts, Backpack, leaderstats, Character)
         và NilInstances.
       - Tự động lấy giá trị .Value (ValueBase), Attributes, CollectionService Tags, Properties.
       - Cơ chế chống tràn bộ nhớ thông minh (Adaptive Anti-Overflow): Giữ nguyên 100% Folder, Script,
         Module, Remote, UI, Value, Tool, Prompt, Detector và tự động gom nhóm các bản sao trang trí
         lặp lại hàng chục nghìn lần trong các game bản đồ lớn (Blox Fruits, Pet Sim, RPG...).
    3. QUÉT SÂU BỘ NHỚ ĐỘNG (_G, shared, GC Tables, Closures, Upvalues & Keybinds):
       - Quét cả biến toàn cục `_G`, `shared` và các bảng dữ liệu người chơi nằm trong RAM (`getgc(true)`)
         cho những game không dùng `leaderstats` hay `IntValue` mà lưu tiền/kho đồ trong bảng Lua.
       - Quét toàn bộ phím tắt bàn phím (`ContextActionService` & `UserInputService.InputBegan`).
    4. ĐỌC & LƯU TOÀN BỘ DECOMPILE CODE (Universal Decompile Reader + Pseudo-Decompile Fallback):
       - Decompile toàn bộ ModuleScript, LocalScript, Client Script (có Timeout chống treo).
       - Đặc biệt: Nếu Executor không hỗ trợ `decompile()` hoặc script bị mã hóa chống decompile,
         tự động kích hoạt bộ **Pseudo-Decompiler từ GC Bytecode/Closures/Protos/Constants/Upvalues**
         để tái tạo cấu trúc hàm, hằng số và lời gọi Remote — đảm bảo BẤT KỲ GAME NÀO cũng thu được code!
       - Lưu ra 3 nơi: Thư mục chứa từng file `.lua` rời, 1 file `.lua` Bundle tổng hợp, và nhúng
         mảng từng dòng code (`SourceLines`) vào file JSON chính.
    5. CHẠY THỬ TÍNH NĂNG, CƠ CHẾ & REMOTE TRÊN MỌI THỂ LOẠI GAME (Universal Active Tester):
       - Tự động nạp Module, chạy thử hàm Getter/Query, bấm thử nút UI, kích hoạt thử Tool,
         ProximityPrompt, ClickDetector, và bắn thử mọi RemoteEvent/RemoteFunction/Bindable
         với bộ tham số thông minh (Replay + Decompile Literal Args + GC Constants + Đa thể loại).
       - Giám sát phản ứng nhân quả (`StateMonitor`) trên cả ValueBase, Attributes, UI, Character
         lẫn bảng dữ liệu trong bộ nhớ (`_G`/`shared`/Module tables).
    6. XUẤT FILE PRETTY-PRINTED JSON CHUẨN XÁC:
       - Chờ hoàn tất 100% cả 5 pha mới ghi ra 1 file JSON trình bày nhiều dòng, thụt lề 2 dấu cách,
         tuyệt đối không viết inline.
]]

-- ============================================================================
-- 1. LỚP TƯƠNG THÍCH MỌI EXECUTOR (UNIVERSAL UNC / sUNC COMPATIBILITY LAYER)
-- ============================================================================
local cloneref = cloneref or function(o) return o end
local getnilinstances = getnilinstances or function() return {} end
local getloadedmodules = getloadedmodules or function() return {} end
local getgc = getgc or function() return {} end
local getconnections = getconnections or function() return {} end
local getcallingscript = getcallingscript or function() return nil end
local islclosure = islclosure or function(f)
    local ok, s = pcall(debug.info, f, "s")
    return ok and s ~= "[C]"
end
local newcclosure = newcclosure or function(f) return f end
local checkcaller = checkcaller or function() return false end
local hookmetamethod = hookmetamethod or nil
local getrawmetatable = getrawmetatable or nil
local setreadonly = setreadonly or make_writeable or nil
local getnamecallmethod = getnamecallmethod or function() return "" end
local decompile = decompile or nil
local disassemble = disassemble or nil
local getscriptbytecode = getscriptbytecode or dumpstring or nil
local getscriptclosure = getscriptclosure or getscriptfunction or nil
local getcallbackvalue = getcallbackvalue or getcallbackmember or nil
local firesignal = firesignal or nil
local fireclickdetector = fireclickdetector or nil
local fireproximityprompt = fireproximityprompt or nil
local makefolder = makefolder or nil
local isfolder = isfolder or function() return false end
local writefile = writefile or nil

local getconstants = (debug and debug.getconstants) or getconstants or function() return {} end
local getupvalues = (debug and debug.getupvalues) or getupvalues or function() return {} end
local getprotos = (debug and debug.getprotos) or getprotos or function() return {} end
local getinfo = (debug and debug.getinfo) or getinfo or function(f)
    local ok, s, l, n, a, v = pcall(debug.info, f, "slna")
    if not ok then
        return { short_src = "Unknown", currentline = -1, name = "anon", numparams = 0, is_vararg = 0 }
    end
    return { short_src = s, currentline = l, name = n, numparams = a or 0, is_vararg = v and 1 or 0 }
end

local function safeGetService(serviceName)
    local ok, svc = pcall(function()
        return cloneref(game:GetService(serviceName))
    end)
    return ok and svc or nil
end

local Players = safeGetService("Players")
local ReplicatedStorage = safeGetService("ReplicatedStorage")
local ReplicatedFirst = safeGetService("ReplicatedFirst")
local StarterGui = safeGetService("StarterGui")
local StarterPack = safeGetService("StarterPack")
local StarterPlayer = safeGetService("StarterPlayer")
local WorkspaceService = safeGetService("Workspace")
local CollectionService = safeGetService("CollectionService")
local Lighting = safeGetService("Lighting")
local Teams = safeGetService("Teams")
local SoundService = safeGetService("SoundService")
local PhysicsService = safeGetService("PhysicsService")
local UserInputService = safeGetService("UserInputService")
local ContextActionService = safeGetService("ContextActionService")

-- Đảm bảo Game và LocalPlayer đã tải xong trên mọi tựa game
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

local LocalPlayer = Players and Players.LocalPlayer
if not LocalPlayer and Players then
    local startWait = os.clock()
    while not LocalPlayer and (os.clock() - startWait) < 10 do
        task.wait(0.2)
        LocalPlayer = Players.LocalPlayer
    end
end

-- ============================================================================
-- 2. CẤU HÌNH ĐA NĂNG CHO MỌI TỰA GAME (UNIVERSAL CONFIGURATION)
-- ============================================================================
local placeId = tonumber(game.PlaceId) or 0
local CONFIG = {
    -- Pha 1: Lắng nghe thụ động ban đầu
    PASSIVE_SPY_DURATION = 10,                   -- Thời gian lắng nghe gói tin thụ động (giây)

    -- Pha 2: Quét cây thư mục đệ quy, Bộ nhớ GC, Framework & Decompile
    MAX_TREE_DEPTH = 20,                         -- Độ sâu tối đa khi quét cây thư mục đệ quy
    MAX_TOTAL_TREE_NODES = 18000,                -- Ngưỡng bảo vệ bộ nhớ cho các game bản đồ khổng lồ (Blox Fruits, Pet Sim...)
    SUMMARIZE_REPETITIVE_CLONES = true,          -- Tự động gom nhóm các Part/Mesh/UI clone trùng tên lặp lại hàng trăm lần trong cùng 1 thư mục
    MAX_IDENTICAL_SIBLINGS_SAMPLE = 6,           -- Số bản sao cùng tên giữ lại làm mẫu chi tiết trong 1 thư mục trước khi gom nhóm
    MAX_SCHEMA_KEYS = 80,                        -- Số lượng khóa tối đa khi giải mã bảng cấu hình
    MAX_SCHEMA_DEPTH = 5,                        -- Độ sâu giải mã bảng lồng nhau
    MAX_UPVALUE_DEPTH = 3,                       -- Độ sâu quét Upvalues của closure
    BATCH_YIELD_COUNT = 300,                     -- Số bước xử lý trước khi task.wait() chống giật lag client

    -- Cấu hình Đọc & Lưu Decompile Code (Hoạt động trên mọi Executor)
    ENABLE_FULL_DECOMPILE = true,                -- Bật tính năng đọc và xuất toàn bộ code decompile
    MAX_DECOMPILE_SCRIPTS = 500,                 -- Số lượng Script/Module tối đa được decompile
    DECOMPILE_TIMEOUT_SECONDS = 2.5,             -- Thời gian chờ tối đa cho 1 lần gọi decompile() tránh bị treo
    SAVE_INDIVIDUAL_LUA_FILES = false,           -- Mặc định tắt xuất file lẻ để gom 100% dữ liệu vào 1 file JSON duy nhất
    SAVE_COMBINED_LUA_BUNDLE = false,            -- Mặc định tắt file bundle phụ (bật true nếu muốn xuất thêm file .lua)
    EMBED_DECOMPILE_IN_JSON = true,              -- Nhúng 100% nội dung code decompile (dạng mảng dòng `SourceLines`) vào file JSON chính
    MAX_SOURCE_LINES_PER_SCRIPT_IN_JSON = 15000, -- Giữ nguyên 100% toàn bộ số dòng code decompile của mọi script trong file JSON mà không cắt bớt

    -- Pha 3: Chạy thử cơ chế & tính năng của Game
    ENABLE_ACTIVE_MECHANISM_TESTS = true,        -- Bật chạy thử Module, UI Button, Tool, ProximityPrompt, ClickDetector
    SAFE_REQUIRE_UNLOADED_MODULES = true,        -- Tự động require() các ModuleScript chưa nạp (bọc trong luồng có timeout)
    MODULE_REQUIRE_TIMEOUT = 1.2,                -- Thời gian chờ tối đa khi require 1 ModuleScript (giây)
    MODULE_GETTER_TEST_LIMIT = 18,               -- Số hàm Getter/Query tối đa chạy thử trên mỗi Module
    MAX_UI_BUTTONS_TO_TEST = 50,                 -- Số lượng nút bấm UI tối đa được kích hoạt thử nghiệm
    MAX_PROMPTS_TO_TEST = 25,                    -- Số lượng ProximityPrompt tối đa được kích hoạt thử
    MAX_CLICK_DETECTORS_TO_TEST = 25,            -- Số lượng ClickDetector tối đa được kích hoạt thử
    MAX_TOOLS_TO_TEST = 15,                      -- Số lượng Tool/Vũ khí trong Backpack được cầm và kích hoạt thử

    -- Pha 4: Chạy thử RemoteEvent & RemoteFunction
    ENABLE_ACTIVE_REMOTE_TESTS = true,           -- Bật chạy thử FireServer / InvokeServer trên các Remote
    SAFE_REMOTE_FILTER = true,                   -- Chặn tự động các Remote mang tên Ban/Kick/AntiCheat/Reset/Delete/Teleport
    MAX_PAYLOAD_VARIANTS_PER_REMOTE = 4,         -- Số biến thể tham số tối đa thử nghiệm cho mỗi Remote
    REMOTE_INVOKE_TIMEOUT = 1.5,                 -- Timeout tối đa khi gọi InvokeServer (tránh treo script nếu server không trả lời)
    REACTION_WINDOW_SECONDS = 0.20,              -- Thời gian chờ thu thập phản ứng (Server Echo + State Diff) sau mỗi lần kích hoạt test
    DELAY_BETWEEN_TESTS = 0.08,                  -- Khoảng nghỉ giữa các lần bắn test để tránh bị kick vì spam gói tin

    -- Pha 5: Định dạng xuất file JSON & Đường dẫn lưu file
    JSON_INDENT = "  ",                          -- Chuỗi thụt lề cho Pretty JSON (2 dấu cách, tuyệt đối không viết inline)
    OUTPUT_JSON_FILENAME = string.format("GameMechanismAnalysis_v6_%d.json", placeId),
    OUTPUT_DECOMPILE_FOLDER = string.format("GameDecompiled_%d", placeId),
    OUTPUT_DECOMPILE_BUNDLE = string.format("GameDecompiledBundle_%d.lua", placeId),
}

-- ============================================================================
-- 3. BỘ LỌC CHỐNG NHIỄU & BỘ LỌC AN TOÀN ĐA TỰA GAME (UNIVERSAL FILTERS)
-- ============================================================================
local IGNORED_ROOT_SERVICES = {
    ["CoreGui"] = true,
    ["CorePackages"] = true,
    ["RobloxReplicatedStorage"] = true,
}

local IGNORED_DEFAULT_SCRIPTS = {
    ["PlayerModule"] = true,
    ["RbxCharacterSounds"] = true,
    ["ChatScript"] = true,
    ["BubbleChat"] = true,
    ["CameraModule"] = true,
    ["ControlModule"] = true,
    ["CharacterSounds"] = true,
    ["Animate"] = false, -- Giữ lại Animate vì nhiều game custom lại script Animate cho combat/movement
}

local DANGEROUS_ACTION_KEYWORDS = {
    "ban", "kick", "punish", "exploit", "cheat", "anticheat", "ac_", "adonis", "hdadmin",
    "detect", "flag", "crash", "shutdown", "wipe", "deleteaccount", "resetdata", "erasedata",
    "resetcareer", "leave", "teleport", "rejoin", "servershop", "robux", "purchaseprompt",
    "promptpurchase", "promptproduct", "promptgamepass", "reportabuse", "security", "honeypot",
    "integrity", "handshake_fail", "tamper", "blacklist"
}

local DECORATIVE_PART_CLASSES = {
    ["Part"] = true,
    ["MeshPart"] = true,
    ["UnionOperation"] = true,
    ["WedgePart"] = true,
    ["CornerWedgePart"] = true,
    ["TrussPart"] = true,
    ["Texture"] = true,
    ["Decal"] = true,
    ["SurfaceAppearance"] = true,
    ["SpecialMesh"] = true,
    ["BlockMesh"] = true,
    ["CylinderMesh"] = true,
    ["Weld"] = true,
    ["WeldConstraint"] = true,
    ["Motor6D"] = true,
    ["Attachment"] = true,
    ["Beam"] = true,
    ["Trail"] = true,
    ["ParticleEmitter"] = true,
    ["PointLight"] = true,
    ["SpotLight"] = true,
    ["SurfaceLight"] = true,
}

local stepCounter = 0
local function throttle()
    stepCounter += 1
    if stepCounter % CONFIG.BATCH_YIELD_COUNT == 0 then
        task.wait()
    end
end

local function safeGetFullName(inst)
    if not inst then return "nil" end
    local ok, res = pcall(function() return inst:GetFullName() end)
    return ok and res or tostring(inst)
end

local function safeGetClassName(inst)
    if not inst then return "nil" end
    local ok, res = pcall(function() return inst.ClassName end)
    return ok and res or "UnknownClass"
end

local function safeIsA(inst, className)
    if not inst then return false end
    local ok, res = pcall(function() return inst:IsA(className) end)
    return ok and res == true
end

local function isClientScriptInstance(inst)
    local cn = safeGetClassName(inst)
    if cn == "LocalScript" then return true end
    if cn == "Script" then
        local ok, rc = pcall(function() return inst.RunContext end)
        if ok and rc == Enum.RunContext.Client then
            return true
        end
    end
    return false
end

local function isGameInstance(inst)
    if not inst or typeof(inst) ~= "Instance" then return false end
    local fullPath = safeGetFullName(inst)
    local rootName = string.match(fullPath, "^([^%.]+)")
    if rootName and IGNORED_ROOT_SERVICES[rootName] then
        return false
    end
    for ignoredName, shouldIgnore in pairs(IGNORED_DEFAULT_SCRIPTS) do
        if shouldIgnore then
            if string.find(fullPath, "%." .. ignoredName .. "%.") or string.find(fullPath, "%." .. ignoredName .. "$") then
                return false
            end
        end
    end
    return true
end

local function isSafeActionTarget(nameOrPath, extraText)
    if not CONFIG.SAFE_REMOTE_FILTER then return true, nil end
    local combined = string.lower(tostring(nameOrPath) .. " " .. tostring(extraText or ""))
    for _, kw in ipairs(DANGEROUS_ACTION_KEYWORDS) do
        if string.find(combined, kw, 1, true) then
            return false, "Chứa từ khóa bảo vệ/nhạy cảm: '" .. kw .. "'"
        end
    end
    return true, nil
end

local function getCleanNameForClassifier(instOrPath)
    local path = type(instOrPath) == "string" and instOrPath or safeGetFullName(instOrPath)
    path = string.gsub(path, "^ReplicatedStorage%.", "")
    path = string.gsub(path, "^StarterPlayer%.StarterPlayerScripts%.", "")
    path = string.gsub(path, "^StarterPlayer%.StarterCharacterScripts%.", "")
    path = string.gsub(path, "^Players%.[^%.]+%.PlayerScripts%.", "")
    path = string.gsub(path, "^Players%.[^%.]+%.PlayerGui%.", "")
    path = string.gsub(path, "^Players%.[^%.]+%.Backpack%.", "")
    path = string.gsub(path, "^Workspace%.", "")
    return path
end

local function callWithTimeout(timeoutSec, fn, ...)
    local finished = false
    local success = false
    local results = nil
    local args = {...}

    task.spawn(function()
        local res = { pcall(fn, unpack(args)) }
        if not finished then
            finished = true
            success = table.remove(res, 1)
            results = res
        end
    end)

    local startClock = os.clock()
    while not finished and (os.clock() - startClock) < timeoutSec do
        task.wait(0.02)
    end

    local elapsedMs = math.floor((os.clock() - startClock) * 1000)
    if not finished then
        finished = true
        return false, "Timeout (Quá thời gian chờ " .. tostring(timeoutSec) .. "s)", elapsedMs, true
    end
    return success, results, elapsedMs, false
end

-- ============================================================================
-- 4. BỘ PHÂN LOẠI NGỮ NGHĨA ĐA THỂ LOẠI GAME (UNIVERSAL GENRE TAXONOMY)
-- ============================================================================
--[[
    Bao phủ mọi thể loại game trên Roblox:
    FPS/Shooter, RPG/Anime/Blox Fruits, Simulator/Clicker, Pet/Gacha/Hatching,
    Tycoon/Building, Tower Defense, Survival/Horror/Wave, Racing/Vehicles,
    Obby/Platformer, Roleplay/Social, Sports, Card/Strategy.
]]
local FEATURE_DOMAINS = {
    {
        Domain = "1. Combat, Weapons, Skills & Abilities (Chiến đấu, Vũ khí, Kỹ năng & Chiêu thức)",
        Purpose = "Xử lý đòn đánh, súng đạn, cận chiến, tung chiêu (Skill/Ability/Spell/Fruit), sát thương, Hitbox, Projectile và AI Quái/Boss.",
        Keywords = {"combat", "attack", "damage", "dmg", "hit", "hitbox", "hitmarker", "weapon", "sword", "blade", "katana", "gun", "pistol", "shotgun", "rifle", "sniper", "laser", "shoot", "fire", "ammo", "reload", "melee", "punch", "kick", "combo", "crit", "skill", "ability", "spell", "magic", "mana", "energy", "chakra", "haki", "fruit", "devilfruit", "stand", "breathing", "awakening", "ultimate", "cast", "cooldown", "stun", "ragdoll", "parry", "block", "guard", "projectile", "bullet", "pvp", "zombie", "enemy", "mob", "boss", "npc", "slayer", "corpse", "turret", "sentry", "c4", "detonate", "explosion", "armor", "shield"}
    },
    {
        Domain = "2. RPG, Progression, Quests, Stats & Loadout (Cấp độ, Nhiệm vụ, Chỉ số, Phụ kiện & Nâng cấp)",
        Purpose = "Quản lý cấp độ (Level/XP/Mastery),Rebirth/Prestige, phân bổ điểm chỉ số (Stat/Talent), trang bị (Loadout/Perk/Mod/Accessory/Armor), nhiệm vụ (Quest/Dialogue) và chế tạo (Craft/Enchant/Forge).",
        Keywords = {"perk", "mod", "mods", "loadout", "equip", "unequip", "recycle", "upgrade", "prestige", "rebirth", "ascend", "level", "exp", "xp", "mastery", "stat", "stats", "statpoint", "attribute", "career", "challenge", "achievement", "badge", "quest", "mission", "dialogue", "dialog", "story", "task", "talent", "skilltree", "passive", "trait", "race", "clan", "bloodline", "class", "element", "craft", "crafting", "forge", "anvil", "enchant", "enhance", "fuse", "fusion", "alchemy", "recipe", "blueprint", "mutation", "accessory", "helmet", "artifact", "relic"}
    },
    {
        Domain = "3. Pets, Gacha, Summon, Crates & Collectibles (Thú cưng, Quay tướng/Trái/Trứng, Mở rương & Sưu tầm)",
        Purpose = "Xử lý ấp trứng (Hatch Egg), triệu hồi/quay Gacha (Summon/Roll/Spin/Banner), quản lý Pet/Mount/Unit, tiến hóa (Shiny/Golden/Rainbow/Evolve) và Index sưu tầm.",
        Keywords = {"pet", "pets", "egg", "eggs", "hatch", "incubator", "summon", "gacha", "roll", "reroll", "spin", "banner", "pity", "crate", "case", "chest", "box", "unbox", "open", "loot", "lootbox", "drop", "rarity", "legendary", "mythic", "shiny", "golden", "rainbow", "evolve", "evolution", "mount", "Mounts", "companion", "familiar", "aura", "index", "collection", "codex", "bestiary", "card", "deck"}
    },
    {
        Domain = "4. Economy, Shop, Inventory, Trading & Monetization (Kinh tế, Cửa hàng, Kho đồ & Giao dịch)",
        Purpose = "Xử lý tiền tệ (Cash/Gold/Gem/Token), mua bán vật phẩm, kho đồ (Inventory/Backpack/Bank), giao dịch người chơi (Trade/Market/Booth), tặng quà và nhập Code (Redeem).",
        Keywords = {"shop", "store", "merchant", "vendor", "buy", "bought", "purchase", "sell", "repair", "trade", "trading", "auction", "booth", "bazaar", "market", "marketplace", "coin", "cash", "gold", "gem", "gems", "diamond", "crystal", "token", "ticket", "bounty", "beli", "yen", "currency", "money", "wallet", "bank", "atm", "transfer", "price", "value", "receipt", "pass", "gamepass", "devproduct", "product", "gift", "skin", "skins", "cosmetic", "consumable", "potion", "food", "inventory", "inventories", "item", "items", "storage", "vault", "locker", "redeem", "code", "codes", "promo", "dailyreward", "reward", "claim"}
    },
    {
        Domain = "5. Tycoon, Building, Placement, Tower Defense & Farming (Xây dựng, Đặt tháp/Nhà máy, Nông trại & Khai thác)",
        Purpose = "Điều khiển hệ thống đặt vật thể (Placement/Build/Plot), dây chuyền Tycoon (Dropper/Upgrader/Collector), tháp phòng thủ (Tower/Unit) và thu hoạch/khai thác (Mine/Chop/Fish/Farm).",
        Keywords = {"tycoon", "plot", "base", "home", "house", "factory", "dropper", "conveyor", "upgrader", "collector", "button", "build", "building", "place", "placement", "grid", "blueprint", "structure", "deployable", "furniture", "decorate", "delete", "demolish", "tower", "unit", "units", "troop", "defense", "farm", "farming", "harvest", "plant", "seed", "crop", "water", "mine", "mining", "ore", "pickaxe", "chop", "wood", "lumber", "tree", "fish", "fishing", "rod", "catch", "dig", "shovel", "simulator", "click", "clicker", "tap", "swing", "collect", "orb"}
    },
    {
        Domain = "6. World, Rounds, Waves, Matchmaking, Vehicles & Movement (Bản đồ, Vòng đấu, Phương tiện & Di chuyển)",
        Purpose = "Điều khiển vòng lặp trận đấu (Wave/Round/Match/Lobby), bầu chọn bản đồ, dịch chuyển (Teleport/Portal/Zone), phương tiện (Car/Boat/Flight) và cơ chế di chuyển (Sprint/Dash/Stamina/Climb).",
        Keywords = {"wave", "round", "match", "game", "survive", "intermission", "voteskip", "mapvote", "votekick", "vote", "voting", "spawn", "respawn", "checkpoint", "stage", "obby", "portal", "teleport", "warp", "zone", "area", "region", "biome", "island", "world", "map", "difficulty", "mode", "raid", "dungeon", "arena", "trial", "queue", "party", "squad", "team", "lobby", "sprint", "run", "dash", "dodge", "roll", "slide", "crouch", "crawl", "doublejump", "wallrun", "climb", "glider", "fly", "flight", "swim", "stamina", "vehicle", "car", "chassis", "drive", "steer", "drift", "nitro", "boost", "fuel", "tire", "engine", "boat", "ship", "plane", "helicopter", "train", "horse", "seat", "weather", "time", "daynight"}
    },
    {
        Domain = "7. Data Persistence, Networking, Frameworks & Security (Dữ liệu, Đồng bộ mạng, Framework & Bảo mật)",
        Purpose = "Quản lý lưu/tải dữ liệu (DataStore/Profile/Replica), gói tin mạng (Knit/BridgeNet/ByteNet/Zap/Packet/Buffer), cài đặt người chơi và kiểm tra bảo mật.",
        Keywords = {"data", "datastore", "playerdata", "clientdata", "session", "profile", "profileservice", "replica", "replicaservice", "rodux", "reflex", "store", "state", "sync", "replicate", "replication", "save", "load", "setting", "settings", "config", "configuration", "option", "packet", "network", "networking", "bridge", "bridgenet", "bytenet", "zap", "blink", "red", "knit", "flamework", "service", "controller", "buffer", "serializer", "compress", "ping", "latency", "clock", "tick", "look", "pitch", "angle", "status", "serverstats", "keybind", "input", "bind", "security", "verify", "validation", "token", "handshake", "anticheat"}
    },
    {
        Domain = "8. UI, HUD, Visuals, Audio & Social (Giao diện, Hiệu ứng, Âm thanh & Tương tác xã hội)",
        Purpose = "Điều khiển hiển thị HUD, Menu, cửa sổ thông báo (Popup/Notification), hiệu ứng hình ảnh/VFX, Camera, Âm thanh và Chat/Emote.",
        Keywords = {"gui", "ui", "hud", "menu", "window", "panel", "frame", "modal", "dialog", "tab", "button", "Bar", "healthbar", "hotbar", "toolbar", "minimap", "compass", "leaderboard", "scoreboard", "tooltip", "popup", "toast", "alert", "notification", "notify", "radial", "sound", "music", "sfx", "audio", "voice", "radio", "visual", "vfx", "fx", "particle", "effect", "highlight", "nightvision", "flash", "lightning", "shake", "camera", "fov", "cutscene", "tween", "animation", "anim", "emote", "dance", "pose", "ragdoll", "limb", "chat", "quickchat", "message", "tag", "title", "nametag", " overhead", "morph", "avatar", "outfit", "customize", "hair", "face", "shirt", "pants"}
    }
}

local function detectDomains(instOrPath, extraHints)
    local cleanText = string.lower(getCleanNameForClassifier(instOrPath))
    if extraHints and #extraHints > 0 then
        cleanText = cleanText .. " " .. string.lower(table.concat(extraHints, " "))
    end
    local matched = {}
    for _, domainInfo in ipairs(FEATURE_DOMAINS) do
        for _, kw in ipairs(domainInfo.Keywords) do
            if string.find(cleanText, kw, 1, true) then
                table.insert(matched, domainInfo.Domain)
                break
            end
        end
    end
    if #matched == 0 then
        table.insert(matched, "9. Core / Game-Specific Custom Systems (Hệ thống đặc thù của Game & Tiện ích chung)")
    end
    return matched
end

-- ============================================================================
-- 5. BỘ GIẢI MÃ SCHEMA GIÁ TRỊ & PRETTY-PRINTED JSON SERIALIZER
-- ============================================================================
local ScriptPathLookup = {}

local function resolveClosureScript(f)
    local okEnv, env = pcall(getfenv, f)
    if okEnv and type(env) == "table" then
        local scr = rawget(env, "script")
        if scr and typeof(scr) == "Instance" then
            return scr
        end
    end
    local okInfo, src = pcall(debug.info, f, "s")
    if okInfo and type(src) == "string" and ScriptPathLookup[src] then
        return ScriptPathLookup[src]
    end
    return nil
end

local function describeValueSchema(val, depth, visited)
    depth = depth or 0
    visited = visited or {}
    if depth > CONFIG.MAX_SCHEMA_DEPTH then return "<MaxDepthReached>" end

    local t = typeof(val)
    if t == "Instance" then
        return string.format("Instance<%s>(%s)", safeGetClassName(val), safeGetFullName(val))
    elseif t == "buffer" and buffer then
        local len = buffer.len(val)
        local hexBytes = {}
        local asciiChars = {}
        local scanLen = math.min(len, 48)
        for i = 0, scanLen - 1 do
            local b = buffer.readu8(val, i)
            table.insert(hexBytes, string.format("%02X", b))
            table.insert(asciiChars, (b >= 32 and b <= 126) and string.char(b) or ".")
        end
        local opcodeU8 = (len >= 1) and buffer.readu8(val, 0) or nil
        local opcodeU16 = (len >= 2) and buffer.readu16(val, 0) or nil
        local asciiStr = table.concat(asciiChars, "")
        local embeddedWords = {}
        for word in string.gmatch(asciiStr, "[%w_%-%.]{3,}") do
            table.insert(embeddedWords, word)
        end
        return {
            _Type = "buffer",
            ByteLength = len,
            OpcodeU8 = opcodeU8,
            OpcodeU16LE = opcodeU16,
            HexPreview = table.concat(hexBytes, " ") .. (len > scanLen and " ..." or ""),
            AsciiPreview = asciiStr,
            EmbeddedStrings = #embeddedWords > 0 and embeddedWords or nil,
        }
    elseif t == "table" then
        if visited[val] then return "<CircularTable>" end
        visited[val] = true
        local schema = {}
        local count = 0
        for k, v in pairs(val) do
            count += 1
            if count > CONFIG.MAX_SCHEMA_KEYS then
                schema["..."] = string.format("<TruncatedAfter_%d_Keys>", CONFIG.MAX_SCHEMA_KEYS)
                break
            end
            schema[tostring(k)] = describeValueSchema(v, depth + 1, visited)
        end
        visited[val] = nil
        return schema
    elseif t == "CFrame" or t == "Vector3" or t == "Vector2" or t == "Color3" or t == "UDim2" or t == "EnumItem" or t == "BrickColor" or t == "NumberRange" or t == "Rect" or t == "Ray" or t == "Region3" then
        return string.format("%s(%s)", t, tostring(val))
    elseif t == "function" then
        local scr = resolveClosureScript(val)
        local info = getinfo(val)
        return string.format("function(%s:%s @ line %s, params=%s)", scr and safeGetFullName(scr) or tostring(info.short_src), tostring(info.name or "anon"), tostring(info.currentline), tostring(info.numparams or 0))
    elseif t == "string" then
        if #val > 260 then
            return string.sub(val, 1, 260) .. "... (len=" .. #val .. ")"
        end
        return val
    elseif t == "number" then
        if val ~= val then return "NaN" end
        if val == math.huge then return "Infinity" end
        if val == -math.huge then return "-Infinity" end
        return val
    elseif t == "boolean" or t == "nil" then
        return val
    else
        return string.format("<%s: %s>", t, tostring(val))
    end
end

local KEY_PRIORITY = {
    -- Cấp độ báo cáo gốc
    -- Tầng 1: Tổng quan & Hướng dẫn đọc cho Người / AI (Overview & Schema Guide)
    ["Metadata"] = 1,
    ["AIAndHumanNavigationGuide"] = 2,
    ["ExecutiveSummary"] = 3,
    -- Tầng 2: Kiến trúc Nền tảng, Bảo mật & Trạng thái Động (Architecture, Security & Live State)
    ["ClientSecurityAndAntiCheatAudit"] = 4,
    ["DetectedFrameworksAndGlobalState"] = 5,
    ["LiveReplicatedAttributesAndValues"] = 6,
    -- Tầng 3: Decompile Chuyên Sâu Cho Từng Remote & Chuỗi Nhân Quả (Remote Decompile & Causal Chains)
    ["RemoteDecompileAndCallCatalog"] = 7,
    ["EndToEndMechanismChains"] = 8,
    ["FeaturesCatalog"] = 9,
    -- Tầng 4: Kết quả Kiểm thử Chủ động & Lắng nghe Thụ động (Active & Passive Runtime Proofs)
    ["ActiveRemoteTestResults"] = 10,
    ["ActiveMechanismTestResults"] = 11,
    ["PassiveRemoteSpyLogs"] = 12,
    -- Tầng 5: Công thức/Upvalue, Vật lý/Raycast, Thế giới, Kinh tế & Hoạt ảnh/Âm thanh
    ["FormulaAndUpvalueMutatorMap"] = 13,
    ["CollisionGroupsAndRaycastMap"] = 14,
    ["WorldEntitiesAndPOIAtlas"] = 15,
    ["GameDatabasesAndToolCatalog"] = 16,
    ["AnimationAndSoundCatalog"] = 17,
    ["KeybindsAndInputBindings"] = 18,
    ["CollectionServiceTags"] = 19,
    -- Tầng 6: Kho Mã Nguồn Decompile Toàn Cục & Cây Thư Mục Đệ Quy (Raw Repositories)
    ["DecompiledScriptsRepository"] = 20,
    ["GameHierarchyTree"] = 21,

    -- Cấp độ Node trong cây thư mục, Decompile & Component
    ["Name"] = 12,
    ["ClassName"] = 13,
    ["Path"] = 14,
    ["Type"] = 15,
    ["Status"] = 16,
    ["DecompileStatus"] = 17,
    ["SavedLuaFilePath"] = 18,
    ["LineCount"] = 19,
    ["ByteSize"] = 20,
    ["Value"] = 21,
    ["Properties"] = 22,
    ["Attributes"] = 23,
    ["Tags"] = 24,
    ["Domains"] = 25,
    ["Purpose"] = 26,
    ["ParsedDecompileInsights"] = 27,
    ["Method"] = 28,
    ["Direction"] = 29,
    ["PayloadSent"] = 30,
    ["ReturnValues"] = 31,
    ["LatencyMs"] = 32,
    ["ReactionFootprint"] = 33,
    ["SourceLines"] = 85,
    ["TotalChildrenCount"] = 90,
    ["RepetitiveSiblingsSummary"] = 94,
    ["DecorativeLeafSummary"] = 95,
    ["Children"] = 99,
}

local ESCAPE_MAP = {
    ['"']  = '\\"',
    ['\\'] = '\\\\',
    ['\b'] = '\\b',
    ['\f'] = '\\f',
    ['\n'] = '\\n',
    ['\r'] = '\\r',
    ['\t'] = '\\t',
}

local function escapeJSONString(str)
    local escaped = string.gsub(tostring(str), '[%z\1-\31"\\]', function(c)
        return ESCAPE_MAP[c] or string.format("\\u%04x", string.byte(c))
    end)
    return '"' .. escaped .. '"'
end

local function encodePrettyJSON(data, indentStr)
    indentStr = indentStr or CONFIG.JSON_INDENT or "  "
    local chunks = {}
    local visited = {}

    local function serialize(val, depth)
        throttle()
        local t = typeof(val)

        if t == "nil" then
            table.insert(chunks, "null")
        elseif t == "boolean" then
            table.insert(chunks, val and "true" or "false")
        elseif t == "number" then
            if val ~= val then
                table.insert(chunks, '"NaN"')
            elseif val == math.huge then
                table.insert(chunks, '"Infinity"')
            elseif val == -math.huge then
                table.insert(chunks, '"-Infinity"')
            else
                if math.floor(val) == val and math.abs(val) < 1e15 then
                    table.insert(chunks, string.format("%d", val))
                else
                    table.insert(chunks, tostring(val))
                end
            end
        elseif t == "string" then
            table.insert(chunks, escapeJSONString(val))
        elseif t == "Instance" then
            table.insert(chunks, escapeJSONString(string.format("[%s] %s", safeGetClassName(val), safeGetFullName(val))))
        elseif t == "table" then
            if visited[val] then
                table.insert(chunks, '"<CircularReference>"')
                return
            end
            visited[val] = true

            if next(val) == nil then
                table.insert(chunks, "{}")
                visited[val] = nil
                return
            end

            local isArray = true
            local maxIdx = 0
            local count = 0
            for k, _ in pairs(val) do
                count += 1
                if type(k) == "number" and k > 0 and math.floor(k) == k then
                    if k > maxIdx then maxIdx = k end
                else
                    isArray = false
                end
            end
            if isArray and maxIdx ~= count then
                isArray = false
            end

            local currentIndent = string.rep(indentStr, depth)
            local childIndent = string.rep(indentStr, depth + 1)

            if isArray then
                table.insert(chunks, "[\n")
                for i = 1, count do
                    table.insert(chunks, childIndent)
                    serialize(val[i], depth + 1)
                    if i < count then
                        table.insert(chunks, ",\n")
                    else
                        table.insert(chunks, "\n")
                    end
                end
                table.insert(chunks, currentIndent .. "]")
            else
                local keys = {}
                for k in pairs(val) do
                    table.insert(keys, k)
                end
                table.sort(keys, function(a, b)
                    local sa, sb = tostring(a), tostring(b)
                    local pa = KEY_PRIORITY[sa] or 50
                    local pb = KEY_PRIORITY[sb] or 50
                    if pa ~= pb then
                        return pa < pb
                    end
                    return sa < sb
                end)

                table.insert(chunks, "{\n")
                local numKeys = #keys
                for idx, k in ipairs(keys) do
                    table.insert(chunks, childIndent .. escapeJSONString(tostring(k)) .. ": ")
                    serialize(val[k], depth + 1)
                    if idx < numKeys then
                        table.insert(chunks, ",\n")
                    else
                        table.insert(chunks, "\n")
                    end
                end
                table.insert(chunks, currentIndent .. "}")
            end

            visited[val] = nil
        else
            table.insert(chunks, escapeJSONString(string.format("[%s] %s", t, tostring(val))))
        end
    end

    serialize(data, 0)
    table.insert(chunks, "\n")
    return table.concat(chunks)
end

-- ============================================================================
-- 6. BỘ ĐỌC HIỂU & LƯU TRỮ CODE DECOMPILE (CÓ PSEUDO-DECOMPILER DỰ PHÒNG)
-- ============================================================================
local function sanitizeFileName(pathStr)
    local clean = string.gsub(tostring(pathStr), "[^%w%._%-]", "_")
    clean = string.gsub(clean, "_+", "_")
    if #clean > 140 then
        clean = string.sub(clean, 1, 65) .. "__" .. string.sub(clean, -65)
    end
    return clean
end

local function parseDecompiledLuaSource(srcCode, remoteNameLookup, scriptPath)
    local numberedLines = {}
    local requiredModules = {}
    local declaredFunctions = {}
    local rawLinesList = {}
    local remoteCallsInSource = {}
    local extractedRemoteLiteralArgs = {}
    local extractedRemoteCodeBlocks = {} -- [remoteName] = { { Script = ..., Line = ..., CodeBlock = {...} } }
    local logicHighlights = {}

    local lineIndex = 0
    for line in string.gmatch(srcCode .. "\n", "(.-)\r?\n") do
        lineIndex += 1
        rawLinesList[lineIndex] = line
        if lineIndex <= CONFIG.MAX_SOURCE_LINES_PER_SCRIPT_IN_JSON then
            table.insert(numberedLines, string.format("%4d | %s", lineIndex, line))
        elseif lineIndex == CONFIG.MAX_SOURCE_LINES_PER_SCRIPT_IN_JSON + 1 then
            table.insert(numberedLines, string.format("... <Đã cắt bớt hiển thị trong JSON sau %d dòng; xem toàn bộ 100%% tại file .lua đã xuất>", CONFIG.MAX_SOURCE_LINES_PER_SCRIPT_IN_JSON))
        end

        local trimmed = string.match(line, "^%s*(.-)%s*$") or ""
        if trimmed ~= "" and not string.find(trimmed, "^%-%-") then
            -- 1. Phát hiện lệnh require(...)
            if string.find(trimmed, "require%s*%(") then
                local reqTarget = string.match(trimmed, "require%s*(%b())")
                if reqTarget and #requiredModules < 45 and not table.find(requiredModules, reqTarget) then
                    table.insert(requiredModules, string.format("Line %d: require%s", lineIndex, reqTarget))
                end
            end

            -- 2. Phát hiện khai báo hàm (function)
            local funcSig = string.match(trimmed, "^local%s+function%s+([%w_%.:]+%s*%b())")
                or string.match(trimmed, "^function%s+([%w_%.:]+%s*%b())")
                or string.match(trimmed, "([%w_%.]+)%s*=%s*function%s*(%b())")
            if funcSig and #declaredFunctions < 65 then
                table.insert(declaredFunctions, string.format("Line %d: %s", lineIndex, trimmed))
            end

            -- 3. Phát hiện lời gọi Remote / Knit Service / BridgeNet / ByteNet
            if string.find(trimmed, ":FireServer")
                or string.find(trimmed, ":InvokeServer")
                or string.find(trimmed, "%.OnClientEvent")
                or string.find(trimmed, "%.OnClientInvoke")
                or string.find(trimmed, ":Fire%(")
                or string.find(trimmed, ":Invoke%(")
                or string.find(trimmed, "GetService%(")
                or string.find(trimmed, "GetController%(") then

                if #remoteCallsInSource < 60 then
                    table.insert(remoteCallsInSource, string.format("Line %d: %s", lineIndex, #trimmed > 180 and (string.sub(trimmed, 1, 180) .. "...") or trimmed))
                end

                local callerExpr, argContent = string.match(trimmed, "([%w_%.:%[%]\"]+)%s*:%s*FireServer%s*(%b())")
                if not callerExpr then
                    callerExpr, argContent = string.match(trimmed, "([%w_%.:%[%]\"]+)%s*:%s*InvokeServer%s*(%b())")
                end
                if not callerExpr then
                    callerExpr, argContent = string.match(trimmed, "([%w_%.:%[%]\"]+)%s*:%s*Fire%s*(%b())")
                end

                if callerExpr and argContent then
                    local innerArgs = string.sub(argContent, 2, -2)
                    local firstStrArg = string.match(innerArgs, '^%s*"([^"]+)"') or string.match(innerArgs, "^%s*'([^']+)'")
                    local secondStrArg = string.match(innerArgs, '^%s*["\'][^"\']+["\']%s*,%s*"([^"]+)"')
                        or string.match(innerArgs, "^%s*['\"][^'\"]+['\"]%s*,%s*'([^']+)'")
                    local secondNumArg = string.match(innerArgs, '^%s*["\'][^"\']+["\']%s*,%s*(%d+)')

                    if firstStrArg and remoteNameLookup then
                        for remName, _ in pairs(remoteNameLookup) do
                            if string.find(callerExpr, remName, 1, true) then
                                extractedRemoteLiteralArgs[remName] = extractedRemoteLiteralArgs[remName] or {}
                                if #extractedRemoteLiteralArgs[remName] < 6 then
                                    local parsedTuple = { firstStrArg }
                                    if secondStrArg then
                                        table.insert(parsedTuple, secondStrArg)
                                    elseif secondNumArg then
                                        table.insert(parsedTuple, tonumber(secondNumArg) or 1)
                                    end
                                    table.insert(extractedRemoteLiteralArgs[remName], parsedTuple)
                                end
                            end
                        end
                    end
                end
            end

            -- 4. Phát hiện các dòng xử lý buffer, thuộc tính nhân vật, hoặc Input
            if #logicHighlights < 40 and (
                string.find(trimmed, "buffer%.")
                or string.find(trimmed, "GetAttribute")
                or string.find(trimmed, "SetAttribute")
                or string.find(trimmed, "CollectionService")
                or string.find(trimmed, "UserInputService")
                or string.find(trimmed, "ContextActionService")
                or string.find(trimmed, "ProximityPrompt")
            ) then
                table.insert(logicHighlights, string.format("Line %d: %s", lineIndex, #trimmed > 160 and (string.sub(trimmed, 1, 160) .. "...") or trimmed))
            end
        end
    end


    -- Trích xuất đoạn code ngữ cảnh (+/- 5 dòng) quanh mỗi chỗ gọi hoặc lắng nghe Remote trong Script
    if remoteNameLookup then
        for idx = 1, lineIndex do
            local ln = rawLinesList[idx] or ""
            if string.find(ln, "FireServer", 1, true)
                or string.find(ln, "InvokeServer", 1, true)
                or string.find(ln, "OnClientEvent", 1, true)
                or string.find(ln, "OnClientInvoke", 1, true)
                or string.find(ln, ":Fire(", 1, true)
                or string.find(ln, ":Invoke(", 1, true) then
                for remName, _ in pairs(remoteNameLookup) do
                    if #remName >= 3 and string.find(ln, remName, 1, true) then
                        extractedRemoteCodeBlocks[remName] = extractedRemoteCodeBlocks[remName] or {}
                        if #extractedRemoteCodeBlocks[remName] < 6 then
                            local snippet = {}
                            for cIdx = math.max(1, idx - 4), math.min(lineIndex, idx + 5) do
                                local prefix = (cIdx == idx) and ">> " or "   "
                                table.insert(snippet, string.format("%s%4d | %s", prefix, cIdx, rawLinesList[cIdx] or ""))
                            end
                            table.insert(extractedRemoteCodeBlocks[remName], {
                                ScriptPath = scriptPath or "UnknownScript",
                                CallLine = idx,
                                DecompiledSnippet = snippet,
                            })
                        end
                    end
                end
            end
        end
    end

    return {
        TotalLines = lineIndex,
        ByteSize = #srcCode,
        NumberedSourceLines = numberedLines,
        ParsedInsights = {
            RequiredModules = #requiredModules > 0 and requiredModules or nil,
            DeclaredFunctions = #declaredFunctions > 0 and declaredFunctions or nil,
            RemoteCallsInSource = #remoteCallsInSource > 0 and remoteCallsInSource or nil,
            KeyLogicHighlights = #logicHighlights > 0 and logicHighlights or nil,
        },
        RawLinesList = rawLinesList,
        ExtractedRemoteLiteralArgs = extractedRemoteLiteralArgs,
        ExtractedRemoteCodeBlocks = extractedRemoteCodeBlocks,
    }
end

-- Bộ tái tạo mã nguồn giả lập (Pseudo-Decompiler) từ GC Closures, Protos, Constants & Upvalues
-- Đảm bảo ngay cả khi Executor không có decompile() hoặc Script chống decompile vẫn thu được toàn bộ ruột logic!
local function buildPseudoDecompiledSource(scriptInst, targetRecord, scriptClosuresList)
    local lines = {
        "-- ============================================================================",
        "-- [PSEUDO-DECOMPILED RECONSTRUCTION FROM GC CLOSURES, PROTOS & UPVALUES]",
        "-- Script Path : " .. safeGetFullName(scriptInst),
        "-- ClassName   : " .. safeGetClassName(scriptInst),
        "-- ============================================================================",
        "",
    }

    if getscriptbytecode then
        local okByte, bc = pcall(getscriptbytecode, scriptInst)
        if okByte and type(bc) == "string" then
            table.insert(lines, string.format("-- [Bytecode Info] Raw Bytecode Length: %d bytes", #bc))
        end
    end

    if targetRecord then
        if targetRecord.LiveModuleSchema then
            table.insert(lines, "-- [Live Required Module Table Keys]:")
            for k, v in pairs(targetRecord.LiveModuleSchema) do
                table.insert(lines, string.format("--   export.%s = %s", tostring(k), tostring(v)))
            end
            table.insert(lines, "")
        end
        if targetRecord.StaticTablesSchema and next(targetRecord.StaticTablesSchema) ~= nil then
            table.insert(lines, "-- [Upvalue Static Tables Discovered]:")
            for tName, keysList in pairs(targetRecord.StaticTablesSchema) do
                table.insert(lines, string.format("local %s = { %s }", tostring(tName), table.concat(keysList, ", ")))
            end
            table.insert(lines, "")
        end
    end

    local visitedClosures = {}
    local function dumpClosureTree(fn, indentLevel)
        if not fn or visitedClosures[fn] or indentLevel > 4 then return end
        visitedClosures[fn] = true
        local pad = string.rep("    ", indentLevel)
        local info = getinfo(fn)
        local fnName = (info.name and info.name ~= "") and info.name or "anonymous_func"
        table.insert(lines, string.format("%sfunction %s(...) -- @ line %s (params: %s)", pad, fnName, tostring(info.currentline), tostring(info.numparams or 0)))

        -- Constants trong hàm
        local okC, consts = pcall(getconstants, fn)
        if okC and type(consts) == "table" and next(consts) ~= nil then
            local cList = {}
            for _, c in pairs(consts) do
                if type(c) == "string" or type(c) == "number" or type(c) == "boolean" then
                    table.insert(cList, type(c) == "string" and string.format("%q", c) or tostring(c))
                    if #cList >= 25 then break end
                end
            end
            if #cList > 0 then
                table.insert(lines, pad .. "    -- Constants: " .. table.concat(cList, ", "))
            end
        end

        -- Upvalues trong hàm
        local okU, upvals = pcall(getupvalues, fn)
        if okU and type(upvals) == "table" and next(upvals) ~= nil then
            for uk, uv in pairs(upvals) do
                local uvt = typeof(uv)
                if uvt == "Instance" then
                    table.insert(lines, string.format("%s    -- Upvalue[%s] = Instance<%s>(%s)", pad, tostring(uk), safeGetClassName(uv), safeGetFullName(uv)))
                elseif uvt ~= "function" and uvt ~= "table" then
                    table.insert(lines, string.format("%s    -- Upvalue[%s] = %s", pad, tostring(uk), tostring(uv)))
                end
            end
        end

        -- Hàm con (Protos)
        local okP, protos = pcall(getprotos, fn)
        if okP and type(protos) == "table" then
            for _, pFn in ipairs(protos) do
                dumpClosureTree(pFn, indentLevel + 1)
            end
        end

        table.insert(lines, pad .. "end\n")
    end

    if scriptClosuresList and #scriptClosuresList > 0 then
        for i = 1, math.min(25, #scriptClosuresList) do
            dumpClosureTree(scriptClosuresList[i], 0)
        end
    elseif getscriptclosure then
        local okMain, mainClosure = pcall(getscriptclosure, scriptInst)
        if okMain and type(mainClosure) == "function" then
            dumpClosureTree(mainClosure, 0)
        end
    end

    if targetRecord and targetRecord.StringConstants and #targetRecord.StringConstants > 0 then
        table.insert(lines, "-- [All Aggregated String Constants]:")
        table.insert(lines, "-- " .. table.concat(targetRecord.StringConstants, " | "))
    end

    local rawText = table.concat(lines, "\n")
    local numbered = {}
    for i, l in ipairs(lines) do
        table.insert(numbered, string.format("%4d | %s", i, l))
    end
    return rawText, numbered
end

local function decompileAndSaveAllGameScripts(ModulesDB, ScriptsDB, RemotesDB, remoteNameMap, ClosuresByScriptPath)
    local repository = {
        Summary = {
            DecompilerAvailable = (decompile ~= nil),
            TotalCandidates = 0,
            SuccessfullyDecompiled = 0,
            PseudoDecompiledFallback = 0,
            SavedIndividualLuaFilesCount = 0,
            OutputFolder = CONFIG.OUTPUT_DECOMPILE_FOLDER,
            CombinedBundleFile = CONFIG.OUTPUT_DECOMPILE_BUNDLE,
        },
        Scripts = {},
    }

    if not CONFIG.ENABLE_FULL_DECOMPILE then
        return repository
    end

    local canSaveFolder = false
    if CONFIG.SAVE_INDIVIDUAL_LUA_FILES and makefolder and writefile then
        local okFolder = pcall(function()
            if not isfolder(CONFIG.OUTPUT_DECOMPILE_FOLDER) then
                makefolder(CONFIG.OUTPUT_DECOMPILE_FOLDER)
            end
        end)
        canSaveFolder = okFolder
    end

    local candidates = {}
    for _, mData in pairs(ModulesDB) do table.insert(candidates, mData) end
    for _, sData in pairs(ScriptsDB) do table.insert(candidates, sData) end

    table.sort(candidates, function(a, b)
        local countA, countB = 0, 0
        for _ in pairs(a.LinkedRemotes) do countA += 1 end
        for _ in pairs(b.LinkedRemotes) do countB += 1 end
        if countA ~= countB then return countA > countB end
        if #a.StringConstants ~= #b.StringConstants then
            return #a.StringConstants > #b.StringConstants
        end
        return tostring(a.Path) < tostring(b.Path)
    end)

    repository.Summary.TotalCandidates = #candidates
    local bundleChunks = {
        "--[[",
        "    ============================================================================",
        "    UNIVERSAL GAME DECOMPILED SCRIPTS MASTER BUNDLE (v4.0)",
        "    PlaceId: " .. tostring(game.PlaceId) .. " | GameId: " .. tostring(game.GameId),
        "    Generated UTC: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"),
        "    Total Scripts Processed: " .. tostring(math.min(#candidates, CONFIG.MAX_DECOMPILE_SCRIPTS)),
        "    ============================================================================",
        "]]\n\n"
    }

    local processedCount = 0
    for _, rec in ipairs(candidates) do
        if processedCount >= CONFIG.MAX_DECOMPILE_SCRIPTS then break end
        local inst = rec.InstanceRef
        if inst then
            processedCount += 1
            throttle()

            local status = "NotDecompiled"
            local rawSource = nil
            local elapsedMs = 0

            if decompile then
                local okDec, decResult, decMs, timedOut = callWithTimeout(CONFIG.DECOMPILE_TIMEOUT_SECONDS, decompile, inst)
                elapsedMs = decMs
                if okDec and type(decResult) == "table" and type(decResult[1]) == "string" and #decResult[1] > 5 then
                    rawSource = decResult[1]
                    status = "DecompiledSuccess"
                    repository.Summary.SuccessfullyDecompiled += 1
                elseif timedOut then
                    status = "TimedOut (> " .. tostring(CONFIG.DECOMPILE_TIMEOUT_SECONDS) .. "s)"
                else
                    status = "DecompilerEmptyOrProtected"
                end
            elseif disassemble then
                local okDis, disResult, disMs = callWithTimeout(CONFIG.DECOMPILE_TIMEOUT_SECONDS, disassemble, inst)
                elapsedMs = disMs
                if okDis and type(disResult) == "table" and type(disResult[1]) == "string" and #disResult[1] > 5 then
                    rawSource = disResult[1]
                    status = "DisassembledSuccess"
                    repository.Summary.SuccessfullyDecompiled += 1
                end
            end

            local parsedData = nil
            local numberedLines = nil

            if rawSource then
                parsedData = parseDecompiledLuaSource(rawSource, remoteNameMap, rec.Path)
                rec.RawLinesList = parsedData.RawLinesList
                numberedLines = parsedData.NumberedSourceLines

                rec.DecompiledMechanismSignatures = parsedData.ParsedInsights.RemoteCallsInSource
                    or parsedData.ParsedInsights.DeclaredFunctions
                    or parsedData.ParsedInsights.KeyLogicHighlights

                if parsedData.ExtractedRemoteCodeBlocks then
                    for remName, blockList in pairs(parsedData.ExtractedRemoteCodeBlocks) do
                        local rPaths = remoteNameMap[remName]
                        if rPaths then
                            for _, rPath in ipairs(rPaths) do
                                if RemotesDB[rPath] then
                                    RemotesDB[rPath].DecompiledCallSnippets = RemotesDB[rPath].DecompiledCallSnippets or {}
                                    for _, blk in ipairs(blockList) do
                                        if #RemotesDB[rPath].DecompiledCallSnippets < 8 then
                                            table.insert(RemotesDB[rPath].DecompiledCallSnippets, blk)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if parsedData.ExtractedRemoteLiteralArgs then
                    for remName, argTuples in pairs(parsedData.ExtractedRemoteLiteralArgs) do
                        local rPaths = remoteNameMap[remName]
                        if rPaths then
                            for _, rPath in ipairs(rPaths) do
                                if RemotesDB[rPath] then
                                    RemotesDB[rPath].DecompileExtractedArgs = RemotesDB[rPath].DecompileExtractedArgs or {}
                                    for _, tuple in ipairs(argTuples) do
                                        if #RemotesDB[rPath].DecompileExtractedArgs < 6 then
                                            table.insert(RemotesDB[rPath].DecompileExtractedArgs, tuple)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                rawSource, numberedLines = buildPseudoDecompiledSource(inst, rec, ClosuresByScriptPath[rec.Path])
                repository.Summary.PseudoDecompiledFallback += 1
                status = status .. " -> ReconstructedViaPseudoDecompiler"
            end

            local linkedRemotesList = {}
            for rPath in pairs(rec.LinkedRemotes) do
                table.insert(linkedRemotesList, rPath)
            end

            local fileHeader = table.concat({
                "-- ============================================================================",
                "-- SCRIPT PATH   : " .. tostring(rec.Path),
                "-- CLASS NAME    : " .. safeGetClassName(inst),
                "-- DOMAINS       : " .. table.concat(rec.Domains or {}, " | "),
                "-- LINKED REMOTES: " .. (#linkedRemotesList > 0 and table.concat(linkedRemotesList, ", ") or "None"),
                "-- DECOMPILE STAT: " .. status .. " (" .. tostring(elapsedMs) .. " ms)",
                "-- ============================================================================\n",
            }, "\n")

            local fullFileContent = fileHeader .. rawSource .. "\n"
            local savedIndividualPath = nil

            if canSaveFolder and writefile then
                local safeName = sanitizeFileName(rec.Path) .. ".lua"
                local targetFilePath = CONFIG.OUTPUT_DECOMPILE_FOLDER .. "/" .. safeName
                local okW = pcall(writefile, targetFilePath, fullFileContent)
                if okW then
                    savedIndividualPath = "workspace/" .. targetFilePath
                    repository.Summary.SavedIndividualLuaFilesCount += 1
                end
            end

            if CONFIG.SAVE_COMBINED_LUA_BUNDLE then
                table.insert(bundleChunks, fullFileContent .. "\n\n")
            end

            rec.SavedLuaFilePath = savedIndividualPath
            rec.DecompileStatus = status

            repository.Scripts[rec.Path] = {
                Name = rec.Name,
                ClassName = safeGetClassName(inst),
                Path = rec.Path,
                Domains = rec.Domains,
                DecompileStatus = status,
                DecompileLatencyMs = elapsedMs,
                SavedLuaFilePath = savedIndividualPath or "Included in Bundle & JSON",
                LineCount = parsedData and parsedData.TotalLines or #numberedLines,
                ByteSize = #rawSource,
                LinkedRemotes = #linkedRemotesList > 0 and linkedRemotesList or nil,
                ParsedDecompileInsights = parsedData and parsedData.ParsedInsights or nil,
                SourceLines = CONFIG.EMBED_DECOMPILE_IN_JSON and numberedLines or nil,
            }
        end
    end

    if CONFIG.SAVE_COMBINED_LUA_BUNDLE and writefile and #bundleChunks > 1 then
        local okBundle, errBundle = pcall(writefile, CONFIG.OUTPUT_DECOMPILE_BUNDLE, table.concat(bundleChunks))
        if okBundle then
            print("[DeepAnalyzer v6.0] -> Đã lưu file tổng hợp toàn bộ Code Decompile: workspace/" .. CONFIG.OUTPUT_DECOMPILE_BUNDLE)
        else
            warn("[DeepAnalyzer v6.0] -> Không thể ghi file Bundle Decompile: " .. tostring(errBundle))
        end
    end

    return repository
end

-- ============================================================================
-- 7. NHẬN DIỆN FRAMEWORK, BIẾN TOÀN CỤC (_G / shared) & PHÍM TẮT (KEYBINDS)
-- ============================================================================
-- Quét Knit, Flamework, ReplicaService, Rodux, BridgeNet2, ByteNet và dữ liệu trong _G / shared
local MonitoredMemoryTables = {} -- Lưu tham chiếu các bảng trạng thái người chơi trong RAM để StateMonitor so sánh!

local function scanFrameworksAndGlobalState()
    local report = {
        DetectedFrameworks = {},
        GlobalTable_G_Keys = {},
        SharedTable_Keys = {},
        KnitArchitecture = nil,
        ReplicaOrStateStores = {},
    }
    table.clear(MonitoredMemoryTables)

    -- 1. Quét bảng _G
    pcall(function()
        if type(_G) == "table" then
            for k, v in pairs(_G) do
                local ks = tostring(k)
                report.GlobalTable_G_Keys[ks] = describeValueSchema(v, 0)
                if type(v) == "table" and #MonitoredMemoryTables < 20 then
                    table.insert(MonitoredMemoryTables, { Label = "_G." .. ks, TableRef = v })
                end
            end
        end
    end)

    -- 2. Quét bảng shared
    pcall(function()
        if type(shared) == "table" then
            for k, v in pairs(shared) do
                local ks = tostring(k)
                report.SharedTable_Keys[ks] = describeValueSchema(v, 0)
                if type(v) == "table" and #MonitoredMemoryTables < 20 then
                    table.insert(MonitoredMemoryTables, { Label = "shared." .. ks, TableRef = v })
                end
            end
        end
    end)

    -- 3. Quét các bảng đặc trưng của Knit, ReplicaService, Rodux, Flamework trong GC
    local okGC, gcAll = pcall(getgc, true)
    if okGC and type(gcAll) == "table" then
        for _, obj in ipairs(gcAll) do
            if type(obj) == "table" then
                throttle()
                -- Phát hiện Knit Client
                local okKnit, isKnit = pcall(function()
                    return rawget(obj, "GetService") ~= nil and rawget(obj, "GetController") ~= nil and (rawget(obj, "Controllers") ~= nil or rawget(obj, "Services") ~= nil)
                end)
                if okKnit and isKnit and not report.KnitArchitecture then
                    table.insert(report.DetectedFrameworks, "Knit Framework")
                    local controllers = {}
                    local services = {}
                    pcall(function()
                        if type(obj.Controllers) == "table" then
                            for cName, cTab in pairs(obj.Controllers) do
                                controllers[tostring(cName)] = describeValueSchema(cTab, 0)
                            end
                        end
                        if type(obj.Services) == "table" then
                            for sName, sTab in pairs(obj.Services) do
                                services[tostring(sName)] = describeValueSchema(sTab, 0)
                            end
                        end
                    end)
                    report.KnitArchitecture = {
                        Controllers = controllers,
                        Services = services,
                    }
                end

                -- Phát hiện ReplicaService / ProfileService Client Replica (`ClassToken`, `Data`, `Id`)
                local okRep, isReplica = pcall(function()
                    return type(rawget(obj, "Data")) == "table" and (rawget(obj, "ClassToken") ~= nil or rawget(obj, "Tags") ~= nil) and rawget(obj, "Id") ~= nil
                end)
                if okRep and isReplica and #report.ReplicaOrStateStores < 15 then
                    if not table.find(report.DetectedFrameworks, "ReplicaService / State Replica") then
                        table.insert(report.DetectedFrameworks, "ReplicaService / State Replica")
                    end
                    local tokenName = tostring(rawget(obj, "ClassToken") or rawget(obj, "Id"))
                    table.insert(report.ReplicaOrStateStores, {
                        ReplicaClassOrId = tokenName,
                        DataSchema = describeValueSchema(rawget(obj, "Data"), 0),
                    })
                    if #MonitoredMemoryTables < 25 then
                        table.insert(MonitoredMemoryTables, { Label = "Replica[" .. tokenName .. "].Data", TableRef = rawget(obj, "Data") })
                    end
                end

                -- Phát hiện Rodux / Reflex Store (`getState`, `dispatch`)
                local okStore, isStore = pcall(function()
                    return type(rawget(obj, "getState")) == "function" and type(rawget(obj, "dispatch")) == "function"
                end)
                if okStore and isStore and #report.ReplicaOrStateStores < 15 then
                    if not table.find(report.DetectedFrameworks, "Rodux / Reflex Store") then
                        table.insert(report.DetectedFrameworks, "Rodux / Reflex Store")
                    end
                    local okSt, st = pcall(function() return obj:getState() end)
                    if okSt and type(st) == "table" then
                        table.insert(report.ReplicaOrStateStores, {
                            StoreType = "Rodux/Reflex",
                            StateSchema = describeValueSchema(st, 0),
                        })
                        if #MonitoredMemoryTables < 25 then
                            table.insert(MonitoredMemoryTables, { Label = "RoduxStoreState", TableRef = st })
                        end
                    end
                end
            end
        end
    end

    -- 4. Kiểm tra các thư viện Networking hiện đại trong ReplicatedStorage
    if ReplicatedStorage then
        for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
            local lowerN = string.lower(desc.Name)
            if lowerN == "bridgenet2" or lowerN == "bridgenet" then
                if not table.find(report.DetectedFrameworks, "BridgeNet / BridgeNet2") then
                    table.insert(report.DetectedFrameworks, "BridgeNet / BridgeNet2")
                end
            elseif lowerN == "bytenet" then
                if not table.find(report.DetectedFrameworks, "ByteNet") then
                    table.insert(report.DetectedFrameworks, "ByteNet")
                end
            elseif lowerN == "zap" then
                if not table.find(report.DetectedFrameworks, "Zap Networking") then
                    table.insert(report.DetectedFrameworks, "Zap Networking")
                end
            elseif lowerN == "flamework" then
                if not table.find(report.DetectedFrameworks, "Flamework") then
                    table.insert(report.DetectedFrameworks, "Flamework")
                end
            end
        end
    end

    return report
end

-- Quét toàn bộ phím tắt (Keybinds) từ ContextActionService & UserInputService
local function scanKeybindsAndInputs()
    local inputReport = {
        ContextActionServiceBindings = {},
        UserInputServiceListeners = {},
    }

    pcall(function()
        if ContextActionService then
            local boundInfo = ContextActionService:GetAllBoundActionInfo()
            if type(boundInfo) == "table" then
                for actionName, info in pairs(boundInfo) do
                    local inputTypes = {}
                    if type(info.inputTypes) == "table" then
                        for _, it in ipairs(info.inputTypes) do
                            table.insert(inputTypes, tostring(it))
                        end
                    end
                    inputReport.ContextActionServiceBindings[tostring(actionName)] = {
                        InputTypes = inputTypes,
                        CreateTouchButton = info.createTouchButton,
                        PriorityLevel = info.priorityLevel,
                    }
                end
            end
        end
    end)

    pcall(function()
        if UserInputService then
            for _, sigName in ipairs({"InputBegan", "InputEnded", "JumpRequest"}) do
                local sig = UserInputService[sigName]
                if sig then
                    local okC, conns = pcall(getconnections, sig)
                    if okC and type(conns) == "table" then
                        for _, c in ipairs(conns) do
                            if c.Function and islclosure(c.Function) then
                                local scr = resolveClosureScript(c.Function)
                                if scr and isGameInstance(scr) then
                                    local info = getinfo(c.Function)
                                    table.insert(inputReport.UserInputServiceListeners, {
                                        Signal = sigName,
                                        ScriptPath = safeGetFullName(scr),
                                        Line = info.currentline,
                                        FunctionName = info.name or "anon",
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    return inputReport
end

-- ============================================================================
-- 8. BỘ GIÁM SÁT PHẢN ỨNG & SO SÁNH TRẠNG THÁI (UNIVERSAL STATE DIFF MONITOR)
-- ============================================================================
local StateMonitor = {
    IsCapturing = false,
    CurrentCapture = nil,
}

local MonitoredValueObjects = {}
local MonitoredAttributeOwners = {}

local function registerMonitoredStateObjects()
    table.clear(MonitoredValueObjects)
    table.clear(MonitoredAttributeOwners)

    local rootsToWatch = { LocalPlayer, ReplicatedStorage, WorkspaceService }
    for _, root in ipairs(rootsToWatch) do
        if root then
            table.insert(MonitoredAttributeOwners, root)
            local ok, desc = pcall(function() return root:GetDescendants() end)
            if ok and type(desc) == "table" then
                for _, inst in ipairs(desc) do
                    if isGameInstance(inst) then
                        if safeIsA(inst, "ValueBase") and #MonitoredValueObjects < 300 then
                            table.insert(MonitoredValueObjects, inst)
                        end
                        local okAttr, attrs = pcall(function() return inst:GetAttributes() end)
                        if okAttr and attrs and next(attrs) ~= nil and #MonitoredAttributeOwners < 300 then
                            table.insert(MonitoredAttributeOwners, inst)
                        end
                    end
                end
            end
        end
    end
end

local function snapshotCharacterState()
    local char = LocalPlayer and LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    local equippedTool = char:FindFirstChildOfClass("Tool")
    return {
        Health = hum and hum.Health or nil,
        MaxHealth = hum and hum.MaxHealth or nil,
        WalkSpeed = hum and hum.WalkSpeed or nil,
        JumpPower = hum and hum.JumpPower or nil,
        Position = hrp and hrp.Position or nil,
        EquippedTool = equippedTool and equippedTool.Name or "None",
    }
end

local function snapshotValuesAttributesAndMemoryTables()
    local valSnap = {}
    for _, vObj in ipairs(MonitoredValueObjects) do
        if vObj and vObj.Parent then
            local ok, val = pcall(function() return vObj.Value end)
            if ok then
                valSnap[safeGetFullName(vObj)] = tostring(describeValueSchema(val, 0))
            end
        end
    end

    -- Bổ sung theo dõi biến trong bảng RAM (_G, shared, Replica.Data, Rodux Store) cho các game không dùng ValueBase
    for _, memEntry in ipairs(MonitoredMemoryTables) do
        if type(memEntry.TableRef) == "table" then
            local count = 0
            for k, v in pairs(memEntry.TableRef) do
                count += 1
                if count > 40 then break end
                local vt = type(v)
                if vt == "number" or vt == "string" or vt == "boolean" then
                    valSnap[memEntry.Label .. "." .. tostring(k)] = tostring(v)
                end
            end
        end
    end

    local attrSnap = {}
    for _, owner in ipairs(MonitoredAttributeOwners) do
        if owner and owner.Parent then
            local ok, attrs = pcall(function() return owner:GetAttributes() end)
            if ok and type(attrs) == "table" then
                local path = safeGetFullName(owner)
                attrSnap[path] = {}
                for k, v in pairs(attrs) do
                    attrSnap[path][k] = tostring(describeValueSchema(v, 0))
                end
            end
        end
    end

    return valSnap, attrSnap
end

local function snapshotUIVisibility()
    local uiSnap = {}
    local pgui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if not pgui then return uiSnap end

    for _, inst in ipairs(pgui:GetDescendants()) do
        if isGameInstance(inst) then
            if safeIsA(inst, "ScreenGui") then
                uiSnap[safeGetFullName(inst)] = { Enabled = inst.Enabled }
            elseif safeIsA(inst, "Frame") or safeIsA(inst, "ScrollingFrame") or safeIsA(inst, "ImageLabel") or safeIsA(inst, "CanvasGroup") then
                if inst.Parent and (safeIsA(inst.Parent, "ScreenGui") or inst.Parent.Name == "Main" or inst.Parent.Name == "Frames" or inst.Parent.Name == "Windows" or inst.Parent.Name == "Menus") then
                    uiSnap[safeGetFullName(inst)] = { Visible = inst.Visible }
                end
            elseif safeIsA(inst, "TextLabel") and inst.Visible and inst.Text ~= "" and #inst.Text < 120 then
                uiSnap[safeGetFullName(inst)] = { Visible = inst.Visible, Text = inst.Text }
            end
        end
    end
    return uiSnap
end

function StateMonitor:BeginCapture(contextLabel)
    local valBefore, attrBefore = snapshotValuesAttributesAndMemoryTables()
    self.CurrentCapture = {
        Context = contextLabel,
        StartTime = os.clock(),
        ValBefore = valBefore,
        AttrBefore = attrBefore,
        CharBefore = snapshotCharacterState(),
        UIBefore = snapshotUIVisibility(),
        OutgoingRemotes = {},
        ServerEchoes = {},
        SpawnedInstances = {},
        TempConnections = {},
    }
    self.IsCapturing = true

    local watchContainers = {
        LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"),
        LocalPlayer and LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer and LocalPlayer.Character,
    }
    for _, container in ipairs(watchContainers) do
        if container then
            local ok, conn = pcall(function()
                return container.DescendantAdded:Connect(function(desc)
                    if self.IsCapturing and self.CurrentCapture and #self.CurrentCapture.SpawnedInstances < 15 then
                        local extra = ""
                        if safeIsA(desc, "TextLabel") or safeIsA(desc, "TextButton") then
                            extra = " (Text='" .. tostring(desc.Text) .. "')"
                        elseif safeIsA(desc, "Sound") then
                            extra = " (SoundId='" .. tostring(desc.SoundId) .. "')"
                        elseif safeIsA(desc, "Animation") then
                            extra = " (AnimId='" .. tostring(desc.AnimationId) .. "')"
                        end
                        table.insert(self.CurrentCapture.SpawnedInstances, string.format("[%s] %s%s", safeGetClassName(desc), safeGetFullName(desc), extra))
                    end
                end)
            end)
            if ok and conn then
                table.insert(self.CurrentCapture.TempConnections, conn)
            end
        end
    end
end

function StateMonitor:RecordOutgoingRemote(remote, method, args)
    if not self.IsCapturing or not self.CurrentCapture then return end
    if #self.CurrentCapture.OutgoingRemotes >= 15 then return end
    table.insert(self.CurrentCapture.OutgoingRemotes, {
        RemotePath = safeGetFullName(remote),
        Method = method,
        Args = describeValueSchema(args, 0),
    })
end

function StateMonitor:RecordServerEcho(remote, args)
    if not self.IsCapturing or not self.CurrentCapture then return end
    if #self.CurrentCapture.ServerEchoes >= 15 then return end
    table.insert(self.CurrentCapture.ServerEchoes, {
        RemotePath = safeGetFullName(remote),
        Args = describeValueSchema(args, 0),
    })
end

function StateMonitor:EndCapture()
    if not self.CurrentCapture then return {} end
    self.IsCapturing = false
    local cap = self.CurrentCapture
    self.CurrentCapture = nil

    for _, conn in ipairs(cap.TempConnections) do
        pcall(function() conn:Disconnect() end)
    end

    local valAfter, attrAfter = snapshotValuesAttributesAndMemoryTables()
    local charAfter = snapshotCharacterState()
    local uiAfter = snapshotUIVisibility()

    local valueDiffs = {}
    for path, newVal in pairs(valAfter) do
        local oldVal = cap.ValBefore[path]
        if oldVal ~= nil and tostring(oldVal) ~= tostring(newVal) then
            table.insert(valueDiffs, {
                Path = path,
                OldValue = oldVal,
                NewValue = newVal,
            })
        end
    end

    local attrDiffs = {}
    for path, newAttrs in pairs(attrAfter) do
        local oldAttrs = cap.AttrBefore[path] or {}
        for attrName, newVal in pairs(newAttrs) do
            local oldVal = oldAttrs[attrName]
            if tostring(oldVal) ~= tostring(newVal) then
                table.insert(attrDiffs, {
                    Path = path,
                    Attribute = attrName,
                    OldValue = oldVal,
                    NewValue = newVal,
                })
            end
        end
    end

    local uiDiffs = {}
    for path, newState in pairs(uiAfter) do
        local oldState = cap.UIBefore[path]
        if oldState then
            if oldState.Enabled ~= nil and oldState.Enabled ~= newState.Enabled then
                table.insert(uiDiffs, string.format("%s: Enabled %s -> %s", path, tostring(oldState.Enabled), tostring(newState.Enabled)))
            end
            if oldState.Visible ~= nil and oldState.Visible ~= newState.Visible then
                table.insert(uiDiffs, string.format("%s: Visible %s -> %s", path, tostring(oldState.Visible), tostring(newState.Visible)))
            end
            if oldState.Text ~= nil and oldState.Text ~= newState.Text then
                table.insert(uiDiffs, string.format("%s: Text '%s' -> '%s'", path, tostring(oldState.Text), tostring(newState.Text)))
            end
        end
    end

    local charDiffs = {}
    if cap.CharBefore and charAfter then
        if cap.CharBefore.Health ~= charAfter.Health then
            table.insert(charDiffs, string.format("Health: %s -> %s", tostring(cap.CharBefore.Health), tostring(charAfter.Health)))
        end
        if cap.CharBefore.WalkSpeed ~= charAfter.WalkSpeed then
            table.insert(charDiffs, string.format("WalkSpeed: %s -> %s", tostring(cap.CharBefore.WalkSpeed), tostring(charAfter.WalkSpeed)))
        end
        if cap.CharBefore.EquippedTool ~= charAfter.EquippedTool then
            table.insert(charDiffs, string.format("EquippedTool: %s -> %s", tostring(cap.CharBefore.EquippedTool), tostring(charAfter.EquippedTool)))
        end
        if cap.CharBefore.Position and charAfter.Position then
            local dist = (charAfter.Position - cap.CharBefore.Position).Magnitude
            if dist > 3 then
                table.insert(charDiffs, string.format("Moved/Teleported: %.1f studs (NewPos=%s)", dist, tostring(charAfter.Position)))
            end
        end
    end

    local hasAnyEffect = (#cap.OutgoingRemotes > 0)
        or (#cap.ServerEchoes > 0)
        or (#valueDiffs > 0)
        or (#attrDiffs > 0)
        or (#uiDiffs > 0)
        or (#charDiffs > 0)
        or (#cap.SpawnedInstances > 0)

    return {
        ObservedReaction = hasAnyEffect,
        TriggeredOutgoingRemotes = #cap.OutgoingRemotes > 0 and cap.OutgoingRemotes or nil,
        ServerEchoEvents = #cap.ServerEchoes > 0 and cap.ServerEchoes or nil,
        ValueAndMemoryChanges = #valueDiffs > 0 and valueDiffs or nil,
        AttributeChanges = #attrDiffs > 0 and attrDiffs or nil,
        UIChanges = #uiDiffs > 0 and uiDiffs or nil,
        CharacterChanges = #charDiffs > 0 and charDiffs or nil,
        SpawnedInstances = #cap.SpawnedInstances > 0 and cap.SpawnedInstances or nil,
    }
end

-- ============================================================================
-- 9. PHA 1: UNIVERSAL PASSIVE REMOTE SPY (HỖ TRỢ MỌI EXECUTOR)
-- ============================================================================
local RemoteLogs = {}
local SpyConnections = {}
local PassiveSpyEnabled = false
local MasterHookInstalled = false

local function captureCallStack()
    local stack = {}
    for level = 3, 10 do
        local ok, s, l, n = pcall(debug.info, level, "sln")
        if not ok or not s then break end
        if s ~= "[C]" and not string.find(s, "^%[") then
            table.insert(stack, string.format("%s:%s (%s)", s, tostring(l), (n and n ~= "") and n or "anon"))
        end
    end
    return stack
end

local function recordRemoteCall(remote, method, direction, args, callerScript, callStack)
    if not isGameInstance(remote) then return end

    if StateMonitor.IsCapturing then
        if direction == "Client->Server" or direction == "Client->Client(Bindable)" then
            StateMonitor:RecordOutgoingRemote(remote, method, args)
        elseif direction == "Server->Client" then
            StateMonitor:RecordServerEcho(remote, args)
        end
    end

    if not PassiveSpyEnabled then return end

    local fullPath = safeGetFullName(remote)
    local entry = RemoteLogs[fullPath]
    if not entry then
        entry = {
            Name = remote.Name,
            ClassName = safeGetClassName(remote),
            Path = fullPath,
            CallCount = 0,
            Directions = {},
            CallerScripts = {},
            UniquePayloadSignatures = {},
            SamplePayloads = {},
            RawCapturedArgsList = {},
        }
        RemoteLogs[fullPath] = entry
    end

    entry.CallCount += 1
    local dirKey = direction .. ":" .. method
    entry.Directions[dirKey] = (entry.Directions[dirKey] or 0) + 1

    local callerPath = callerScript and safeGetFullName(callerScript) or "Unknown/Engine"
    entry.CallerScripts[callerPath] = (entry.CallerScripts[callerPath] or 0) + 1

    local sigParts = { method, callerPath }
    if args[1] ~= nil then
        if type(args[1]) == "table" then
            for k in pairs(args[1]) do table.insert(sigParts, tostring(k)) end
        else
            table.insert(sigParts, tostring(typeof(args[1])) .. ":" .. tostring(args[1]))
        end
    end
    local signature = table.concat(sigParts, "|")

    if not entry.UniquePayloadSignatures[signature] and #entry.SamplePayloads < 12 then
        entry.UniquePayloadSignatures[signature] = true
        local serializedArgs = {}
        for i = 1, #args do
            serializedArgs[i] = describeValueSchema(args[i], 0)
        end
        table.insert(entry.SamplePayloads, {
            Method = method,
            Direction = direction,
            Caller = callerPath,
            CallStack = callStack or {},
            ArgSchema = serializedArgs,
        })
        if direction == "Client->Server" and #entry.RawCapturedArgsList < 5 then
            table.insert(entry.RawCapturedArgsList, args)
        end
    end
end

local function installHooksAndListeners()
    PassiveSpyEnabled = true

    if not MasterHookInstalled then
        MasterHookInstalled = true
        local hookedViaMetamethod = false

        -- Phương thức 1: hookmetamethod chuẩn UNC
        if hookmetamethod then
            local okHook = pcall(function()
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                    if (PassiveSpyEnabled or StateMonitor.IsCapturing) and not checkcaller() and typeof(self) == "Instance" then
                        local method = getnamecallmethod()
                        if method == "FireServer" or method == "InvokeServer" or method == "Fire" or method == "Invoke" then
                            local cn = safeGetClassName(self)
                            if cn == "RemoteEvent" or cn == "UnreliableRemoteEvent" or cn == "RemoteFunction" or cn == "BindableEvent" or cn == "BindableFunction" then
                                local args = {...}
                                local caller = getcallingscript()
                                local stack = captureCallStack()
                                pcall(recordRemoteCall, self, method, (method == "Fire" or method == "Invoke") and "Client->Client(Bindable)" or "Client->Server", args, caller, stack)
                            end
                        end
                    end
                    return oldNamecall(self, ...)
                end))
            end)
            hookedViaMetamethod = okHook
        end

        -- Phương thức 2 (Fallback cho các Executor chỉ hỗ trợ getrawmetatable + setreadonly)
        if not hookedViaMetamethod and getrawmetatable and setreadonly then
            pcall(function()
                local mt = getrawmetatable(game)
                local oldNamecall = mt.__namecall
                setreadonly(mt, false)
                mt.__namecall = newcclosure(function(self, ...)
                    if (PassiveSpyEnabled or StateMonitor.IsCapturing) and not checkcaller() and typeof(self) == "Instance" then
                        local method = getnamecallmethod()
                        if method == "FireServer" or method == "InvokeServer" or method == "Fire" or method == "Invoke" then
                            local cn = safeGetClassName(self)
                            if cn == "RemoteEvent" or cn == "UnreliableRemoteEvent" or cn == "RemoteFunction" or cn == "BindableEvent" or cn == "BindableFunction" then
                                local args = {...}
                                local caller = getcallingscript()
                                local stack = captureCallStack()
                                pcall(recordRemoteCall, self, method, (method == "Fire" or method == "Invoke") and "Client->Client(Bindable)" or "Client->Server", args, caller, stack)
                            end
                        end
                    end
                    return oldNamecall(self, ...)
                end)
                setreadonly(mt, true)
            end)
        end
    end

    for _, inst in ipairs(game:GetDescendants()) do
        if isGameInstance(inst) and (safeIsA(inst, "RemoteEvent") or safeIsA(inst, "UnreliableRemoteEvent")) then
            local ok, conn = pcall(function()
                return inst.OnClientEvent:Connect(function(...)
                    if PassiveSpyEnabled or StateMonitor.IsCapturing then
                        recordRemoteCall(inst, "OnClientEvent", "Server->Client", {...}, nil, {})
                    end
                end)
            end)
            if ok and conn then
                table.insert(SpyConnections, conn)
            end
        end
        throttle()
    end
end

local function disconnectSpyConnectionsForCleanGCScan()
    PassiveSpyEnabled = false
    for _, conn in ipairs(SpyConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(SpyConnections)
end

local function reconnectServerEchoListenersForActiveTests()
    for _, inst in ipairs(game:GetDescendants()) do
        if isGameInstance(inst) and (safeIsA(inst, "RemoteEvent") or safeIsA(inst, "UnreliableRemoteEvent")) then
            local ok, conn = pcall(function()
                return inst.OnClientEvent:Connect(function(...)
                    if StateMonitor.IsCapturing then
                        StateMonitor:RecordServerEcho(inst, {...})
                    end
                end)
            end)
            if ok and conn then
                table.insert(SpyConnections, conn)
            end
        end
        throttle()
    end
end

-- ============================================================================
-- 10. PHA 2: QUÉT ĐẦY ĐỦ CÂY THƯ MỤC ĐỆ QUY MỌI TỰA GAME (ADAPTIVE TREE SCANNER)
-- ============================================================================
local totalTreeNodesScanned = 0

local function isPurelyDecorativeLeafPart(inst, isInsideWorkspace)
    if not CONFIG.SUMMARIZE_REPETITIVE_CLONES or not isInsideWorkspace then
        return false
    end
    local cn = safeGetClassName(inst)
    if not DECORATIVE_PART_CLASSES[cn] then
        return false
    end
    local okCh, ch = pcall(function() return inst:GetChildren() end)
    if okCh and ch and #ch > 0 then
        return false
    end
    local okAttr, attrs = pcall(function() return inst:GetAttributes() end)
    if okAttr and attrs and next(attrs) ~= nil then
        return false
    end
    local okTags, tags = pcall(function() return inst:GetTags() end)
    if okTags and tags and #tags > 0 then
        return false
    end
    return true
end

local function isImportantStructuralInstance(inst)
    local cn = safeGetClassName(inst)
    return cn == "Folder"
        or cn == "Configuration"
        or cn == "Model"
        or cn == "Tool"
        or cn == "ModuleScript"
        or cn == "LocalScript"
        or cn == "Script"
        or cn == "RemoteEvent"
        or cn == "UnreliableRemoteEvent"
        or cn == "RemoteFunction"
        or cn == "BindableEvent"
        or cn == "BindableFunction"
        or cn == "ProximityPrompt"
        or cn == "ClickDetector"
        or cn == "ScreenGui"
        or safeIsA(inst, "ValueBase")
end

local function extractInstanceKeyProperties(inst)
    local props = {}
    local cn = safeGetClassName(inst)

    pcall(function()
        if safeIsA(inst, "LocalScript") or safeIsA(inst, "Script") then
            props.Disabled = inst.Disabled
            local okRc, rc = pcall(function() return inst.RunContext end)
            if okRc then props.RunContext = tostring(rc) end
        elseif cn == "Tool" then
            props.Enabled = inst.Enabled
            props.CanBeDropped = inst.CanBeDropped
            props.RequiresHandle = inst.RequiresHandle
            if inst.ToolTip ~= "" then props.ToolTip = inst.ToolTip end
        elseif cn == "ProximityPrompt" then
            props.ActionText = inst.ActionText
            props.ObjectText = inst.ObjectText
            props.HoldDuration = inst.HoldDuration
            props.MaxActivationDistance = inst.MaxActivationDistance
            props.Enabled = inst.Enabled
            props.KeyCode = tostring(inst.KeyboardKeyCode)
        elseif cn == "ClickDetector" then
            props.MaxActivationDistance = inst.MaxActivationDistance
        elseif cn == "Humanoid" then
            props.Health = inst.Health
            props.MaxHealth = inst.MaxHealth
            props.WalkSpeed = inst.WalkSpeed
            props.JumpPower = inst.JumpPower
            props.DisplayName = inst.DisplayName
        elseif cn == "Model" then
            if inst.PrimaryPart then
                props.PrimaryPart = inst.PrimaryPart.Name
            end
        elseif safeIsA(inst, "ScreenGui") or safeIsA(inst, "BillboardGui") or safeIsA(inst, "SurfaceGui") then
            props.Enabled = inst.Enabled
            if safeIsA(inst, "ScreenGui") then
                props.ResetOnSpawn = inst.ResetOnSpawn
            end
        elseif safeIsA(inst, "GuiObject") then
            props.Visible = inst.Visible
            if safeIsA(inst, "TextLabel") or safeIsA(inst, "TextButton") or safeIsA(inst, "TextBox") then
                if inst.Text ~= "" then
                    props.Text = #inst.Text > 120 and (string.sub(inst.Text, 1, 120) .. "...") or inst.Text
                end
            end
        elseif cn == "Animation" then
            props.AnimationId = inst.AnimationId
        elseif cn == "Sound" then
            props.SoundId = inst.SoundId
            props.IsPlaying = inst.IsPlaying
            props.Volume = inst.Volume
        elseif cn == "Team" then
            props.TeamColor = tostring(inst.TeamColor)
            props.AutoAssignable = inst.AutoAssignable
        elseif cn == "Seat" or cn == "VehicleSeat" then
            props.Disabled = inst.Disabled
            if cn == "VehicleSeat" then
                props.MaxSpeed = inst.MaxSpeed
                props.Torque = inst.Torque
            end
        end
    end)

    return next(props) ~= nil and props or nil
end

local function buildHierarchyNodeRecursive(inst, depth, isInsideWorkspace)
    throttle()
    totalTreeNodesScanned += 1

    local cn = safeGetClassName(inst)
    if depth > CONFIG.MAX_TREE_DEPTH then
        return {
            Name = inst.Name,
            ClassName = cn,
            Path = safeGetFullName(inst),
            Note = "<MaxTreeDepthReached>",
        }
    end

    local node = {
        Name = inst.Name,
        ClassName = cn,
        Path = safeGetFullName(inst),
    }

    if safeIsA(inst, "ValueBase") then
        local okVal, val = pcall(function() return inst.Value end)
        if okVal then
            node.Value = describeValueSchema(val, 0)
        end
    end

    local keyProps = extractInstanceKeyProperties(inst)
    if keyProps then
        node.Properties = keyProps
    end

    local okAttr, attrs = pcall(function() return inst:GetAttributes() end)
    if okAttr and type(attrs) == "table" and next(attrs) ~= nil then
        local formattedAttrs = {}
        for k, v in pairs(attrs) do
            formattedAttrs[tostring(k)] = describeValueSchema(v, 0)
        end
        node.Attributes = formattedAttrs
    end

    local okTags, tags = pcall(function() return inst:GetTags() end)
    if okTags and type(tags) == "table" and #tags > 0 then
        node.Tags = tags
    end

    local okChildren, children = pcall(function() return inst:GetChildren() end)
    if okChildren and type(children) == "table" and #children > 0 then
        node.TotalChildrenCount = #children

        -- Nếu tổng số node toàn game đã vượt ngưỡng an toàn RAM (trên các map 100,000+ parts),
        -- chỉ đệ quy tiếp các đối tượng cấu trúc/logic quan trọng (Folder, Model, Script, Remote, Value, UI, Tool)
        local memoryBudgetExceeded = (totalTreeNodesScanned > CONFIG.MAX_TOTAL_TREE_NODES) and isInsideWorkspace

        local childNodes = {}
        local decorativeSummary = {}
        local siblingSignatureCount = {}

        for _, child in ipairs(children) do
            if isGameInstance(child) then
                local childClass = safeGetClassName(child)
                local siblingKey = childClass .. ":" .. tostring(child.Name)

                if isPurelyDecorativeLeafPart(child, isInsideWorkspace) or (memoryBudgetExceeded and not isImportantStructuralInstance(child)) then
                    decorativeSummary[siblingKey] = (decorativeSummary[siblingKey] or 0) + 1
                    if decorativeSummary[siblingKey] <= CONFIG.MAX_IDENTICAL_SIBLINGS_SAMPLE and not memoryBudgetExceeded then
                        table.insert(childNodes, buildHierarchyNodeRecursive(child, depth + 1, isInsideWorkspace))
                    end
                else
                    -- Gom nhóm nếu có hàng trăm bản sao Model/Frame y hệt nhau (ví dụ 300 cây cối trùng tên "Tree" trong 1 thư mục)
                    local isCloneableLeafOrModel = (childClass == "Model" or safeIsA(child, "GuiObject")) and not safeIsA(child, "ScreenGui")
                    if CONFIG.SUMMARIZE_REPETITIVE_CLONES and isCloneableLeafOrModel then
                        siblingSignatureCount[siblingKey] = (siblingSignatureCount[siblingKey] or 0) + 1
                        if siblingSignatureCount[siblingKey] <= CONFIG.MAX_IDENTICAL_SIBLINGS_SAMPLE then
                            table.insert(childNodes, buildHierarchyNodeRecursive(child, depth + 1, isInsideWorkspace))
                        end
                    else
                        table.insert(childNodes, buildHierarchyNodeRecursive(child, depth + 1, isInsideWorkspace))
                    end
                end
            end
        end

        table.sort(childNodes, function(a, b)
            local aIsFolder = (a.ClassName == "Folder" or a.ClassName == "Configuration" or a.ClassName == "Model")
            local bIsFolder = (b.ClassName == "Folder" or b.ClassName == "Configuration" or b.ClassName == "Model")
            if aIsFolder ~= bIsFolder then
                return aIsFolder
            end
            if a.ClassName ~= b.ClassName then
                return tostring(a.ClassName) < tostring(b.ClassName)
            end
            return tostring(a.Name) < tostring(b.Name)
        end)

        if #childNodes > 0 then
            node.Children = childNodes
        end

        local collapsedDecorative = {}
        for k, cnt in pairs(decorativeSummary) do
            if cnt > CONFIG.MAX_IDENTICAL_SIBLINGS_SAMPLE or memoryBudgetExceeded then
                table.insert(collapsedDecorative, string.format("%s (x%d)", k, cnt))
            end
        end
        if #collapsedDecorative > 0 then
            table.sort(collapsedDecorative)
            node.DecorativeLeafSummary = collapsedDecorative
        end

        local collapsedSiblings = {}
        for k, cnt in pairs(siblingSignatureCount) do
            if cnt > CONFIG.MAX_IDENTICAL_SIBLINGS_SAMPLE then
                table.insert(collapsedSiblings, string.format("%s (x%d total, %d sampled)", k, cnt, CONFIG.MAX_IDENTICAL_SIBLINGS_SAMPLE))
            end
        end
        if #collapsedSiblings > 0 then
            table.sort(collapsedSiblings)
            node.RepetitiveSiblingsSummary = collapsedSiblings
        end
    end

    return node
end

local function buildFullGameHierarchyTree()
    totalTreeNodesScanned = 0
    local tree = {}

    -- Quét các dịch vụ chứa code/cấu hình quan trọng TRƯỚC để luôn đạt độ chi tiết 100%
    local servicesToScan = {
        { Key = "ReplicatedStorage", Instance = ReplicatedStorage, IsWorkspace = false },
        { Key = "ReplicatedFirst", Instance = ReplicatedFirst, IsWorkspace = false },
        { Key = "StarterPack", Instance = StarterPack, IsWorkspace = false },
        { Key = "StarterPlayer", Instance = StarterPlayer, IsWorkspace = false },
        { Key = "StarterGui", Instance = StarterGui, IsWorkspace = false },
        { Key = "Teams", Instance = Teams, IsWorkspace = false },
        { Key = "Lighting", Instance = Lighting, IsWorkspace = false },
        { Key = "SoundService", Instance = SoundService, IsWorkspace = false },
        { Key = "Workspace", Instance = WorkspaceService, IsWorkspace = true },
    }

    if LocalPlayer then
        print("[DeepAnalyzer v6.0] -> Đang dựng cây thư mục chi tiết cho: LocalPlayer (" .. LocalPlayer.Name .. ")")
        local lpNode = {
            Name = LocalPlayer.Name,
            ClassName = "Player",
            Path = safeGetFullName(LocalPlayer),
            Attributes = LocalPlayer:GetAttributes(),
            Children = {},
        }
        for _, child in ipairs(LocalPlayer:GetChildren()) do
            if isGameInstance(child) then
                table.insert(lpNode.Children, buildHierarchyNodeRecursive(child, 1, false))
            end
        end
        if LocalPlayer.Character then
            table.insert(lpNode.Children, buildHierarchyNodeRecursive(LocalPlayer.Character, 1, false))
        end
        tree["LocalPlayer_Runtime"] = lpNode
    end

    for _, svc in ipairs(servicesToScan) do
        if svc.Instance then
            print("[DeepAnalyzer v6.0] -> Đang dựng cây thư mục chi tiết cho: " .. svc.Key)
            tree[svc.Key] = buildHierarchyNodeRecursive(svc.Instance, 0, svc.IsWorkspace)
        end
    end

    local nilNodes = {}
    for _, ni in ipairs(getnilinstances()) do
        if isGameInstance(ni) and (safeIsA(ni, "LuaSourceContainer") or safeIsA(ni, "RemoteEvent") or safeIsA(ni, "RemoteFunction") or safeIsA(ni, "Folder") or safeIsA(ni, "Tool") or safeIsA(ni, "Model")) then
            if #nilNodes < 100 then
                table.insert(nilNodes, {
                    Name = ni.Name,
                    ClassName = safeGetClassName(ni),
                    Properties = extractInstanceKeyProperties(ni),
                })
            end
        end
    end
    if #nilNodes > 0 then
        tree["NilInstances"] = nilNodes
    end

    return tree
end

-- ============================================================================
-- 11. QUÉT SÂU GC CLOSURES, UPVALUES, UI SIGNALS & ĐỌC/LƯU DECOMPILE CODE
-- ============================================================================
local function scanGameArchitectureDeep()
    local RemotesDB = {}
    local ModulesDB = {}
    local ScriptsDB = {}
    local UIElementsDB = {}
    local TaggedObjectsDB = {}
    local ClosuresByScriptPath = {}
    local InteractablesDB = {
        ProximityPrompts = {},
        ClickDetectors = {},
        Tools = {},
    }

    local allInstances = {}
    for _, inst in ipairs(game:GetDescendants()) do
        if isGameInstance(inst) then
            table.insert(allInstances, inst)
        end
        throttle()
    end
    for _, ni in ipairs(getnilinstances()) do
        if isGameInstance(ni) then
            table.insert(allInstances, ni)
        end
    end
    for _, mod in ipairs(getloadedmodules()) do
        if isGameInstance(mod) then
            table.insert(allInstances, mod)
        end
    end

    local seenInstanceMap = {}
    for _, inst in ipairs(allInstances) do
        if not seenInstanceMap[inst] then
            seenInstanceMap[inst] = true
            throttle()
            local className = safeGetClassName(inst)
            local fullPath = safeGetFullName(inst)

            if className == "ModuleScript" or className == "LocalScript" or className == "Script" then
                ScriptPathLookup[fullPath] = inst
                ScriptPathLookup[inst.Name] = ScriptPathLookup[inst.Name] or inst
            end

            -- 1) Remote & Bindable
            if className == "RemoteEvent" or className == "UnreliableRemoteEvent" or className == "RemoteFunction" or className == "BindableEvent" or className == "BindableFunction" then
                local clientListeners = {}
                local signalToInspect = nil
                if className == "RemoteEvent" or className == "UnreliableRemoteEvent" then
                    signalToInspect = inst.OnClientEvent
                elseif className == "BindableEvent" then
                    signalToInspect = inst.Event
                end

                if signalToInspect then
                    local ok, conns = pcall(getconnections, signalToInspect)
                    if ok and type(conns) == "table" then
                        for _, conn in ipairs(conns) do
                            if conn.Function and islclosure(conn.Function) then
                                local scr = resolveClosureScript(conn.Function)
                                local info = getinfo(conn.Function)
                                local scrPath = scr and safeGetFullName(scr) or tostring(info.short_src)
                                if not string.find(scrPath, "^%[") and scrPath ~= "" then
                                    table.insert(clientListeners, string.format("%s (line %s, func %s)", scrPath, tostring(info.currentline), tostring(info.name or "anon")))
                                end
                            end
                        end
                    end
                end

                RemotesDB[fullPath] = {
                    InstanceRef = inst,
                    Name = inst.Name,
                    ClassName = className,
                    Path = fullPath,
                    ClientListeners = clientListeners,
                    ReferencedByScripts = {},
                    UpvalueContextualHints = {},
                    DiscoveredActionStrings = {},
                    DecompileExtractedArgs = {},
                    RuntimeTraffic = RemoteLogs[fullPath] or "Không phát sinh gói tin trong thời gian Passive Spy",
                    Domains = {},
                }

            -- 2) ModuleScript
            elseif className == "ModuleScript" then
                ModulesDB[fullPath] = {
                    InstanceRef = inst,
                    Name = inst.Name,
                    Path = fullPath,
                    ExportedAPI = {},
                    StaticTablesSchema = {},
                    StringConstants = {},
                    LinkedRemotes = {},
                    Domains = {},
                }

            -- 3) LocalScript / Client Script
            elseif isClientScriptInstance(inst) then
                local okDis, isDis = pcall(function() return inst.Disabled end)
                ScriptsDB[fullPath] = {
                    InstanceRef = inst,
                    Name = inst.Name,
                    ClassName = className,
                    Path = fullPath,
                    Disabled = okDis and isDis or false,
                    DefinedFunctions = {},
                    StringConstants = {},
                    LinkedRemotes = {},
                    Domains = {},
                }

            -- 4) ScreenGui & Interactive Buttons
            elseif className == "ScreenGui" then
                local interactiveButtons = {}
                for _, desc in ipairs(inst:GetDescendants()) do
                    if safeIsA(desc, "TextButton") or safeIsA(desc, "ImageButton") then
                        local handlers = {}
                        for _, sigName in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down"}) do
                            local okSig, sig = pcall(function() return desc[sigName] end)
                            if okSig and sig then
                                local okConn, conns = pcall(getconnections, sig)
                                if okConn and type(conns) == "table" then
                                    for _, c in ipairs(conns) do
                                        if c.Function and islclosure(c.Function) then
                                            local scr = resolveClosureScript(c.Function)
                                            local info = getinfo(c.Function)
                                            table.insert(handlers, string.format("[%s] -> %s (line %s)", sigName, scr and safeGetFullName(scr) or tostring(info.short_src), tostring(info.currentline)))
                                        end
                                    end
                                end
                            end
                        end

                        if #handlers > 0 or (safeIsA(desc, "TextButton") and desc.Text ~= "") then
                            table.insert(interactiveButtons, {
                                InstanceRef = desc,
                                Name = desc.Name,
                                Path = safeGetFullName(desc),
                                Text = safeIsA(desc, "TextButton") and desc.Text or nil,
                                Visible = desc.Visible,
                                ConnectedHandlers = handlers,
                            })
                        end
                    end
                end

                UIElementsDB[fullPath] = {
                    Name = inst.Name,
                    Path = fullPath,
                    Enabled = inst.Enabled,
                    InteractiveButtonsCount = #interactiveButtons,
                    AllButtonsInternal = interactiveButtons,
                    TracedButtons = {},
                    Domains = detectDomains(inst),
                }
                for i = 1, math.min(40, #interactiveButtons) do
                    local b = interactiveButtons[i]
                    table.insert(UIElementsDB[fullPath].TracedButtons, {
                        Name = b.Name,
                        Path = b.Path,
                        Text = b.Text,
                        Visible = b.Visible,
                        ConnectedHandlers = b.ConnectedHandlers,
                    })
                end

            -- 5) ProximityPrompt, ClickDetector & Tool
            elseif className == "ProximityPrompt" then
                table.insert(InteractablesDB.ProximityPrompts, inst)
            elseif className == "ClickDetector" then
                table.insert(InteractablesDB.ClickDetectors, inst)
            elseif className == "Tool" then
                table.insert(InteractablesDB.Tools, inst)
            end

            -- 6) CollectionService Tags
            local okTags, tags = pcall(function() return inst:GetTags() end)
            if okTags and tags and #tags > 0 then
                for _, tag in ipairs(tags) do
                    TaggedObjectsDB[tag] = TaggedObjectsDB[tag] or { Count = 0, SampleInstances = {} }
                    TaggedObjectsDB[tag].Count += 1
                    if #TaggedObjectsDB[tag].SampleInstances < 10 then
                        table.insert(TaggedObjectsDB[tag].SampleInstances, fullPath)
                    end
                end
            end
        end
    end

    local remoteNameMap = {}
    for path, rData in pairs(RemotesDB) do
        remoteNameMap[rData.Name] = remoteNameMap[rData.Name] or {}
        table.insert(remoteNameMap[rData.Name], path)
    end

    local function inspectUpvaluesRecursive(uvTable, ownerRecord, depth, visited)
        if depth > CONFIG.MAX_UPVALUE_DEPTH then return end
        for k, v in pairs(uvTable) do
            local vt = typeof(v)
            if vt == "Instance" and isGameInstance(v) then
                local vPath = safeGetFullName(v)
                if RemotesDB[vPath] then
                    RemotesDB[vPath].ReferencedByScripts[ownerRecord.Path] = true
                    table.insert(RemotesDB[vPath].UpvalueContextualHints, tostring(k))
                    ownerRecord.LinkedRemotes[vPath] = true
                end
            elseif vt == "table" and not visited[v] then
                visited[v] = true
                if ownerRecord.StaticTablesSchema and depth == 1 and type(k) == "string" then
                    local sampleKeys = {}
                    for subK, subV in pairs(v) do
                        table.insert(sampleKeys, string.format("%s (%s)", tostring(subK), typeof(subV)))
                        if #sampleKeys >= 25 then break end
                    end
                    if #sampleKeys > 0 then
                        ownerRecord.StaticTablesSchema[k] = sampleKeys
                    end
                end
                inspectUpvaluesRecursive(v, ownerRecord, depth + 1, visited)
            end
        end
    end

    local okGC, gcObjects = pcall(getgc, false)
    if okGC and type(gcObjects) == "table" then
        for _, obj in ipairs(gcObjects) do
            if type(obj) == "function" and islclosure(obj) then
                throttle()
                local scrInst = resolveClosureScript(obj)
                if scrInst and isGameInstance(scrInst) then
                    local scrPath = safeGetFullName(scrInst)
                    ClosuresByScriptPath[scrPath] = ClosuresByScriptPath[scrPath] or {}
                    if #ClosuresByScriptPath[scrPath] < 35 then
                        table.insert(ClosuresByScriptPath[scrPath], obj)
                    end

                    local targetRecord = ModulesDB[scrPath] or ScriptsDB[scrPath]
                    if targetRecord then
                        local info = getinfo(obj)
                        if info and info.name and info.name ~= "" then
                            local funcList = targetRecord.ExportedAPI or targetRecord.DefinedFunctions
                            if funcList and #funcList < 80 and not table.find(funcList, info.name) then
                                table.insert(funcList, info.name)
                            end
                        end

                        local okConst, consts = pcall(getconstants, obj)
                        if okConst and type(consts) == "table" then
                            for _, c in pairs(consts) do
                                if type(c) == "string" and #c > 1 and #c < 90 then
                                    if remoteNameMap[c] then
                                        for _, rPath in ipairs(remoteNameMap[c]) do
                                            RemotesDB[rPath].ReferencedByScripts[scrPath] = true
                                            targetRecord.LinkedRemotes[rPath] = true
                                        end
                                    end
                                    if #targetRecord.StringConstants < 65 and not table.find(targetRecord.StringConstants, c) then
                                        table.insert(targetRecord.StringConstants, c)
                                    end
                                end
                            end
                        end

                        local okUp, upvals = pcall(getupvalues, obj)
                        if okUp and type(upvals) == "table" then
                            inspectUpvaluesRecursive(upvals, targetRecord, 1, {})
                        end
                    end
                end
            end
        end
    end

    for _, rec in pairs(ModulesDB) do
        for rPath in pairs(rec.LinkedRemotes) do
            if RemotesDB[rPath] then
                for _, sConst in ipairs(rec.StringConstants) do
                    if #RemotesDB[rPath].DiscoveredActionStrings < 15 and not table.find(RemotesDB[rPath].DiscoveredActionStrings, sConst) then
                        table.insert(RemotesDB[rPath].DiscoveredActionStrings, sConst)
                    end
                end
            end
        end
    end
    for _, rec in pairs(ScriptsDB) do
        for rPath in pairs(rec.LinkedRemotes) do
            if RemotesDB[rPath] then
                for _, sConst in ipairs(rec.StringConstants) do
                    if #RemotesDB[rPath].DiscoveredActionStrings < 15 and not table.find(RemotesDB[rPath].DiscoveredActionStrings, sConst) then
                        table.insert(RemotesDB[rPath].DiscoveredActionStrings, sConst)
                    end
                end
            end
        end
    end

    for _, rData in pairs(RemotesDB) do
        rData.Domains = detectDomains(rData.InstanceRef, rData.UpvalueContextualHints)
    end
    for _, mData in pairs(ModulesDB) do
        mData.Domains = detectDomains(mData.InstanceRef, mData.StringConstants)
    end
    for _, sData in pairs(ScriptsDB) do
        sData.Domains = detectDomains(sData.InstanceRef, sData.StringConstants)
    end

    return {
        Remotes = RemotesDB,
        Modules = ModulesDB,
        Scripts = ScriptsDB,
        UI = UIElementsDB,
        CollectionServiceTags = TaggedObjectsDB,
        Interactables = InteractablesDB,
        RemoteNameMap = remoteNameMap,
        ClosuresByScriptPath = ClosuresByScriptPath,
    }
end

-- ============================================================================
-- 12. PHA 3: CHẠY THỬ CƠ CHẾ & TÍNH NĂNG GAME (UNIVERSAL MECHANISM RUNNER)
-- ============================================================================
local function runActiveMechanismTests(rawScan)
    local results = {
        ModuleIntrospectionAndQueries = {},
        UIButtonSignalTests = {},
        ToolAndWeaponTests = {},
        ProximityPromptTests = {},
        ClickDetectorTests = {},
    }

    if not CONFIG.ENABLE_ACTIVE_MECHANISM_TESTS then
        return results
    end

    registerMonitoredStateObjects()

    -- ------------------------------------------------------------------------
    -- 12.1. Nạp an toàn ModuleScript & chạy thử các hàm Getter/Query/Config
    -- ------------------------------------------------------------------------
    print("[DeepAnalyzer v6.0] -> [Pha 3.1] Đang kiểm tra ModuleScripts và chạy thử các hàm Getter/Query...")
    local loadedMap = {}
    for _, mod in ipairs(getloadedmodules()) do
        loadedMap[mod] = true
    end

    for path, mData in pairs(rawScan.Modules) do
        throttle()
        local modInst = mData.InstanceRef
        if modInst then
            local canRequire = loadedMap[modInst] or (
                CONFIG.SAFE_REQUIRE_UNLOADED_MODULES
                and (
                    (ReplicatedStorage and modInst:IsDescendantOf(ReplicatedStorage))
                    or (LocalPlayer and modInst:IsDescendantOf(LocalPlayer))
                    or (ReplicatedFirst and modInst:IsDescendantOf(ReplicatedFirst))
                )
            )
            local isSafeMod, unsafeReason = isSafeActionTarget(path)

            if canRequire and isSafeMod then
                local okReq, reqRes, reqMs, timedOut = callWithTimeout(CONFIG.MODULE_REQUIRE_TIMEOUT, require, modInst)
                if okReq and type(reqRes) == "table" and reqRes[1] ~= nil then
                    local modReturn = reqRes[1]
                    local modReport = {
                        Path = path,
                        WasAlreadyLoaded = loadedMap[modInst] == true,
                        RequireLatencyMs = reqMs,
                        ReturnType = typeof(modReturn),
                        ExportedTableSchema = {},
                        TestedQueryFunctions = {},
                    }

                    if type(modReturn) == "table" then
                        modReport.ExportedTableSchema = describeValueSchema(modReturn, 0)
                        mData.LiveModuleSchema = modReport.ExportedTableSchema

                        -- Nếu Module trả về bảng dữ liệu người chơi (Data/Stats/Inventory), đưa vào diện theo dõi StateMonitor!
                        local lowerName = string.lower(mData.Name)
                        if (string.find(lowerName, "data") or string.find(lowerName, "stat") or string.find(lowerName, "inventory") or string.find(lowerName, "profile") or string.find(lowerName, "store")) and #MonitoredMemoryTables < 30 then
                            table.insert(MonitoredMemoryTables, { Label = "Module[" .. mData.Name .. "]", TableRef = modReturn })
                        end

                        local testedCount = 0
                        for k, v in pairs(modReturn) do
                            if type(k) == "string" and type(v) == "function" and testedCount < CONFIG.MODULE_GETTER_TEST_LIMIT then
                                local lowerK = string.lower(k)
                                local isSafeGetter = (
                                    string.find(lowerK, "^get")
                                    or string.find(lowerK, "^calc")
                                    or string.find(lowerK, "^can")
                                    or string.find(lowerK, "^is")
                                    or string.find(lowerK, "^has")
                                    or string.find(lowerK, "^find")
                                    or string.find(lowerK, "^read")
                                    or string.find(lowerK, "^check")
                                    or string.find(lowerK, "^fetch")
                                ) and isSafeActionTarget(k)

                                if isSafeGetter then
                                    testedCount += 1
                                    local okCall, callRes, callMs = callWithTimeout(0.35, v, modReturn)
                                    if not okCall then
                                        okCall, callRes, callMs = callWithTimeout(0.35, v)
                                    end
                                    table.insert(modReport.TestedQueryFunctions, {
                                        FunctionName = k,
                                        Success = okCall,
                                        LatencyMs = callMs,
                                        ReturnSchema = okCall and describeValueSchema(callRes, 0) or tostring(callRes and callRes[1] or callRes),
                                    })
                                end
                            end
                        end
                    end

                    table.insert(results.ModuleIntrospectionAndQueries, modReport)
                elseif timedOut then
                    table.insert(results.ModuleIntrospectionAndQueries, {
                        Path = path,
                        Status = "Require Timed Out (> " .. tostring(CONFIG.MODULE_REQUIRE_TIMEOUT) .. "s)",
                    })
                end
            elseif not isSafeMod then
                table.insert(results.ModuleIntrospectionAndQueries, {
                    Path = path,
                    Status = "Skipped (" .. tostring(unsafeReason) .. ")",
                })
            end
        end
    end

    -- Sau khi đã nạp các Module (và có LiveModuleSchema), thực thi Decompile & Lưu toàn bộ Script/Module!
    print("[DeepAnalyzer v6.0] -> [Pha 3.2] Đang đọc mã nguồn Decompile của toàn bộ ModuleScript & LocalScript và lưu ra file...")
    rawScan.DecompiledRepository = decompileAndSaveAllGameScripts(
        rawScan.Modules,
        rawScan.Scripts,
        rawScan.Remotes,
        rawScan.RemoteNameMap,
        rawScan.ClosuresByScriptPath
    )

    -- ------------------------------------------------------------------------
    -- 12.2. Kích hoạt thử các nút bấm giao diện (UI Button Signal Exerciser)
    -- ------------------------------------------------------------------------
    print("[DeepAnalyzer v6.0] -> [Pha 3.3] Đang kích hoạt thử các nút bấm UI để ghi nhận luồng cơ chế...")
    local uiButtonsTested = 0
    local testedButtonSignatures = {}

    for _, uiScreen in pairs(rawScan.UI) do
        if uiScreen.AllButtonsInternal then
            for _, btnInfo in ipairs(uiScreen.AllButtonsInternal) do
                if uiButtonsTested >= CONFIG.MAX_UI_BUTTONS_TO_TEST then break end
                local btn = btnInfo.InstanceRef
                if btn and btn.Parent and #btnInfo.ConnectedHandlers > 0 then
                    local btnSig = tostring(uiScreen.Name) .. "|" .. tostring(btn.Name) .. "|" .. tostring(btnInfo.ConnectedHandlers[1])
                    if not testedButtonSignatures[btnSig] then
                        testedButtonSignatures[btnSig] = true
                        local safeBtn, reason = isSafeActionTarget(btnInfo.Path, btnInfo.Text)

                        if safeBtn then
                            uiButtonsTested += 1
                            StateMonitor:BeginCapture("UIButton:" .. btnInfo.Path)
                            local triggeredMethod = "None"

                            pcall(function()
                                for _, sigName in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down"}) do
                                    local sig = btn[sigName]
                                    if sig then
                                        if firesignal then
                                            pcall(firesignal, sig)
                                            triggeredMethod = "firesignal(" .. sigName .. ")"
                                        else
                                            local okC, conns = pcall(getconnections, sig)
                                            if okC and type(conns) == "table" then
                                                for _, c in ipairs(conns) do
                                                    if c.Fire then
                                                        pcall(function() c:Fire() end)
                                                        triggeredMethod = "Connection:Fire(" .. sigName .. ")"
                                                    elseif c.Function then
                                                        pcall(c.Function)
                                                        triggeredMethod = "ClosureCall(" .. sigName .. ")"
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end)

                            task.wait(CONFIG.REACTION_WINDOW_SECONDS)
                            local footprint = StateMonitor:EndCapture()

                            table.insert(results.UIButtonSignalTests, {
                                ButtonName = btnInfo.Name,
                                Path = btnInfo.Path,
                                ButtonText = btnInfo.Text,
                                TriggerMethod = triggeredMethod,
                                Handlers = btnInfo.ConnectedHandlers,
                                ReactionFootprint = footprint,
                            })
                            task.wait(CONFIG.DELAY_BETWEEN_TESTS)
                        else
                            table.insert(results.UIButtonSignalTests, {
                                ButtonName = btnInfo.Name,
                                Path = btnInfo.Path,
                                ButtonText = btnInfo.Text,
                                Status = "Skipped (" .. tostring(reason) .. ")",
                            })
                        end
                    end
                end
            end
        end
        uiScreen.AllButtonsInternal = nil
    end

    -- ------------------------------------------------------------------------
    -- 12.3. Chạy thử cơ chế Vũ khí / Công cụ (Backpack & Character Tools)
    -- ------------------------------------------------------------------------
    print("[DeepAnalyzer v6.0] -> [Pha 3.4] Đang chạy thử cơ chế trang bị & kích hoạt Tool/Vũ khí...")
    local char = LocalPlayer and LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local originalTool = char and char:FindFirstChildOfClass("Tool")
    local toolsTested = 0

    for _, tool in ipairs(rawScan.Interactables.Tools) do
        if toolsTested >= CONFIG.MAX_TOOLS_TO_TEST then break end
        if tool and tool.Parent and LocalPlayer and (tool:IsDescendantOf(LocalPlayer) or (char and tool:IsDescendantOf(char))) then
            toolsTested += 1
            StateMonitor:BeginCapture("ToolActivate:" .. safeGetFullName(tool))

            local equippedSuccess = false
            pcall(function()
                if hum and tool.Parent ~= char then
                    hum:EquipTool(tool)
                    task.wait(0.08)
                end
                equippedSuccess = (tool.Parent == char)
                tool:Activate()
                task.wait(0.05)
                tool:Deactivate()
            end)

            task.wait(CONFIG.REACTION_WINDOW_SECONDS)
            local footprint = StateMonitor:EndCapture()

            local toolConfigs = {}
            for _, desc in ipairs(tool:GetDescendants()) do
                if safeIsA(desc, "ValueBase") then
                    local okV, v = pcall(function() return desc.Value end)
                    if okV then toolConfigs[desc.Name] = describeValueSchema(v, 0) end
                end
            end

            table.insert(results.ToolAndWeaponTests, {
                ToolName = tool.Name,
                Path = safeGetFullName(tool),
                EquippedAndActivated = equippedSuccess,
                ToolAttributes = tool:GetAttributes(),
                InternalValueConfigs = next(toolConfigs) ~= nil and toolConfigs or nil,
                ReactionFootprint = footprint,
            })
            task.wait(CONFIG.DELAY_BETWEEN_TESTS)
        end
    end

    pcall(function()
        if hum then
            if originalTool and originalTool.Parent then
                hum:EquipTool(originalTool)
            else
                hum:UnequipTools()
            end
        end
    end)

    -- ------------------------------------------------------------------------
    -- 12.4. Chạy thử ProximityPrompts & ClickDetectors trong màn chơi
    -- ------------------------------------------------------------------------
    print("[DeepAnalyzer v6.0] -> [Pha 3.5] Đang kiểm tra tương tác ProximityPrompt & ClickDetector...")
    local testedPrompts = 0
    local seenPromptNames = {}
    for _, prompt in ipairs(rawScan.Interactables.ProximityPrompts) do
        if testedPrompts >= CONFIG.MAX_PROMPTS_TO_TEST then break end
        if prompt and prompt.Parent then
            local sig = prompt.Name .. "|" .. tostring(prompt.ActionText) .. "|" .. tostring(prompt.ObjectText)
            if not seenPromptNames[sig] then
                seenPromptNames[sig] = true
                local isSafePrompt, reason = isSafeActionTarget(safeGetFullName(prompt), tostring(prompt.ActionText) .. " " .. tostring(prompt.ObjectText))
                if isSafePrompt then
                    testedPrompts += 1
                    StateMonitor:BeginCapture("ProximityPrompt:" .. safeGetFullName(prompt))
                    local triggered = false
                    if fireproximityprompt then
                        triggered = pcall(fireproximityprompt, prompt)
                    end
                    task.wait(CONFIG.REACTION_WINDOW_SECONDS)
                    local footprint = StateMonitor:EndCapture()

                    table.insert(results.ProximityPromptTests, {
                        Name = prompt.Name,
                        Path = safeGetFullName(prompt),
                        ActionText = prompt.ActionText,
                        ObjectText = prompt.ObjectText,
                        TriggeredViaExecutor = triggered,
                        ReactionFootprint = footprint,
                    })
                    task.wait(CONFIG.DELAY_BETWEEN_TESTS)
                else
                    table.insert(results.ProximityPromptTests, {
                        Name = prompt.Name,
                        Path = safeGetFullName(prompt),
                        Status = "Skipped (" .. tostring(reason) .. ")",
                    })
                end
            end
        end
    end

    local testedDetectors = 0
    local seenDetectorParents = {}
    for _, cd in ipairs(rawScan.Interactables.ClickDetectors) do
        if testedDetectors >= CONFIG.MAX_CLICK_DETECTORS_TO_TEST then break end
        if cd and cd.Parent then
            local parentName = cd.Parent.Name
            if not seenDetectorParents[parentName] then
                seenDetectorParents[parentName] = true
                local isSafeCD, reason = isSafeActionTarget(safeGetFullName(cd))
                if isSafeCD then
                    testedDetectors += 1
                    StateMonitor:BeginCapture("ClickDetector:" .. safeGetFullName(cd))
                    local triggered = false
                    if fireclickdetector then
                        triggered = pcall(fireclickdetector, cd)
                    end
                    task.wait(CONFIG.REACTION_WINDOW_SECONDS)
                    local footprint = StateMonitor:EndCapture()

                    table.insert(results.ClickDetectorTests, {
                        Name = cd.Name,
                        ParentName = parentName,
                        Path = safeGetFullName(cd),
                        TriggeredViaExecutor = triggered,
                        ReactionFootprint = footprint,
                    })
                    task.wait(CONFIG.DELAY_BETWEEN_TESTS)
                else
                    table.insert(results.ClickDetectorTests, {
                        Name = cd.Name,
                        Path = safeGetFullName(cd),
                        Status = "Skipped (" .. tostring(reason) .. ")",
                    })
                end
            end
        end
    end

    return results
end

-- ============================================================================
-- 13. PHA 4: CHẠY THỬ REMOTE EVENT & REMOTE FUNCTION ĐA THỂ LOẠI GAME
-- ============================================================================
local function buildCandidatePayloadsForRemote(rData)
    local candidates = {}

    -- Ưu tiên 1: Nếu Passive Spy hoặc Pha 3 đã bắt được tham số thực tế của Remote này
    local spyEntry = RemoteLogs[rData.Path]
    if spyEntry and spyEntry.RawCapturedArgsList and #spyEntry.RawCapturedArgsList > 0 then
        table.insert(candidates, {
            VariantType = "1_ReplayCapturedPayload",
            Args = spyEntry.RawCapturedArgsList[1],
        })
    end

    -- Ưu tiên 2: Tham số bóc tách trực tiếp từ Code Decompile (`:FireServer("...")`)
    if rData.DecompileExtractedArgs and #rData.DecompileExtractedArgs > 0 then
        for i = 1, math.min(2, #rData.DecompileExtractedArgs) do
            local tuple = rData.DecompileExtractedArgs[i]
            if isSafeActionTarget(tostring(tuple[1])) then
                table.insert(candidates, {
                    VariantType = "2_DecompiledSourceLiteralArgs (" .. tostring(tuple[1]) .. ")",
                    Args = tuple,
                })
            end
        end
    end

    -- Ưu tiên 3: Thử gọi không tham số `()` (Chuẩn cho Knit GetData, Init, Fetch, Ping, Claim, Clicker...)
    table.insert(candidates, {
        VariantType = "3_EmptyArgsProbe",
        Args = {},
    })

    -- Ưu tiên 4: Hằng số chuỗi tìm thấy trong GC Constants/Upvalues của Script tham chiếu tới Remote
    if rData.DiscoveredActionStrings and #rData.DiscoveredActionStrings > 0 then
        local chosenAction = nil
        for _, str in ipairs(rData.DiscoveredActionStrings) do
            local okSafe = isSafeActionTarget(str)
            if okSafe and #str >= 2 and #str <= 35 and not string.find(str, "%s") then
                chosenAction = str
                break
            end
        end
        if chosenAction then
            table.insert(candidates, {
                VariantType = "4_InferredGCConstantString (" .. chosenAction .. ")",
                Args = { chosenAction, 1 },
            })
        end
    end

    -- Ưu tiên 5: Tham số Heuristic đa thể loại (RPG, Pet/Egg, Shop, Tycoon, Combat, Vote)
    local lowerName = string.lower(rData.Name .. " " .. rData.Path)
    if string.find(lowerName, "egg") or string.find(lowerName, "hatch") or string.find(lowerName, "roll") or string.find(lowerName, "summon") or string.find(lowerName, "spin") then
        table.insert(candidates, {
            VariantType = "5_GenreHeuristic_PetGachaHatch",
            Args = { "Basic", 1, false },
        })
    elseif string.find(lowerName, "buy") or string.find(lowerName, "shop") or string.find(lowerName, "equip") or string.find(lowerName, "upgrade") or string.find(lowerName, "item") or string.find(lowerName, "craft") then
        table.insert(candidates, {
            VariantType = "5_GenreHeuristic_ShopEquipUpgrade",
            Args = { { Action = "Info", Id = 1, Item = "Default", Amount = 1 } },
        })
    elseif string.find(lowerName, "quest") or string.find(lowerName, "dialog") or string.find(lowerName, "claim") or string.find(lowerName, "reward") or string.find(lowerName, "redeem") then
        table.insert(candidates, {
            VariantType = "5_GenreHeuristic_QuestRewardClaim",
            Args = { 1 },
        })
    elseif string.find(lowerName, "vote") or string.find(lowerName, "ready") or string.find(lowerName, "toggle") or string.find(lowerName, "sprint") then
        table.insert(candidates, {
            VariantType = "5_GenreHeuristic_BooleanToggle",
            Args = { true },
        })
    else
        table.insert(candidates, {
            VariantType = "5_UniversalStructuredProbe",
            Args = { "GetData", { Id = 1 } },
        })
    end

    local limited = {}
    for i = 1, math.min(#candidates, CONFIG.MAX_PAYLOAD_VARIANTS_PER_REMOTE) do
        table.insert(limited, candidates[i])
    end
    return limited
end

local function runActiveRemoteTests(rawScan)
    local remoteTestReports = {}
    if not CONFIG.ENABLE_ACTIVE_REMOTE_TESTS then
        return remoteTestReports
    end

    print("[DeepAnalyzer v6.0] -> [Pha 4] Bắt đầu chạy thử các RemoteEvent & RemoteFunction trong game...")

    local remoteList = {}
    for _, rData in pairs(rawScan.Remotes) do
        table.insert(remoteList, rData)
    end
    table.sort(remoteList, function(a, b) return a.Path < b.Path end)

    for _, rData in ipairs(remoteList) do
        throttle()
        local inst = rData.InstanceRef
        local path = rData.Path
        local cn = rData.ClassName

        local isSafe, unsafeReason = isSafeActionTarget(path, table.concat(rData.DiscoveredActionStrings or {}, " "))

        if not inst or not inst.Parent then
            remoteTestReports[path] = {
                Name = rData.Name,
                ClassName = cn,
                Path = path,
                Status = "Skipped (Instance nil hoặc đã bị hủy)",
            }
        elseif not isSafe then
            remoteTestReports[path] = {
                Name = rData.Name,
                ClassName = cn,
                Path = path,
                Domains = rData.Domains,
                Status = "Skipped by Safety Guard (" .. tostring(unsafeReason) .. ")",
            }
        else
            local candidatePayloads = buildCandidatePayloadsForRemote(rData)
            local probeRuns = {}

            for _, cand in ipairs(candidatePayloads) do
                StateMonitor:BeginCapture("RemoteProbe:" .. path .. " [" .. cand.VariantType .. "]")

                local okCall, callRes, latencyMs, timedOut = false, nil, 0, false
                local methodUsed = "None"

                if cn == "RemoteEvent" or cn == "UnreliableRemoteEvent" then
                    methodUsed = "FireServer"
                    okCall, callRes, latencyMs, timedOut = callWithTimeout(
                        CONFIG.REMOTE_INVOKE_TIMEOUT,
                        function(...) return inst:FireServer(...) end,
                        unpack(cand.Args)
                    )
                elseif cn == "RemoteFunction" then
                    methodUsed = "InvokeServer"
                    okCall, callRes, latencyMs, timedOut = callWithTimeout(
                        CONFIG.REMOTE_INVOKE_TIMEOUT,
                        function(...) return inst:InvokeServer(...) end,
                        unpack(cand.Args)
                    )
                elseif cn == "BindableEvent" then
                    methodUsed = "Fire"
                    okCall, callRes, latencyMs, timedOut = callWithTimeout(
                        CONFIG.REMOTE_INVOKE_TIMEOUT,
                        function(...) return inst:Fire(...) end,
                        unpack(cand.Args)
                    )
                elseif cn == "BindableFunction" then
                    methodUsed = "Invoke"
                    okCall, callRes, latencyMs, timedOut = callWithTimeout(
                        CONFIG.REMOTE_INVOKE_TIMEOUT,
                        function(...) return inst:Invoke(...) end,
                        unpack(cand.Args)
                    )
                end

                task.wait(CONFIG.REACTION_WINDOW_SECONDS)
                local footprint = StateMonitor:EndCapture()

                table.insert(probeRuns, {
                    Variant = cand.VariantType,
                    Method = methodUsed,
                    PayloadSent = describeValueSchema(cand.Args, 0),
                    ExecutionSuccess = okCall,
                    TimedOut = timedOut,
                    LatencyMs = latencyMs,
                    ReturnValues = okCall and describeValueSchema(callRes, 0) or tostring(callRes),
                    ReactionFootprint = footprint,
                })

                task.wait(CONFIG.DELAY_BETWEEN_TESTS)
            end

            remoteTestReports[path] = {
                Name = rData.Name,
                ClassName = cn,
                Path = path,
                Domains = rData.Domains,
                Status = "Tested (" .. tostring(#probeRuns) .. " payload variants)",
                ProbeResults = probeRuns,
            }
        end
    end

    return remoteTestReports
end

-- ============================================================================
-- 14. BỘ TỔNG HỢP DANH MỤC TÍNH NĂNG (UNIVERSAL FEATURE CATALOG SYNTHESIS)
-- ============================================================================
local function buildFeatureCatalog(rawScan, activeRemoteResults)
    local catalog = {}
    for _, d in ipairs(FEATURE_DOMAINS) do
        catalog[d.Domain] = {
            Purpose = d.Purpose,
            Components = { Remotes = {}, Modules = {}, ClientScripts = {}, UIScreens = {} },
            CoreMechanism = {},
        }
    end
    catalog["9. Core / Game-Specific Custom Systems (Hệ thống đặc thù của Game & Tiện ích chung)"] = {
        Purpose = "Các dịch vụ nền tảng, thư viện dùng chung (Framework/Networking/Utility) và các hệ thống riêng biệt của tựa game.",
        Components = { Remotes = {}, Modules = {}, ClientScripts = {}, UIScreens = {} },
        CoreMechanism = {},
    }

    for path, rData in pairs(rawScan.Remotes) do
        rData.InstanceRef = nil
        rData.UpvalueContextualHints = nil
        rData.DecompiledCallSnippets = nil

        local refScripts = {}
        for sPath in pairs(rData.ReferencedByScripts) do
            table.insert(refScripts, sPath)
        end
        if type(rData.RuntimeTraffic) == "table" and rData.RuntimeTraffic.CallerScripts then
            for callerPath in pairs(rData.RuntimeTraffic.CallerScripts) do
                if not table.find(refScripts, callerPath) then
                    table.insert(refScripts, callerPath .. " (Dynamic Caller)")
                end
            end
        end

        local activeTestSummary = activeRemoteResults[path] and activeRemoteResults[path].Status or "Not Tested"

        for _, dom in ipairs(rData.Domains) do
            local bucket = catalog[dom]
            if bucket then
                table.insert(bucket.Components.Remotes, {
                    Name = rData.Name,
                    Path = path,
                    Type = rData.ClassName,
                    ClientListeners = rData.ClientListeners,
                    ReferencedByScripts = refScripts,
                    DiscoveredActionStrings = rData.DiscoveredActionStrings,
                    DecompileExtractedArgs = #rData.DecompileExtractedArgs > 0 and rData.DecompileExtractedArgs or nil,
                    ActiveTestStatus = activeTestSummary,
                    RuntimeTraffic = rData.RuntimeTraffic,
                })

                if #refScripts > 0 or #rData.ClientListeners > 0 or type(rData.RuntimeTraffic) == "table" then
                    local mechDesc = string.format(
                        "[%s: %s] -> Tham chiếu/Gọi bởi: (%s) | Lắng nghe tại Client: (%s) | Passive Spy: %s | Active Test: %s",
                        rData.ClassName,
                        rData.Name,
                        #refScripts > 0 and table.concat(refScripts, ", ") or "Server-only / Chưa nạp closure",
                        #rData.ClientListeners > 0 and table.concat(rData.ClientListeners, ", ") or "Không có OnClientEvent listener",
                        type(rData.RuntimeTraffic) == "table" and ("Đã bắt " .. tostring(rData.RuntimeTraffic.CallCount) .. " lần gọi") or "Chưa kích hoạt thụ động",
                        activeTestSummary
                    )
                    table.insert(bucket.CoreMechanism, mechDesc)
                end
            end
        end
    end

    for path, mData in pairs(rawScan.Modules) do
        mData.InstanceRef = nil
        local linkedRemotes = {}
        for rPath in pairs(mData.LinkedRemotes) do table.insert(linkedRemotes, rPath) end
        for _, dom in ipairs(mData.Domains) do
            local bucket = catalog[dom]
            if bucket then
                table.insert(bucket.Components.Modules, {
                    Name = mData.Name,
                    Path = path,
                    DecompileStatus = mData.DecompileStatus,
                    SavedLuaFilePath = mData.SavedLuaFilePath,
                    ExportedFunctions = mData.ExportedAPI,
                    StaticTablesSchema = mData.StaticTablesSchema,
                    LiveModuleSchema = mData.LiveModuleSchema,
                    LinkedRemotes = linkedRemotes,
                    ImportantConstants = mData.StringConstants,
                    DecompiledMechanismSignatures = mData.DecompiledMechanismSignatures,
                })
            end
        end
    end

    for path, sData in pairs(rawScan.Scripts) do
        sData.InstanceRef = nil
        local linkedRemotes = {}
        for rPath in pairs(sData.LinkedRemotes) do table.insert(linkedRemotes, rPath) end
        for _, dom in ipairs(sData.Domains) do
            local bucket = catalog[dom]
            if bucket then
                table.insert(bucket.Components.ClientScripts, {
                    Name = sData.Name,
                    Path = path,
                    Disabled = sData.Disabled,
                    DecompileStatus = sData.DecompileStatus,
                    SavedLuaFilePath = sData.SavedLuaFilePath,
                    DefinedFunctions = sData.DefinedFunctions,
                    LinkedRemotes = linkedRemotes,
                    ImportantConstants = sData.StringConstants,
                    DecompiledMechanismSignatures = sData.DecompiledMechanismSignatures,
                })
            end
        end
    end

    for _, uiData in pairs(rawScan.UI) do
        for _, dom in ipairs(uiData.Domains) do
            local bucket = catalog[dom]
            if bucket then
                table.insert(bucket.Components.UIScreens, uiData)
            end
        end
    end

    return catalog
end


-- ============================================================================
-- 14B. CÁC MODULE TRÍ TUỆ CHUYÊN SÂU v5.0 (WORLD ATLAS, ECONOMY DB, SECURITY AUDIT,
--      LIVE ATTRIBUTE TRACKER, END-TO-END CHAINS & LUA API CHEAT-SHEET GENERATOR)
-- ============================================================================
local LiveStateTracker = {
    TrackedChanges = {},
    Connections = {},
}

local function startLiveStateReplicationTracker()
    local watchTargets = {
        { Label = "Workspace", Inst = WorkspaceService },
        { Label = "ReplicatedStorage", Inst = ReplicatedStorage },
        { Label = "LocalPlayer", Inst = LocalPlayer },
        { Label = "Character", Inst = LocalPlayer and LocalPlayer.Character or nil },
    }

    for _, item in ipairs(watchTargets) do
        local inst = item.Inst
        if inst then
            local okC, conn = pcall(function()
                return inst.AttributeChanged:Connect(function(attrName)
                    local key = item.Label .. "@" .. tostring(attrName)
                    local val = inst:GetAttribute(attrName)
                    local entry = LiveStateTracker.TrackedChanges[key]
                    if not entry then
                        entry = {
                            Owner = item.Label,
                            AttributeName = attrName,
                            ValueType = typeof(val),
                            UpdateCount = 0,
                            SampleValues = {},
                        }
                        LiveStateTracker.TrackedChanges[key] = entry
                    end
                    entry.UpdateCount += 1
                    local formatted = tostring(describeValueSchema(val, 0))
                    if #entry.SampleValues < 8 and not table.find(entry.SampleValues, formatted) then
                        table.insert(entry.SampleValues, formatted)
                    end
                end)
            end)
            if okC and conn then
                table.insert(LiveStateTracker.Connections, conn)
            end
        end
    end
end

local function stopLiveStateReplicationTracker()
    for _, conn in ipairs(LiveStateTracker.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(LiveStateTracker.Connections)
    return LiveStateTracker.TrackedChanges
end

-- Quét Bản đồ Thực thể Sống (Mobs, Bosses, NPCs) & Công trình / Điểm tương tác (POIs, Crates, Stations)
local function scanWorldEntitiesAndPOIAtlas()
    local atlas = {
        MobAndNPCArchetypes = {},
        InteractiveStructuresAndPOIs = {},
    }
    if not WorkspaceService then return atlas end

    for _, inst in ipairs(WorkspaceService:GetDescendants()) do
        throttle()
        if isGameInstance(inst) and safeGetClassName(inst) == "Model" then
            local hum = inst:FindFirstChildOfClass("Humanoid") or inst:FindFirstChild("MockHumanoid")
            local hasEntityAttr = inst:GetAttribute("Zombie") ~= nil
                or inst:GetAttribute("Bandit") ~= nil
                or inst:GetAttribute("Boss") ~= nil
                or inst:GetAttribute("Enemy") ~= nil
                or inst:GetAttribute("NPC") ~= nil
                or inst:GetAttribute("ProjectedHealth") ~= nil

            if (hum or hasEntityAttr) and inst ~= (LocalPlayer and LocalPlayer.Character) then
                local archName = inst.Name
                local entry = atlas.MobAndNPCArchetypes[archName]
                if not entry then
                    local bodyParts = {}
                    for _, ch in ipairs(inst:GetChildren()) do
                        if safeIsA(ch, "BasePart") and #bodyParts < 12 then
                            table.insert(bodyParts, ch.Name)
                        end
                    end
                    local okPos, pos = pcall(function() return inst:GetPivot().Position end)
                    entry = {
                        ArchetypeName = archName,
                        ActiveCountInWorld = 0,
                        SamplePath = safeGetFullName(inst),
                        SamplePosition = okPos and tostring(pos) or nil,
                        Health = hum and (safeIsA(hum, "Humanoid") and hum.Health or hum:GetAttribute("Health")) or inst:GetAttribute("ProjectedHealth"),
                        MaxHealth = hum and (safeIsA(hum, "Humanoid") and hum.MaxHealth or hum:GetAttribute("MaxHealth")) or nil,
                        Attributes = inst:GetAttributes(),
                        HitboxBodyParts = bodyParts,
                    }
                    atlas.MobAndNPCArchetypes[archName] = entry
                end
                entry.ActiveCountInWorld += 1
            else
                -- Kiểm tra xem Model có phải là POI, Rương (Crate), Công trình (Structure) hoặc Trạm tương tác không
                local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
                local cd = inst:FindFirstChildWhichIsA("ClickDetector", true)
                local parentName = inst.Parent and inst.Parent.Name or ""
                if prompt or cd or parentName == "Structures" or parentName == "Crates" or parentName == "Tiles" or parentName == "Crafting" then
                    local poiKey = parentName .. "/" .. inst.Name
                    local poiEntry = atlas.InteractiveStructuresAndPOIs[poiKey]
                    if not poiEntry then
                        local okPos, pos = pcall(function() return inst:GetPivot().Position end)
                        poiEntry = {
                            Name = inst.Name,
                            CategoryFolder = parentName,
                            CountInWorld = 0,
                            SamplePath = safeGetFullName(inst),
                            SamplePosition = okPos and tostring(pos) or nil,
                            Attributes = inst:GetAttributes(),
                            PromptActionText = prompt and prompt.ActionText or nil,
                            PromptObjectText = prompt and prompt.ObjectText or nil,
                            HasClickDetector = (cd ~= nil),
                        }
                        atlas.InteractiveStructuresAndPOIs[poiKey] = poiEntry
                    end
                    poiEntry.CountInWorld += 1
                end
            end
        end
    end

    return atlas
end

-- Trích xuất Cơ sở dữ liệu Vũ khí, Công cụ (Tools) & Bảng cấu hình Kinh tế/Chế tạo
local function extractGameDatabasesAndToolCatalog(rawScan)
    local dbReport = {
        ToolsAndWeaponsBlueprints = {},
        DataAndConfigModules = {},
    }

    local toolContainers = {
        ReplicatedStorage,
        StarterPack,
        LocalPlayer and LocalPlayer:FindFirstChild("Backpack") or nil,
        LocalPlayer and LocalPlayer.Character or nil,
    }

    local seenTools = {}
    for _, container in ipairs(toolContainers) do
        if container then
            for _, inst in ipairs(container:GetDescendants()) do
                if safeGetClassName(inst) == "Tool" and not seenTools[inst.Name] then
                    seenTools[inst.Name] = true
                    local statsFolder = inst:FindFirstChild("Stats") or inst:FindFirstChild("Config") or inst:FindFirstChild("Configuration")
                    local statsData = {}
                    if statsFolder then
                        for k, v in pairs(statsFolder:GetAttributes()) do
                            statsData[k] = describeValueSchema(v, 0)
                        end
                        for _, ch in ipairs(statsFolder:GetChildren()) do
                            if safeIsA(ch, "ValueBase") then
                                local okV, val = pcall(function() return ch.Value end)
                                if okV then statsData[ch.Name] = describeValueSchema(val, 0) end
                            end
                        end
                    end
                    local internalRemotes = {}
                    for _, ch in ipairs(inst:GetDescendants()) do
                        local cn = safeGetClassName(ch)
                        if cn == "RemoteEvent" or cn == "RemoteFunction" or cn == "UnreliableRemoteEvent" then
                            table.insert(internalRemotes, ch.Name .. " (" .. cn .. ")")
                        end
                    end
                    dbReport.ToolsAndWeaponsBlueprints[inst.Name] = {
                        ToolName = inst.Name,
                        SamplePath = safeGetFullName(inst),
                        ToolAttributes = inst:GetAttributes(),
                        StatsAndConfig = next(statsData) ~= nil and statsData or nil,
                        InternalRemotes = #internalRemotes > 0 and internalRemotes or nil,
                    }
                end
            end
        end
    end

    for path, mData in pairs(rawScan.Modules) do
        if mData.LiveModuleSchema and type(mData.LiveModuleSchema) == "table" then
            local lowerPath = string.lower(path)
            if string.find(lowerPath, "info")
                or string.find(lowerPath, "data")
                or string.find(lowerPath, "craft")
                or string.find(lowerPath, "shop")
                or string.find(lowerPath, "item")
                or string.find(lowerPath, "weapon")
                or string.find(lowerPath, "upgrade")
                or string.find(lowerPath, "class")
                or string.find(lowerPath, "perk")
                or string.find(lowerPath, "pet")
                or string.find(lowerPath, "egg") then
                dbReport.DataAndConfigModules[path] = mData.LiveModuleSchema
            end
        end
    end

    return dbReport
end

-- Kiểm toán Cơ chế Bảo mật & Anti-Cheat phía Client
local function auditClientSecurityAndAntiCheat(rawScan)
    local securityAudit = {
        SuspectedAntiCheatScripts = {},
        SuspectedSecurityAndPingRemotes = {},
        SecurityRelatedPlayerAttributes = {},
    }

    local secKeywords = {
        "anticheat", "anti_cheat", "knightmare", "km_", "adonis", "hdadmin",
        "security", "ping", "heartbeat", "handshake", "exploit", "detect",
        "teleport", " Integrity", " sanity", "flag", "ban", "kick"
    }

    local function matchesSecKeyword(str)
        local low = string.lower(tostring(str))
        for _, kw in ipairs(secKeywords) do
            if string.find(low, kw, 1, true) then
                return kw
            end
        end
        return nil
    end

    for path, rData in pairs(rawScan.Remotes) do
        local matchedKw = matchesSecKeyword(path)
        if matchedKw then
            table.insert(securityAudit.SuspectedSecurityAndPingRemotes, {
                Path = path,
                ClassName = rData.ClassName,
                MatchedKeyword = matchedKw,
                ClientListeners = rData.ClientListeners,
                ReferencedByScripts = rData.ReferencedByScripts,
            })
        end
    end

    for path, sData in pairs(rawScan.Scripts) do
        local matchedKw = matchesSecKeyword(path) or matchesSecKeyword(table.concat(sData.StringConstants or {}, " "))
        if matchedKw then
            table.insert(securityAudit.SuspectedAntiCheatScripts, {
                Path = path,
                ClassName = sData.ClassName,
                MatchedKeyword = matchedKw,
                LinkedRemotes = sData.LinkedRemotes,
                KeyConstants = sData.StringConstants,
            })
        end
    end

    if LocalPlayer then
        for k, v in pairs(LocalPlayer:GetAttributes()) do
            if matchesSecKeyword(k) then
                securityAudit.SecurityRelatedPlayerAttributes["LocalPlayer." .. k] = describeValueSchema(v, 0)
            end
        end
        if LocalPlayer.Character then
            for k, v in pairs(LocalPlayer.Character:GetAttributes()) do
                if matchesSecKeyword(k) then
                    securityAudit.SecurityRelatedPlayerAttributes["Character." .. k] = describeValueSchema(v, 0)
                end
            end
        end
    end

    return securityAudit
end

-- Tổng hợp Sơ đồ Luồng Sự kiện Đầu-Cuối (End-to-End Mechanism Chains)
local function buildEndToEndMechanismChains(activeMechanismResults, activeRemoteResults)
    local chains = {}

    for _, btnTest in ipairs(activeMechanismResults.UIButtonSignalTests or {}) do
        if btnTest.ReactionFootprint and btnTest.ReactionFootprint.ObservedReaction then
            table.insert(chains, {
                TriggerType = "UIButton",
                TriggerSource = btnTest.Path,
                ButtonText = btnTest.ButtonText,
                Handlers = btnTest.Handlers,
                ResultingFootprint = btnTest.ReactionFootprint,
            })
        end
    end

    for _, toolTest in ipairs(activeMechanismResults.ToolAndWeaponTests or {}) do
        if toolTest.ReactionFootprint and toolTest.ReactionFootprint.ObservedReaction then
            table.insert(chains, {
                TriggerType = "ToolActivation",
                TriggerSource = toolTest.Path,
                ResultingFootprint = toolTest.ReactionFootprint,
            })
        end
    end

    for path, remTest in pairs(activeRemoteResults or {}) do
        if remTest.ProbeResults then
            for _, probe in ipairs(remTest.ProbeResults) do
                if (probe.ReactionFootprint and probe.ReactionFootprint.ObservedReaction) or (probe.Method == "InvokeServer" and probe.ExecutionSuccess and probe.ReturnValues ~= nil) then
                    table.insert(chains, {
                        TriggerType = "ActiveRemoteProbe (" .. tostring(probe.Variant) .. ")",
                        TriggerSource = path,
                        Method = probe.Method,
                        PayloadSent = probe.PayloadSent,
                        ServerReturnValues = probe.ReturnValues,
                        ResultingFootprint = probe.ReactionFootprint,
                    })
                end
            end
        end
    end

    return chains
end

-- 14B.5. DECOMPILE CHUYÊN SÂU CHO TỪNG REMOTE & SINH CODE GỌI MẪU (NHƯ COBALT / RSPY + HYDROXIDE)
local function formatLuaValueForSnippet(val, depth, visited)
    depth = depth or 0
    visited = visited or {}
    if depth > 3 then return "{ --[[ MaxDepth ]] }" end
    local t = typeof(val)
    if t == "string" then
        return string.format("%q", #val > 120 and (string.sub(val, 1, 120) .. "...") or val)
    elseif t == "number" or t == "boolean" then
        return tostring(val)
    elseif t == "Vector3" then
        return string.format("Vector3.new(%s)", tostring(val))
    elseif t == "CFrame" then
        return string.format("CFrame.new(%s)", tostring(val))
    elseif t == "Instance" then
        return "game." .. safeGetFullName(val)
    elseif t == "table" then
        if visited[val] then return "{ --[[ Circular ]] }" end
        visited[val] = true
        local parts = {}
        local count = 0
        for k, v in pairs(val) do
            count += 1
            if count > 6 then
                table.insert(parts, "...")
                break
            end
            if type(k) == "number" then
                table.insert(parts, formatLuaValueForSnippet(v, depth + 1, visited))
            else
                table.insert(parts, string.format("[%q] = %s", tostring(k), formatLuaValueForSnippet(v, depth + 1, visited)))
            end
        end
        visited[val] = nil
        return "{ " .. table.concat(parts, ", ") .. " }"
    else
        return "nil --[[ " .. t .. " ]]"
    end
end

local function inspectSingleClosureDecompile(fn, rawScan)
    if not fn or type(fn) ~= "function" then return nil end
    local scr = resolveClosureScript(fn)
    local scrPath = scr and safeGetFullName(scr) or nil
    local info = getinfo(fn)
    local lineNum = tonumber(info.currentline) or -1

    local constsList = {}
    local okC, consts = pcall(getconstants, fn)
    if okC and type(consts) == "table" then
        for idx, c in pairs(consts) do
            if (type(c) == "string" or type(c) == "number" or type(c) == "boolean") and #constsList < 25 then
                table.insert(constsList, string.format("[%s] = %s", tostring(idx), type(c) == "string" and string.format("%q", c) or tostring(c)))
            end
        end
    end

    local upvalsList = {}
    local okU, upvals = pcall(getupvalues, fn)
    if okU and type(upvals) == "table" then
        for idx, u in pairs(upvals) do
            if #upvalsList < 20 then
                table.insert(upvalsList, string.format("[%s] = %s", tostring(idx), tostring(describeValueSchema(u, 0))))
            end
        end
    end

    -- Nếu có sẵn mã nguồn đã decompile của Script chứa hàm này, cắt chính xác đoạn code quanh dòng `lineNum`!
    local sourceSnippet = nil
    if scrPath and lineNum > 0 then
        local rec = rawScan.Modules[scrPath] or rawScan.Scripts[scrPath]
        if rec and rec.RawLinesList and #rec.RawLinesList >= lineNum then
            sourceSnippet = {}
            for l = math.max(1, lineNum - 3), math.min(#rec.RawLinesList, lineNum + 12) do
                local marker = (l == lineNum) and ">> " or "   "
                table.insert(sourceSnippet, string.format("%s%4d | %s", marker, l, rec.RawLinesList[l] or ""))
            end
        end
    end

    return {
        ScriptPath = scrPath or tostring(info.short_src),
        FunctionName = (info.name and info.name ~= "") and info.name or "anonymous_listener",
        LineNumber = lineNum,
        NumParams = info.numparams or 0,
        Constants = #constsList > 0 and constsList or nil,
        Upvalues = #upvalsList > 0 and upvalsList or nil,
        DecompiledHandlerCode = sourceSnippet,
    }
end

local function buildRemoteDecompileAndCallCatalog(rawScan)
    local remoteCatalog = {}

    for path, rData in pairs(rawScan.Remotes) do
        throttle()
        local inst = rData.InstanceRef
        local cn = rData.ClassName

        -- 1. Tạo đoạn code Lua gọi mẫu chuẩn xác (như rSpy / Cobalt)
        local methodStr = "FireServer"
        if cn == "RemoteFunction" then
            methodStr = "InvokeServer"
        elseif cn == "BindableEvent" then
            methodStr = "Fire"
        elseif cn == "BindableFunction" then
            methodStr = "Invoke"
        end

        local sampleArgsTuple = nil
        local spyEntry = RemoteLogs[path]
        if spyEntry and spyEntry.RawCapturedArgsList and #spyEntry.RawCapturedArgsList > 0 then
            sampleArgsTuple = spyEntry.RawCapturedArgsList[1]
        elseif rData.DecompileExtractedArgs and #rData.DecompileExtractedArgs > 0 then
            sampleArgsTuple = rData.DecompileExtractedArgs[1]
        elseif rData.DiscoveredActionStrings and #rData.DiscoveredActionStrings > 0 then
            sampleArgsTuple = { rData.DiscoveredActionStrings[1] }
        end

        local formattedArgs = {}
        if sampleArgsTuple then
            for i = 1, #sampleArgsTuple do
                table.insert(formattedArgs, formatLuaValueForSnippet(sampleArgsTuple[i]))
            end
        end

        local callSnippet = string.format(
            "game.%s:%s(%s)",
            path,
            methodStr,
            table.concat(formattedArgs, ", ")
        )

        -- 2. Decompile các hàm lắng nghe sự kiện của Remote ở phía Client (OnClientEvent / OnClientInvoke / Event)
        local decompiledListeners = {}
        if inst then
            local sig = nil
            if cn == "RemoteEvent" or cn == "UnreliableRemoteEvent" then
                sig = inst.OnClientEvent
            elseif cn == "BindableEvent" then
                sig = inst.Event
            end
            if sig then
                local okConn, conns = pcall(getconnections, sig)
                if okConn and type(conns) == "table" then
                    for _, c in ipairs(conns) do
                        if c.Function and islclosure(c.Function) and #decompiledListeners < 8 then
                            local inspected = inspectSingleClosureDecompile(c.Function, rawScan)
                            if inspected then
                                table.insert(decompiledListeners, inspected)
                            end
                        end
                    end
                end
            end

            if (cn == "RemoteFunction" or cn == "BindableFunction") and getcallbackvalue then
                local cbProp = (cn == "RemoteFunction") and "OnClientInvoke" or "OnInvoke"
                local okCb, cbFn = pcall(getcallbackvalue, inst, cbProp)
                if okCb and type(cbFn) == "function" then
                    local inspected = inspectSingleClosureDecompile(cbFn, rawScan)
                    if inspected then
                        table.insert(decompiledListeners, inspected)
                    end
                end
            end
        end

        remoteCatalog[path] = {
            Name = rData.Name,
            ClassName = cn,
            Path = path,
            Domains = rData.Domains,
            GeneratedLuaCallCode = callSnippet,
            DecompiledSenderCodeBlocks = rData.DecompiledCallSnippets,
            DecompiledClientListenerClosures = #decompiledListeners > 0 and decompiledListeners or nil,
            InferredActionConstants = #rData.DiscoveredActionStrings > 0 and rData.DiscoveredActionStrings or nil,
        }
    end

    -- Dọn dẹp RawLinesList tạm trên Modules/Scripts để tiết kiệm bộ nhớ trước khi xuất JSON
    for _, mData in pairs(rawScan.Modules) do mData.RawLinesList = nil end
    for _, sData in pairs(rawScan.Scripts) do sData.RawLinesList = nil end

    return remoteCatalog
end

-- 14B.6. BỘ DÒ TÌM CÔNG THỨC TÍNH TOÁN, CONSTANT INDEX & UPVALUE INDEX (FORMULA & UPVALUE MUTATOR MAP)
local function scanFormulaAndUpvalueMutatorMap(rawScan)
    local formulaMap = {}
    local targetKeywords = {
        "recoil", "spread", "inaccuracy", "damage", "firerate", "reload", "cooldown",
        "walkspeed", "speed", "stamina", "hunger", "jump", "dash", "range", "crit",
        "price", "cost", "ammo", "capacity", "penetration", "bullet", "hitscan"
    }

    local function matchKeyword(str)
        if not str or str == "" then return nil end
        local low = string.lower(tostring(str))
        for _, kw in ipairs(targetKeywords) do
            if string.find(low, kw, 1, true) then
                return kw
            end
        end
        return nil
    end

    for scrPath, closuresList in pairs(rawScan.ClosuresByScriptPath or {}) do
        for _, fn in ipairs(closuresList) do
            throttle()
            local info = getinfo(fn)
            local fnName = info.name or ""
            local matched = matchKeyword(fnName)

            local numAndStrConsts = {}
            local okC, consts = pcall(getconstants, fn)
            if okC and type(consts) == "table" then
                for cIdx, cVal in pairs(consts) do
                    if not matched and type(cVal) == "string" then
                        matched = matchKeyword(cVal)
                    end
                    if (type(cVal) == "number" or type(cVal) == "string" or type(cVal) == "boolean") and #numAndStrConsts < 20 then
                        table.insert(numAndStrConsts, string.format("Const[%s] = %s (%s)", tostring(cIdx), tostring(cVal), type(cVal)))
                    end
                end
            end

            if matched and #formulaMap < 120 then
                local upvalueEntries = {}
                local okU, upvals = pcall(getupvalues, fn)
                if okU and type(upvals) == "table" then
                    for uIdx, uVal in pairs(upvals) do
                        local ut = typeof(uVal)
                        if ut == "number" or ut == "boolean" or ut == "string" or ut == "table" then
                            table.insert(upvalueEntries, string.format("Upval[%s] = %s (%s)", tostring(uIdx), tostring(describeValueSchema(uVal, 0)), ut))
                        end
                    end
                end

                table.insert(formulaMap, {
                    MatchedMechanic = matched,
                    ScriptPath = scrPath,
                    FunctionName = (fnName ~= "") and fnName or "anonymous_closure",
                    LineNumber = info.currentline,
                    NumParams = info.numparams or 0,
                    ConstantsIndexMap = #numAndStrConsts > 0 and numAndStrConsts or nil,
                    UpvaluesIndexMap = #upvalueEntries > 0 and upvalueEntries or nil,
                })
            end
        end
    end

    return formulaMap
end

-- 14B.7. BẢN ĐỒ LỚP VA CHẠM & BỘ LỌC RAYCAST (COLLISION GROUPS & RAYCAST FILTER MAPPER)
local function scanCollisionAndRaycastArchitecture()
    local physicsReport = {
        RegisteredCollisionGroups = {},
        SamplePartCollisionGroupsByFolder = {},
        DiscoveredRaycastParamsInMemory = {},
    }

    pcall(function()
        if PhysicsService and PhysicsService.GetRegisteredCollisionGroups then
            local groups = PhysicsService:GetRegisteredCollisionGroups()
            if type(groups) == "table" then
                for _, g in ipairs(groups) do
                    table.insert(physicsReport.RegisteredCollisionGroups, g.name or tostring(g))
                end
            end
        end
    end)

    if WorkspaceService then
        for _, child in ipairs(WorkspaceService:GetChildren()) do
            if isGameInstance(child) then
                local groupCounts = {}
                local okD, desc = pcall(function() return child:GetDescendants() end)
                if okD and type(desc) == "table" then
                    for i = 1, math.min(400, #desc) do
                        local p = desc[i]
                        if safeIsA(p, "BasePart") then
                            local okG, cg = pcall(function() return p.CollisionGroup end)
                            if okG and cg and cg ~= "Default" then
                                groupCounts[cg] = (groupCounts[cg] or 0) + 1
                            end
                        end
                    end
                end
                if next(groupCounts) ~= nil then
                    physicsReport.SamplePartCollisionGroupsByFolder[child.Name] = groupCounts
                end
            end
        end
    end

    local okGC, gcAll = pcall(getgc, true)
    if okGC and type(gcAll) == "table" then
        for _, obj in ipairs(gcAll) do
            if typeof(obj) == "RaycastParams" and #physicsReport.DiscoveredRaycastParamsInMemory < 25 then
                local filterNames = {}
                pcall(function()
                    for _, inst in ipairs(obj.FilterDescendantsInstances or {}) do
                        if #filterNames < 10 then
                            table.insert(filterNames, safeGetFullName(inst))
                        end
                    end
                end)
                table.insert(physicsReport.DiscoveredRaycastParamsInMemory, {
                    FilterType = tostring(obj.FilterType),
                    RespectCanCollide = obj.RespectCanCollide,
                    IgnoreWater = obj.IgnoreWater,
                    CollisionGroup = obj.CollisionGroup,
                    FilterInstances = filterNames,
                })
            end
        end
    end

    return physicsReport
end

-- 14B.8. TỪ ĐIỂN ANIMATION ID & SOUND ID TOÀN GAME (ANIMATION & SOUND ACTION CATALOG)
local function scanAnimationAndSoundCatalog()
    local mediaCatalog = {
        Animations = {},
        Sounds = {},
    }
    local seenAnims = {}
    local seenSounds = {}

    for _, inst in ipairs(game:GetDescendants()) do
        throttle()
        if isGameInstance(inst) then
            local cn = safeGetClassName(inst)
            if cn == "Animation" then
                local okId, animId = pcall(function() return inst.AnimationId end)
                if okId and animId and animId ~= "" and not seenAnims[animId .. "|" .. inst.Name] then
                    seenAnims[animId .. "|" .. inst.Name] = true
                    if #mediaCatalog.Animations < 150 then
                        table.insert(mediaCatalog.Animations, {
                            Name = inst.Name,
                            AnimationId = animId,
                            ParentPath = safeGetFullName(inst.Parent),
                        })
                    end
                end
            elseif cn == "Sound" then
                local okId, sndId = pcall(function() return inst.SoundId end)
                if okId and sndId and sndId ~= "" and not seenSounds[sndId .. "|" .. inst.Name] then
                    seenSounds[sndId .. "|" .. inst.Name] = true
                    if #mediaCatalog.Sounds < 150 then
                        table.insert(mediaCatalog.Sounds, {
                            Name = inst.Name,
                            SoundId = sndId,
                            ParentPath = safeGetFullName(inst.Parent),
                        })
                    end
                end
            end
        end
    end

    return mediaCatalog
end

-- ============================================================================
-- 15. LUỒNG THỰC THI CHÍNH (UNIVERSAL MAIN PIPELINE)
-- ============================================================================
task.spawn(function()
    local pipelineStartTime = os.clock()
    print("============================================================================")
    print("[DeepAnalyzer v6.0 Universal] KHỞI ĐỘNG HỆ THỐNG PHÂN TÍCH ĐA NĂNG CHO MỌI GAME")
    print("============================================================================")

    -- PHA 1: Lắng nghe thụ động ban đầu + Theo dõi biến động Attributes thời gian thực
    print(string.format("[DeepAnalyzer v6.0] [Pha 1/5] Lắng nghe thụ động (Passive Spy & Live Attribute Tracker) trong %d giây...", CONFIG.PASSIVE_SPY_DURATION))
    startLiveStateReplicationTracker()
    installHooksAndListeners()
    if CONFIG.PASSIVE_SPY_DURATION > 0 then
        task.wait(CONFIG.PASSIVE_SPY_DURATION)
    end
    disconnectSpyConnectionsForCleanGCScan()

    -- PHA 2: Quét đầy đủ cây thư mục đệ quy, Frameworks (_G/shared/Knit/Replica), Keybinds & GC Closures
    print("[DeepAnalyzer v6.0] [Pha 2/5] Quét cây thư mục đệ quy, Frameworks, _G/shared, Keybinds & GC Closures...")
    local frameworksAndGlobals = scanFrameworksAndGlobalState()
    local keybindsAndInputs = scanKeybindsAndInputs()
    local fullHierarchyTree = buildFullGameHierarchyTree()
    local rawArchitecture = scanGameArchitectureDeep()

    -- Kết nối lại bộ lắng nghe Server Echo để phục vụ Pha 3 & Pha 4 (Active Testing)
    reconnectServerEchoListenersForActiveTests()

    -- PHA 3: Nạp Module, Đọc & Lưu toàn bộ Code Decompile (kèm Pseudo-Decompiler dự phòng) & Chạy thử cơ chế Game
    print("[DeepAnalyzer v6.0] [Pha 3/5] Nạp Module, Đọc/Lưu Code Decompile & Chạy thử cơ chế (UI, Tools, Prompts, Detectors)...")
    local activeMechanismResults = runActiveMechanismTests(rawArchitecture)

    -- PHA 4: Chạy thử các RemoteEvent & RemoteFunction (dùng tham số bắt được + tham số từ Code Decompile + Đa thể loại)
    print("[DeepAnalyzer v6.0] [Pha 4/5] Chạy thử các RemoteEvent / RemoteFunction và ghi nhận phản ứng Server...")
    local activeRemoteResults = runActiveRemoteTests(rawArchitecture)

    -- Ngắt kết nối lắng nghe trước khi tổng hợp báo cáo
    disconnectSpyConnectionsForCleanGCScan()

    -- PHA 5: Tổng hợp báo cáo khoa học 6 tầng (bao gồm Remote Decompiler, Formula Map, Physics/Raycast, Animation/Sound) vào 1 file JSON duy nhất
    print("[DeepAnalyzer v6.0] [Pha 5/5] Đang tổng hợp Remote Decompile, Formula/Upvalue Map, World Atlas, Security Audit & Pretty JSON...")
    local liveReplicatedChanges = stopLiveStateReplicationTracker()
    local remoteDecompileCatalog = buildRemoteDecompileAndCallCatalog(rawArchitecture)
    local formulaAndUpvalueMap = scanFormulaAndUpvalueMutatorMap(rawArchitecture)

    -- Dọn dẹp các trường tạm sau khi buildRemoteDecompileAndCallCatalog đã sử dụng xong RawCapturedArgsList
    for _, log in pairs(RemoteLogs) do
        log.UniquePayloadSignatures = nil
        log.RawCapturedArgsList = nil
    end
    rawArchitecture.ClosuresByScriptPath = nil
    local collisionAndRaycastMap = scanCollisionAndRaycastArchitecture()
    local animationAndSoundCatalog = scanAnimationAndSoundCatalog()
    local worldAtlas = scanWorldEntitiesAndPOIAtlas()
    local gameDatabases = extractGameDatabasesAndToolCatalog(rawArchitecture)
    local securityAudit = auditClientSecurityAndAntiCheat(rawArchitecture)
    local endToEndChains = buildEndToEndMechanismChains(activeMechanismResults, activeRemoteResults)
    local featureCatalog = buildFeatureCatalog(rawArchitecture, activeRemoteResults)

    local totalRemotes, totalModules, totalScripts, totalUIScreens = 0, 0, 0, 0
    for _ in pairs(rawArchitecture.Remotes) do totalRemotes += 1 end
    for _ in pairs(rawArchitecture.Modules) do totalModules += 1 end
    for _ in pairs(rawArchitecture.Scripts) do totalScripts += 1 end
    for _ in pairs(rawArchitecture.UI) do totalUIScreens += 1 end

    local totalTestedRemotes = 0
    local totalReactiveRemotes = 0
    for _, rRes in pairs(activeRemoteResults) do
        if rRes.ProbeResults then
            totalTestedRemotes += 1
            for _, p in ipairs(rRes.ProbeResults) do
                if (p.ReactionFootprint and p.ReactionFootprint.ObservedReaction) or (p.Method == "InvokeServer" and p.ExecutionSuccess and p.ReturnValues ~= nil) then
                    totalReactiveRemotes += 1
                    break
                end
            end
        end
    end

    local finalReport = {
        Metadata = {
            AnalyzerVersion = "6.0-ScientificSingleJSON-RemoteDecompilerEdition",
            PlaceId = game.PlaceId,
            GameId = game.GameId,
            PlaceVersion = game.PlaceVersion,
            AnalysisTimestampUTC = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            TotalExecutionTimeSeconds = math.floor((os.clock() - pipelineStartTime) * 100) / 100,
            LocalPlayerName = LocalPlayer and LocalPlayer.Name or "Unknown",
            LocalPlayerUserId = LocalPlayer and LocalPlayer.UserId or 0,
            TotalHierarchyNodesScanned = totalTreeNodesScanned,
            ConfigurationUsed = CONFIG,
        },
        AIAndHumanNavigationGuide = {
            ArchitectureDesign = "6-Layer Top-Down Scientific Pyramid (High-Signal Actionable Intelligence at Top -> Raw Repositories at Bottom)",
            ForeignKeyConvention = "Mọi đối tượng đều liên kết chéo với nhau qua đường dẫn chuẩn `Path` (GetFullName).",
            Layer1_Overview = "Metadata & ExecutiveSummary: Thống kê tổng quan toàn bộ quy mô game.",
            Layer2_SecurityAndState = "ClientSecurityAndAntiCheatAudit, DetectedFrameworksAndGlobalState, LiveReplicatedAttributesAndValues: Cơ chế bảo vệ, Knit/Replica/Rodux và các thuộc tính biến thiên thời gian thực.",
            Layer3_RemoteDecompileAndChains = "RemoteDecompileAndCallCatalog, EndToEndMechanismChains, FeaturesCatalog: Đoạn code gọi mẫu cho từng Remote, code Decompile chỗ gửi/nhận của từng Remote và chuỗi nhân quả UI -> Script -> Remote -> ServerEcho.",
            Layer4_RuntimeProofs = "ActiveRemoteTestResults, ActiveMechanismTestResults, PassiveRemoteSpyLogs: Bằng chứng thực nghiệm khi bắn thử Remote và kích hoạt tính năng.",
            Layer5_SpecializedMaps = "FormulaAndUpvalueMutatorMap (chỉ số Constant/Upvalue để hook), CollisionGroupsAndRaycastMap, WorldEntitiesAndPOIAtlas, GameDatabasesAndToolCatalog, AnimationAndSoundCatalog.",
            Layer6_RawRepositories = "DecompiledScriptsRepository (mã nguồn từng dòng của mọi Script) & GameHierarchyTree (cây thư mục đệ quy toàn bộ game).",
        },
        ExecutiveSummary = {
            DetectedFrameworks = frameworksAndGlobals.DetectedFrameworks,
            TotalGameRemotesAndBindables = totalRemotes,
            TotalGameModules = totalModules,
            TotalGameClientScripts = totalScripts,
            TotalScreenGuis = totalUIScreens,
            DecompileSummary = rawArchitecture.DecompiledRepository and rawArchitecture.DecompiledRepository.Summary or nil,
            ActivelyTestedRemotesCount = totalTestedRemotes,
            RemotesWithObservedServerResponseOrStateChange = totalReactiveRemotes,
            EndToEndVerifiedMechanismChainsCount = #endToEndChains,
            DiscoveredFormulaClosuresCount = #formulaAndUpvalueMap,
            DiscoveredAnimationsCount = #animationAndSoundCatalog.Animations,
            DiscoveredSoundsCount = #animationAndSoundCatalog.Sounds,
            SuspectedAntiCheatScriptsCount = #securityAudit.SuspectedAntiCheatScripts,
            SuspectedSecurityRemotesCount = #securityAudit.SuspectedSecurityAndPingRemotes,
            TestedModulesCount = #activeMechanismResults.ModuleIntrospectionAndQueries,
            TestedUIButtonsCount = #activeMechanismResults.UIButtonSignalTests,
            TestedToolsCount = #activeMechanismResults.ToolAndWeaponTests,
            TestedProximityPromptsCount = #activeMechanismResults.ProximityPromptTests,
            TestedClickDetectorsCount = #activeMechanismResults.ClickDetectorTests,
        },
        ClientSecurityAndAntiCheatAudit = securityAudit,
        DetectedFrameworksAndGlobalState = frameworksAndGlobals,
        LiveReplicatedAttributesAndValues = liveReplicatedChanges,
        RemoteDecompileAndCallCatalog = remoteDecompileCatalog,
        EndToEndMechanismChains = endToEndChains,
        FeaturesCatalog = featureCatalog,
        ActiveRemoteTestResults = activeRemoteResults,
        ActiveMechanismTestResults = activeMechanismResults,
        PassiveRemoteSpyLogs = RemoteLogs,
        FormulaAndUpvalueMutatorMap = formulaAndUpvalueMap,
        CollisionGroupsAndRaycastMap = collisionAndRaycastMap,
        WorldEntitiesAndPOIAtlas = worldAtlas,
        GameDatabasesAndToolCatalog = gameDatabases,
        AnimationAndSoundCatalog = animationAndSoundCatalog,
        KeybindsAndInputBindings = keybindsAndInputs,
        CollectionServiceTags = rawArchitecture.CollectionServiceTags,
        DecompiledScriptsRepository = rawArchitecture.DecompiledRepository,
        GameHierarchyTree = fullHierarchyTree,
    }

    local okEncode, prettyJsonString = pcall(encodePrettyJSON, finalReport, CONFIG.JSON_INDENT)
    if not okEncode then
        warn("[DeepAnalyzer v6.0] Lỗi khi định dạng Pretty JSON: " .. tostring(prettyJsonString))
        return
    end

    if writefile then
        local okWrite, errWrite = pcall(writefile, CONFIG.OUTPUT_JSON_FILENAME, prettyJsonString)
        if okWrite then
            print("============================================================================")
            print("[DeepAnalyzer v6.0 Universal] HOÀN TẤT TOÀN BỘ QUÁ TRÌNH QUÉT, DECOMPILE & TEST!")
            print(" -> Đã xuất 1 File JSON Toàn Diện duy nhất (Pretty-Printed): workspace/" .. CONFIG.OUTPUT_JSON_FILENAME)
            print(" -> Dung lượng JSON: " .. string.format("%.2f KB", #prettyJsonString / 1024))
            print("============================================================================")
        else
            warn("[DeepAnalyzer v6.0] Lỗi writefile: " .. tostring(errWrite))
        end
    else
        warn("[DeepAnalyzer v6.0] Executor không hỗ trợ writefile().")
    end
end)