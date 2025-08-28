
License = "S0Jv82irIGcm6sIZzAeCcW0xu9yWy8tY"

getgenv().ConfigsKaitun = {
	Beta_Fix_Data_Sync = true,

	NoDeletePlayer = true,

	["Block Pet Gift"] = true,

	Collect_Cooldown = 120, -- cooldown to collect fruit

	["Low Cpu"] = false,
	["Auto Rejoin"] = true,

	["Rejoin When Update"] = false,
	["Limit Tree"] = {
		["Limit"] = 800,
		["Destroy Until"] = 400,

		["Safe Tree"] = {
            "Beanstalk",
			-- for the event
            ["Blueberry"] = 15,
            ["Strawberry"] = 15,
            ["Apple"] = 15,
            ["Coconut"] = 15,
            ["Dragon Fruit"] = 15,
            ["Mango"] = 15,
            ["Tomato"] = 20,
            ["Cactus"] = 15,
		}
	},

	Seed = {
		Buy = {
			Mode = "Custom", -- Custom , Auto
			Custom = { -- any fruit u need to place
				"Beanstalk",
			}
		},
		Place = {
			Mode = "Select", -- Select , Lock
			Select = {
				"Beanstalk"
			},
			Lock = {
				"Beanstalk",
			}
		}
	},

	["Seed Pack"] = {
		Locked = {

		}
	},

	Events = {
		["Bean Event"] = {
			Minimum_Money = 10_000_000, -- minimum money to start play this event
		},
		MaxMoney_Restocks = 10_000_000,
		Shop = { -- un comment to buy
			"Sprout Seed Pack",
			"Sprout Egg",
			-- "Mandrake",
			"Silver Fertilizer",
			-- "Canary Melon",
			-- "Amberheart",
			["Spriggan"] = 8,
			-- Friend Shop
			"Skyroot Chest",
			"Pet Shard GiantBean",
		},
		["Traveling Shop"] = {
			"Bee Egg",
			"Common Summer Egg",
			"Rare Summer Egg",
			"Paradise Egg",
		},
		Craft = {
			"Anti Bee Egg",
			"Pet Shard GiantBean",
			"Sprout Egg",
		},
		Start_Do_Honey = 2_000_000 -- start trade fruit for honey at money
	},

	Gear = {
		Buy = { 
			"Master Sprinkler",
			"Godly Sprinkler",
			"Advanced Sprinkler",
			"Basic Sprinkler",
			"Lightning Rod",
			"Level Up Lollipop",
			"Medium Treat",
			"Medium Toy",
			"Cleaning Pet Shard",
		},
		Lock = {
			"Master Sprinkler",
			"Godly Sprinkler",
			"Advanced Sprinkler",
			"Basic Sprinkler",
			"Lightning Rod",
			"Level Up Lollipop",
			"Pet Shard GiantBean",
		},
	},

	Eggs = {
		Place = {
			"Sprout Egg",
			"Gourmet Egg",
			"Zen Egg",
			"Primal Egg",
			"Dinosaur Egg",
			"Oasis Egg",
			"Anti Bee Egg",
			"Night Egg",
			"Bug Egg",
			"Paradise Egg",
			"Bee Egg",
			"Mythical Egg",
		},
		Buy = {
			"Bee Egg",
			"Oasis Egg",
			"Paradise Egg",
			"Anti Bee Egg",
			"Night Egg",
			"Rare Summer Egg",
			"Bug Egg",
			"Mythical Egg",
			"Uncommon Egg",
			"Common Egg",
		}
	},

	Pets = {
		["Auto Feed"] = true,

		["Start Delete Pet At"] = 50,
		["Upgrade Slot"] = {
			["Pet"] = {
				["Dog"] = { 5, 100, 4, true }, -- the "true" on the last is auto equip (use for like only need to use for upgrade pet)
				["Golden Lab"] = { 5, 100, 3, true },
				["Bunny"] = { 5, 100, 2, true },
				["Dairy Cow"] = { 5, 100, 1, true },
			},
			["Limit Upgrade"] = 5, -- max is 5 (more than or lower than 1 will do nothing)
			["Equip When Done"] = {
				["Capybara"] = { 1, 101, 1 }, -- 5 on the first mean equip only 5 | pet , 100 mean equip only level pet lower than 100 | the one on the last is priority it will ues first if possible 
				--["Starfish"] = { 7, 75, 2 },
				--["Ostrich"] = { 7, 101, 3 },
			},
		},
		Unfavorite_AllPet = false,
		Favorite_LockedPet = false,
		Locked_Pet_Age = 75, -- pet that age > 60 will lock
		Locked = {
			"Griffin",
			"Golden Goose",
			"French Fry Ferret",
			"Spaghetti Sloth",
			"Corrupted Kitsune",
			"Starfish",
			"Kitsune",
			"Tanchozuru",
			"Dilophosaurus",
			"Moon Cat",
			"Capybara",
			"T-Rex",
			"Disco Bee",
			"Butterfly",
			"Queen Bee",
			"Dragonfly",
			"Raccoon",
			"Fennec Fox",
			"Mimic Octopus",
			"Red Fox",
			"Blood Owl",
			"Ostrich",
			["Dairy Cow"] = 3,
		},
		LockPet_Weight = 7, -- if Weight >= 10 they will locked
		Ignore_Pet_Weight = {
			"NAME oF PET THAT U DONT NEED LOCK",
		},
		Instant_Sell = {
			"NAME oF SOMETHING",
		}
	},

	Webhook = {
		UrlPet = "https://canary.discord.com/api/webhooks/1409434912188137482/TWezT7FAmHIrS4Fd86rHA_vJ_tAJAU_6SoquUysIDSfO89VKU-QR2sjiWKSRn_Rl84wL",
		UrlSeed = "xxx",
		PcName = "Ug",

		Mention = "", -- discord id

		Noti = {
			Seeds = {
			},
			SeedPack = {
				"Idk"
			},
			Pets = {
				"Golden Goose",
				"French Fry Ferret",
				"Corrupted Kitsune",
				"Kitsune",
				"Spinosaurus",
				"T-Rex",
				"Disco Bee",
				"Butterfly",
				"Mimic Octopus",
				"Queen Bee",
				"Fennec Fox",
				"Dragonfly",
				"Raccoon",
				"Red Fox",
				"Griffin",
				"French Fry Ferret",
			},
			Pet_Weight_Noti = true,
		}
	},
}




loadstring(game:HttpGet('https://raw.githubusercontent.com/Real-Aya/Loader/main/Init.lua'))()
