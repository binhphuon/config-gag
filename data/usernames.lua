local up88 = {"a", "b"}
local gom60 = {"c", "d"}
local gom75 = {"e", "f"}
local other = {"g", "h"}





local function mergeTables(...)
    local result = {}
    for _, t in ipairs({...}) do
        for _, v in ipairs(t) do
            table.insert(result, v)
        end
    end
    return result
end

return {
    up88 = up88,
    gom60 = gom60,
    gom75 = gom75,
    other = other,
    rai_tien = mergeTables(gom60, gom75, other)
}
