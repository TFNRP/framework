fx_version 'cerulean'
game 'gta5'

shared_script {
    'util.lua',
}
client_script {
    'client.lua',
    'presence.lua',
    'suggestions.lua',
}
export {
    'GetLocalClientDuty',
    'RegisterCommandSuggestion',
    'RegisterCommandAlias',
    'RegisterFrameworkCommand',
}
server_script {
    'dependencies/**.lua',
    'config.lua',
    'server.lua',
}
server_export {
    'IsOnDuty',
    'RegisterFrameworkCommand',
}
dependency 'copyutil' -- https://github.com/MrGriefs/copyutil