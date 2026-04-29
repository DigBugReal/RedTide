--The Paul's New Hoove

local hooveBuff = Buff.new("paulBuff")
hooveBuff.icon_sprite = gm.constants.sBuffHandSpeed
hooveBuff.max_stack = 1
hooveBuff.show_icon = true

local hoove = Item.new("paulsNewHoove")
hoove:set_sprite(gm.constants.sHoof)
hoove:set_tier(ItemTier.find("conjoined"))

RecalculateStats.add(function(actor, api)
	local stack = actor:buff_count(hooveBuff)
	if stack <= 0 then return end 
	
	api.pHmax_add(0.28 + (0.84 * stack)) 
	api.attack_speed_add(0.1 + (0.3 * stack))
end)

Callback.add(hooveBuff.on_step, function(actor)
	if actor:buff_count(hooveBuff) > 0 and actor.hp > actor.maxhp * 0.301 then
		actor:buff_remove(hooveBuff)
	end
end)

Callback.add(Callback.ON_PLAYER_STEP, function(actor)

	local stack = actor:item_count(hoove)
	if stack <= 0 then return end
	
	if actor.hp < actor.maxhp * 0.301 and actor:buff_count(hooveBuff) <= 0 then
		actor:buff_apply(hooveBuff, 1)
	end
    
end)