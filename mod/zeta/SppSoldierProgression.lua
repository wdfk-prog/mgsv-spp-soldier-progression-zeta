-- SppSoldierProgression.lua
-- Zeta module for MGSV:TPP staff rank progression.
-- Works through ZetaMbmCommonSetting's non-replacer merge path.
--
-- Modes:
--   0 = Gradual (source-style: vanilla early game, S+/S++ progression later)
--   1 = Gradual+ (source-style behavior: S is available from 1% early and rises with MB level)
--   2 = High-A Gradual (A/A+/A++ from the start, then S/S+/S++ progression)
--   3 = High-A Gradual+ (High-A start + S available from 1% early)
--   4 = Custom High Ranks (A/A+/A++/S/S+/S++ user weights)
--   5 = 100% S++
--   6 = Vanilla
--
-- Notes:
-- * The public Nexus description documents the behavior of spp_gradual+ but does not publish
--   its complete per-threshold table. The Gradual+ curve below reproduces that documented
--   behavior rather than claiming a byte-for-byte copy of the original .mgsv.
-- * The later Gradual thresholds follow the publicly documented S++ progression values.
-- * Fast MB Brig is optional and uses the documented timeMinutePer1Enmity=0 method.

local this = {
  modName = "S++ Soldier Progression",
  modDesc = "Configurable A/S/S+/S++ field-soldier progression using Zeta's MbmCommonSetting merge.",
  modCategory = "Gameplay",
  modLoadOrder = 90,
}

local rankKeys = {"g","f","e","d","c","b","a","s","sp","spp"}

local function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

local function copyEntry(src)
  local dst = {}
  if src ~= nil then
    for k,v in pairs(src) do dst[k] = v end
  end
  return dst
end

local function copyArray(src)
  local dst = {}
  if src ~= nil then
    for i,v in ipairs(src) do dst[i] = copyEntry(v) end
  end
  return dst
end

local function clearRanks(row)
  for _,key in ipairs(rankKeys) do row[key] = 0 end
end

local function setRanks(row, values)
  clearRanks(row)
  if values ~= nil then
    for k,v in pairs(values) do row[k] = v end
  end
end

-- Publicly documented gradual progression tail from the classic S++ Soldier Mod.
-- Internal rank mapping used by MbmCommonSetting:
-- c=A, b=A+, a=A++, s=S, sp=S+, spp=S++.
local function gradualStage(level)
  if level < 385 then return nil end
  if level < 413 then
    return {c=11,b=31,a=35,s=15,sp=8,spp=0}
  elseif level < 434 then
    return {c=5,b=25,a=35,s=20,sp=15,spp=0}
  elseif level < 574 then
    return {c=0,b=20,a=35,s=20,sp=20,spp=5}
  elseif level < 756 then
    return {c=0,b=0,a=15,s=35,sp=35,spp=15}
  elseif level < 840 then
    return {c=0,b=0,a=5,s=35,sp=40,spp=20}
  elseif level < 1050 then
    return {c=0,b=0,a=0,s=0,sp=50,spp=50}
  end
  return {c=0,b=0,a=0,s=0,sp=0,spp=100}
end

local function applyGradualTail(rows)
  for _,row in ipairs(rows) do
    local stage = gradualStage(row.totalSectionLv or 0)
    if stage ~= nil then setRanks(row, stage) end
  end
  return rows
end

-- High-A opening: only A/A+/A++ before the documented S+/S++ progression begins.
-- This is a Zeta-specific adaptation because the Nexus page says an A/A+/A++ variant exists
-- but does not publish that variant's exact table.
local function applyHighAOpening(rows)
  for _,row in ipairs(rows) do
    local level = row.totalSectionLv or 0
    if level < 385 then
      local p = clamp(level / 385, 0, 1)
      local aRank = math.floor((45 - 25 * p) + 0.5)      -- A:   45 -> 20
      local aPlus = math.floor((35 -  4 * p) + 0.5)     -- A+:  35 -> 31
      local aPlusPlus = 100 - aRank - aPlus             -- A++: remainder
      setRanks(row, {c=aRank,b=aPlus,a=aPlusPlus})
    end
  end
  return rows
