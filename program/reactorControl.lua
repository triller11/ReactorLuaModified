-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 1.0 --
-- Reactor control --

--Loads the touchpoint and input APIs
shell.run("cp /extreme-reactors-control/config/touchpoint.lua /touchpoint")
os.loadAPI("touchpoint")
shell.run("rm touchpoint")

shell.run("cp /extreme-reactors-control/config/input.lua /input")
os.loadAPI("input")
shell.run("rm input")

--Some variables
local page = touchpoint.new(touchpointLocation)
local rodLevel
local enPer
local fuel
local fuelPer
local rfGen
local fuelCons
local isOn
local enPerR
local rOn
local rOff
local internalBuffer

--Create the buttons
function createButtons()
    page:add("Main Menu", function() run("/extreme-reactors-control/start/menu.lua") end, 2, 22, 17, 22)

    --Control Rods Buttons
    page:add("-1", function() setControlRods("-", 1) end, 45, 5, 48, 5)
    page:add("-10", function() setControlRods("-", 10) end, 39, 5, 43, 5)
    page:add("-100", function() setControlRods("-", 100) end, 32, 5, 37, 5)
    page:add("+1", function() setControlRods("+", 1) end, 45, 7, 48, 7)
    page:add("+10", function() setControlRods("+", 10) end, 39, 7, 43, 7)
    page:add("+100", function() setControlRods("+", 100) end, 32, 7, 37, 7)

    page:draw()
end

--Create additional manual buttons
function createButtonsMan()
    createButtons()

    --Reactor Toggle Button
    rOn = { " On ", label = "reactorOn" }
    rOff = { " Off ", label = "reactorOn" }

    page:add("reactorOn", toggleReactor, 11, 10, 15, 10)
    if r.getActive() then
        page:rename("reactorOn", rOn, true)
        page:toggleButton("reactorOn")
    else
        page:rename("reactorOn", rOff, true)
    end

    --Print buttons
    page:draw()
end

--Checks, if all peripherals were setup correctly
function checkPeripherals()
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.setTextColor(colors.red)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    if r == "" then
        mon.write("Reactor not found! Please check and reboot the computer (Press and hold Ctrl+R)")
        error("Reactor not found! Please check and reboot the computer (Press and hold Ctrl+R)")
    end
    if v == "" then
        v = r
        internalBuffer = true
    else
        internalBuffer = false
    end
end

--Toggles the reactor on/off
function toggleReactor()
    r.setActive(not r.getActive())
    page:toggleButton("reactorOn")
    if r.getActive() then
        page:rename("reactorOn", rOn, true)
    else
        page:rename("reactorOn", rOff, true)
    end
end

--Adjusts the control rods
function setControlRods(operation, value)
    local targetValue = r.getControlRodLevel(0)
    if operation == "-" then
        targetValue = targetValue - value
        if targetValue < 1 then targetValue = 0 end
    elseif operation == "+" then
        targetValue = targetValue + value
        if targetValue > 98 then targetValue = 99 end
    end
    r.setAllControlRodLevels(targetValue)
end

--Returns the current energy level (energy storage)
function getEnergy()
    local en = v.getEnergyStored()
    local enMax
    if v == r then enMax = 10000000
    else
        enMax = v.getMaxEnergyStored()
    end
    return math.floor(en / enMax * 100)
end

--Returns the current energy level (reactor)
function getEnergyR()
    local en = r.getEnergyStored()
    local enMax = 10000000
    return math.floor(en / enMax * 100)
end

--Reads all the reactors data
function getReactorData()
    rodLevel = r.getControlRodLevel(0)
    enPer = getEnergy()
    enPerR = getEnergyR()
    fuel = r.getFuelAmount()
    local fuelMax = r.getFuelAmountMax()
    fuelPer = math.floor(fuel / fuelMax * 100)
    rfGen = r.getEnergyProducedLastTick()
    fuelCons = r.getFuelConsumedLastTick()
    isOn = r.getActive()
end

--Checks for button clicks
function getClick()

    while true do

        --Refresh Data
        getReactorData()

        --refresh screen
        if overallMode == "auto" then
            displayDataAuto()
        elseif overallMode == "manual" then
            displayDataMan()
        end

        --timer
        local timer1 = os.startTimer(1)

        while true do
            --gets the event
            local event, p1 = page:handleEvents(os.pullEvent())
            print(event .. ", " .. p1)

            --execute a buttons function if clicked
            if event == "button_click" then
                page:flash(p1)
                page.buttonList[p1].func()
                break
            elseif event == "timer" and p1 == timer1 then
                break
            end
        end
    end
