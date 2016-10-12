local builder = {}

function builder:split(text, sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        text:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

function builder:loadMap(s)
    local muros = self:split(s, "\n")
    local res = {}
    for i,v in ipairs(muros) do
        local m = {}
        v:gsub(".", function(c) table.insert( m, c ) end)
        table.insert( res, m )
    end

    return res
end

function builder:round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

return builder
