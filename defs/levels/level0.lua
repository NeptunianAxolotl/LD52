
local SPAWN_TIME_MULT = 1

local def = {
	humanName = "Simple Pickup",
	description = [[
Fly to the planet and collect the person.

WSAD to move
]],
	nextLevel = "level1",
	gravity = 10,
	starCount = 350,
	noShooting = true,
	asteroidSpawn = {
	},
	shipSpawn = {
	},
	planets = {
		{
			name = "planet1",
			pos = {-900, 0},
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.15,
			age = "classical",
			maxAge = "classical",
			shootRateMult = 1,
			earlyAgeSpeed = 1/Global.EARLY_AGE_SECONDS,
			lateAgeSpeed = 1/Global.LATE_AGE_SECONDS,
			guySpeed = 4/Global.GUY_SECONDS,
			guyGap = 0,
			guyAgeBoost = 6,
			fillLastAge = false,
		},
	},
	goal = {
		planet1 = {
			philosopher = 1
		}
	},
	sun = {
		alignX = 0.5,
		alignY = 0.5,
		radius = 160,
		image = "sun",
	},
	asteroids = {
	},
	player = {
		pos = {-300, -500},
		orbitMult = -1.2,
	},
}

return def
