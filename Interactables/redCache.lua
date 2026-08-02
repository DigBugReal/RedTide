
local box = Object.new("redCache", Object.Parent.INTERACTABLE)
box:set_sprite(gm.constants.sChest1)
box:set_depth(90)

Callback.add(box.on_create, function(self)
	self:interactable_init()
	self.mask_index = gm.constants.sChest1
	Instance.get_data(self).marks_cost = math.random(5, 10)
	self.image_blend = Color.CRIMSON
	self:interactable_init_cost(self, "mark", Instance.get_data(self).marks_cost)
	self:interactable_init_name()
end)

Callback.add(box.on_step, function(self)
	local data = Instance.get_data(self)
	
	if data.open_delay then
		if data.open_delay > 0 then
			data.open_delay = data.open_delay - 1
		else
			data.open_delay = nil
		end
	end
	
	if self.active == 1 then
		self:sound_play(gm.constants.wChest1, 1, 1)
		self.active = 2
		self.image_speed = 0.2
		data.open_delay = 25
		Instance.get_data(gm._mod_game_getDirector()).marks = Instance.get_data(gm._mod_game_getDirector()).marks - data.marks_cost
	elseif self.active == 2 and data.open_delay == 0 then
		local randomConj = CONJLIST[math.random(#CONJLIST)]
		item1 = Item.find(randomConj[2])
		item2 = Item.find(randomConj[3])
		local inst1 = item1:create(self.x, self.y - 32)
		inst1.spawn_x = inst1.x + 16
		local inst2 = item2:create(self.x, self.y - 32)
		inst2.spawn_x = inst2.x - 16
	end

end)
Callback.add(Callback.ON_STAGE_START, Callback.Priority.BEFORE, function()
	if Object.find("conjunction", namespace) and #Instance.find_all(Object.find("conjunction", namespace)) >= 1 then
		local attempts = 0
		
		while Instance.count(box) == 0 and attempts < 48 do
			gm._mod_game_getDirector():mapobject_spawn(box.value, 1)
		end
	end
end)