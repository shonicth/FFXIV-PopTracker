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

--levels
function Leveling()
  return(
    math.max(5pldlevels, 5warlevels, 5drklevels, 5gnblevels, 5whmlevels, 5schlevels, 5astlevels, 5sgelevels, 5mnklevels, 5drglevels, 5ninlevels, 5samlevels, 5rprlevels, 5vprlevels, 5brdlevels, 5mchlevels, 5dnclevels, 5blmlevels, 5smnlevels, 5rdmlevels, 5pctlevels, 5blulevels)
  )
end
