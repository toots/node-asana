{Asana}   = require "./asana"
{inspect} = require "util"

console.dir = ->
  console.log.apply this, (inspect(value, false, 3) for value in arguments)

module.exports = (key, workspace) ->
  asana = new Asana
    key : key

  users = new asana.Users

  users.fetch
    success: ->
      console.log "Asana users:"
      console.dir users.toJSON()

      return unless users.models.length > 0

      user = users.models[0]

      user.fetch
        asana:
          fields : ["mame", "email"]

        success: ->
          console.log "One user:"
          console.dir user.toJSON()

        error: (model, err) ->
          console.log "Error while fetching user:"
          console.dir err

    error: (model, err) ->
      console.log "Error while fetching users:"
      console.dir err
