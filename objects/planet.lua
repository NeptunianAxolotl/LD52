
local Resources = require("resourceHandler")
local Font = require("include/font")
local planetUtils = require("utilities/planetUtils")
local planetNameDefs = require("defs/planetNames")

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
		range = 600,
		reloadSpeed = 1/8,
		checkRate = 0.33,
		typeName = "modern_bullet",
		projSpeed = 250,
		spawnRadius = 20,
	},
	[8] = {
		range = 420,
		reloadSpeed = 1/0.45,
		checkRate = 0.33,
		typeName = "space_bullet",
		projSpeed = 420,
		spawnRadius = 15,
	},
}

local bulletImmuneAges = {
	[8] = true
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
	self.ageProgress = self.def.ageProgress or 0
	self.guyProgress = 0
	
	self.baseDrawRotation = math.pi*2
	self.ageDrawRotation = math.pi*2
	self.planetDrawBase = self.def.forcePlanetType or TerrainHandler.GetUnusedPlanetType() or util.SampleList(planetImageList)
	self.humanName = self.def.humanName or util.SampleList(planetNameDefs[self.planetDrawBase]) or "name issue"
	TerrainHandler.UsePlanetType(self.planetDrawBase)
	
	function self.Destroy()
		if self.isDead then
			return
		end
		local bx, by = self.body:getWorldCenter()
		for i = 1, 30 do
			EffectsHandler.SpawnEffect(
				"fireball_explode",
				util.Add({bx, by}, util.RandomPointInCircle(self.def.radius*0.7)),
				{
					delay = math.random()*0.5,
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
	
	function self.IsGuyAppearing()
		return GetGuyTimeRemaining() < Global.GUY_FADE_IN_TIME
	end
	
	function self.GetAngle()
		return self.body:getAngle()
	end
	
	function self.AddSmuggleAbductionProgress(newProgress, abductionId)
		if not ageGuys[self.age] then
			return false
		end
		self.smuggleAbductionProgress = (self.smuggleAbductionProgress or 0) + newProgress
		self.smuggleAbductionId = abductionId
		if self.smuggleAbductionProgress >= 1 then
			self.guyProgress = 0
			self.guyAgeEndRemovalTime = false
			self.guyGapTime = self.def.guyGap
			self.smuggleAbductionProgress = false
			return false, false, true
		end
		return self.smuggleAbductionProgress, ageGuys[self.age]
	end
	
	function self.IsGuyAvailible(abductionId)
		return ((not self.smuggleAbductionProgress) or (self.smuggleAbductionId == abductionId)) and (self.guyProgress >= 1)
	end
	
	local function IsBeingAbducted()
		return self.smuggleAbductionProgress or (PlayerHandler.GetAbductPlanet() == self.def.name)
	end
	
	function self.CheckShoot(dt)
		if not shootParameters[self.age] then
			return
		end
		local shootDef = shootParameters[self.age]
		
		self.reloadProgress = (self.reloadProgress or 0) + dt * shootDef.reloadSpeed * (self.def.shootRateMult or 1)
		if self.reloadProgress < 1 then
			return
		end
		self.reloadProgress = 1 - shootDef.checkRate * shootDef.reloadSpeed
		
		local mx, my = self.body:getWorldCenter()
		local closestAsteroid = planetUtils.GetClosestAsteroid(mx, my, shootDef.range + self.def.radius)
		if not closestAsteroid then
			return
		end
		local fullSpawnRad = self.def.radius + shootDef.spawnRadius
		if planetUtils.ShootAtBody(
				closestAsteroid.GetBody(), self.body, shootDef.typeName,
				shootDef.projSpeed, fullSpawnRad, self.iterableMapKey) then
			self.reloadProgress = 0
		end
	end
	
	function self.CheckRepelBullets(dt)
		if not bulletRepelAges[self.age] then
			return
		end
		local mx, my = self.body:getWorldCenter()
		EnemyHandler.ApplyToBullets(planetUtils.RepelFunc, dt, {mx, my}, self.iterableMapKey, self.def.radius)
		PlayerHandler.ApplyToPlayer(planetUtils.RepelFunc, dt, {mx, my}, self.iterableMapKey, self.def.radius)
	end
	
	function self.IsBulletImmune()
		return bulletImmuneAges[self.age]
	end
	
	function self.AddDamage(damage, guyDamage)
		if self.age <= 1 then
			return true
		end
		self.ageProgress = self.ageProgress - damage
		
		if not self.smuggleAbductionProgress then
			self.guyProgress = self.guyProgress - (guyDamage or 0)
			if self.guyProgress < 0 then
				self.guyProgress = 0
			end
		end
		
		if self.ageProgress < 0 then
			 -- Can only go down one age per damage instance.
			self.age = self.age - 1
			self.ageProgress = math.max(0, self.ageProgress + 1)
			if ageGuys[self.age] and self.IsGuyAppearing() then
				self.guyGapTime = self.def.guyGap
			end
			self.guyProgress = 0
			if self.age <= 1 then
				self.age = 1
				self.ageProgress = 0
			end
			
			local bx, by = self.body:getWorldCenter()
			local vx, vy = self.body:getLinearVelocity()
			local selfVelocity = {vx, vy}
			for i = 1, 30 do
				EffectsHandler.SpawnEffect(
					"fireball_explode",
					util.Add({bx, by}, util.RandomPointInCircle(self.def.radius*0.7)),
					{
						delay = math.random()*0.5,
						scale = 0.2 + 0.3*math.random(),
						animSpeed = 1 + 0.5*math.random(),
						velocity = selfVelocity,
					}
				)
			end
		end
		
		if damage >= 2 and self.age > 1 then
			-- Huge asteroids kill an extra age
			self.age = self.age - 1
		end
	end
	
	function self.Update(dt)
		if self.isDead then
			self.body:destroy()
			return true
		end
		self.animTime = self.animTime + dt
		
		if self.age > 1 and (self.def.fillLastAge or self.age < self.def.maxAge) then
			local ageSpeed = (self.age <= 4 and self.def.earlyAgeSpeed) or (self.age > 4 and self.def.lateAgeSpeed) or self.def.ageSpeed
			if self.IsGuyAvailible() and ageGuys[self.age] then
				ageSpeed = ageSpeed * self.def.guyAgeBoost
			end
			self.ageProgress = self.ageProgress + dt * ageSpeed
			if self.ageProgress > 1 then
				if IsBeingAbducted() then
					self.ageProgress = self.ageProgress - dt * ageSpeed
				elseif self.IsGuyAppearing() and (self.guyAgeEndRemovalTime or 1) > 0 then
					if Global.GUY_AGE_END_DELAY then
						self.guyAgeEndRemovalTime = (self.guyAgeEndRemovalTime or Global.GUY_AGE_END_DELAY) - dt
					end
					self.ageProgress = self.ageProgress - dt * ageSpeed
				else
					self.guyProgress = 0
					self.guyAgeEndRemovalTime = false
					if self.age < self.def.maxAge then
						self.age = self.age + 1
						self.ageProgress = self.ageProgress - 1
					else
						self.ageProgress = self.ageProgress - dt * ageSpeed
					end
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
			self.guyAgeEndRemovalTime = false
		end
		
		self.CheckRepelBullets(dt)
		self.CheckShoot(dt)
		
		if self.IsGuyAvailible() and ageGuys[self.age] then
			local playerBody = PlayerHandler.GetPlayerShipBody()
			local bx, by = self.body:getWorldCenter()
			local myVx, myVy = self.body:getLinearVelocity()
			local pVx, pVy = playerBody:getLinearVelocity()
			if util.DistSq(myVx, myVy, pVx, pVy) < Global.ABDUCT_VEL_MATCH_SQ + self.def.radius then
				if PlayerHandler.GetDistanceToPlayer({bx, by}) < Global.ABDUCT_DIST_REQUIRE then
					if PlayerHandler.SetAbducting(ageGuys[self.age], self.def.name, self.body, self.def.radius) then
						self.guyProgress = 0
						self.guyAgeEndRemovalTime = false
						self.guyGapTime = self.def.guyGap
					end
				end
			end
		end
		
		TerrainHandler.WrapBody(self.body)
		TerrainHandler.ApplyGravity(self.body)
		TerrainHandler.UpdateSpeedLimit(self.body)
		
		if self.smuggleAbductionProgress then
			self.smuggleAbductionProgress = self.smuggleAbductionProgress - 2*dt
			if self.smuggleAbductionProgress < 0 then
				self.smuggleAbductionProgress = false
			end
		end
	end
	
	function self.Draw(drawQueue)
		local x, y = self.body:getWorldCenter()
		local angle = self.body:getAngle()
		drawQueue:push({y=-2; f=function()
			love.graphics.setColor(1, 1, 1, 0.5)
			if self.ageProgress > 0 then
				love.graphics.arc("fill", "pie", x, y, self.def.radius * 1.4, math.pi*1.5 + math.pi*2*math.min(1.01, self.ageProgress), math.pi*1.5, 32)
			end
		end})
		drawQueue:push({y=2; f=function()
			love.graphics.push()
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				
				if Global.AGE_IMAGE[self.age] then
					Resources.DrawImage(self.planetDrawBase, 0, 0, self.baseDrawRotation, false, self.def.radius)
					Resources.DrawImage(Global.AGE_IMAGE[self.age], 0, 0, self.ageDrawRotation, false, self.def.radius)
				else
					Resources.DrawImage(Global.DEAD_IMAGE[self.planetDrawBase], 0, 0, self.ageDrawRotation, false, self.def.radius)
				end
				
				if Global.DRAW_PHYSICS then
					love.graphics.setColor(1, 1, 1, 1)
					love.graphics.circle("line", 0, 0, self.def.radius)
				end
			love.graphics.pop()
		
			if ageGuys[self.age] and not IsBeingAbducted() then
				local timeRemaining = GetGuyTimeRemaining()
				if self.IsGuyAppearing() then
					local period = 0.5
					local offset = 0.7
					if self.guyAgeEndRemovalTime then
						period = 0.3
						offset = 0.7 * (self.guyAgeEndRemovalTime / (5 + self.guyAgeEndRemovalTime))
					end
					local alpha = (self.animTime%period) / period
					local fadeIn = math.min(1, (Global.GUY_FADE_IN_TIME - timeRemaining)/Global.GUY_FADE_IN_TIME)
					alpha = 0.3 * 0.5 * (math.sin(alpha * 2 * math.pi) + 1) + offset
					Resources.DrawImage("guyglow", x, y, 0, alpha * fadeIn, self.def.radius)
					Resources.DrawImage(ageGuys[self.age], x, y, 0, (offset / 0.7 + (1 - offset / 0.7) * alpha) * fadeIn, self.def.radius)
				end
				if self.guyProgress > 0 and self.guyProgress < 1 then
					local fadeIn = math.max(0, math.min(1, (Global.GUY_FADE_IN_TIME - timeRemaining)/Global.GUY_FADE_IN_TIME))
					love.graphics.setColor(1, 1, 1, 0.6 * (1 - fadeIn))
					love.graphics.arc("fill", "pie", x, y, self.def.radius * 0.6, math.pi*1.5 + math.pi*2*math.min(1, self.guyProgress), math.pi*1.5, 32)
				end
			end
			
			--Font.SetSize(3)
			--love.graphics.setColor(1, 1, 1, 1)
			--love.graphics.printf(ageNames[self.age], x - 100, y - 24, 200, "center")
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
