--loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/ploxfruit.lua"))() 
script_key = "O8ywQn0ruAE6XGc7QHxB2xoVTpbce1wCH0ic" -- Put ur key between ""
getgenv().Shutdown = false -- Turn on if u are farming bulk accounts
getgenv().Configs = {
    ["Team"] = "Marines",
    ["FPS Boost"] = {
        ["Enable"] = true,
        ["FPS Cap"] = 70, --recommend 15
    },
    ["Farm Boss Drops"] = {
        ["Enable"] = false,
        ["When x2 Exp Expired"] = false
    },
    ["Hop"] = {
        ["Enable"] = false,
        ["Hop Find Tushita"] = false,
        ["Hop Find Valkyrie Helm"] = false,
        ["Hop Find Mirror Fractal"] = false,
        ["Hop Find Darkbeard"] = false, -- For skull guitar
        ["Hop Find Soul Reaper"] = false, -- For CDK
        ["Hop Find Mirage"] = false, -- For pull lever
        ["Find Fruit"] = false, -- Will find 1m+ fruit to unlock swan door to access third sea
        ["Hop Elite"] = false, -- For god chalice farming
    },
    ["Farm Mastery"] = {
        ["Enable"] = false,
        ["Farm Mastery Weapons"] = {"Sword", "Gun", "Blox Fruit"}, -- Blox Fruit, Gun (left -> right: High -> Low Priority)
        ["Swords To Farm"] = {"Cursed Dual Katana"},
        ["Guns To Farm"] = {"Skull Guitar"},
        ["Mastery Health (%)"] = 40 -- For Blox Fruit, Gun
    },
    ["Farm Config"] = {
        ["First Farm At Sky"] = true,
        ["Farm Bone Get x2 Exp"] = {
            ["Enable"] = true,
            ["Level"] = 2000 -- level to start farming
        }
    },
    ["Trackstat"] = {
        ["Enable"] = false,
        ["Key"] = "2", -- Get from xerohub.click
        ["Device"] = "msi" -- u can put any name here
    },
    ["Fruit to use for auto third sea"] = {}, -- example: {"Shadow-Shadow", "Buddha-Buddha"}
    ["Get Fruits"] = true,
    ["Auto Spawn rip_indra"] = false,
    ["Auto Spawn Dough King"] = false,
    ["Auto Pull Lever"] = false,
    ["Auto Collect Berry"] = false,
    ["Auto Evo Race"] = false,
    ["Awaken Fruit"] = false,
    ["Rainbow Haki"] = false,
    ["Hop Player Near"] = false,
    ["Skull Guitar"] = false,
    ["Cursed Dual Katana"] = false,
    ["Switch Melee"] = true,
    ["Eat Fruit"] = "", -- leave blank for none, put the fruit name like this example: Smoke Fruit, T-Rex Fruit, ...
    ["Snipe Fruit"] = "Dough Fruit", -- leave blank for none, put the fruit name like this example: Smoke Fruit, T-Rex Fruit, ...
    ["Lock Fragment"] = 0,
    ["Buy Stuffs"] = true -- buso, geppo, soru, ken haki, ...
}
repeat task.wait(10) pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Xero2409/XeroHub/refs/heads/main/kaitun.lua"))() end) until getgenv().Check_Execute
