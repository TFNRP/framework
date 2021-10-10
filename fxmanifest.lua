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
    -- 'RegisterFrameworkCommand', Failed export defined in "server_export"?
}
server_script {
    'dependencies/**.lua',
    'config.lua',
    'server.lua',
}
server_export {
    'GetPlayerDuty',
    'RegisterFrameworkCommand',
}
dependency 'copyutil' -- https://github.com/MrGriefs/copyutil