EncoreHelper = {}

EncoreHelper.ShowAlert = function(message, playNotificationSound)
    SetTextComponentFormat('STRING')
    AddTextComponentString(message)
    DisplayHelpTextFromStringLabel(0, 0, playNotificationSound, -1)
end

EncoreHelper.SpawnVehicle = function(name, coordinates, heading)
    RequestModel(name)

    while not HasModelLoaded(name) do
        Citizen.Wait(100)
    end

    local vehicle = CreateVehicle(name, coordinates, heading, true, true)

    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleOnGroundProperly(vehicle)
	SetModelAsNoLongerNeeded(name)

	Wait(50)
	
	TriggerEvent('keys:addNew', vehicle, GetVehicleNumberPlateText(vehicle))

    return vehicle
end

EncoreHelper.CreateBlip = function(coordinates, name, spriteId, colorId, scale)
	local blip = AddBlipForCoord(coordinates)

	SetBlipSprite(blip, spriteId)
	SetBlipColour(blip, colorId)
	SetBlipScale(blip, scale)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)

	return blip
end

EncoreHelper.CreateRouteBlip = function(coordinates)
	local blip = AddBlipForCoord(coordinates)

	SetBlipSprite(blip, 57)
	SetBlipColour(blip, 5)
	SetBlipScale(blip, 0.30)
	SetBlipRoute(blip,  true)

	return blip
end

--
-- Events
--

RegisterNetEvent('encore_trucking:helper:showAlert')
AddEventHandler('encore_trucking:helper:showAlert', function(message, playNotificationSound)
	EncoreHelper.ShowAlert(message, playNotificationSound)
end)