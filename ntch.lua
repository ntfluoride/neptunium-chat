-- Neptunium Chat (build1) | Built on FlexChat

term = require("term")
component = require("component")
event = require("event")
serialization = require("serialization")
messages = {}
buffer = ""
invalidating = false

print("Welcome to Neptunium Chat, built upon (and compatible with) FlexChat! \n")
print("Please insert the port you'd like to communicate through:")
port = tonumber(term.read())

while port == nil do
    print("I'm sorry, that's not a valid port.")
    port = tonumber(io.stdin:read())
end

print("Please insert your alias:")
alias = term.read()
alias = alias:gsub("\n", "")

term.clear()

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
        term.write(("[" .. message.name .. "] " .. message.content), true)
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
eventHandlers = setmetatable({}, {__index = function() return unknownEvent end})

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