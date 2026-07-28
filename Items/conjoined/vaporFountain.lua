--i love vaping

local vapor = Item.new("vaporFountain")
vapor:set_sprite(gm.constants.sGeyser)
vapor:set_tier(ItemTier.find("conjoined"))
ItemLog.new_from_item(vapor)

table.insert(CONJLIST, {"vaporFountain", "warbanner", "mortarTube"})

local fount = Object.new("vaporFountainObj")
fount:set_sprite(gm.constants.sGeyser)

local gust = Object.new("vaporFoundtainProj")
gust:set_sprite(gm.constants.sEfEngiMortar)

Callback.add(gust.on_create, function(self)
	self.speed = 10
	self.parent = -4
	self.gravity = 0.2
	self.vspeed = -10
	self.hspeed = math.random(-1, 1)
	self.image_blend = Color.AQUA

end)

Callback.add(gust.on_step, function(self)
	self.image_angle = self.direction
	
	local data = Instance.get_data(self)

	local actors = self:get_collisions(gm.constants.pActorCollisionBase)

	for _, actor in ipairs(actors) do
		if self:attack_collision_canhit(actor) then
			if Net.host then
				local attack = self.parent:fire_explosion(self.x, self.y, 150, 150, 1.3, gm.constants.sEfBombExplodeEnemy).attack_info
				rt_set_no_proc(attack)
			end

			self:sound_play(gm.constants.wWormExplosion, 1, 3)
			self:sound_play(gm.constants.wMinerShoot4, 1, 3)
			self:screen_shake(8)
			self:destroy()
		end
	end
	
	if self:is_colliding(gm.constants.pBlock, self.x, self.y + 1) then
		self:screen_shake(8)
		
		if Net.host then
			local attack = self.parent:fire_explosion(self.x, self.y, 150, 150, 1.3, gm.constants.sEfBombExplodeEnemy).attack_info
			rt_set_no_proc(attack)
		end

		self:sound_play(gm.constants.wWormExplosion, 1, 2)
		self:sound_play(gm.constants.wMinerShoot4, 1, 2)
		self:destroy()
	
	end
end)

Hook.add_post(gm.constants["player_level_up@gml_Object_oDirectorControl_Create_0"], function() 
	for _, actor in ipairs(vapor:get_holding_actors()) do
	
		local tain = fount:create(actor.x, actor.y)
		tain.parent = actor
	end
end)

Callback.add(fount.on_create, function(self)
	self.parent = -4
	self.fireTimer = 5 * 60
	self.image_speed = 0.2
	self.image_blend = Color.AQUA
	self.depth = 1
end)

Callback.add(fount.on_step, function(self)

	if not rt_is_colliding_stage(self, self.x, self.y + 1) then
		rt_move_contact_solid(self, 90)
	end
	
	if not self.parent then return end
	
	if self.fireTimer > 0 then
		self.fireTimer = self.fireTimer - 1
	end
	
	local bombCount = self.parent:item_count(vapor)
	
	if self.fireTimer <= 0 then
		for i = 1, 1 + (3 * bombCount) do
			Alarm.add(0 + ((i - 1) * math.max(5, (10 - bombCount))), function()		if not Util.bool(Global.__run_exists) then return end
				local bomb = gust:create(self.x - 10, self.y - 30)
				bomb.parent = self.parent
				bomb.team = self.parent.team
			end)
		
		end
		
		self.fireTimer = 5 * 60
	end

end)

Callback.add(Callback.ON_INTERACTABLE_ACTIVATE, function(interactable, actor)
	if actor:item_count(vapor) <= 0 then return end
	
	local currentTp = Instance.find(gm.constants.oTeleporter) or Instance.find(gm.constants.oTeleporterEpic) or Instance.find(gm.constants.oCommand)
	if not currentTp then return end
	
	if interactable == currentTp and interactable.active == 1 then
		local tain = fount:create(actor.x, actor.y)
		tain.parent = actor
	end
end)