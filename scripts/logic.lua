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
    (has("outerlanosceaaccess") and upperlanosceaaccess())
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
function northernthanalanaccess()
    return(
    --Directly connected to Central
    (has("northernthanalanaccess"))
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
    (has("coerthascentralhighlandsaccess") and (northshroudaccess() or (has"mordhonaaccess" and has"northanthanalanaccess") or ishgardaccess()))
  )
end
function mordhonaaccess()
    return(
    --Directly connected to Central
    (has("mordhonaaccess") and (northernthanalanaccess() or coerthascentralhighlandsaccess()))
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
    (has("coerthaswesternhighlandsaccess") and (ishgardaccess()))
  )
end
function theseaofcloudsaccess()
  return(
    --Connected to Ishgard
    (has("theseaofcloudsaccess") and (ishgardaccess()))
  )
end
  function thedravanianforelandsaccess()
  return(
    --Connected to CWH and Dravanian Hinterlands
    (has("thedravanianforelandsaccess") and (coerthaswesternhighlandsaccess()))
  )
end
  function thechurningmistsaccess()
  return(
    --Connected to Dravanian Forelands
    (has("thechurningmistsaccess") and (thedravanianforelandsaccess()))
  )
end
  function thedravanianhinterlandsandidyllshireaccess()
  return(
    --Connected to CWH and Dravanian Forelands
    (has("thedravanianhinterlandsandidyllshireaccess") and (coerthaswesternhighlandsaccess()))
  )
end
  function azysllaaccess()
  return(
    --Connected to Ishgard
    (has("azysllaaccess") and (ishgardaccess()))
  )
end

--StB
  function thefringesaccess()
    return(
      --Connected to East Shroud
      (has("thefringesaccess") and (eastshroudaccess()))
    )
  end
  function rhalgrsreachaccess()
    return(
      --Connected to Fringes
      (has("rhalgrsreachaccess") and (thefringesaccess()))
    )
    end
  function thepeaksaccess()
    return(
      --Connected to Fringes
      (has("thepeaksaccess") and (thefringesaccess()))
    )
    end
  function thelochsaccess()
    return(
      --Connected to Fringes
      (has("thelochsaccess") and (thepeaksaccess()))
    )
    end
  function kuganeaccess()
    return(
      --Connected to Fringes
      (has("kuganeaccess"))
    )
    end
  function therubyseaaccess()
    return(
      --Connected to Fringes
      (has("therubyseaaccess") and (kuganeaccess()))
    )
    end
  function theazimsteppeaccess()
    return(
      --Connected to Fringes
      (has("theazimsteppeaccess") and (therubyseaaccess()))
    )
    end
  function yanxiaaccess()
    return(
      --Connected to Fringes
      (has("yanxiaaccess") and (therubyseaaccess()))
    )
    end
--ShB
function thecrystariumaccess()
  return(
    (has("thecrystariumaccess") and (mordhonaaccess()))
  )
end
function eulmoreaccess()
  return(
    (has("eulmoreaccess") and (thecrystariumaccess()))
  )
end
function lakelandaccess()
  return(
    (has("lakelandaccess") and (thecrystariumaccess()))
  )
end
function kholusiaaccess()
  return(

    (has("kholusiaaccess") and (thecrystariumaccess()))
  )
end
function amharaengaccess()
  return(
    (has("amharaengaccess") and (thecrystariumaccess()))
  )
end
function ilmhegaccess()
  return(
    (has("ilmhegaccess") and (lakelandaccess()))
  )
end
function theraktikagreatwoodaccess()
  return(
    (has("theraktikagreatwoodaccess") and (lakelandaccess()))
  )
end
function thetempestaccess()
  return(
    (has("thetempestaccess") and (kholusiaaccess()))
  )
end

--EnW
function oldsharlayanaccess()
  return(
    (has("oldsharlayanaccess"))
  )
