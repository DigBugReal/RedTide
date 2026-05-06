-- --taken mostly from scrapper.lua
-- --still wip

-- local obj = Object.new("conjunction", Object.Parent.INTERACTABLE_CRATE)
-- obj:set_sprite(gm.constants.sShrine6)
-- obj:set_depth(1)

-- local animation_held_time   = 80
-- local animation_print_time  = 38
-- local left_x_offset         = -50   -- Location of the hole of the scrapper relative to the origin
-- local right_x_offset         = 50   -- Location of the hole of the scrapper relative to the origin
-- local holder_y_offset         = -60


-- Hook.add_post(gm.constants.interactable_check_cost, function(self, other, result, args)
    -- if self:get_object_index() ~= obj.value then return end

    -- local inst_data = Instance.get_data(self)
    -- local actor = args[3].value

    -- -- temp
	-- local conItems = 1
    -- if conItems > 0 then
        -- for i = 0, conItems - 1 do
            -- local item = Item.find("paulsNewHoove", "RedTide")
			
			-- return
        -- end
    -- end

    -- -- If not, prevent usage
    -- result.value = false
-- end)


-- Callback.add(obj.on_step, function(inst)
    -- local inst_data = Instance.get_data(inst)
    -- local actor = inst.activator

    -- -- Set item entry location
    -- inst_data.left_x = inst.x + left_x_offset
	-- inst_data.right_x = inst.x + right_x_offset
    -- inst_data.holder_y = inst.y + holder_y_offset



    -- if inst.active == 0 then
        -- inst_data.populate = false
        -- inst_data.animation_time = 0
        -- inst_data.animation_items = {}
		-- if not inst_data.morphinTime then
			-- inst_data.taken_count = 0
		-- end


    -- -- Initial activation (opened item picker UI)
    -- elseif inst.active == 1 then
        -- if not inst_data.populate then
            -- inst_data.populate = true

            -- -- Add items to contents
            -- local arr = Array.new()
            -- local size = #actor.inventory_item_order
            -- for i = 0, size - 1 do
                -- local item = actor.inventory_item_order:get(i)
                -- local wrapped = Item.wrap(item)
                -- arr:push(wrapped.object_id)
            -- end
            -- inst.contents = arr
        -- end

        -- -- [Client]  Send current selection to host
        -- if Net.client and Util.bool(actor.is_local) then
            -- inst_data.prev_selection = inst_data.prev_selection or 0
            -- if inst_data.prev_selection ~= inst.selection then
                -- inst_data.prev_selection = inst.selection
                -- packetSelect:send_to_host(inst, inst.selection)
            -- end
        -- end


    -- -- Item selected
    -- elseif inst.active == 3 then
        -- inst.last_move_was_mouse = true
        -- inst.owner = -4

        -- -- [Client]  Wait for packet from host
        -- if Net.client then
            -- inst.active = 100
            -- return
        -- end

        -- -- Get selected item
        -- local obj_id = inst.contents:get(inst.selection)
        -- inst_data.taken = Item.wrap(gm.object_to_item(obj_id))

        -- -- Take item from inventory
        -- actor:item_take(inst_data.taken, 1)
        
        -- -- Start scrapper animation
        -- for i = 1, 1 do
            -- -- x and y are offsets from the actor's position here
            -- table.insert(inst_data.animation_items, {
                -- sprite  = inst_data.taken.sprite_id,
                -- x       = ((1 - 1) * -17) + ((i - 1) * 34),
                -- y       = -48,
                -- scale   = 1.0
            -- })
        -- end
        -- inst:sound_play_at(gm.constants.wDroneRecycler_Activate, 1.0, 1.0, inst.x, inst.y)
		-- inst_data.taken_count = inst_data.taken_count + 1
		-- print(inst_data.taken_count)
        -- inst.active = 4

        -- -- [Host]  Send sync info to clients
        -- -- if Net.host then
            -- -- packetUse:send_to_all(inst, inst_data.taken, inst_data.taken_count)
        -- -- end

        
    -- -- Draw items above player
    -- elseif inst.active == 4 then
        -- -- Free actor
        -- GM.actor_activity_set(actor, 0)
		
        -- if inst_data.animation_time < animation_held_time then inst_data.animation_time = inst_data.animation_time + 1
        -- else
            -- -- Turn offsets into absolute positions
            -- for _, item in ipairs(inst_data.animation_items) do
                -- item.x = actor.x + item.x
                -- item.y = actor.y + item.y
				-- item.useNum = inst_data.taken_count
            -- end
            -- inst.active = 5
        -- end


    -- -- Slide items towards hole
    -- elseif inst.active == 5 then
        -- local item = inst_data.animation_items[1]
		-- if not inst_data.morphinTime then
			-- inst_data.morphinTime = true
		-- end
		-- if inst_data.taken_count == 1 then
			-- if math.distance(item.x, item.y, inst_data.left_x, inst_data.holder_y) < 1 then
				-- inst_data.animation_time = 0
				-- inst.active = 0
			-- end
		-- elseif inst_data.taken_count == 2 then
			-- if math.distance(item.x, item.y, inst_data.right_x, inst_data.holder_y) < 1 then
				-- inst_data.animation_time = 0
				-- inst.active = 6
			-- end
		-- end
		

    -- -- Delay for scrapping sfx
    -- elseif inst.active == 6 then
        -- if inst_data.animation_time < animation_print_time then 
			-- inst_data.animation_time = inst_data.animation_time + 1
		-- end
		-- if inst_data.animation_time >= animation_print_time then
			-- inst.active = 7
        -- end

        -- if inst_data.animation_time == 6 then
            -- inst:sound_play_at(gm.constants.wDroneRecycler_Recycling, 1, 1, inst.x, inst.y)
        -- end


    -- -- Create drop(s) and reset
    -- elseif inst.active == 7 then

		-- local conjoinedIt = Item.find("paulsNewHoove", "RedTide")
        -- local created = conjoinedIt:create(inst_data.left_x + 50, inst_data.holder_y - 20, inst)

        -- inst.active = 0
		-- inst_data.morphinTime = false
		

    -- end
-- end)


-- Callback.add(obj.on_draw, function(inst)
    -- local inst_data = Instance.get_data(inst)
    -- local actor = inst.activator
	
	-- -- Draw items above player
    -- if inst.active == 4 then
        -- for _, item in ipairs(inst_data.animation_items) do
            -- rt_draw_item_sprite(item.sprite,
            -- actor.x + item.x,
            -- actor.y + item.y)
			-- -- item.y = math.lerp(item.y, item.y + actor.y, 0.1)
			
        -- end

		-- -- Slide items towards hole
    -- elseif inst.active == 5 then
        -- for _, item in ipairs(inst_data.animation_items) do
            -- rt_draw_item_sprite(item.sprite,
            -- item.x,
            -- item.y,
            -- math.easeout(item.scale, 3))
			-- if item.useNum == 1 then
				-- item.x = math.lerp(item.x, inst_data.left_x, 0.1)
			-- elseif item.useNum == 2 then
				-- item.x = math.lerp(item.x, inst_data.right_x, 0.1)
			-- end
            -- item.y = math.lerp(item.y, inst_data.holder_y, 0.1)
        -- end

    -- end
-- end)