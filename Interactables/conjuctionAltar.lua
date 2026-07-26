local obj = Object.new("conjunction", Object.Parent.INTERACTABLE_CRATE)
obj:set_sprite(gm.constants.sShrine6)
obj:set_depth(1)

local animation_held_time   = 80
local animation_print_time  = 38
local left_x_offset         = -50
local right_x_offset         = 50
local holder_y_offset         = -60

local card = InteractableCard.new("conjunction")
card.object_id                      = obj
card.required_tile_space            = 0
card.spawn_with_sacrifice           = true
card.spawn_cost                     = 85
card.spawn_weight                   = 4
card.default_spawn_rarity_override  = 1
card.decrease_weight_on_spawn       = true

Hook.add_pre(gm.constants.run_create, function(self, other, result, args)
    local command = Artifact.find("command").active

    for id = 0, #Class.Stage - 1 do
        local stage = Stage.wrap(id)

        if not command then
            stage:add_interactable(card)
        else
            stage:remove_interactable(card)
        end

    end
end)

Hook.add_post(gm.constants.interactable_check_cost, function(self, other, result, args)
    if self:get_object_index() ~= obj.value then return end

    local inst_data = Instance.get_data(self)
    local actor = args[3].value
	actor.canUseConjoined = 0
	
	for i, list in ipairs(CONJLIST) do
		if actor:item_count(Item.find(list[2])) > 0 and actor:item_count(Item.find(list[3])) > 0 then
			actor.canUseConjoined = actor.canUseConjoined + 1
		end
	end
	if actor.canUseConjoined < 1 then
		result.value = false
	end
end)

Callback.add(obj.on_create, function(inst)
    inst.translation_key = "interactable.conjunction"
    inst.text = gm.translate(inst.translation_key..".text")
end)

