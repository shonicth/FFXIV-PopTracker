function fatesanity_disabled()
    return Tracker:ProviderCountForCode('fatesanity') == 0
end

function FishAccess(location, reqFshLevel)
  local fshLevels = Tracker:ProviderCountForCode("5fshlevels")
  if fshLevels < ((reqFshLevel // 5) * 5)  then
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

function fateMinLevelAccess(reqLevel)
      local leveling = leveling() 
    if leveling > math.max(reqLevel - 5, reqLevel // 10 * 10) then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function fateMinLevelVisibility(reqLevel)
    local level_cap = Tracker:ProviderCountForCode("level_cap")
    if level_cap > math.max(reqLevel - 5, reqLevel // 10 * 10) and Tracker:ProviderCountForCode('fatesanity') == 0 then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function fateAccess(fate)
    if fate ~= nil then
      local leveling = leveling() 
        local reqLevel = fatelist[fate]
        if leveling > math.max(reqLevel - 5, reqLevel // 10 * 10) then
            return AccessibilityLevel.Normal
        end
    end
    return AccessibilityLevel.None
end

function fateVisibility(fate)
    if Tracker:ProviderCountForCode("fatesanity") > 0 and fate ~= nil then
        local level_cap = Tracker:ProviderCountForCode("level_cap")
        local reqLevel = fatelist[fate]
        if level_cap > math.max(reqLevel - 5, reqLevel // 10 * 10) then
            return true
        end
    end
    return false
end