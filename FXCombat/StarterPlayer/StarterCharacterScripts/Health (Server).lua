
local Character = script.Parent
local Player = game.Players:GetPlayerFromCharacter(Character);
local Manager = require(game.ServerScriptService.Combat.PlayerManager);

while task.wait() do
	local Data = Manager.GetPlayer(Player.UserId);
	if Data.Health < Data.MaxHealth then
		if Data.Danger == false then 
			Manager.UpdateHealth(Player.UserId,wait()*(1/math.random(95,105))*Data.MaxHealth);
		end
	end
end