
local globals = {
	BACK_COL = {0/255, 0/255, 0/255},
	
	OUTLINE_COL = {100/255, 92/255, 89/255},
	PANEL_COL = {148/255, 131/255, 122/255},
	TEXT_COL = {1, 1, 1},
	
	OUTLINE_DISABLE_COL = {50/255, 46/255, 89*0.5/255},
	PANEL_DISABLE_COL = {148*0.5/255, 131*0.5/255, 122*0.5/255},
	TEXT_DISABLE_COL = {1 * 0.8, 1 * 0.8, 1 * 0.8},
	
	OUTLINE_HIGHLIGHT_COL = {100*1.2/255, 92*1.2/255, 89*1.2/255},
	PANEL_HIGHLIGHT_COL = {148*1.2/255, 131*1.2/255, 122*1.2/255},
	TEXT_HIGHLIGHT_COL = {1, 1, 1},
	
	OUTLINE_FLASH_COL = {100*1.6/255, 92*1.6/255, 89*1.6/255},
	PANEL_FLASH_COL = {148*1.6/255, 131*1.6/255, 122*1.6/255},
	TEXT_FLASH_COL = {1, 1, 1},
	
	BUTTON_FLASH_PERIOD = 0.5,
	
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
	
	GUY_FADE_IN_TIME = 1.2,
	SUN_ROTATE_FACTOR = 0.2,
	
	GUY_SECONDS = 10,
	EARLY_AGE_SECONDS = 12,
	LATE_AGE_SECONDS = 50,
	
	INIT_LEVEL = "level0",
	DRAW_PHYSICS = false,
	DRAW_ITEM_COUNTS = true,
	DEBUG_PLANET_NAME = false,
	
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