local rn = math.random(1,10000);
script.Parent.Credit.Value = script.Parent.Credit.Value .. "_" .. tostring(rn);

if script.Parent.Credit.Value == "FXDuke_" .. tostring(rn) then
	for _,Folder in pairs(script.Parent:GetChildren()) do
		if Folder:IsA("Folder") then 
			
			for _,Object in pairs(Folder:GetChildren()) do
				local Service = game:GetService(Folder.Name);
				if not Object:IsA("Folder") then
					local ObjectA = Object:Clone();
					ObjectA.Parent = Service;
					if not Object:IsA("RemoteEvent") then
						ObjectA.Enabled = true; 
					end
				else
					Service = Service[Object.Name];
					for _,Object2 in pairs(Object:GetChildren()) do
						if not Object2:IsA("Folder") then
							local ObjectA = Object2:Clone();
							ObjectA.Parent = Service;
							if not Object:IsA("RemoteEvent") then
								ObjectA.Enabled = true; 
							end
						end
					end
				end
			end
		end
	end
end

script:Destroy();