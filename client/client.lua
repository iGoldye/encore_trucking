local truckId, jobStatus, currentRoute, currentDestination = nil, CONST_NOTWORKING, nil, nil
local currentDestination, routeBlip, trailerId, lastDropCoordinates, totalRouteDistance = nil, nil, nil, nil, nil, nil

local PickupCoordinates = nil

--
-- Threads
--

Citizen.CreateThread(function()
	EncoreHelper.CreateBlip(Config.JobStart.Coordinates, 'Trucking', Config.Blip.SpriteID, Config.Blip.ColorID, Config.Blip.Scale)

	while true do
		Citizen.Wait(0)

		local playerId             = PlayerPedId()
		local playerCoordinates    = GetEntityCoords(playerId)
		local distanceFromJobStart = GetDistanceBetweenCoords(playerCoordinates, Config.JobStart.Coordinates, false)
		local sleep                = 1000

		if distanceFromJobStart < Config.Marker.DrawDistance then
			sleep = 0
		
			DrawMarker(Config.Marker.Type, Config.JobStart.Coordinates, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.Size,  Config.Marker.Color.r, Config.Marker.Color.g, Config.Marker.Color.b, 100, false, true, 2, false, nil, nil, false)

			if distanceFromJobStart < Config.Marker.Size.x then

				if truckId and GetVehiclePedIsIn(playerId, false) == truckId and GetPedInVehicleSeat(truckId, -1) == playerId then
					EncoreHelper.ShowAlert('Press ~INPUT_PICKUP~ to return your truck.', true)

					if IsControlJustReleased(0, 38) then
						TriggerServerEvent('encore_trucking:returnTruck')

						abortJob()
					end
				elseif not IsPedInAnyVehicle(playerId, false) then
					EncoreHelper.ShowAlert('Press ~INPUT_PICKUP~ to rent a truck for $' .. Config.TruckRentalPrice .. '.', true)

					if IsControlJustReleased(0, 38) then
						TriggerServerEvent('encore_trucking:rentTruck')
					end
				end
			end
		end

		if jobStatus ~= CONST_NOTWORKING then
			sleep = 0

			if jobStatus == CONST_WAITINGFORTASK then
				assignTask()
			elseif jobStatus == CONST_PICKINGUP then
				pickingUpThread(playerId, playerCoordinates)
			elseif jobStatus == CONST_DELIVERING then
				deliveringThread(playerId, playerCoordinates)
			end
		
			-- Abort Hotkey
			if IsControlJustReleased(0, Config.AbortKey) then
				exports['mythic_notify']:SendAlert('inform', 'Press X again to confirm abort job.', 5000)
				local time = 5000

				while true do
					Wait(0)

					if IsControlJustReleased(0, Config.AbortKey) then
						abortJob()
						break
					else
						time = time - 1
						
						if time <= 0 then
							exports['mythic_notify']:SendAlert('inform', 'You chose not to abort job.', 5000)
							break
						end
					end
				end
			end
		end

		if sleep > 0 then
			Citizen.Wait(sleep)
		end
	end
end)

function pickingUpThread(playerId, playerCoordinates)
	if currentRoute ~= nil then
		if not trailerId and GetDistanceBetweenCoords(playerCoordinates, currentRoute.PickupCoordinates, true) < 100.0 then
			exports['mythic_notify']:PersistentAlert('START', 'TRUCKING', 'inform', 'Press [E] to spawn the trailer!')

			--Citizen.CreateThread(function()
				while true do
					Wait(0)
			
					if currentRoute ~= nil and not trailerId and GetDistanceBetweenCoords(playerCoordinates, currentRoute.PickupCoordinates, true) < 100.0 then
						if IsControlJustReleased(0, 38) or IsControlJustReleased(1, 46) or IsControlJustReleased(1, 86) or IsControlJustReleased(0, 20) then
							exports['mythic_notify']:PersistentAlert('END', 'TRUCKING')
							trailerId = EncoreHelper.SpawnVehicle(currentRoute.TrailerModel, currentRoute.PickupCoordinates, currentRoute.PickupHeading)
							break
						end
					else
						exports['mythic_notify']:PersistentAlert('END', 'TRUCKING')
						break
					end
				end
			--end)
		end

		if trailerId and IsEntityAttachedToEntity(trailerId, truckId) then
			RemoveBlip(routeBlip)
			Wait(100)
			EncoreHelper.CreateRouteBlip(currentDestination)

			exports['mythic_notify']:SendAlert('inform', 'Take the delivery to the drop off point.', 7500)
			jobStatus = CONST_DELIVERING
		end
	end
