local players_service = game:GetService("Players")
local run_service = game:GetService("RunService")

local localplayer = players_service.LocalPlayer
local localplayer_mouse = localplayer:GetMouse()

local data, weaponHit_data

for i, v in pairs(getgc(true)) do
    if type(v) == "table" and rawget(v, "aimPoint") then
        for x, y in pairs(v) do
            if typeof(y) == "Instance" and y.Name == localplayer.Name then
                data = v
            end
        end
    end
end

local function GetClosestPlayerToCursor()
    local closest_cursor_distance = math.huge
    local closest_player_to_cursor
    
    for _, player in pairs(players_service:GetPlayers()) do
        if player ~= localplayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("Head") then
            local screen_position = workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)

            local cursor_distance = (Vector2.new(localplayer_mouse.X, localplayer_mouse.Y) - Vector2.new(screen_position.X, screen_position.Y)).Magnitude
    
	        if cursor_distance < closest_cursor_distance then
                closest_player_to_cursor = player
                closest_cursor_distance = cursor_distance
            end
        end
    end

    return closest_player_to_cursor
end

local player = GetClosestPlayerToCursor()

run_service.Stepped:Connect(function()
    pcall(function() data.weaponsSystem.currentWeapon.configValues.ShotCooldown = 0 end)
    player = GetClosestPlayerToCursor()

    weaponHit_data = {
        ["part"] = player.Character.Head,
        ["h"] = player.Character.Humanoid,
        ["sid"] = data.nextShotId,
    }
end)

local old_namecall

old_namecall = hookmetamethod(game, '__namecall', function(remote, ...)
	local arguments = {...}
	local namecall_method = getnamecallmethod()

    if not checkcaller() and namecall_method == "FireServer" then
        if remote.Name == "WeaponHit" then
            arguments[2]["part"] = weaponHit_data["part"]
            arguments[2]["h"] = weaponHit_data["h"]
            arguments[2]["sid"] = weaponHit_data["sid"]
        end
    end
  
	return old_namecall(remote, unpack(arguments))
end)
