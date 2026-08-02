--Red Tide
--by Beebus Greebus and Friends

mods["ReturnsAPI-ReturnsAPI"].auto{
    namespace   = "RedTide",
    mp          = false
}

PATH = _ENV["!plugins_mod_folder_path"].."/"

local init = function()
	--colors !!
	Color.CRIMSON = Color.from_hex(0xda245F)
	Color.THISTLE = Color.from_hex(0x502248)
	
	--item tiers
	local conj = ItemTier.new("conjoined")
	gm.scribble_add_color("crRT", Color.CRIMSON, true)
	gm.scribble_add_color("thRT", Color.THISTLE, true)
	conj.text_color          = "crRT"
    conj.pickup_color        = Color.CRIMSON
    conj.pickup_color_bright = Color.THISTLE
	conj:set_head_shape{{0, 20}, {130, -10}, {130, 10}, {0, -20}}
	
	CONJLIST = {} --God of the Conjoined Items. 
	--Whenever a Conjoined Item is defined, be sure to table.insert into this table with another 3-item table that includes
	--The CONJOINED ITEM'S IDENTIFIER FIRST, and then its two components' identifiers second and third.
	--See cloakDagger.lua for an easy example.
	
	local folders = {
		"Misc", -- contains utility functions that other code depends on, so load first
		"Gameplay",
		"Language",
		"Actors",
		"Elites",
		"Survivors",
		"Items",
		"Equipments",
		"Interactables",
		"Stages"
	}
	
	Stage.remove_all_rooms() -- reload stages
	
	for _, folder in ipairs(folders) do
		-- NOTE: this includes filepaths within subdirectories of the above folders
		local filepaths = path.get_files(path.combine(PATH, folder))
		for _, filepath in ipairs(filepaths) do
			-- filter for files with the .lua extension, incase there's non-lua files
			if string.sub(filepath, -4, -1) == ".lua" then
				require(filepath)
			end
		end
	end

	
	HOTLOADING = true
end

Initialize.add(init)

if HOTLOADING then
	init()
end

