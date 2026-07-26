local SPRITE_PATH = path.combine(PATH, "Sprites/Actors/babyDevil")
local SOUND_PATH = path.combine(PATH, "Audio/Actors/babyDevil")

local sprite_idle			= Sprite.new("bDevilIdle", path.combine(SPRITE_PATH, "idle.png"), 1, 8, 9)
local sprite_death			= Sprite.new("bDevilDie", path.combine(SPRITE_PATH, "death.png"), 2, 8, 9)
sprite_death:set_speed(999999999) --please for the love of god just don't show the first frame when dying

local baby = Object.new("BabyDevil", Object.Parent.ENEMY_CLASSIC)
baby:set_sprite(sprite_idle)
baby:set_depth(10) 

local mlog = rt_create_monster_log("BabyDevilLog")
mlog.sprite_id = sprite_idle
mlog.portrait_id = sprite_idle
mlog.sprite_offset_x = 45
mlog.sprite_offset_y = 55
mlog.stat_hp = 30
mlog.stat_damage = 0
mlog.stat_speed = 1

Callback.add(baby.on_create, function(actor)
	-- actor.sprite_palette = sprite_palette
	actor.sprite_idle = sprite_idle
	actor.sprite_walk = sprite_idle
	actor.sprite_jump = sprite_idle
	actor.sprite_jump_peak = sprite_idle
	actor.sprite_fall = sprite_idle
	actor.sprite_death = sprite_death
	actor.sprite_ping = sprite_idle
	actor.team = 3
	-- actor.is_targettable = false --default is true
	-- actor.is_character_enemy_targettable = false --default is false
	-- actor.dirty = 1
	-- Object.find(gm.constants.oActorTargetPlayer):create(actor.x, actor.y)
	actor.babyWalkTimer = 0
	
	actor.sound_hit = gm.constants.wImpHit
	actor.sound_hit_pitch = 1.5 --default is 1
	actor.sound_death = gm.constants.wFwoosh
	
	actor.can_jump = true
	actor.leap_max_distance = 12
	-- damage, health, knockback cap/threshold, gold/exp reward
	actor:enemy_stats_init(0, 30, 0, 0)
	actor.pHmax_base = 2.4

	actor.monster_log_drop_id = mlog.value

	actor:init_actor_late()
end)

-- Hook.add_pre(gm.constants["actor_team_utils"], function()


-- end)


Hook.add_pre("gml_Object_oShrine3_Alarm_0", function(self, other)

	if math.random() <= 0.3 then
		Alarm.add(15, function() 	if not Util.bool(Global.__run_exists) then return end
			if not self.babies_dead then
				self.babies_dead = 0
			end
			local child = baby:create(self.x + math.random(-30, 30), self.y - 10)
			child:sound_play(gm.constants.wImpShoot2, 1, 3)
			child.parent = self
		end)
	end

end)

Hook.add_pre("gml_Object_oShrine3_Step_2", function(self, other)
	if self.active == 1 then
		self.give_marks = true
	end
	if self.time == 0 or self.minions_dead == self.minions_max then
		if (not self.babies_dead or self.babies_dead > 0) then self.babies_dead = nil return end
		
		if self.give_marks then
			for i = 1, math.random(3, 5) do
				Alarm.add(0 + (i * 15), function()		if not Util.bool(Global.__run_exists) then return end
					rt_red_mark_create(self, self.x, self.y + 20, 1, 1, 1, -2)
				end)
			end
			self.give_marks = false
			if self.doReward then
			 self.doReward = nil
			end
			self.babies_dead = nil
		end
	end
end)

Callback.add(baby.on_step, function(actor)
	if actor.parent then
		if actor.parent.time == 0 or not actor.parent.give_marks then
			actor.dontDoFunnyKill = true
			actor.hp = math.huge * -1
		end
	end
	actor:alarm_set(0, -1)
	if math.random() <= 0.005 and not actor.isFleeing then
		actor.isFleeing = true
		actor.dir = math.random(1,2)
		actor.babyWalkTimer = math.random(10, 40)
		actor:alarm_set(0, -1) -- disable the classic enemy ai -- not perfect but it does the job
	end
	
	if actor.babyWalkTimer <= 0 and actor.isFleeing then
		actor.isFleeing = false
		actor.moveLeft = false
		actor.moveRight = false
	end
	
	if Net.client then return end

	if actor.actor_state_current_id == -1 and actor.isFleeing and (actor.babyWalkTimer > 0 or not actor:is_grounded()) then
		if actor.babyWalkTimer > 0 then
			actor.babyWalkTimer = actor.babyWalkTimer - 1
		end
		
		local sync = false
		if actor.dir == 1 then
			actor.moveRight = true
			sync = true
		else
			actor.moveLeft = true
			sync = true
		end
		
		-- if actor.target.x > actor.x then
			-- if not Util.bool(actor.moveLeft) then sync = true end
			-- actor.moveLeft = true
			-- actor.moveRight = false
			-- else
			-- if not Util.bool(actor.moveRight) then sync = true end
			-- actor.moveLeft = false
			-- actor.moveRight = true
		-- end


		if math.random() < 0.1 then
			actor.moveUp = true
			sync = true
		end

		if sync then
			actor:net_send_instance_message(0) -- actor_position_info
		end
	end
	
end)

