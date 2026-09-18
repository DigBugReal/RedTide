--imp jaron
local SPRITE_PATH = path.combine(PATH, "Sprites/Actors/impBaron")
-- local SOUND_PATH = path.combine(PATH, "Audio/Actors/impBaron")

local sprite_idle			= Sprite.new("baronIdle", path.combine(SPRITE_PATH, "idle.png"), 1, 43, 88)
local sprite_pal			= Sprite.new("baronPal", path.combine(SPRITE_PATH, "palette.png"), 1, 0, 0)

GM.elite_generate_palettes(sprite_pal)

local baron = Object.new("ImpBaron", Object.Parent.ENEMY_CLASSIC)
baron:set_sprite(sprite_idle)
baron:set_depth(11)

local buff = Buff.new("ImpBaronTossBuff")
buff.show_icon = false
buff.is_debuff = true

Callback.add(Callback.ON_STEP, function()
	for _, actor in ipairs(buff:get_holding_actors()) do
		local data = Instance.get_data(actor)
		
		--apply this to only classic actors (actors who interact with physics, have skills, etc)
		if GM.actor_is_classic(actor) and data.baronThrow then
			actor:skill_util_nudge_forward(actor.pHmax * data.baronThrow) 
			data.baronThrow = rt_approach(data.baronThrow, 0, 0.1)
			if actor:get_object_index() ~= gm.constants.oP then
				GM.actor_activity_set(actor, 0)
			end
		end
		
		if not data.baronThrow or data.baronThrow == 0 then
			actor:buff_remove(buff)
		end
	end
end)

local mlog = rt_create_monster_log("impBaronLog")
mlog.sprite_id = sprite_idle
mlog.portrait_id = sprite_idle
mlog.sprite_offset_x = 12
mlog.sprite_offset_y = 74
mlog.stat_hp = 350
mlog.stat_damage = 18
mlog.stat_speed = 1.4

local primary = Skill.new("baronZ")
primary.cooldown = 60 * 60
local statePrimary = ActorState.new("baronPrimary")

local secondary = Skill.new("baronX")
secondary.cooldown = 1 * 60
local stateSecondary = ActorState.new("baronSecondary")

Callback.add(baron.on_create, function(actor)
	actor.sprite_palette = sprite_pal
	actor.sprite_spawn = sprite_idle
	actor.sprite_idle = sprite_idle
	actor.sprite_walk = sprite_idle
	
	actor.sprite_jump = sprite_idle
	actor.sprite_jump_peak = sprite_idle
	actor.sprite_fall = sprite_idle
	
	actor.sprite_death = sprite_idle
	actor.sprite_ping = sprite_idle

	actor.sound_spawn = gm.constants.wImpHit
	actor.sound_hit = gm.constants.wImpHit
	actor.sound_hit_pitch = 0.6 --default is 1
	actor.sound_death = gm.constants.wImpDeath
	
	actor.can_jump = true
	-- damage, health, knockback cap/threshold, gold/exp reward
	actor:enemy_stats_init(18, 350, 50, 40)
	actor.pHmax_base = 1.7
	actor.z_range = 300 -- range of the primary
	actor.x_range = 300

	actor.monster_log_drop_id = mlog.value
	
	actor:set_default_skill(Skill.Slot.PRIMARY, primary)
	actor:set_default_skill(Skill.Slot.SECONDARY, secondary)
	actor:init_actor_late()
end)

--Baron Dash/PlayerGrab
Callback.add(primary.on_activate, function(actor, skill, slot)
	actor:set_state(statePrimary)
end)

Callback.add(statePrimary.on_enter, function(actor, data)
	actor.image_index = 0
	data.fired = 0
	data.dashTimer = 30
	data.windup = 25
	data.endlag = 40
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
	
	if data.windup == 25 then
		actor:sound_play(gm.constants.wImpShoot2, 1, 0.7 + math.random() * 0.2)
	end
	
	if (data.dashTimer <= 0 and data.fired == 1) or data.fired == 3 then
		actor.pHspeed = 0
		data.endlag = data.endlag - 1
	end
	
	if data.endlag <= 0 then
		actor:skill_util_reset_activity_state()
	end
	
	if data.fired == 0 then
		if data.windup > 0 then
			data.windup = data.windup - 1
			actor.pHspeed = (actor.pHmax * -2.8) * actor.image_xscale
			actor.pVspeed = 0
		else
			data.fired = 1
			actor:sound_play(gm.constants.wImpGShoot1, 1, 0.7 + math.random() * 0.2)
		end
	end
	
	if data.fired == 1 and data.dashTimer > 0 then
		actor.pHspeed = (actor.pHmax * 6.6) * actor.image_xscale
		actor.pVspeed = 0
	
	end
	
	if actor:is_colliding(gm.constants.pActor, actor.x + (10 * actor.image_xscale), actor.y) and data.fired == 1 and data.dashTimer > 0 and not data.victim then
		local victim = actor:get_collisions(gm.constants.pActor, actor.x + (10 * actor.image_xscale), actor.y)[1]
		--the .master variable is checked against to blacklist drones
		if victim.team ~= actor.team and not victim.master and not Instance.get_data(victim).baronGrabbed then
			data.victim = victim
			
			if Net.host then
				local attack = actor:fire_direct(data.victim, 2, 0, victim.x, victim.y, nil, true)
			end
			
			victim:apply_knockback(actor.image_xscale, 79, 0, 1)
			victim.y = actor.y
			victim.pVspeed = 0
			victim.x = actor.x + (50 * actor.image_xscale)
			Instance.get_data(victim).baronGrabbed = true
			data.delay = 80
			data.fired = 2
		end
	end
	
	if data.fired == 2 then
		actor.pHspeed = 0
		actor.pVspeed = 0
		local victim = data.victim
		if GM.actor_is_alive(victim) then
			victim.pVspeed = 0
			victim.y = actor.y
			victim.x = actor.x + (50 * actor.image_xscale)
			
			if data.delay and data.delay > 0 then data.delay = data.delay - 1 end
			
			if data.delay < 74 then
				victim.invincible = 5
			end
			
			if data.delay == 30 then
				actor:sound_play(gm.constants.wJarSouls, 1, 1.3 + math.random() * 0.2)
				actor.image_xscale = gm.choose(-1,1)
			end
			
			if data.delay <= 0 then
				actor:sound_play(gm.constants.wFwoosh, 1.4, 0.4 + math.random() * 0.2)
				victim.pVspeed = -13
				
				Instance.get_data(victim).baronThrow = 6 * actor.image_xscale
				victim:buff_apply(buff, 3 * 60, 1)
				Instance.get_data(victim).baronGrabbed = false
				
				data.fired = 3
			end
		else
			data.fired = 3
			
		end
		
	end
end)

