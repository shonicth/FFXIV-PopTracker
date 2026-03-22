function has(item, amount)
  local count = Tracker:ProviderCountForCode(item)
  amount = tonumber(amount)
  if not amount then
    return count > 0
  else
    return count >= amount
  end
end

function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end
--regions
function middlelanosceaaccess()
  return(
    has("limsalominsaandmiddlelanosceaaccess")
  )
end
function lowerlanosceaaccess()
    return(
    (has("lowerlanosceaaccess") and middlelanoaccess())
  )
end
function easternlanosceaaccess()
    return(
    (has("easternlanosceaaccess") and middlelanoaccess())
  )
end
function westernlanoaccess()
    return(
    (has("westernlanosceaaccess") and middlelanoaccess())
  )
end
function upperlanosceaaccess()
    return(
    (has("upperlanosceaaccess") and easternlanoaccess()) or (has("upperlanosceaaccess") and westernlanoaccess())
  )
end
function outerlanosceaaccess()
    return(
    (has("outerlanosceaaccess") and upperlanoaccess())
  )
end
--levels
function leveling()
  return(
    math.max(Tracker:ProviderCountForCode("5pldlevels"), Tracker:ProviderCountForCode("5warlevels"), Tracker:ProviderCountForCode("5drklevels"), Tracker:ProviderCountForCode("5gnblevels"), Tracker:ProviderCountForCode("5whmlevels"), Tracker:ProviderCountForCode("5schlevels"), Tracker:ProviderCountForCode("5astlevels"), Tracker:ProviderCountForCode("5sgelevels"), Tracker:ProviderCountForCode("5mnklevels"), Tracker:ProviderCountForCode("5drglevels"), Tracker:ProviderCountForCode("5ninlevels"), Tracker:ProviderCountForCode("5samlevels"), Tracker:ProviderCountForCode("5rprlevels"), Tracker:ProviderCountForCode("5vprlevels"), Tracker:ProviderCountForCode("5brdlevels"), Tracker:ProviderCountForCode("5mchlevels"), Tracker:ProviderCountForCode("5dnclevels"), Tracker:ProviderCountForCode("5blmlevels"), Tracker:ProviderCountForCode("5smnlevels"), Tracker:ProviderCountForCode("5rdmlevels"), Tracker:ProviderCountForCode("5pctlevels"), Tracker:ProviderCountForCode("5blulevels"))
  )
end
