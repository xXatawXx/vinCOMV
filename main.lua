local value_x, value_y, value_z = 0.0, 0.0, 0.0
local VehData, centerDebug, goUp = {}, false, 0

local function round(num)
	return num + (2^52 + 2^51) - (2^52 + 2^51)
end

RegisterCommand('enablecenterdebug', function(source,args,rawCommand)
	centerDebug = not centerDebug
end, true)

RegisterCommand('updatecenter', function(source,args,rawCommand)
	if centerDebug then
		local option = args[1]
		if args[1] ~= nil then
			if option == "y" then
				value_y = round(tonumber(args[2]))
			end
			if option == "z" then
				value_z = round(tonumber(args[2]))
			end
		else
			print("type something dumbass")
		end
	else
		print("lel scrub")
	end
end, true)

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		if centerDebug then
			sleep = 0
			if DoesEntityExist(vehicle) then
				for k,v in pairs(VehData) do
					value_x, value_y, value_z = v.value.x, v.value.y, v.value.z 
					break
				end
				local vecfind = string.find("vecCentreOfMassOffset", "vec")
				if vecfind ~= nil and vecfind == 1 and GetVehicleHandlingVector(vehicle, "CHandlingData", "vecCentreOfMassOffset" ) then
					table.insert(VehData, { name = "vecCentreOfMassOffset", value = GetVehicleHandlingVector(vehicle, "CHandlingData", "vecCentreOfMassOffset" ), type = "vector3" } )
				end
			end
        end
		Citizen.Wait(sleep)
	end
end)

Citizen.CreateThread( function()
    while true do 
        Citizen.Wait(1)
        if centerDebug then
			local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			local carPos = GetEntityCoords(vehicle)
			local LPos = GetOffsetFromEntityInWorldCoords(vehicle, 2.0, value_y, value_z)
            local RPos = GetOffsetFromEntityInWorldCoords(vehicle, -2.0, value_y, value_z)
			local forPos = GetOffsetFromEntityInWorldCoords(vehicle, 0, value_y, value_z)
            DrawLine(carPos, forPos, 255,0,0,255)
            DrawLine(forPos, LPos, 0,0,255,255)
            DrawLine(forPos, RPos, 0,0,255,255)
			
			if IsControlJustPressed(0, 172) and goUp ~= 15 then
				goUp = goUp + 1
				SetEntityCoordsNoOffset(vehicle, carPos.x, carPos.y, carPos.z + 1.0, false, false, true)
			elseif goUp == 15 then
				goUp = 0
				FreezeEntityPosition(vehicle, true)
			end
			if IsControlJustPressed(0, 73) then
				goUp = 0
				FreezeEntityPosition(vehicle, false)
			end
		else
			Citizen.Wait(5000)
		end
    end
end)

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.25, 0.25)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

AddEventHandler('onClientResourceStart', function(resource)
	if (GetCurrentResourceName() == resource) then
		FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), false), false)
	end
end)