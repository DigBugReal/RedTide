--its moeny

local kroner = Item.new("moneyScraper")
kroner:set_sprite(gm.constants.sCrowbar)
kroner:set_tier(ItemTier.find("conjoined"))
ItemLog.new_from_item(kroner)

local mBuff = Buff.new("scraperDebuff")
mBuff.icon_sprite = gm.constants.sBuffs
mBuff.icon_subimage = 1
mBuff.max_stack = 1
mBuff.is_timed = false
mBuff.show_icon = true

table.insert(CONJLIST, {"moneyScraper", "crowbar", "smartShopper"})

RecalculateStats.add(function(actor, api)

	local stack = actor:buff_count(mBuff)
	if stack <= 0 then return end 
	local data = Instance.get_data(actor)
	if not data.scrapeSpeedValue then return end
	
	api.pHmax_mult(0.8 ^ data.scrapeSpeedValue)
	api.attack_speed_mult(0.8 ^ data.scrapeSpeedValue)
end)

Callback.add(Callback.ON_HIT_PROC, function(actor, victim, hit_info)
	local actor = hit_info.inflictor
	if actor:item_count(kroner) <= 0 then return end
	if not Instance.get_data(victim).moneyScraped and victim.exp_worth > 0 then
		victim.exp_worth = victim.exp_worth - (stack * 0.25) --currently also affects exp, not wanted
		local coin = Object.find("EfGold"):create(victim.x, victim.y)
		coin.value.value = victim.exp_worth * 0.25
		Instance.get_data(victim).moneyScraped = true
		Instance.get_data(victim).scrapeSpeedValue = actor:item_count(kroner)
		victim:buff_apply(mBuff, 1)
	end
	
end)

--trying to figure out how to only affect gold and not exp, just ripped from smart shopper bc i have no fucking clue what im doing
-- Callback.add(Callback.ON_KILL_PROC, function(actor, killer)
	-- if actor:buff_count(mBuff) <= 0 then print("fml") return end
	-- local actualWorth = actor.exp_worth * 0.75
	-- local dropValTotal = math.max(actualWorth * killer:item_count(kroner) * 0.25, 10)
	-- local dropAmtBase = math.max(1, math.min(25, dropValTotal / 10) * Global.__vfx_bias)
	-- local dropVal = dropValTotal / dropAmtBase
	-- local g = Object.find("EfGold"):create(actor.x, actor.y)
	-- g.direction = math.random(180)
	-- g.speed = gm.random_range(2,6)
	-- g.value.value = dropVal
-- end)

DamageCalculate.add(function(api)
	for _, actor in ipairs(kroner:get_holding_actors()) do
		local stacks = actor:item_count(kroner)
		if api.hit.hp >= api.hit.maxhp * 0.70 then
			api.damage_mult(1.5, true)
		end
	end
end)

Callback.add(kroner.on_removed, function(actor, stack)
	local data = Instance.get_data(actor)
	if stack <= 1 then
		for _, actor in ipairs(mBuff:get_holding_actors()) do
			actor:buff_remove(mBuff)
		end
	end
end)