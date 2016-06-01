

if Notifications == nil then
  Notifications = class({})
end

function Notifications:Inventory(PID,table)
  DeepPrintTable(table)
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PID), "inventory_notification", {text=table.text, color=table.color, duration=table.duration} )
end


function Notifications:Save(PID,table)
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PID), "save_notification", {text=table.text, color=table.color, duration=table.duration} )
end

function Notifications:Custom(PID,table)
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PID), "custom_notification", {text=table.text, color=table.color, duration=table.duration} )
end

function Notifications:clean(PID)
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PID), "clean_notification", {} )
end