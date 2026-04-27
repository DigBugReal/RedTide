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
	local x, y, team = actor.x, actor.y, actor.team
    
    -- Apply to all nearby allies
    local actors = Instance.find_all(gm.constants.pActor)
    for _, a in ipairs(actors) do
        if  a.team == team
        and math.distance(a.x, a.y, x, y) <= max_range then
            a:buff_apply(undyBuff, 60 * 5)
        end
    end
end)

--I SAID- I SAID HELLO DOWN THERE