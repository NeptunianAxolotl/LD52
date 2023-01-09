
local Resources = require("resourceHandler")
local Font = require("include/font")

local ShipDefs = util.LoadDefDirectory("defs/ship")

local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	self.objType = "enemyShip"
	self.def = util.CopyTable(ShipDefs[self.def.typeName], false, self.def)
	
	local modCoords = {}
	self.coords = {}
	for i = 1, #self.def.coords do
		local pos = util.Mult(self.def.scaleFactor, self.def.coords[i])
		modCoords[#modCoords + 1] = pos[1]
		modCoords[#modCoords + 1] = pos[2]
		self.coords[i] = pos
	end
	
	self.body = love.physics.newBody(physicsWorld, self.def.pos[1], self.def.pos[2], "dynamic")
	self.shape = love.physics.newPolygonShape(unpack(modCoords))
	self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density)
	
	self.body:setAngularDamping(self.def.angleDampen)
	self.body:setUserData(self)
	self.fixture:setFriction(0.45)
	
	self.damage = 0
	self.dodgeAngle = (math.random() < 0.6 and 1.5) or -1.5
	
	function self.GetBody()
		return self.body
	end
	
	function self.Destroy(doSplit)
		if self.isDead then
			return
		end
		local bx, by = self.body:getWorldCenter()
		for i = 1, 12 do
			EffectsHandler.SpawnEffect(
				"fireball_explode",
				util.Add({bx, by}, util.RandomPointInCircle(self.def.scaleFactor*0.6)),
				{
					delay = math.random()*0.2,
					scale = 0.15 + 0.2*math.random(),
					animSpeed = 1 + 0.8*math.random()
				}
			)
		end
		self.isDead = true
		self.wantSplit = doSplit
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
	
	function self.AddDamage(damage)
		self.damage = self.damage + damage
		if self.damage >= self.def.health then
			self.Destroy(true)
		end
	end
	
	function self.Update(dt)
		if self.isDead then
			if self.wantSplit and self.def.splitTo then
				local bx, by = self.body:getWorldCenter()
				local vx, vy = self.body:getLinearVelocity()
				local outVel = util.RandomPointInAnnulus(50, 250)
				for i = 1, self.def.splitCount do
					local asteroidData = {
						pos = util.Add({bx, by}, util.RandomPointInAnnulus(self.def.scaleFactor*0.2, self.def.scaleFactor*0.5)),
						velocity = util.Add({vx, vy}, outVel),
						typeName = self.def.splitTo,
					}
					EnemyHandler.QueueAsteroidCreation(asteroidData)
					outVel = util.Mult(-1, outVel) -- Replace with rotation if more than two are spawned
				end
			end
			self.body:destroy()
			return true
		end
		self.animTime = self.animTime + dt
		
		TerrainHandler.WrapBody(self.body)
		TerrainHandler.ApplyGravity(self.body)
		TerrainHandler.UpdateSpeedLimit(self.body, false, self.def.minDampening)
		
		self.drawMove = {}
		self.def.DoBehaviour(self, dt)
		
		if self.targetAngle then
			local turnAngle = util.AngleSubtractShortest(self.targetAngle, self.body:getAngle())
			local magnitude = math.min(1, math.abs(turnAngle))
			if turnAngle > 0 then
				self.body:applyTorque(self.def.turnRate * magnitude)
				if magnitude > 0.2 then
					self.drawMove[#self.drawMove + 1] = "police_right"
				end
			else
				self.body:applyTorque(-1*self.def.turnRate * magnitude)
				if magnitude > 0.2 then
					self.drawMove[#self.drawMove + 1] = "police_left"
				end
			end
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
		drawQueue:push({y=0; f=function()
			love.graphics.push()
				local x, y = self.body:getWorldCenter()
				local angle = self.body:getAngle()
				local alpha = TerrainHandler.GetWrapAlpha(x, y)
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				
				for i = 1, #self.drawMove do
					if type(self.drawMove[i]) == "table" then
						Resources.DrawImage(self.drawMove[i][1], 0, 0, 0, alpha, self.def.scaleFactor * self.drawMove[i][2])
					else
						Resources.DrawImage(self.drawMove[i], 0, 0, 0, alpha, self.def.scaleFactor)
					end
				end
				Resources.DrawImage(self.def.image, 0, 0, 0, alpha, self.def.scaleFactor)
				if self.stasisProgress then
					Resources.DrawImage("stasis", 0, 0, 0, alpha * 0.5 * (1 - self.stasisProgress * self.stasisProgress), self.def.scaleFactor)
				end
			love.graphics.pop()
			
			if self.abductionPlanet and not self.isDead and not self.abductionPlanet.body:isDestroyed() then
				local px, py = self.abductionPlanet.body:getWorldCenter()
				local abductPos = {px, py}
				local sX, sY = self.body:getWorldCenter()
				local toShip, shipDist = util.Unit(util.Subtract({sX, sY}, abductPos))
				local triangleRad = self.abductionPlanet.def.radius*math.sqrt(1 - self.abductionProgress)
				local planetLeft = util.Add(abductPos, util.RotateVector(util.Mult(triangleRad, toShip), 0.5*math.pi))
				local planetRight = util.Add(abductPos, util.RotateVector(util.Mult(triangleRad, toShip), -0.5*math.pi))
				abductPos = util.Add(abductPos, util.Mult(self.abductionProgress * shipDist, toShip))
				
				drawQueue:push({y=10; f=function()
					Resources.DrawImage(self.abductType, abductPos[1], abductPos[2], 0, 1, self.abductionPlanet.def.radius*(1 - self.abductionProgress))
					
					love.graphics.setColor(235/255, 140/255, 129/255, 0.72)
					love.graphics.polygon("fill", sX, sY, planetLeft[1], planetLeft[2], planetRight[1], planetRight[2])
				end})
			end
			
			if Global.DRAW_PHYSICS then
				love.graphics.push()
					x, y = self.body:getWorldCenter()
					love.graphics.translate(x, y)
					love.graphics.rotate(angle)
					love.graphics.setColor(1, 1, 1, 1)
					
					local lx, ly = self.body:getLocalCenter()
					
					for i = 1, #self.coords do
						local other = self.coords[(i < #self.coords and (i + 1)) or 1]
						love.graphics.line(self.coords[i][1] - lx, self.coords[i][2] - ly, other[1] - lx, other[2] - ly)
					end
				love.graphics.pop()
			end
		end})
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return New
