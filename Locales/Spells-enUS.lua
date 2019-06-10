-- Spells-enUS.lua
spellTable_Damage = { --~spec
        
    -- Frost Mage:
    [153595]    = 64, -- Comet Storm
    [112948]    = 64, -- Frost Bomb
    [157997]    = 64, -- Ice Nova
    [84714]     = 64, -- Frozen Orb
    [84721]     = 64, -- Frozen Orb
    [10]        = 64, -- Blizzard
    [190357]    = 64, -- Blizzard
    [30455]     = 64, -- Ice Lance
    [148022]    = 64, -- Icicle
    [228598]    = 64, -- Ice Lance
    [228597]    = 64, -- Frostbolt
    [116]       = 64, -- Frostbolt
    [228600]    = 64, -- glacial spike
    [228354]    = 64, -- flurry
    [257338]    = 64, -- ebonbolt
    
            -- Shadow Priest:
    [15286]     = 258, -- Vampiric Embrace
    [32379]     = 258, -- Shadow Word: Death
    [73510]     = 258, -- Mind Spike
    [78203]     = 258, -- Shadowy Apparitions
    [34914]     = 258, -- Vampiric Touch
    [8092]      = 258, -- Mind Blast
    [15407]     = 258, -- Mind Flay
    [228266]    = 258, -- Void Bolt
    [228260]    = 258, --Void Eruption

            -- Affliction :
    [152109]    = 265, -- Soulburn: Haunt
    [165367]    = 265, -- Eradication
    [113860]    = 265, -- Dark Soul: Misery
    [77215]     = 265, -- Mastery: Potent Afflictions
    [86121]     = 265, -- Soul Swap
    [48181]     = 265, -- Haunt
    [980]       = 265, -- Agony
    [103103]    = 265, -- Drain Soul
    [27243]     = 265, -- Seed of Corruption
    [117198]    = 265, -- Soul Shards
    [74434]     = 265, -- Soulburn
    [108558]    = 265, -- Nightfall
    [30108]     = 265, -- Unstable Affliction
    [233490]    = 265, -- Unstable Affliction
}

