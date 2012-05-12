{Asana}   = require "./asana"
{inspect} = require "util"

console.dir = ->
  console.log.apply this, (inspect(value, false, 3) for value in arguments)

module.exports = (key, workspace) ->
  asana = new Asana
    key : key

  asana.User.all { pretty: true, fields: ["name", "email"] }, (err, users) ->
    if err?
      console.log "Error while fetching all asana users:"
      return console.dir err

    console.log "Asana users:"
    console.log users

