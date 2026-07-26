--HA! Boom, baby!

local hooveBuff = Buff.new("paulBuff")
hooveBuff.icon_sprite = gm.constants.sBuffHandSpeed
hooveBuff.max_stack = 1
hooveBuff.show_icon = true

local hoove = Item.new("paulsNewHoove")
hoove:set_sprite(gm.constants.sHoof)
hoove:set_tier(ItemTier.find("conjoined"))
ItemLog.new_from_item(hoove)

table.insert(CONJLIST, {"paulsNewHoove", "paulsGoatHoof", "energyCell"})

RecalculateStats.add(function(actor, api)
	local stack = actor:buff_count(hooveBuff)
	local itemstack = actor:item_count(hoove)
	if stack <= 0 then return end 
	local data = Instance.get_data(actor)
		if data.hoovetimer >= 495 then
			if hooveBuff.icon_subimage ~= 9 then
				hooveBuff.icon_subimage = 9
			end
			api.pHmax_add(0.28 + (0.84 * itemstack)) 
		else
			if hooveBuff.icon_subimage ~= 0 then
				hooveBuff.icon_subimage = 0
			end
		end
		api.attack_speed_add((data.hoovetimer * itemstack) * 0.001)
end)

Callback.add(hooveBuff.on_step, function(actor)
	local data = Instance.get_data(actor)
	if actor:buff_count(hooveBuff) > 0 and data.hoovetimer and data.hoovetimer <= 0 then
		actor:buff_remove(hooveBuff)
	end
end)

hoove.effect_display = EffectDisplay.func(function(actor_unwrapped)
	local actor = Instance.wrap(actor_unwrapped)
	local data = Instance.get_data(actor)
	if data.hoovetimer and data.hoovetimer > 0 then
		rt_do_afterimages(actor, Color.ORANGE, 0.002 * data.hoovetimer)
	end
	
end, EffectDisplay.DrawPriority.BODY_POST)

Callback.add(Callback.ON_PLAYER_STEP, function(actor)

	local stack = actor:item_count(hoove)
	if stack <= 0 then return end
	
	local data = Instance.get_data(actor)
	if not data.hoovetimer then
		data.hoovetimer = 0
	else
		if data.hoovetimer <= 500 and data.hoovetimer > 0 then
			actor:buff_apply(hooveBuff, 1)
		end
		if actor.pHspeed ~= 0 and (actor.activity_type ~= 4 and actor.activity_type ~= 1) and data.hoovetimer < 500 then
			data.hoovetimer = data.hoovetimer + 1
		elseif data.hoovetimer > 0 then
			data.hoovetimer = data.hoovetimer - 1
		end
	end
    
end)

Callback.add(hoove.on_removed, function(actor, stack)
	local data = Instance.get_data(actor)
	if stack <= 1 then
		data.hoovetimer = nil
		if actor:buff_count(hooveBuff) > 0 then
			actor:buff_remove(hooveBuff)
		end
	end
end)