end

local function takePoints(row, amount, donors)
  local left = amount
  for _,key in ipairs(donors) do
    if left <= 0 then break end
    local cur = row[key] or 0
    local take = math.min(cur, left)
    row[key] = cur - take
    left = left - take
  end
  return amount - left
end

-- spp_gradual+ is documented as keeping S available from 1% at the start and increasing
-- as Mother Base levels up. The full original threshold table is not publicly listed.
-- This curve rises from 1% to 15% by totalSectionLv 385, then keeps at least 15% S
-- until the final 1050 threshold where the classic progression reaches 100% S++.
local function applyAlwaysS(rows)
  for _,row in ipairs(rows) do
    local level = row.totalSectionLv or 0
    if level < 1050 then
      local ramp = clamp(level / 385, 0, 1)
      local targetS = 1 + math.floor(14 * ramp + 0.5)
      local currentS = row.s or 0
      if currentS < targetS then
        local needed = targetS - currentS
        -- Remove probability from lower ranks first. If the late-game table has no lower
        -- ranks left, take from S+ before S++.
        local removed = takePoints(row, needed, {"g","f","e","d","c","b","a","sp","spp"})
        row.s = currentS + removed
      end
    end
  end
  return rows
end

local function make100Spp(rows)
  for _,row in ipairs(rows) do setRanks(row, {spp=100}) end
  return rows
end

