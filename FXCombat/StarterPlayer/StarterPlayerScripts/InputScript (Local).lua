-- Written by FXDuke#0001

local Input = game:GetService("ReplicatedStorage").Input
local Mouse = game:GetService("ReplicatedStorage").Mouse

game:GetService("UserInputService").InputBegan:Connect(function(input,processed)
	Input:FireServer(input.KeyCode,processed,true);
end)

game:GetService("UserInputService").InputEnded:Connect(function(input,processed)
	Input:FireServer(input.KeyCode,processed,false);
end)

local _Mouse = game:GetService("Players").LocalPlayer:GetMouse()
_Mouse.Button1Up:Connect(function()
	Mouse:FireServer(Enum.UserInputType.MouseButton1,false)
end)
_Mouse.Button1Down:Connect(function()
	Mouse:FireServer(Enum.UserInputType.MouseButton1,true)
end)
_Mouse.Button2Up:Connect(function()
	Mouse:FireServer(Enum.UserInputType.MouseButton2,false)
end)
_Mouse.Button2Down:Connect(function()
	Mouse:FireServer(Enum.UserInputType.MouseButton2,true)
end)