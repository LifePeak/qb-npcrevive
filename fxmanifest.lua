fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'goldberg_official'
description 'A Script for SaltyV | NPC Medic Revivestation'
version '1.0.0'


shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/de.lua',
    'config.lua',
    'helper.lua',
}

client_scripts {
    'client/main.lua',
}

server_script 'server/main.lua'

