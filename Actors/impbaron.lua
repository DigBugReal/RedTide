--imp jaron
local SPRITE_PATH = path.combine(PATH, "Sprites/Actors/impBaron")
-- local SOUND_PATH = path.combine(PATH, "Audio/Actors/impBaron")

local sprite_idle			= Sprite.new("baronIdle", path.combine(SPRITE_PATH, "idle.png"), 1, 43, 88)

local baron = Object.new("ImpBaron", Object.Parent.ENEMY_CLASSIC)
baron:set_sprite(sprite_idle)
baron:set_depth(10)

local mlog = rt_create_monster_log("impBaronLog")
mlog.sprite_id = sprite_idle
mlog.portrait_id = sprite_idle
mlog.sprite_offset_x = 12
mlog.sprite_offset_y = 74
mlog.stat_hp = 350
mlog.stat_damage = 18
mlog.stat_speed = 1.4

--gm.constants.wJarSouls at 1.3 pitch

local primary = Skill.new("baronZ")
primary.cooldown = 7 * 60
local statePrimary = ActorState.new("baronPrimary")

Callback.add(baron.on_create, function(actor)
	-- actor.sprite_palette = sprite_palette
	actor.sprite_idle = sprite_idle
	actor.sprite_walk = sprite_idle
	
	actor.sprite_jump = sprite_idle
	actor.sprite_jump_peak = sprite_idle
	actor.sprite_fall = sprite_idle
	
	actor.sprite_death = sprite_idle
	actor.sprite_ping = sprite_idle

	actor.sound_hit = gm.constants.wImpHit
	actor.sound_hit_pitch = 0.6 --default is 1
	actor.sound_death = gm.constants.wImpDeath
	
	actor.can_jump = false
	-- damage, health, knockback cap/threshold, gold/exp reward
	actor:enemy_stats_init(18, 350, 50, 40)
	actor.pHmax_base = 1.7
	actor.z_range = 350 -- range of the primary

	actor.monster_log_drop_id = mlog.value
	
	actor:set_default_skill(Skill.Slot.PRIMARY, primary)
	actor:init_actor_late()
end)

Callback.add(primary.on_activate, function(actor, skill, slot)
	actor:set_state(statePrimary)
end)

Callback.add(statePrimary.on_enter, function(actor, data)
	actor.image_index = 0
	data.fired = 0
	data.dashTimer = 30
	if data.victim then
		data.victim = nil
	
	end
end)

Callback.add(statePrimary.on_step, function(actor, data)
	-- actor:skill_util_fix_hspeed()
	-- actor:actor_animation_set(sprite_idle, 0.23) -- 0.23 is anim speed value, its 0.23 to make the animation match the sound
	if data.fired == 1 then
		data.dashTimer = data.dashTimer - 1 
	end
	
	if data.dashTimer <= 0 or data.fired == 3 then
		actor:skill_util_reset_activity_state()
	
	end
	
	if data.fired == 0 then
		data.fired = 1
		actor:sound_play(gm.constants.wImpGShoot1, 1, 0.7 + math.random() * 0.2)
	end
	
	if data.fired == 1 and data.dashTimer > 0 then
		actor.pHspeed = (actor.pHmax * 5.6) * actor.image_xscale
		actor.pVspeed = 0
	
	end
	
	if actor:is_colliding(gm.constants.oP, actor.x + (10 * actor.image_xscale), actor.y) and data.fired ~= 2 and not data.victim then
		local victim = actor:get_collisions(gm.constants.oP, actor.x + (10 * actor.image_xscale), actor.y)[1]
		data.victim = victim
		
		if Net.host then
			actor:fire_direct(data.victim, 1, 0, victim.x, victim.y, nil, false)
		end
		
		victim:apply_knockback(actor.image_xscale, 91, 0, 1)
		victim.y = actor.y
		victim.pVspeed = 0
		victim.x = actor.x + (50 * actor.image_xscale)
		data.delay = 80
		data.fired = 2
	end
	
	if data.fired == 2 then
		actor.pHspeed = 0
		actor.pVspeed = 0
		local victim = data.victim
		victim.pVspeed = 0
		victim.y = actor.y
		victim.x = actor.x + (50 * actor.image_xscale)
		
		if data.delay and data.delay > 0 then data.delay = data.delay - 1 end
		
		if data.delay == 30 then
			actor:sound_play(gm.constants.wJarSouls, 1, 1.3 + math.random() * 0.2)
			actor.image_xscale = gm.choose(-1,1)
		end
		
		if data.delay <= 0 then
			actor:sound_play(gm.constants.wFwoosh, 1.4, 0.4 + math.random() * 0.2)
			victim:apply_knockback(actor.image_xscale, 50, 25, 1)
			victim.pVspeed = -10
			data.fired = 3
		end
		
	end
	
end)