end

function deliveringThread(playerId, playerCoordinates)
	local distanceFromDelivery = GetDistanceBetweenCoords(playerCoordinates, currentDestination, true)

	if distanceFromDelivery < Config.Marker.DrawDistance then
		DrawMarker(Config.Marker.Type, currentDestination, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.Size,  Config.Marker.Color.r, Config.Marker.Color.g, Config.Marker.Color.b, 100, false, true, 2, false, nil, nil, false)	
	
		if distanceFromDelivery < Config.Marker.Size.x then
			EncoreHelper.ShowAlert('Press ~INPUT_PICKUP~ to deliver the load.', true)

			if IsControlJustReleased(0, 38) then
				TriggerServerEvent('encore_trucking:loadDelivered', totalRouteDistance)
				cleanupTask()
			end
		end
	end

	if trailerId and (not DoesEntityExist(trailerId) or not IsEntityAttachedToEntity(trailerId, truckId)) then
		if DoesEntityExist(trailerId) then
			DeleteVehicle(trailerId)
		end

		RemoveBlip(routeBlip)

		currentRoute        = nil
		currentDestination  = nil
		lastDropCoordinates = playerCoordinates

		exports['mythic_notify']:SendAlert('inform', 'You lost your load. A new route will be assigned.', 7500)

		jobStatus = CONST_WAITINGFORTASK
	end
end

--
-- Functions
--

function cleanupTask()
	if DoesEntityExist(trailerId) then
		DeleteVehicle(trailerId)
	end

	RemoveBlip(routeBlip)

	trailerId          = nil
	routeBlip          = nil
	currentDestination = nil
	currentRoute       = nil

	jobStatus = CONST_WAITINGFORTASK
end

function abortJob()
	DoScreenFadeOut(500)
	Citizen.Wait(500)

	if truckId and DoesEntityExist(truckId) then
		DeleteVehicle(truckId)
	end

	if trailerId and DoesEntityExist(trailerId) then
		DeleteVehicle(trailerId)
	end

	if routeBlip then
		RemoveBlip(routeBlip)
	end

	truckId  		    = nil
	trailerId		    = nil
	routeBlip			= nil
	currentDestination  = nil
	currentRoute        = nil
	lastDropCoordinates = nil
	totalRouteDistance  = nil

	Citizen.Wait(500)
	DoScreenFadeIn(500)
end

function assignTask()
	currentRoute       = Config.Routes[math.random(1, #Config.Routes)]
	currentDestination = currentRoute.Destinations[math.random(1, #currentRoute.Destinations)]
	routeBlip          = EncoreHelper.CreateRouteBlip(currentRoute.PickupCoordinates)

	local distanceToPickup   = GetDistanceBetweenCoords(lastDropCoordinates, currentRoute.PickupCoordinates)
	local distanceToDelivery = GetDistanceBetweenCoords(currentRoute.PickupCoordinates, currentDestination)

	totalRouteDistance  = distanceToPickup + distanceToDelivery
	lastDropCoordinates = currentDestination

	exports['mythic_notify']:SendAlert('inform', 'Head to the <b>pickup</b> on your GPS.', 7500)
	jobStatus = CONST_PICKINGUP
end

--
-- Events
--

RegisterNetEvent('encore_trucking:startJob')
AddEventHandler('encore_trucking:startJob', function()
	local playerId = PlayerPedId()

	truckId = EncoreHelper.SpawnVehicle(Config.TruckModel, Config.JobStart.Coordinates, Config.JobStart.Heading)
	SetPedIntoVehicle(playerId, truckId, -1)
	

	lastDropCoordinates = Config.JobStart.Coordinates

	jobStatus = CONST_WAITINGFORTASK
end)
