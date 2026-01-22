local nuiOpen = false

AddEventHandler('onClientResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  SetNuiFocus(false, false)
  SendNUIMessage({ action = "hideAll" })
end)

RegisterCommand(Config.Commands.OpenUI, function()
  if nuiOpen then return end
  SetNuiFocus(true, true)
  nuiOpen = true
  SendNUIMessage({
    action     = "open",
    title      = Config.UITitle,
    categories = Config.Categories,
    allowImage = Config.AllowImages
  })
end, false)

-- /admsg message | image | postal
RegisterCommand(Config.Commands.Quick, function(_, args)
  local raw = table.concat(args or {}, " ")
  if not raw or raw == "" then
    lib.notify({ title = 'Announcement', description = ('Usage: /%s <message> | <optional image url> | <optional postal>'):format(Config.Commands.Quick), type = 'warning' })
    return
  end
  local parts = {}
  for part in string.gmatch(raw, "([^|]+)") do table.insert(parts, part) end
  local msg = (parts[1] or ""):gsub("^%s*(.-)%s*$","%1")
  local img = (parts[2] or ""):gsub("^%s*(.-)%s*$","%1")
  local pst = (parts[3] or ""):gsub("^%s*(.-)%s*$","%1")
  TriggerServerEvent('ransom-announce:submit', { message = msg, image = img, category = "Business", postal = pst })
end, false)

RegisterNUICallback('close', function(_, cb)
  cb(1)
  SetNuiFocus(false, false)
  nuiOpen = false
  SendNUIMessage({ action = "hideAll" })
end)

RegisterNUICallback('submit', function(data, cb)
  cb(1)
  SetNuiFocus(false, false)
  nuiOpen = false
  TriggerServerEvent('ransom-announce:submit', {
    message = data.message or "",
    image   = data.image or "",
    category= data.category or "Business",
    postal  = data.postal or ""
  })
end)

RegisterNetEvent('ransom-announce:broadcast', function(payload)
  if Config.ShowOnScreen then
    SendNUIMessage({ action = "showBanner", payload = payload, playSound = false })
  end
end)

RegisterNetEvent('ransom-announce:notify', function(payload)
  local ntype = payload.type or 'inform'
  local desc  = payload.description or ''
  lib.notify({ title = 'Announcement', description = desc, type = ntype })
end)