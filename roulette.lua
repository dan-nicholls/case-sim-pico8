roulette = {
	items = {},
	offset = 0,
	speed = 4,
	accel = 0,
	active = false,
	timer = 0,
	winner = nil,
	last_center_idx = -1
}

function start_roulette()
	roulette.items = {}
	for i = 1, 30 do
		add(roulette.items, get_random_item())
	end
	roulette.offset = 0
	roulette.speed = 8
	roulette.accel = 0.995
	roulette.timer = 0
	roulette.active = true 
	roulette.winner = nil
	roulette.last_center_idx = -1

end

function update_roulette()
	if not roulette.active then return end

	roulette.offset += roulette.speed
	roulette.speed *= roulette.accel
	roulette.timer += 1

	local item_spacing = 32
	local center_x = 64
	local center_idx = flr((center_x + roulette.offset) / item_spacing) + 1

	if center_idx != roulette.last_center_idx then
		sfx(0)
		roulette.last_center_idx = center_idx
	end

	if roulette.speed < 2 then 
		roulette.speed = 0
		roulette.accel = 0
		roulette.active = false

		local total_width = #roulette.items * item_spacing
		local visual_offset = (roulette.offset + 64) % total_width
		local center_idx = flr(visual_offset / item_spacing) + 1

		roulette.winner = roulette.items[center_idx]
		current_item = roulette.winner
		add(stash, current_item)
		
		if current_item.type == "knife" or #current_item.effects > 0 then
			sfx(2)
		else
			sfx(1)
		end
	end
end

rarity_colors = {
	common = 6,
	rare = 3,
	epic = 2,
	legendary = 9,
}

function draw_item(item, x, y, box_size, col)
	if col then
		rect(x, y, x + box_size, y + box_size, col)
	end
	local cx = x
	local cy = y
	if item.type == "gun" then
		cx = x + (box_size/2)-(3*8/2)
		cy = y + (box_size/2)-4
	end
	if item.type == "knife" then
		cx = x + (box_size/2)-(1*8/2)
		cy = y + (box_size/2)-(3*8/2)
	end
	item:draw(cx, cy)
end

function draw_roulette()
	if not roulette.active then return end

	local spacing = 32
	local box_size = 30
	local cx = 64
	local cy = 64-(box_size/2)
	local total_width = #roulette.items * spacing

	for i=1, #roulette.items do
		local item = roulette.items[i]
		local raw_x = ((i-1) * spacing) - roulette.offset

		local x = raw_x % total_width
		if x > 128 then
			x -= total_width
		end

		if x >= -32 and x <= 128 then
			draw_item(item, x, cy, box_size, rarity_colors[item.rarity])
		end
	end

	local rect_y = 64-(box_size/2)-2
	line(cx, rect_y, cx, rect_y + box_size+4, 10)
end
