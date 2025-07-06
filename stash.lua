stash = { }

total = 0
for i=0,99,1 do
	item = get_random_item()
	add(stash, item)
	total = total + item.price
end
--printh("total: "..total.." avg: "..total/#stash)

selected_index = 1
current_page = 0
items_per_page = 20
cols = 5
rows = 4

function get_page_items(s, p)
	local start_idx = #s - p * items_per_page
	local end_idx = max(start_idx - items_per_page + 1, 1)

	local items = {}
	for i = start_idx, end_idx, -1 do
		add(items, i)
	end
	return items
end

function draw_stash()
	local spacing = 26
	local margin_x = 0
	local margin_y = 8

	local page_items = get_page_items(stash, current_page)

	for i , item_idx in ipairs(page_items) do
		local col = (i - 1) % cols
		local row = flr((i - 1) / cols)

		local x = margin_x + col * spacing
		local y = margin_y + row * spacing

		local item = stash[item_idx]
		draw_item(item, x, y, 24, nil)
	end

	--draw selected index
	local select_col = (selected_index-1) % cols
	local select_row = flr((selected_index-1)/cols)
	local x = margin_x + select_col*spacing
	local y = margin_y + select_row*spacing
	rect(x, y, x+spacing, y+spacing, 7)

	draw_item_description(stash[page_items[selected_index]])	

	print("stash (" .. #stash .. ") - ❎ to go back", 0, 0, 6)
	printd("i:"..tostr(selected_index).." x:"..tostr(select_col).." y:"..tostr(select_row))
	printd("p "..tostr(p))
end

rarity_sprites = {
	common = 48,
	rare = 49,
	epic = 50,
	legendary = 51,
}

function draw_item_description(item)
	local box_y = 110
	rectfill(0, box_y, 127, 127, 1)
	rect(0, box_y, 127, 127, 6)
	y = box_y + 3

	if item then
		print("type: "..item.type, 4, y, 7)
		local price_str = "$"..item.price
		local px = 126 - #price_str * 4
		print(price_str, px, y, 10)

		y += 8
		e_str = ""
		if item.effects and #item.effects > 0 then
			for e in all(item.effects) do
				e_str = e_str..e.name.." "
			end
			print("effects: " .. e_str, 4, y, 7)
		else
			print("effects: none", 4, y, 7)
		end
		local px = 126 - #item.rarity*4
		print(item.rarity, px, y)
	end
end

function update_stash()
	local stash_size = #stash
	local max_page = max(0, flr((stash_size - 1) / items_per_page))

	-- left
	if btnp(0) then
		if selected_index % items_per_page == 1 then
			-- move to next page if it exists
			if current_page > 0 then
				current_page -= 1
				selected_index = 20
			end
		else
			selected_index = max(1, selected_index - 1)
		end
	end

	-- right
	if btnp(1) then
		if selected_index % items_per_page == 0 then
			if current_page  < max_page  then
				current_page += 1
				selected_index = 1
			end
		else
			selected_index = min(20, selected_index + 1)
		end
	end

	local page_start = #stash - current_page * items_per_page
	local page_end = max(page_start - items_per_page + 1, 1)
	selected_index = mid(1, selected_index, min(items_per_page, #get_page_items(stash, current_page)))

	local start_idx = #stash - current_page * items_per_page
	local end_idx = max(start_idx - items_per_page + 1, 1)
	for i=start_idx, end_idx, -1 do
		local item = stash[i]
		if item.update then item:update() end
	end
end
