local DynamicTank = {
    name = "",
    id = {},
    side = "",
    type = "",

    filledPercentage = function(self)
        return math.floor(self.id.getFilledPercentage())
    end
}

function _G.newDynamicTank(name, id, side, type)
    print("Creating new Dynamic Tank")
    local tank = {}
    setmetatable(tank, { __index = DynamicTank })

    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    tank.name = name
    tank.id = id
    tank.side = side
    tank.type = type

    return tank
end
