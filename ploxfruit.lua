--loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/ploxfruit.lua"))() 

Config = {
    Team = "Pirates",
    Configuration = {
        HopWhenIdle = true,
        AutoHop = true,
        AutoHopDelay = 60 * 60,
        FpsBoost = true,
        blackscreen = false
    },
    Items = {

        -- Melees 
        AutoFullyMelees = true,

        -- Swords 
        Saber = true,
        CursedDualKatana = false,

        -- Guns 
        SoulGuitar = false,

        -- Upgrades 

        RaceV2 = true

    },
    Settings = {
        StayInSea2UntilHaveDarkFragments = false
    }
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/sucvatthieunang/djtme/refs/heads/main/module"))()
