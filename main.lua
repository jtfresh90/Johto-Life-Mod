return function(mod)
  -- Johto Life 0.1.3 — Gen2 only
  local function resolveGame()
    if mod.game ~= nil then return mod.game end
    if mod.world and mod.world.game ~= nil then return mod.world.game end
    return nil
  end
  local game = resolveGame()
  local function G()
    game = resolveGame() or game
    return game
  end

  mod.options:define({
    { key = "extra_npcs", type = "toggle", label = "EXTRA NPCS", default = true },
    { key = "extra_npc_count", type = "number", label = "EXTRA NPC COUNT",
      default = 0, min = 0, max = 150, step = 1 },
    { key = "indoor_npcs", type = "toggle", label = "INDOOR NPCS", default = true },
    { key = "indoor_npc_count", type = "number", label = "INDOOR NPC COUNT",
      default = 3, min = 0, max = 30, step = 1 },
    { key = "pokemon_npcs", type = "toggle", label = "POKEMON NPCS", default = true },
    { key = "pokemon_npc_count", type = "number", label = "POKEMON NPC COUNT",
      default = 0, min = 0, max = 50, step = 1 },
    { key = "sleeping_npcs", type = "toggle", label = "SLEEPING NPCS", default = true },
    { key = "sleep_pct", type = "number", label = "SLEEP RATE %",
      default = 15, min = 0, max = 100, step = 5 },
    { key = "day_sleepers", type = "toggle", label = "DAY SLEEPERS", default = true },
    { key = "common_courtesy", type = "toggle", label = "COMMON COURTESY", default = true },
    { key = "name_all_npcs", type = "toggle", label = "NAME ALL NPCS", default = true },
  })
  local function opt(k) return mod.options:get(k) end
  local function setOpt(k, v) mod.options:set(k, v) end
  local outdoorTouched = mod.save:get("outdoorTouched") and true or false
  local pokeTouched = mod.save:get("pokeTouched") and true or false

  local townDefaults = {
    NEW_BARK_TOWN = 12, CHERRYGROVE_CITY = 20, VIOLET_CITY = 40,
    AZALEA_TOWN = 25, GOLDENROD_CITY = 80, ECRUTEAK_CITY = 50,
    OLIVINE_CITY = 40, CIANWOOD_CITY = 25, MAHOGANY_TOWN = 20,
    BLACKTHORN_CITY = 35, PALLET_TOWN = 8, VIRIDIAN_CITY = 20,
    PEWTER_CITY = 25, CERULEAN_CITY = 30, VERMILION_CITY = 30,
    LAVENDER_TOWN = 15, CELADON_CITY = 60, FUCHSIA_CITY = 40,
    SAFFRON_CITY = 60, CINNABAR_ISLAND = 10,
  }
  local ROUTE_DEFAULT = 8

  local SPRITE_DEFS = {
    { "SPRITE_YOUNGSTER", "m" }, { "SPRITE_LASS", "f" },
    { "SPRITE_BUG_CATCHER", "m" }, { "SPRITE_COOLTRAINER_M", "m" },
    { "SPRITE_COOLTRAINER_F", "f" }, { "SPRITE_BEAUTY", "f" },
    { "SPRITE_SUPER_NERD", "m" }, { "SPRITE_ROCKER", "m" },
    { "SPRITE_POKEFAN_M", "m" }, { "SPRITE_POKEFAN_F", "f" },
    { "SPRITE_GRAMPS", "m" }, { "SPRITE_GRANNY", "f" },
    { "SPRITE_TWIN", "f" }, { "SPRITE_SCHOOLBOY", "m" },
    { "SPRITE_TEACHER", "f" }, { "SPRITE_FISHER", "m" },
    { "SPRITE_BIRD_KEEPER", "m" }, { "SPRITE_SCIENTIST", "m" },
    { "SPRITE_OFFICER", "m" }, { "SPRITE_SAGE", "m" },
    { "SPRITE_BOARDER", "m" }, { "SPRITE_SKIER", "f" },
    { "SPRITE_BUENA", "f" }, { "SPRITE_SAILOR", "m" },
    { "SPRITE_SWIMMER_GUY", "m" }, { "SPRITE_SWIMMER_GIRL", "f" },
    { "YOUNGSTER", "m" }, { "LASS", "f" }, { "BUG_CATCHER", "m" },
    { "COOLTRAINER_M", "m" }, { "COOLTRAINER_F", "f" },
    { "BEAUTY", "f" }, { "POKEFAN_M", "m" }, { "GRAMPS", "m" },
    { "FISHER", "m" }, { "SAILOR", "m" },
  }
  local MALE_NAMES = {
    "Aaron","Adam","Alex","Andrew","Ben","Blake","Brian","Caleb","Carlos","Chris",
    "Daniel","David","Derek","Dylan","Eric","Ethan","Felix","Frank","George","Greg",
    "Henry","Ian","Jack","James","Jason","Joel","John","Jordan","Kevin","Kyle",
    "Leo","Liam","Lucas","Mark","Mason","Matt","Max","Nathan","Nick","Noah",
    "Owen","Paul","Peter","Ray","Ryan","Sam","Scott","Sean","Steve","Tom","Tony","Tyler","Will","Zack",
  }
  local FEMALE_NAMES = {
    "Alice","Amy","Anna","Ashley","Beth","Brooke","Carla","Chloe","Claire","Dana",
    "Diana","Elena","Emma","Erin","Faye","Grace","Hannah","Helen","Iris","Jane",
    "Jenny","Jill","Joy","Kate","Kelly","Laura","Lily","Lisa","Lucy","Maria",
    "Mary","Megan","Mia","Molly","Nancy","Nina","Olivia","Paige","Rachel","Rose",
    "Ruby","Sara","Sofia","Sue","Tina","Vera","Wendy","Zoe",
  }
  -- Overworld-friendly Johto mons (names used as display + dialogue)
  local POKE_LIST = {
    "PIDGEY","RATTATA","SENTRET","HOOTHOOT","LEDYBA","SPINARAK","PICHU","CLEFFA",
    "IGGLYBUFF","TOGEPI","MAREEP","MARILL","HOPPIP","AIPOM","SUNKERN","YANMA",
    "WOOPER","MURKROW","MISDREAVUS","WOBBUFFET","GIRAFARIG","PINECO","DUNSPARCE",
    "GLIGAR","SNUBBULL","QWILFISH","SHUCKLE","HERACROSS","SNEASEL","TEDDIURSA",
    "SLUGMA","SWINUB","CORSOLA","REMORAID","DELIBIRD","MANTINE","SKARMORY",
    "HOUNDOUR","PHANPY","STANTLER","SMEARGLE","TYROGUE","SMOOCHUM","ELEKID",
    "MAGBY","MILTANK","LARVITAR","CHIKORITA","CYNDAQUIL","TOTODILE",
  }
  local POKE_CRY_LINES = {
    "%s!",
    "%s!\n%s!",
    "%s?",
    "%s...",
    "%s!\n%s?",
  }
  local lines = {
    "I'm headed to the\nMART before sunset.", "JOHTO feels lively\ntoday!",
    "Have you tried the\nlocal GYM?", "My partner is at\nthe POKEMON CENTER.",
    "I'm training for\nthe LEAGUE!", "Watch for wild\nPOKEMON in the grass!",
    "GOLDENROD has the\nbest shops!", "I love the music\nin this town!",
    "Excuse me, do you\nknow the way?", "I'm visiting family\nin the next town.",
    "The weather is\nperfect for a stroll!", "TEAM ROCKET better\nstay away!",
    "I'm saving up for\na BICYCLE!", "Have you seen any\nrare POKEMON?",
    "Don't step on the\nflower beds!",
  }
  local routeLines = {
    "These routes are\nfull of TRAINERS!", "I'm traveling\nbetween towns.",
    "Tall grass hides\nsurprises!", "Don't get lost on\nthe long road.",
    "My team needs more\nexperience!",
  }

  local spawnSerial = 0
  local function isTown(id) return townDefaults[id] ~= nil end
  local function isRoute(id) return type(id) == "string" and id:match("^ROUTE_") ~= nil end
  local function isIndoor(id)
    if not id then return false end
    id = tostring(id)
    if isTown(id) or isRoute(id) then return false end
    if id:find("HOUSE", 1, true) or id:find("HOME", 1, true) then return true end
    if id:find("_1F", 1, true) or id:find("_2F", 1, true) or id:find("_3F", 1, true) then return true end
    if id:find("MART", 1, true) or id:find("CENTER", 1, true) or id:find("GYM", 1, true) then return true end
    return false
  end
  local function defaultCount(id)
    if townDefaults[id] then return townDefaults[id] end
    if isRoute(id) then return ROUTE_DEFAULT end
    if isIndoor(id) then return math.floor(tonumber(opt("indoor_npc_count")) or 3) end
    return 0
  end
  local function humanTarget(mapId)
    if not opt("extra_npcs") then return 0 end
    if isIndoor(mapId) then
      if not opt("indoor_npcs") then return 0 end
      return math.max(0, math.floor(tonumber(opt("indoor_npc_count")) or 3))
    end
    if not (isTown(mapId) or isRoute(mapId)) then return 0 end
    if outdoorTouched then
      return math.max(0, math.floor(tonumber(opt("extra_npc_count")) or 0))
    end
    local n = math.floor(tonumber(opt("extra_npc_count")) or 0)
    if n > 0 then return n end
    return defaultCount(mapId)
  end
  local function pokeTarget(mapId)
    if not opt("pokemon_npcs") then return 0 end
    if not (isTown(mapId) or isRoute(mapId)) then return 0 end
    if pokeTouched then
      return math.max(0, math.floor(tonumber(opt("pokemon_npc_count")) or 0))
    end
    return math.max(0, math.floor(tonumber(opt("pokemon_npc_count")) or 0))
  end

  local function cellHasWarp(map, x, y)
    if not map then return false end
    local entry = nil
    if map.warpAt then entry = map:warpAt(x, y) end
    if not entry and map.warpAtCell then entry = map:warpAtCell(x, y) end
    if entry then return true end
    -- scan warp list on map.def
    local warps = map.def and map.def.warps or map.warps
    if type(warps) == "table" then
      for _, w in pairs(warps) do
        if type(w) == "table" and w.x == x and w.y == y then return true end
      end
    end
    return false
  end

  local function pickCell(ow, map)
    if not (ow and map) then return nil end
    local w = map.width or (map.def and map.def.width) or 20
    local h = map.height or (map.def and map.def.height) or 18
    for _ = 1, 60 do
      local x = love.math.random(2, math.max(2, w - 3))
      local y = love.math.random(2, math.max(2, h - 3))
      local blocked = false
      if map.isWalkable and not map:isWalkable(x, y) then blocked = true end
      if map.isWalkableCell and not map:isWalkableCell(x, y) then blocked = true end
      if cellHasWarp(map, x, y) then blocked = true end
      -- also avoid adjacent door tiles so they don't stand in front of doors
      if not blocked then
        for dx = -1, 1 do
          for dy = -1, 1 do
            if cellHasWarp(map, x + dx, y + dy) then blocked = true end
          end
        end
      end
      if not blocked then
        for _, e in ipairs(ow.entities or ow.npcs or {}) do
          if e.cellX == x and e.cellY == y then blocked = true break end
        end
      end
      if not blocked then return x, y end
    end
    return nil
  end

  local function randomName(g)
    local pool = (g == "f") and FEMALE_NAMES or MALE_NAMES
    return pool[love.math.random(#pool)]
  end
  local function liveAmbient(ow, pokeOnly)
    local list = {}
    for _, n in ipairs((ow and ow.npcs) or {}) do
      local d = n.def or {}
      if d.johtoLifeAmbient then
        local isPoke = d.johtoLifePokemon and true or false
        if pokeOnly == nil or pokeOnly == isPoke then list[#list + 1] = n end
      end
    end
    return list
  end

  local function spawnOne(ow, map, mapId, isPoke)
    local x, y = pickCell(ow, map)
    if not x then return nil end
    spawnSerial = spawnSerial + 1
    local sprite, gender, displayName, monName
    if isPoke then
      monName = POKE_LIST[love.math.random(#POKE_LIST)]
      displayName = monName
      -- Prefer overworld mon sprite if engine knows it; fall back to common sprites
      sprite = "SPRITE_" .. monName
      gender = "m"
    else
      local def = SPRITE_DEFS[love.math.random(#SPRITE_DEFS)]
      sprite, gender = def[1], def[2]
      displayName = randomName(gender)
    end
    local tag = isPoke and "JOHTO_POKE_" or "JOHTO_NPC_"
    local name = tag .. tostring(mapId) .. "_" .. spawnSerial
    local id, err = mod.world:spawnNpc(mapId, {
      name = name,
      sprite = sprite,
      x = x, y = y,
      text = "",
      -- Gen2 movement: walk randomly so they don't freeze on spawn tile
      movement = "WALK",
      range = "ANY_DIR",
      moving = true,
      johtoLifeAmbient = true,
      johtoLifePokemon = isPoke and true or nil,
      johtoLifeDisplayName = displayName,
      johtoLifeGender = gender,
      johtoLifeMon = monName,
    })
    if not id and isPoke then
      -- retry with a neutral sprite if mon sheet missing
      id, err = mod.world:spawnNpc(mapId, {
        name = name,
        sprite = "SPRITE_POKE_BALL",
        x = x, y = y,
        text = "",
        movement = "WALK",
        range = "ANY_DIR",
        moving = true,
        johtoLifeAmbient = true,
        johtoLifePokemon = true,
        johtoLifeDisplayName = displayName,
        johtoLifeMon = monName,
      })
    end
    if not id then
      mod.log:warn("Johto Life spawn failed: " .. tostring(err) .. " " .. tostring(sprite))
      return nil
    end
    for _, n in ipairs(ow.npcs or {}) do
      if n.id == id or (n.def and n.def.name == name) then
        n.def = n.def or {}
        n.def.johtoLifeAmbient = true
        n.def.johtoLifePokemon = isPoke and true or nil
        n.def.johtoLifeDisplayName = displayName
        n.def.johtoLifeGender = gender
        n.def.johtoLifeMon = monName
        n.frozen = false
        if n.movement == nil then n.movement = "WALK" end
        return n
      end
    end
    return true
  end

  local function spawnAmbient(mapId)
    if not mapId then return end
    if not (isTown(mapId) or isRoute(mapId) or isIndoor(mapId)) then return end
    local ow = mod.world and mod.world:overworld()
    if not ow or not ow.map or ow.map.id ~= mapId then return end
    local map = ow.map

    local function balance(want, pokeOnly)
      local have = liveAmbient(ow, pokeOnly)
      while #have > want do
        local n = table.remove(have)
        local id = n.id or (n.def and n.def.id)
        if id then pcall(function() mod.world:removeNpc(id) end) end
      end
      local guard = 0
      while #have < want and guard < want + 25 do
        guard = guard + 1
        local n = spawnOne(ow, map, mapId, pokeOnly)
        if n then have[#have + 1] = n else break end
      end
    end

    balance(humanTarget(mapId), false)
    if isTown(mapId) or isRoute(mapId) then
      balance(pokeTarget(mapId), true)
    end
  end

  local function refreshCurrentMap()
    local ow = mod.world and mod.world:overworld()
    if ow and ow.map then spawnAmbient(ow.map.id) end
  end

  local function safeRequire(path)
    local ok, m = pcall(require, path)
    if ok then return m end
    return nil
  end

  -- Display name for ANY npc (story or ambient)
  local nameCache = {}
  local function displayNameFor(npc)
    if not npc then return "Someone" end
    local d = npc.def or {}
    if d.johtoLifeDisplayName then return d.johtoLifeDisplayName end
    if d.johtoLifeMon then return d.johtoLifeMon end
    local key = tostring(npc.id or d.name or d.index or npc)
    if nameCache[key] then return nameCache[key] end
    -- story NPC: prefer explicit name if human-readable
    local raw = d.name or d.id or ""
    raw = tostring(raw)
    if raw ~= "" and not raw:match("^[%d_]+$") and not raw:find("OBJECT", 1, true)
        and not raw:find("JOHTO_", 1, true) and #raw < 16 and raw:match("^[%a%d ]+$") then
      nameCache[key] = raw
      return raw
    end
    -- gender from sprite
    local spr = tostring(d.sprite or npc.sprite or ""):upper()
    local gender = "m"
    if spr:find("LASS", 1, true) or spr:find("_F", 1, true) or spr:find("GIRL", 1, true)
        or spr:find("BEAUTY", 1, true) or spr:find("GRANNY", 1, true)
        or spr:find("TEACHER", 1, true) or spr:find("TWIN", 1, true)
        or spr:find("SKIER", 1, true) or spr:find("BUENA", 1, true) then
      gender = "f"
    end
    local nm = randomName(gender)
    nameCache[key] = nm
    d.johtoLifeDisplayName = nm
    return nm
  end

  local function openJohtoOptions(parentGame)
    local ListMenu = safeRequire("src.ui.ListMenu") or safeRequire("src.menu.ListMenu")
    local g = parentGame or G()
    if not (ListMenu and g and g.stack) then
      mod.log:warn("Johto Life: ListMenu unavailable; use Mods panel")
      return
    end
    local function rebuild()
      local items = {
        { text = "EXTRA NPCS", value = opt("extra_npcs") and "ON" or "OFF",
          right = opt("extra_npcs") and "ON" or "OFF",
          apply = function() setOpt("extra_npcs", not opt("extra_npcs")); refreshCurrentMap() end },
        { text = "EXTRA NPC COUNT",
          value = tostring(math.floor(tonumber(opt("extra_npc_count")) or 0)),
          right = tostring(math.floor(tonumber(opt("extra_npc_count")) or 0)),
          step = function(dir)
            outdoorTouched = true; mod.save:set("outdoorTouched", true)
            local n = math.max(0, math.min(150, math.floor(tonumber(opt("extra_npc_count")) or 0) + (dir or 1)))
            setOpt("extra_npc_count", n); refreshCurrentMap()
          end,
          apply = function()
            outdoorTouched = true; mod.save:set("outdoorTouched", true)
            local n = math.floor(tonumber(opt("extra_npc_count")) or 0)
            setOpt("extra_npc_count", (n >= 150) and 0 or (n + 1)); refreshCurrentMap()
          end },
        { text = "INDOOR NPCS", value = opt("indoor_npcs") and "ON" or "OFF",
          right = opt("indoor_npcs") and "ON" or "OFF",
          apply = function() setOpt("indoor_npcs", not opt("indoor_npcs")); refreshCurrentMap() end },
        { text = "INDOOR NPC COUNT",
          value = tostring(math.floor(tonumber(opt("indoor_npc_count")) or 3)),
          right = tostring(math.floor(tonumber(opt("indoor_npc_count")) or 3)),
          step = function(dir)
            local n = math.max(0, math.min(30, math.floor(tonumber(opt("indoor_npc_count")) or 3) + (dir or 1)))
            setOpt("indoor_npc_count", n); refreshCurrentMap()
          end,
          apply = function()
            local n = math.floor(tonumber(opt("indoor_npc_count")) or 3)
            setOpt("indoor_npc_count", (n >= 30) and 0 or (n + 1)); refreshCurrentMap()
          end },
        { text = "POKEMON NPCS", value = opt("pokemon_npcs") and "ON" or "OFF",
          right = opt("pokemon_npcs") and "ON" or "OFF",
          apply = function() setOpt("pokemon_npcs", not opt("pokemon_npcs")); refreshCurrentMap() end },
        { text = "POKEMON NPC COUNT",
          value = tostring(math.floor(tonumber(opt("pokemon_npc_count")) or 0)),
          right = tostring(math.floor(tonumber(opt("pokemon_npc_count")) or 0)),
          step = function(dir)
            pokeTouched = true; mod.save:set("pokeTouched", true)
            local n = math.max(0, math.min(50, math.floor(tonumber(opt("pokemon_npc_count")) or 0) + (dir or 1)))
            setOpt("pokemon_npc_count", n); refreshCurrentMap()
          end,
          apply = function()
            pokeTouched = true; mod.save:set("pokeTouched", true)
            local n = math.floor(tonumber(opt("pokemon_npc_count")) or 0)
            setOpt("pokemon_npc_count", (n >= 50) and 0 or (n + 1)); refreshCurrentMap()
          end },
        { text = "NAME ALL NPCS", value = opt("name_all_npcs") and "ON" or "OFF",
          right = opt("name_all_npcs") and "ON" or "OFF",
          apply = function() setOpt("name_all_npcs", not opt("name_all_npcs")) end },
        { text = "COMMON COURTESY", value = opt("common_courtesy") and "ON" or "OFF",
          right = opt("common_courtesy") and "ON" or "OFF",
          apply = function() setOpt("common_courtesy", not opt("common_courtesy")) end },
        { text = "SLEEPING NPCS", value = opt("sleeping_npcs") and "ON" or "OFF",
          right = opt("sleeping_npcs") and "ON" or "OFF",
          apply = function() setOpt("sleeping_npcs", not opt("sleeping_npcs")) end },
        { text = "SLEEP RATE %",
          value = tostring(math.floor(tonumber(opt("sleep_pct")) or 15)),
          right = tostring(math.floor(tonumber(opt("sleep_pct")) or 15)),
          step = function(dir)
            local n = math.max(0, math.min(100, math.floor(tonumber(opt("sleep_pct")) or 15) + 5 * (dir or 1)))
            setOpt("sleep_pct", n)
          end,
          apply = function()
            local n = math.floor(tonumber(opt("sleep_pct")) or 15)
            setOpt("sleep_pct", (n >= 100) and 0 or (n + 5))
          end },
        { text = "DAY SLEEPERS", value = opt("day_sleepers") and "ON" or "OFF",
          right = opt("day_sleepers") and "ON" or "OFF",
          apply = function() setOpt("day_sleepers", not opt("day_sleepers")) end },
      }
      for _, it in ipairs(items) do
        it.label = it.text
        it.action = function() if it.apply then it.apply() end end
        it.onSelect = it.action
      end
      return items
    end
    local items = rebuild()
    local ok, menu = pcall(function()
      return ListMenu.new(g, { title = "JOHTO LIFE", items = items })
    end)
    if ok and menu then
      local baseUp = menu.update
      if type(baseUp) == "function" then
        menu.update = function(self, dt)
          baseUp(self, dt)
          local input = g.input
          if not input or not input.pressed then return end
          local idx = self.selected or self.index or 1
          local it = (self.items or items)[idx]
          if it and it.step then
            if input:pressed("left") then it.step(-1)
            elseif input:pressed("right") then it.step(1) end
          end
        end
      end
      g.stack:push(menu)
    end
  end

  local function johtoLifeRow(g)
    return {
      label = "JOHTO LIFE", text = "JOHTO LIFE",
      right = ">", value = ">",
      onSelect = function() openJohtoOptions(g) end,
      action = function() openJohtoOptions(g) end,
      apply = function() openJohtoOptions(g) end,
    }
  end
  if mod.hooks and mod.hooks.wrap then
    pcall(function()
      mod.hooks:wrap("ui.options.items", function(next, g, items)
        local list = next(g, items) or items or {}
        list[#list + 1] = johtoLifeRow(g)
        return list
      end)
    end)
    pcall(function()
      mod.hooks:wrap("ui.options.rows", function(next, g, rows)
        local list = next(g, rows) or rows or {}
        list[#list + 1] = johtoLifeRow(g)
        return list
      end)
    end)
  end
  local Options = safeRequire("src.menu.Options") or safeRequire("src.ui.Options")
  if Options and type(Options.buildItems) == "function" then
    local baseBuild = Options.buildItems
    Options.buildItems = function(self, ...)
      local items = baseBuild(self, ...) or {}
      items[#items + 1] = johtoLifeRow(self.game or G())
      return items
    end
  end

  -- ===== Common Courtesy (same as 0.1.2) =====
  local Overworld = safeRequire("src.world.OverworldController")
  local TextBox = safeRequire("src.render.TextBox")
  local Strings = safeRequire("src.core.Strings")
  local homes = mod.save:get("homes") or {}
  local function saveHomes() mod.save:set("homes", homes) end
  local function key(id) return tostring(id) end
  local function now()
    local ok, t = pcall(os.time)
    return (ok and type(t) == "number") and t or 0
  end
  local COURTESY_MEMORY_STEPS = 1500
  local function steps() return tonumber(mod.save:get("courtesyWalkSteps")) or 0 end
  local function setSteps(n) mod.save:set("courtesyWalkSteps", math.max(0, math.floor(n))) end
  local function markKnown(dest)
    if not dest then return end
    local h = homes[key(dest)] or {}
    h.known, h.knocked = true, nil
    h.knownUntil = steps() + COURTESY_MEMORY_STEPS
    homes[key(dest)] = h; saveHomes()
  end
  local function isKnown(dest)
    local h = homes[key(dest)]
    if not h or not h.known then return false end
    if not h.knownUntil then
      h.knownUntil = steps() + COURTESY_MEMORY_STEPS
      homes[key(dest)] = h; saveHomes()
      return true
    end
    if steps() >= h.knownUntil then
      h.known, h.knownUntil, h.knocked = nil, nil, nil
      homes[key(dest)] = h; saveHomes()
      return false
    end
    return true
  end
  local function resident(mapId)
    if not mapId then return false end
    local id = tostring(mapId):upper()
    return id:find("HOUSE", 1, true) ~= nil or id:find("HOME", 1, true) ~= nil
  end
  local excluded = {
    PLAYERS_HOUSE_1F = true, PLAYERS_HOUSE_2F = true,
    KRISS_HOUSE_1F = true, KRISS_HOUSE_2F = true,
    RIVALS_HOUSE = true, ELMS_HOUSE = true,
  }
  local function isHouseDest(dest)
    return dest and not excluded[dest] and resident(dest)
  end
  local function liveWorld()
    if mod.world and mod.world.overworld then
      local ok, w = pcall(function() return mod.world:overworld() end)
      if ok and w then return w end
    end
    local g = G()
    return g and (g.world or g.overworld) or nil
  end
  local function pushText(world, msg, onDone, opts)
    local g = G()
    if g and g.stack and TextBox and Strings then
      g.stack:push(TextBox.new(g, Strings(msg), onDone, opts))
      return true
    end
    if world and world.showText then world:showText(msg, onDone) return true end
    return false
  end
  local function facingXY(world)
    local p = world and world.player
    if not p then return nil end
    local d = ({ up={0,-1}, down={0,1}, left={-1,0}, right={1,0} })[p.facing] or {0,1}
    return (p.cellX or 0) + d[1], (p.cellY or 0) + d[2]
  end
  local function warpAt(world, x, y)
    if not (world and world.map and x) then return nil end
    local m = world.map
    if m.warpAtCell then return m:warpAtCell(x, y) end
    if m.warpAt then return m:warpAt(x, y) end
    return nil
  end
  local function destOf(w)
    if not w then return nil end
    if type(w) == "string" then return w end
    return w.destMap or w.map
  end

  local pendingTrespass = mod.save:get("pendingTrespass")
  local function clearTrespass(world)
    pendingTrespass = nil
    mod.save:set("pendingTrespass", nil)
    if world then world.johtoLifeTrespass = nil end
  end
  local function warpBackTo(world, from)
    if not (from and from.map) then return false end
    local x = tonumber(from.x) or 0
    local y = tonumber(from.y) or 0
    if world and world.warpToMapId then
      return world:warpToMapId(from.map, x, y, "down")
    end
    if Overworld and Overworld.startWarpTo then
      return Overworld.startWarpTo(from.map, x, y, "down")
    end
    if world and world.setMap then
      return world:setMap(from.map, x, y, "down")
    end
    return false
  end
  local function tryEject(world, toMap)
    if not opt("common_courtesy") then return false end
    world = world or liveWorld()
    local trespass = (world and world.johtoLifeTrespass) or pendingTrespass
    if not trespass or not trespass.home then return false end
    local mapId = toMap or (world and world.map and world.map.id)
    if not mapId or tostring(mapId) ~= tostring(trespass.home) then return false end
    if world and world.johtoLifeResolving then return false end
    if world then world.johtoLifeResolving = true end
    local from = trespass.from or {}
    local function finish()
      warpBackTo(world, from)
      clearTrespass(world)
      if world then world.johtoLifeResolving = false end
    end
    if not pushText(world, "Please come back\nlater, and KNOCK!", finish) then finish() end
    return true
  end
  local function markTrespass(world, dest, fromMap, fromX, fromY)
    local t = { home = dest, from = { map = fromMap, x = fromX or 0, y = fromY or 0 } }
    pendingTrespass = t
    mod.save:set("pendingTrespass", t)
    if world then world.johtoLifeTrespass = t end
  end

  if mod.events and mod.events.on then
    mod.events:on("player.warped", function(payload)
      payload = payload or {}
      local toMap, fromMap = payload.toMap, payload.fromMap
      if not opt("common_courtesy") then return end
      if not isHouseDest(toMap) or resident(fromMap) then return end
      if isKnown(toMap) then return end
      local h = homes[key(toMap)] or {}
      if h.knocked then return end
      local world = liveWorld()
      local px, py = 0, 0
      if world and world.player then
        px = world.player.cellX or 0
        py = world.player.cellY or 0
      end
      markTrespass(world, toMap, fromMap, px, py)
    end)
    local function onMapIn(p)
      local id = p and (p.mapId or p.id)
      if id then
        spawnAmbient(id)
        tryEject(liveWorld(), id)
      end
    end
    mod.events:on("map.ready", onMapIn)
    mod.events:on("map.reloaded", onMapIn)
    mod.events:on("map.entered", onMapIn)
    mod.events:on("mod.options_changed", function(p)
      if not p or p.mod ~= mod.id then return end
      if p.key == "extra_npc_count" then
        outdoorTouched = true; mod.save:set("outdoorTouched", true)
      end
      if p.key == "pokemon_npc_count" then
        pokeTouched = true; mod.save:set("pokeTouched", true)
      end
      refreshCurrentMap()
    end)
  end

  if Overworld then
    local baseInteract = Overworld.interact
    Overworld.interact = function(world)
      if opt("common_courtesy") and world and world.player and world.map then
        local x, y = facingXY(world)
        local at = warpAt(world, x, y)
        if at then
          local def = at.def or at
          local dest = destOf(def)
          if isHouseDest(dest) and not resident(world.map.id) and not isKnown(dest) then
            pushText(world, "KNOCK before\nentering?", nil, {
              choice = function(yes)
                local h = homes[key(dest)] or {}
                if yes then
                  h.knocked = true
                  homes[key(dest)] = h; saveHomes()
                  clearTrespass(world)
                  pushText(world, "KNOCK! KNOCK!\nCome in!", function()
                    world.johtoLifeWelcome = dest
                    if world.takeWarp then world:takeWarp(def)
                    elseif Overworld.takeWarp then Overworld.takeWarp(def) end
                  end)
                else
                  homes[key(dest)] = h; saveHomes()
                end
              end
            })
            return true
          end
        end
      end
      if type(baseInteract) == "function" then return baseInteract(world) end
      if world and world.interactBody then return world:interactBody() end
    end

    local World2 = safeRequire("src.world.gen2.World")
    if World2 and type(World2.takeWarp) == "function" then
      local baseWorldWarp = World2.takeWarp
      World2.takeWarp = function(self, warpDef)
        if opt("common_courtesy") and self and self.map and self.player and warpDef then
          local dest = destOf(warpDef)
          if isHouseDest(dest) and not resident(self.map.id) then
            local h = homes[key(dest)] or {}
            if not isKnown(dest) and not h.knocked and (h.lockedUntil or 0) > now() then
              pushText(self, "Please try again\nin 5 minutes.")
              return false
            end
            if not isKnown(dest) and not h.knocked then
              markTrespass(self, dest, self.map.id, self.player.cellX, self.player.cellY)
            end
          end
        end
        return baseWorldWarp(self, warpDef)
      end
    end
    if World2 and type(World2.step) == "function" then
      local baseStep = World2.step
      World2.step = function(self, ...)
        local r = baseStep(self, ...)
        if self and self.map then tryEject(self, self.map.id) end
        return r
      end
    end

    local baseUpdate = Overworld.update
    local lastCell = { map = nil, x = nil, y = nil }
    Overworld.update = function(world, dt)
      if type(baseUpdate) == "function" then pcall(baseUpdate, world, dt) end
      if not world then return end
      local p = world.player
      if p and world.map then
        local mid = world.map.id
        if lastCell.map ~= mid then
          lastCell.map, lastCell.x, lastCell.y = mid, p.cellX, p.cellY
        elseif lastCell.x ~= p.cellX or lastCell.y ~= p.cellY then
          lastCell.x, lastCell.y = p.cellX, p.cellY
          setSteps(steps() + 1)
        end
      end
      tryEject(world, world.map and world.map.id)
      if world.johtoLifeWelcome and world.map and world.map.id == world.johtoLifeWelcome then
        local w = world.johtoLifeWelcome
        world.johtoLifeWelcome = nil
        markKnown(w)
        pushText(world, "Welcome! Thank you\nfor knocking.")
      end
      -- keep ambient humans walking (unfreeze non-sleepers)
      for _, npc in ipairs(world.npcs or {}) do
        local d = npc.def or {}
        if d.johtoLifeAmbient and not npc.nightlifeSleeping then
          npc.frozen = false
        end
      end
      if opt("sleeping_npcs") then
        local pct = math.floor(tonumber(opt("sleep_pct")) or 15)
        local isNight = false
        if type(world.timeOfDay) == "function" then
          local ok, tod = pcall(function() return world:timeOfDay() end)
          isNight = ok and tod == "NIGHT"
        end
        for _, npc in ipairs(world.npcs or {}) do
          local d = npc.def or {}
          if d.johtoLifeAmbient and not d.johtoLifePokemon then
            local s = tostring(npc.id or d.name or "")
            local h = 0
            for i = 1, #s do h = h + s:byte(i) * i end
            local daySleeper = opt("day_sleepers") and ((h % 10) < 3)
            local window = daySleeper and (not isNight) or false
            if daySleeper then window = not isNight else window = isNight end
            if window and pct > 0 and (h % 100) < pct then
              npc.frozen = true
              npc.nightlifeSleeping = true
            elseif npc.nightlifeSleeping then
              npc.frozen = false
              npc.nightlifeSleeping = nil
            end
          end
        end
      end
      if world.map and (isTown(world.map.id) or isRoute(world.map.id) or isIndoor(world.map.id)) then
        local wantH = humanTarget(world.map.id)
        local wantP = pokeTarget(world.map.id)
        if #liveAmbient(world, false) ~= wantH or #liveAmbient(world, true) ~= wantP then
          spawnAmbient(world.map.id)
        end
      end
    end

    -- Talk: ambient, Pokemon ambient, and optional name-prefix for story NPCs
    local baseTalk = Overworld.talkTo
    Overworld.talkTo = function(world, npc)
      local d = npc and npc.def
      if d and d.johtoLifeAmbient then
        local display = d.johtoLifeDisplayName or displayNameFor(npc)
        if npc.nightlifeSleeping then
          pushText(world, display .. " is fast\nasleep.")
          return true
        end
        if d.johtoLifePokemon then
          local mon = d.johtoLifeMon or display
          local fmt = POKE_CRY_LINES[love.math.random(#POKE_CRY_LINES)]
          local body = fmt:format(mon, mon)
          pushText(world, display .. ":\n" .. body)
          return true
        end
        local name = tostring(d.name or "")
        local pool = name:find("ROUTE", 1, true) and routeLines or lines
        local idx = tonumber(name:match("_(%d+)$")) or 1
        local h = 0
        for i = 1, #name do h = h + name:byte(i) * i end
        pushText(world, display .. ":\n" .. pool[((idx + h - 1) % #pool) + 1])
        return true
      end
      -- Story / original NPCs: keep their dialogue, but show a name first
      if opt("name_all_npcs") and npc then
        local display = displayNameFor(npc)
        -- Let vanilla talk run; if it shows text without a name, we still
        -- try to surface the name in a short line when possible.
        if type(baseTalk) == "function" then
          local handled = baseTalk(world, npc)
          if handled then return true end
        end
        -- Fallback if vanilla had nothing
        pushText(world, display .. ":\n...")
        return true
      end
      if type(baseTalk) == "function" then return baseTalk(world, npc) end
      return false
    end
  else
    mod.log:warn("Johto Life: Overworld facade missing")
  end

  mod.log:info("Johto Life 0.1.3 loaded")
end
