screen = 0

current_item = nil
debug = false 

music_enabled = true

function printd(...)
	if debug then
		print(...)
	end
end

function update_splash()
	splash_timer += 1
	pulse_timer = (pulse_timer + 1) % 60

	if btnp(5) then -- ❎
		screen = 1
	end
end

function draw_grid_background()
	for y = 0, 127, 8 do
		for x = 0, 127, 8 do
			pset(x, y, 2)
		end
	end
end

function draw_logo(x, y)
	palt(15, true)
	sspr(48, 0, 16, 16, x, y)
end

splash_timer = 0
pulse_timer = 0
title = "★ CSGO CRATE SIM ★"
start_msg = "press ❎ to start"

function draw_main_screen()
	cls(0)
	draw_grid_background()

	-- Title shimmer
	local shimmer_col = 7
	if (splash_timer % 30) < 15 then shimmer_col = 10 end
	print_centered(title, 64, shimmer_col)

	-- Animated crate (bobbing)
	local bounce = sin(splash_timer / 20) * 2
	draw_logo(56, 40 + bounce)

	-- Pulsing start message
	if pulse_timer < 25 then
		print_centered(start_msg, 100, 6)
	end
end

function print_centered(text, y, col)
	local x = 63 - (#text * 2)
	print(text, x, y, col)
end

function _init()
	menuitem(1, "toggle music", function()
		music_enabled = not music_enabled
		if music_enabled then
			music(0)
		else
			music(-1)
		end
	end)
	if music_enabled then
		music(0)
	end
end

function _update()
	if (btnp(4)) then
		if screen == 1 then
			if not roulette.active then
				screen = 2
			end
		else
			screen = 1
		end
	end

	if screen == 0 then
		update_splash()
	end
	
	if screen == 1 then
		if (btnp(5)) and not roulette.active then 
			start_roulette()
		end

		update_roulette()
		if current_item and current_item.update then
			current_item:update()
		end
		crate:update()
	end 
	if screen == 2 then
		update_stash()
	end
end

function draw_background()
	for y=0,127,16 do
		line(0, y, 127, y, 0)
	end
end

function _draw()
	cls()
	if screen == 0 then
		draw_main_screen()
	end
	if screen == 1 then
		draw_grid_background()
		if roulette.active then
			draw_roulette()
		else	
			if current_item then
				draw_item(current_item, 64-12, 64-12, 24, nil)
			end
			print("press ❎ - open case", 25, 110, 6)
			print("press 🅾️ - view stash", 23, 120, 6)
		end

		print("stash: " .. #stash, 0,0, 6)
	end
	if screen == 2 then
		draw_stash()
	end
end
