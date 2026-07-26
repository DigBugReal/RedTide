--  <1>	Cloak and Dagger 
--			Common 
--
--- 		Skill 
--		Gain 6 Block. 
--Add 1 Shiv into your Hand.

local silent = Item.new("cloakDagger")
silent:set_sprite(gm.constants.sScarf)
silent:set_tier(ItemTier.find("conjoined"))
ItemLog.new_from_item(silent)

table.insert(CONJLIST, {"cloakDagger", "hermitsScarf", "rustyKnife"})

DamageDodge.add(function(api, current_dodge)
	if not api.hit then return end
	if not Instance.exists(api.hit) then return end
	if api.hit ~= gm.constants.oP then return end
	if api.hit:item_count(silent) <= 0 then return end
	
	local stack = api.hit:item_count(silent)
	
	local formula = ((0.1 * stack) / ((0.1 * stack) + 1)) * 0.7
	
	if math.random() <= formula then
		-- print(formula)
		local flash = Object.find("EfFlash"):create(api.hit.x, api.hit.y)
		flash.parent = api.hit
		flash.rate = 0.1
		flash.image_alpha = 1
		
		api.hit.invincible = math.max(api.hit.invincible, 50)
		
		return DamageDodge.EVADED
	end
end)

Hook.add_pre(gm.constants["actor_on_dodge"], function(actor)
	if actor:item_count(silent) <= 0 then return end
	GM.apply_buff(actor, Buff.find("smokebomb"), (2 + (2 * actor:item_count(silent))) * 30)
	
	local bufflist = List.new()
	actor:collision_rectangle_list(actor.x - 75, actor.y - 35, actor.x + 75, actor.y + 35, gm.constants.pActor, false, true, bufflist, false)
	for _, victim in ipairs(bufflist) do
		if victim.team ~= actor.team then
			victim:apply_knockback(actor.image_xscale * -1, 45, 1, 1)
			victim:apply_dot(0.35, 8, 30, actor, Color.RED, false)
		end
	end	
	bufflist:destroy()
	
end)