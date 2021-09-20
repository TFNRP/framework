RegisterCommandSuggestion({ 'me', 'do' }, 'Provide information or an action for others around you.', {
    { name = 'action/information', help = 'The action or information to disclose.' }
})
RegisterCommandSuggestion({ 'ooc', 'global' }, 'Send a global out of character message.', {
    { name = 'message', help = 'The message you would like to send.' }
})
RegisterCommandSuggestion({ 'pm', 'dm', 'message' }, 'Send a private message.', {
    { name = 'player', help = 'The player\'s server id.' },
    { name = 'message', help = 'The message you would like to send them.' },
})
RegisterCommandSuggestion({ 'ad', 'advert' }, 'Send an advert message.', {
    { name = 'message', help = 'The message you would like to advert.' },
})
RegisterCommandSuggestion({ 'darkweb' }, 'Send an anonymous darweb message.', {
    { name = 'message', help = 'The message you would like to send on the darkweb.' },
})
RegisterCommandSuggestion({ 'twt', 'tweet', 'twitter' }, 'Send a tweet.', {
    { name = 'message', help = 'The message you would like to tweet.' },
})
RegisterCommandSuggestion({ 'rt', 'retweet' }, 'Retweet the last tweet.')
RegisterCommandSuggestion({ 'dv', 'delveh' }, 'Delete the nearest vehicle.')
RegisterCommandSuggestion('duty', 'Toggle on/off duty.')
RegisterCommandSuggestion('offduty', 'Disable patrolman duties.')
RegisterCommandSuggestion('onduty', 'Enable patrolman duties.')
RegisterCommandSuggestion({ 'clean', 'wash' }, 'Clean the vehicle you\'re currently in.')
RegisterCommandSuggestion({ 'fix', 'repair' }, 'Fix the vehicle you\'re currently in.')
RegisterCommandSuggestion('hood', 'Open the hood of the vehicle you\'re currently in.')
RegisterCommandSuggestion('trunk', 'Open the trunk of the vehicle you\'re currently in.')
RegisterCommandSuggestion('door', 'Open a door of the vehicle you\'re currently in.', {
    { name = 'number', help = 'The number of the door to open. 1 is driver\'s, 2 is passenger\'s, etc.' }
})
RegisterCommandSuggestion('taserlaser', 'Toggle your taser\'s laser. Best experienced in first-person because bullets shoot from the camera.')
RegisterCommandSuggestion({ 'heal', 'health' }, 'Set your health.', {
    { name = 'amount', help = '0 = none (dead), 1 = some, 2 = under half, 3 = over half, 4 = almost max, 5 = max.' }
})
RegisterCommandSuggestion({ 'armour', 'armor' }, 'Set your armour.', {
    { name = 'amount', help = '0 = none, 1 = some, 2 = under half, 3 = over half, 4 = almost max, 5 = max.' }
})
RegisterCommandSuggestion({ 'globalme', 'gme', 'globaldo', 'gdo' }, 'Provide information or an action for players further away.', {
    { name = 'message', help = 'The message you would like to send.' }
})