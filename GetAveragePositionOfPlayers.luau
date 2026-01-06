--!strict

function GetAveragePositionOfPlayers( Players : SharedTable )
	local MinX, MaxX = math.huge, -math.huge
	local MinY, MaxY = math.huge, -math.huge
	local MinZ, MaxZ = math.huge, -math.huge
	
	for Index = 1, #Players, 1 do
		
		if Players[Index].Character then
			local CurrentPosition : Vector3 = Players[Index].Character:GetPivot().Position
			
			-- Min
			if CurrentPosition.X < MinX then MinX = CurrentPosition.X end
			if CurrentPosition.Y < MinY then MinY = CurrentPosition.Y end
			if CurrentPosition.Z < MinZ then MinZ = CurrentPosition.Z end

			-- Max
			if CurrentPosition.X > MaxX then MaxX = CurrentPosition.X end
			if CurrentPosition.Y > MaxY then MaxY = CurrentPosition.Y end
			if CurrentPosition.Z > MaxZ then MaxZ = CurrentPosition.Z end
			
		end
		
	end
	
	return Vector3.new( MinX, MinY, MinZ ):Lerp( Vector3.new( MaxX, MaxY, MaxZ ), 0.5 )
end

return GetAveragePositionOfPlayers
