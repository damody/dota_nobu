--require("equilibrium_constant")
print ( '[Nobu-lua] ADDON INIT EXECUTED' )

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

_G.CountUsedAbility_Table = {}

_G.heromap = {
  npc_dota_hero_kunkka              = "A01",
  npc_dota_hero_windrunner          = "A02",
  npc_dota_hero_ancient_apparition  = "A04",
  npc_dota_hero_troll_warlord       = "A06",
  npc_dota_hero_centaur             = "A07",
  npc_dota_hero_axe                 = "A08",
  npc_dota_hero_monkey_king         = "A09",
  npc_dota_hero_warlock             = "A10",
  npc_dota_hero_necrolyte           = "A11",
  npc_dota_hero_storm_spirit        = "A12",
  npc_dota_hero_zuus                = "A13",
  npc_dota_hero_lion                = "A14",
  npc_dota_hero_winter_wyvern       = "A15",
  npc_dota_hero_huskar              = "A16",
  npc_dota_hero_sniper              = "A17",
  npc_dota_hero_spectre             = "A19",
  npc_dota_hero_skeleton_king       = "A20",
  npc_dota_hero_luna                = "A21",
  npc_dota_hero_ember_spirit        = "A22",
  npc_dota_hero_witch_doctor        = "A23",
  npc_dota_hero_doom_bringer        = "A24",
  npc_dota_hero_treant              = "A25",
  npc_dota_hero_techies             = "A26",
  npc_dota_hero_omniknight          = "A27",
  npc_dota_hero_invoker             = "A28",
  npc_dota_hero_oracle              = "A29",
  npc_dota_hero_slardar             = "A30",
  npc_dota_hero_medusa              = "A31",
  npc_dota_hero_juggernaut          = "A32",
  npc_dota_hero_shadow_shaman       = "A33",
  npc_dota_hero_crystal_maiden      = "A34",

  npc_dota_hero_nevermore           = "B01",
  npc_dota_hero_faceless_void       = "B02",
  npc_dota_hero_elder_titan         = "B03",
  npc_dota_hero_clinkz              = "B04",
  npc_dota_hero_keeper_of_the_light = "B05",
  npc_dota_hero_dark_seer           = "B06",  
  npc_dota_hero_furion              = "B07",
  npc_dota_hero_magnataur           = "B08",
  npc_dota_hero_chen                = "B09",
  npc_dota_hero_phantom_assassin    = "B11",
  npc_dota_hero_razor               = "B12",
  npc_dota_hero_riki                = "B13",
  npc_dota_hero_meepo               = "B14",
  npc_dota_hero_bristleback         = "B15",
  npc_dota_hero_naga_siren          = "B16",
  npc_dota_hero_slark               = "B17",
  npc_dota_hero_queenofpain         = "B18",
  npc_dota_hero_lich                = "B19",
  npc_dota_hero_earth_spirit        = "B20",
  npc_dota_hero_chaos_knight        = "B21",
  npc_dota_hero_leshrac             = "B22",
  npc_dota_hero_enchantress         = "B23",
  npc_dota_hero_earthshaker         = "B24",
  npc_dota_hero_pugna               = "B25",
  npc_dota_hero_brewmaster          = "B26",
  npc_dota_hero_abaddon             = "B27", 
  npc_dota_hero_disruptor           = "B28",
  npc_dota_hero_abyssal_underlord   = "B30",
  npc_dota_hero_shadow_demon        = "B31",
  npc_dota_hero_dragon_knight       = "B32",
  npc_dota_hero_drow_ranger         = "B33",
  npc_dota_hero_beastmaster         = "B34",
  npc_dota_hero_visage              = "B36",

  npc_dota_hero_viper               = "C01",
  npc_dota_hero_legion_commander    = "C02",
  npc_dota_hero_ogre_magi           = "C03",
  npc_dota_hero_lina                = "C04",
  npc_dota_hero_obsidian_destroyer  = "C05",
  npc_dota_hero_ursa                = "C06",
  npc_dota_hero_silencer            = "C07",
  npc_dota_hero_lycan               = "C08",
  npc_dota_hero_vengefulspirit      = "C09",
  npc_dota_hero_antimage            = "C10",
  npc_dota_hero_tiny                = "C11",
  npc_dota_hero_spirit_breaker      = "C14",
  npc_dota_hero_mirana              = "C15",
  npc_dota_hero_rubick              = "C16",
  npc_dota_hero_puck                = "C17",
  npc_dota_hero_templar_assassin    = "C19",
  npc_dota_hero_terrorblade         = "C20",
  npc_dota_hero_alchemist           = "C21",
  npc_dota_hero_jakiro              = "C22",
  npc_dota_hero_undying             = "C23",
  npc_dota_hero_night_stalker       = "C24",
}

