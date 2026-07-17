local SPRITE_PATH = path.combine(PATH, "Sprites/Actors/babyDevil")
local SOUND_PATH = path.combine(PATH, "Audio/Actors/babyDevil")

local sprite_idle			= Sprite.new("bDevilIdle", path.combine(SPRITE_PATH, "idle.png"), 1, 10, 35)

local baby = Object.new("BabyDevil", Object.Parent.ENEMY_CLASSIC)
baby:set_sprite(sprite_idle)
baby:set_depth(10) 

local mlog = rt_create_monster_log("BabyDevilLog")
mlog.sprite_id = sprite_idle
mlog.portrait_id = sprite_idle
mlog.sprite_offset_x = 45
mlog.sprite_offset_y = 80
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
	actor.sprite_death = sprite_idle
	actor.sprite_ping = sprite_idle
	
	actor.babyWalkTimer = 0
	
	actor.can_jump = true
	actor.leap_max_distance = 12
	
	-- damage, health, knockback cap/threshold, gold/exp reward
	actor:enemy_stats_init(0, 30, 0, 0)
	actor.pHmax_base = 2.4

	actor.monster_log_drop_id = mlog.value

	actor:init_actor_late()
end)

Callback.add(Callback.ON_STEP, function()
	for _, shrine in ipairs(Instance.find_all(gm.constants.oShrine3)) do
		if shrine.sprite_index == shrine.sprite_death and not Instance.exists(gm.constants.oImpM) and not shrine.spawnedBaby then
			shrine.spawnedBaby = true
			Alarm.add(15, function()
				local child = baby:create(shrine.x, shrine.y - 20)
				child:sound_play(gm.constants.wImpShoot2, 1, 2)
			end)
		end
	end

end)

Callback.add(baby.on_step, function(actor)
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