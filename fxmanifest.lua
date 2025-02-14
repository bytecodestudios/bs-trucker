fx_version 'bodacious'
game 'gta5'
lua54 'yes'

author "Cadburry (Bytecode Studios)"
description "Trucker Job for Snappy Phone Party System"

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}

client_scripts {
    'bridge/**/client.lua',
    'modules/**/client.lua',
}

server_scripts {
    'bridge/**/server.lua',
    'modules/**/server.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
    'snappy-phone',
    'cad-pedspawner'
}