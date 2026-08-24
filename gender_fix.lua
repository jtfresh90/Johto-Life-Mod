-- Drop-in gender helpers for Johto Life 0.1.10
-- Paste into main.lua replacing FEMALE_SPRITE_EXACT through genderFromNpc.

-- Crystal overworld sprite constants (pret/pokecrystal constants/sprite_constants.asm)
-- Gender by numeric sprite id when def.sprite is a number
local GENDER_BY_INDEX = {
  -- female
  [0x0a]="f", -- JANINE
  [0x0c]="f", -- MOM
  [0x0e]="f", -- REDS_MOM
  [0x0f]="f", -- DAISY
  [0x13]="f", -- WHITNEY
  [0x17]="f", -- JASMINE
  [0x19]="f", -- CLAIR
  [0x1b]="f", -- KAREN
  [0x1d]="f", -- MISTY
  [0x20]="f", -- ERIKA
  [0x22]="f", -- SABRINA
  [0x24]="f", -- COOLTRAINER_F
  [0x26]="f", -- TWIN
  [0x28]="f", -- LASS
  [0x29]="f", -- TEACHER
  [0x2a]="f", -- BEAUTY
  [0x2e]="f", -- POKEFAN_F
  [0x30]="f", -- GRANNY
  [0x32]="f", -- SWIMMER_GIRL
  [0x36]="f", -- ROCKET_GIRL
  [0x37]="f", -- NURSE
  [0x38]="f", -- LINK_RECEPTIONIST
  [0x3d]="f", -- KIMONO_GIRL
  [0x42]="f", -- RECEPTIONIST
  [0x58]="f", -- OLD_LINK_RECEPTIONIST
  [0x60]="f", -- KRIS
  [0x61]="f", -- KRIS_BIKE
  -- male (including overweight POKEFAN_M = 0x2d and fisher/gentleman/black belt)
  [0x01]="m", [0x02]="m", [0x03]="m", [0x04]="m", [0x05]="m",
  [0x06]="m", [0x07]="m", [0x08]="m", [0x09]="m", [0x0b]="m",
  [0x0d]="m", [0x10]="m", [0x11]="m", [0x12]="m", [0x14]="m",
  [0x15]="m", [0x16]="m", [0x18]="m", [0x1a]="m", [0x1c]="m",
  [0x1e]="m", [0x1f]="m", [0x21]="m", [0x23]="m", [0x25]="m",
  [0x27]="m", -- YOUNGSTER
  [0x2b]="m", -- SUPER_NERD
  [0x2c]="m", -- ROCKER
  [0x2d]="m", -- POKEFAN_M  (chubby / "overweight" male)
  [0x2f]="m", -- GRAMPS
  [0x31]="m", -- SWIMMER_GUY
  [0x35]="m", -- ROCKET
  [0x39]="m", -- CLERK
  [0x3a]="m", -- FISHER
  [0x3b]="m", -- FISHING_GURU
  [0x3c]="m", -- SCIENTIST
  [0x3e]="m", -- SAGE
  [0x3f]="m", -- UNUSED_GUY
  [0x40]="m", -- GENTLEMAN
  [0x41]="m", -- BLACK_BELT
  [0x43]="m", -- OFFICER
  [0x44]="m", -- CAL
  [0x46]="m", -- CAPTAIN
  [0x48]="m", -- GYM_GUIDE
  [0x49]="m", -- SAILOR
  [0x4a]="m", -- BIKER
  [0x4b]="m", -- PHARMACIST
  [0x62]="m", -- KURT_OUTSIDE
  [0x66]="m", -- STANDING_YOUNGSTER
}

-- Also match string names / substrings
local function genderFromNpc(npc)
  local d = npc and npc.def or {}
  -- numeric index first (most reliable on Gen2)
  local idx = tonumber(d.sprite) or tonumber(npc.spriteId) or tonumber(d.spriteId)
  if not idx and npc.sprite and type(npc.sprite.id) == "number" then
    idx = npc.sprite.id
  end
  if idx and GENDER_BY_INDEX[idx] then
    return GENDER_BY_INDEX[idx]
  end
  local spr = ""
  if npc.sprite and type(npc.sprite.id) == "string" then spr = npc.sprite.id:upper()
  elseif type(d.sprite) == "string" then spr = d.sprite:upper()
  elseif type(npc.spriteId) == "string" then spr = npc.spriteId:upper()
  end
  if spr ~= "" then
    if spr:find("POKEFAN_M", 1, true) or spr:find("POKEFANM", 1, true) then return "m" end
    if spr:find("POKEFAN_F", 1, true) or spr:find("POKEFANF", 1, true) then return "f" end
    if spr:find("HIKER", 1, true) or spr:find("FISHER", 1, true) then return "m" end
    if spr:find("BLACK_BELT", 1, true) or spr:find("BLACKBELT", 1, true) then return "m" end
    if spr:find("GENTLEMAN", 1, true) or spr:find("SAILOR", 1, true) then return "m" end
    if spr:find("GRAMPS", 1, true) or spr:find("OFFICER", 1, true) then return "m" end
    if spr:find("YOUNGSTER", 1, true) or spr:find("BUG_CATCHER", 1, true) then return "m" end
    if spr:find("SUPER_NERD", 1, true) or spr:find("ROCKER", 1, true) then return "m" end
    if spr:find("SWIMMER_GUY", 1, true) or spr:find("BIKER", 1, true) then return "m" end
    if spr:find("SAGE", 1, true) or spr:find("SCIENTIST", 1, true) then return "m" end
    if spr:find("LASS", 1, true) or spr:find("BEAUTY", 1, true) then return "f" end
    if spr:find("GRANNY", 1, true) or spr:find("TEACHER", 1, true) then return "f" end
    if spr:find("TWIN", 1, true) or spr:find("NURSE", 1, true) then return "f" end
    if spr:find("SWIMMER_GIRL", 1, true) or spr:find("KIMONO", 1, true) then return "f" end
    if spr:find("_F$") or spr:find("_F_") or spr:find("GIRL", 1, true) then return "f" end
    if spr:find("_M$") or spr:find("_M_") or spr:find("GUY", 1, true) then return "m" end
  end
  -- default male for unknown human town sprites (most Crystal outdoor fillers are male)
  return "m"
end
