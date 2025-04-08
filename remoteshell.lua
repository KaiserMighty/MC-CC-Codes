-- save as startup

peripheral.find("modem", rednet.open)
local id = os.getComputerID()
local label = os.getComputerLabel()
rednet.host("remote", ("System %d"):format(id))
if label ~= nil then
    rednet.broadcast(("System ID %d with label %s is online!"):format(id, label))
else
    rednet.broadcast(("System ID %d is online!"):format(id))
end

while true do
    local id, message, protocol
    repeat
        id, message, protocol = rednet.receive()
    until protocol == "remote"

    print("Processing: " .. message)
    local cmdExec, err = load(message, nil, "t", _ENV)
    if cmdExec then
        print("Input = " .. message)
        local result = {pcall(cmdExec)}
        print("Debug = " .. tostring(result))
        cmdResult = result
        if result then
            result = textutils.serialize(cmdResult, {compact = true})
        end
        print("Output = " .. tostring(result))
    end
end

-- rednet.lookup("remote")
-- rednet.send(id, "gps.locate()", "remote")
-- rednet.broadcast("gps.locate()", "remote")