--Baron Enemy Toss
Callback.add(secondary.on_activate, function(actor, skill, slot)
	local victim = actor:get_collisions(gm.constants.pActor, actor.x, actor.y)[1]
	if not (actor:is_colliding(gm.constants.pActor, actor.x, actor.y) and 
	victim.team == actor.team and victim:get_object_index() ~= gm.constants.pEnemyClassic and victim:get_object_index() ~= gm.constants.pEnemyFlying and
	gm.sprite_get_height(victim.sprite_idle) <= 53 and
	Instance.get_data(victim).baron_throwparent == nil) then return end
	-- print(gm.sprite_get_height(victim.sprite_idle))
	actor:set_state(stateSecondary)
end)

Callback.add(stateSecondary.on_enter, function(actor, data)
	actor.image_index = 0
	data.fired = 0
	data.enemyTossDelay = 80
	if data.victim then
		data.victim = nil
	end

end)

Callback.add(stateSecondary.on_step, function(actor, data)
	actor:skill_util_fix_hspeed()
	-- actor:actor_animation_set(sprite_idle, 0.23) -- 0.23 is anim speed value, its 0.23 to make the animation match the sound
	if data.fired == 0 then
		data.victim = actor:get_collisions(gm.constants.pActor, actor.x, actor.y)[1]
		local victim = data.victim
		
		victim:apply_knockback(actor.image_xscale, 79, 0, 1)
		victim.y = actor.y
		victim.pVspeed = 0
		victim.x = actor.x + (50 * actor.image_xscale)
		Instance.get_data(victim).baronGrabbed = true
		Instance.get_data(victim).baron_throwparent = actor
		
		data.fired = 1
	end
	
	if data.fired == 1 then
		local victim = data.victim
		if data.enemyTossDelay > 0 then
			data.enemyTossDelay = data.enemyTossDelay - 1
			
			victim.pVspeed = 0
			victim.y = actor.y
			victim.x = actor.x + (50 * actor.image_xscale)
			victim.invincible = 5
			
			
		else
			actor:sound_play(gm.constants.wFwoosh, 1.4, 0.4 + math.random() * 0.2)
			victim.pVspeed = -6
		
			Instance.get_data(victim).baronThrow = 5 * actor.image_xscale
			victim:buff_apply(buff, 3 * 60, 1)
			Instance.get_data(victim).baronGrabbed = false
			
			data.fired = 2
		end
	end
	
	if data.fired == 2 then
		actor:skill_util_reset_activity_state()
	end
end)

Hook.add_pre(gm.constants.actor_phy_on_landed, function(self, other, result, args)
    local actor = Instance.wrap(self)
    if not Instance.get_data(actor).baron_throwparent then return end
	
	local baron = Instance.get_data(actor).baron_throwparent
	local attack = baron:fire_explosion(actor.x, actor.y, 60, 40, 2.3, gm.constants.sHuntressMine2Explosion, nil)
	attack.y = attack.y - 6
	actor:screen_shake(11)
	actor:sound_play(gm.constants.wBoarExplosion, 1, 1.4)
	Instance.get_data(actor).baron_throwparent = nil
end)

local card = MonsterCard.new("baron")
card.object_id = baron.value
card.spawn_cost = 160
card.spawn_type = 0 --MonsterCard.SpawnType.CLASSIC
card.can_be_blighted = true

if HOTLOADING then return end

local stages = {
	"hiveCluster",
	"templeOfTheElders",
	"riskOfRain",
	"marshlandSanctuary",
	"crater",
	"verdantWoodland",
}

local postLoopStages = {
	"sunkenTombs",
	"ancientValley",
	"magmaBarracks",
	"skyMeadow",
	"torridOutlands",
	"whistlingBasin",
	"sanctuary"
}

for _, s in ipairs(stages) do
	local stage = Stage.find(s)
	
	if stage then
		stage:add_monster(card)
	end
end

for _, s in ipairs(postLoopStages) do
	local stage = Stage.find(s)
	
	if stage then
		stage:add_monster_loop(card)
	end
end