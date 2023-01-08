
local planetUtils = require("utilities/planetUtils")

local function SmugglerBehaviour(self)
	planetUtils.ForceTowardsClosest(self.body, "asteroid", false, 8000, false)
end

local def = {
	density = 5,
	coords = {{-0.25, 0.25}, {-0.25, -0.25}, {0.18, -0.43}, {0.75, -0.41}, {0.94, 0}, {0.75, 0.41}, {0.18, 0.43}},
	scaleFactor = 120,
	health = 5,
	image = "police",
	
	DoBehaviour = SmugglerBehaviour,
}

return def
