
local Resources = require("resourceHandler")
local Font = require("include/font")


local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	self.objType = "sun"
	
	self.body = love.physics.newBody(physicsWorld, self.def.pos[1], self.def.pos[2], "static")
	self.shape = love.physics.newCircleShape(self.def.radius)
	self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density)
	self.body:setUserData(self)
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		
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
				love.graphics.circle("line", 0, 0, self.def.radius)
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
