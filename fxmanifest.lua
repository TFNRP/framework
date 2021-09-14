fx_version 'cerulean'
game 'gta5'

shared_script {
    'config.lua',
    'util.lua',
}
client_script {
    'client.lua',
    'presence.lua',
    'suggestions.lua',
}
export {
    'IsLocalClientOnDuty',
    'RegisterCommandSuggestion',
    'RegisterCommandAlias',
    'RegisterFrameworkCommand',
}
server_script {
    'server.lua',
}
server_export {
    'IsOnDuty',
    'RegisterFrameworkCommand',
}
dependency 'copyutil' -- https://github.com/MrGriefs/copyutil