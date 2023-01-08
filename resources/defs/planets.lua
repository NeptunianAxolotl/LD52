local images = {}

local toAdd = {
	"planet1",
	"planet2",
	"planet3",
	"planet4",
	"stone1",
	"stone2",
	"stone3",
	"classicalage",
	"victorianage",
	"modernage",
	"spaceage",
	"asteroid_damage_0",
	"asteroid_damage_1",
	"asteroid_damage_2",
	"bullet",
	"modern_bullet",
	"space_bullet",
}

for i = 1, #toAdd do
	local name = toAdd[i]
	images[#images + 1] = {
		name = name,
		form = "image", -- image, sound or animation
		file = "resources/images/planets/" .. name .. ".png",
		xScale = 0.00525,
		yScale = 0.00525,
		xOffset = 0.5,
		yOffset = 0.5,
	}
end

return images
