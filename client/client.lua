-- Variables

local RSGCore = exports['rsg-core']:GetCoreObject()
local deployeddecks = nil

-- Functions

local function loadAnimDict(dict)
  while (not HasAnimDictLoaded(dict)) do
      RequestAnimDict(dict)
      Wait(5)
  end
end

local function helpText(text)
	SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- target
Citizen.CreateThread(function()

local djdecksprop = {
    `p_chairhob01x`,
    }
    exports['rsg-target']:AddTargetModel(djdecksprop, {
        options = {
            {
				type = "client",
				event = "rsg_chair:client:pickupDJEquipment",
                icon = "fas fa-undo",
                label = "put away Chair",
            },
        },
        distance = 3.0
    })
end)

-- Events

-- place dj equipment
RegisterNetEvent('rsg_chair:client:placeDJEquipment', function()
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local forward = GetEntityForwardVector(PlayerPedId())
    local x, y, z = table.unpack(coords + forward * 1.5)
	TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), -1, true, "StartScenario", 0, false)
	Wait(500)
    ClearPedTasks(PlayerPedId())
    local object = CreateObject(GetHashKey('p_chairhob01x'), x, y, z, true, false, false)
    PlaceObjectOnGroundProperly(object)
    SetEntityHeading(object, heading)
    FreezeEntityPosition(object, true)
    deployeddecks = NetworkGetNetworkIdFromEntity(object)
end)


RegisterNetEvent('rsg_chair:client:pickupDJEquipment', function()
    local obj = NetworkGetEntityFromNetworkId(deployeddecks)
    local objCoords = GetEntityCoords()
    NetworkRequestControlOfEntity(obj)
    SetEntityAsMissionEntity(obj,false,true)
    DeleteEntity(obj)
    DeleteObject(obj)
    if not DoesEntityExist(obj) then
        TriggerServerEvent('rsg_chair:server:pickeupdecks')
        deployeddecks = nil
    end
    Wait(500)
    ClearPedTasks(PlayerPedId())
	RSGCore.Functions.Notify('you picked up the Chair!', 'primary', 3000)
end)
