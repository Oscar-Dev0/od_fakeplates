function Class()
    local class = {}
    class.__index = class
    return setmetatable(class, { __call = function(self, ...)
        local instance = setmetatable({}, self)
        if instance.init then instance:init(...) end
        return instance
    end })
end
