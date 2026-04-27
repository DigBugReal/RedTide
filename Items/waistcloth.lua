--Oversized Waistcloth

local undyBuff = Buff.new("clothBuff")
undyBuff.icon_sprite = gm.constants.sEfWarbanner

local undy = Item.new("oversizedWaistcloth")
undy:set_sprite(gm.constants.sBanner)
undy:set_tier(ItemTier.BOSS)

RecalculateStats.add(function(actor, api)
	local stack = actor:buff_count(undyBuff)
	if stack <= 0 then return end 
	
	api.pHmax_add(0.6) --not actually 25% idfk how movespeed calc works;;
	api.attack_speed_add(0.25)
end)

Callback.add(Callback.ON_SKILL_ACTIVATE, function(actor, slot)
    if slot ~= Skill.Slot.SPECIAL then return end

    local stack = actor:item_count(undy)
    if stack <= 0 then return end
	
    actor:buff_apply(undyBuff, 60 * 5)
end)