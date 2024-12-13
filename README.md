# Extreme Reactors Control 

*** Based off of Reactor and Turbine control program - Original work thanks to the contributors over at https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program  ***

***Description:***

The following list shows the features of the program:
- Control up to 120 Turbines + Multiple Reactors (Tested with 384 Turbines and 16 Reactors on FTB Rev 3.5 but the monitor will not display more then 130 buttons)
- Automatic and manual Control of Reactor and attached Turbines
- Energy-based automatic Control
    - Switches Turbines on/off if energy level is low/high
    - Supports multiple Energy Storage types like Capacitorbanks (EnderIO), Energy Core (Draconic Evolution), Mekanism, etc.
- Large option menu
    - Change Background and Text Color
    - Set energy level for activating/deactivating the reactor
    - Set Reactor Steam Output Level
- Multiple Language support (Can be set via config file or install. options menu changes to come)
- Support for using Mekanism Dynamic Tank as steam storage for reinforced reactors, allowing the reactor to automatically turn on/off based on stored steam amounts further increasing efficiency of the system.

*** Mod Packs Tested Against ***
Claimed by previous author
- FTB Revelations (v3.5) w/ Mekanisms
- All The Mods (v6)

Personally tested
- All the Mods 10

## How To Install
- Set up a Computer, connect all parts (Reactor, Energy Storage, Turbines, optionally: mekanism dynamic tank valve) with ***Wired Modems***
- ***Activate*** all modems
- For setups with only a reactor or less than 33 turbines use a monitor 7 wide and 4 tall.
- For setups with over 32 turbines use a monitor that is 8 wide and 6 tall.
- Requires some form of energry storage that is supported (Capacitorbanks (EnderIO), Energy Core (Draconic Evolution), Mekanism, etc.).
- Type in the following into the computer:

    ```
    wget https://raw.githubusercontent.com/triller11/ReactorLuaModified/refs/heads/main/install/installer.lua installer
    ```

- Run the installer by typing installer and pressing enter
- Then follow the install instructions
    
    


## Thank You For Using ##

- This is a modification of another authors code which itsself was a modification of another codebase. All credit goes to previous contributors.
- @MPThLee Added Support for New Class name of Induction Port in Mekanism
- @Sxigames for the Portuguese (Brazil) translation file
- DISCORD: seigneurghost for the French translation file
- DISCORD: phxnkyhouse for Polish translation file.
- All the people who report bugs and test develop on Discord

