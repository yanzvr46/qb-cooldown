local QBCore = exports['qb-core']:GetCoreObject()
local isCooldown = false
local cooldownStartTime = 0
local currentCooldownTimer = 0 


local function getRemainingCooldownTime()
    if isCooldown then
        local elapsedTime = (os.time() - cooldownStartTime) / 60 
        return math.max(0, currentCooldownTimer - elapsedTime) 
    end
    return 0
end

CreateThread(function()
    while true do        
        Wait(1000)
        if isCooldown and getRemainingCooldownTime() <= 0 then
            isCooldown = false
        end
    end
end)

RegisterServerEvent("cad-cooldown:server:coolsync")
AddEventHandler("cad-cooldown:server:coolsync", function(bool, cooldownTime)
    if bool then
        isCooldown = true
        cooldownStartTime = os.time()
        currentCooldownTimer = cooldownTime or Config.CooldownTimer
    else
        isCooldown = false
    end
end)

QBCore.Functions.CreateCallback("cad-cooldown:server:checkcooldown", function(source, cb)
    if isCooldown then
        cb(true, getRemainingCooldownTime()) 
    else
        cb(false, 0)
    end
end)

QBCore.Commands.Add("cooldown", "Set Robbery Cooldown", {{name="state", help="true/false"}, {name="time", help="Durasi cooldown dalam menit (opsional)"}}, false, function(src, args)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local job = Player.PlayerData.job.name
    local role = Player.PlayerData.permission

    if role == 'admin' or job == 'police' then
        if tostring(args[1]) == "true" then
            local cooldownTime = tonumber(args[2]) or Config.CooldownTimer
            isCooldown = true
            cooldownStartTime = os.time()
            currentCooldownTimer = cooldownTime
            TriggerClientEvent("QBCore:Notify", src, "Cooldown dimulai selama " .. cooldownTime .. " menit.", "success")
        elseif tostring(args[1]) == "false" then
            isCooldown = false
            TriggerClientEvent("QBCore:Notify", src, "Cooldown telah direset.", "success")
        else
            TriggerClientEvent("QBCore:Notify", src, "Input tidak valid. Gunakan true/false.", "error")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "Anda tidak memiliki akses ke command ini.", "error")
    end
end, false)

QBCore.Commands.Add("checkcooldown", "Cek sisa waktu cooldown", {}, false, function(src, args)
    if isCooldown then
        local remainingTime = getRemainingCooldownTime()
        TriggerClientEvent("QBCore:Notify", src, "Sisa waktu cooldown: " .. math.ceil(remainingTime) .. " menit.", "primary")
    else
        TriggerClientEvent("QBCore:Notify", src, "Tidak ada cooldown aktif saat ini.", "success")
    end
end, false)
