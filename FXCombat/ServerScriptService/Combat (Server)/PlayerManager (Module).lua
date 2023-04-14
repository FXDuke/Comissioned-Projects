-- Written by FXDuke#0001
--[[
		
		HOW TO ADD A NEW STATE:
		
		Put this in __Player.Combat - 
		State Name = {
			State(bool): 		The "State" of the State, for cooldown abilities this will be true until the cooldown is over
			Active(bool): 		This is for cooldown abilities like parry or dodge, this is true until the duration of the ability is over
			Duration(float):	This is for cooldown abilities like parry or dodge, this is how long the ability's effects last
			Cooldown(float):	This is for cooldown abilities like parry or dodge, this is how long until you can use the ability again (AFTER THE DURATION HAS ENDED)
		},
		
		Put this in CooldownStates (for abilities with cooldowns) - 
		
		["State Name"] = false/true, : This means the ability will be activated when the state is set to false/true.
		
		Put this in ChangeState_Events - 
		
		["State Name"] = function(PlayerData,Value)
		
		end,
		PlayerData is the Player's __Player data and the value is the State's value or the State's Active value,
]]

-- Player Object

__Player = {
	
	-- Player Variables
	
	Instance = nil,	 -- Player Instance
	UserId = nil,	 -- Player.UserId
	Character = nil, -- Player.Character (updates automatically)
	
	-- Data
	
	Spawned = false, -- if the character is spawned in or not 
	Danger = false,  -- when true prevents healing
	DangerTimer = 0, -- how long until danger is removed
	
	-- Stats
	
	Health = 0,
	MaxHealth = 0,
	
	-- Combat
	
	States = {
		ChipDamage = 0.105, -- 10/95
		Dodging = {
			State = false,
			Active = false,
			Duration = 0.5;
			Cooldown = 1.5,
		},
		Parrying = {
			State = false,
			Active = false,
			Duration = 0.5,
			Cooldown = 2,
		},
		Blocking = {
			State = false,
			Active = false,
			Duration = 0,
			Cooldown = 0,
		},
		Knocked = {
			State = false,
			Active = false,
			Duration = 15,
			Cooldown = 0,
		},
		Stunned = {
			State = false,
			Active = false,
			Duration = 0.5,
			Cooldown = 0,
		},
		Attack = {
			Index = 0,
			MaxIndex = 5,
			WeaponType = "Fist",
			State = false,
			Cooldown = 0.2,
			SwingRange = 7.5, -- CIRCULAR RADIUS. (PositionX^2+PositionY^2 <= SwingRange^2) NEEDS TO BE TRUE FOR HIT.
		},
	},
	
	
};

-- Variables

local CooldownStates = {
	["Blocking"] = false,
	["Dodging"] = true,
	["Parrying"] = true,
	["Knocked"] = true,
}

-- Callable Functions

