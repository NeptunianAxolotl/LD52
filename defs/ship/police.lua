
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

local function PoliceBehaviour(self)
	local netForce = false
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "sun", -5000, 500, true))
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "planet", -4000, 280, true))
	netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "asteroid", -1400, 150, false))
	
	if (not netForce) or util.AbsVal(netForce) < 1500 then
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", 320, false, false))
	elseif (not netForce) or util.AbsVal(netForce) < 3000 then
		netForce = AddIfExists(netForce, planetUtils.ForceTowardsClosest(self.body, "player", 320, false, false, self.dodgeAngle))
	end
	
	if netForce then
		self.targetAngle = util.Angle(netForce)
	else
		self.targetAngle = false
	end
end

local def = {
	density = 5,
	coords = {{-0.25, 0.25}, {-0.25, -0.25}, {0.18, -0.43}, {0.75, -0.41}, {0.94, 0}, {0.75, 0.41}, {0.18, 0.43}},
	scaleFactor = 110,
	health = 5,
	image = "police",
	minDampening = 1.2,
	turnRate = 50000,
	
	DoBehaviour = PoliceBehaviour,
}

return def