local bowl = Object.new("BabyBowl")
bowl:set_sprite(sprite_idle)

Callback.add(baby.on_destroy, Callback.Priority.BEFORE, function(self)
	if self.parent and not self.dontDoFunnyKill then
		self.parent.babies_dead = self.parent.babies_dead + 1
	end
	self.image_index = 1
	
	if self.dontDoFunnyKill then return end
	
	local goSon = bowl:create(self.x, self.y - 1)
	local player = gm.player_util_nearest_player(self.x, self.y, true)
	goSon.parent = player
	goSon.image_xscale = self.image_xscale * -1
	goSon.team = player.team


end)

Callback.add(bowl.on_create, function(inst)
	inst.speed = 7
	inst.parent = -4
	inst.gravity = 0.2
	inst.vspeed = 0
	local data = Instance.get_data(inst)
	data.hit_list = {}
	
end)

Callback.add(bowl.on_step, function(inst)
	if not Instance.exists(inst.parent) then
		inst:destroy()
		return
	end
	
	if Global.time_stop ~= 0 then
		inst.speed = 0
		inst.gravity = 0
		inst.vspeed = 0
	else
		if inst.speed == 0 then
			inst.speed = 7 * inst.image_xscale
		end
		gm.part_particles_create(Global.below, inst.x - (1 * inst.image_xscale), (inst.y - 8) + math.random(10), Global.pSpeed, 1)
	end
	
	local nextPosX = inst.x + (2 * inst.image_xscale)

	if not inst.set_facing then
		inst.speed = inst.speed * inst.image_xscale
		inst.set_facing = true
	end

	local data = Instance.get_data(inst)

	local actors = inst:get_collisions(gm.constants.pActorCollisionBase)

	for _, actor in ipairs(actors) do
		if actor:get_object_index() ~= baby.value then
			if inst:attack_collision_canhit(actor) and not data.hit_list[actor.id] then
				if Net.host then
					local attack = inst.parent:fire_direct(actor, 4, inst.direction, inst.x, inst.y, gm.constants.sEfBombExplodeEnemy).attack_info
					rt_set_no_proc(attack)
				end

				inst:sound_play(gm.constants.wClayHit, 0.5, 0.9)
				inst:sound_play(gm.constants.wMinerShoot4, 1, 2)
				inst:screen_shake(8)
				data.hit_list[actor.id] = true
			end
		end
	end
		if inst:is_colliding(gm.constants.pBlockFloor, inst.x, inst.y + 0.8 + (1 * math.ceil(inst.vspeed))) then
			inst.gravity = 0
			inst.vspeed = 0
				if inst:is_colliding(gm.constants.pBlockFloor, inst.x, inst.y) then
				inst.y = inst.y - (1 + 0.2)
			end
		elseif Global.time_stop == 0 then
			inst.gravity = 0.2
		end

	if inst:is_colliding(gm.constants.pBlock, nextPosX, inst.y) then
		inst:screen_shake(10)
		
		if Net.host then
			local attack = inst.parent:fire_explosion(inst.x, inst.y, 4, 4, 4, gm.constants.sEfBombExplodeEnemy).attack_info
			rt_set_no_proc(attack)
		end

		inst:sound_play(gm.constants.wClayHit, 0.5, 0.9)
		inst:sound_play(gm.constants.wMinerShoot4, 1, 2)

		inst:destroy()
	end
	
	if inst:is_colliding(gm.constants.oGeyser) then
		inst.vspeed = -23
		inst:sound_play(gm.constants.wGeyser, 1, 1)
	end
	
	if inst:is_colliding(gm.constants.oGeyserWeak) then
		inst.vspeed = -11.5
		inst:sound_play(gm.constants.wGeyser, 1, 1)
	end
	
end)