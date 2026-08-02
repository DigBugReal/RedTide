--Red Marks
local hudSpr = Sprite.new("redMarkHud", path.combine(PATH, "Sprites/UI/redMarkCounter.png"), 1, 17, 3)
local symS = Sprite.new("redMarkSym1", path.combine(PATH, "Sprites/UI/markSymSmall.png"), 1, 17, 3)
local symB = Sprite.new("redMarkSym2", path.combine(PATH, "Sprites/UI/markSymBig.png"), 1, 17, 3)
local symM = Sprite.new("redMarkSym3", path.combine(PATH, "Sprites/UI/markSymMed.png"), 1, 17, 3)

local mark = Object.new("redMarkPickup", Object.Parent.PICKUP_ITEM)
mark:set_sprite(hudSpr)

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

Hook.add_post("gml_Object_oEfGold_Step_2", function(self, other)
	if not self.is_mark then return end
	if not self.target then return end
	
	-- if not self:place_meeting(self.value.x, self.value.y, gm.constants.pBlock) then
		-- self.value.speed = self.value.speed * -2
		-- self.value.hspeed = self.value.hspeed * -2
	-- end
	
	if self.value.speed > 0 then
		self.value.speed = self.value.speed - 0.005
	end
	
	if self.value.hspeed < 0 then
		self.value.hspeed = self.value.hspeed + 0.01
	end
	if self.value.hspeed > 0 then
		self.value.hspeed = self.value.hspeed - 0.01
	end
	if self.value.vspeed < 0 then
		self.value.vspeed = self.value.vspeed + (0.005 * -self.value.vspeed) * 2
	end
	
	if self.value.hspeed ~= 0 then
		self.image_angle = self.image_angle + (math.random() * self.value.hspeed)
	end
	if not self.value.pickup_timer then
		if Math.distance(self.x, self.y, self.target.x, self.target.y) <= 60 or self.value.foundPlayer then 
			self:alarm_set(1, 1)
			if not self.value.foundPlayer then self.value.foundPlayer = true end
		end
	else
		self.value.pickup_timer = self.value.pickup_timer - 1
		if self.value.pickup_timer <= 0 then self.value.pickup_timer = nil end
	end
	

end)

-- Callback.add(Callback.ON_STEP, function()

	-- for _, coin in ipairs(Instance.find_all(gm.constants.oEfGold)) do
		-- if not coin.is_mark then return end
		
		
		-- if coin.dead then
			-- local player = coin.target
			-- local data = Instance.get_data(player)

			
		-- end
		
		-- if not coin.dead and data then
			-- if not data.marks then
				-- data.marks = 1
			-- else
				-- data.marks = data.marks + 1
			-- end
		-- end
	-- end



-- end)

-- Hook.add_post("gml_Object_oEfGold_Create_0", function(self, other)
	
	-- -- value gets set after creation, so waiting a frame to change it
	-- Alarm.add(1, function()
		-- if Instance.exists(self) then
			-- self.value.value = 0
			-- self.is_red_mark = true
		-- end
	-- end)

	-- -- local data = Instance.get_data(self)
	-- -- data.lifetime = 1000
-- end)

local alarm_hook = Hook.add_post("gml_Object_oEfGold_Alarm_1", function(self, other)
	if not self.is_mark then return end
	
	if Math.distance(self.x, self.y, self.target.x, self.target.y) > 60 and not self.value.foundPlayer then 
		self.value.speed = 5
		self.value.hspeed = 0
		self.value.vspeed = 0
	end
	

end)

Hook.add_post("gml_Object_oEfGold_Alarm_2", function(self, other)
	if not self.is_mark then return end
	if Global._mod_sound_isPlaying(gm.constants.wCoin) > 0 then
		GM.audio_stop_sound(gm.constants.wCoin)
		GM.sound_play_global(gm.constants.wPickupOLD, 1, 1.5)
		GM.sound_play_global(gm.constants.wCoin, 1, 0.7)
		local data = Instance.get_data(gm._mod_game_getDirector())
		if not data.marks then
			data.marks = 1
		else
			data.marks = data.marks + 1
		end
	end
end)

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

Callback.add(Callback.ON_STAGE_START, function()
	for _, actor in ipairs(Instance.find_all(gm.constants.oP)) do
		local data = Instance.get_data(gm._mod_game_getDirector())
		if data.marks and data.marks <= 0 then 
			data.marks = nil
		end
	end

end)

Hook.add_pre(gm.constants["draw_hud_animation_update"], function(self, other, thing, args)
	local Marks = Instance.get_data(gm._mod_game_getDirector()).marks
	if not Marks then return end
    local x = Global.___view_l_x
    local y = Global.___view_l_y
    if not x or not y then return end
	gm.draw_set_halign(-2)
	gm.draw_set_valign(-2)
	GM.draw_sprite_ext(hudSpr, 0, x + 30, y + 67, 1, 1, 0, Color.WHITE, 1)
	gm.draw_set_color(Color.WHITE)
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
	
	if not Instance.get_data(director).marks or Instance.get_data(director).marks < self.cost then
		result.value = false
	end
end)