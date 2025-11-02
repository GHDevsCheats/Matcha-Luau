local function parse(json)
    local results = {}
    for key, value in json:gmatch('%s*"([^"]-)"%s*:%s*"([^"]-)"%s*[,}]') do
        results[key] = value
    end
    return results
end

local allOffsets = parse(game:HttpGet("https://offsets.ntgetwritewatch.workers.dev/offsets.json"))

function getOffset(OffsetName)
    local offset = allOffsets[OffsetName]
    if offset then return offset end
    
    return "0x0"
end




GHDev = {}
GHDev.Utils = {}

local Utils = GHDev.Utils
function Utils.getPrimitive(Instance)
    return memory_read("uintptr_t", Instance.Address + getOffset("Primitive"))
end

function Utils.readVector3(address)
    local vec = Vector3.new(0, 0, 0)
    vec.x = memory_read("float", address)
    vec.y = memory_read("float", address + 0x4)
    vec.z = memory_read("float", address + 0x8)
    return vec
end

function Utils.writeVector3(address, vec)
    memory_write("float", address, vec.x)
    memory_write("float", address + 0x4, vec.y)
    memory_write("float", address + 0x8, vec.z)
end

function Utils.readMatrix3(address)
    local data = {}
    data["0"] = memory_read("float", address + 0x00)
    data["1"] = memory_read("float", address + 0x04)
    data["2"] = memory_read("float", address + 0x08)
    data["3"] = memory_read("float", address + 0x0C)
    data["4"] = memory_read("float", address + 0x10)
    data["5"] = memory_read("float", address + 0x14)
    data["6"] = memory_read("float", address + 0x18)
    data["7"] = memory_read("float", address + 0x1C)
    data["8"] = memory_read("float", address + 0x20)
    return data
end

function Utils.writeMatrix3(address, data)
    memory_write("float", address + 0x00, data["0"])
    memory_write("float", address + 0x04, data["1"])
    memory_write("float", address + 0x08, data["2"])
    memory_write("float", address + 0x0C, data["3"])
    memory_write("float", address + 0x10, data["4"])
    memory_write("float", address + 0x14, data["5"])
    memory_write("float", address + 0x18, data["6"])
    memory_write("float", address + 0x1C, data["7"])
    memory_write("float", address + 0x20, data["8"])
end

function Utils.readMatrix4(address)
    local data = {}
    data["0"]  = memory_read("float", address + 0x00)
    data["1"]  = memory_read("float", address + 0x04)
    data["2"]  = memory_read("float", address + 0x08)
    data["3"]  = memory_read("float", address + 0x0C)
    data["4"]  = memory_read("float", address + 0x10)
    data["5"]  = memory_read("float", address + 0x14)
    data["6"]  = memory_read("float", address + 0x18)
    data["7"]  = memory_read("float", address + 0x1C)
    data["8"]  = memory_read("float", address + 0x20)
    data["9"]  = memory_read("float", address + 0x24)
    data["10"] = memory_read("float", address + 0x28)
    data["11"] = memory_read("float", address + 0x2C)
    data["12"] = memory_read("float", address + 0x30)
    data["13"] = memory_read("float", address + 0x34)
    data["14"] = memory_read("float", address + 0x38)
    data["15"] = memory_read("float", address + 0x3C)
    return data
end

function Utils.writeMatrix4(address, data)
    memory_write("float", address + 0x00, data["0"])
    memory_write("float", address + 0x04, data["1"])
    memory_write("float", address + 0x08, data["2"])
    memory_write("float", address + 0x0C, data["3"])
    memory_write("float", address + 0x10, data["4"])
    memory_write("float", address + 0x14, data["5"])
    memory_write("float", address + 0x18, data["6"])
    memory_write("float", address + 0x1C, data["7"])
    memory_write("float", address + 0x20, data["8"])
    memory_write("float", address + 0x24, data["9"])
    memory_write("float", address + 0x28, data["10"])
    memory_write("float", address + 0x2C, data["11"])
    memory_write("float", address + 0x30, data["12"])
    memory_write("float", address + 0x34, data["13"])
    memory_write("float", address + 0x38, data["14"])
    memory_write("float", address + 0x3C, data["15"])
end

function Utils.readCFrame(address)
    local cframe = {}

    cframe.rotation = Utils.readMatrix3(address)
    cframe.position = Utils.readVector3(address + 0x24)  -- foreced offset cause fuckass website offset is wrong

    return cframe
end

function GHDev.writeCFrame(address, cframe)
    Utils.writeMatrix3(address, cframe.rotation)
    Utils.writeVector3(address + 0x24, cframe.position) -- foreced offset cause fuckass website offset is wrong
end


function GHDev.getLookVector(matrix3)
    local vec = Vector3.new(0, 0, 0)
    vec.x = matrix3["2"]
    vec.y = matrix3["5"]
    vec.z = matrix3["8"]
    return vec * -1
end

