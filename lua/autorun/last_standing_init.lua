LastStanding = {}

-- had to change the loading of addon files for after the gamemode has initialized
-- else, it would break a lot of stuff we depend on TTT
hook.Add('OnGamemodeLoaded', 'LastStanding.GamemodeLoaded', function() 

	print('[Last Standing] Initializing addon files...')

	if engine.ActiveGamemode() != 'terrortown' then 
		print('[Last Standing] Can\'t initialize this addon on another gamemode other than TTT!!! Please change it in your server settings!!!')
		return
	end

    	if SERVER then 
		print("[Last Standing] Including SERVER file sv_last_standing")
		include('last_standing/sv_last_standing.lua')
		AddCSLuaFile('last_standing/cl_last_standing.lua')
	else
		print("[Last Standing] Including CLIENT file cl_last_standing")
		include('last_standing/cl_last_standing.lua')
	end

	if SERVER then 
		util.AddNetworkString("LastStanding_NotifyPlayers")
	end
end)
