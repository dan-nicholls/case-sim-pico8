-- Items
function get_random_gun()
	i = {
		sprite = {
			handle = gun_sprites.handle[get_random_index(gun_sprites.handle)],
			body = gun_sprites.body[get_random_index(gun_sprites.body)],
			barrel = gun_sprites.barrel[get_random_index(gun_sprites.barrel)],
		},
		type = "gun",
		price = 0,
		color = flr(rnd(13))+1,
		effects = get_random_effect(),
		update = function(self)
			for e in all(self.effects) do
				e:update(24,8)
			end
		end,
		draw = function(self, x, y)
			palt(15, true)

			for e in all(self.effects) do
				e:draw(x, y)
			end

			pal(4, self.color) 
			spr(self.sprite.handle, x, y)
			spr(self.sprite.body, x+8, y)
			spr(self.sprite.barrel, x+16, y)

			pal()

		end
	}
	i.price = get_item_price(i)
	i.rarity = get_rarity_tier(i.price)
	return i
end

function distribute_price(base_price, min_val, max_val, final_min, final_max)
	local norm = (base_price - min_val) / (max_val - min_val)
	norm = mid(0, norm, 1) -- clamp to [0,1] to avoid overshoot
	local curved = norm ^ 2.5
	return flr(final_min + (final_max - final_min) * curved)
end


function get_part_value(index)
	-- pseudo-fib sequence
	local values = {1, 2, 3, 5, 7, 11}
	return values[index] or 0
end

function index_of(tbl, val)
	for i=1, #tbl do
		if tbl[i] == val then
			return i
		end
	end
	return 1 -- fallback
end


function get_item_price(item)
	local price = 0

	if item.type == "gun" then
		local hi = index_of(gun_sprites.handle, item.sprite.handle)
		local bi = index_of(gun_sprites.body, item.sprite.body)
		local bai = index_of(gun_sprites.barrel, item.sprite.barrel)

		price = get_part_value(hi) + get_part_value(bi) + get_part_value(bai)
		price = distribute_price(price, 3, 33, 1, 30)
	elseif item.type == "knife" then
		local ti = index_of(knife_sprites.tip, item.sprite.tip)
		local bi = index_of(knife_sprites.blade, item.sprite.blade)
		local hi = index_of(knife_sprites.hilt, item.sprite.hilt)

		price = get_part_value(ti) + get_part_value(bi) + get_part_value(hi)
		price = distribute_price(price, 3, 33, 50, 1000)
	end

	-- Apply effect multipliers
	if item.effects then
		for e in all(item.effects) do
			price *= e.multiplier or 1
		end
	end

	return flr(price)
end

function get_rarity_tier(price)
	if price < 30 then return "common"
	elseif price < 80 then return "rare"
	elseif price < 200 then return "epic"
	else return "legendary"
	end
end

function get_random_index(l)
	return flr(rnd(#l)) + 1
end

knife_sprites = {
	tip = {128 ,129, 130, 131, 132, 133},
	blade = {144, 145, 146, 147, 148, 149},
	hilt = {160, 161, 162, 163, 164, 165}
}

gun_sprites = {
	handle = {64, 80, 96, 112, 67, 83},
	body = {65, 81, 97, 113, 68, 84},
	barrel = {66, 82, 98, 114, 69, 85},
}

function get_random_knife()
	i = {
		sprite = {
			tip = knife_sprites.tip[get_random_index(knife_sprites.tip)],
			blade = knife_sprites.blade[get_random_index(knife_sprites.blade)],
			hilt = knife_sprites.hilt[get_random_index(knife_sprites.hilt)],
		},
		type = "knife",
		price = 0,
		effects = get_random_effect(),
		update = function(self)
			for e in all(self.effects) do
				e:update(8, 24)
			end
		end,
		draw = function(self,x ,y)
			palt(15, true)

			for e in all(self.effects) do
				e:draw(x, y)
			end

			spr(self.sprite.tip, x, y)
			spr(self.sprite.blade, x, y+8)
			spr(self.sprite.hilt, x, y+16)
		end
	}
	i.price = get_item_price(i)
	i.rarity = get_rarity_tier(i.price)
	return i
end

crate = {
	x = 64,
	y = 80,
	scale = 1.0,
	time = 0,
	update = function(self)
		self.time += 0.1
		self.scale = 1.0 + abs(0.5*sin(self.time/4))
	end,
	draw = function(self)
		palt(15, true)
		local s = self.scale
		local x = self.x
		local y = self.y

		-- Top row
		sspr(0, 8, 16, 16, x, y, 16*s, 16*s)         -- sprite 16
	end
}

function get_random_item()
	local val = rnd(1)
	if val < 0.03 then
		return get_random_knife()
	else
		return get_random_gun()
	end
end

-- Effects
function make_glitter_effect()
	return {
		name = "glitter",
		multiplier = 2.4,
		particles = {},
		update = function(self, x, y)
			if rnd() < 0.3 then
				add(self.particles, {
					x=rnd(x),
					y=rnd(y),
					t=15
				})
			end
			for s in all(self.particles) do
				s.t -= 1
				if s.t <= 0 then
					del(self.particles, s)
				end
			end
		end,
		draw = function(self, x, y)
			for s in all(self.particles) do
				pset(x+s.x, y+s.y, 7)
			end
		end
	}
end

function make_fire_effect()
	return {
		name = "fire",
		multiplier = 6.8,
		particles = {},
		update = function(self, x, y)
			if rnd() < 0.025 then
				add(self.particles, {
					x=rnd(x),
					y=rnd(y),
					t=25,
				})
			end
			for p in all(self.particles) do
				p.t -= 1
				if p.t <= 0 then
					del(self.particles, p)
				end
			end
		end,
		draw = function(self, x, y)
			for p in all(self.particles) do
				spr(2, x+p.x, y+p.y)
			end
		end
	}
end

function make_star_effect()
	return {
		name = "star",
		multiplier = 3.2,
		particles = {},
		update = function(self, x, y)
			if rnd() < 0.05 then
				add(self.particles, {
					x=rnd(x),
					y=rnd(y),
					t=30,
					frame = 1
				})
			end
			for i = #self.particles, 1, -1 do
				local p = self.particles[i]
				p.t -= 1
				if p.t <= 0 then
					del(self.particles, p)
				end
			end
		end,
		draw = function(self, x, y)
			for p in all(self.particles) do
				spr(p.frame, x+p.x, y+p.y)
			end
		end
	}
end

function shuffle(t)
	for i = #t, 2, -1 do
		local j = flr(rnd(i)) + 1
		t[i], t[j] = t[j], t[i]
	end
end

function get_random_effect()
	local pool = {
		make_glitter_effect,
		make_fire_effect,
		make_star_effect
	}

	shuffle(pool)

	local effects = {}
	local chance = 0.15
	local decay = 0.4

	for effect_fn in all(pool) do
		if rnd() < chance then
			add(effects, effect_fn())
			chance *= decay
		else
			break
		end
	end

	return effects
end
