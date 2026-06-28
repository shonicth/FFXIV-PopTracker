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
    local logicBait = fishtable[fish].logical_bait[zone] or fishtableOld[fish].zones[zone]
    local allBait = fishtable[fish].all_bait[zone]
    if allBait == nil then
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
        if allBait ~= nil then
            for _, item in ipairs(logicBait) do
                if Tracker:ProviderCountForCode(item) > 0 then
                    return AccessibilityLevel.SequenceBreak
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
    local reqLevelNumber = tonumber(reqLevel) 
    if leveling >= math.max(reqLevelNumber - 5, reqLevelNumber // 10 * 10) then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function fateMinLevelVisibility(reqLevel)
    local level_cap = Tracker:ProviderCountForCode("level_cap")
    local reqLevelNumber = tonumber(reqLevel) 
    if level_cap >= reqLevelNumber and Tracker:ProviderCountForCode('fatesanity') == 0 then
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
    if ExcludedDuties ~= nil then
        for _, duty in ipairs(ExcludedDuties) do
            if duty == dutyname then
                return false
            end
        end
    end
    return true
end

function goal_duty_access(goal)
    local mcguffinsNeeded = Tracker:FindObjectForCode("mcguffins").MaxCount
    if Tracker:ProviderCountForCode(goal) > 0 and mcguffinsNeeded > 0 then
        if Tracker:ProviderCountForCode("mcguffins") >= mcguffinsNeeded then
            return true
        end
        return false
    end
    return true
end

--There's probably a better way to handle this
function goal_ultima()
    if Tracker:ProviderCountForCode("DefeatUltimaWeapon") == 0 and Tracker:ProviderCountForCode("allow_main_scenario_duties") == 0 then 
        return false
    end
    return true
end

function collect_memories()
    local mcguffins_needed = Tracker:ProviderCountForCode("mcguffins_needed") / 2
    if Tracker:ProviderCountForCode("mcguffins") >= mcguffins_needed then
        return true
    end
    return false
end