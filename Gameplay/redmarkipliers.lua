--Red Marks

--hud sprites
local hudSpr = Sprite.new("redMarkHud", path.combine(PATH, "Sprites/UI/redMarkCounter.png"), 1, 17, 3)
local symS = Sprite.new("redMarkSym1", path.combine(PATH, "Sprites/UI/markSymSmall.png"), 1, 17, 3)
local symB = Sprite.new("redMarkSym2", path.combine(PATH, "Sprites/UI/markSymBig.png"), 1, 17, 3)
local symM = Sprite.new("redMarkSym3", path.combine(PATH, "Sprites/UI/markSymMed.png"), 1, 17, 3)

--marks object sprites
local spr_mark1 = Sprite.new("redMarkSpr1", path.combine(PATH, "Sprites/Misc/redmark.png"), 6, 6, 9)
local spr_mark2 = Sprite.new("redMarkSpr2", path.combine(PATH, "Sprites/Misc/redmark2.png"), 6, 13, 16)
local spr_mark3 = Sprite.new("redMarkSpr3", path.combine(PATH, "Sprites/Misc/redmark3.png"), 6, 19, 21)

--Red Mark Object--
	--Global variable so you can just say "RedMark" in other files
	RedMark = Object.new("redMark")
	RedMark:set_sprite(spr_mark1)
	
	if not CurrentMarks then --so that hotloading doesn't reset the counter
		CurrentMarks = nil --counter for red marks
	end
	
	local RedMarkImg = Object.new("redMarkAfterImg") --for red mark afterimages
	
	Callback.add(RedMarkImg.on_create, function(self)
		self.parent = -4
		self.image_alpha = 1
	end)
	
	Callback.add(RedMarkImg.on_step, function(self)
		if self.image_alpha > 0 then
			self.image_alpha = self.image_alpha - 0.06
		else
			self:destroy()
		end
	end)
	
	--Red Mark functioning
	Callback.add(RedMark.on_create, function(self)
		self.target = -4
		self.speed = 0
		self.gravity = 0
		self.vspeed = 0
		self.hspeed = 0
		self.image_speed = 0.2
		
		local data = Instance.get_data(self)
		data.mark_value = 0 --mark_value is to be set manually whenever a mark is made
		data.pickup_timer = 90 --cooldown that won't allow pickup immediately on spawn
		data.pulse_timer = 61
		data.afterimg_timer = 16
		
	end)
	
	Callback.add(RedMark.on_step, function(self)
		if not Instance.get_data(self).mark_value or Instance.get_data(self).mark_value <= 0 then self:destroy() end

		if not self.target or self.target == -4 then --find the nearest player and set them as the target
			self.target = gm.player_util_nearest_player(self.x, self.y, true)
		end
		
		local data = Instance.get_data(self)
		
		--spawning
		if not data.pickup_timer then data.pickup_timer = 90 end
		
		data.pickup_timer = data.pickup_timer - 1
		
		if not data.did_spawn_sound then
			self:sound_play(gm.constants.wRevive, 0.7, (math.max(3, 9 - (data.mark_value))) + (math.random() * 0.6))
			data.did_spawn_sound = true
		end
		
		if data.pulse_timer == 60 or (data.foundPlayer and data.pulse_timer ~= -4) then
			local circ = Object.find("EfCircle", "ror")
			local theCircle = circ:create(self.x, self.y)
			theCircle.rate = 1
			theCircle.radius = 90
			theCircle.image_blend = Color.CRIMSON
			if not data.foundPlayer then
				data.pulse_timer = 59
			else
				data.pulse_timer = -4
			end
		end
		
		if data.pulse_timer == 0 then
			data.pulse_timer = 61
		
		end
		
		--change sprite based on value
		if data.mark_value > 0 then
			if data.mark_value > 4 and data.mark_value < 10 and self.sprite_index ~= spr_mark2.value then
				self.sprite_index = spr_mark2
			elseif data.mark_value >= 10 and self.sprite_index ~= spr_mark3.value then
				self.sprite_index = spr_mark3
			end
		end
		
		--player collision
		if self:is_colliding(gm.constants.oP, self.x, self.y) and data.pickup_timer <= 0 then
			if CurrentMarks == nil then
				CurrentMarks = data.mark_value
			else
				CurrentMarks = CurrentMarks + data.mark_value
			end
			self:destroy()
		end
		
		--speed control
		if self.speed > 0 then
			self.speed = self.speed - 0.005
		end
		if self.hspeed < 0 then
			self.hspeed = self.hspeed + 0.01
		end
		if self.hspeed > 0 then
			self.hspeed = self.hspeed - 0.01
		end
		if self.vspeed < 0 then
			self.vspeed = self.vspeed + (0.005 * -self.vspeed) * 2
		end
		if self.hspeed ~= 0 and not data.foundPlayer then
			self.image_angle = self.image_angle + (math.random() * self.hspeed)
		end
		
		--pickup
		local dist = Math.distance(self.x, self.y, self.target.x, self.target.y)
		
		if data.pickup_timer <= 0 then
		
			--grabrange preview if you're close to it
			if data.pulse_timer > 0 and dist <= 140 and not data.foundPlayer then
				data.pulse_timer = data.pulse_timer - 1
			end
			
			if dist <= 100 or data.foundPlayer then 
			
				self.direction = gm.point_direction(self.x, self.y, self.target.x, self.target.y + (-2 + math.random(0, 4)))
				self.speed = math.min(self.speed + 0.5, 15) --accelerate up to a max of 15
				
				self.image_speed = math.max(0.2, (0.05 * ((self.direction * 0.1) / (dist * 0.025)))) --make the sprite spin faster based on distance from player
				
				if self.x > self.target.x then --make the object rotate faster based on distance from player and where it's approaching from
					self.image_angle = self.image_angle + (0.7 * ((self.direction * 0.1) / (dist * 0.025)))
				
				elseif self.x < self.target.x then
					self.image_angle = self.image_angle - (0.7 * ((self.direction * 0.1) / (dist * 0.025)))
					
				end
				
				if not data.foundPlayer then data.foundPlayer = true end
			end
			
		else
			self.image_blend = Color.GRAY
		end
		
		if self.image_blend ~= Color.WHITE and data.pickup_timer <= 0 then
			self.image_blend = Color.WHITE
			local flash = GM.instance_create(self.x, self.y, gm.constants.oEfFlash)
			flash.parent = self
			flash.rate = 0.08
			flash.image_alpha = 1
			flash.image_blend = Color.WHITE
		end
		
		--afterimages
		if not data.afterimg_timer then data.afterimg_timer = 16 end
		
		if data.foundPlayer then --only do afterimages if a player has been found
			if data.afterimg_timer > 0 then data.afterimg_timer = data.afterimg_timer -1
			
			else data.afterimg_timer = 16 end
			
			if data.afterimg_timer == 15 then
				local img = RedMarkImg:create(self.x, self.y)
				img.parent = self
				img.sprite_index = self.sprite_index
				img.image_index = self.image_index
				img.image_speed = 0
				img.image_angle = self.image_angle
			end
		end
		
		--surface collision
		if self:is_colliding(gm.constants.pBlockFloor, self.x + (2 * self.image_xscale), self.y) and not data.foundPlayer then
			self.direction = self.direction * -1
			
		elseif self:is_colliding(gm.constants.pBlock, self.x + (2 * self.image_xscale), self.y) and not data.foundPlayer then
			--account for walls and ceilings
			if math.floor(self.direction) >= 30 and math.floor(self.direction) <= 150 then
				self.vspeed = self.vspeed * -1
			end
			
			if math.floor(self.direction) < 30 or math.floor(self.direction) > 150 then
				self.hspeed = self.hspeed * -1
			end
		end
	end)
	
	Callback.add(RedMark.on_destroy, function(self)
		local data = Instance.get_data(self)
		if not data.foundPlayer then return end --rest of code only happens if a mark is picked up by a player (ideally)
		GM.sound_play_global(gm.constants.wPickupOLD, 1, 1.5)
		GM.sound_play_global(gm.constants.wCoin, 3, math.max(0.3, 0.8 - (data.mark_value * 0.05)))

		local finalPart
		if data.mark_value > 4 and data.mark_value < 10 then
			finalPart = Global.pGoldSparkleBig
		elseif data.mark_value >= 10 then
			finalPart = Global.pJewelSparkleBig
		else
			finalPart = Global.pScoreSparkle
		end
		gm.part_particles_create_colour(Global.above, self.target.x, self.target.y, finalPart, Color.CRIMSON, 1)
	
	end)
	
