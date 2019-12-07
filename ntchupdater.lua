-- Neptunium Chat Updater (v1.0 | December 7th, 2019)
 
term = require("term")
component = require("component")
computer = require("computer")
event = require("event")
gpu = component.gpu
os = require("os")
w, h = gpu.getResolution()
 
term.clear()
 
computer.beep(175, 0.25)
computer.beep(200, 0.25)
computer.beep(125, 0.5)
 
print("Welcome to the Neptunium Chat Updater!")
print("\nPlease select what branch you'd like to download:")
print("[F]inal, [W]ork In Progress")
 
branch = io.read()
 
while branch == "F" or branch == "f" do -- Select the Final branch
    os.execute('wget -f https://raw.githubusercontent.com/ntfluoride/neptunium-chat/master/ntch.lua /home/ntch.lua')
    os.exit()
end
 
while branch == "W" or branch == "w" do -- Select the Work In Progress branch
    os.execute('wget -f https://raw.githubusercontent.com/ntfluoride/neptunium-chat/wip/ntch.lua /home/ntch.lua')
    os.exit()
end