Config = {
  PlayerDisplayPrefixes = {
    {'prefix.admin', '^1[Administrator] '},
    {'prefix.moderator', '^2[Moderator] '},
    {'prefix.staff', '^2[Staff] '},
    {'prefix.lspd', '^5[LSPD] '},
    {'prefix.bcso', '^8[BCSO] '},
    {'prefix.sahp', '^3[SAHP] '},
    {'prefix.sams', '^2[SAMS] '},
  },
  ServerNotifications = {
    chatPublic = {
      GetConvar('framework_ServerNotifications_chatPublic', ''),
      function (source, data)
        local username = GetPlayerName(source)
        if not username then username = 'N/A' end
        username = username .. ' [ID: ' .. source .. ']'
        return {
          username = username,
          content = data,
          allowed_mentions = { -- content sanitisation
            parse = { 'roles', 'users', 'everyone' }
          },
        }
      end
    },
    chatPrivate = {
      GetConvar('framework_ServerNotifications_chatPrivate', ''),
      function (source, data)
        local username = GetPlayerName(source)
        if not username then username = 'N/A' end
        username = username .. ' [ID: ' .. source .. ']'
        return {
          username = username,
          content = data,
          allowed_mentions = { -- content sanitisation
            parse = { 'roles', 'users', 'everyone' }
          },
        }
      end
    },
    staffPublic = {
      GetConvar('framework_ServerNotifications_staffPublic', ''),
      function (source, data)
        return {
          username = 'System',
          content = '',
          embeds = {
            {
              title = data.title,
              description = data.description,
              footer = data.footer,
              fields = data.fields,
              color = 0x15A3C7,
            }
          },
          allowed_mentions = {
            parse = { 'roles', 'users', 'everyone' }
          },
        }
      end
    },
    staffPrivate = {
      GetConvar('framework_ServerNotifications_staffPrivate', ''),
      function (source, data)
        return {
          username = 'System',
          content = '',
          embeds = {
            {
              title = data.title,
              description = data.description,
              footer = data.footer,
              fields = data.fields,
              color = 0x15A3C7,
            }
          },
          allowed_mentions = {
            parse = { 'roles', 'users', 'everyone' }
          },
        }
      end
    },
    serverPublic = {
      GetConvar('framework_ServerNotifications_serverPublic', ''),
      function (source, data)
        return {
          username = 'System',
          content = '```css\n' .. data .. '\n```',
          allowed_mentions = {
            parse = { 'roles', 'users', 'everyone' }
          },
        }
      end
    },
    serverPrivate = {
      GetConvar('framework_ServerNotifications_serverPrivate', ''),
      function (source, data)
        return {
          username = 'System',
          content = '```css\n' .. data .. '\n```',
          allowed_mentions = {
            parse = { 'roles', 'users', 'everyone' }
          },
        }
      end
    },
  },
}