_G.nobu2dota = {}
for k,v in pairs(_G.heromap) do
  _G.nobu2dota[v]=k
end

_G.heromap_version = {
  A01 = {["11"] = true , ["16"] = true},
  A02 = {["11"] = true , ["16"] = true},
  A04 = {["11"] = true , ["16"] = true},
  A06 = {["11"] = true , ["16"] = true},
  A07 = {["11"] = true , ["16"] = true},
  A08 = {["11"] = true , ["16"] = true},
  A09 = {["11"] = true , ["16"] = true},
  A10 = {["11"] = true , ["16"] = true},
  A11 = {["11"] = true , ["16"] = true},
  A12 = {["11"] = false , ["16"] = true},
  A13 = {["11"] = true , ["16"] = true},
  A14 = {["11"] = true , ["16"] = true},
  A15 = {["11"] = true , ["16"] = true},
  A16 = {["11"] = false , ["16"] = true},
  A17 = {["11"] = true , ["16"] = true},
  A19 = {["11"] = true , ["16"] = true},
  A20 = {["11"] = true , ["16"] = true},
  A21 = {["11"] = true , ["16"] = true},
  A22 = {["11"] = true , ["16"] = true},
  A23 = {["11"] = false , ["16"] = true},
  A24 = {["11"] = false , ["16"] = true},
  A25 = {["11"] = true , ["16"] = true},
  A26 = {["11"] = true , ["16"] = true},
  A27 = {["11"] = true , ["16"] = true},
  A28 = {["11"] = true , ["16"] = true},
  A29 = {["11"] = true , ["16"] = true},
  A30 = {["11"] = true , ["16"] = true},
  A31 = {["11"] = true , ["16"] = true},
  A32 = {["11"] = true , ["16"] = true},
  A33 = {["11"] = true , ["16"] = true},
  A34 = {["11"] = true , ["16"] = true},

  B01 = {["11"] = true , ["16"] = true},
  B02 = {["11"] = true , ["16"] = true},
  B03 = {["11"] = true , ["16"] = true},
  B04 = {["11"] = true , ["16"] = true},
  B05 = {["11"] = true , ["16"] = true},
  B06 = {["11"] = true , ["16"] = true},
  B07 = {["11"] = true , ["16"] = true},
  B08 = {["11"] = true , ["16"] = true},
  B09 = {["11"] = true , ["16"] = true},
  B11 = {["11"] = true , ["16"] = true},
  B12 = {["11"] = false , ["16"] = true},
  B13 = {["11"] = true , ["16"] = true},
  B14 = {["11"] = true , ["16"] = true},
  B15 = {["11"] = true , ["16"] = true},
  B16 = {["11"] = true , ["16"] = true},
  B17 = {["11"] = true , ["16"] = true},
  B18 = {["11"] = true , ["16"] = true},
  B19 = {["11"] = true , ["16"] = true},
  B20 = {["11"] = true , ["16"] = true},
  B21 = {["11"] = true , ["16"] = true},
  B22 = {["11"] = true , ["16"] = true},
  B23 = {["11"] = true , ["16"] = true},
  B24 = {["11"] = false , ["16"] = true},
  B25 = {["11"] = true , ["16"] = true},
  B26 = {["11"] = false , ["16"] = true},
  B27 = {["11"] = true , ["16"] = true},
  B28 = {["11"] = true , ["16"] = true},
  B30 = {["11"] = true , ["16"] = true},
  B31 = {["11"] = true , ["16"] = true},
  B32 = {["11"] = true , ["16"] = true},
  B33 = {["11"] = true , ["16"] = true},
  B34 = {["11"] = true , ["16"] = true},
  B36 = {["11"] = true , ["16"] = true},

  C01 = {["11"] = true , ["16"] = true},
  C02 = {["11"] = true , ["16"] = true},
  C03 = {["11"] = true , ["16"] = true},
  C04 = {["11"] = true , ["16"] = true},
  C05 = {["11"] = true , ["16"] = true},
  C06 = {["11"] = true , ["16"] = true},
  C07 = {["11"] = true , ["16"] = true},
  C08 = {["11"] = true , ["16"] = true},
  C09 = {["11"] = true , ["16"] = true},
  C10 = {["11"] = true , ["16"] = true},
  C11 = {["11"] = true , ["16"] = true},
  C13 = {["11"] = false , ["16"] = true},
  C14 = {["11"] = true , ["16"] = true},
  C15 = {["11"] = true , ["16"] = true},
  C16 = {["11"] = true , ["16"] = true},
  C17 = {["11"] = true , ["16"] = true},
  C19 = {["11"] = true , ["16"] = true},
  C20 = {["11"] = true , ["16"] = true},
  C21 = {["11"] = true , ["16"] = true},
  C22 = {["11"] = true , ["16"] = true},
  C23 = {["11"] = false , ["16"] = true},
  C24 = {["11"] = true , ["16"] = true},
}

