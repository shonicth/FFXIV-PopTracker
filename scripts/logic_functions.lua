function fatesanity_disabled()
    return Tracker:ProviderCountForCode('fatesanity') == 0
end


--function FishAccess(location, reqFshLevel)
--  local fshLevels = Tracker:ProviderCountForCode("5fshlevels")
--  if fshLevels < ((reqFshLevel // 5) * 5)  then
--    return AccessibilityLevel.None
--  end
--  logicFish = logicFishList[location]
--  outLogicFish = outLogicFishList[location]
--  if logicFish ~= nil then
--    for _, item in pairs(logicFish) do
--      if Tracker:ProviderCountForCode(item) > 0 then
--        return AccessibilityLevel.Normal
--      end
--    end
--  end
--  if outLogicFish ~= nil then
--    for _, item in pairs(outLogicFish) do
--      if Tracker:ProviderCountForCode(item) > 0 then
--        return AccessibilityLevel.SequenceBreak
--      end
--    end
--  end
--  return AccessibilityLevel.None
--end

function fishAccess(zone, fish)
    local fshLevels = Tracker:ProviderCountForCode("5fshlevels")
    local reqFshLevel = fishtable[fish].lvl
    local logicBait = fishtable[fish].zones[zone]
    if logicBait == nil then
        print(zone)
        print(fish)
        print("zone/fish is nil")
    end
    if fshLevels >= ((reqFshLevel // 5) * 5)  then
        if logicBait ~= nil then
            for _, item in ipairs(logicBait) do
                if Tracker:ProviderCountForCode(item) > 0 then
                    return AccessibilityLevel.Normal
                end
            end
        end
    end
end

function fishVisibility(fish)
  local level_cap = Tracker:ProviderCountForCode("level_cap")
  local reqFshLevel = fishtable[fish].lvl
  local timed = fishtable[fish].timed or 0
  if level_cap >= reqFshLevel and Tracker:FindObjectForCode("fishsanity").CurrentStage > timed then
         return true
    end
    return false
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
    if level_cap >= reqLevel and Tracker:ProviderCountForCode('fatesanity') == 0 then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function fateAccess(fate)
    if fate == nil then
        print(fate)
        print("fate is nil")
    end
    if fate ~= nil then
      local leveling = leveling() 
        local reqLevel = fatelist[fate]
        if leveling >= math.max(reqLevel - 5, reqLevel // 10 * 10) then
            return AccessibilityLevel.Normal
        end
    end
    return AccessibilityLevel.None
end

function fateVisibility(fate)
    if fate == nil then
        print(fate)
        print("fate is nil")
    end
    if Tracker:ProviderCountForCode("fatesanity") > 0 and fate ~= nil then
        local level_cap = Tracker:ProviderCountForCode("level_cap")
        local reqLevel = fatelist[fate]
        if level_cap >= reqLevel then
            return true
        end
    end
    return false
end

function duty_visibility(name)
  local dutyname = dutylist[name] 
    for _, duty in ipairs(ExcludedDuties) do
        if duty == dutyname then
            return false
        end
    end
    return true
end