end

--Displays the data on the screen (auto mode)
function displayDataAuto()
    if enPer <= reactorOnAt then
        r.setActive(true)
    elseif enPer > reactorOffAt then
        r.setActive(false)
    end

    --Print all buttons
    page:draw()

    mon.setBackgroundColor(tonumber(backgroundColor))
    mon.setTextColor(tonumber(textColor))

    --Print the energy bar
    mon.setCursorPos(2, 2)

    mon.write("Energy: " .. enPer .. "%  ")

    mon.setCursorPos(2, 3)
    local part1 = enPer / 5
    mon.setCursorPos(2, 3)
    mon.setBackgroundColor(colors.lightGray)
    mon.write("                    ")
    mon.setBackgroundColor(colors.green)
    mon.setCursorPos(2, 3)
    for i = 1, part1 do
        mon.write(" ")
    end

    mon.setTextColor(textColor)
    mon.setBackgroundColor(tonumber(backgroundColor))

    --Print the reactor energy bar
    mon.setCursorPos(2, 5)
    mon.write("Energy (Reactor): " .. enPerR .. "%  ")

    mon.setCursorPos(2, 6)
    local part2 = enPerR / 5
    mon.setCursorPos(2, 6)
    mon.setBackgroundColor(colors.lightGray)
    mon.write("                    ")
    mon.setBackgroundColor(colors.green)
    mon.setCursorPos(2, 6)
    for i = 1, part2 do
        mon.write(" ")
    end

    mon.setTextColor(textColor)
    mon.setBackgroundColor(tonumber(backgroundColor))

    --Print the RodLevel bar
    mon.setCursorPos(30, 2)
    mon.write("RodLevel: " .. rodLevel .. "  ")
    mon.setCursorPos(30, 3)

    local part3 = rodLevel / 5
    mon.setCursorPos(30, 3)
    mon.setBackgroundColor(colors.lightGray)
    mon.write("                    ")
    mon.setBackgroundColor(colors.green)
    mon.setCursorPos(30, 3)
    for i = 1, part3 do
        mon.write(" ")
    end

    mon.setTextColor(textColor)
    mon.setBackgroundColor(tonumber(backgroundColor))

    mon.setCursorPos(2, 8)
    
    mon.write("RF-Production: " .. input.formatNumberComma(math.floor(rfGen)) .. " RF/t      ")

    mon.setCursorPos(2, 10)
    
    mon.write("Reactor: ")
    if r.getActive() then
        mon.setTextColor(colors.green)
        mon.write("on ")
    end
    if not r.getActive() then
        mon.setTextColor(colors.red)
        mon.write("off")
    end

    mon.setTextColor(tonumber(textColor))

    --Display Fuel Consumption
    mon.setCursorPos(2, 12)
    local fuelCons2 = string.sub(fuelCons, 0, 4)

    mon.write("Fuel Consumption: " .. fuelCons2 .. "mb/t     ")

    --Display Reactor Efficiency (RF/mb)
    mon.setCursorPos(2, 14)

    --Calculation and formatting of the efficiency
    local fuelEfficiency = rfGen / fuelCons
    if tonumber(fuelCons) == 0 then fuelEfficiency = 0 end
    local fuelEfficiency2 = math.floor(fuelEfficiency)

    mon.write("Efficiency: " .. input.formatNumberComma(fuelEfficiency2) .. " RF/mb    ")

    --Display the current Casing/Core Temperature
    local caT = tostring(r.getCasingTemperature())
    local caseTemp = string.sub(caT, 0, 6)
    local coT = tostring(r.getFuelTemperature())
    local coreTemp = string.sub(coT, 0, 6)

    mon.setCursorPos(2, 16)

    mon.write("Casing Temperature: " .. caseTemp .. "C    ")
    mon.setCursorPos(2, 17)
    mon.write("Core Temperature: " .. coreTemp .. "C    ")

    mon.setCursorPos(2, 25)
    mon.write("Version " .. version)
end