_G.heromap_skill = {
  A01 = {["11"] = "WERT" , ["16"] = "WERDT"},
  A02 = {["11"] = "WERT" , ["16"] = "WERT"},
  A04 = {["11"] = "WERDFT" , ["16"] = "WERDT"},
  A06 = {["11"] = "WERT" , ["16"] = "WERDT"},
  A07 = {["11"] = "WERT" , ["16"] = "WERDT"},
  A08 = {["11"] = "WERT" , ["16"] = "WERT"},
  A09 = {["11"] = "WERT" , ["16"] = "WERT"},
  A10 = {["11"] = "WERT" , ["16"] = "WERDT"},
  A11 = {["11"] = "WERT" , ["16"] = "WERT"},
  A12 = {["11"] = "" , ["16"] = "WERDT"},
  A13 = {["11"] = "WERT" , ["16"] = "WERDT"},
  A14 = {["11"] = "WERDT" , ["16"] = "WERT"},
  A15 = {["11"] = "WERT" , ["16"] = "WERT"},
  A16 = {["11"] = "" , ["16"] = "WERT"},
  A17 = {["11"] = "WERT" , ["16"] = "WERT"},
  A19 = {["11"] = "WERT" , ["16"] = "WERT"},
  A20 = {["11"] = "WERT" , ["16"] = "WERT"},
  A21 = {["11"] = "WERDT" , ["16"] = "WERDT"},
  A22 = {["11"] = "WERDT" , ["16"] = "WERT"},
  A23 = {["11"] = "" , ["16"] = "WERT"},
  A24 = {["11"] = "WERT" , ["16"] = "WERDT"},
  A25 = {["11"] = "WERDT" , ["16"] = "WERT"},
  A26 = {["11"] = "WERT" , ["16"] = "WERDT"},
  A27 = {["11"] = "WERT" , ["16"] = "WERDT"},
  A28 = {["11"] = "WERT" , ["16"] = "WERT"},
  A29 = {["11"] = "WERT" , ["16"] = "WERT"},
  A30 = {["11"] = "WERT" , ["16"] = "WERT"},
  A31 = {["11"] = "WERT" , ["16"] = "WERT"},
  A32 = {["11"] = "WERT" , ["16"] = "WERDFT"},
  A33 = {["11"] = "WERT" , ["16"] = "WERT"},
  A34 = {["11"] = "WERT" , ["16"] = "WERT"},

  B01 = {["11"] = "WERT" , ["16"] = "WERT"},
  B02 = {["11"] = "WERT" , ["16"] = "WERDT"},
  B03 = {["11"] = "WERT" , ["16"] = "WDFERT"},
  B04 = {["11"] = "WERDT" , ["16"] = "WERT"},
  B05 = {["11"] = "WERT" , ["16"] = "WERT"},
  B06 = {["11"] = "WERT" , ["16"] = "WERT"},
  B07 = {["11"] = "WERT" , ["16"] = "WERT"},
  B08 = {["11"] = "WERDT" , ["16"] = "WERT"},
  B09 = {["11"] = "WERT" , ["16"] = "WERT"},
  B11 = {["11"] = "WERDFT" , ["16"] = "WERDFT"},
  B12 = {["11"] = "WERT" , ["16"] = "WERT"},
  B13 = {["11"] = "WERDT" , ["16"] = "WERDBT"},
  B14 = {["11"] = "WERDT" , ["16"] = "WERDT"},
  B15 = {["11"] = "WERT" , ["16"] = "WERDT"},
  B16 = {["11"] = "WERT" , ["16"] = "WERDFT"},
  B17 = {["11"] = "WERT" , ["16"] = "WERT"},
  B18 = {["11"] = "WERT" , ["16"] = "WERT"},
  B19 = {["11"] = "WERDT" , ["16"] = "WERT"},
  B20 = {["11"] = "WERT" , ["16"] = "WERT"},
  B21 = {["11"] = "WERT" , ["16"] = "WERT"},
  B22 = {["11"] = "WERDT" , ["16"] = "WERT"},
  B23 = {["11"] = "WERDT" , ["16"] = "WERDT"},
  B24 = {["11"] = "" , ["16"] = "WERT"},
  B25 = {["11"] = "WERT" , ["16"] = "WERT"},
  B26 = {["11"] = "" , ["16"] = "WERDT"},
  B27 = {["11"] = "WERT" , ["16"] = "WERT"},
  B28 = {["11"] = "WERT" , ["16"] = "WERT"},
  B28 = {["11"] = "WERT" , ["16"] = "WERT"},
  B30 = {["11"] = "WERT" , ["16"] = "WERT"},
  B31 = {["11"] = "WERT" , ["16"] = "WERT"},
  B32 = {["11"] = "WERDT" , ["16"] = "WERDT"},
  B33 = {["11"] = "WERT" , ["16"] = "WERT"},
  B34 = {["11"] = "WERT" , ["16"] = "WERT"},
  B36 = {["11"] = "WERDT" , ["16"] = "WERDT"},

  C01 = {["11"] = "WERDT" , ["16"] = "WERT"},
  C02 = {["11"] = "WERDT" , ["16"] = "WERT"},
  C03 = {["11"] = "WERT" , ["16"] = "WERT"},
  C04 = {["11"] = "WERT" , ["16"] = "WERT"},
  C05 = {["11"] = "WERT" , ["16"] = "WERT"},
  C06 = {["11"] = "WERDT" , ["16"] = "WERDT"},
  C07 = {["11"] = "WERT" , ["16"] = "WERDT"},
  C08 = {["11"] = "WERDT" , ["16"] = "WERDT"},
  C09 = {["11"] = "WERT" , ["16"] = "WERT"},
  C10 = {["11"] = "WERT" , ["16"] = "WERT"},
  C11 = {["11"] = "WERT" , ["16"] = "WERT"},
  C13 = {["11"] = "WERT" , ["16"] = "WERT"},
  C14 = {["11"] = "WERT" , ["16"] = "WERT"},
  C15 = {["11"] = "WERT" , ["16"] = "WERT"},
  C16 = {["11"] = "WERDT" , ["16"] = "WERDT"},
  C17 = {["11"] = "WERT" , ["16"] = "WERDT"},
  C19 = {["11"] = "WERT" , ["16"] = "WERDT"},
  C20 = {["11"] = "WERT" , ["16"] = "WERT"},
  C21 = {["11"] = "WERT" , ["16"] = "WERT"},
  C22 = {["11"] = "WERT" , ["16"] = "WERDT"},
  C23 = {["11"] = "WERT" , ["16"] = "WERT"},
  C24 = {["11"] = "WERT" , ["16"] = "WERT"},
}


