-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 1.0 --
-- Start program --

--========== Global variables for all program parts ==========

--All options
_G.optionList = {}
_G.version = 0
_G.rodLevel = 0
_G.backgroundColor = 0
_G.textColor = 0
_G.reactorOffAt = 0
_G.reactorOnAt = 0
_G.mainMenu = ""
_G.lang = ""
_G.overallMode = ""
_G.program = ""
_G.turbineTargetSpeed = 0
_G.targetSteam = 0
_G.turbineOnOff = ""
_G.debug = 0
_G.skipControlRodCheck = 0


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

--TouchpointLocation (same as the monitor)
_G.touchpointLocation = {}

--========== Global functions for all program parts ==========

--===== Functions for loading and saving the options =====

local repoUrl = "https://gitlab.com/seekerscomputercraft/extremereactorcontrol/-/raw/"

function _G.debugOutput(message) 
	if debug == 1 then
		print(message)
	end
end

--Loads the options.txt file and adds values to the global variables
function _G.loadOptionFile()
	debugOutput("Loading Option File")
	--Loads the file
	local file = fs.open("/extreme-reactors-control/config/options.txt","r")
	local list = file.readAll()
	file.close()

    --Insert Elements and assign values
    _G.optionList = textutils.unserialise(list)

	--Assign values to variables
	_G.version = optionList["version"]
	_G.rodLevel = optionList["rodLevel"]
	_G.backgroundColor = tonumber(optionList["backgroundColor"])
	_G.textColor = tonumber(optionList["textColor"])
	_G.reactorOffAt = optionList["reactorOffAt"]
	_G.reactorOnAt = optionList["reactorOnAt"]
	_G.mainMenu = optionList["mainMenu"]
	_G.overallMode = optionList["overallMode"]
	_G.program = optionList["program"]
	_G.turbineTargetSpeed = optionList["turbineTargetSpeed"]
	_G.targetSteam  = optionList["targetSteam"]
	_G.turbineOnOff = optionList["turbineOnOff"]
	_G.debug = optionList["debug"]
	_G.skipControlRodCheck = optionList["skipControlRodCheck"]
end

--Refreshes the options list
function _G.refreshOptionList()
	debugOutput("Refreshing Option List")
	debugOutput("Variable: version")
	optionList["version"] = version
	debugOutput("Variable: rodLevel")
	optionList["rodLevel"] = rodLevel
	debugOutput("Variable: backgroundColor"..backgroundColor)
	optionList["backgroundColor"] = backgroundColor
	debugOutput("Variable: textColor = "..textColor)
	optionList["textColor"] = textColor
	debugOutput("Variable: reactorOffAt")
	optionList["reactorOffAt"] = reactorOffAt
	debugOutput("Variable: reactorOnAt")
	optionList["reactorOnAt"] = reactorOnAt
	debugOutput("Variable: mainMenu")
	optionList["mainMenu"] = mainMenu
	debugOutput("Variable: overallMode")
	optionList["overallMode"] = overallMode
	debugOutput("Variable: program")
	optionList["program"] = program
	debugOutput("Variable: turbineTargetSpeed")
	optionList["turbineTargetSpeed"] = turbineTargetSpeed
	debugOutput("Variable: targetSteam")
	optionList["targetSteam"] = targetSteam
	debugOutput("Variable: turbineOnOff")
	optionList["turbineOnOff"] = turbineOnOff
	debugOutput("Variable: skipControlRodCheck")
	optionList["skipControlRodCheck"] = skipControlRodCheck
end

--Saves all data basck to the options.txt file
function _G.saveOptionFile()
	debugOutput("Saving Option File")
	--Refresh option list
	refreshOptionList()
    --Serialise the table
    local list = textutils.serialise(optionList)
	--Save optionList to the config file
	local file = fs.open("/extreme-reactors-control/config/options.txt","w")
    file.writeLine(list)
	file.close()
	print("Saved.")
end


--===== Automatic update detection =====

