{Asana}   = require "./asana"
{inspect} = require "util"

console.dir = ->
  console.log.apply this, (inspect(value, false, 3) for value in arguments)

module.exports = (key, workspace) ->
  {user, Users, Workspaces}= new Asana
    key : key

  user.fetch
    success: ->
      console.log "My user:"
      console.dir user.toJSON()

    error: (model, err) ->
      console.log "Error while fetching my user:"
      console.dir err

  users = new Users

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

  workspaces = new Workspaces

  workspaces.fetch
    success: ->
      console.log "Asana workspaces:"
      console.dir workspaces.toJSON()

    error: (model, err) ->
      console.log "Error while fetching workspaces:"
      console.dir err
