
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

local ageGuys = {
	false,
	false,
	false,
	false,
	"philosopher",
	"inventor",
	"scientist",
	false,
}

local planetImageList = {
	"planet1",
	"planet2",
	"planet3",
	"planet4",
}

local ageImages = {
	"stone3",
	"stone1",
	"stone2",
	"stone3",
	"stone3",
	"stone3",
	"stone3",
	"stone3",
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
	
	self.body:setAngle(math.random()*math.pi*2)
	self.body:setAngularVelocity(0.28)
	self.fixture:setFriction(0.6)
	
	self.age = self.def.age
	self.ageProgress = 0
	self.guyProgress = 0
	
	self.baseDrawRotation = math.pi*2
	self.ageDrawRotation = math.pi*2
	self.planetDrawBase = util.SampleList(planetImageList)
	
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
	
	function self.AddDamage(damage)
		if self.age <= 1 then
			return
		end
		self.ageProgress = self.ageProgress - damage
		if self.ageProgress < 0 then
			 -- Can only go down one age per damage instance.
			self.age = self.age - 1
			self.ageProgress = math.max(0, self.ageProgress + 1)
			if self.guyProgress > 0.95 and ageGuys[self.age] then
				self.guyGapTime = self.def.guyGap
			end
			self.guyProgress = 0
			if self.age <= 1 then
				self.age = 1
				self.ageProgress = 0
			end
			
			local bx, by = self.body:getPosition()
			for i = 1, 15 do
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
		end
	end
	
	function self.Update(dt)
		if self.isDead then
			self.body:destroy()
			return true
		end
		self.animTime = self.animTime + dt
		
		if self.age > 1 and self.age < self.def.maxAge then
			local ageSpeed = self.def.ageSpeed
			if self.guyProgress >= 1 and ageGuys[self.age] then
				ageSpeed = ageSpeed * self.def.guyAgeBoost
			end
			self.ageProgress = self.ageProgress + dt * ageSpeed
			if self.ageProgress > 1 then
				self.age = self.age + 1
				self.ageProgress = self.ageProgress - 1
			end
		else
			self.ageProgress = 0
		end
		
		if self.guyGapTime and self.guyGapTime >= 0 then
			self.guyGapTime = self.guyGapTime - dt
		end
		
		if ageGuys[self.age] and (self.guyGapTime or 0) <= 0 then
			if self.guyProgress < 1 then
				self.guyProgress = self.guyProgress + dt * self.def.guySpeed
			end
		else
			self.guyProgress = 0
		end
		
		if self.guyProgress >= 1 and ageGuys[self.age] then
			local playerBody = PlayerHandler.GetPlayerShipBody()
			local bx, by = self.body:getPosition()
			local myVx, myVy = self.body:getLinearVelocity()
			local pVx, pVy = playerBody:getLinearVelocity()
			if util.DistSq(myVx, myVy, pVx, pVy) < Global.ABDUCT_VEL_MATCH_SQ + self.def.radius then
				if PlayerHandler.GetDistanceToPlayer({bx, by}) < Global.ABDUCT_DIST_REQUIRE then
					if PlayerHandler.SetAbducting(ageGuys[self.age], self.body, self.def.radius) then
						self.guyProgress = 0
						self.guyGapTime = self.def.guyGap
					end
				end
			end
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
				
				Resources.DrawImage(self.planetDrawBase, 0, 0, self.baseDrawRotation, false, self.def.radius)
				Resources.DrawImage(ageImages[self.age], 0, 0, self.ageDrawRotation, false, self.def.radius)
				
				if Global.DRAW_PHYSICS then
					love.graphics.setColor(1, 1, 1, 1)
					love.graphics.circle("line", 0, 0, self.def.radius)
				end
			love.graphics.pop()
		
			if self.guyProgress > 0.95 and ageGuys[self.age] then
				Resources.DrawImage(ageGuys[self.age], x, y, 0, math.min(1, (self.guyProgress - 0.95)/0.05), self.def.radius)
			end
			
			love.graphics.setColor(1, 1, 1, 0.6)
			love.graphics.arc("fill", "pie", x, y, self.def.radius * 0.9, math.pi*1.5 + math.pi*2*self.ageProgress, math.pi*1.5, 32)
			
			Font.SetSize(3)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.printf(ageNames[self.age], x - 100, y - 24, 200, "center")
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
