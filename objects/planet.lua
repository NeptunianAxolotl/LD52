
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

local shootParameters = {
	[7] = {
		range = 400,
		reloadSpeed = 1/12,
		checkRate = 0.33,
		typeName = "modern_bullet",
		projSpeed = 250,
		spawnRadius = 15,
	},
	[8] = {
		range = 360,
		reloadSpeed = 1/0.45,
		checkRate = 0.33,
		typeName = "space_bullet",
		projSpeed = 380,
		spawnRadius = 15,
	},
}

local bulletImmuneAges = {
}

local bulletRepelAges = {
	[8] = true
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

local function RepelFunc(key, other, index, dt, repelPos, planetKey, planetRadius)
	if other.def.parentPlanetKey == planetKey then
		return
	end
	local bx, by = other.body:getPosition()
	local dist = util.Dist(bx, by, repelPos[1], repelPos[2]) - planetRadius
	if dist > Global.REPEL_DIST then
		return
	end
	
	local force = util.Mult(Global.REPEL_MAX_FORCE * (1 - dist / Global.REPEL_DIST), util.Unit({bx - repelPos[1], by - repelPos[2]}))
	other.body:applyForce(force[1], force[2])
end

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
	
	local function GetGuyTimeRemaining()
		return (1 - self.guyProgress) / self.def.guySpeed + self.guyGapTime
	end
	
	function self.CheckShoot(dt)
		if not shootParameters[self.age] then
			return
		end
		local shootDef = shootParameters[self.age]
		
		self.reloadProgress = (self.reloadProgress or 0) + dt * shootDef.reloadSpeed
		if self.reloadProgress < 1 then
			return
		end
		self.reloadProgress = 1 - shootDef.checkRate * shootDef.reloadSpeed
		
		local mx, my = self.body:getPosition()
		local closestAsteroid, closeDist = EnemyHandler.GetClosestAsteroid(mx, my, shootDef.range + self.def.radius)
		if not closestAsteroid then
			return
		end
		local ax, ay = closestAsteroid.GetBody():getPosition()
		local aVx, aVy = closestAsteroid.GetBody():getLinearVelocity()
		local mVx, mVy = self.body:getLinearVelocity()
		
		-- Relativity
		aVx, aVy = aVx - mVx, aVy - mVy
		
		-- Find a predicted travel time that matches predicted velocity
		local fullSpawnRad = self.def.radius + shootDef.spawnRadius
		local bestTravel = 0.1
		local bestTravelDelta = 100
		local gravityAccel = TerrainHandler.GetLocalGravityAccel(ax, ay)
		for travelTest = 0.1, 1.6, 0.1 do
			local px = ax + travelTest * aVx + 0.5 * travelTest * travelTest * gravityAccel[1]
			local py = ay + travelTest * aVy + 0.5 * travelTest * travelTest * gravityAccel[2]
			local travelTime = (util.Dist(mx, my, px, py) - fullSpawnRad) / shootDef.projSpeed
			if math.abs(travelTime - travelTest) < bestTravelDelta then
				bestTravel = travelTime
				bestTravelDelta = math.abs(travelTime - travelTest)
			end
		end
		local travelTime = bestTravel
		local px, py = ax + travelTime * aVx, ay + travelTime * aVy
		
		-- Shoot at predicted spot
		local toPrediction = util.Unit({px - mx, py - my})
		local bulletData = {
			pos = util.Add({mx, my}, util.Mult(fullSpawnRad, toPrediction)),
			velocity = util.Add({mVx, mVy}, util.Mult(shootDef.projSpeed, toPrediction)),
			typeName = shootDef.typeName,
			target = closestAsteroid.GetBody(),
			parentPlanetKey = self.iterableMapKey,
		}
		EnemyHandler.AddBullet(bulletData)
		self.reloadProgress = 0
	end
	
	function self.CheckRepelBullets(dt)
		if not bulletRepelAges[self.age] then
			return
		end
		local mx, my = self.body:getPosition()
		EnemyHandler.ApplyToBullets(RepelFunc, dt, {mx, my}, self.iterableMapKey, self.def.radius)
		PlayerHandler.ApplyToPlayer(RepelFunc, dt, {mx, my}, self.iterableMapKey, self.def.radius)
	end
	
	function self.IsBulletImmune()
		return bulletImmuneAges[self.age]
	end
	
	function self.AddDamage(damage)
		if self.age <= 1 then
			return true
		end
		self.ageProgress = self.ageProgress - damage
		if self.ageProgress < 0 then
			 -- Can only go down one age per damage instance.
			self.age = self.age - 1
			self.ageProgress = math.max(0, self.ageProgress + 1)
			if  ageGuys[self.age] and GetGuyTimeRemaining() < 0.5 then
				self.guyGapTime = self.def.guyGap
			end
			self.guyProgress = 0
			self.reloadProgress = 0
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
		
		if self.age > 1 and (self.def.fillLastAge or self.age < self.def.maxAge) then
			local ageSpeed = self.def.ageSpeed
			if self.guyProgress >= 1 and ageGuys[self.age] then
				ageSpeed = ageSpeed * self.def.guyAgeBoost
			end
			self.ageProgress = self.ageProgress + dt * ageSpeed
			if self.ageProgress > 1 then
				if self.age < self.def.maxAge then
					self.age = self.age + 1
					self.ageProgress = self.ageProgress - 1
				else
					self.ageProgress = 1
				end
			end
		else
			self.ageProgress = 0
		end
		
		if self.guyGapTime and self.guyGapTime >= 0 then
			self.guyGapTime = self.guyGapTime - dt
		else
			self.guyGapTime = 0
		end
		
		if ageGuys[self.age] and (self.guyGapTime or 0) <= 0 then
			if self.guyProgress < 1 then
				self.guyProgress = self.guyProgress + dt * self.def.guySpeed
			end
		else
			self.guyProgress = 0
		end
		
		self.CheckRepelBullets(dt)
		self.CheckShoot(dt)
		
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
		
			if ageGuys[self.age] and GetGuyTimeRemaining() < 0.5 then
				local timeRemaining = GetGuyTimeRemaining()
				Resources.DrawImage(ageGuys[self.age], x, y, 0, math.min(1, (0.5 - timeRemaining)/0.5), self.def.radius)
			end
			
			love.graphics.setColor(1, 1, 1, 0.6)
			if self.ageProgress < 1 then
				love.graphics.arc("fill", "pie", x, y, self.def.radius * 0.9, math.pi*1.5 + math.pi*2*self.ageProgress, math.pi*1.5, 32)
			end
			
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
