
local Font = require("include/font")
local NewAsteroid = require("objects/asteroid")
local NewBullet = require("objects/bullet")
local NewShip = require("objects/ship")

local self = {}
local api = {}


----------------------------------------------------------------------
----------------------------------------------------------------------
-- Collision

function api.Collision(aData, bData)
	if (aData.objType == "asteroid" or aData.objType == "bullet" or aData.objType == "enemyShip") and bData.objType == "sun" then
		aData.Destroy()
		return true
	end
	if (aData.objType == "asteroid" or aData.objType == "enemyShip") and bData.objType == "bullet" then
		if bData.def.stasisEffect and aData.objType == "enemyShip" then
			aData.ApplyStasis(bData.def.stasisEffect)
		else
			aData.AddDamage(bData.def.damage)
		end
		bData.Destroy()
		return true
	end
	if (aData.objType == "asteroid" and bData.objType == "enemyShip") then
		aData.AddDamage(1)
		bData.AddDamage(aData.def.shipDamage)
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
		bData.Destroy(false, "planet", aData)
		return true
	end
	if aData.objType == "playerShip" and bData.objType == "bullet" then
		if bData.def.stasisEffect then
			aData.ApplyStasis(bData.def.stasisEffect)
		end
		bData.Destroy()
		return true
	end
end

----------------------------------------------------------------------
----------------------------------------------------------------------
-- Utilities

function api.ApplyToBullets(func, ...)
	IterableMap.Apply(self.bullets, func, ...)
end

function api.GetAsteroids()
	return self.asteroids
end

function api.GetBullets()
	return self.bullets
end

function api.GetShips()
	return self.ships
end

function api.GetSpawnCount(typeName)
	return (self.spawnCount[typeName] or 0)
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

function api.AddShip(data)
	IterableMap.Add(self.ships, NewShip({def = data}, self.world.GetPhysicsWorld()))
end

local function CheckEnemyTypeSpawn(spawnData, spawnIndex, dt, timerTable, spawnFunc)
	if not timerTable[spawnIndex] then
		timerTable[spawnIndex] = spawnData.timeMin + math.random()*spawnData.timeRand
	end
	local rate = dt
	if spawnData.spawnRateFunc then
		rate = rate * spawnData.spawnRateFunc()
	end
	timerTable[spawnIndex] = timerTable[spawnIndex] - rate
	if timerTable[spawnIndex] < 0 then
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
			if forceLeft then
				pos[1] = 0
				velocity[1] = math.abs(velocity[1])
			elseif forceRight then
				pos[1] = TerrainHandler.GetWidth()
				velocity[1] = -1*math.abs(velocity[1])
			elseif velocity[1] < 0 then
				pos[1] = TerrainHandler.GetWidth()
			end
		else
			if forceTop then
				pos[2] = 0
				velocity[2] = math.abs(velocity[2])
			elseif forceBottom then
				pos[2] = TerrainHandler.GetWidth()
				velocity[2] = -1*math.abs(velocity[2])
			elseif velocity[2] < 0 then
				pos[2] = TerrainHandler.GetHeight()
			end
		end
		
		local toSpawn = {
			pos = pos,
			velocity = velocity,
			typeName = util.SampleList(spawnData.typeName),
		}
		self.spawnCount[toSpawn.typeName] = (self.spawnCount[toSpawn.typeName] or 0) + 1
		spawnFunc(toSpawn)
		timerTable[spawnIndex] = timerTable[spawnIndex] + spawnData.timeMin + math.random()*spawnData.timeRand
	end
end

local function SpawnEnemiesUpdate(dt)
	local levelData = TerrainHandler.GetLevelData()
	if levelData.asteroidSpawn then
		if levelData.asteroidSpawn then
			for i = 1, #levelData.asteroidSpawn do
				CheckEnemyTypeSpawn(levelData.asteroidSpawn[i], i, dt, self.asteroidTimer, api.AddAsteroid)
			end
		end
		if levelData.shipSpawn then
			for i = 1, #levelData.shipSpawn do
				CheckEnemyTypeSpawn(levelData.shipSpawn[i], i, dt, self.shipTimer, api.AddShip)
			end
		end
	end
end

----------------------------------------------------------------------
----------------------------------------------------------------------
-- Callins

function api.Update(dt)
	SpawnEnemiesUpdate(dt)
	IterableMap.ApplySelf(self.asteroids, "Update", dt)
	IterableMap.ApplySelf(self.ships, "Update", dt)
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
	IterableMap.ApplySelf(self.ships, "Draw", drawQueue)
	IterableMap.ApplySelf(self.bullets, "Draw", drawQueue)
end

function api.Initialize(world, levelIndex, mapDataOverride)
	self = {
		world = world,
		asteroids = IterableMap.New(),
		bullets = IterableMap.New(),
		ships = IterableMap.New(),
		asteroidCreateQueue = false,
		shipTimer = {},
		asteroidTimer = {},
		spawnCount = {},
	}
end

return api
