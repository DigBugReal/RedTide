--rok and role
local SPRITE_PATH = path.combine(PATH, "Sprites/Items")
local sprite_amp			= Sprite.new("fireAmp", path.combine(SPRITE_PATH, "fireAmp.png"), 1, 16, 16)
local sprite_bar			= Sprite.new("fireAmpBar", path.combine(SPRITE_PATH .. "/vfx" , "ampBar.png"), 7, 8, 9)

local amp = Item.new("fireAmp")
amp:set_sprite(sprite_amp)
amp:set_tier(ItemTier.find("conjoined"))
ItemLog.new_from_item(amp)

table.insert(CONJLIST, {"fireAmp", "ukulele", "willOTheWisp"})

-- account for survivor bars and such
local class_offsets = {
	[Survivor.find("drifter").value] = 19,
	[Survivor.find("sniper").value] = 22,
}

Callback.add(amp.on_acquired, function(actor, stack)
	local data = Instance.get_data(actor)
	if not data.static then
		data.static = 0
	end
	if not data.staticCooldown then
		data.staticCooldown = 0
	end
end)

Callback.add(amp.on_removed, function(actor, stack)
	local data = Instance.get_data(actor)
	if stack <= 1 then
		data.static = nil
		data.staticCooldown = nil
	end
end)

Callback.add(Callback.ON_PLAYER_STEP, function(actor)
	local stack = actor:item_count(amp)
	if stack <= 0 then return end
	local data = Instance.get_data(actor)
	
	if data.staticCooldown then
		if data.staticCooldown <= 0 then return end
		data.staticCooldown = data.staticCooldown - 1
		if data.static > 0 and Global._current_frame % 3 == 0 then
			data.static = data.static - 1
		end
	end
	
end)

Callback.add(Callback.ON_HIT_PROC, function(actor, victim, hit_info)
	local actor = hit_info.inflictor
	local stack = actor:item_count(amp)
	if stack <= 0 then return end
	local data = Instance.get_data(actor)
	
	if data.static and data.static >= 6 and data.staticCooldown and data.staticCooldown <= 0 then
		data.staticCooldown = 30
		local obj = Object.find("ChainLightning")
        local l1= obj:create(victim.x - 100, victim.y)
        l1.damage = hit_info.attack_info.damage * (stack * 2.5)
        l1.bounce = 3
        l1.range = 80
        l1.blend = Color.AQUA
		
		local l2= obj:create(victim.x + 100, victim.y)
        l2.damage = hit_info.attack_info.damage * (stack * 2.5)
        l2.bounce = 3
        l2.range = 80
        l2.blend = Color.FUCHSIA
		
		local newAttack = actor:fire_explosion(victim.x, victim.y, 30, 110, 5.5 + (2.5 * stack), gm.constants.sWispBMineFriendly).attack_info
		rt_set_no_proc(newAttack)
		victim:sound_play(gm.constants.wWispBShoot1_2, 1, 0.7)
		victim:sound_play(gm.constants.wWispBDeath, 1, 2)
		victim:apply_knockback(victim.image_xscale * -1, 20, 3, 1)
		victim:screen_shake(8)
	
	end
	
end)

Callback.add(Callback.ON_KILL_PROC, function(victim, actor)
	local stack = actor:item_count(amp)
	if stack <= 0 then return end
	local data = Instance.get_data(actor)
	
	if not data.static then
		data.static = 0
	end
	
	if data.static < 6 and data.staticCooldown <= 0 then
		data.static = data.static + 1
	end
	
end)

amp.effect_display = EffectDisplay.func(function(actor_unwrapped)
	local actor = Instance.wrap(actor_unwrapped)
	local data = Instance.get_data(actor)
	local x = actor.x + 21
	local y = actor.y

	local offset = class_offsets[actor.class]
	if offset then
		y = y + offset
	end
	
	GM.draw_sprite(sprite_bar, data.static, x, y)

end, EffectDisplay.DrawPriority.ABOVE)