Callback.add(obj.on_step, function(inst)
    local inst_data = Instance.get_data(inst)
    local actor = inst.activator
	
    -- Set item entry location
    inst_data.left_x = inst.x + left_x_offset
	inst_data.right_x = inst.x + right_x_offset
    inst_data.holder_y = inst.y + holder_y_offset



    if inst.active == 0 then
        inst_data.populate = false
        inst_data.animation_time = 0
        inst_data.animation_items = {}

    -- Initial activation (opened item picker UI)
    elseif inst.active == 1 then
        if not inst_data.populate then
            inst_data.populate = true

            -- Add items to contents
            local arr = Array.new()
			local itemList = Class.ITEM
            local size = 0
            for i, _ in ipairs(itemList) do
				local item = Item.wrap(i - 1)
				if item.tier == ItemTier.find("conjoined", namespace).value then
					size = size + 1
				end
            end
			
			--i am sorry
            for i = 0, 0 do
			
				for i, _ in ipairs(itemList) do
					local item = Item.wrap(i - 1)
					
					if item.tier == ItemTier.find("conjoined", namespace).value then
						
						for j, list in ipairs(CONJLIST) do
						
							if list[1] == item.identifier then

								for g, name in ipairs(list) do

									if g ~= 1 then

										if actor:item_count(Item.find(name)) > 0 then

											if g == 2 then
												actor.hasConj1 = true
											elseif g == 3 then
												actor.hasConj2 = true
											end

										end
									end
								
								end
							end
							
						end
						if actor.hasConj1 and actor.hasConj2 then
							arr:push(item.object_id)
							actor.hasConj1 = nil
							actor.hasConj2 = nil
						end
					end
					
				end
				
            end
			
			
            inst.contents = arr
        end

        -- [Client]  Send current selection to host
        if Net.client and Util.bool(actor.is_local) then
            inst_data.prev_selection = inst_data.prev_selection or 0
            if inst_data.prev_selection ~= inst.selection then
                inst_data.prev_selection = inst.selection
                packetSelect:send_to_host(inst, inst.selection)
            end
        end


    -- Item selected
    elseif inst.active == 3 then
        inst.last_move_was_mouse = true
        inst.owner = -4

        -- [Client]  Wait for packet from host
        if Net.client then
            inst.active = 100
            return
        end

        -- Get selected item
        local obj_id = inst.contents:get(inst.selection)
        inst_data.sel = Item.wrap(gm.object_to_item(obj_id))
		
		for i, list in ipairs(CONJLIST) do
		
			if list[1] == inst_data.sel.identifier then
				for g, name in ipairs(list) do
					if g ~= 1 then
						if actor:item_count(Item.find(name)) > 0 then
							if g == 2 then
								inst_data.item1 = Item.find(name)
							elseif g == 3 then
								inst_data.item2 = Item.find(name)
							end
						end
					end

				end
			end
	
		end
		
        -- Take item from inventory
        actor:item_take(inst_data.item1, 1)
		actor:item_take(inst_data.item2, 1)
        
        -- Start item animation
        for i = 1, 2 do
            -- x and y are offsets from the actor's position here
			local spriteID
			local xPos
			if i == 1 then
				spriteID = inst_data.item1.sprite_id
				xPos = ((1 - 1) * -17) + ((-0.5) * 34)
			else
				spriteID = inst_data.item2.sprite_id
				xPos = ((1 - 1) * -17) + ((0.5) * 34)
			end
            table.insert(inst_data.animation_items, {
                sprite  = spriteID,
                x       = xPos,
                y       = -48,
                scale   = 1.0
            })
        end
        inst:sound_play_at(gm.constants.wDroneRecycler_Activate, 1.0, 1.0, inst.x, inst.y)
        inst.active = 4
        
    -- Draw items above player
    elseif inst.active == 4 then
        -- Free actor
        GM.actor_activity_set(actor, 0)
		
        if inst_data.animation_time < animation_held_time then inst_data.animation_time = inst_data.animation_time + 1
        else
            -- Turn offsets into absolute positions
            for _, item in ipairs(inst_data.animation_items) do
                item.x = actor.x + item.x
                item.y = actor.y + item.y
            end
            inst.active = 5
        end


    -- Slide items towards hole
    elseif inst.active == 5 then
        local item1 = inst_data.animation_items[1]
		
		if math.distance(item1.x, item1.y, inst_data.left_x, inst_data.holder_y) < 1 then
			inst_data.animation_time = 0
			inst.active = 6
		end
		
        local item2 = inst_data.animation_items[2]
		
		if math.distance(item2.x, item2.y, inst_data.right_x, inst_data.holder_y) < 1 then
			inst_data.animation_time = 0
			inst.active = 6
		end
		

    -- Delay for scrapping sfx
    elseif inst.active == 6 then
        if inst_data.animation_time < animation_print_time then 
			inst_data.animation_time = inst_data.animation_time + 1
		end
		if inst_data.animation_time >= animation_print_time then
			inst.active = 7
        end

        if inst_data.animation_time == 6 then
            inst:sound_play_at(gm.constants.wDroneRecycler_Recycling, 1, 1, inst.x, inst.y)
        end


    -- Create drop(s) and reset
    elseif inst.active == 7 then

        local created = inst_data.sel:create(inst_data.left_x + 50, inst_data.holder_y - 20, inst)

        inst.active = 0
		if not inst_data.isDebug then
			inst:destroy()
		end

    end
	-- print(inst.active)
end)


Callback.add(obj.on_draw, function(inst)
    local inst_data = Instance.get_data(inst)
    local actor = inst.activator
	
	-- Draw items above player
    if inst.active == 4 then
        for _, item in ipairs(inst_data.animation_items) do
            rt_draw_item_sprite(item.sprite,
            actor.x + item.x,
            actor.y + item.y)
			-- item.y = math.lerp(item.y, item.y + actor.y, 0.1)
			
        end

		-- Slide items towards hole
    elseif inst.active == 5 then
        for i, item in ipairs(inst_data.animation_items) do
            rt_draw_item_sprite(item.sprite,
            item.x,
            item.y,
            math.easeout(item.scale, 3))
			if i == 1 then
				item.x = math.lerp(item.x, inst_data.left_x, 0.1)
			else
				item.x = math.lerp(item.x, inst_data.right_x, 0.1)
			end
            item.y = math.lerp(item.y, inst_data.holder_y, 0.1)
        end

    end
end)