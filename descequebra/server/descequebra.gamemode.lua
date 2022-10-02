-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("descequebra",src)
clientAPI = Tunnel.getInterface("descequebra")


-----------------------------------------------------------------------------------------------------------------------------------------
-- Set Dimensao Desce Quebra
-----------------------------------------------------------------------------------------------------------------------------------------
function src.dimenssionSet()
    local source = source
    local user_id = vRP.getUserId(source)
    -- dimension stuff
    local dimensionId = parseInt(730000)
    SetPlayerRoutingBucket(source, parseInt(dimensionId))
    TriggerClientEvent("decequebra:SetDimension", source, parseInt(dimensionId))
    return nil
end