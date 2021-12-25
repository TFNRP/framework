Config = {
  PlayerDisplayPrefixes = {
    {'prefix.admin', '^1[Administrator] '},
    {'prefix.moderator', '^2[Moderator] '},
    {'prefix.staff', '^2[Staff] '},
    {'prefix.lspd', '^5[LSPD] '},
    {'prefix.bcso', '^3[BCSO] '},
    {'prefix.sahp', '^3[SAHP] '},
    {'prefix.safr', '^2[SAFR] '},
    {'prefix.sast', '^5[SAST] '},
  },
  SwearFilter = {
    'nigger',
    'nigg?a',
    'retard',
    'nazi',
    'hitler',
    'fag',
    'faggot',
  },
  DefaultDensity = .5,
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
  Reminders = {
    Interval = 10,
    Messages = {
      'Join our ^6Discord^7 server: ^5^_https://discord.gg/Hfxz3Aj',
      'Join our ^6Discord^7 server: ^3^_/discord',
      'Make sure you\'re up to date with the ^3^_/rules',
      'Make sure to read the rules on our ^6Discord^7: ^3^_/rules',
      'Want to become an ^4LEO^7 or ^1Fire^7/^1EMS^7? Get ^3whitelisted^7 by asking a ^5moderator^7 or joining the ^6Discord^7 server: ^3^_/discord',
      'Unsure about keybinds? Need help getting started? Use the ^3^_/help^0^r command!',
      'The server uses ^6OneSync Infinity^7, so you can only see ^3nearby^7 players.',
      function()
        local admins = {}
        for _, player in ipairs(GetPlayers()) do
          for _, arr in ipairs({
            { 'prefix.admin', '~r~' },
            { 'prefix.moderator', '~g~' },
          }) do
            if IsPlayerAceAllowed(player, arr[1]) then
              table.insert(admins, arr[2] .. (GetPlayerName(player) or 'Someone') .. '~s~')
              break
            end
          end
        end

        local str = ''
        for i, name in ipairs(admins) do
          if i == #admins then
            str = str .. name
          else
            str = str .. name .. ', '
          end
        end
        if #admins == 0 then
          return 'There are currently 0 moderators online.'
        else
          return 'There are currently ' .. #admins .. ' moderators online: ' .. str
        end
      end,
      function()
        if #GetPlayers() <= 3 then
          return "Looks like not many people are online. You can join the ^6Discord^7 server to be notified when more people are on: ^5^_/discord^7"
        end
      end
    },
  },
}