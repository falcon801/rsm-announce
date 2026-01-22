
Config = {}

Config.AnyoneCanAdvertise = true
Config.CooldownSeconds    = 20
Config.MaxMessageLength   = 300
Config.MinMessageLength   = 8
Config.MaxImageURLLength  = 600
Config.AllowImages        = true
Config.RequireURLPrefix   = true

Config.ShowOnScreen = true
Config.ChatEcho     = false   
Config.PlaySound    = false

Config.Categories = { "Business", "Services", "Events", "Vehicles", "Real Estate", "Recruitment", "Misc" }

Config.Webhook = {
  Enabled  = true,
  URL      = "",
  Username = "",
  Avatar   = "",
  Color    = 0x1FE47A
}

Config.Commands = {
  OpenUI = 'ad',
  Quick  = 'admsg'
}

Config.CityName = ""  --set to cityname
Config.UITitle  = ""  --set as well

Config.BlockedPhrases = { "d i s c o r d", "mod menu", "cheat menu" }