local ChangeState_Events = {
	["Stunned"] = function(PlayerData,Value)	
		PlayerData.Instance.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = (Value) and 1 or 16;
	end,	
	["Parrying"] = function(PlayerData,Value)
		-- put call here for when parry frames are enabled and disabled
	end,
	["Blocking"] = function(PlayerData,Value)
		-- put call here for when blocking is enabled and disabled
	end,
	["Dodging"] = function(PlayerData,Value)
		if not Value then return end;
		local BodyVelocity = Instance.new("BodyVelocity");
		BodyVelocity.P = math.huge;
		BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge);
		BodyVelocity.Velocity = (Vector3.new(PlayerData.Character.HumanoidRootPart.Velocity.X,0,PlayerData.Character.HumanoidRootPart.Velocity.Z) * 6);
		task.spawn(function()
			while BodyVelocity do 
				local dt = wait();
				BodyVelocity.Velocity -= Vector3.new(dt,0,dt);
			end
		end)
		BodyVelocity.Parent = PlayerData.Character.HumanoidRootPart;
		game.Debris:AddItem(BodyVelocity, 0.20);
	end,
	["Knocked"] = function(PlayerData,Value)
		
		if Value == true then 
			for _, Part in pairs(PlayerData.Character:GetDescendants()) do  --ragdoll
				if Part:IsA("Motor6D") then
				
					local Attachment0, Attachment1 = Instance.new("Attachment"), Instance.new("Attachment");
					Attachment0.CFrame = Part.C0;
					Attachment1.CFrame = Part.C1;
					Attachment0.Parent = Part.Part0;
					Attachment1.Parent = Part.Part1;
					local BallConstraint = Instance.new("BallSocketConstraint");
					BallConstraint.Attachment0 = Attachment0;
					BallConstraint.Attachment1 = Attachment1;
					BallConstraint.Parent = Part.Part0;
					Part.Enabled = false;
					
				end
			end
			game:GetService("ReplicatedStorage").State:FireClient(PlayerData.Instance,"Controls",true);
			return;
		end
		for _,Part in pairs(PlayerData.Character:GetDescendants()) do  --unragdoll
			if Part:IsA('Motor6D') then
				Part.Enabled = true;
			end
			if Part.Name == 'BallSocketConstraint' or Part.Name == 'Attachment' then
				Part:Destroy();
			end
		end
		game:GetService("ReplicatedStorage").State:FireClient(PlayerData.Instance,"Controls",false);
	end,
};

-- Functions 

function __playerTable(Player)
	local Table = table.clone(__Player);

	Table.Instance = Player;
	Table.UserId = Player.UserId;

	return Table;
end

-- Main Script

