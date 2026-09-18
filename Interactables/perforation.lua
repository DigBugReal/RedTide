local spr_perf_1 = Sprite.new("redPerfSpr1", path.combine(PATH, "Sprites/Misc/perf.png"), 1, 43, 47)
local standin = Object.new("redPerfSpot", Object.Parent.INTERACTABLE)
standin:set_sprite(gm.constants.sAmethyst)
standin:set_depth(90)

-- local crystal = Object.new("redPerf", Object.Parent.MAP_OBJECTS)
-- crystal:set_sprite(gm.constants.sAmethyst)
-- crystal:set_depth(90)

-- Callback.add(crystal.on_create, function(self)
	-- self.active = 0
	-- self.active_total = 0
	-- self.active_thres = math.random(3, 8)
	-- self.m_id = 0
	-- self.image_blend = Color.CRIMSON
	-- self.image_speed = 0
-- end)

-- Callback.add(crystal.on_destroy, function(self)
	-- self:sound_play(gm.constants.wSmite, 1, 1.5)
	-- -- Global.screen_shake(15)
-- end)

-- Callback.add(crystal.on_step, function(self)
	-- if self:place_meeting(self.x, self.y, gm.constants.oExplosionAttack) then

		-- self.active = self.active + 1
		-- gm.net_send_instance_message(31)
	
	-- end
	
	-- if self.active > 0 then
		-- self.active_total = self.active_total + self.active
		-- self.active = 0
		-- self:sound_play(gm.constants.wGolemHit, 0.7, 1.5)
	
	-- end
	
	-- if self.active_total >= self.active_thres then
		-- self:destroy()
	-- end
-- end)

Callback.add(standin.on_create, function(self)
	self:interactable_init()
	self:interactable_init_name()
end)

Callback.add(standin.on_step, function(self)
	if not self.made_crystal then
		local crys = Object.find("BlockDestroy"):create(self.x, self.y - 30)
		crys.sprite_index = spr_perf_1
		crys.image_index = 0
		crys.depth = 90
		crys.active_thres = math.random(1, 8)
		-- crys.image_speed = 0
		crys.is_red_perf = true
		
		self.made_crystal = true
	else
		self:destroy()
		
	end

end)

Hook.add_pre("gml_Object_oBlockDestroy_Step_2", function(self, other, result, args)
	if not self.is_red_perf then return end
	
	if self.active_total >= self.active_thres then
		self:destroy()
	end
	
	if self.active ~= 0 then
		for i = 1, math.random(1,2) do
			local coin = RedMark:create(self.x + math.random(-10,10), self.y)
			Instance.get_data(coin).mark_value = 1
			coin.speed = gm.choose(1, 2) * gm.choose(-0.8, 0.8)
			coin.hspeed = coin.speed
			coin.vspeed = math.random(0, 2) * -0.5
		end
		
	end


end)

Hook.add_pre("gml_Object_oBlockDestroy_Destroy_0", function(self, other, result, args)
	if not self.is_red_perf then return end
	
	--add conjoined to the elite pool
	local conje = Elite.find("conj", "RedTide")
	
	local blacklist = {
		["magmaWorm"] = true,
		["betaConstruct"] = true,
	}
	
	local all_monster_cards = MonsterCard.find_all()
	for i, card in ipairs(all_monster_cards) do
		if not blacklist[card.identifier] then
			local elite_list = List.wrap(card.elite_list)
			if not elite_list:contains(conje) then
				elite_list:add(conje)
			end
		end
	end
	
	self:sound_play(gm.constants.wSmite, 1, 1.5)
	self:screen_shake(15)
	
	return false

end)


Callback.add(Callback.ON_STAGE_START, Callback.Priority.BEFORE, function()

	local attempts = 0

	while Instance.count(standin) == 0 and attempts < 48 do
		gm._mod_game_getDirector():mapobject_spawn(standin.value, 1)
	end
	
end)