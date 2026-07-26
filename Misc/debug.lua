local mark = Console.new{
    "spawn_mark [count] [esplode]",
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
			if not args[2] then
				if i % 2 == 0 then i = i * -1 end
				inst = Object.find("EfGold"):create(mx + (i * 10), my)
				inst.hspeed = 0
				inst.vspeed = 0
			else
				inst = Object.find("EfGold"):create(mx, my)
				inst.speed = math.random() * math.random(-5, 5)
				inst.hspeed = math.random() * math.random(-5, 5)
				inst.vspeed = math.random() * math.random(-5, 5)
			end
			inst.gravity = 0
			inst.sprite_index = Sprite.find("redMarkHud", namespace)
			inst.value.value = 0
			inst.is_mark = true
			inst.target = gm.player_util_nearest_player(inst.x, inst.y, true)
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