--Check for updates
function _G.checkUpdates()

	--Check current branch (release or beta)
	local currBranch = ""
	local tmpString = string.sub(version,5,5)
	if tmpString == "" or tmpString == nil or tmpString == "r" then
		currBranch = "main"
	elseif tmpString == "b" then
		currBranch = "develop"
	end

	--Get Remote version file
	downloadFile(repoUrl..currBranch.."/",currBranch..".ver")

	--Compare local and remote version
	local file = fs.open(currBranch..".ver","r")
	local remoteVer = file.readLine()
	file.close()

	print("remoteVer: "..remoteVer)
	print("localVer: "..version)
	print("Update? -> "..tostring(remoteVer > version))
	print("Cells: "..#capacitors)
	
	--Update if available
	if remoteVer > version then
		print("Update...")
		sleep(2)
		doUpdate(remoteVer,currBranch)
	end

	--Remove remote version file
	shell.run("rm "..currBranch..".ver")
end


function _G.doUpdate(toVer,branch)

	--Set the monitor up
	local x,y = controlMonitor.getSize()
	controlMonitor.setBackgroundColor(colors.black)
	controlMonitor.clear()

	local x1 = x/2-15
	local y1 = y/2-4
	local x2 = x/2
	local y2 = y/2

	--Draw Box
	controlMonitor.setBackgroundColor(colors.gray)
	controlMonitor.setTextColor(colors.gray)
	controlMonitor.setCursorPos(x1,y1)
	for i=1,8 do
		controlMonitor.setCursorPos(x1,y1+i-1)
		controlMonitor.write("                              ") --30 chars
	end

	--Print update message
	controlMonitor.setTextColor(colors.white)

	controlMonitor.setCursorPos(x2-9,y1+1)
	controlMonitor.write("Update available!") --17 chars

	controlMonitor.setCursorPos(x2-(math.ceil(string.len(toVer)/2)),y1+3)
	controlMonitor.write(toVer)

	controlMonitor.setCursorPos(x2-8,y1+5)
	controlMonitor.write("To install look") --15 chars

	controlMonitor.setCursorPos(x2-12,y1+6)
	controlMonitor.write("at the computer terminal") --24 chars

	--Print install instructions to the terminal
	term.clear()
	term.setCursorPos(1,1)
	local tx,ty = term.getSize()

		print("Do you want to install the update (y/n)?")
		term.write("Input: ")

	--Run Counter for installation skipping
	local count = 10
	local out = false

	term.setCursorPos(tx/2-5,ty)
	term.write(" -- 10 -- ")

	while true do

		local timer1 = os.startTimer(1)

		while true do

			local event, p1 = os.pullEvent()

			if event == "key" then

				if p1 == 36 or p1 == 21 then
					shell.run("/extreme-reactors-control/install/installer.lua update "..branch)
					out = true
					break
				end

			elseif event == "timer" and p1 == timer1 then

				count = count - 1
				term.setCursorPos(tx/2-5,ty)
				term.write(" -- 0"..count.." -- ")
				break
			end
		end

		if out then break end

		if count == 0 then
			term.clear()
			term.setCursorPos(1,1)
			break
		end
	end
end

--Download Files (For Remote version file)
function _G.downloadFile(relUrl,path)
	local gotUrl = http.get(relUrl..path)
	if gotUrl == nil then
		term.clear()
		error("File not found! Please check!\nFailed at "..relUrl..path)
	else
		_G.url = gotUrl.readAll()
	end

	local file = fs.open(path,"w")
	file.write(url)
	file.close()
end


--===== Initialization of all peripherals =====

function _G.initPeripherals()
	--Get all peripherals
	local peripheralList = peripheral.getNames()
	for i = 1, #peripheralList do
		--Turbines
		if peripheral.getType(peripheralList[i]) == "BigReactors-Turbine" then
			print("Turbine - "..peripheralList[i])
			_G.turbines[amountTurbines] = peripheral.wrap(peripheralList[i])
			_G.amountTurbines = amountTurbines + 1
			--Reactor
		elseif peripheral.getType(peripheralList[i]) == "BigReactors-Reactor" then
			print("Reactor - "..peripheralList[i])
			_G.reactors[amountReactors] = peripheral.wrap(peripheralList[i])
			_G.amountReactors = amountReactors + 1
			--Monitor & Touchpoint
		elseif peripheral.getType(peripheralList[i]) == "monitor" then
			print("Monitor - "..peripheralList[i])
			if(peripheralList[i] == controlMonitor) then
				--add to output monitors
				_G.monitors[amountMonitors] = peripheral.wrap(peripheralList[i])
				_G.amountMonitors = amountMonitors + 1
			else
				_G.controlMonitor = peripheral.wrap(peripheralList[i])
				_G.touchpointLocation = peripheralList[i]	
			end

			--Capacitorbank / Energycell / Energy Core
		else
			local tmp = peripheral.wrap(peripheralList[i])
			local stat,err = pcall(function() tmp.getEnergyStored() end)
			if stat then
				print("EnergyCell - "..peripheralList[i])
				_G.capacitors[amountCapacitors] = tmp
				_G.amountCapacitors = amountCapacitors + 1
			end
		end
	end
	
	--Check for errors
	term.clear()
	term.setCursorPos(1,1)
	--No Monitor
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
		controlMonitor.write("Monitor too small\n Must be at least 7 in length and 4 in height.\nPlease check and reboot the computer (Press and hold Ctrl+R)")
		error("Monitor too small.\nMust be at least 7 in length and 4 in height.\nPlease check and reboot the computer (Press and hold Ctrl+R)")
	end

	_G.amountReactors = amountReactors - 1
	_G.amountTurbines = amountTurbines - 1
	_G.amountCapacitors = amountCapacitors - 1
end


--===== Shutdown and restart the computer =====

function _G.reactorestart()
	saveOptionFile()
	controlMonitor.clear()
	controlMonitor.setCursorPos(38,8)
	controlMonitor.write("Rebooting...")
	os.reboot()
end


--=========== Run the program ==========

--Load the option file and initialize the peripherals

debugOutput("Loading Options File")
loadOptionFile()


debugOutput("Initializing Network Devices")
initPeripherals()

debugOutput("Checking for Updates")
checkUpdates()

--Run program or main menu, based on the settings
if mainMenu then
	shell.run("/extreme-reactors-control/start/menu.lua")
	shell.completeProgram("/extreme-reactors-control/start/start.lua")
else
	if program == "turbine" then
		shell.run("/extreme-reactors-control/program/turbineControl.lua")
	elseif program == "reactor" then
		shell.run("/extreme-reactors-control/program/reactorControl.lua")
	end
	shell.completeProgram("/extreme-reactors-control/start/start.lua")
end


--========== END OF THE START.LUA FILE ==========