_G.heromap_autoskill = {
  A01 = {["11"] = "" , ["16"] = "D"},
  A02 = {["11"] = "" , ["16"] = ""},
  A04 = {["11"] = "F" , ["16"] = "D"},
  A06 = {["11"] = "" , ["16"] = ""},
  A07 = {["11"] = "" , ["16"] = "D"},
  A08 = {["11"] = "" , ["16"] = ""}, 
  A09 = {["11"] = "" , ["16"] = ""},
  A10 = {["11"] = "" , ["16"] = "D"},
  A11 = {["11"] = "" , ["16"] = ""},
  A12 = {["11"] = "" , ["16"] = "D"},
  A13 = {["11"] = "" , ["16"] = "D"},
  A14 = {["11"] = "" , ["16"] = ""},
  A15 = {["11"] = "" , ["16"] = ""},
  A16 = {["11"] = "" , ["16"] = ""},
  A17 = {["11"] = "" , ["16"] = ""},
  A19 = {["11"] = "" , ["16"] = ""},
  A20 = {["11"] = "" , ["16"] = ""},
  A21 = {["11"] = "D" , ["16"] = "D"},
  A22 = {["11"] = "D" , ["16"] = ""},
  A23 = {["11"] = "" , ["16"] = ""},
  A24 = {["11"] = "" , ["16"] = "D"},
  A25 = {["11"] = "D" , ["16"] = ""},
  A26 = {["11"] = "" , ["16"] = "D"},
  A27 = {["11"] = "" , ["16"] = ""},
  A28 = {["11"] = "" , ["16"] = ""},
  A29 = {["11"] = "" , ["16"] = ""},
  A30 = {["11"] = "" , ["16"] = ""},
  A31 = {["11"] = "" , ["16"] = ""},
  A32 = {["11"] = "" , ["16"] = "F"},
  A33 = {["11"] = "" , ["16"] = ""},
  A34 = {["11"] = "" , ["16"] = ""},

  B01 = {["11"] = "" , ["16"] = ""},
  B02 = {["11"] = "" , ["16"] = "D"},
  B03 = {["11"] = "" , ["16"] = ""},
  B04 = {["11"] = "" , ["16"] = ""},
  B05 = {["11"] = "" , ["16"] = ""},
  B06 = {["11"] = "" , ["16"] = ""},
  B07 = {["11"] = "" , ["16"] = ""},
  B08 = {["11"] = "" , ["16"] = ""},
  B09 = {["11"] = "" , ["16"] = ""},
  B11 = {["11"] = "DF" , ["16"] = "D"},
  B12 = {["11"] = "" , ["16"] = ""},
  B13 = {["11"] = "D" , ["16"] = ""},
  B14 = {["11"] = "" , ["16"] = "D"},
  B15 = {["11"] = "" , ["16"] = ""},
  B16 = {["11"] = "" , ["16"] = "D"},
  B17 = {["11"] = "" , ["16"] = ""},
  B18 = {["11"] = "" , ["16"] = ""},
  B19 = {["11"] = "" , ["16"] = ""},
  B20 = {["11"] = "" , ["16"] = ""},
  B21 = {["11"] = "" , ["16"] = ""},
  B22 = {["11"] = "D" , ["16"] = ""},
  B23 = {["11"] = "D" , ["16"] = "D"},
  B24 = {["11"] = "" , ["16"] = ""},
  B25 = {["11"] = "" , ["16"] = ""},
  B26 = {["11"] = "" , ["16"] = ""},
  B27 = {["11"] = "" , ["16"] = ""},
  B28 = {["11"] = "" , ["16"] = ""},
  B30 = {["11"] = "" , ["16"] = ""},
  B31 = {["11"] = "" , ["16"] = ""},
  B32 = {["11"] = "D" , ["16"] = ""},
  B33 = {["11"] = "" , ["16"] = ""},
  B34 = {["11"] = "" , ["16"] = ""},
  B36 = {["11"] = "D" , ["16"] = ""},

  C01 = {["11"] = "D" , ["16"] = ""},
  C02 = {["11"] = "D" , ["16"] = ""},
  C03 = {["11"] = "" , ["16"] = ""},
  C04 = {["11"] = "" , ["16"] = ""},
  C05 = {["11"] = "" , ["16"] = ""},
  C06 = {["11"] = "D" , ["16"] = "D"},
  C07 = {["11"] = "" , ["16"] = "D"},
  C08 = {["11"] = "D" , ["16"] = "D"},
  C09 = {["11"] = "" , ["16"] = ""},
  C10 = {["11"] = "" , ["16"] = ""},
  C11 = {["11"] = "" , ["16"] = ""},
  C14 = {["11"] = "" , ["16"] = ""},
  C15 = {["11"] = "" , ["16"] = ""},
  C16 = {["11"] = "D" , ["16"] = "D"},
  C17 = {["11"] = "" , ["16"] = "D"},
  C19 = {["11"] = "" , ["16"] = "D"},
  C20 = {["11"] = "" , ["16"] = ""},
  C21 = {["11"] = "" , ["16"] = ""},
  C22 = {["11"] = "" , ["16"] = "D"},
  C23 = {["11"] = "" , ["16"] = ""},
  C24 = {["11"] = "" , ["16"] = ""},
}

