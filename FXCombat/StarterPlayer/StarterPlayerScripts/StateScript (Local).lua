
local Storage = game:GetService("ReplicatedStorage")

local States = {
	["Controls"] = function(Value)
		local controls = require(game:GetService("Players").LocalPlayer.PlayerScripts.PlayerModule):GetControls();
		if Value == true then
			game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").AssemblyLinearVelocity += game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.UpVector*5;
			game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RequiresNeck = false;
			game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Physics);
			controls:Disable();
			return;
		end 
		controls:Enable();
		game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RequiresNeck = true;
		game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.GettingUp);
	end,
}

Storage.State.OnClientEvent:Connect(function(State,Value)
	States[State](Value);
end)