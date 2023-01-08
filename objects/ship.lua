
local Resources = require("resourceHandler")
local Font = require("include/font")

local ShipDefs = util.LoadDefDirectory("defs/ship")

local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	self.objType = self.def.objectType
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
	
	self.body:setAngularDamping(8.6)
	self.body:setUserData(self)
	self.fixture:setFriction(0.45)
	
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
		TerrainHandler.UpdateSpeedLimit(self.body)
		
		self.def.DoBehaviour(self)
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
				
				Resources.DrawImage(self.def.image, 0, 0, 0, false, self.def.scaleFactor)
			love.graphics.pop()
			
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
