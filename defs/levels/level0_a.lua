
local SPAWN_TIME_MULT = 1

local def = {
	humanName = "Armageddon",
	description = [[
Protect the planet and harvest the people.  Watch out for the asteroids!

WSAD/Arrow Keys to move. X/Numpad 0 to brake. Space/Enter/Z to shoot.

Shoot the asteroids, or nudge them out of the way with your ship if you're feeling adventurous.

Please don't shoot the planet.
]],
	nextLevel = "level1",
	prevLevel = "level0",
	gravity = 16,
	starCount = 750,
	asteroidSpawn = {
		{
			timeMin = 20 * SPAWN_TIME_MULT,
			timeRand = 8 * SPAWN_TIME_MULT,
			speedMin = 2,
			speedMax = 6,
			orbitMult = 0.75,
			orbitMultRand = 0.2,
			orbitOtherDirChance = 0,
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.4,
			typeName = {"asteroid_big", "asteroid_med", "asteroid_med"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				if count < 1 then
					return 3
				elseif count <= 2 then
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
			pos = util.RotateVector({-1000, 0}, -1.5),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			age = "iron",
			maxAge = "classical",
			shootRateMult = 1,
			earlyAgeSpeed = 1/Global.EARLY_AGE_SECONDS,
			lateAgeSpeed = 1/Global.LATE_AGE_SECONDS,
			guySpeed = 1/Global.GUY_SECONDS,
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
		{
			-- Designed to hit the planet early
			pos = util.RotateVector({-1000, 0}, 1.5),
			orbitMult = -1.005,
			typeName = "asteroid_big",
		},
		{
			-- Designed to hit the planet early
			pos = util.RotateVector({-1000, 0}, 2),
			orbitMult = -1.002,
			typeName = "asteroid_med",
		},
	},
	player = {
		pos = {-300, -500},
		orbitMult = -1.2,
	},
}

return def
