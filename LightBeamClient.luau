--!native
--- [ Script by BlearDev ] ---


--- [ SERVICES ] ---
local PlayersService = game:GetService('Players')
local RunService = game:GetService('RunService')


--- [ LOCAL VALUES ] ---
local LocalPlayer = PlayersService.LocalPlayer
local PlayerCamera = workspace.CurrentCamera


--- [ OBJECT ] ---
local LightBeamClient = { }
LightBeamClient.__index = LightBeamClient


--- [ METHODS ] ---
function LightBeamClient.new( SpotLight : SpotLight, LightBeam : Attachment )
	-- Object
	local self = setmetatable( {}, LightBeamClient )
	
	-- Values
	self.Connections = {}
	self.Light = SpotLight
	self.LightAttachment = LightBeam
	self.BeamAttachment = self.LightAttachment:WaitForChild('BeamAttachment')
	self.LightBeam = self.LightAttachment:WaitForChild('LightBeam')
	self.GlowSprite = self.LightAttachment:WaitForChild('GlowSprite')
	
	-- Setup
	self.LightAttachment.Parent = self.Light.Parent
	self:UpdateAppearance()
	self:FormConnections()
	
	return self
end

-- When fired, this updates the LightBeam and GlowSprites Transparency based on the angle difference between the SpotLight and Camera.
function LightBeamClient:Update( )
	-- Get the current CFrame of the Light to later be used in dot projection.
	local LightCFrame = CFrame.new( Vector3.zero )

	if self.Light.Parent:IsA('BasePart') then
		LightCFrame = self.Light.Parent.CFrame
	elseif self.Light.Parent:IsA('Attachment') then
		LightCFrame = self.Light.Parent.WorldCFrame
	end

	-- Compare the Direction of the Light and PlayerCamera to know from what angle the Light is being viewed from.
	local LightDirection = LightCFrame.LookVector
	LightDirection = Vector3.new( math.clamp(LightDirection.X, -1, 1), math.clamp(LightDirection.Y, -1, 1), math.clamp(LightDirection.Z, -1, 1) )
	
	local CameraDirection = ( LightCFrame.Position - PlayerCamera.CFrame.Position ).Unit
	local LightDot = LightDirection:Dot( CameraDirection )

	-- Apply LightDot to the LightBeam effect to provent the effect from looking strange at different angles but also make it look better.
	self.GlowSprite.GlowImage.ImageTransparency = math.clamp( LightDot * 1, 0, 1 )
	self.LightBeam.Transparency = NumberSequence.new( { 
		NumberSequenceKeypoint.new( 0, 1 ), 
		NumberSequenceKeypoint.new( 0.1, math.abs( LightDot * 1.133 ) ), 
		NumberSequenceKeypoint.new( 1, 1 ), 
	} )
	
	-- Check if BeamCollision is enabled, then use a Raycast(Might change to a BoxCast in the future) to try and disallow the LightBeam from going through walls, floors, etc.
	if self.BeamCollision then
		
	end
end

-- When fired, this updates the LightBeam's and GlowSprite's Color, Facing Angle, and even if they are toggled on and off based on the state of the SpotLight.
function LightBeamClient:UpdateAppearance( )
	-- Toggle the LightBeam and GlowSprite On/Off based on if the SpotLight is On or Off.
	self.LightBeam.Enabled = self.Light.Enabled
	self.GlowSprite.Enabled = self.Light.Enabled
	
	-- Change the Colors of the LightBeam and GlowSprite to the Color of the SpotLight.
	self.LightBeam.Color = ColorSequence.new( {
		ColorSequenceKeypoint.new( 0, self.Light.Color ), 
		ColorSequenceKeypoint.new( 1, self.Light.Color )
	})
	self.GlowSprite.GlowImage.ImageColor3 = self.Light.Color
	
	
	
	-- BeamDistance: Update the direction of the LightBeam to make sure it faces the same way the Angle of the SpotLight faces.
	self.BeamAttachment.CFrame = CFrame.new( Vector3.new( 0, 0, -1 ) * self.BeamDistance )
end

--When fired, form all connections for the LightBeam Object.
function LightBeamClient:FormConnections( )
	
	-- Light Toggled On/Off
	self.Connections['LightToggled'] = self.Light:GetPropertyChangedSignal('Enabled'):Connect(function()
		self:UpdateAppearance()
	end)
	
	-- Light Color Changed
	self.Connections['ColorChanged'] = self.Light:GetPropertyChangedSignal('Color'):Connect(function()
		self:UpdateAppearance()
	end)
	
	-- Light Face Changed
	self.Connections['ColorChanged'] = self.Light:GetPropertyChangedSignal('Face'):Connect(function()
		self:UpdateAppearance()
	end)
	
	-- Main Update Loop
	self.Connections['RenderStepped'] = RunService.RenderStepped:Connect(function( DeltaTime : number )
		if not self.Light.Enabled then return end
		self:Update()
	end)
	
end

function LightBeamClient:DisconnectConnections( )
	if not self.Connections then return end

	for ConnectionName, _ in pairs( self.Connections ) do
		self.Connections[ConnectionName]:Disconnect()
		self.Connections[ConnectionName] = nil
	end
end

function LightBeamClient:Destory( )
	self:DisconnectConnections()
	self.LightAttachment:Remove()
end

return LightBeamClient
