<h2 align="center">TFNRP Framework</h2>

<p align="center">
<a href="https://patreon.com/JustAPaw"><img alt="Patreon" src="https://img.shields.io/badge/patreon-donate?color=F77F6F&labelColor=F96854&logo=patreon&logoColor=ffffff"></a>
<a href="https://discord.gg/xHaPKfSDtu"><img alt="Discord" src="https://img.shields.io/discord/463778631551025187?color=7389D8&labelColor=6A7EC2&logo=discord&logoColor=ffffff"></a>
<a href="https://cfx.re/join/734okr"><img alt="FiveM" src="https://img.shields.io/badge/connect-fivem?color=E01A59&labelColor=F40552&logo=fivem&logoColor=ffffff"></a>
</p>

## Table of Contents

- [About](#about)
- [Documentation](#documentation)
  - [Server Convars](#server-convars)
  - [Server Commands](#server-commands)

## About

The framework used by and created for TFNRP

## Documentation

### Server Convars

Server convars which can be used with the framework in order convar usage and convar description.  
You can set a convar with `set some_convar`. Client replication (`setr`) not needed unless specified.

`set reminders_interval <integer>`: The interval between each reminder, in minutes. Default: `5`  
`set reminders_prefix <string>`: The reminder's prefix. Default: `'^3^*[System]'`  
`set framework_ServerNotifications_chatPublic <string>`: A Discord webhook to be used with the `chatPublic` notification.  
`set framework_ServerNotifications_chatPrivate <string>`: A Discord webhook to be used with the `chatPrivate` notification.  
`set framework_ServerNotifications_staffPublic <string>`: A Discord webhook to be used with the `staffPublic` notification.  
`set framework_ServerNotifications_staffPrivate <string>`: A Discord webhook to be used with the `staffPrivate` notification.  
`set framework_ServerNotifications_serverPublic <string>`: A Discord webhook to be used with the `serverPublic` notification.  
`set framework_ServerNotifications_serverPrivate <string>`: A Discord webhook to be used with the `serverPrivate` notification.  

### Server Commands

Commands which are used in `server.cfg`, i.e. `add_ace`.  
Not to be confused with in-game commands, but they *can* also be used in-game.  

`reminders_add <string>`: Adds a reminder, can be used instead of editing them via `config.lua`.  
`reminders_remove [integer]`: Removes the last reminder. Can also supply the number of the reminder.  