_G.hero_name_zh = {
  A01 = "德川家康",
  A02 = "稻姬",
  A03 = "石川數正",
  A04 = "竹中重治",
  A05 = "酒井忠次",
  A06 = "井伊直政",
  A07 = "本多忠勝",
  A08 = "榊原康政",
  A09 = "蜂須賀政勝",
  A10 = "平手政秀",
  A11 = "齋藤道三",
  A12 = "大谷吉繼",
  A13 = "服部半藏",
  A14 = "前田利家",
  A15 = "寧寧",
  A16 = "鳥居元忠",
  A17 = "佐佐成政",
  A18 = "稻葉一鐵",
  A19 = "黑田孝高",
  A20 = "九鬼嘉隆",
  A21 = "瑞龍院日秀",
  A22 = "仙石秀久",
  A23 = "宇喜多秀家",
  A24 = "佐久間盛政",
  A25 = "織田信長",
  A26 = "濃姫",
  A27 = "柴田勝家",
  A28 = "羽柴秀吉",
  A29 = "石田三成",
  A30 = "丹羽長秀",
  A31 = "森蘭丸",
  A32 = "瀧川一益",
  A33 = "本多正信",
  A34 = "阿松",
  A35 = "島左近",
  A36 = "前野長康",
  B01 = "雜賀孫市",
  B02 = "風魔小太郎",
  B03 = "齋藤朝信",
  B04 = "伊達政宗",
  B05 = "毛利元就",
  B06 = "真田幸村",
  B07 = "足利義昭",
  B08 = "淺井長政",
  B09 = "真田昌幸",
  B10 = "三好長慶",
  B11 = "菊姬",
  B12 = "山本勘助",
  B13 = "百地三太夫",
  B14 = "片倉景綱",
  B15 = "今川義元",
  B16 = "望月千代女",
  B17 = "霧隱才藏",
  B18 = "湖衣姬",
  B19 = "宇佐美定滿",
  B20 = "山縣昌景",
  B21 = "馬場信房",
  B22 = "太原雪齋",
  B23 = "伊勢姬",
  B24 = "秋山信友",
  B25 = "本願寺顯如",
  B26 = "大熊朝秀",
  B27 = "小島貞興",
  B28 = "松永久秀",
  B29 = "村上義清",
  B30 = "柿崎景家",
  B31 = "武田信玄",
  B32 = "上杉謙信",
  B33 = "最上義姬",
  B34 = "武田勝賴",
  B35 = "北條早雲",
  B36 = "直江兼續",
  C01 = "明智光秀",
  C02 = "明智秀滿",
  C03 = "島津義弘",
  C04 = "阿國",
  C05 = "前田慶次",
  C06 = "石川五右衛門",
  C07 = "立花道雪",
  C08 = "加藤段藏",
  C09 = "立花誾千代",
  C10 = "香宗我部親泰",
  C11 = "立花宗茂",
  C12 = "大友宗麟",
  C13 = "龍造寺隆信",
  C14 = "齋藤義龍",
  C15 = "玉子",
  C16 = "果心居士",
  C17 = "阿市",
  C18 = "小早川隆景",
  C19 = "松姬",
  C20 = "長宗我部元親",
  C21 = "宮本武藏",
  C22 = "佐佐木小次郎",
  C23 = "加藤清正",
  C24 = "柳生宗嚴",
}


