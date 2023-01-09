
local Resources = require("resourceHandler")
local Font = require("include/font")
local planetUtils = require("utilities/planetUtils")

local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	self.objType = "sun"
	
	self.body = love.physics.newBody(physicsWorld, self.def.pos[1], self.def.pos[2], "static")
	self.shape = love.physics.newCircleShape(self.def.radius)
	self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density)
	
	self.body:setUserData(self)
	self.fixture:setFriction(0.8)
	
	self.flameRot = {}
	self.flameScale = {}
	self.flameScaleSpeed = {}
	self.flameRotRate = {}
	
	for i = 1, #self.def.flames do
		self.flameRot[i] = math.random()*2*math.pi
		self.flameRotRate[i] = -1*(0.02 + 0.04*math.random())
		self.flameScale[i] = 0.97 + 0.1 * math.random()
		self.flameScaleSpeed[i] = 0.9 + 0.2 * math.random()
	end
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		for i = 1, #self.def.flames do
			self.flameScaleSpeed[i] = self.flameScaleSpeed[i] + (math.random()*1.2 - 0.6*self.flameScaleSpeed[i])*dt
			self.flameRotRate[i] = self.flameRotRate[i] + (-0.2*math.random() - 0.02 - self.flameRotRate[i])*dt
			
			self.flameRot[i] = (self.flameRot[i] + Global.SUN_ROTATE_FACTOR*(i + 3)*self.flameRotRate[i]*dt)%(2*math.pi)
			self.flameScale[i] = self.flameScale[i] + (self.flameScaleSpeed[i] - 0.5 - self.flameScale[i]*0.48)*dt
		end
		
		PlayerHandler.ApplyToPlayer(planetUtils.RepelFunc, dt, self.def.pos, false, self.def.radius, 80, Global.REPEL_MAX_FORCE * self.def.gravity * 0.01)
		--local vx, vy = self.body:getLinearVelocity()
		--local speed = util.Dist(0, 0, vx, vy)
		--print(speed)
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=5; f=function()
			love.graphics.push()
				local x, y = self.body:getWorldCenter()
				local angle = self.body:getAngle()
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				
				for i = 1, #self.def.flames do
					Resources.DrawImage(self.def.flames[i], 0, 0, self.flameRot[i], false, self.def.radius*self.flameScale[i])
				end
				Resources.DrawImage(self.def.image, 0, 0, 0, false, self.def.radius)
				if Global.DRAW_PHYSICS then
					love.graphics.setColor(1, 1, 1, 1)
					love.graphics.circle("line", 0, 0, self.def.radius)
					
					Font.SetSize(2)
					love.graphics.printf("Sun (hot)", -100, -50, 200, "center")
				end
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
