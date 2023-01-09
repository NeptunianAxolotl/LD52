
local Resources = require("resourceHandler")
local Font = require("include/font")

local AsteroidDefs = util.LoadDefDirectory("defs/asteroid")

local asteroidDamageImages = {
	[0] = "asteroid_damage_0",
	[0.5] = "asteroid_damage_1",
	[1] = "asteroid_damage_1",
	[1.5] = "asteroid_damage_2"
}

local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	self.objType = "asteroid"
	self.def = util.CopyTable(AsteroidDefs[self.def.typeName], false, self.def)
	
	self.body = love.physics.newBody(physicsWorld, self.def.pos[1], self.def.pos[2], "dynamic")
	if self.def.coords then
		local modCoords = {}
		self.coords = {}
		for i = 1, #self.def.coords do
			local pos = util.Mult(self.def.radius, self.def.coords[i])
			modCoords[#modCoords + 1] = pos[1]
			modCoords[#modCoords + 1] = pos[2]
			self.coords[i] = pos
		end
		
		self.shape = love.physics.newPolygonShape(unpack(modCoords))
		self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density * Global.ASTEROID_WEIGHT_MULT)
	else
		self.shape = love.physics.newCircleShape(self.def.radius)
		self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density * Global.ASTEROID_WEIGHT_MULT)
	end
	
	if self.def.velocity then
		self.body:setLinearVelocity(self.def.velocity[1], self.def.velocity[2])
	end
	self.body:setUserData(self)
	
	self.body:setAngle(math.random()*math.pi*2)
	self.body:setAngularVelocity(math.random()*3 - 1.5)
	self.fixture:setFriction(0.6)
	self.fixture:setRestitution(self.def.bounce or 0.6)
	if self.def.angleDampen then
		self.body:setAngularDamping(self.def.angleDampen)
	end
	
	self.damage = 0
	
	function self.GetBody()
		return self.body
	end
	
	function self.Destroy(doSplit, deathType, other)
		if self.isDead then
			return
		end
		local bx, by = self.body:getWorldCenter()
		if self.def.planetDeathAnim and deathType == "planet" then
			local angle = self.body:getAngle()
			local vx, vy = other.body:getLinearVelocity()
			EffectsHandler.SpawnEffect(
				self.def.planetDeathAnim,
				{bx, by},
				{
					direction = angle,
					angularVelocity = self.body:getAngularVelocity(),
					velocity = {vx, vy},
					scale = self.def.radius
				}
			)
		else
			for i = 1, 12 do
				EffectsHandler.SpawnEffect(
					"fireball_explode",
					util.Add({bx, by}, util.RandomPointInCircle(self.def.radius*0.6)),
					{
						delay = math.random()*0.2,
						scale = 0.15 + 0.2*math.random(),
						animSpeed = 1 + 0.8*math.random()
					}
				)
			end
		end
		self.isDead = true
		self.wantSplit = doSplit or self.def.alwaySplit
	end
	
	function self.AddDamage(damage)
		if not self.def.health then
			return
		end
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
						pos = util.Add({bx, by}, util.RandomPointInAnnulus(self.def.radius*0.2, self.def.radius*0.5)),
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
		TerrainHandler.UpdateSpeedLimit(self.body)
		
		--local vx, vy = self.body:getLinearVelocity()
		--local speed = util.Dist(0, 0, vx, vy)
		--print(speed)
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=-1; f=function()
			love.graphics.push()
				local x, y = self.body:getWorldCenter()
				local angle = self.body:getAngle()
				local alpha = TerrainHandler.GetWrapAlpha(x, y)
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				local image = self.def.image or asteroidDamageImages[self.damage] or "asteroid_damage_2"
				if self.def.damageImages then
					for i = 1, #self.def.damageImages do
						if self.damage < self.def.damageImages[i][1] then
							image = self.def.damageImages[i][2]
							break
						end
					end
				end
				Resources.DrawImage(image, 0, 0, 0, alpha, self.def.radius)
				if Global.DRAW_PHYSICS then
					if self.def.coords then
						local lx, ly = self.body:getLocalCenter()
						for i = 1, #self.coords do
							local other = self.coords[(i < #self.coords and (i + 1)) or 1]
							love.graphics.line(self.coords[i][1] - lx, self.coords[i][2] - ly, other[1] - lx, other[2] - ly)
						end
					else
						love.graphics.setColor(1, 1, 1, 1)
						love.graphics.circle("line", 0, 0, self.def.radius)
					end
				end
			love.graphics.pop()
		end})
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return New