end
function labyrinthosaccess()
  return(
    (has("labyrinthosaccess") and (oldsharlayanaccess()))
  )
end
function ultimathuleaccess()
  return(
    (has("ultimathuleaccess") and (labyrinthosaccess()))
  )
end
function garlemaldaccess()
  return(
    (has("garlemaldaccess") and (thelochsaccess()))
  )
end
function marelamentorumaccess()
  return(
    (has("marelamentorumaccess") and (garlemaldaccess()))
  )
end
function radzathanaccess()
  return(
    --should this be directly connected to limsa etc?
    (has("radzathanaccess") and (thavnairaccess()))
  )
end
function thavnairaccess()
  return(
    (has("thavnairaccess") and (oldsharlayanaccess() or radzathanaccess()))
  )
end
function elpisaccess()
  return(
    (has("elpisaccess") and (thecrystariumaccess()))
  )
end


--DT
function tuliyollalaccess()
  return(
    (has("tuliyollalaccess") and (oldsharlayanaccess()))
  )
end
function urqopachaaccess()
  return(
    (has("urqopachaaccess") and (tuliyollalaccess()))
  )
end
function kozamaukaaccess()
  return(
    (has("kozamaukaaccess") and (tuliyollalaccess()))
  )
end
function yaktelaccess()
  return(
    (has("yaktelaccess") and (tuliyollalaccess()))
  )
end
function shaaloaniaccess()
  return(
    (has("shaaloaniaccess") and (tuliyollalaccess()))
  )
end
function heritagefoundaccess()
  return(
    (has("heritagefoundaccess") and (shaaloaniaccess()))
  )
end
function livingmemoryaccess()
  return(
    (has("livingmemoryaccess") and (yaktelaccess()))
  )
end
function solutionnineaccess()
  return(
    (has("solutionnineaccess") and (heritagefoundaccess()))
  )
end

--levels
function leveling()
  return(
    math.max(Tracker:ProviderCountForCode("5pldlevels"), Tracker:ProviderCountForCode("5warlevels"), Tracker:ProviderCountForCode("5drklevels"), Tracker:ProviderCountForCode("5gnblevels"), Tracker:ProviderCountForCode("5whmlevels"), Tracker:ProviderCountForCode("5schlevels"), Tracker:ProviderCountForCode("5astlevels"), Tracker:ProviderCountForCode("5sgelevels"), Tracker:ProviderCountForCode("5mnklevels"), Tracker:ProviderCountForCode("5drglevels"), Tracker:ProviderCountForCode("5ninlevels"), Tracker:ProviderCountForCode("5samlevels"), Tracker:ProviderCountForCode("5rprlevels"), Tracker:ProviderCountForCode("5vprlevels"), Tracker:ProviderCountForCode("5brdlevels"), Tracker:ProviderCountForCode("5mchlevels"), Tracker:ProviderCountForCode("5dnclevels"), Tracker:ProviderCountForCode("5blmlevels"), Tracker:ProviderCountForCode("5smnlevels"), Tracker:ProviderCountForCode("5rdmlevels"), Tracker:ProviderCountForCode("5pctlevels"), Tracker:ProviderCountForCode("5blulevels"))
  )
end

function FishAccess(location, reqFshLevel)
  local fshLevels = Tracker:ProviderCountForCode("fshlevels")
  if fshLevels < reqFshLevel then
    return AccessibilityLevel.None
  end
  logicFish = logicFishList[location]
  outLogicFish = outLogicFishList[location]
  if logicFish ~= nil then
    for _, item in pairs(logicFish) do
      if Tracker:ProviderCountForCode(item) > 0 then
        return AccessibilityLevel.Normal
      end
    end
  end
  if outLogicFish ~= nil then
    for _, item in pairs(outLogicFish) do
      if Tracker:ProviderCountForCode(item) > 0 then
        return AccessibilityLevel.SequenceBreak
      end
    end
  end
  return AccessibilityLevel.None
end