function GHDev.getRightVector(matrix3)
    local vec = Vector3.new(0, 0, 0)
    vec.x = matrix3["0"]
    vec.y = matrix3["3"]
    vec.z = matrix3["6"]
    return vec
end

function GHDev.getUpVector(matrix3)
    local vec = Vector3.new(0, 0, 0)
    vec.x = matrix3["1"]
    vec.y = matrix3["4"]
    vec.z = matrix3["7"]
    return vec
end

function Utils.printVector3(vector3)
    print("Vector3(" .. vector3.x .. ", " .. vector3.y .. ", " .. vector3.z .. ")")
end

function Utils.printMatrix3(matrix3)
    print("Matrix3(" .. matrix3["0"] .. ", " .. matrix3["1"] .. ", " .. matrix3["2"] .. ", " .. matrix3["3"] .. ", " .. matrix3["4"] .. ", " .. matrix3["5"] .. ", " .. matrix3["6"] .. ", " .. matrix3["7"] .. ", " .. matrix3["8"] .. ")")
end

function Utils.printMatrix4(matrix4)
    print("Matrix4(" .. matrix4["0"]  .. ", " .. matrix4["1"]  .. ", " .. matrix4["2"]  .. ", " .. matrix4["3"]  .. ", " .. matrix4["4"]  .. ", " .. matrix4["5"]  .. ", " .. matrix4["6"]  .. ", " .. matrix4["7"]  .. ", " .. matrix4["8"]  .. ", " .. matrix4["9"]  .. ", " .. matrix4["10"] .. ", " .. matrix4["11"] .. ", " .. matrix4["12"] .. ", " .. matrix4["13"] .. ", " .. matrix4["14"] .. ", " .. matrix4["15"] .. ")")
end

function Utils.printCFrame(cframe)
    local pos = cframe.position
    local rot = cframe.rotation
    print("CFrame(Position: (" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. "), " .. "Rotation: (" .. rot["0"] .. ", " .. rot["1"] .. ", " .. rot["2"] .. ", " .. rot["3"] .. ", " .. rot["4"] .. ", " .. rot["5"] .. ", " .. rot["6"] .. ", " .. rot["7"] .. ", " .. rot["8"] .. "))")
end




function GHDev.getPartPosition(part)
    if part and part.Parent then
        return GHDev.Utils.readVector3(GHDev.Utils.getPrimitive(part) + getOffset("Position"))
    end
end

function GHDev.setPartPosition(part, pos)
    if part and part.Parent then
        GHDev.Utils.writeVector3(GHDev.Utils.getPrimitive(part) + getOffset("Position"), pos)
    end
end

function GHDev.getPartSize(part)
    if part and part.Parent then
        return GHDev.Utils.readVector3(GHDev.Utils.getPrimitive(part) + 0x1cc) -- foreced offset cause fuckass website offset is wrong
    end
end

function GHDev.setPartSize(part, size)
    if part and part.Parent then
        GHDev.Utils.writeVector3(GHDev.Utils.getPrimitive(part) + 0x1cc, size) -- foreced offset cause fuckass website offset is wrong
    end
end

function GHDev.getPartRotation(part)
    if part and part.Parent then
        return GHDev.Utils.readMatrix3(GHDev.Utils.getPrimitive(part) + 0xf8) -- foreced offset cause fuckass website offset is wrong
    end
end

function GHDev.setPartRotation(part, rot)
    if part and part.Parent then
        GHDev.Utils.writeMatrix3(GHDev.Utils.getPrimitive(part) + 0xf8, rot) -- foreced offset cause fuckass website offset is wrong
    end
end



function GHDev.getPartCFrame(part)
    if part and part.Parent then
        return GHDev.Utils.readCFrame(GHDev.Utils.getPrimitive(part) + 0xf8) -- foreced offset cause fuckass website offset is wrong
    end
end

function GHDev.setPartCFrame(part, CFrame)
    if part and part.Parent then
        GHDev.Utils.writeCFrame(GHDev.Utils.getPrimitive(part) + 0xf8, CFrame) -- foreced offset cause fuckass website offset is wrong
    end
end

return GHDev






-- example usecase
local player = game.Players.LocalPlayer
local line = Drawing.new("Line")
line.Color = Color3.fromRGB(0, 255, 0)
line.Visible = true

while true do
    local char = player.Character
    if char and char.Parent then
        local head = char.Head
        if head and head.Parent then
            print("asd")
            local cf = GHDev.getPartCFrame(head)
            local rot = cf.rotation
            local pos = cf.position
            GHDev.Utils.printCFrame(cf)
            local lookVec = GHDev.getLookVector(rot)
            local pos1, vis1 = WorldToScreen(pos)
            local pos2, vis2 = WorldToScreen(pos + lookVec)
            if vis1 and vis2 and pos1 and pos2 then
                line.From = pos1
                line.To = pos2
                print("hi...")
                
            end
        end
    end
    wait(0.01)
end