--Displays the data on the screen (manual mode)
function displayDataMan()

    if r.getActive() then
        if not page.buttonList["reactorOn"].active then
            page:toggleButton("reactorOn")
            page:rename("reactorOn", rOn, true)
        end
    else
        if page.buttonList["reactorOn"].active then
            page:toggleButton("reactorOn")
            page:rename("reactorOn", rOff, true)
        end
    end

    page:draw()

    mon.setBackgroundColor(tonumber(backgroundColor))
    mon.setTextColor(tonumber(textColor))

    --Print the energy bar
    mon.setCursorPos(2, 2)

    mon.write("Energy: " .. enPer .. "%  ")

    mon.setCursorPos(2, 3)
    local part1 = enPer / 5
    mon.setCursorPos(2, 3)
    mon.setBackgroundColor(colors.lightGray)
    mon.write("                    ")
    mon.setBackgroundColor(colors.green)
    mon.setCursorPos(2, 3)
    for i = 1, part1 do
        mon.write(" ")
    end

    mon.setTextColor(textColor)
    mon.setBackgroundColor(tonumber(backgroundColor))

    --Print the reactor energy bar
    mon.setCursorPos(2, 5)
    
    mon.write("Energy (Reactor): " .. enPerR .. "%  ")

    mon.setCursorPos(2, 6)
    local part2 = enPerR / 5
    mon.setCursorPos(2, 6)
    mon.setBackgroundColor(colors.lightGray)
    mon.write("                    ")
    mon.setBackgroundColor(colors.green)
    mon.setCursorPos(2, 6)
    for i = 1, part2 do
        mon.write(" ")
    end

    mon.setTextColor(textColor)
    mon.setBackgroundColor(tonumber(backgroundColor))

    --Print the RodLevel bar
    mon.setCursorPos(30, 2)
    mon.write("RodLevel: " .. rodLevel .. "  ")
    mon.setCursorPos(30, 3)

    local part3 = rodLevel / 5
    mon.setCursorPos(30, 3)
    mon.setBackgroundColor(colors.lightGray)
    mon.write("                    ")
    mon.setBackgroundColor(colors.green)
    mon.setCursorPos(30, 3)
    for i = 1, part3 do
        mon.write(" ")
    end

    mon.setTextColor(textColor)
    mon.setBackgroundColor(tonumber(backgroundColor))

    --Print the current RF Production of the reactor
    mon.setCursorPos(2, 8)
    
    mon.write("RF-Production: " .. input.formatNumberComma(math.floor(rfGen)) .. " RF/t      ")

    --Print the current status of the reactor
    mon.setCursorPos(2, 10)

    mon.write("Reactor: ")        

    mon.setTextColor(tonumber(textColor))

    --Display Fuel Consumption
    mon.setCursorPos(2, 12)
    local fuelCons2 = string.sub(tostring(fuelCons), 0, 4)

    mon.write("Fuel Consumption: " .. fuelCons2 .. "mb/t     ")

    --Display Reactor Efficiency (RF/mb)
    mon.setCursorPos(2, 14)

    --Calculation and formatting of the efficiency
    local fuelEfficiency = rfGen / fuelCons
    if tonumber(fuelCons) == 0 then fuelEfficiency = 0 end
    local fuelEfficiency2 = math.floor(fuelEfficiency)

    mon.write("Efficiency: " .. input.formatNumberComma(fuelEfficiency2) .. " RF/mb    ")

    --Display the current Casing/Core temperature of the reactor
    local caT = tostring(r.getCasingTemperature())
    local caseTemp = string.sub(caT, 0, 6)
    local coT = tostring(r.getFuelTemperature())
    local coreTemp = string.sub(coT, 0, 6)

    mon.setCursorPos(2, 16)

    mon.write("Casing Temperature: " .. caseTemp .. "C    ")
    mon.setCursorPos(2, 17)
    mon.write("Core Temperature: " .. coreTemp .. "C    ")

    --Print the current version
    mon.setCursorPos(2, 25)
    mon.write("Version " .. version)
end

--Runs another program
function run(program)
    shell.run(program)
    error("terminated.")
end

--Run
checkPeripherals()
if overallMode == "auto" then
    createButtons()
elseif overallMode == "manual" then
    createButtonsMan()
end
mon.setBackgroundColor(tonumber(backgroundColor))
mon.setTextColor(tonumber(textColor))
mon.clear()
getClick()
