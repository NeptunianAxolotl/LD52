
local planetUtils = require("utilities/planetUtils")

local function AddIfExists(v1, v2)
	if not v2 then
		return v1
	end
	if not v1 then
		return v2
	end
	return util.Add(v1, v2)
end

local function PlanetHasGuy(planet)
	return planet.IsGuyAppearing()
end

local function UsefulPlanet(planet)
	return planet.age >= 4 and planet.age ~= 8 -- Space age
end

local function DoMovement(self)
	local avoidMod = self.GetSpeedMod() * self.def.avoidMult
	local speedMod = self.GetSpeedMod() * self.def.speedMult
	
	local netForce = false
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "sun", -4000 * avoidMod, TerrainHandler.GetSunRadius() + 300, true))
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "planet", -5000 * avoidMod, Global.PLANET_RADIUS + 125, true))
	
	if self.abductionProgress and not netForce then
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "bullet", -1000 * speedMod, 650, true))
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "asteroid", -1200 * avoidMod, 500, true))
	else
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "bullet", -200 * speedMod, 550, true))
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "asteroid", -350 * avoidMod, 450, true))
	end
	
	local goodPlanetForce, goodPlanetObj = false
	if (not netForce) or util.AbsVal(netForce) < 1500 then
		if self.abductionProgress then
			goodPlanetForce, goodPlanetObj = planetUtils.ForceTowardsClosest(self.body, "planet", 350 * speedMod, false, false, false, PlanetHasGuy)
		else
			goodPlanetForce, goodPlanetObj = planetUtils.ForceTowardsClosest(self.body, "planet", 500 * avoidMod, false, false, false, PlanetHasGuy)
		end
		netForce = AddIfExists(netForce, goodPlanetForce)
	end
	
	if not self.abductionProgress and not goodPlanetObj then
		if (not netForce) or util.AbsVal(netForce) < 1800 then
			netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", -250 * speedMod, false, false))
			netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", -650 * speedMod, 1000, false))
			netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", -400 * speedMod, 550, false))
			netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", 80 * speedMod, 1000, false, self.dodgeAngle))
		end
	else
		if (not netForce) or util.AbsVal(netForce) < 1400 then
			local force = (self.abductionProgress and -100) or -650
			netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", force * speedMod, 700, false))
		end
	end
	
	if (not goodPlanetObj) and ((not netForce) or util.AbsVal(netForce) < 1600) then
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "planet", 450 * speedMod, false, false, false, UsefulPlanet))
	end
	
	if netForce then
		self.targetAngle = util.Angle(netForce)
	else
		self.targetAngle = false
	end
	
	local mag = util.AbsVal(netForce)
	if mag > 80 * self.def.speedMult then
		self.drawMove[#self.drawMove + 1] = {
			"smuggler_thrust",
			math.min(1, mag / 240)
		}
	end
	
	return goodPlanetObj
end

local function DoAbduction(self, dt, foundPlanet)
	if not foundPlanet.IsGuyAvailible(self.abductionId) then
		return
	end
	
	local bx, by = self.body:getWorldCenter()
	local ox, oy = foundPlanet.body:getWorldCenter()
	if util.DistSq(bx, by, ox, oy) > self.def.abductRange * self.def.abductRange then
		return
	end
	
	self.abductionId = self.abductionId or math.random()
	local progress, abType, finished = foundPlanet.AddSmuggleAbductionProgress(2.35*dt, self.abductionId)
	self.abductionProgress = progress
	self.abductType = abType
	if self.abductionProgress then
		self.abductionPlanet = foundPlanet
	end
	if finished then
		local vx, vy = foundPlanet.body:getLinearVelocity()
		EffectsHandler.SpawnEffect(
			"enter_ship_bad",
			{ox, oy},
			{velocity = {vx, vy}}
		)
		EffectsHandler.SpawnEffect(
			"enter_ship_bad",
			{bx, by},
			{scale = 0.45}
		)
	end
end

local function SmugglerBehaviour(self, dt)
	local foundPlanet = DoMovement(self)
	self.abductionProgress = false
	self.abductionPlanet = false
	if foundPlanet then
		DoAbduction(self, dt, foundPlanet)
	end
end

local def = {
	density = 5,
	coords = {{-0.25, 0.25}, {-0.25, -0.25}, {0.18, -0.43}, {0.75, -0.41}, {0.94, 0}, {0.75, 0.41}, {0.18, 0.43}},
	scaleFactor = 95,
	health = 2,
	image = "smuggler",
	angleDampen = 17,
	minDampening = 1.2,
	turnRate = 80000,
	abductRange = 380,
	avoidMult = 0.9,
	speedMult = 0.8,
	
	DoBehaviour = SmugglerBehaviour,
}

return def
