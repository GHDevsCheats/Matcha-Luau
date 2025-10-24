--!native

local Enum = {}
local function CreateEnumCategory(name, items)
    local category = {}
    local reverse = {}
    for k, v in pairs(items) do
        category[k] = v
        reverse[v] = k
    end
    function category:GetNameFromValue(value)
        return reverse[value]
    end
    Enum[name] = category
end
CreateEnumCategory("KeyCode", {
    A = 0x41,
    B = 0x42,
    C = 0x43,
    D = 0x44,
    E = 0x45,
    F = 0x46,
    G = 0x47,
    H = 0x48,
    I = 0x49,
    J = 0x4A,
    K = 0x4B,
    L = 0x4C,
    M = 0x4D,
    N = 0x4E,
    O = 0x4F,
    P = 0x50,
    Q = 0x51,
    R = 0x52,
    S = 0x53,
    T = 0x54,
    U = 0x55,
    V = 0x56,
    W = 0x57,
    X = 0x58,
    Y = 0x59,
    Z = 0x5A,
    Zero = 0x30,
    One = 0x31,
    Two = 0x32,
    Three = 0x33,
    Four = 0x34,
    Five = 0x35,
    Six = 0x36,
    Seven = 0x37,
    Eight = 0x38,
    Nine = 0x39,
    F1 = 0x70,
    F2 = 0x71,
    F3 = 0x72,
    F4 = 0x73,
    F5 = 0x74,
    F6 = 0x75,
    F7 = 0x76,
    F8 = 0x77,
    F9 = 0x78,
    F10 = 0x79,
    F11 = 0x7A,
    F12 = 0x7B,
    Up = 0x26,
    Down = 0x28,
    Left = 0x25,
    Right = 0x27,
    Shift = 0x10,
    Control = 0x11,
    Alt = 0x12,
    Space = 0x20,
    Enter = 0x0D,
    Escape = 0x1B,
    Tab = 0x09,
    Backspace = 0x08
})
CreateEnumCategory("UserInputType", {
    MouseButton1 = 0x01,
    MouseButton2 = 0x02,
    MouseButton3 = 0x04,
    MouseWheel = 0xFF01,
    MouseMove = 0xFF02,
    Keyboard = 0xFF03
})

local function Signal()
    local self = {
        Connections = {}
    }

    function self:Connect(fn)
        table.insert(self.Connections, fn)
        return {
            Disconnect = function()
                for i, f in ipairs(self.Connections) do
                    if f == fn then
                        table.remove(self.Connections, i)
                        break
                    end
                end
            end
        }
    end

    function self:Fire(...)
        for _, fn in ipairs(self.Connections) do
            fn(...)
        end
    end

    return self
end

local function MakeInputObject(keyCode, userInputType)
    return {
        KeyCode = keyCode,
        UserInputType = userInputType or Enum.UserInputType.Keyboard
    }
end

local UserInputService = {
    InputBegan = Signal(),
    InputEnded = Signal(),
    _keyStates = {},
    _keysToMonitor = {}
}

function UserInputService:RegisterMouseButton(mouseEnum)
    self._keysToMonitor[mouseEnum] = true
    self._keyStates[mouseEnum] = false
end

function UserInputService:RegisterKey(vk)
    self._keysToMonitor[vk] = true
    self._keyStates[vk] = false
end

function UserInputService:IsMouseButtonPressed(mouseEnum)
    return self._keyStates[mouseEnum] or false
end

function UserInputService:GetKeysPressed()
    local pressedKeys = {}
    for vk, pressed in pairs(self._keyStates) do
        if pressed then
            table.insert(pressedKeys, vk)
        end
    end
    return pressedKeys
end

function UserInputService:IsKeyDown(keycode)
    return self._keyStates[keycode] or false
end

function UserInputService:_Update()
    for vk in pairs(self._keysToMonitor) do
        local pressed

        if vk == Enum.UserInputType.MouseButton1 then
            pressed = ismouse1pressed()
        elseif vk == Enum.UserInputType.MouseButton2 then
            pressed = ismouse2pressed()
        elseif vk == Enum.UserInputType.MouseButton3 then
            pressed = iskeypressed(0x04)
        else
            pressed = iskeypressed(vk)
        end

        local wasPressed = self._keyStates[vk]

        if pressed and not wasPressed then
            self._keyStates[vk] = true
            local isMouseInput = vk == Enum.UserInputType.MouseButton1 or vk == Enum.UserInputType.MouseButton2 or vk ==
                                     Enum.UserInputType.MouseButton3 or vk == Enum.UserInputType.MouseWheel or vk ==
                                     Enum.UserInputType.MouseMove

            local inputType = isMouseInput and vk or Enum.UserInputType.Keyboard

            self.InputBegan:Fire(MakeInputObject(vk, inputType))

        elseif not pressed and wasPressed then
            self._keyStates[vk] = false
            local isMouseInput = vk == Enum.UserInputType.MouseButton1 or vk == Enum.UserInputType.MouseButton2 or vk ==
                                     Enum.UserInputType.MouseButton3 or vk == Enum.UserInputType.MouseWheel or vk ==
                                     Enum.UserInputType.MouseMove

            local inputType = isMouseInput and vk or Enum.UserInputType.Keyboard

            self.InputEnded:Fire(MakeInputObject(vk, inputType))
        end
    end
end

spawn(function()
    while true do
        UserInputService:_Update()
        wait(0.01)
    end
end)

--[[
examp usage:

UserInputService:RegisterKey(Enum.KeyCode.W)
UserInputService:RegisterMouseButton(Enum.UserInputType.MouseButton1)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        print("W key pressed")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        print('w key release')
    end
end)

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        print("Left mouse pressed")
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        print("Left mouse released")
    end
end)]]
