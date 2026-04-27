--Red Tide
--by Beebus Greebus and Friends

mods["ReturnsAPI-ReturnsAPI"].auto{
    namespace   = "RedTide",
    mp          = true
}

PATH = _ENV["!plugins_mod_folder_path"].."/"

local init = function()
	
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
		"Artifacts",
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

