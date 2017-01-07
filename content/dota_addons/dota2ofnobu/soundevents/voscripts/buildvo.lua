
function readAll(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

heromap = {
  bristleback = "b15",
  earthshaker = "b24",
  brewmaster = "b26",
  silencer = "c07",
  sniper = "a17",
  beastmaster = "b34",
  huskar = "a16",

  mirana = "c15",
  antimage = "c10",
  crystal_maiden = "a34",
  storm_spirit = "a12",
  
  troll_warlord = "a06",
  faceless_void = "b02",
  broodmother = "a13",

  invoker = "a28",
  omniknight = "a27",
  oracle = "a29",
  ancient_apparition = "a04",
  dragon_knight = "b32",
  drow_ranger = "b33",
  
  nevermore = "b01",
  pugna = "b25",
  axe = "b06",
  viper = "c01",
  windrunner = "c17",
  keeper_of_the_light = "b05",
  jakiro = "c22",
  alchemist = "c21",
  treant = "a25",
  templar_assassin = "c19",
  medusa = "a31",
  magnataur = "b08",
  centaur = "a07",
  naga_siren = "b16",
}

local template = readAll("game_sounds_vo_template.vsndevts")
for idx, val in pairs(heromap) do
  local temp = template
  temp = string.gsub(temp, "template", idx)
  temp = string.gsub(temp, "XNUM", val)
  local f = io.open("game_sounds_vo_"..idx..".vsndevts", "wb")
  f:write(temp)
  f:close()
end

