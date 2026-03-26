function duty_visibility(name)
    for _, duty in ipairs(ExcludedDuties) do
        if duty == name then
            return false
        end
    end
    return true
end