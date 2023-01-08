
local Resources = require("resourceHandler")
local Font = require("include/font")

local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	self.objType = "bullet"
	
	self.body = love.physics.newBody(physicsWorld, self.def.pos[1], self.def.pos[2], "dynamic")
	self.shape = love.physics.newCircleShape(self.def.radius)
	self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density)
	
	if self.def.velocity then
		self.body:setLinearVelocity(self.def.velocity[1], self.def.velocity[2])
	end
	self.body:setUserData(self)
	self.fixture:setFriction(0.6)
	
	 self.life =  self.def.life
	
	function self.Destroy()
		if self.isDead then
			return
		end
		local bx, by = self.body:getPosition()
		for i = 1, 5 do
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
	end
	
	function self.Update(dt)
		self.life = self.life - dt
		if self.isDead or self.life < 0 then
			self.isDead = true
			self.body:destroy()
			return true
		end
		self.animTime = self.animTime + dt
		
		TerrainHandler.WrapBody(self.body)
		TerrainHandler.ApplyGravity(self.body)
		TerrainHandler.UpdateSpeedLimit(self.body, Global.BULLET_SPEED_LIMIT)
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=0; f=function()
			love.graphics.push()
				local x, y = self.body:getPosition()
				local angle = self.body:getAngle()
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				
				Resources.DrawImage("planet3", 0, 0, 0, math.min(1, self.life), self.def.radius)
				love.graphics.setColor(1, 1, 1, math.min(1, self.life))
				love.graphics.circle("line", 0, 0, self.def.radius)
			love.graphics.pop()
		end})
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return New