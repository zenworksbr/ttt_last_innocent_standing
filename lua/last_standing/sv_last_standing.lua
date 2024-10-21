-- Create options for the addon functionality
local cvar_enable = CreateConVar("ttt_announce_last_innocent_alive", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_PROTECTED}, "Enable notifications to warn the last Innocent alive that they are by theirselves? 1 or 0", 0, 1)
local cvar_if_one_t = CreateConVar("ttt_announce_if_one_traitor", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_PROTECTED}, "Enable notifications if there is only one Traitor left? 1 or 0, 0 by default", 0, 1)
local cvar_warn_detective = CreateConVar("ttt_announce_if_detective", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_PROTECTED}, "Enable notifications if the last one is a Detective? 1 or 0, 0 by default", 0, 1)

cvar_enable = cvar_enable:GetBool()
cvar_if_one_t = cvar_if_one_t:GetBool()
cvar_warn_detective = cvar_warn_detective:GetBool()

cvars.AddChangeCallback('ttt_announce_last_innocent_alive', function(cvar, old, new)
        cvar_enable = tobool(new)
end)

cvars.AddChangeCallback('ttt_announce_if_one_traitor', function(cvar, old, new)
        cvar_if_one_t = tobool(new)
end)

cvars.AddChangeCallback('ttt_announce_if_detective', function(cvar, old, new)
        cvar_warn_detective = tobool(new)
end)

LastStanding.role_names = {
	['detective'] = 'Detetive',
	['innocent'] = 'Inocente'
}

-- Define either the player was already warned or not, so we don't get multiple warns when there are more than one Traitor
local broadcasted = broadcasted or false

-- Function for counting the ammount of players and their in-game roles so we can work with them
local function CountActiveRolePlayers()

	-- Create players object to keep track of each players' roles
	local players = {}
    	players.innocent = {}
	players.traitor = {}
	players.detective = {}
    
	for _, ply in ipairs( player.GetAll() ) do

		if !IsValid(ply) or !ply:IsActive() then continue end

		table.insert(players[ply:GetRoleString()], ply)
	end
    
	return players
end

local function GetLastInnocentStanding(player_table)
	for role, plys in pairs( player_table ) do

		if role == 'traitor' then continue end

		for _, ply in pairs(plys) do

			if not IsValid(ply) then continue end
			if ply:IsTraitor() or ply:IsActiveTraitor() then continue end
			if !ply:Alive() then continue end
				
			return ply:Name(), role
		end
	end
end

-- Prepare some stuff and execute the initial count of players
hook.Add("TTTBeginRound", "InitTTTLastInnocentAlive", function()
	
        print("Avisar último Inocente? " .. (cvar_enable and "Sim" or "Não"))
        print("Avisar somente quando houver mais de um Traidor? " .. (!cvar_if_one_t and "Sim" or "Não"))
        print("Avisar Detetive? " .. (cvar_warn_detective and "Sim" or "Não"))

        if !cvar_enable then broadcasted = true return end
        if cvar_if_one_t then return end
        broadcasted = false

        local players = CountActiveRolePlayers()
end)

if SERVER then
	hook.Add("PostPlayerDeath", "CheckIfLastInnocentAliveAfterDeath", function(ply)
		if (GetRoundState() != ROUND_ACTIVE) then return end
       		if !cvar_enable then broadcasted = true return end
		if broadcasted then return end
		if SpecDM and ply:IsGhost() then return end
		local players = CountActiveRolePlayers()
		if (#players.innocent + #players.detective > 1)
		or (#players.innocent + #players.detective < 1) then return end
		
		if ((#players.innocent == 1 or #players.detective == 1) and #players.traitor > 0) then
			
			-- Don't do anything if "warn only if there is more than 1 traitor" cvar is enabled
			if (!cvar_if_one_t and #players.traitor == 1) then broadcasted = false return end
			
			-- Same as above, but if the "warn detectives" is disabled
			if (!cvar_warn_detective and #players.detective > 0) then broadcasted = false return end

			local plynick, role = GetLastInnocentStanding(players)
			role = LastStanding.role_names[role]
			print(plynick)
			print(role)

			print(plynick .. " é o último Inocente vivo!")

			-- Quick and easy (but not the best) way of propagating the message to all players in the server
			PrintMessage( HUD_PRINTCENTER, plynick .. ' é o último ' .. role .. ' vivo! MATE TODOS!!!' )
                        net.Start('LastStanding_NotifyPlayers')
                                net.WriteString(plynick)
                                net.WriteString(role)
                        net.Broadcast()

			-- Avoid repeated warnings after first one
			broadcasted = true
		end
	end)

	hook.Add("PlayerDisconnected", "CheckIfLastInnocentAliveAfterDisconnect", function(ply)
		if (GetRoundState() != ROUND_ACTIVE) then return end
		if !cvar_enable then return end
        	if broadcasted then return end
		if SpecDM and ply:IsGhost() then return end
		local players = CountActiveRolePlayers()
		if (#players.innocent + #players.detective > 1)
		or (#players.innocent + #players.detective < 1) then return end
		
		if ((#players.innocent == 1 or #players.detective == 1) and #players.traitor > 0) then
			
			-- Don't do anything if "warn only if there is more than 1 traitor" cvar is enabled
			if (!cvar_if_one_t and #players.traitor == 1) then broadcasted = false return end
			
			-- Same as above, but if the "warn detectives" is disabled
			if (!cvar_warn_detective and #players.detective > 0) then broadcasted = false return end

			local plynick, role = GetLastInnocentStanding(players)
			role = LastStanding.role_names[role]

			print(plynick .. " é o último Inocente vivo!")

			-- Quick and easy (but not the best) way of propagating the message to all players in the server
			PrintMessage( HUD_PRINTCENTER, plynick .. ' é o último ' .. role .. ' vivo! MATE TODOS!!!' )
                        net.Start('LastStanding_NotifyPlayers')
                                net.WriteString(plynick)
                                net.WriteString(role)
                        net.Broadcast()

			-- Avoid repeated warnings after first one
			broadcasted = true
		end
	end)
end

print('[Last Standing] SERVER-side initialized successfully.')