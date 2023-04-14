

local Character = script.Parent;
local Animator = Character:WaitForChild("Humanoid"):WaitForChild("Animator");

local Animations = {};

for _,Animation in pairs(script.Animations:GetChildren()) do
	Animations[Animation.Name] = Animator:LoadAnimation(Animation);
end

local Active = {};

script.Animate.OnInvoke = function(Animation)
	if Active[Animation] == true then 
		Animations[Animation]:Stop();
		return;
	end
	Active[Animation] = true;
	Animations[Animation]:Play();
	Animations[Animation].Stopped:Wait();
	Active[Animation] = false;
	return;
end
