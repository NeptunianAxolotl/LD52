
local globals = {
	BACK_COL = {0/255, 0/255, 0/255},
	
	OUTLINE_COL = {0.2, 0.2, 0.2},
	PANEL_COL = {0.53, 0.53, 0.55},
	TEXT_COL = {1, 1, 1},
	
	OUTLINE_DISABLE_COL = {0.2 * 0.5, 0.2 * 0.5, 0.2 * 0.5},
	PANEL_DISABLE_COL = {0.53 * 0.5, 0.53 * 0.5, 0.55 * 0.5},
	TEXT_DISABLE_COL = {1 * 0.8, 1 * 0.8, 1 * 0.8},
	
	OUTLINE_HIGHLIGHT_COL = {0.2 * 1.2, 0.2 * 1.2, 0.2 * 1.2},
	PANEL_HIGHLIGHT_COL = {0.53 * 1.2, 0.53 * 1.2, 0.55 * 1.2},
	TEXT_HIGHLIGHT_COL = {1, 1, 1},
	
	MASTER_VOLUME = 0.75,
	MUSIC_VOLUME = 0.4,
	DEFAULT_MUSIC_DURATION = 174.69,
	CROSSFADE_TIME = 0,
	
	PHYSICS_SCALE = 300,
	LINE_SPACING = 36,
	INC_OFFSET = -15,
	
	WORLD_WIDTH = 4500,
	WORLD_HEIGHT = 3200,
	UI_SPACE = 850,
	
	GRAVITY_MULT = 700000,
	SPEED_LIMIT = 1800,
	BULLET_SPEED_LIMIT = 2800,
	ACCEL_MULT = 155,
	EMERGENCY_BRAKE_MULT = 80,
	BRAKE_MULT = 35,
	BRAKE_DAMPEN = 2.2,
	TURN_MULT = 11500,
	MIN_TURN = 2600,
	
	SHOOT_COOLDOWN = 0.1,
	BULLET_RECHARGE = 0.45,
	BULLET_STOCKPILE = 4,
	SHOOT_SPEED = 1200,
	ASTEROID_WEIGHT_MULT = 1.2,
	
	ABDUCT_VEL_MATCH_SQ = 1000 * 1000,
	ABDUCT_DIST_REQUIRE = 240,
	ABDUCT_SPEED = 1.2,
	
	REPEL_DIST = 150,
	REPEL_MAX_FORCE = 1300,
	GUY_AGE_END_DELAY = 10,
	
	WRAP_ALPHA_SIZE = 35,
	PLANET_RADIUS = 110,
	
	INIT_LEVEL = "testLevel",
	DRAW_PHYSICS = false,
	
	AGE_IMAGE = {
		false,
		"stone1",
		"stone2",
		"stone3",
		"classicalage",
		"victorianage",
		"modernage",
		"spaceage",
	},
	DEAD_IMAGE = {
		planet1 = "planet1_dead",
		planet2 = "planet2_dead",
		planet3 = "planet3_dead",
		planet4 = "planet4_dead",
	},
}

return globals