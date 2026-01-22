fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ransom-announce'
author 'you'
description 'Business announcements with Discord webhook + Postal (no sound)'
version '1.0.6'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/styles.css',
  'html/script.js'
}

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'

dependencies {
  'ox_lib'
}