
local Resources = require("resourceHandler")
local Font = require("include/font")

local ageNames = {
	"Dead",
	"Stone",
	"Bronze",
	"Iron",
	"Classical",
	"Invention",
	"Modern",
	"Space",
}

local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	self.objType = "planet"
	
	self.body = love.physics.newBody(physicsWorld, self.def.pos[1], self.def.pos[2], "dynamic")
	self.shape = love.physics.newCircleShape(self.def.radius)
	self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density)
	
	if self.def.velocity then
		self.body:setLinearVelocity(self.def.velocity[1], self.def.velocity[2])
	end
	self.body:setUserData(self)
	self.fixture:setFriction(0.6)
	
	self.age = self.def.age
	self.ageProgress = 0
	
	function self.Destroy()
		if self.isDead then
			return
		end
		local bx, by = self.body:getPosition()
		for i = 1, 20 do
			EffectsHandler.SpawnEffect(
				"fireball_explode",
				util.Add({bx, by}, util.RandomPointInCircle(self.def.radius*0.6)),
				{
					delay = math.random()*0.4,
					scale = 0.2 + 0.3*math.random(),
					animSpeed = 1 + 0.5*math.random()
				}
			)
		end
		self.isDead = true
	end
	
	function self.Update(dt)
		if self.isDead then
			self.body:destroy()
			return true
		end
		self.animTime = self.animTime + dt
		
		if self.age > 1 and self.age < self.def.maxAge then
			self.ageProgress = self.ageProgress + dt * self.def.ageSpeed
			if self.ageProgress > 1 then
				self.age = self.age + 1
				self.ageProgress = self.ageProgress - 1
			end
		else
			self.ageProgress = 0
		end
		
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
				local x, y = self.body:getPosition()
				local angle = self.body:getAngle()
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.circle("line", 0, 0, self.def.radius)
				
				love.graphics.setColor(0.5, 0.5, 0.5, 0.8)
				love.graphics.arc("fill", "pie", 0, 0, self.def.radius * 0.9, math.pi*1.5 + math.pi*2*self.ageProgress, math.pi*1.5, 32)
				
				Font.SetSize(3)
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.printf(ageNames[self.age], -100, -24, 200, "center")
			love.graphics.pop()
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
