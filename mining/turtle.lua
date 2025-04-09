function startup()
    peripheral.find("modem", rednet.open)
    local id = os.getComputerID()
    local label = os.getComputerLabel()
    print(label, id)
    rednet.host(label, (("System %d"):format(id)))

    local gps = {gps.locate()}
    currentPos = vector.new(gps[1], gps[2], gps[3])
    home = findHome()
    limits = findLimits() -- {limits_min, limits_max}
    distanceToHome = distanceToHome()
end

function findGPS(target, protocol)
    rednet.send(target, "nil", protocol)
    local msg_id, gps_tmp, protocol
    local coords = {}
    local counter = 1
    repeat
        msg_id, gps_tmp, protocol = rednet.receive()
        if target == msg_id then
            coords[counter] = gps_tmp
            counter = counter + 1
        end
    until counter > 3
    local vec = vector.new(coords[1], coords[2], coords[3])
    return vec
end

function findHome()
    local net_id = rednet.lookup("home")
    coords = findGPS(net_id, "home")
    coords.x = coords.x + 2
    return coords
end

function findLimits()
    local net_id = {rednet.lookup("chunkmarker")}
    local limits_min = findGPS(net_id[1], "chunkmarker")
    local limits_max = findGPS(net_id[2], "chunkmarker")

    print(limits_min.y, limits_max.y)
    if limits_min.y < limits_max.y then -- start mining after lowest chunk marker
        limits_max.y = limits_min.y
    end

    limits_max.y = limits_max.y - 4     -- extra spacing for grace
    limits_min.y = -56                  -- stop mining before bedrock (y = -64)

    return {limits_min, limits_max}
end

function distanceToHome()
    local displacement = home - currentPos
    return math.abs(displacement.x) + math.abs(displacement.y) + math.abs(displacement.z)
end

-- main
startup()

print("Current Position:", currentPos)
print("Home:", home:tostring())
print("Limits start:", limits[1]:tostring())
print("Limits end:", limits[2]:tostring())
print("Distance to Home:", distanceToHome)