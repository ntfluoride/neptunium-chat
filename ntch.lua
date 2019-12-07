-- Neptunium Chat (v1.03 WIP | December 7th, 2019) | Thanks to Mr. Reflectronic!
 
term = require("term")
component = require("component")
computer = require("computer")
event = require("event")
gpu = component.gpu
os = require("os")
w, h = gpu.getResolution()
serialization = require("serialization")
messages = {}
buffer = ""
invalidating = false
 
term.clear()
 
computer.beep(100, 0.25)
computer.beep(150, 0.25)
computer.beep(200, 0.5)
 
-- print("Welcome to Neptunium Chat v1.03!")
print("Welcome to Neptunium Chat v1.03 (WIP)!")
detectedmem = computer.totalMemory()

while detectedmem < 384000 do -- If total memory is less than 384KB abort loading
    gpu.setForeground(0x000000)
    gpu.setBackground(0x8B0000)
    gpu.fill(1, 1, w, h, " ")
    term.clear()
    print("This machine lacks sufficient memory to continue running this program. Terminating...")
    os.sleep(5)
    os.exit
end

print("Please choose a theme for your client:")
print("(Some themes might have issues on low-end hardware)")
print("[D]efault | [F]all | [H]eat | [I]nverted | [L]ight | [S]ummer ")
usertheme = io.read()
 
while usertheme == "D" or usertheme == "d" do -- Select the default theme
    gpu.setForeground(0xFFFFFF)
    gpu.setBackground(0x000000)
    gpu.fill(1, 1, w, h, " ")
    term.clear()
end
 
while usertheme == "I" or usertheme == "i" do -- Select the inverted theme (better than light *I* guess :P)
    gpu.setForeground(0x000000)
    gpu.setBackground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")
    term.clear()
end

while usertheme == "L" or usertheme == "l" do -- Select the light theme (freak)
    gpu.setForeground(0x000000)
    gpu.setBackground(0xC0C0C0)
    gpu.fill(1, 1, w, h, " ")
    term.clear()
end
 
while usertheme == "S" or usertheme == "s" do -- Select the bright summer theme
    gpu.setForeground(0x008000)
    gpu.setBackground(0x0000FF)
    gpu.fill(1, 1, w, h, " ")
    term.clear()
end

while usertheme == "F" or usertheme == "f" do -- Select the warm fall theme
    gpu.setForeground(0x808080)
    gpu.setBackground(0x654321)
    gpu.fill(1, 1, w, h, " ")
    term.clear()
end

while usertheme == "DE" or usetheme == "de" do -- Select the debug theme (easter egg!)
    gpu.setForeground(0x000000)
    gpu.setBackground(0x008000)
    gpu.fill(1, 1, w, h, " ")
    term.clear()
end

while usertheme == nil do
    print("Unknown theme selection.")
    computer.beep(1500, 0.5)
    usertheme = io.stdin:read()
end

print("Please select the port you'd like to communicate through (1 - 65535):")
port = tonumber(term.read())
 
while port == nil do
    print("Unknown port number.")
    computer.beep(1500, 0.5)
    port = tonumber(io.stdin:read())
end
 
print("Please insert an alias:")
alias = term.read()
alias = alias:gsub("\n", "")
 
term.clear()

print("You're connected!")
 
width, height = term.getViewport()
height = height + 1
 
component.modem.open(port)
 
function getLines(str)
        local lines = math.ceil(str:len()/width)
        if lines == 0 then lines = 1 end
        return lines
end
 
function invalidate()
    invalidating = true
    term.clear()
    local bufLines = getLines(buffer)
    local lineBudget = height - bufLines
    for i, v in ipairs(messages) do
        local message = messages[i]
        local lines = getLines(message.content)
        lineBudget = lineBudget - lines
        if lineBudget <= 0 then break end
           
        term.setCursor(1, lineBudget)
        term.write(("[" .. message.name .. "]> " .. message.content), true)
    end
 
    term.setCursor(1, height-bufLines)
    term.write(buffer, true)
    invalidating = false
end
 
function spin()
    while invalidating do
        -- Spin until done invalidating
    end
end
 
function moveCursorBack()
    local x, y = term.getCursor()
    if x ~= 1 then
        term.setCursor(x - 2, y)
    end
  invalidate()
end
 
function unknownEvent() end -- If event is not relevant, do nothing
eventHandlers = setmetatable({}, {__index = function() return unknownEvent end })
 
function eventHandlers.modem_message(_, _, _, _, message)
    spin()
    local msg = serialization.unserialize(message)
    msg.name = msg.name:gsub("\n", "")
    table.insert(messages, 1, msg) -- The first message is the latest
  invalidate()
end
 
function eventHandlers.key_down(kbdAddr, char, code, pName)
    spin()
    if char == 13 then -- Enter
        local serializedMsg = serialization.serialize({name=alias,content=buffer})
        buffer=""
        eventHandlers["modem_message"](nil, nil, nil, nil, serializedMsg)
        component.modem.broadcast(port, serializedMsg)
      return
    end
   
    if char == 127 then -- Backspace
        moveCursorBack()
        buffer = buffer:sub(1, -2)
        invalidate()
        return
    end
 
    if char >= 63232 and char <= 63235 then -- Arrow keys
        return -- They will crash otherwise
    end
   
    buffer = buffer .. string.char(char)
    invalidate()
end
 
function handleEvent(eventId, ...)
    if (eventId) then
        eventHandlers[eventId](...)
    end
end
 
while true do
    term.setCursorBlink(true)
    handleEvent(event.pull())
end