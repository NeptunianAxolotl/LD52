
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
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		
		PlayerHandler.ApplyToPlayer(planetUtils.RepelFunc, dt, self.def.pos, false, self.def.radius, 80, Global.REPEL_MAX_FORCE * self.def.gravity * 0.01)
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
