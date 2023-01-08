

local Font = require("include/font")
local NewAsteroid = require("objects/asteroid")
local NewBullet = require("objects/bullet")

local self = {}
local api = {}


----------------------------------------------------------------------
----------------------------------------------------------------------
-- Collision

function api.Collision(aData, bData)
	if (aData.objType == "asteroid" or aData.objType == "bullet") and bData.objType == "sun" then
		aData.Destroy()
		return true
	end
	if aData.objType == "asteroid" and bData.objType == "bullet" then
		aData.AddDamage(bData.def.damage)
		bData.Destroy()
		return true
	end
	if aData.objType == "planet" and bData.objType == "bullet" then
		if not aData.IsBulletImmune() then
			aData.AddDamage(bData.def.planetDamage, bData.def.guyDamage)
			bData.Destroy()
			return true
		end
	end
	if aData.objType == "planet" and bData.objType == "asteroid" then
		aData.AddDamage(bData.def.planetDamage)
		bData.Destroy()
		return true
	end
	if aData.objType == "playerShip" and bData.objType == "bullet" then
		bData.Destroy()
		return true
	end
end

----------------------------------------------------------------------
----------------------------------------------------------------------
-- Utilities

function api.GetClosestAsteroid(x, y, maxDist)
	local maxDistSq = maxDist * maxDist
	local function MinFunc(asteroid)
		if asteroid.isDead then
			return false
		end
		local bx, by = asteroid.GetBody():getWorldCenter()
		local distSq = util.DistSq(x, y, bx, by)
		if distSq < maxDistSq then
			return distSq
		end
		return false
	end
	
	local asteroid, asteroidDist = IterableMap.GetMinimum(self.asteroids, MinFunc)
	return asteroid, asteroidDist and math.sqrt(asteroidDist)
end

function api.ApplyToBullets(func, ...)
	IterableMap.Apply(self.bullets, func, ...)
end

----------------------------------------------------------------------
----------------------------------------------------------------------
-- Creation and handling

function api.QueueAsteroidCreation(asteroidData)
	self.asteroidCreateQueue = self.asteroidCreateQueue or {}
	self.asteroidCreateQueue[#self.asteroidCreateQueue + 1] = asteroidData
end

function api.AddAsteroid(data)
	IterableMap.Add(self.asteroids, NewAsteroid({def = data}, self.world.GetPhysicsWorld()))
end

function api.AddBullet(data)
	IterableMap.Add(self.bullets, NewBullet({def = data}, self.world.GetPhysicsWorld()))
end

local function SpawnAsteroidsUpdate(spawnData, spawnIndex, dt)
	if not self.asteroidTimer[spawnIndex] then
		self.asteroidTimer[spawnIndex] = spawnData.timeMin + math.random()*spawnData.timeRand
	end
	self.asteroidTimer[spawnIndex] = self.asteroidTimer[spawnIndex] - dt
	if self.asteroidTimer[spawnIndex] < 0 then
		local spawnMin = 0.5 - (spawnData.spawnRange or 1) * 0.5
		local spawnPosFactor = (spawnMin + (spawnData.spawnRange or 1) * math.random()) + (spawnData.spawnOffset or 0)
		local pos = {0, spawnPosFactor * TerrainHandler.GetHeight()}
		local leftRightSpawn = true
		if spawnData.topBotChance and math.random() < spawnData.topBotChance then
			pos[1] = spawnPosFactor * TerrainHandler.GetWidth()
			pos[2] = 0
			leftRightSpawn = false
		end
		
		local velocity = {0, 0}
		if spawnData.speedMin then
			velocity = util.Add(velocity, util.RandomPointInAnnulus(spawnData.speedMin, spawnData.speedMax))
		end
		if spawnData.orbitMult then
			local orbitMult = spawnData.orbitMult + (spawnData.orbitMultRand or 0)*math.random()
			if spawnData.orbitOtherDirChance and math.random() < spawnData.orbitOtherDirChance then
				orbitMult = -1*orbitMult
			end
			velocity = util.Add(velocity, TerrainHandler.GetCircularOrbitVelocity(pos, orbitMult))
		end
		
		if spawnData.avoidOrbitOverWrap then
			if leftRightSpawn then
				if velocity[2] < 0 and pos[2] > TerrainHandler.GetSunY() then
					velocity[2] = -1*velocity[2]
				elseif velocity[2] > 0 and pos[2] < TerrainHandler.GetSunY() then
					velocity[2] = -1*velocity[2]
				end
			else
				if velocity[1] < 0 and pos[1] > TerrainHandler.GetSunX() then
					velocity[1] = -1*velocity[1]
				elseif velocity[1] > 0 and pos[1] < TerrainHandler.GetSunX() then
					velocity[1] = -1*velocity[1]
				end
			end
		end
		
		if leftRightSpawn then
			if velocity[1] < 0 then
				pos[1] = TerrainHandler.GetWidth()
			end
		else
			if velocity[2] < 0 then
				pos[2] = TerrainHandler.GetHeight()
			end
		end
		
		local asteroidData = {
			pos = pos,
			velocity = velocity,
			typeName = spawnData.spawnType,
		}
		api.AddAsteroid(asteroidData)
		self.asteroidTimer[spawnIndex] = self.asteroidTimer[spawnIndex] + spawnData.timeMin + math.random()*spawnData.timeRand
	end
end

local function SpawnEnemiesUpdate(dt)
	local levelData = TerrainHandler.GetLevelData()
	if levelData.asteroidSpawn then
		for i = 1, #levelData.asteroidSpawn do
			SpawnAsteroidsUpdate(levelData.asteroidSpawn[i], i, dt)
		end
	end
end

----------------------------------------------------------------------
----------------------------------------------------------------------
-- Callins

function api.Update(dt)
	SpawnEnemiesUpdate(dt)
	IterableMap.ApplySelf(self.asteroids, "Update", dt)
	IterableMap.ApplySelf(self.bullets, "Update", dt)
	
	if self.asteroidCreateQueue then
		for i = 1, #self.asteroidCreateQueue do
			local asteroidData = self.asteroidCreateQueue[i]
			api.AddAsteroid(asteroidData)
		end
		self.asteroidCreateQueue = false
	end
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.asteroids, "Draw", drawQueue)
	IterableMap.ApplySelf(self.bullets, "Draw", drawQueue)
end

function api.Initialize(world, levelIndex, mapDataOverride)
	self = {
		world = world,
		asteroids = IterableMap.New(),
		bullets = IterableMap.New(),
		asteroidCreateQueue = false,
		asteroidTimer = {}
	}
end

return api
