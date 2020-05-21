-- 
-- ESX
--

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--
-- Functions
--

function getMoney(playerId)
	local player = ESX.GetPlayerFromId(playerId)

	if player ~= nil then
		local money = player.getMoney()
		return money
	end
end

function addMoney(playerId, amount)
	local player = ESX.GetPlayerFromId(playerId)

	if player ~= nil then
		player.addMoney(amount)
		return true
	end
end

function removeMoney(playerId, amount)
	local player = ESX.GetPlayerFromId(playerId)

	if player ~= nil then
		player.removeMoney(amount)
		return true
	end
end

--
-- Events
--

RegisterNetEvent('encore_trucking:loadDelivered')
AddEventHandler('encore_trucking:loadDelivered', function(totalRouteDistance)
	local playerId = source
	local payout   = math.floor(totalRouteDistance * Config.PayPerMeter)

	addMoney(playerId, payout)
	TriggerClientEvent('mythic_notify:client:SendAlert', playerId, { type = 'inform', text = 'Received $'..payout..' commission from trucking.', length = 7500 })
end)

RegisterNetEvent('encore_trucking:rentTruck')
AddEventHandler('encore_trucking:rentTruck', function()
	local playerId = source

	if getMoney(playerId) < Config.TruckRentalPrice then
		TriggerClientEvent('mythic_notify:client:SendAlert', playerId, { type = 'error', text = 'You do not have enough money to rent a truck.', length = 7500 })
		return
	end

	removeMoney(playerId, Config.TruckRentalPrice)

	TriggerClientEvent('encore_trucking:startJob', playerId)
end)

RegisterNetEvent('encore_trucking:returnTruck')
AddEventHandler('encore_trucking:returnTruck', function()
	local playerId = source

	addMoney(playerId, Config.TruckRentalPrice)

	TriggerClientEvent('mythic_notify:client:SendAlert', playerId, { type = 'inform', text = 'Your $' .. Config.TruckRentalPrice .. ' deposit was returned to you.', length = 7500 })
end)