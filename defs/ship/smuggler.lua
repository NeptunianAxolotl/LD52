
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
	return planet.age ~= 1 and planet.age ~= 8 -- Space age
end

local function DoMovement(self)
	local netForce = false
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "sun", -4000 * self.GetSpeedMod(), 550, true))
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "planet", -5000 * self.GetSpeedMod(), 220, true))
	
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "bullet", -800 * self.GetSpeedMod(), 350, true))
	if not self.abductionProgress and not netForce then
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "asteroid", -900 * self.GetSpeedMod(), 250, true))
	end
	
	local goodPlanetForce, goodPlanetObj = false
	if (not netForce) or util.AbsVal(netForce) < 1500 then
		if self.abductionProgress then
			goodPlanetForce, goodPlanetObj = planetUtils.ForceTowardsClosest(self.body, "planet", 300 * self.GetSpeedMod(), false, false, false, PlanetHasGuy)
		else
			goodPlanetForce, goodPlanetObj = planetUtils.ForceTowardsClosest(self.body, "planet", 500 * self.GetSpeedMod(), false, false, false, PlanetHasGuy)
		end
		netForce = AddIfExists(netForce, goodPlanetForce)
	end
	
	if not self.abductionProgress and not goodPlanetObj then
		if (not netForce) or util.AbsVal(netForce) < 1800 then
			netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", -250 * self.GetSpeedMod(), false, false))
			netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", -500 * self.GetSpeedMod(), 800, false))
			netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", 80 * self.GetSpeedMod(), 900, false, self.dodgeAngle))
		end
	else
		if (not netForce) or util.AbsVal(netForce) < 1400 then
			local force = (self.abductionProgress and -200) or -450
			netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", force * self.GetSpeedMod(), 600, false))
		end
	end
	
	if (not goodPlanetObj) and ((not netForce) or util.AbsVal(netForce) < 900) then
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "planet", 350 * self.GetSpeedMod(), false, false, false, UsefulPlanet))
	end
	
	if netForce then
		self.targetAngle = util.Angle(netForce)
	else
		self.targetAngle = false
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
	self.abductionProgress, self.abductType = foundPlanet.AddSmuggleAbductionProgress(2.35*dt, self.abductionId)
	if self.abductionProgress then
		self.abductionPlanet = foundPlanet
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
	scaleFactor = 105,
	health = 2,
	image = "smuggler",
	angleDampen = 17,
	minDampening = 1.2,
	turnRate = 80000,
	abductRange = 380,
	
	DoBehaviour = SmugglerBehaviour,
}

return def
