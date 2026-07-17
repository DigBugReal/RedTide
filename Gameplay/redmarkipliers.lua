--Red Marks
local hudSpr = Sprite.new("redMarkHud", path.combine(PATH, "Sprites/UI/redMarkCounter.png"), 1, 17, 3)

local mark = Object.new("redMarkPickup", Object.Parent.PICKUP_ITEM)
mark:set_sprite(hudSpr)

-- Callback.add(mark.on_create, function(self)
	-- self.show_pickup_display = false
	-- self.tier = ItemTier.find("conjoined", namespace)

-- end)

Callback.add(Callback.ON_KILL_PROC, function(target, attacker)
	if target:get_object_index() == Object.find("BabyDevil").value then 
		-- local mar = mark:create(target.x, target.y - 15)
		
		local inst = Object.find("EfGold"):create(target.x, target.y - 50)
		inst.hspeed = (-1 * target.image_xscale) - (target.image_xscale * (math.random()))
		inst.inherit_angle = target.image_xscale
		inst.vspeed = math.random() * -0.8
		inst.gravity = 0
		inst.sprite_index = hudSpr
		inst.value.value = 0
		inst.is_mark = true
		inst.target = gm.player_util_nearest_player(inst.x, inst.y, true)
		--set a limit for how far they can fly away
		--make them bob in place
		--make them ignore collision
		--give them a collision ellipse so they can be grabbed
	end
end)

Hook.add_post("gml_Object_oEfGold_Step_2", function(self, other)
	if not self.is_mark then return end
	
	-- print(self.value.speed)
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
	
	self.image_angle = self.image_angle + (math.random() * self.inherit_angle)
	
	if gm.point_distance(self.x, self.y, self.target.x, self.target.y) <= 60 then 
		self:alarm_set(1, 1)
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

	if gm.point_distance(self.x, self.y, self.target.x, self.target.y) > 60 then 
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
		local data = Instance.get_data(self.target)
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
		local data = Instance.get_data(actor)
		if data.marks and data.marks <= 0 then 
			data.marks = nil
		end
	end

end)

Hook.add_pre(gm.constants["draw_hud_animation_update"], function(self, other, thing, args)
	local Marks = Instance.get_data(gm.view_player()).marks
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