--【全局變量】
_G.nobu_debug = false--IsInToolsMode() --是否在測試模式
_G.nobu_server_b = true
_G.nobu_chubing_b = true
_G.Nobu_Test = class({})

if Nobu == nil then
  _G.Nobu = class({})
else
  --先Stop事件，為了reload script用
  for i,v in ipairs(Nobu.Event) do
    StopListeningToGameEvent(v)
  end

  --停止filter

  --GameRules:GetGameModeEntity():ClearDamageFilter()
  GameRules:GetGameModeEntity():ClearExecuteOrderFilter()
  GameRules:GetGameModeEntity():ClearModifyGoldFilter()
  GameRules:GetGameModeEntity():ClearDamageFilter()
  --GameRules:GetGameModeEntity():ClearAbilityTuningValueFilter()

  --重新註冊
  Nobu = nil
  _G.Nobu = class({})

  --重新註冊用
  Script_reload_B = true
end

--【require】
require('require')


--【初始化】
function Activate()
  -- if Script_reload_B == false then
    print("[Nobu-lua] Activate")
    -- Script_reload_B = true
    -- StopListeningToAllGameEvents(Nobu:GetEntityHandle())

    AMHCInit()
    if _G.nobu_server_b then
      Nobu:CheckAFK() --Server Init
    end
    Nobu:InitGameMode()
    Nobu:Init_Event_and_Filter_GameMode() --管理事件、Filter
  -- end
