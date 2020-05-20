--
-- Functions
--

function getMoney(playerId)
	-- Insert your framework's method here.

	return 10000
end

function addMoney(playerId, amount)
	-- Insert your framework's method here.

	return true
end

function removeMoney(playerId, amount)
	-- Insert your framework's method here.

	return true
end

--
-- Events
--

RegisterNetEvent('encore_trucking:loadDelivered')
AddEventHandler('encore_trucking:loadDelivered', function(totalRouteDistance)
	local playerId = source
	local payout   = math.floor(totalRouteDistance * Config.PayPerMeter)

	addMoney(playerId, payout)

	TriggerClientEvent('encore_trucking:helper:showNotification', playerId, 'Received ~g~$' .. payout .. '~s~ commission from trucking.')
end)

RegisterNetEvent('encore_trucking:rentTruck')
AddEventHandler('encore_trucking:rentTruck', function()
	local playerId = source

	if getMoney(playerId) < Config.TruckRentalPrice then
		TriggerClientEvent('encore_trucking:helper:showNotification', playerId, 'You do not have enough money to rent a truck.')
		return
	end

	removeMoney(playerId, Config.TruckRentalPrice)

	TriggerClientEvent('encore_trucking:startJob', playerId)
end)

RegisterNetEvent('encore_trucking:returnTruck')
AddEventHandler('encore_trucking:returnTruck', function()
	local playerId = source

	addMoney(playerId, Config.TruckRentalPrice)

	TriggerClientEvent('encore_trucking:helper:showNotification', playerId, 'Your $' .. Config.TruckRentalPrice .. ' deposit was returned to you.')
end)