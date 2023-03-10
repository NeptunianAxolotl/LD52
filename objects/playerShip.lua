
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
	
	SoundHandler.PlaySound("enemy_bullet")
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
	self.def.density = 5
	
	local coords = {{-0.4, 0.35}, {-0.4, -0.35}, {-0.1, -0.35}, {0.6, -0.05}, {0.6, 0.05}, {-0.1, 0.35}}
	local scaleFactor = 84
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
	
	self.body:setAngularDamping(9.6)
	self.body:setUserData(self)
	self.fixture:setFriction(0.45)
	
	self.shootCooldown = 0
	self.bulletStock = Global.BULLET_STOCKPILE
	self.restockCooldown = Global.BULLET_RECHARGE
	
	if self.def.velocity then
		self.body:setLinearVelocity(self.def.velocity[1], self.def.velocity[2])
	end
	
	function self.GetBody()
		return self.body
	end
	
	function self.ApplyStasis(effect)
		self.stasisProgress = 0
		self.stasisEffect = effect
	end
	
	function self.GetSpeedMod()
		if not self.stasisProgress then
			return 1
		end
		return 1 - (1 - self.stasisProgress * self.stasisProgress) * self.stasisEffect.accelReduce
	end
	
	function self.TurnMod()
		if not self.stasisProgress then
			return 1
		end
		return 1 - (1 - self.stasisProgress * self.stasisProgress) * self.stasisEffect.turnReduce
	end
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		
		self.body:setLinearDamping(0)
		TerrainHandler.UpdateSpeedLimit(self.body)
	
		TerrainHandler.WrapBody(self.body)
		TerrainHandler.ApplyGravity(self.body)
		
		local vx, vy = self.body:getLinearVelocity()
		local speed = math.sqrt(vx*vx + vy*vy)
		local buildTurnRamp = false
		
		self.drawMove = {}
		if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
			SoundHandler.PlaySoundAutoLoop("accelerate_a")
			self.thrustDrawRamp = math.min(1, (self.thrustDrawRamp or 0.3) + 15*dt)
			self.drawMove[#self.drawMove + 1] = {"p_thrust", self.thrustDrawRamp}
			buildTurnRamp = true
			local angle = self.body:getAngle()
			local accel = Global.ACCEL_MULT * (2 - speed / (speed + 120)) * self.GetSpeedMod()
			local forceVec = util.PolarToCart(accel, angle)
			self.body:applyForce(forceVec[1], forceVec[2])
		elseif self.thrustDrawRamp then
			SoundHandler.StopSound("accelerate_a")
			self.thrustDrawRamp = self.thrustDrawRamp - 18*dt
			if self.thrustDrawRamp < 0.3 then
				self.thrustDrawRamp = false
			else
				self.drawMove[#self.drawMove + 1] = {"p_thrust", self.thrustDrawRamp}
			end
		else
			SoundHandler.StopSound("accelerate_a")
		end
		
		if self.bulletStock < Global.BULLET_STOCKPILE then
			if self.restockCooldown >= 0 then
				self.restockCooldown = self.restockCooldown - dt
			end
			if self.restockCooldown < 0 then
				self.restockCooldown = Global.BULLET_RECHARGE
				self.bulletStock = self.bulletStock + 1
			end
		end
		if self.shootCooldown >= 0 then
			self.shootCooldown = self.shootCooldown - dt
		end
		if self.shootCooldown < 0 and self.bulletStock > 0 and 
				(love.keyboard.isDown("space") or love.keyboard.isDown("return") or love.keyboard.isDown("kpenter") or love.keyboard.isDown("z")) then
			if TerrainHandler.CanShoot() then
				SpawnBullet(physicsWorld, self.body)
				self.shootCooldown = Global.SHOOT_COOLDOWN
				self.bulletStock = self.bulletStock - 1
			end
		end
		
		local emergencyStop = CheckEmergencyStop(physicsWorld, self.body)
		if emergencyStop or love.keyboard.isDown("s") or love.keyboard.isDown("down") or love.keyboard.isDown("x") or love.keyboard.isDown("kp0") then
			SoundHandler.PlaySoundAutoLoop("brake_a")
			self.drawMove[#self.drawMove + 1] = "p_slow"
			buildTurnRamp = true
			local vx, vy = self.body:getLinearVelocity()
			local force = -1 * Global.BRAKE_MULT * self.GetSpeedMod()
			if emergencyStop then
				force = -1 * Global.EMERGENCY_BRAKE_MULT
			end
			local forceVec = util.Mult(force, util.Unit({vx, vy}))
			self.body:applyForce(forceVec[1], forceVec[2])
			self.body:setLinearDamping(Global.BRAKE_DAMPEN)
		else
			SoundHandler.StopSound("brake_a")
		end
		
		local turnAmount = false
		if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
			self.drawMove[#self.drawMove + 1] = "p_left"
			turnAmount = -1
		elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
			self.drawMove[#self.drawMove + 1] = "p_right"
			turnAmount = 1
		end
		if turnAmount or buildTurnRamp then
			self.turnRamp = math.min(1, (self.turnRamp or 0) + 8*dt)
		else
			self.turnRamp = 0
		end
		
		if turnAmount then
			local vx, vy = self.body:getLinearVelocity()
			local speed = util.Dist(0, 0, vx, vy)
			turnAmount = (0.9 * self.turnRamp + 0.1) * turnAmount 
			turnAmount = turnAmount * math.max(Global.MIN_TURN, Global.TURN_MULT * (0.15 + 0.85 * (1 - speed / (speed + 750)))) * self.TurnMod()
			self.body:applyTorque(turnAmount)
		end
		
		if self.stasisProgress then
			self.stasisProgress = self.stasisProgress + dt / self.stasisEffect.duration
			if self.stasisProgress > 1 then
				self.stasisProgress = false
				self.stasisEffect = false
			end
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=1; f=function()
			love.graphics.push()
				local x, y = self.body:getWorldCenter()
				local angle = self.body:getAngle()
				local alpha = TerrainHandler.GetWrapAlpha(x, y)
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				
				for i = 1, #self.drawMove do
					if type(self.drawMove[i]) == "table" then
						Resources.DrawImage(self.drawMove[i][1], 0, 0, 0, alpha, scaleFactor * self.drawMove[i][2])
					else
						Resources.DrawImage(self.drawMove[i], 0, 0, 0, alpha, scaleFactor)
					end
				end
				Resources.DrawImage("ship", 0, 0, 0, alpha, scaleFactor)
				if self.stasisProgress then
					Resources.DrawImage("stasis", 0, 0, 0, alpha * 0.5 * (1 - self.stasisProgress * self.stasisProgress), scaleFactor)
				end
				
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