PlayerManager = {
	AddPlayer = function(Player)
		PlayerManager.Players[Player.UserId] = __playerTable(Player);
		task.wait();
		Player.CharacterAdded:Connect(function(Character)
			PlayerManager.Players[Player.UserId].Character = Character;
			PlayerManager.Players[Player.UserId].Health = Character:FindFirstChildOfClass("Humanoid").MaxHealth;
			PlayerManager.Players[Player.UserId].MaxHealth = Character:FindFirstChildOfClass("Humanoid").MaxHealth;
			PlayerManager.Players[Player.UserId].Spawned = true;

			Character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
				PlayerManager.Players[Player.UserId].Spawned = false;
			end)
		end)
	end,
	RemovePlayer = function(Player)
		table.remove(PlayerManager.Players,Player.UserId);
	end,
	AnimatePlayer = function(UserId, AnimationName)
		PlayerManager.Players[UserId].Character:WaitForChild("ServerAnimate"):WaitForChild("Animate"):Invoke(AnimationName);
	end,
	CombatState = function(UserId) -- Returns True or False, True means they are able to be attacked and a table with combat values.
		task.wait();
		local PlayerObject = PlayerManager.Players[UserId];
		local Result = {
			State = true,
			Parrying = PlayerObject.States.Parrying.Active,
			Dodging = PlayerObject.States.Dodging.Active,
			Blocking = PlayerObject.States.Blocking.State,
			Knocked = PlayerObject.States.Knocked.Active,
			Stunned = PlayerObject.States.Stunned.State,
			ChipDamage = 1,
		};
		
		if (PlayerObject.States.Knocked.Active==true or PlayerObject.States.Dodging.Active==true or PlayerObject.States.Parrying.Active==true or PlayerObject.States.Blocking.State == true) then
			Result.State = false;
		end
		
		return Result;
	end,
	UpdateHealth = function(UserId,Change)
		local Health = PlayerManager.Players[UserId].Health+Change;
			
		if (Health<=0) then 
			Health = 1;
			PlayerManager.ChangeState(UserId,"Knocked",true);
		elseif (Health>PlayerManager.Players[UserId].MaxHealth) then
			Health = PlayerManager.Players[UserId].MaxHealth;
		end
			
		PlayerManager.Players[UserId].Health = Health;
	end,
	ChangeState = function(UserId,State,Value) -- States(string): "Blocking": Blocking, "Parrying": Parrying, "Dodging": Dodging, "Knocked": Knocked, "Stunned": Stunned
		if (State == "Stunned") then 
			ChangeState_Events["Stunned"](PlayerManager.Players[UserId],true);
			PlayerManager.Players[UserId].States.Stunned.State = true;
			PlayerManager.Players[UserId].States.Stunned.Duration = Value;
			return;
		end
		if (PlayerManager.Players[UserId].States[State].State ~= Value) then	
			if (CooldownStates[State] == Value) then -- Basically if its an ability with a cooldown
				if (State == "Blocking") then 
					task.spawn(function()
						ChangeState_Events["Parrying"](PlayerManager.Players[UserId],false);
						PlayerManager.Players[UserId].States.Parrying.Active = false;
						task.wait(PlayerManager.Players[UserId].States.Parrying.Cooldown);
						PlayerManager.Players[UserId].States.Parrying.State = false;
					end)
				end
				PlayerManager.Players[UserId].States[State].State = true;
				task.spawn(function()
					ChangeState_Events[State](PlayerManager.Players[UserId],true);
					PlayerManager.Players[UserId].States[State].Active = true;
					task.wait(PlayerManager.Players[UserId].States[State].Duration);
					ChangeState_Events[State](PlayerManager.Players[UserId],false);
					PlayerManager.Players[UserId].States[State].Active = false;
					task.wait(PlayerManager.Players[UserId].States[State].Cooldown);
					PlayerManager.Players[UserId].States[State].State = false;
				end)
			else 
				ChangeState_Events[State](PlayerManager.Players[UserId],Value);
				PlayerManager.Players[UserId].States[State].State = Value;
			end
		end
	end,
	PlayerDanger = function(UserId,Time)
		if PlayerManager.Players[UserId].Danger == false then 
			PlayerManager.Players[UserId].Danger = true;
			PlayerManager.Players[UserId].DangerTimer = Time;
		else
			PlayerManager.Players[UserId].DangerTimer = (PlayerManager.Players[UserId].DangerTimer+Time<180) and PlayerManager.Players[UserId].DangerTimer+Time or 180; -- Maximum danger time is 3 minutes
		end
	end,
	GetPlayer = function(UserId)
		return PlayerManager.Players[UserId];
	end,
	GetState = function(UserId,State)
		return {State=PlayerManager.Players[UserId].States[State].State,Active=PlayerManager.Players[UserId].States[State].Active};
	end,
	Players = {},	
};

-- Add Current Players

for _,PlayerInstance in pairs(game:GetService("Players"):GetPlayers()) do 
	PlayerManager.AddPlayer(PlayerInstance);
end

-- Threaded Functions

game:GetService("Players").PlayerAdded:Connect(PlayerManager.AddPlayer);
game:GetService("Players").PlayerRemoving:Connect(PlayerManager.RemovePlayer);

game:GetService("RunService").Heartbeat:Connect(function(DeltaTime)
	for _,PlayerObject in pairs(PlayerManager.Players) do
		if (PlayerObject.Spawned == true and PlayerObject.Instance.Character) then
			PlayerObject.Instance.Character:FindFirstChildOfClass("Humanoid").Health = PlayerObject.Health;
		end
		if PlayerObject.Danger then 
			PlayerObject.DangerTimer -= DeltaTime;
			if 0>=PlayerObject.DangerTimer then
				PlayerObject.Danger = false;
				PlayerObject.DangerTimer = 0;
			end
		end
		if PlayerObject.States.Stunned.State == true then 
			PlayerObject.States.Stunned.Duration -= DeltaTime;
			if 0>=PlayerObject.States.Stunned.Duration then
				ChangeState_Events["Stunned"](PlayerObject,false);
				PlayerManager.AnimatePlayer(PlayerObject.UserId,"Stunned");
				PlayerObject.States.Stunned.State = false;
				PlayerObject.States.Stunned.Duration = 0;
			end
		end
	end
end)

return PlayerManager;
