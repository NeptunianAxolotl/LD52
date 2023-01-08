
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

local function DoMovement(self)
	local netForce = false
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "sun", -4000 * self.GetSpeedMod(), 450, true))
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "planet", -3000 * self.GetSpeedMod(), 250, true))
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "asteroid", -1000 * self.GetSpeedMod(), 110, false))
	
	if (not netForce) or util.AbsVal(netForce) < 1500 then
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", 320 * self.GetSpeedMod(), false, false))
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", -900 * self.GetSpeedMod(), 300, true))
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", 400 * self.GetSpeedMod(), 350, false, self.dodgeAngle))
	elseif (not netForce) or util.AbsVal(netForce) < 3000 then
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", 320 * self.GetSpeedMod(), false, false, self.dodgeAngle))
	end
	
	if netForce then
		self.targetAngle = util.Angle(netForce)
	else
		self.targetAngle = false
	end
end

local function DoShooting(self, dt)
	if not PlayerHandler.GetPlayerShipBody() then
		return
	end
	self.shootProgress = (self.shootProgress or 0) + dt*self.def.fireSpeed
	if self.shootProgress < 1 then
		return
	end
	local otherBody = PlayerHandler.GetPlayerShipBody()
	local bx, by = self.body:getWorldCenter()
	local ox, oy = otherBody:getWorldCenter()
	local smuggler = planetUtils.GetClosestSmuggler(bx, by, self.def.range)
	local playerDistSq = util.DistSq(bx, by, ox, oy)
	if playerDistSq > self.def.range * self.def.range then
		if not smuggler then
			self.shootProgress = 0.95
			return
		end
		otherBody = smuggler.body
	elseif smuggler then
		local sx, sy = smuggler.body:getWorldCenter()
		local smugglerDistSq = util.DistSq(bx, by, sx, sy)
		if smugglerDistSq < playerDistSq then
			otherBody = smuggler.body
		end
	end
	planetUtils.ShootAtBody(otherBody, self.body, "police_bullet", 600, 85)
	self.shootProgress = 0
end

local function PoliceBehaviour(self, dt)
	DoMovement(self)
	DoShooting(self, dt)
end

local def = {
	density = 5,
	coords = {{-0.25, 0.25}, {-0.25, -0.25}, {0.18, -0.43}, {0.75, -0.41}, {0.94, 0}, {0.75, 0.41}, {0.18, 0.43}},
	scaleFactor = 110,
	health = 3,
	image = "police",
	angleDampen = 16,
	minDampening = 1.2,
	turnRate = 60000,
	range = 900,
	fireSpeed = 1/2,
	
	DoBehaviour = PoliceBehaviour,
}

return def
