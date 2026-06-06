-- local spriteIcon = Sprite.new("EliteIconBlooming", "~/sprites/Elites/Blooming/icon.png", 1, 14, 10)

local conje = Elite.new("conjeet")
-- conje:set_palette(spritePaletteConj)
conje.blend_col = Color.RED
-- conje.healthbar_icon = spriteIcon

local conjeSmall = Elite.new("conjsmal")
conje.blend_col = Color.MAROON

local conjOrb = Item.new("eliteOrbConj")
conjOrb.is_hidden = true

local conjOrbSmal = Item.new("eliteOrbConjSmal")
conjOrb.is_hidden = true

Callback.add(conje.on_apply, function(actor)
	actor:item_give(conjOrb)
	actor.maxhp = actor.maxhp * 1.1
	actor.hp = actor.maxhp
end)

Callback.add(conjeSmall.on_apply, function(actor)
	actor:item_give(conjOrbSmal)
	actor.maxhp = actor.maxhp * 0.25
	actor.hp = actor.maxhp
end)

Callback.add(Callback.ON_STEP, function()
	if Net.client then return end

	for _, actor in ipairs(conjOrb:get_holding_actors()) do
		if Instance.exists(actor) then
			local data = Instance.get_data(actor)
			local clorne = Object.wrap(actor.object_index)
			
			
			if actor.hp <= (actor.maxhp * 0.5) then
				local clorne1 = clorne:create(actor.x - 5, actor.y)
				GM.elite_set(clorne1, conjeSmall)
				local clorne2 = clorne:create(actor.x + 5, actor.y)
				GM.elite_set(clorne2, conjeSmall)
				actor:kill()
			end
		end
	end
end)

Callback.add(Callback.ON_ATTACK_HIT, function(hit_info)

	if hit_info.inflictor and (hit_info.inflictor:item_count(conjOrb) > 0 or hit_info.inflictor:item_count(conjOrbSmal) > 0 ) then
		victim = hit_info.target
		if victim.team ~= hit_info.inflictor then
			if hit_info.inflictor:item_count(conjOrb) > 0 then
				victim:apply_dot(0.35, 4, 30, hit_info, Color.RED, false)
			elseif hit_info.inflictor:item_count(conjOrbSmal) > 0 then
				victim:apply_dot(0.35, 4, 30, hit_info, Color.RED, false) --uhhh this but weaker
			end
		end
	end
	
end)

local blacklist = {
	["magmaWorm"] = true, -- your mom
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