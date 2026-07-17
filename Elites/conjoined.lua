local spritePaletteConj = Sprite.new("ElitePaletteConj", path.combine(PATH, "sprites/Elites/Conjoined/conjoined.png"))
local conjIcon = Sprite.new("EliteIconConj", path.combine(PATH, "sprites/Elites/Conjoined/conjicon.png"), 1, 14, 8)

local spritePaletteSplit = Sprite.new("ElitePaletteSplit", path.combine(PATH, "sprites/Elites/Conjoined/split.png"))
-- local splitIcon = Sprite.new("EliteIconSplit", path.combine(PATH, "sprites/Elites/Conjoined/splitIcon.png"), 2, 14, 10)
local splitIcon1 = Sprite.new("EliteIconSplit", path.combine(PATH, "sprites/Elites/Conjoined/split1.png"), 1, 14, 6)
local splitIcon2 = Sprite.new("EliteIconSplit2", path.combine(PATH, "sprites/Elites/Conjoined/split2.png"), 1, 14, 8)

local conje = Elite.new("conj")
conje:set_palette(spritePaletteConj)
conje.healthbar_icon = conjIcon
conje.blend_col = Color.CRIMSON



local split = Elite.new("split")
split:set_palette(spritePaletteSplit)
split.blend_col = Color.THISTLE
split.healthbar_icon = splitIcon1

local split2 = Elite.new("split2")
split2:set_palette(spritePaletteSplit)
split2.blend_col = Color.THISTLE
split2.healthbar_icon = splitIcon2

local conjOrb = Item.new("eliteOrbConj")
conjOrb.is_hidden = true

local splitOrb = Item.new("eliteOrbSplit")
splitOrb.is_hidden = true

Callback.add(conje.on_apply, function(actor)
	actor:item_give(conjOrb)
	if actor.exp_worth then
		actor.exp_worth = actor.exp_worth * 0
	end
end)

Callback.add(split.on_apply, function(actor)
	actor:item_give(splitOrb)
	if actor.exp_worth then
		actor.exp_worth = actor.exp_worth * 0.7
	end
end)

Callback.add(split2.on_apply, function(actor)
	actor:item_give(splitOrb)
	if actor.exp_worth then
		actor.exp_worth = actor.exp_worth * 0.7
	end
end)

conjOrb.effect_display = EffectDisplay.func(function(actor_unwrapped)
	local actor = Instance.wrap(actor_unwrapped)
	
	rt_do_afterimages(actor, Color.CRIMSON, 0.5)
	
end, EffectDisplay.DrawPriority.BODY_POST)

splitOrb.effect_display = EffectDisplay.func(function(actor_unwrapped)
	local actor = Instance.wrap(actor_unwrapped)
	
	rt_do_afterimages(actor, Color.THISTLE, 0.4)
	
end, EffectDisplay.DrawPriority.BODY_POST)

RecalculateStats.add(Callback.Priority.AFTER, function(actor, api)
	local stack = actor:item_count(conjOrb)
    if stack <= 0 then return end
	actor.threshBreak = 1
	api.maxhp_mult(4)
end)

RecalculateStats.add(Callback.Priority.AFTER, function(actor, api)
	local stack = actor:item_count(splitOrb)
    if stack <= 0 then return end
	
	api.maxhp_mult(0.40)
	api.damage_mult(0.7)
end)

Callback.add(Callback.ON_DEATH, function(actor)
	if actor:item_count(conjOrb) <= 0 then return end
	local clorne = Object.wrap(actor.object_index)
	local clorne1 = clorne:create(actor.x - 10, actor.y)
	GM.elite_set(clorne1, split)
	local clorne2 = clorne:create(actor.x + 10, actor.y)
	clorne2.image_xscale = clorne2.image_xscale * -1
	GM.elite_set(clorne2, split2)
end)

Callback.add(Callback.ON_STEP, function()
	if Net.client then return end

	for _, actor in ipairs(conjOrb:get_holding_actors()) do
		if Instance.exists(actor) then
			if actor.hp <= (actor.maxhp * 0.5) and actor.threshBreak == 1 then
				actor.threshBreak = 0
				actor:apply_knockback(-actor.image_xscale, math.huge, 0, 1)
				actor.intangible = 1
				Alarm.add(35, function()
					actor:kill()
				end)
			end
		end
	end
end)

Callback.add(Callback.ON_HIT_PROC, function(actor, victim, hit_info)
	if actor:item_count(conjOrb) <= 0 then return end
	
	if victim.team ~= actor.team then
		local dote = victim:apply_dot(0.35, 4, 30, hit_info, Color.RED, false)
		dote.parent = actor --the enemy that inflicts the dot will now show up as what killed you if you die to the bleed
	end
	
end)

Callback.add(Callback.ON_HIT_PROC, function(actor, victim, hit_info)
	if actor:item_count(splitOrb) <= 0 then return end
	
	if victim.team ~= actor.team then
		local dote = victim:apply_dot(0.35, 4, 30, hit_info, Color.RED, false)
		dote.parent = actor
	end
	
end)

local blacklist = {
	["magmaWorm"] = true, -- your mom
	["exploder"] = true,
}

-- the
local all_monster_cards = MonsterCard.find_all()
for i, card in ipairs(all_monster_cards) do
	if not blacklist[card.identifier] then
		local elite_list = List.wrap(card.elite_list)
		if not elite_list:contains(conje) then
			elite_list:add(conje)
		end
	end
end