local function normalizedCustomRanks()
  local raw = {
    c   = math.max(0, this.ZVar("CustomA",   {default=20}) or 0),
    b   = math.max(0, this.ZVar("CustomAP",  {default=20}) or 0),
    a   = math.max(0, this.ZVar("CustomAPP", {default=30}) or 0),
    s   = math.max(0, this.ZVar("CustomS",   {default=15}) or 0),
    sp  = math.max(0, this.ZVar("CustomSP",  {default=10}) or 0),
    spp = math.max(0, this.ZVar("CustomSPP", {default=5}) or 0),
  }

  local order = {"c","b","a","s","sp","spp"}
  local total = 0
  for _,key in ipairs(order) do total = total + raw[key] end
  if total <= 0 then return {a=100} end

  -- Largest-remainder normalization: preserves the requested ratios and guarantees 100 total.
  local out, fractions = {}, {}
  local used = 0
  for _,key in ipairs(order) do
    local exact = raw[key] * 100 / total
    local base = math.floor(exact)
    out[key] = base
    used = used + base
    table.insert(fractions, {key=key, frac=exact-base})
  end
  table.sort(fractions, function(x,y) return x.frac > y.frac end)
  local remaining = 100 - used
  for i=1,remaining do
    local item = fractions[((i-1) % #fractions) + 1]
    out[item.key] = out[item.key] + 1
  end
  return out
end

local function makeCustom(rows)
  local custom = normalizedCustomRanks()
  for _,row in ipairs(rows) do setRanks(row, custom) end
  return rows
end

local function makeFastBrig(baseTable)
  local ret = {}
  local source = baseTable and baseTable.timeMinutePer1Enmitys or nil
  if source ~= nil and next(source) then
    for _,entry in ipairs(source) do
      table.insert(ret, {index=entry.index, heroicPoint=entry.heroicPoint, timeMinutePer1Enmity=0})
    end
  else
    -- Fallback for the stock/Zeta table: indexes 0..10.
    for i=0,10 do table.insert(ret, {index=i, heroicPoint=i*1000, timeMinutePer1Enmity=0}) end
  end
  return ret
end

function this.MbmCommonSetting(zetaMbm)
  local base = {}
  if zetaMbm ~= nil and zetaMbm.GetTable ~= nil then
    local ok, result = pcall(zetaMbm.GetTable)
    if ok and result ~= nil then base = result end
  end

  local ret = {}
  local mode = this.ZVar("Mode", {default=3}) or 3
  local baseRanges = base.staffBaseRankRanges or {}

  if mode ~= 6 and baseRanges ~= nil and next(baseRanges) then
    local rows = copyArray(baseRanges)

    if mode == 0 then
      -- Source-style Gradual: vanilla early progression, documented S/S+/S++ tail.
      rows = applyGradualTail(rows)
    elseif mode == 1 then
      -- Source-style Gradual+: Gradual plus always-available S from 1% early.
      rows = applyGradualTail(rows)
      rows = applyAlwaysS(rows)
    elseif mode == 2 then
      -- High-A Gradual: A/A+/A++ from the start, then documented gradual tail.
      rows = applyHighAOpening(rows)
      rows = applyGradualTail(rows)
    elseif mode == 3 then
      -- High-A Gradual+: High-A opening plus early S chance.
      rows = applyHighAOpening(rows)
      rows = applyGradualTail(rows)
      rows = applyAlwaysS(rows)
    elseif mode == 4 then
      -- User-controlled high-rank distribution at every threshold.
      rows = makeCustom(rows)
    elseif mode == 5 then
      rows = make100Spp(rows)
    end

    ret.staffBaseRankRanges = rows
  end

  if (this.ZVar("FastBrig", {default=0}) or 0) > 0 then
    ret.timeMinutePer1Enmitys = makeFastBrig(base)
  end

  return ret
end

local function applyNow()
  if ZetaMbmCommonSetting ~= nil and ZetaMbmCommonSetting.Reload ~= nil then
    local ok = pcall(ZetaMbmCommonSetting.Reload)
    if TppUiCommand ~= nil and TppUiCommand.AnnounceLogView ~= nil then
      if ok then
        TppUiCommand.AnnounceLogView("[S++ Progression] Applied. Reload mission/ACC for new soldiers.")
      else
        TppUiCommand.AnnounceLogView("[S++ Progression] Reload failed; restart the game.")
      end
    end
  end
end

function this.ModMenu()
  return {
    {
      var="Mode",
      name="Progression Mode",
      desc="Choose rank progression. Changes affect newly generated soldiers; reload the mission/ACC after applying.",
      list={
        "Gradual",
        "Gradual+",
        "High-A Gradual",
        "High-A Gradual+",
        "Custom High Ranks",
        "100% S++",
        "Vanilla"
      },
      default=3,
    },
    {
      var="CustomProbMenu",
      name="Custom Probabilities",
      desc="Used only by Custom High Ranks. Values are treated as weights and normalized to exactly 100%.",
      options={
        {var="CustomA",   name="A %",   desc="Custom A-rank weight.",   number={min=0,max=100,inc=1}, default=20},
        {var="CustomAP",  name="A+ %",  desc="Custom A+-rank weight.",  number={min=0,max=100,inc=1}, default=20},
        {var="CustomAPP", name="A++ %", desc="Custom A++-rank weight.", number={min=0,max=100,inc=1}, default=30},
        {var="CustomS",   name="S %",   desc="Custom S-rank weight.",   number={min=0,max=100,inc=1}, default=15},
        {var="CustomSP",  name="S+ %",  desc="Custom S+-rank weight.",  number={min=0,max=100,inc=1}, default=10},
        {var="CustomSPP", name="S++ %", desc="Custom S++-rank weight.", number={min=0,max=100,inc=1}, default=5},
      },
    },
    {
      var="FastBrig",
      name="Fast MB Brig",
      desc="Optional: nullifies the MB brig rank-time multiplier. Typical conversion is about 10-15 minutes. Does not affect FOB brig.",
      default=0,
    },
    {
      var="ApplyNow",
      name="Apply / Reload",
      desc="Apply the selected rank/brig settings. Then return to ACC or start/restart a mission so enemies are regenerated.",
      command=applyNow,
    },
  }
end

return this
