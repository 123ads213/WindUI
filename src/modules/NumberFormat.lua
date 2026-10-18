-- Compact display only. Stored values and callbacks stay numeric.
local NumberFormat = {}
local Suffixes = { "k", "m", "b", "t", "qa", "qi", "sx", "sp", "oc", "no", "dc" }

function NumberFormat.Finite(value)
    local n = tonumber(value)
    if n == nil or n ~= n or math.abs(n) == math.huge then return nil end
    return n
end

function NumberFormat.Plain(value)
    return string.format("%.15g", value)
end

function NumberFormat.Format(value, options)
    options = options or {}
    local n = NumberFormat.Finite(value)
    if not n then return "—" end
    if options.Compact == false then return NumberFormat.Plain(n) end
    local decimals = math.clamp(math.floor(tonumber(options.Decimals) or 2), 0, 6)
    local magnitude = math.abs(n)
    if magnitude < 1000 then return NumberFormat.Plain(n) end
    if magnitude >= 1e36 then return string.format("%." .. decimals .. "e", n) end
    local tier = 0
    local scaled = n
    while math.abs(scaled) >= 1000 and tier < #Suffixes do
        tier += 1
        scaled /= 1000
    end
    local factor = 10 ^ decimals
    if math.floor(math.abs(scaled) * factor + 0.5) / factor >= 1000 then
        if tier == #Suffixes then return string.format("%." .. decimals .. "e", n) end
        tier += 1
        scaled /= 1000
    end
    scaled = (scaled < 0 and -1 or 1) * math.floor(math.abs(scaled) * factor + 0.5) / factor
    local text = string.format("%." .. decimals .. "f", scaled)
    if decimals > 0 then text = text:gsub("0+$", ""):gsub("%.$", "") end
    return text .. Suffixes[tier]
end

function NumberFormat.Parse(value)
    if type(value) == "number" then return NumberFormat.Finite(value) end
    if type(value) ~= "string" then return nil end
    local text = value:lower():match("^%s*(.-)%s*$")
    local plain = NumberFormat.Finite(text)
    if plain then return plain end
    local number, suffix = text:match("^(.-)%s*([a-z]+)$")
    local n = number and NumberFormat.Finite(number)
    if not n then return nil end
    for tier, unit in ipairs(Suffixes) do
        if unit == suffix then return NumberFormat.Finite(n * 1000 ^ tier) end
    end
    return nil
end

-- A lattice anchored at Min; clamp again because the nearest step can exceed Max.
function NumberFormat.Snap(value, minimum, maximum, step)
    local n = NumberFormat.Finite(value)
    if not n then return nil end
    n = math.clamp(n, minimum, maximum)
    if n == minimum or n == maximum then return n end
    return math.clamp(minimum + math.floor((n - minimum) / step + 0.5) * step, minimum, maximum)
end

function NumberFormat.Ratio(value, minimum, maximum)
    if maximum == minimum then return 1 end
    return math.clamp((value - minimum) / (maximum - minimum), 0, 1)
end

return NumberFormat