end

--【資源預載】
function Precache( context )
  -- 【KV資源預載】
  --PrecacheEveryThingFromKV(context)   --有問題:會超lag
  PrecacheResource( "model", "models/heroes/broodmother/spiderling.vmdl", context )
  -- 【特效預載】
    local particle_Precache_Table = {
    --淺井長政
    "particles/b01w/b01w.vpcf",
    --武田勝賴
    "particles/units/heroes/hero_beastmaster/beastmaster_wildaxe.vpcf",
    "particles/b34e/b34e.vpcf",
    "particles/b34e/b34e2.vpcf",

    --立花道雪
    "particles/c07w/c07w.vpcf",
    "particles/c07e3/c07e3.vpcf",
    "particles/econ/items/razor/razor_punctured_crest/razor_static_link_blade.vpcf",
    "particles/c07e3/c07e3.vpcf",
    "particles/07t/c07t.vpcf",
    "particles/07t/c07t_zc.vpcf",
    "particles/b05e/b05e.vpcf",

    --光秀
    "particles/c09/c09w_hide.vpcf",
    --阿市
    "particles/c17w/c17w.vpcf",

    --秋山信友
    "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf",
    "particles/b24t/b01t.vpcf",
    "particles/b24w/b24w.vpcf" ,
    "particles/units/heroes/hero_tiny/tiny_avalanche.vpcf",
    "particles/b24t3/b24t3.vpcf",
    "particles/b13e/b13e.vpcf",

    "particles/b08w2/b08w2.vpcf",
    "particles/b08t_2/b08t.vpcf",

    --羽柴秀吉
    "particles/econ/items/phoenix/phoenix_solar_forge/phoenix_sunray_solar_forge.vpcf",
    --鳥居元宗
    "particles/generic_gameplay/generic_hit_blood.vpcf",
    "particles/a16r3/a16r3.vpcf",
    --巨龍
    "particles/item/dragon.vpcf",
    --星杵
    "particles/item/item_club_of_nebula.vpcf",
    "particles/a07w5/a07w5.vpcf",
    "particles/a07w4/a07w4_c.vpcf",
    "particles/a34e2/a34e2.vpcf",
    "particles/a04r3/a04r3.vpcf",
    --法術書
    "particles/item/item_spell_book.vpcf",
    "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf",
    --吹箭
    "particles/units/heroes/hero_gyrocopter/gyro_base_attack.vpcf",
    "particles/item/item_flood_book.vpcf",
    "particles/item/item_ignite_book.vpcf",
    --闇牙黃泉津
    "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_model.vpcf",
    --三日月宗近
    "particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_impact_notarget_moonfall.vpcf",
    "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf",
    --忍者刀
    "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf",
    "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_start.vpcf",
    "particles/econ/items/necrolyte/necronub_base_attack/necrolyte_base_attack_ka_glow.vpcf",
    "particles/econ/items/templar_assassin/templar_assassin_focal/ta_focal_base_attack_explosion.vpcf",
    "particles/item/item_commander_of_fantop.vpcf",
    "particles/generic_gameplay/generic_sleep.vpcf",
    --池田鬼神丸國重
    "particles/econ/items/phantom_lancer/phantom_lancer_immortal_ti6/phantom_lancer_immortal_ti6_spiritlance_cast_flash.vpcf",
    "particles/radiant_fx/tower_good3_powerline.vpcf",
    "particles/generic_gameplay/dropped_tango_aura.vpcf",
    "particles/units/heroes/hero_undying/undying_decay_fakeprojectile_glow.vpcf",
    
    "particles/units/heroes/hero_gyrocopter/gyro_base_attack.vpcf",

    "particles/econ/items/puck/puck_alliance_set/puck_dreamcoil_magic_aproset.vpcf",

    "particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf",
    
    "particles/b02r3/b02r3.vpcf",

    "particles/item/item_perceive_wine.vpcf",

    --國鋼
    "particles/item/item_the_great_sword_of_spike.vpcf",

    "particles/item/war_speedup3.vpcf",
    "particles/item/war_light.vpcf",
    "particles/econ/courier/courier_onibi/courier_onibi_green_ambient_c.vpcf",
    "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf",

    "particles/a07e/a07e_t.vpcf",
    "particles/a07r/a07r_c.vpcf",
    "particles/shake2.vpcf",
    "particles/shake3.vpcf",
    -- 鐵碎牙．妖刀
    "particles/generic_gameplay/generic_slowed_cold.vpcf",
    "particles/item/item_the_great_sword_of_hurricane.vpcf",
    "particles/item/item_the_great_sword_of_hurricane/tornado.vpcf",
    -- 鱗片甲
    "particles/econ/items/axe/axe_cinder/axe_cinder_battle_hunger_flames_b.vpcf",
    "particles/item/item_flame_armor/flame_aura.vpcf",
    -- 狐火大鎧
    "particles/econ/items/axe/axe_cinder/axe_cinder_battle_hunger_flames_b.vpcf",
    "particles/item/item_foxfire_armor/foxfire_aura.vpcf",
    -- 冰計
    "particles/item/item_ice_book/ice.vpcf",
    "particles/b33/b33r_old_poison.vpcf",
    "particles/q09_2/q09_2.vpcf",
    -- 洞寶
    "particles/b05t3/b05t3_j0.vpcf",
    -- 葵紋越前康繼．禦神刀 11.2B
    "particles/item/item_the_great_sword_of_sunflower_pattern_echizen_kang_following/item_the_great_sword_of_sunflower_pattern_echizen_kang_following.vpcf",
    -- 鐵碎牙．妖刀 11.2B
    "particles/item/item_the_great_sword_of_iron_fragmentor/item_the_great_sword_of_iron_fragmentor.vpcf",
    "particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf",
    "particles/item/item_the_great_sword_of_iron_fragmentor/item_the_great_sword_of_iron_fragmentor_hit.vpcf",

    -- 施法提示
    "particles/spell_hint/spell_hint_circle.vpcf",
    "particles/spell_hint/spell_hint_circle_fog.vpcf",
    --真 池田鬼神丸國重．銘刀
    "particles/item/diseaseonkey_king_spring_water_base.vpcf",
    -- 水計
    "particles/a11w/a11wonkey_king_spring_water_base.vpcf",
    --地藏王菩薩木雕‧古物
    "particles/c19_projectile/c19_projectile.vpcf",
    --狂風之書
    "particles/item/wind.vpcf",
    --蠍尾妖弓
    "particles/b33r/b33r.vpcf",
    --犒賞
    "particles/item/reward6300.vpcf",

    "particles/a19/a19_wfire/mk_arcana_spring_fire_ring_glow.vpcf",
    "particles/a19/a19_wfire/mk_arcana_spring_fire_ring_glow_2.vpcf",
    --落石
    "particles/item/item_rockfall_bookinvoker_chaos_meteor_fly2.vpcf",
    --注意要加,
    }
    for i,v in ipairs(particle_Precache_Table) do
      PrecacheResource("particle", v, context)
    end

    -- 【聲音預載】
    local sound_Precache_Table = {
      --武田勝賴
      -- "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts"
    "soundevents/items/item_the_overflame_art_of_war.vsndevts",
    "soundevents/items/D09.vsndevts",
    "soundevents/items/D03.vsndevts",
    "soundevents/custom_sounds.vsndevts",
    "soundevents/game_sounds_heroes/game_sounds_lich.vsndevts",
    "soundevents/game_sounds_heroes/game_sounds_nyx_assassin.vsndevts",
    "soundevents/a07t.vsndevts",
    "soundevents/a28r.vsndevts",
    "soundevents/nobu_sounds_items.vsndevts",
    --"soundevents/game_sounds_creeps.vsndevts",
    "soundevents/game_sounds_heroes/game_sounds_abaddon.vsndevts",
    "soundevents/a17.vsndevts",
    "soundevents/game_sounds_heroes/game_sounds_slark.vsndevts",
    --制魔
    "particles/item/supressor_armor.vpcf",
    }
    for i,v in ipairs(sound_Precache_Table) do
      PrecacheResource("soundfile", v, context)
    end
end

--特別做來script reload
if Script_reload_B then
  print("Script_reload_B")
  Timers:CreateTimer(1,function()
    Activate()
  end)
end
--[[
if true and not debug.bHookIsSet then
debug.sethook(function( ... )
  local info = debug.getinfo(2)
  local src = tostring(info.short_src)
  local name = tostring(info.name)
  if name ~= "__index" then
    print(debug.traceback("Crash "..src.." "..name))
  end
  -- body
end, "c")
debug.bHookIsSet = true
end
]]

function CDOTA_BaseNPC:GetMagicalArmorValue()
  return 30.0
end