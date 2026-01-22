local lastPost = {}

RegisterNetEvent('ransom-announce:submit', function(data)
  local src = source
  local identifier = getIdentifier(src)
  if not identifier then 
    notify(src, 'error', 'Unable to identify your account.')
    return 
  end

  local msg = trim((data.message or ""):gsub("%s+", " "))
  local img = trim(data.image or "")
  local cat = trim(data.category or "Business")
  local pst = trim(data.postal or "")

  if #msg < Config.MinMessageLength then 
    notify(src, 'warning', ('Message too short (min %d).'):format(Config.MinMessageLength))
    return 
  end
  if #msg > Config.MaxMessageLength then 
    notify(src, 'warning', ('Message too long (max %d).'):format(Config.MaxMessageLength))
    return 
  end

  for _, bad in ipairs(Config.BlockedPhrases) do
    if bad ~= "" and msg:lower():find(bad:lower(), 1, true) then 
      notify(src, 'error', 'Your message contains a blocked phrase.')
      return 
    end
  end

  if Config.AllowImages and img ~= "" then
    if #img > Config.MaxImageURLLength then 
      notify(src, 'warning', ('Image URL too long (max %d).'):format(Config.MaxImageURLLength))
      return 
    end
    if Config.RequireURLPrefix and not (img:lower():match("^https://") or img:lower():match("^http://")) then 
      notify(src, 'warning', 'Image URL must start with http:// or https://')
      return 
    end
  else
    img = ""
  end

  if #pst > 10 then pst = pst:sub(1,10) end

  local now = os.time()
  local last = lastPost[identifier] or 0
  local remaining = Config.CooldownSeconds - (now - last)
  if remaining > 0 then
    notify(src, 'warning', ('Slow down. You can post again in %d seconds.'):format(remaining))
    return
  end
  lastPost[identifier] = now

  local payload = {
    name     = GetPlayerName(src) or "Unknown",
    message  = msg,
    image    = img,
    category = normalizeCategory(cat),
    postal   = pst,
    when     = os.date("!%Y-%m-%d %H:%M:%S") .. " UTC",
    city     = Config.CityName
  }

  TriggerClientEvent('ransom-announce:broadcast', -1, payload)
  notify(src, 'success', 'Your announcement was posted.')

  if Config.Webhook.Enabled and Config.Webhook.URL and Config.Webhook.URL ~= "" then
    sendToDiscord(payload)
  end
end)

function notify(src, ntype, text)
  TriggerClientEvent('ransom-announce:notify', src, { type = ntype, description = text })
end

function trim(s) return (tostring(s or ""):gsub("^%s*(.-)%s*$", "%1")) end

function normalizeCategory(cat)
  if not cat or cat == "" then return "Business" end
  for _, c in ipairs(Config.Categories or {}) do
    if c:lower() == cat:lower() then return c end
  end
  return "Business"
end

function getIdentifier(src)
  for _, t in ipairs({ "license2", "license", "fivem", "discord", "xbl", "live", "ip" }) do
    local id = GetPlayerIdentifierByType(src, t)
    if id and id ~= "" then return id end
  end
  for i = 0, GetNumPlayerIdentifiers(src) - 1 do
    local id = GetPlayerIdentifier(src, i)
    if id and id ~= "" then return id end
  end
  return nil
end

function GetPlayerIdentifierByType(player, idType)
  for i = 0, GetNumPlayerIdentifiers(player) - 1 do
    local id = GetPlayerIdentifier(player, i)
    if id and id:find(idType .. ":") == 1 then
      return id
    end
  end
  return nil
end

function sendToDiscord(p)
  local embeds = {{
    title = (p.category or "Announcement") .. " • " .. (p.city or "City"),
    description = p.message or "",
    color = Config.Webhook.Color or 0x43B581,
    fields = {
      { name = "From", value = ("`%s`"):format(p.name or "Unknown"), inline = true },
      { name = "When", value = p.when or "", inline = true }
    },
    footer = { text = "rsm-announce" }
  }}
  if p.postal and p.postal ~= "" then
    table.insert(embeds[1].fields, { name = "Postal", value = p.postal, inline = true })
  end
  if p.image and p.image ~= "" then
    embeds[1].image = { url = p.image }
  end
  local body = {
    username   = Config.Webhook.Username or "rsm-announce",
    avatar_url = Config.Webhook.Avatar or nil,
    embeds     = embeds
  }
  PerformHttpRequest(Config.Webhook.URL, function() end, 'POST', json.encode(body), { ['Content-Type'] = 'application/json' })
end