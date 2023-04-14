local function PartBehind(Part1,Part2)
	local Forward,Backward = (Part1.CFrame + Part1.CFrame.LookVector),(Part1.CFrame + Part1.CFrame.LookVector*-1);
	local ForwardMagnitude,BackwardMagnitude = (Forward.Position-Part2.Position).Magnitude,(Backward.Position-Part2.Position).Magnitude;
	return not (ForwardMagnitude <= BackwardMagnitude);
end

local Weapon_Types = {
	["Fist"] = { -- make the name what you made the name for WeaponType in the __Player object
		[1] = { -- mouse 1
			[1] = "Punch1", -- whatever the name is for the animation in the animations folder put it here in order	
			[2] = "Punch2",	
			[3] = "Punch3",	
			[4] = "Punch4",	
			[5] = "Punch5",	
		},
		[2] = { -- mouse 2
			[1] = "M2",	
		},
	},
};

local Manager = require(script.PlayerManager);
local Storage = game:GetService("ReplicatedStorage");

Storage.Input.OnServerEvent:Connect(function(Player,Input,Processed,Began)
	if (Processed == false) then
		if (Input == Enum.KeyCode.F) then 
			if (Began == true) then 
				Manager.ChangeState(Player.UserId,"Parrying",true);
			end
			Manager.GetPlayer(Player.UserId).Instance.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = (Began) and 5 or 16;
			Manager.AnimatePlayer(Player.UserId,"Block");
			Manager.ChangeState(Player.UserId,"Blocking",Began);
		elseif (Input == Enum.KeyCode.Q and Began) then 
			Manager.ChangeState(Player.UserId,"Dodging",true);
		end
	end
end)

Storage.Mouse.OnServerEvent:Connect(function(Player,Type,Began)
	local Success1, Failure = pcall(function()
		local PlayerData = Manager.GetPlayer(Player.UserId);
		if (Began == true and PlayerData.States.Attack.State == false and PlayerData.States.Blocking.State==false and PlayerData.States.Parrying.Active==false and PlayerData.States.Stunned.State==false) then 
			
			Manager.Players[Player.UserId].States.Attack.State = true;
			Manager.Players[Player.UserId].States.Attack.Index = (Manager.Players[Player.UserId].States.Attack.Index<Manager.Players[Player.UserId].States.Attack.MaxIndex) and Manager.Players[Player.UserId].States.Attack.Index+1 or 1;
			
			local Parried = false; 

			for _,xPlayer in pairs(Manager.Players) do
				if (xPlayer.UserId ~= Player.UserId and xPlayer.Spawned == true and Parried == false) then 
					local CombatInfo = Manager.CombatState(xPlayer.UserId);
					local VectorData = (PlayerData.Character.HumanoidRootPart.Position - xPlayer.Character.HumanoidRootPart.Position);
					if (VectorData.Magnitude <= PlayerData.States.Attack.SwingRange and PartBehind(PlayerData.Character.HumanoidRootPart,xPlayer.Character.HumanoidRootPart) == false) then
						if (CombatInfo.State == true) then
							local RayInfo = RaycastParams.new();
							RayInfo.IgnoreWater = true;
							RayInfo.FilterDescendantsInstances = {PlayerData.Character,xPlayer.Character};
							local Obstructed = workspace:Raycast(PlayerData.Character.HumanoidRootPart.Position,VectorData.Unit*PlayerData.States.Attack.SwingRange,RayInfo);
							if (not Obstructed.Instance) then 
								if (Manager.Players[Player.UserId].States.Attack.Index == Manager.Players[Player.UserId].States.Attack.MaxIndex or Type == Enum.UserInputType.MouseButton2) then
									local BodyVelocity = Instance.new("BodyVelocity");
									BodyVelocity.P = math.huge;
									BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge);
									BodyVelocity.Velocity = -(xPlayer.Character.HumanoidRootPart.CFrame.lookVector * 45);
									BodyVelocity.Parent = xPlayer.Character.HumanoidRootPart;
									game.Debris:AddItem(BodyVelocity, 0.5);
									Manager.UpdateHealth(xPlayer.UserId,-15*CombatInfo.ChipDamage);
									Manager.ChangeState(xPlayer.UserId,"Stunned",0.5);
									Manager.AnimatePlayer(xPlayer.UserId,"Knockback");
								end
								if (Type == Enum.UserInputType.MouseButton1 and Manager.Players[Player.UserId].States.Attack.Index < Manager.Players[Player.UserId].States.Attack.MaxIndex) then
									Manager.UpdateHealth(xPlayer.UserId,-10*CombatInfo.ChipDamage);
									Manager.ChangeState(xPlayer.UserId,"Stunned",0.5);
									Manager.AnimatePlayer(xPlayer.UserId,"Stunned");
								end
								Manager.PlayerDanger(xPlayer.UserId,30);
							end
						else
							if (CombatInfo.Parrying == true) then
								Parried = true;
							end
						end 
					end
				end
			end

			PlayerData.Instance.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 5;
			if (Parried == true) then
				Manager.ChangeState(Player.UserId,"Stunned",0.75);
				Manager.AnimatePlayer(PlayerData.UserId,"ParriedLeft");
			else 
				local PunchType = (Type == Enum.UserInputType.MouseButton2) and Weapon_Types[PlayerData.States.Attack.WeaponType][2][1] or Weapon_Types[PlayerData.States.Attack.WeaponType][1][Manager.Players[Player.UserId].States.Attack.Index];
				Manager.AnimatePlayer(PlayerData.UserId,PunchType);
			end
			PlayerData.Instance.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16;
			
			if (Manager.Players[Player.UserId].States.Attack.Index == Manager.Players[Player.UserId].States.Attack.MaxIndex or Type == Enum.UserInputType.MouseButton2) then
				Manager.Players[Player.UserId].States.Attack.Index = 0; 
				Manager.ChangeState(PlayerData.UserId,"Stunned",0.75);
			end
			
			task.spawn(function()
				task.wait(Manager.Players[Player.UserId].States.Attack.Cooldown);
				Manager.Players[Player.UserId].States.Attack.State = false;
			end)
		end
	end)
	if not Success1 then print(Failure) end
end)