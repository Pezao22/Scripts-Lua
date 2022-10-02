-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp","lib/Proxy")

src = {}
Tunnel.bindInterface("descequebra",src)
serverAPI = Tunnel.getInterface("descequebra")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
myDimension = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETDIMENSION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("decequebra:SetDimension",function(number)
    myDimension = number
    -- colocar aqui
    print("[global.dimensions] update dimension to "..myDimension)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Configurações
-----------------------------------------------------------------------------------------------------------------------------------------

local Descequebra = {
    tempo = 0, -- NAO ALTERE AQUI O TEMPO É ALTERADO NA LINHA 125
    inDescequebra = nill, --- IGNORE
    text = 'Nao fique fora do veiculo mais de 30 segundos ou sera respawnado !!!', --- MENSSAGEM DA NOTIFY AO RESPAWNAR
    veh = 'sanchez', -- SETA O VEICULO DO MODO DESCEQUEBRA
    spawns = {                   ----- Altere as coords de spawn na primeira vez que o jogador entra
        {219.06, -1042.83, 29.37},
        {286.11, -861.26, 29.32},
        {122.49, -799.43, 31.37},
        {-35.64, -948.64, 29.42}
    }
}

function spawnVeh()
    local peds = PlayerPedId()
    local mHash = GetHashKey(Descequebra["veh"])

    RequestModel(mHash)
    while not HasModelLoaded(mHash) do
        RequestModel(mHash)
        Citizen.Wait(10)
    end

    if HasModelLoaded(mHash) then
        local ped = PlayerPedId()
        local nveh = CreateVehicle(mHash, GetEntityCoords(ped), GetEntityHeading(ped), true, false)

        SetVehicleDirtLevel(nveh, 0.0)
        SetVehRadioStation(nveh, "OFF")
        SetVehicleNumberPlateText(nveh, "Pezao XD")
        SetPedIntoVehicle(ped, nveh, -1)
        SetEntityAsMissionEntity(nveh, true, true)

        SetVehicleFuelLevel(nveh, 100.0)

        SetModelAsNoLongerNeeded(mHash)
    end
end

function randomLoc()
    local peds = PlayerPedId()
    local cord = GetEntityCoords(peds)

    local x = cord.x + math.random(10.0, 40.0) - math.random(10.0, 80.0)
    local y = cord.y + math.random(10.0, 40.0) - math.random(10.0, 80.0)
    local z = cord.z + 200

    -- print(x, y, z)
    local bowz, cdz = GetGroundZFor_3dCoord(x, y, z);
    -- print(cdz)

    Citizen.Wait(300)
    SetEntityCoords(peds, x, y, cdz)
    spawnVeh()
    TriggerEvent("Notify", {
        type = "error",
        text = Descequebra["text"],
        time = 8000
    })

end

function startDeceQuebra(status)
    local status = status
    Citizen.CreateThread(function()
        while status do
            local ped = PlayerPedId()
            local timeDistance = 200
            if Descequebra["inDescequebra"] then
                if not parseInt(myDimension) == 730000 then
                    Descequebra["inDescequebra"] = false
                    startDeceQuebra(false)
                    myDimension = 1
                    print("[global.dimensions] dimensao atualizada "..myDimension)
                    TriggerEvent("Notify", {
                        type = "inform",
                        text = "Voce trocou de dimensao e saiu do moto Desce e Quebra !!!",
                        time = 9000
                    })
                    return
                end

                local veh = GetPlayersLastVehicle(ped, 1)
                local ped_driver = GetPedInVehicleSeat(veh, -1)

                if not IsPedSittingInVehicle(ped_driver, veh) then

                    timeDistance = 5

                    if Descequebra["tempo"] == 1 then
                        Descequebra["tempo"] = 0
                        randomLoc()
                    end

                    if Descequebra["tempo"] > 0 then
                        draw("Tempo: ~r~" .. Descequebra["tempo"] .. "~w~ segundos para retornar ao veiculo !!!.", 4,
                            0.5, 0.95, 0.50, 255, 255, 255, 255)
                    end

                    if Descequebra["tempo"] == 0 then
                        Descequebra["tempo"] = 10 -- Altere aqui O TEMPO DE RESPAWN
                    end
                else
                    if Descequebra["tempo"] > 0 then
                        Descequebra["tempo"] = 0
                    end
                end

                if GetEntityHealth(ped) <= 101 then
                    -- local coords2 = GetEntityCoords(ped)
                    Citizen.Wait(200)
                    TriggerEvent("core:killGod")
                    SetEntityHealth(ped, 399)
                    randomLoc()
                end
            end
            Citizen.Wait(timeDistance)
        end
    end)

    Citizen.CreateThread(function()
        while status do
            if Descequebra["tempo"] == nil then
                Descequebra["tempo"] = 0
            end

            if Descequebra["tempo"] > 0 then
                Descequebra["tempo"] = Descequebra["tempo"] - 1
            end
            Citizen.Wait(1000)
        end
    end)
end

RegisterCommand('descequebra', function()
    if Descequebra["inDescequebra"] then
        TriggerEvent("descequebra:Quit")
    else
        TriggerEvent("decequebra:Entrar")
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTERARENA  
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("decequebra:Entrar")
AddEventHandler("decequebra:Entrar", function()
    local ped = PlayerPedId()

    if Descequebra["inDescequebra"] then
        TriggerEvent("Notify", {
            type = "error",
            text = "Você já está no Desce e Quebra"
        })
        return
    end

    if not Descequebra["inDescequebra"] then
        Descequebra["inDescequebra"] = true
        startDeceQuebra(true)
        -- print('entrou')
        TriggerEvent("Notify", {
            type = "inform",
            text = "Você entrou na dimensão de Descequebra"
        })
        TriggerEvent("clearWeapons")
        serverAPI.dimenssionSet()

        local spawnPoints = math.random(#Descequebra["spawns"])
        SetEntityCoords(ped, Descequebra["spawns"][spawnPoints][1], Descequebra["spawns"][spawnPoints][2],
            Descequebra["spawns"][spawnPoints][3])
        spawnVeh()
        ExecuteCommand('armas')
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEPLAYERFROMARENA 
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("descequebra:Quit")
AddEventHandler("descequebra:Quit", function()
    if Descequebra["inDescequebra"] then
        Descequebra["inDescequebra"] = false
        startDeceQuebra(false)
        -- print('saiu')
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DRAWq
-----------------------------------------------------------------------------------------------------------------------------------------
function draw(text, font, x, y, scale, r, g, b, a)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
