local mark = Console.new{
    "spawn_mark [count] [val] [esplode]",
    {
        "Markiplier",
    },
    function(args)
        if not Util.bool(Global.__run_exists) then
            Console.print("Not currently in a run.")
            return
        end
		
		local count = args[1]
		
		local mx, my = Global.mouse_x, Global.mouse_y
		
		for i = 1, (count or 1) do
			local inst
			if not args[3] then
				if i % 2 == 0 then i = i * -1 end
				inst = RedMark:create(mx + (i * 10), my)
				inst.hspeed = 0
				inst.vspeed = 0
			else
				inst = RedMark:create(mx, my)
				inst.speed = math.random() * (5 * gm.choose(-1,1))
				inst.hspeed = math.random() * (5 * gm.choose(-1,1))
				inst.vspeed = math.random() * (5 * gm.choose(-1,1))
			end
			Instance.get_data(inst).mark_value = args[2]
			inst.target = gm.player_util_nearest_player(inst.x, inst.y, true)
		end
    end
}

local yum = Console.new{
    "yumyum",
    {
        "Markiplier3",
    },
    function(args)
        if not Util.bool(Global.__run_exists) then
            Console.print("Not currently in a run.")
            return
        end
		
		for _, mark in ipairs(Instance.find_all(RedMark)) do
			Instance.get_data(mark).foundPlayer = true
		
		end
    end
}

local john = Console.new{
    "merger (debug)",
    {
        "Markiplier2",
    },
    function(args)
        if not Util.bool(Global.__run_exists) then
            Console.print("Not currently in a run.")
            return
        end
		
		local mx, my = Global.mouse_x, Global.mouse_y
		
		local jun = Object.find("conjunction", namespace):create(mx, my)
		if args[1] then
			Instance.get_data(jun).isDebug = true
		end
    end
}