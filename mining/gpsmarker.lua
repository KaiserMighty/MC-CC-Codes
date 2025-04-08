-- save as startup
-- label set "chunkmarker"
-- label set "home"

peripheral.find("modem", rednet.open)
local id = os.getComputerID()
local label = os.getComputerLabel()
print(label, id)
rednet.host(label, (("System %d"):format(id)))
local gps_x, gps_y, gps_z = gps.locate()

while true do
    local msg_id, message, protocol
    repeat
        msg_id, message, protocol = rednet.receive()
    until protocol == label
    rednet.send(msg_id, gps_x)
    rednet.send(msg_id, gps_y)
    rednet.send(msg_id, gps_z)
end

-- rednet.lookup("protocol")
-- rednet.send(id, "nil", "protocol")
-- local id, gps_x, gps_y, gps_z
-- id, gps_x = rednet.receive()
-- verify send id and receive id are the same