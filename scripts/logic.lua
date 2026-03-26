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
--La Noscea
function lowerlanosceaaccess()
    return(
    --Directly connected to Limsa
    (has("lowerlanosceaaccess"))
    
  )
end
function easternlanosceaaccess()
    return(
     --Directly connected to Limsa
    (has("easternlanosceaaccess"))
  )
end
function westernlanosceaaccess()
    return(
     --Directly connected to Limsa
    (has("westernlanosceaaccess"))
  )
end
function upperlanosceaaccess()
    return(
     --Connected to Western, Eastern, and Outer(stub?)
    (has("upperlanosceaaccess") and (easternlanosceaaccess() or westernlanosceaaccess()))
  )
end
function outerlanosceaaccess()
    return(
    --Connected to Upper
    (has("outerlanosceaaccess") and upperlanoaccess())
  )
end
function mistaccess()
    return(
    (lowerlanosceaaccess())
  )
end

--The Black Shroud
function eastshroudaccess()
    return(
    --Directly connected to Gridania
    (has("eastshroudaccess"))
  )
end
function southshroudaccess()
    return(
    --Directly connected to Central
    (has("southshroudaccess"))
  )
end
function northshroudaccess()
    return(
    --Directly connected to Gridania
    (has("northshroudaccess"))
  )
end
--Thanalan
function westernthanalanaccess()
    return(
    --Directly connected to Uldah
    (has("westernthanalanaccess"))
  )
end
function easternthanalanaccess()
    return(
    --Directly connected to Central
    (has("easternthanalanaccess"))
  )
end
function southernthanalanaccess()
    return(
    --Directly connected to Central
    (has("southernthanalanaccess"))
  )
end
function northanthanalanaccess()
    return(
    --Directly connected to Central
    (has("northanthanalanaccess"))
  )
end
function thegobletaccess()
    return(
    --Connected to Western
    (westernthanalanaccess())
  )
end
--ARR Misc
function coerthascentralhighlandsaccess()
    return(
    --Connected to North Shroud, Mor Dhona, and Ishgard
    (has("coerthascentralhighlandsaccess") and (northshroudaccess() or mordhonaaccess()))
  )
end
function mordhonaaccess()
    return(
    --Directly connected to Central
    (has("mordhonaaccess") and (northanthanalanaccess() or coerthascentralhighlandsaccess()))
  )
end
--HW
function ishgardaccess()
    return(
    --Directly connected to Airship
    (has("ishgardaccess"))
  )
end
function coerthaswesternhighlandsaccess()
  return(
    --Connected to Ishgard
    (has("coerthaswesternhighlandsaccess" and (ishgardaccess())))
  )
function theseaofcloudsaccess()
  return(
    --Connected to Ishgard
    (has("theseaofcloudsaccess" and (ishgardaccess())))
  )
  function thedravanianforelandsaccess()
  return(
    --Connected to CWH and Dravanian Hinterlands
    (has("thedravanianforelandsaccess" and (coerthaswesternhighlandsaccess() or thedravanianhinterlandsandidyllshireaccess())))
  )
  function thechurningmistsaccess()
  return(
    --Connected to Dravanian Forelands
    (has("thechurningmistsaccess" and (thedravanianforelandsaccess())))
  )
  function thedravanianhinterlandsandidyllshireaccess()
  return(
    --Connected to CWH and Dravanian Forelands
    (has("coerthaswesternhighlandsaccess" and (coerthaswesternhighlandsaccess() or thedravanianforelandsaccess())))
  )
  function azysllaaccess()
  return(
    --Connected to Ishgard
    (has("coerthaswesternhighlandsaccess" and (ishgardaccess())))
  )

--StB

--ShB

--EnW

--DT

--levels
function leveling()
  return(
    math.max(Tracker:ProviderCountForCode("5pldlevels"), Tracker:ProviderCountForCode("5warlevels"), Tracker:ProviderCountForCode("5drklevels"), Tracker:ProviderCountForCode("5gnblevels"), Tracker:ProviderCountForCode("5whmlevels"), Tracker:ProviderCountForCode("5schlevels"), Tracker:ProviderCountForCode("5astlevels"), Tracker:ProviderCountForCode("5sgelevels"), Tracker:ProviderCountForCode("5mnklevels"), Tracker:ProviderCountForCode("5drglevels"), Tracker:ProviderCountForCode("5ninlevels"), Tracker:ProviderCountForCode("5samlevels"), Tracker:ProviderCountForCode("5rprlevels"), Tracker:ProviderCountForCode("5vprlevels"), Tracker:ProviderCountForCode("5brdlevels"), Tracker:ProviderCountForCode("5mchlevels"), Tracker:ProviderCountForCode("5dnclevels"), Tracker:ProviderCountForCode("5blmlevels"), Tracker:ProviderCountForCode("5smnlevels"), Tracker:ProviderCountForCode("5rdmlevels"), Tracker:ProviderCountForCode("5pctlevels"), Tracker:ProviderCountForCode("5blulevels"))
  )
end
