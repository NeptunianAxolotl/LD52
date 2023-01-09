
local SPAWN_TIME_MULT = 1

local def = {
	humanName = "Orientation",
	description = [[
First planet.

Protect the planet and harvest the people.

WSAD/Arrow Keys to move
Space to shoot

Don't shoot the planet.

Move once two have been selected.
]],
	nextLevel = "level2",
	gravity = 15,
	starCount = 1200,
	asteroidSpawn = {
		{
			timeMin = 20 * SPAWN_TIME_MULT,
			timeRand = 8 * SPAWN_TIME_MULT,
			speedMin = 2,
			speedMax = 6,
			orbitMult = 0.75,
			orbitMultRand = 0.2,
			orbitMultBothDirections = 0,
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.4,
			typeName = {"asteroid_big"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				if count == 0 then
					return 3
				elseif count == 1 then
					return 1
				end
				return 0.2
			end,
		},
	},
	shipSpawn = {
	},
	planets = {
		{
			name = "planet1",
			pos = {-1000, 0},
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0,
			age = "stone",
			maxAge = "classical",
			shootRateMult = 2,
			earlyAgeSpeed = 1/12,
			lateAgeSpeed = 1/50,
			guySpeed = 1/12,
			guyGap = 0,
			guyAgeBoost = 6,
			fillLastAge = false,
		},
	},
	goal = {
		planet1 = {
			philosopher = 2
		}
	},
	sun = {
		alignX = 0.5,
		alignY = 0.5,
		radius = 160,
		image = "sun",
	},
	asteroids = {
		{
			-- Designed to hit the planet in the classical age
			pos = util.RotateVector({1200, -400}, -1.85),
			orbitMult = 0.75,
			orbitAngle = -0.38,
			typeName = "asteroid_big",
		},
		{
			-- Harmless, taget practice
			pos = {350, 1200},
			orbitMult = 0.98,
			typeName = "asteroid_big",
		}
	},
	player = {
		pos = {-300, -500},
		orbitMult = -1.2,
	},
}

return def