--HUD and Counter--
	Hook.add_pre(gm.constants["run_create"], function() --reset counter at the start of each run
		if CurrentMarks then
			CurrentMarks = nil
		end
	end)

	Callback.add(Callback.ON_STAGE_START, function() --hide the counter next stage if you have 0

		if CurrentMarks and CurrentMarks <= 0 then 
			CurrentMarks = nil
		end

	end)

	Hook.add_pre(gm.constants["draw_hud_animation_update"], function(self, other, thing, args) --hud
		local Marks = CurrentMarks
		if not Marks then return end
		local x = Global.___view_l_x
		local y = Global.___view_l_y
		if not x or not y then return end
		gm.draw_set_halign(-2)
		gm.draw_set_valign(-2)
		GM.draw_sprite_ext(hudSpr, 0, x + 30, y + 67, 1, 1, 0, Color.WHITE, 1)
		gm.draw_set_color(Color.CRIMSON)
		gm.draw_set_font_w(Global.fntSquareNumBig)
		gm.draw_text(x + 44, y + 65, gm.string(Marks or 0), 0)
	end)

	Hook.add_post(gm.constants.interactable_cache_strings, function(self, other, result, args)
		if self.cost_type ~= "mark" then return end

		self._blend = Color.CRIMSON
		
		self._text = gm.translate("<spr redMarkSym3 1>" .. gm.string(self.cost))
		gm.scribble_set_starting_format("fntSquareMed", 16777215, 0)
		self.text_cost_small = gm.scribble_cache(gm.translate("<spr redMarkSym3 1>" .. gm.string(self.cost)))
		gm.scribble_set_starting_format("fntSquareLarge", 16777215, 0)
		self.text_cost_large = gm.scribble_cache(gm.translate("<spr redMarkSym2 1>" .. gm.string(self.cost)))
		self.cost_string = self._text
		self.cost_color = self._blend
	end)

	Hook.add_post(gm.constants.interactable_check_cost, function(self, other, result, args)
		if self.cost_type ~= "mark" then return end

		local inst_data = Instance.get_data(self)
		local director = gm._mod_game_getDirector()
		
		if not CurrentMarks or CurrentMarks < self.cost then
			result.value = false
		end
	end)

--old redmark implementation where it was a pickup

-- local mark = Object.new("redMarkPickup", Object.Parent.PICKUP_ITEM)
-- mark:set_sprite(hudSpr)

-- Callback.add(mark.on_create, function(self)
	-- self.show_pickup_display = false
	-- self.tier = ItemTier.find("conjoined", namespace)

-- end)

-- Hook.add_pre("gml_Object_oShrine3_Step_2", function(self, other)
		-- if self.active ~= 1 then return end
		-- for i = 1, math.random(3, 5) do
			-- Alarm.add(60 + (i * 2), function()
				-- rt_red_mark_create(self, 1, 1, 1, -2)
			-- end)
		-- end
-- end)

-- Callback.add(Callback.ON_PICKUP_COLLECTED, function(inst, actor)
	-- -- print(inst == mark)
	-- if inst:get_object_index() == mark.value then
		-- local data = Instance.get_data(actor)
		-- if not data.marks then
			-- data.marks = 1
		-- else
			-- data.marks = data.marks + 1
		-- end
		-- -- print(data.marks)
	-- end

-- end)