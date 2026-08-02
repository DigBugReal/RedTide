--its moeny

local kroner = Item.new("goldenCuffs")
kroner:set_sprite(gm.constants.sMoney)
kroner:set_tier(ItemTier.find("conjoined"))
ItemLog.new_from_item(kroner)

local mBuff = Buff.new("goldenCuffsDebuff")
mBuff.icon_sprite = gm.constants.sBuffs
mBuff.icon_subimage = 1
mBuff.max_stack = 10
mBuff.is_debuff = true
mBuff.is_timed = false
mBuff.show_icon = true
mBuff.draw_stack_number = true
mBuff.icon_stack_subimage = false

table.insert(CONJLIST, {"goldenCuffs", "prisonShackles", "smartShopper"})

RecalculateStats.add(function(actor, api)

	local stack = actor:buff_count(mBuff)
	if stack <= 0 then return end 
	local data = Instance.get_data(actor)
	if not data.itemValue then return end
	
	api.pHmax_mult((0.94 ^ stack) ^ data.itemValue)
	api.attack_speed_mult((0.94 ^ stack) ^ data.itemValue)
end)

Callback.add(Callback.ON_HIT_PROC, function(actor, victim, hit_info)
	local actor = hit_info.inflictor
	if actor:item_count(kroner) <= 0 then return end
	if not Instance.get_data(victim).moneyStole and victim.exp_worth > 0 then
		local coin = Object.find("EfGold"):create(victim.x, victim.y)
		coin.value.value = victim.exp_worth * (0.25 * actor:item_count(kroner))
		Instance.get_data(victim).moneyStole = true
		Instance.get_data(victim).itemValue = actor:item_count(kroner)
	end
	if not GM.actor_is_boss(victim) then
		if victim.hp >= victim.maxhp * 0.70 then
			victim:buff_apply(mBuff, 1)
		end
	else
		if victim.hp >= victim.maxhp * 0.95 then
			victim:buff_apply(mBuff, 1)
		end
	end
	
end)

-- DamageCalculate.add(function(api)
	-- for _, actor in ipairs(kroner:get_holding_actors()) do
		-- local stacks = actor:item_count(kroner)
		-- if api.hit.hp >= api.hit.maxhp * 0.70 then
			-- api.damage_mult(1.5, true)
		-- end
	-- end
-- end)

Callback.add(kroner.on_removed, function(actor, stack)
	local data = Instance.get_data(actor)
	if stack <= 1 then
		for _, victim in ipairs(mBuff:get_holding_actors()) do
			victim:buff_remove(mBuff, victim:buff_count(mBuff))
		end
	end
end)