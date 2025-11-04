-- loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/zgift60feed88.lua"))()

getgenv().Keyyy = "HoangPhuc3636"

getgenv().auto_gift = true --false nếu như chỉ muốn auto accept gift

-- Blacklist pet
getgenv().unvalidToolNames = {"Capybara", "Ostrich", "Griffin", "Golden Goose", "Dragonfly", "Mimic Octopus", "Red Fox", "French Fry Ferret", "Cockatrice", "Swan"}

-- Config lấy gift pet
getgenv().DataGetTool = {
    {
        name_pet    = nil,  -- nil = gift toàn bộ pet đủ điều kiện trừ pet trong blacklist (unvalidToolNames), chủ yếu gom pet age
        min_age     = 60,
        max_age     = 75,
        min_weight  = 2.5,           
        unequip_Pet = false, -- auto pickup pet đủ điều kiện để gift
        limit_pet   = 9,
        kick_after_done = false,     
        wait_before_kick = 30,
        playerlist  = {"Edmund_Beau2003","EdithH3idi57","ElisaAnn26","Jing_Gilbert2002","Ka3d3_ELLA74","XuanElijah82","DavidDawnGrant94","Satsuki_Erin2018","AlmaArthur2019","YiDawnAva","BrentFreya30","BlairIngridDee","HarukaEddie38","N0b0ru_Audrey","AiBianca65","AbbyFallon2010","ImogenClaudia60","HazelIris2015","RinaGregAiden93","MasashiElena2006","HiroshiGertrudeElean","Daphn3Graham44","Eric_D3anna2010","FredHeidi200211","AsahiBrent2020","BaoDanaGrant","ShigeruCharles70","QiangHeatherEbba","AN_Andrea48","CAMERON_Douglas2005","HitoshiEbony2021","EdwardChad75","BarbaraHeather66","AsahiChloe82","CarrieBrianArthur201","HongBlakeHugo2009","ErnestEbba56","FanAlmaEl3na","DannyEli2002","BradGrahamDallas","YangB0nni32010","Brent_Ava2014","Ayaka_Eb0ny57","Dam0n_Eb0ny","AnnaDeanna2011","DanGareth2010","RyoDariaErica","ErinEric2021","HarukiAmberHeather34","WEN_Diana2013","DanDean72","EdwinAriBail3y","GilbertFrankAnita","Zhong_Dan2004","CherylBrentFrank","MasahiroAnthony12","DeanEbony2014","KazukiDeclan202142","YiDeirdreCaleb2018","D3anColinDawn","ShizukaErnestIgor","SatsukiBarry2021","IngridDeclan2002","EddieDariusGene","LI_Har0ld2004","Cara_Ida2007","FionaAxel2020","HunterImogen33","Gar3thEdgar37","MasatoImogenCassandr","BlakeDaphne56","DanGeneAnthony","ZhiAngelica2006","B0BeauEast0n","AsukaD0minicFi0na97","Elois3Anita","HitoshiEarl2024","ShigeruChadElena","Fall0nIrene2014","B0BarbaraGwen","ElijahBecky52","BR3TT_Elias2009","D0risHarryFaith2012","GabrielDanny2004","XiDavid2015","CassandraChaseBob","Adam_Ann2008","XiFaith2017","EikoEllen2010","XiaDannyFrances","ZhiEliErnest2008","XiBrettCara","AnnArthur53","Bo_Am3lia2004","H0ward_Beth","FanCherylIan2004","HotaruFrankDaniel","GuoBrenda201437","Wei_Helen2004","HiroshiBarry201163","LuAnnHannah","BonnieBeth44","BlairGloriaBenjamin2","Ern3stHug0","IrisCaraIda","FumikoChris200616","Sheng_Grace29","EsmeGwen35","XiaBailey2004","ShengFredHolly","XxTiger_BANEXX2015","N0ah_Shad0w2021","Flam3Hunt3r74","L0ganBeastHunter","N0ahSkyFlick2010","FireStealth76","S0NIC_Raven2021","LionFoxBeast","XxBlizzardUltraMiner","XxWilliamFusionCyber","Silv3rB3ar18","MysticClawSlime20176"}
    }
}

-- Auto accept gift, xóa nếu muốn
task.spawn(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20accept%20gift.lua"))()
end)

-- Auto gift
loadstring(game:HttpGet("https://raw.githubusercontent.com/Txlerz3636/Gag-Trading/main/Auto%20gift.lua"))()
