-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 1.0 --

-- Loads the Touchpoint API (by Lyqyd)
shell.run("cp /extreme-reactors-control/config/touchpoint.lua /touchpoint")
os.loadAPI("touchpoint")
shell.run("rm touchpoint")


-- Touchpoint Page
local page = touchpoint.new(touchpointLocation)
-- Button Labels
local startOn = {}
local startOff = {}

function _G.createButtons()
  page:add("Deutsch",nil,39,11,49,11)
  page:add("English",nil,39,13,49,13)

  page:add("Start program",startTC,3,5,20,5)
  page:add("Reactor only",function() switchProgram("Reactor") end,3,9,20,9)
  page:add("Turbines",function() switchProgram("Turbine") end,3,11,20,11)
  page:add("Automatic",nil,23,9,35,9)
  page:add("Manual",nil,23,11,35,11)
  page:add("Options",displayOptions,3,16,20,16)
  page:add("Quit program",exit,3,17,20,17)
  page:add("Reboot",restart,3,18,20,18)
  page:add("menuOn",nil,39,7,49,7)
  startOn = {"   On    ",label = "menuOn"}
  startOff = {"   Off   ",label = "menuOn"}
  page:toggleButton("English")

  if program == "turbine" then
    page:toggleButton("Turbines")
  elseif program == "reactor" then
    page:toggleButton("Reactor only")
  end
  
  if overallMode == "auto" then
    page:toggleButton("Automatic")
  elseif overallMode == "manual" then
    page:toggleButton("Manual")
  end

  if mainMenu then
    page:rename("menuOn",startOn,true)
    page:toggleButton("menuOn")
  else
    page:rename("menuOn",startOff,true)
  end
end

function _G.exit()
  controlMonitor.clear()
  controlMonitor.setCursorPos(27,8)
  controlMonitor.write("Program terminated!")    
  term.clear()
  term.setCursorPos(1,1)
  shell.completeProgram("/extreme-reactors-control/start/menu.lua")
end

function _G.switchProgram(currBut)
  if program == "turbine" and currBut == "Reactor" then
    program = "reactor"

    if not page.buttonList["Reactor only"].active then
      page:toggleButton("Reactor only")
    end
    if page.buttonList["Turbines"].active then
      page:toggleButton("Turbines")
    end

  elseif program == "reactor" and currBut == "Turbine" then
    program = "turbine"
        
    if page.buttonList["Reactor only"].active then
      page:toggleButton("Reactor only")
    end
    if not page.buttonList["Turbines"].active then
      page:toggleButton("Turbines")
    end
  end   


  saveOptionFile()
  page:draw()
  displayMenu()
end

function _G.startTC()
  if program == "turbine" then
    shell.run("/extreme-reactors-control/program/turbineControl.lua")
  elseif program == "reactor" then
    shell.run("/extreme-reactors-control/program/reactorControl.lua")
  end
end

function displayOptions()
  shell.run("/extreme-reactors-control/program/editOptions.lua")
end

function reboot()
  restart()
end

local function getClick(funct)
  local event,but = page:handleEvents(os.pullEvent())
  if event == "button_click" then
    if but == "menuOn" then
      print("menuOn")
      if not mainMenu then
        mainMenu = true
        saveOptionFile()
        page:rename("menuOn",startOn,true)
      elseif mainMenu then
        mainMenu = false
        saveOptionFile()
        page:rename("menuOn",startOff,true)
      end
      page:toggleButton(but)
      funct()

    elseif but == "Automatic" then
      if page.buttonList[but].active == false then
        page:toggleButton(but)
      end
      if overallMode == "manual" then
        page:toggleButton("Manual")
      elseif overallMode == "semi-manual" then
        page:toggleButton("Semi-Manual")
      end
      overallMode = "auto"
      saveOptionFile()
      funct()

    elseif but == "Manual" then
      if page.buttonList[but].active == false then
        page:toggleButton(but)
      end

      if overallMode == "auto" then
        page:toggleButton("Automatic")
      elseif overallMode == "semi-manual" then
        page:toggleButton("Semi-Manual")
      end

      overallMode = "manual"
      saveOptionFile()
      funct()
    else
      page:flash(but)
      page.buttonList[but].func()
    end

  else
    sleep(1)
    funct()
  end
end

function _G.displayMenu()
  controlMonitor.clear()
  page:draw()
  controlMonitor.setBackgroundColor(backgroundColor)
  controlMonitor.setTextColor(textColor)

  controlMonitor.setCursorPos(3,2)
  controlMonitor.write("-- Main Menu --")
  controlMonitor.setCursorPos(39,5)
  controlMonitor.write("Show this screen on startup: ")
  controlMonitor.setCursorPos(39,9)
  controlMonitor.write("Language: ")
  controlMonitor.setCursorPos(3,7)
  controlMonitor.write("Program: ")
  controlMonitor.setCursorPos(23,7)
  controlMonitor.write("Mode:")

  getClick(displayMenu)
end

createButtons()
displayMenu()