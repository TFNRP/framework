fx_version 'cerulean'
game 'gta5'

client_script {
    'util.lua',
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
    'util.lua',
    'server.lua',
}
server_export {
    'IsOnDuty',
    'RegisterFrameworkCommand',
}
dependency 'copyutil' -- https://github.com/MrGriefs/copyutil