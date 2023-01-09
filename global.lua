
local globals = {
	BACK_COL = {0/255, 0/255, 0/255},
	PANEL_COL = {0.53, 0.53, 0.55},
	
	MASTER_VOLUME = 0.75,
	MUSIC_VOLUME = 0.4,
	DEFAULT_MUSIC_DURATION = 174.69,
	CROSSFADE_TIME = 0,
	
	PHYSICS_SCALE = 300,
	LINE_SPACING = 36,
	INC_OFFSET = -15,
	
	WORLD_WIDTH = 4500,
	WORLD_HEIGHT = 3200,
	
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
	
	ABDUCT_VEL_MATCH_SQ = 600 * 600,
	ABDUCT_DIST_REQUIRE = 200,
	ABDUCT_SPEED = 2,
	
	REPEL_DIST = 150,
	REPEL_MAX_FORCE = 1300,
	GUY_AGE_END_DELAY = 10,
	
	WRAP_ALPHA_SIZE = 35,
	PLANET_RADIUS = 100,
	
	INIT_LEVEL = "testLevel",
	DRAW_PHYSICS = false,
}

return globals