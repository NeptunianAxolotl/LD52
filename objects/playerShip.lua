
local Resources = require("resourceHandler")
local Font = require("include/font")

local function GetStopVectors(body)
	local bx, by = body:getWorldCenter()
	local vx, vy = body:getLinearVelocity()

	local pos = {bx, by}
	local vel = {vx, vy}
	local travel, speed = util.Unit(vel)
	local tooShort = (speed < 250)
	
	local leftStart = util.Add(pos, util.RotateVector(util.Mult(30, travel), 0.5*math.pi))
	local leftEnd = util.Add(leftStart, util.Mult(0.3, vel))
	
	local rightStart = util.Add(pos, util.RotateVector(util.Mult(30, travel), -0.5*math.pi))
	local rightEnd = util.Add(rightStart, util.Mult(0.3, vel))
	
	return leftStart, leftEnd, rightStart, rightEnd, tooShort
end

local function SpawnBullet(physicsWorld, body)
	local bx, by = body:getWorldCenter()
	local vx, vy = body:getLinearVelocity()
	local angle = body:getAngle()
	
	local spawnPos = util.Add({bx, by}, util.PolarToCart(70, angle))
	local spawnVel = util.Add({vx, vy}, util.PolarToCart(Global.SHOOT_SPEED, angle))
	local recolForce = util.PolarToCart(-120, angle)
	
	body:applyForce(recolForce[1], recolForce[2])
	
	local bulletData = {
		pos = spawnPos,
		velocity = spawnVel,
		typeName = "player_bullet",
	}
	EnemyHandler.AddBullet(bulletData)
end

local function CheckEmergencyStop(physicsWorld, body)
	local leftStart, leftEnd, rightStart, rightEnd, tooShort = GetStopVectors(body)
	if tooShort then
		return false
	end
	local wantStop = false
	local function CheckRay(fixture)
		if wantStop then
			return -1
		end
		local userData = fixture:getBody():getUserData()
		if userData and userData.objType == "planet" or userData.objType == "sun" then
			wantStop = true
			return 0
		end
		return -1
	end
	physicsWorld:rayCast(leftStart[1], leftStart[2], leftEnd[1], leftEnd[2], CheckRay)
	if not wantStop then
		physicsWorld:rayCast(rightStart[1], rightStart[2], rightEnd[1], rightEnd[2], CheckRay)
	end
	return wantStop
end

local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	self.objType = "playerShip"
	
	local coords = {{-0.4, 0.35}, {-0.4, -0.35}, {-0.1, -0.35}, {0.6, -0.05}, {0.6, 0.05}, {-0.1, 0.35}}
	local scaleFactor = 50*1.4*1.2
	local modCoords = {}
	for i = 1, #coords do
		local pos = util.Mult(scaleFactor, coords[i])
		modCoords[#modCoords + 1] = pos[1]
		modCoords[#modCoords + 1] = pos[2]
		coords[i] = pos
	end
	
	self.body = love.physics.newBody(physicsWorld, self.def.pos[1], self.def.pos[2], "dynamic")
	self.shape = love.physics.newPolygonShape(unpack(modCoords))
	self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density)
	
	self.body:setAngularDamping(9)
	self.body:setUserData(self)
	self.fixture:setFriction(0.45)
	
	self.shootCooldown = 0
	
	if self.def.velocity then
		self.body:setLinearVelocity(self.def.velocity[1], self.def.velocity[2])
	end
	
	function self.GetBody()
		return self.body
	end
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		
		self.body:setLinearDamping(0)
		TerrainHandler.UpdateSpeedLimit(self.body)
	
		TerrainHandler.WrapBody(self.body)
		TerrainHandler.ApplyGravity(self.body)
		
		if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
			local angle = self.body:getAngle()
			local forceVec = util.PolarToCart(Global.ACCEL_MULT, angle)
			self.body:applyForce(forceVec[1], forceVec[2])
		end
		
		if self.shootCooldown >= 0 then
			self.shootCooldown = self.shootCooldown - dt
		end
		if self.shootCooldown < 0 and (love.keyboard.isDown("space") or love.keyboard.isDown("return") or love.keyboard.isDown("kpenter")) then
			SpawnBullet(physicsWorld, self.body)
			self.shootCooldown = Global.SHOOT_COOLDOWN
		end
		
		local emergencyStop = CheckEmergencyStop(physicsWorld, self.body)
		if emergencyStop or love.keyboard.isDown("s") or love.keyboard.isDown("down") then
			local vx, vy = self.body:getLinearVelocity()
			local force = -1 * Global.BRAKE_MULT
			if emergencyStop then
				force = -1 * Global.EMERGENCY_BRAKE_MULT
			end
			local forceVec = util.Mult(force, util.Unit({vx, vy}))
			self.body:applyForce(forceVec[1], forceVec[2])
			self.body:setLinearDamping(Global.BRAKE_DAMPEN)
		end
		
		local turnAmount = false
		if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
			turnAmount = -1
		elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
			turnAmount = 1
		end
		if turnAmount then
			local vx, vy = self.body:getLinearVelocity()
			local speed = util.Dist(0, 0, vx, vy)
			turnAmount = turnAmount * math.max(Global.MIN_TURN, Global.TURN_MULT * (0.15 + 0.85 * (1 - speed / (speed + 750))))
			self.body:applyTorque(turnAmount)
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=0; f=function()
			love.graphics.push()
				local x, y = self.body:getWorldCenter()
				local angle = self.body:getAngle()
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				
				Resources.DrawImage("ship", 0, 0, 0, false, self.def.radius)
				
			love.graphics.pop()
			
			if Global.DRAW_PHYSICS then
				love.graphics.push()
					x, y = self.body:getWorldCenter()
					love.graphics.translate(x, y)
					love.graphics.rotate(angle)
					love.graphics.setColor(1, 1, 1, 1)
					
					local lx, ly = self.body:getLocalCenter()
					
					for i = 1, #coords do
						local other = coords[(i < #coords and (i + 1)) or 1]
						love.graphics.line(coords[i][1] - lx, coords[i][2] - ly, other[1] - lx, other[2] - ly)
					end
				love.graphics.pop()
				
				local leftStart, leftEnd, rightStart, rightEnd = GetStopVectors(self.body)
				love.graphics.line(leftStart[1], leftStart[2], leftEnd[1], leftEnd[2])
				love.graphics.line(rightStart[1], rightStart[2], rightEnd[1], rightEnd[2])
			end
			
		end})
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return New
