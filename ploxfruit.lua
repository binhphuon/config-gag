--loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/ploxfruit.lua"))() 
script_key="ywSfRYwsGlHiFVRBTvoVXgZFZcXTioJC";
getgenv().NAH = {
    DeleteMap = true,
    BlackScreen = false,
    LockFragment = 1500,
    AwakenFruit = false,
    UpRace = false,
    LockFps = true,
    FPSCAP = 60,
    FarmItems = {
        Pole = false,
        Saber = true,
        GetMirrorFactorWhenHaveCup = false,
    },
    TableFruit = {
        ListFruit = {"Kitsune-Kitsune"},
        SnipeFruit = true,
        EatFruit = false
    },
}
task.spawn(function()
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/binhphuon/config-gag/refs/heads/main/hope%20bf.lua"))()
    end)
    if not ok then
        warn("[Load] Loi khi chay hope bf.lua: " .. tostring(err))
    end
end)
loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/094bcde19464e77064beb3eb705d047d.lua"))()


