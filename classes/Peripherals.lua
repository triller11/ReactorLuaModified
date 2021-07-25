-- Reactor / Turbine Control
-- (c) 2017 Thor_s_Crafter
-- Version 3.0


--Peripherals
_G.monitors = {} --Monitor
_G.controlMonitor = "" --Monitor
_G.reactors = {} --Reactor
_G.capacitors = {} --Energy Storage
_G.turbines = {} --Turbines

--Total count of all turbines
_G.amountTurbines = 0
_G.amountMonitors = 0
_G.amountCapacitors = 0
_G.amountReactors = 0

local function searchPeripherals()
    local peripheralList = peripheral.getNames()
    for i = 1, #peripheralList do
        local periItem = peripheralList[i]
        local periType = peripheral.getType(periItem)
        local peri = peripheral.wrap(periItem)
        
        if periType == "BigReactors-Reactor" then
            print("Reactor - "..periItem)
            _G.reactors[amountReactors] = newReactor("r" .. tostring(amountReactors), peri, periItem, periType)
            _G.amountReactors = amountReactors + 1
        elseif periType == "BigReactors-Turbine" then
            print("Turbine - "..periItem)
            _G.turbines[amountTurbines] = newTurbine("t" .. tostring(amountTurbines), peri, periItem, periType)
            _G.amountTurbines = amountTurbines + 1
        elseif periType == "BiggerReactors_Reactor" then
            print("BiggerReactor Reactor - "..periItem)
            _G.reactors[amountReactors] = newBiggerReactor("r" .. tostring(amountReactors), peri, periItem, periType)
            _G.amountReactors = amountReactors + 1
        elseif periType == "BiggerReactors_Turbine" then
            print("BiggerReactor Turbine - "..periItem)
            _G.turbines[amountTurbines] = newBiggerTurbine("t" .. tostring(amountTurbines), peri, periItem, periType)
            _G.amountTurbines = amountTurbines + 1
        elseif periType == "monitor" then
            print("Monitor - "..periItem)
			if(peripheralList[i] == controlMonitor) then
				--add to output monitors
				_G.monitors[amountMonitors] = peripheral.wrap(peripheralList[i])
				_G.amountMonitors = amountMonitors + 1
			else
				_G.controlMonitor = peripheral.wrap(peripheralList[i])
				_G.touchpointLocation = periItem
			end
        else
            local successGetEnergyStored, errGetEnergyStored = pcall(function() peri.getEnergyStored() end)
            local successGetEnergy, errGetEnergy = pcall(function() peri.getEnergy() end)

            if successGetEnergyStored then
			    --Capacitorbank / Energycell / Energy Core
                print("getEnergyStored() device - "..peripheralList[i])
                _G.capacitors[amountCapacitors] = newEnergyStorage("e" .. tostring(amountCapacitors), peri, periItem, periType)
                _G.amountCapacitors = amountCapacitors + 1
            end

            if successGetEnergy then
			    --Mekanism / others
                print("getEnergy() device - "..peripheralList[i])
                _G.capacitors[amountCapacitors] = newMekanismEnergyStorage("e" .. tostring(amountCapacitors), peri, periItem, periType)
                _G.amountCapacitors = amountCapacitors + 1
            end

        end
    end

	_G.amountReactors = amountReactors - 1
	_G.amountTurbines = amountTurbines - 1
	_G.amountCapacitors = amountCapacitors - 1
end

local function checkPeripherals()
	--Check for errors
	term.clear()
	term.setCursorPos(1,1)

    if _G.reactors[0] == nil then
        error("No reactor found!")
    end
	if controlMonitor == "" then
        error("Monitor not found!\nPlease check and reboot the computer (Press and hold Ctrl+R)")
	end

    --Monitor clear
	controlMonitor.setBackgroundColor(colors.black)
	controlMonitor.setTextColor(colors.red)
	controlMonitor.clear()
	controlMonitor.setCursorPos(1,1)
    
	--Monitor too small
	local monX,monY = controlMonitor.getSize()
	if monX < 71 or monY < 26 then
		controlMonitor.write("Monitor too small\n Must be at least 8 in length and 6 in height.\nPlease check and reboot the computer (Press and hold Ctrl+R)")
		error("Monitor too small.\nMust be at least 8 in length and 6 in height.\nPlease check and reboot the computer (Press and hold Ctrl+R)")
	end
end


function _G.initPeripherals()
    searchPeripherals()
    checkPeripherals()
end


