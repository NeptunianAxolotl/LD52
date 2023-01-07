
local Resources = require("resourceHandler")
local Font = require("include/font")

local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	
	local coords = {{0, 0.35}, {0, -0.35}, {1, 0}}
	local scaleFactor = 50
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
	
	if self.def.velocity then
		self.body:setLinearVelocity(self.def.velocity[1], self.def.velocity[2])
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
		
		if love.keyboard.isDown("s") or love.keyboard.isDown("down") or love.keyboard.isDown("space") then
			local vx, vy = self.body:getLinearVelocity()
			local forceVec = util.Mult(-1 * Global.BRAKE_MULT, util.Unit({vx, vy}))
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
			turnAmount = turnAmount * Global.TURN_MULT
			turnAmount = turnAmount * (0.15 + 0.85 * (1 - speed / (speed + 600)))
			self.body:applyTorque(turnAmount)
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=0; f=function()
			love.graphics.push()
				local x, y = self.body:getPosition()
				local angle = self.body:getAngle()
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				for i = 1, #coords do
					local other = coords[(i < #coords and (i + 1)) or 1]
					love.graphics.line(coords[i][1], coords[i][2], other[1], other[2])
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
