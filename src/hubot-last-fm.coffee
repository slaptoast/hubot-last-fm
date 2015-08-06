# Description:
#   Looks up what people are listening via Last.fm
#
# Dependencies:
#   none
#
# Configuration:
#   HUBOT_LAST_FM_API_KEY
#
# Commands:
#   what's playing - Gets the latest tracks for all Last.fm users in the team
#   what's weekly artists
#   what's <user name> listening to - Gets the latest tracks for <user name>
#   what's <user name> playing - Gets the latest tracks for <user name>
#   add last.fm <user name> <Last.fm name> - Adds <Last.fm name> for <user name>
#   update last.fm <user name> <Last.fm name> - Updates the Last.fm username for <user name> to be <Last.fm name>
#   what's <user name> weekly artists
# Notes:
#   Add a JSON file mapping users to Last.fm user names in `data/last-fm-users.json`
#
# Author:
#   derekpeterson

fs = require 'fs'

API_KEY = process.env.HUBOT_LAST_FM_API_KEY
unless API_KEY?
  console.log "[hubot-last-fm] Missing Last.fm API key (HUBOT_LAST_FM_API_KEY) in environment"
  process.exit(1)

userList = {}
fs.readFile './data/last-fm-users.json', (err, data) ->
  if err
    console.log "[hubot-last-fm] You can provide a Last.fm user list in `data/last-fm-users.json`"
    return
  userList = JSON.parse(data)

getWeeklyArtist = (msg, usr, slackName) ->
  msg.http('http://ws.audioscrobbler.com/2.0/?')
    .query(
      method: 'user.getweeklyartistchart'
      user: usr
      api_key: API_KEY
      format: 'json'
      limit: 5
    )
    .get() (err, res, body) ->
      if err or res.statusCode isnt 200
        msg.send "NO MUSIC FOR YOU: #{err}"
        return

      results = JSON.parse(body)
      if results.error
        msg.send "Nothing for #{usr}: #{results.message}"
        return

      artists = results?.weeklyartistchart?.artist

      unless artists?
        msg.send "#{usr}: *silence*"
        return

      artistStr = for ix, artist of artists
        "#{artist.name} [Tracks: #{artist.playcount}]"


      msg.send "#{slackName}: #{artistStr}"



getLastTrack = (msg, usr, slackName) ->
  msg.http('http://ws.audioscrobbler.com/2.0/?')
    .query(
      method: 'user.getrecenttracks'
      user: usr
      api_key: API_KEY
      format: 'json'
      limit: 1
    )
    .get() (err, res, body) ->
      if err or res.statusCode isnt 200
        msg.send "NO MUSIC FOR YOU: #{err}"
        return

      results = JSON.parse(body)
      if results.error
        msg.send "Nothing for #{usr}: #{results.message}"
        return

      song = results?.recenttracks?.track

      unless song?
        msg.send "#{usr}: *silence*"
        return

      song = if song.length? then song[0] else song
      songStr = "\"#{song.name}\" by #{song.artist['#text']} (#{song.url})"
      msg.send "#{slackName}: #{songStr}"

getLatest = (msg, usr, person) ->
  if usr
    getLastTrack msg, usr, person
  else
    for name, user of userList
      getLastTrack msg, user, 

getLatestWeekly = (msg, usr, person) ->
  if usr
    getWeeklyArtist msg, usr, person
  else
    for name, user of userList
      getWeeklyArtist msg, user,       

setUser = (msg, slackName, lastFmName) ->
  userList[slackName] = lastFmName
  msg.send "Set #{slackName} as #{lastFmName} on Last.fm"

module.exports = (robot) ->
  robot.hear /what'?s playing/i, (msg) ->
    getLatest msg

  robot.hear /what'?s weekly artists/i, (msg) ->
    getLatestWeekly msg

  robot.hear /what'?s (.*) (?:weekly artists)/i, (msg) ->
    person = msg.match[1]
    username = userList[person]
    unless username
      msg.send "I don't have a Last.fm username for #{person}"
      return
    getLatestWeekly msg, username, person

  robot.hear /what'?s (.*) (?:listening|playing)/i, (msg) ->
    person = msg.match[1]
    username = userList[person]
    unless username
      msg.send "I don't have a Last.fm username for #{person}"
      return
    getLatest msg, username, person

  robot.hear /what am I (?:playing|listening)/i, (msg) ->
    username = userList[msg.message.user.name]
    unless username
      msg.send "You (#{msg.message.user.name}) don't have a Last.fm username set"
      return
    getLatest msg, username, msg.message.user.name

  robot.hear /add last.?fm (.*) (.*)/i, (msg) ->
    slackName = msg.match[1]
    lastFmName = msg.match[2]
    if userList[slackName]
      msg.send "Use \"update last.fm #{slackName} #{lastFmName}\" to update #{slackName}'s Last.fm name"
      return
    setUser msg, slackName, lastFmName

  robot.hear /update last.?fm (.*) (.*)/i, (msg) ->
    setUser msg, msg.match[1], msg.match[2]

  robot.hear /last.?fm roster/i, (msg) ->
    users = for slack, last of userList
      "#{slack}: #{last}"
    msg.send users.join '\n'