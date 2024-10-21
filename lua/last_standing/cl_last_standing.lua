LastStanding = LastStanding or {}

local role_colors = {
	['Detetive'] = Color(32, 32, 255),
	['Inocente'] = Color(36, 255, 36)
}

local function NotifyPlayer(plyname, role)
        chat.AddText(role_colors[role], '' .. plyname .. ' ', Color(200, 160, 0), 'é o ', role_colors[role], 'último ' .. role, Color(200, 160, 0), ' vivo! ', Color(230, 0, 0) , 'MATE TODOS!!!')
end

net.Receive('LastStanding_NotifyPlayers', function(ply, len)
        -- if ply != LocalPlayer() then return end

        local last = net.ReadString()
        local role = net.ReadString()

        NotifyPlayer(last, role)
end)

print('[Last Standing] CLIENT-side initialized successfully.')