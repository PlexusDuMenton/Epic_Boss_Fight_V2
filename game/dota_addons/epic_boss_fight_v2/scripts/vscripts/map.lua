require( "libraries/Timers" )
if map == nil then
    map = class({})
end

function OnEnterShop(trigger)
    local ent = trigger.activator
    if not ent then return end
    ent.Isinshop = true
    --play sound telling player he entered it
    --open shop hud
    return
end

function OnExitShop(trigger)
    local ent = trigger.activator
    if not ent then return end
    ent.Isinshop = false
    --play exit music ?
    --close shop hud if player didn't yet
    return
end