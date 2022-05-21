mathutils = {}

mathutils.clamp = function(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

mathutils.map = function(value, min1, max1, min2, max2)
    return min2 + (max2 - min2) * ((value - min1) / (max1 - min1))
end
