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