--[[ 
spellTable_Control {
    	--mage
		[2139]	= true, -- Counterspell
		[44572]	= true, -- Deep Freeze
		[58534]	= true, -- Deep Freeze
		[31661]	= true, -- Dragon's Breath
		[33395]	= true, -- Freeze (pet)
		[122]		= true, -- Frost Nova
		[102051]	= true, -- Frostjaw
		[157997]	= true, -- Ice Nova
		[111340]	= true, -- Ice Ward
		[118]		= true, -- Polymorph sheep
		[28272]	= true, -- Polymorph pig
		[126819]	= true, -- Polymorph pig 2
		[61305]	= true, -- Polymorph black cat
		[61721]	= true, -- Polymorph rabbit
		[61780]	= true, -- Polymorph turkey
		[28271]	= true, -- Polymorph turtle
		[161354]	= true, -- Polymorph Monkey
		[161353]	= true, -- Polymorph Polar Bear Cub
		[161355]	= true, -- Polymorph Penguin
		[82691]	= true, -- Ring of frost
		
		--priest
        [605]		= true, -- Dominate Mind
        [87194]	= true, -- Glyph of Mind Blast
        [88625]	= true, -- Holy Word: Chastise
        [64044]	= true, -- Psychic Horror
        [8122]	= true, -- Psychic scream
        [9484]	= true, -- Shackle undead
        [15487]	= true, -- Silence
        [131556]	= true, -- Sin and Punishment
        [114404]	= true, -- Void Tendril's Grasp

  		--warlock
        [89766]	= true, -- Axe Toss (Felguard)
        [111397]	= true, -- Blood Horror
        [170996]	= true, -- Debilitate (terrorguard)
        [5782] 	= true, -- Fear
        [118699]	= true, -- Fear		
        [5484]	= true, -- Howl of terror
        [115268]	= true, -- Mesmerize (shivarra)
        [6789] 	= true, -- Mortal Coil
        [115781]	= true, -- Optical Blast (improved spell lock from Grimoire of Supremacy)
        [6358]	= true, -- Seduction (succubus)
        [30283]	= true, -- Shadowfury
        [19647]	= true, -- Spell Lock (Felhunters)
        [31117]	= true, -- Unstable Affliction
        [179057]	= true, --Chaos Nova          
}

spellTable_Cooldowns = {
		-- 1 attack cooldown
		-- 2 personal defensive cooldown
		-- 3 targetted defensive cooldown
		-- 4 raid defensive cooldown
		-- 5 personal utility cooldown
		--MAGE
			--frost
	[64] = {
		[12472] = 1, --Icy Veins
		[205021] = 1, --Ray of Frost
		[55342] = 1, --Mirror Image
		[45438] = 2, --Ice Block
		[66] = 5, --Invisibility
        [235219] = 5, --Cold Snap
    },
		
		--PRIEST
			--shadow priest
	[258] = {
		[34433] = 1, --Shadowfiend
		[200174] = 1, --Mindbender
		[193223] = 1, --Surrender to Madness
		[47585] = 2, --Dispersion
		[15286] = 4, --Vampiric Embrace
		[64044] = 5, --Psychic Horror
		[8122] = 5, --Psychic Scream
},
            		--WARLOCK
			--affliction
	[265] = {
		[205180] = 1, --Summon Darkglare
		[113860] = 1, --Dark Soul: Misery
		[104773] = 2, --Unending Resolve
		[108416] = 2, --Dark Pact				
		[30283] = 5, --Shadowfury
		[6789] = 5, --Mortal Coil
    },
}

spellTable_Absorbs = {
        --priest
	    [47753]	=	true,  --Divine Aegis (discipline)
	    [17]		=	true,  --Power Word: Shield (discipline)
	    [114908]	=	true,  --Spirit Shell (discipline)
	    [114214]	=	true,  --Angelic Bulwark (talent)
	    [152118]	=	true,  --Clarity of Will (talent)

	    --warlock
	    --[6229]	=	true, --Twilight Ward
	    [108366]	=	true, --Soul Leech (talent)
	    [108416]	=	true, --Sacrificial Pact (talent)
	    [110913]	=	true, --Dark Bargain (talent)
	    [7812]	=	true, --Voidwalker's Sacrifice

	    --mage
	    [11426]	=	true, --Ice Barrier (talent)
	    [1463]	=	true, --Incanter's Ward (talent)
}

classIdToName = {
        [64]        = "MAGE", -- Frost Mage
        [258]       = "PRIEST", -- Shadow Priest
        [265]       = "WARLOCK", -- Affliction Warlock
}

tableClassTalents = {
    [87023]	    =	"MAGE", -- "Cauterize"
    [152087]	=	"MAGE", -- "Prismatic Crystal"
    [157750]	=	"MAGE", -- "Summon Water Elemental"
    [159916]	=	"MAGE", -- "Amplify Magic"
    [157913]	=	"MAGE", -- "Evanesce"
    [153561]	=	"MAGE", -- "Meteor"
    [157978]	=	"MAGE", -- "Unstable Magic"
    [157980]	=	"MAGE", -- "Supernova"
    [153564]	=	"MAGE", -- "Meteor"
    [44461]	    =	"MAGE", -- "Living Bomb"
    [148022]	=	"MAGE", -- "Icicle"
    [155152]	=	"MAGE", -- "Prismatic Crystal"
    [108839]	=	"MAGE", --  Ice Floes
    [7302]	    =	"MAGE", --  Frost Armor
    [31661]	    =	"MAGE", --  Dragon's Breath
    [53140]	    =	"MAGE", --  Teleport: Dalaran
    [11417]	    =	"MAGE", --  Portal: Orgrimmar
    [42955]	    =	"MAGE", --  Conjure Refreshment
    [44457]	    =	"MAGE", -- Living Bomb
    [1953]	    =	"MAGE", -- Blink
    [108843]	=	"MAGE", -- Blazing Speed
  --[131078]	=	"MAGE", -- Icy Veins
    [12043]	    =	"MAGE", -- Presence of Mind
    [108978]	=	"MAGE", -- Alter Time
    [55342]	    =	"MAGE", -- Mirror Image
    [84714]	    =	"MAGE", -- Frozen Orb
    [45438]	    =	"MAGE", -- Ice Block
    [115610]	=	"MAGE", -- Temporal Shield
    [110960]	=	"MAGE", -- Greater Invisibility
    [110959]	=	"MAGE", -- Greater Invisibility
    [11129]	    =	"MAGE", -- Combustion
    [11958]	    =	"MAGE", -- Cold Snap
    [61316]	    =	"MAGE", -- Dalaran Brilliance
    [112948]	=	"MAGE", -- Frost Bomb
    [2139]	    =	"MAGE", -- Counterspell
    [80353]	    =	"MAGE", -- Time Warp
    [2136]	    =	"MAGE", -- Fire Blast
    [7268]	    =	"MAGE", -- Arcane Missiles
    [111264]	=	"MAGE", -- Ice Ward
    [114923]	=	"MAGE", -- Nether Tempest
    [2120]	    =	"MAGE", -- Flamestrike
    [44425]	    =	"MAGE", -- Arcane Barrage
    [12042]	    =	"MAGE", -- Arcane Power
    [1459]	    =	"MAGE", -- Arcane Brilliance
    [127140]	=	"MAGE", -- Alter Time
    [116011]	=	"MAGE", -- Rune of Power
    [116014]	=	"MAGE", -- Rune of Power
    [132627]	=	"MAGE", -- Teleport: Vale of Eternal Blossoms
    [31687]	    =	"MAGE", -- Summon Water Elemental
    [3567]	    =	"MAGE", -- Teleport: Orgrimmar
    [30449]	    =	"MAGE", -- Spellsteal
    [44572] 	=	"MAGE", -- Deep Freeze
    [113724]	=	"MAGE", -- Ring of Frost
    [132626]	=	"MAGE", -- Portal: Vale of Eternal Blossoms
    [12472]	    =	"MAGE", -- Icy Veins
    [116]	    =	"MAGE", --frost bolt
    [30455]	    =	"MAGE", --ice lance
    [84721]	    =	"MAGE", --frozen orb
    [1449]	    =	"MAGE", --arcane explosion
    [113092]	=	"MAGE", --frost bomb
    [115757]	=	"MAGE", --frost nova
    [44614]	    =	"MAGE", --forstfire bolt
    [42208]	    =	"MAGE", --blizzard
    [11426]	    =	"MAGE", --Ice Barrier (heal)
    [11366]	    =	"MAGE", --pyroblast
    [133]	    =	"MAGE", --fireball
    [108853]	=	"MAGE", --infernoblast
    [2948]	    =	"MAGE", --scorch
    [30451]	    =	"MAGE", --arcane blase
    [12051]	    =	"MAGE", --evocation

    [121148]	=	"PRIEST", -- "Cascade"
    [94472]	    =	"PRIEST", -- "Atonement"
    [126154]	=	"PRIEST", -- "Lightwell Renew"
    [23455]	    =	"PRIEST", -- "Holy Nova"
    [140815]	=	"PRIEST", -- "Power Word: Solace"
    [56160]	    =	"PRIEST", -- "Glyph of Power Word: Shield"
    [152116]	=	"PRIEST", -- "Saving Grace"
    [147193]	=	"PRIEST", -- "Shadowy Apparition"
    [155361]	=	"PRIEST", -- "Void Entropy"
    [73325]	    =	"PRIEST", -- "Leap of Faith"
    [155245]	=	"PRIEST", -- "Clarity of Purpose"
    [155521]	=	"PRIEST", -- "Auspicious Spirits"
    [148859]	=	"PRIEST", -- "Shadowy Apparition"
    [120696]	=	"PRIEST", -- "Halo"
    [122128]	=	"PRIEST", -- "Divine Star"		
    [132157]	=	"PRIEST", -- "Holy Nova"
    [19236] 	= 	"PRIEST", -- Desperate Prayer
    [47788] 	= 	"PRIEST", -- Guardian Spirit
    [81206] 	= 	"PRIEST", -- Chakra: Sanctuary
    [62618] 	= 	"PRIEST", -- Power Word: Barrier
    [32375] 	= 	"PRIEST", -- Mass Dispel
    [32546] 	= 	"PRIEST", -- Binding Heal			
    [126135] 	= 	"PRIEST", -- Lightwell
    [81209] 	= 	"PRIEST", -- Chakra: Chastise
    [81208] 	= 	"PRIEST", -- Chakra: Serenity
    [2006] 	    = 	"PRIEST", -- Resurrection
    [1706] 	    = 	"PRIEST", -- Levitate			
    [73510] 	= 	"PRIEST", -- Mind Spike
    [127632] 	= 	"PRIEST", -- Cascade
    --[108921] 	= 	"PRIEST", -- Psyfiend
    [88625] 	= 	"PRIEST", -- Holy Word: Chastise
    [121135]	=	"PRIEST", -- Cascade
    [122121]	=	"PRIEST", -- Divine Star
    [110744]	=	"PRIEST", -- Divine Star
    [8122]	    =	"PRIEST", -- Psychic Scream
    [81700]	    =	"PRIEST", -- Archangel
    [123258]	=	"PRIEST", -- Power Word: Shield
    [48045]	    =	"PRIEST", -- Mind Sear
    [49821]	    =	"PRIEST", -- Mind Sear
    [123040]	=	"PRIEST", -- Mindbender
    [121536]	=	"PRIEST", -- Angelic Feather
    [121557]	=	"PRIEST", -- Angelic Feather
    [88685]	    =	"PRIEST", -- Holy Word: Sanctuary
    [88684]	    =	"PRIEST", -- Holy Word: Serenity
    [33076]	    =	"PRIEST", -- Prayer of Mending
    [32379]	    =	"PRIEST", -- Shadow Word: Death
    [129176]	=	"PRIEST", -- Shadow Word: Death
    [586]	    =	"PRIEST", -- Fade
    [120517]	=	"PRIEST", -- Halo
    --[64901]	=	"PRIEST", -- Hymn of Hope
    [64843]	    =	"PRIEST", -- Divine Hymn
    [64844]	    =	"PRIEST", -- Divine Hymn
    [34433]	    =	"PRIEST", -- Shadowfiend
    [120644]	=	"PRIEST", -- Halo
    [15487]	    =	"PRIEST", -- Silence
    --[89485]	=	"PRIEST", -- Inner Focus
    [109964]	=	"PRIEST", -- Spirit Shell
    [129197]	=	"PRIEST", -- Mind Flay (Insanity)
    [112833]	=	"PRIEST", -- Spectral Guise
    [47750]	    =	"PRIEST", -- Penance
    [33206]	    =	"PRIEST", -- Pain Suppression
    [15286]	    =	"PRIEST", -- Vampiric Embrace
    --[588]	    =	"PRIEST", -- Inner Fire
    [21562]	    =	"PRIEST", -- Power Word: Fortitude
    --[73413]	=	"PRIEST", -- Inner Will
    [10060]	    =	"PRIEST", -- Power Infusion
    --[2050]	=	"PRIEST", -- Heal
    [15473]	    =	"PRIEST", -- Shadowform
    [108920]	=	"PRIEST", -- Void Tendrils
    [47585]	    =	"PRIEST", -- Dispersion
    [123259]	=	"PRIEST", -- Prayer of Mending
    [34650]	    =	"PRIEST", --mana leech (pet)
    [589]	    =	"PRIEST", --shadow word: pain
    [34914]	    =	"PRIEST", --vampiric touch
    --[34919]	=	"PRIEST", --vampiric touch (mana)
    [15407]	    =	"PRIEST", --mind flay
    [8092]	    =	"PRIEST", --mind blast
    [15290]	    =	"PRIEST", -- Vampiric Embrace
    [127626]	=	"PRIEST", --devouring plague (heal)
    [2944]	    =	"PRIEST", --devouring plague (damage)
    [585]	    =	"PRIEST", --smite
    [47666]	    =	"PRIEST", --penance
    [14914]	    =	"PRIEST", --holy fire
    [81751]	    =	"PRIEST",  --atonement
    [47753]	    =	"PRIEST",  --divine aegis
    [33110]	    =	"PRIEST", --prayer of mending
    [77489]	    =	"PRIEST", --mastery echo of light
    [596]	    =	"PRIEST", --prayer of healing
    [34861]	    =	"PRIEST", --circle of healing
    [139]	    =	"PRIEST", --renew
    [120692]	=	"PRIEST", --halo
    [2060]	    =	"PRIEST", --greater heal
    [110745]	=	"PRIEST", --divine star
    [2061]	    =	"PRIEST", --flash heal
    [88686]	    =	"PRIEST", --santuary
    [17]		=	"PRIEST", --power word: shield
    --[64904]	=	"PRIEST", --hymn of hope
    [129250]	=	"PRIEST", --power word: solace

    [104318]	=	"WARLOCK", -- fel firebolt
    [270481]	=	"WARLOCK", -- demonfire
    [271971]	=	"WARLOCK", -- dreadbite
    [264178]	=	"WARLOCK", -- demonbolt
    [233490]	=	"WARLOCK", -- unstable affliction
    [232670]	=	"WARLOCK", -- shadow bolt    
    [108447]	=	"WARLOCK", -- "Soul Link"
    [108508]	=	"WARLOCK", -- "Mannoroth's Fury"
    [108482]	=	"WARLOCK", -- "Unbound Will"
    [157897]	=	"WARLOCK", -- "Summon Terrorguard"
    [111771]	=	"WARLOCK", -- "Demonic Gateway"
    [157899]	=	"WARLOCK", -- "Summon Abyssal"
    [157757]	=	"WARLOCK", -- "Summon Doomguard"
    [119915]	=	"WARLOCK", -- "Wrathstorm"
    [137587]	=	"WARLOCK", -- "Kil'jaeden's Cunning"
    [1949]	    =	"WARLOCK", -- "Hellfire"
    [171140]	=	"WARLOCK", -- "Shadow Lock"
    [104025]	=	"WARLOCK", -- "Immolation Aura"
    [119905]	=	"WARLOCK", -- "Cauterize Master"
    [119913]	=	"WARLOCK", -- "Fellash"
    [111898]	=	"WARLOCK", -- "Grimoire: Felguard"
    [30146]	    =	"WARLOCK", -- "Summon Felguard"
    [119914]	=	"WARLOCK", -- "Felstorm"
    [86121]	    =	"WARLOCK", -- "Soul Swap"
    [86213]	    =	"WARLOCK", -- "Soul Swap Exhale"
    [157695]	=	"WARLOCK", -- "Demonbolt"	
    [86040]	    =	"WARLOCK", -- "Hand of Gul'dan"
    [124915]	=	"WARLOCK", -- "Chaos Wave"
    [22703]	    =	"WARLOCK", -- "Infernal Awakening"
    [5857]	    =	"WARLOCK", -- "Hellfire"
    [129476]	=	"WARLOCK", -- "Immolation Aura"
    [152108]	=	"WARLOCK", -- "Cataclysm"
    [27285]	    =	"WARLOCK", -- "Seed of Corruption"
    [131740]	=	"WARLOCK", -- "Corruption"
    [131737]	=	"WARLOCK", -- "Agony"		
    [131736]	=	"WARLOCK", -- "Unstable Affliction"
    [80240] 	= 	"WARLOCK", -- Havoc
    [112921] 	= 	"WARLOCK", -- Summon Abyssal
    [48020] 	= 	"WARLOCK", -- Demonic Circle: Teleport
    [111397] 	= 	"WARLOCK", -- Blood Horror
    [112869] 	= 	"WARLOCK", -- Summon Observer
    [1454] 	    = 	"WARLOCK", -- Life Tap
    [112868] 	= 	"WARLOCK", -- Summon Shivarra
    [112869] 	= 	"WARLOCK", -- Summon Observer
    [120451] 	= 	"WARLOCK", -- Flames of Xoroth
    [29893] 	= 	"WARLOCK", -- Create Soulwell
    [114189] 	= 	"WARLOCK", -- Health Funnel
    [112866] 	= 	"WARLOCK", -- Summon Fel Imp
    [108683] 	= 	"WARLOCK", -- Fire and Brimstone
    [688] 	    = 	"WARLOCK", -- Summon Imp
    --[112092] 	= 	"WARLOCK", -- Shadow Bolt
    [113861] 	= 	"WARLOCK", -- Dark Soul: Knowledge
    --[103967] 	= 	"WARLOCK", -- Carrion Swarm
    [112870] 	= 	"WARLOCK", -- Summon Wrathguard
    [104316] 	= 	"WARLOCK", -- Imp Swarm
    [17962]	    =	"WARLOCK", -- Conflagrate
    [108359]	=	"WARLOCK", -- Dark Regeneration
    [110913]	=	"WARLOCK", -- Dark Bargain
    [105174]	=	"WARLOCK", -- Hand of Gul'dan
    [697]	    =	"WARLOCK", -- Summon Voidwalker
    [6201]	    =	"WARLOCK", -- Create Healthstone
    [146739]	=	"WARLOCK", -- Corruption
    [109151]	=	"WARLOCK", -- Demonic Leap
    [104773]	=	"WARLOCK", -- Unending Resolve
    [103958]	=	"WARLOCK", -- Metamorphosis
    [119678]	=	"WARLOCK", -- Soul Swap
    --[6229]	=	"WARLOCK", -- Twilight Ward
    [74434]	    =	"WARLOCK", -- Soulburn
    [30283]	    =	"WARLOCK", -- Shadowfury
    [113860]	=	"WARLOCK", -- Dark Soul: Misery
    [108503]	=	"WARLOCK", -- Grimoire of Sacrifice
    [104232]	=	"WARLOCK", -- Rain of Fire
    [6353]	    =	"WARLOCK", -- Soul Fire
    [689]	    =	"WARLOCK", -- Drain Life
    [17877]	    =	"WARLOCK", -- Shadowburn
    [113858]	=	"WARLOCK", -- Dark Soul: Instability
    --[1490]	=	"WARLOCK", -- Curse of the Elements
    [114635]	=	"WARLOCK", -- Ember Tap
    [27243]	    =	"WARLOCK", -- Seed of Corruption
    --[131623]	=	"WARLOCK", -- Twilight Ward
    [6789]	    =	"WARLOCK", -- Mortal Coil
    [111400]	=	"WARLOCK", -- Burning Rush
    [124916]	=	"WARLOCK", -- Chaos Wave
    --[1120]	=	"WARLOCK", -- Drain Soul
    [109773]	=	"WARLOCK", -- Dark Intent
    [112927]	=	"WARLOCK", -- Summon Terrorguard
    [1122]	    =	"WARLOCK", -- Summon Infernal
    [108416]	=	"WARLOCK", -- Sacrificial Pact
    [5484]	    =	"WARLOCK", -- Howl of Terror
    [29858]	    =	"WARLOCK", -- Soulshatter
    [18540]	    =	"WARLOCK", -- Summon Doomguard
    --[89420]	=	"WARLOCK", -- Drain Life
    [20707]	    =	"WARLOCK", -- Soulstone
    [132413]	=	"WARLOCK", -- Shadow Bulwark
    --[109466]	=	"WARLOCK", -- Curse of Enfeeblement
    [48018]	    =	"WARLOCK", -- Demonic Circle: Summon
    --[77799]	=	"WARLOCK", --fel flame
    [63106]	    =	"WARLOCK", --siphon life
    [1454]	    =	"WARLOCK", --life tap
    [103103]	=	"WARLOCK", --malefic grasp
    [980]	    =	"WARLOCK", --agony
    [30108]	    =	"WARLOCK", --unstable affliction
    [172]	    =	"WARLOCK", --corruption	
    [48181]	    =	"WARLOCK", --haunt	
    [29722]	    =	"WARLOCK", --incenerate
    [348]	    =	"WARLOCK", --Immolate
    [116858]	=	"WARLOCK", --Chaos Bolt
    [114654]	=	"WARLOCK", --incinerate
    [108686]	=	"WARLOCK", --immolate
    [108685]	=	"WARLOCK", --conflagrate
    [104233]	=	"WARLOCK", --rain of fire
    [103964]	=	"WARLOCK", --touch os chaos
    [686]	    =	"WARLOCK", --shadow bolt
    --[114328]	=	"WARLOCK", --shadow bolt glyph
    [140719]	=	"WARLOCK", --hellfire
    [104027]	=	"WARLOCK", --soul fire
    [603]	    =	"WARLOCK", --doom
    [108371]	=	"WARLOCK", --Harvest life
}

 ]]