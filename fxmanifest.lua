fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'od_fakeplates'
provide 'brazzers-fakeplates'
author 'Oscar Dev - Original: Brazzers Development'
version '2.0.0'

shared_scripts { '@ox_lib/init.lua', 'shared/config.lua', 'shared/detect.lua', 'locales/*.lua', 'shared/locale.lua', 'shared/class.lua' }
client_scripts {
    'bridge/core/client/*.lua', 'bridge/target/*.lua', 'bridge/keys/client/*.lua',
    'client/vehicle.lua', 'client/plates.lua', 'client/main.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua', 'bridge/core/server/*.lua', 'bridge/inventory/server/*.lua', 'bridge/keys/server/*.lua',
    'server/repository.lua', 'server/service.lua', 'server/main.lua'
}

dependencies { 'oxmysql', 'ox_lib', '/onesync' }
