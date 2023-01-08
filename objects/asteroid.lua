
local Resources = require("resourceHandler")
local Font = require("include/font")

local AsteroidDefs = util.LoadDefDirectory("defs/asteroid")

local asteroidDamageImages = {
	[0] = "asteroid_damage_0",
	[1] = "asteroid_damage_1",
	[2] = "asteroid_damage_2"
}

local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	self.objType = "asteroid"
	self.def = util.CopyTable(AsteroidDefs[self.def.typeName], false, self.def)
	
	self.body = love.physics.newBody(physicsWorld, self.def.pos[1], self.def.pos[2], "dynamic")
	self.shape = love.physics.newCircleShape(self.def.radius)
	self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density * Global.ASTEROID_WEIGHT_MULT)
	
	if self.def.velocity then
		self.body:setLinearVelocity(self.def.velocity[1], self.def.velocity[2])
	end
	self.body:setUserData(self)
	
	self.body:setAngle(math.random()*math.pi*2)
	self.body:setAngularVelocity(math.random()*3 - 1.5)
	self.fixture:setFriction(0.6)
	self.fixture:setRestitution(0.6)
	
	self.damage = 0
	
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
				util.Add({bx, by}, util.RandomPointInCircle(self.def.radius*0.6)),
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
		drawQueue:push({y=0; f=function()
			love.graphics.push()
				local x, y = self.body:getWorldCenter()
				local angle = self.body:getAngle()
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				
				Resources.DrawImage(asteroidDamageImages[self.damage] or "asteroid_damage_2", 0, 0, 0, false, self.def.radius)
				if Global.DRAW_PHYSICS then
					love.graphics.setColor(1, 1, 1, 1)
					love.graphics.circle("line", 0, 0, self.def.radius)
				end
			love.graphics.pop()
		end})
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return New
