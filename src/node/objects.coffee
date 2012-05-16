{attributify, clone} = require "./utils"

module.exports = (src) ->
  class Model extends src.asana.Backbone.Model
    asana : src.asana
    sync  : src.sync

    set: (attr, val, options) ->
      super attributify(attr), attributify(val), options

  class Collection extends src.asana.Backbone.Collection
    asana : src.asana
    sync  : src.sync

  class src.User extends Model
    urlRoot: "/users"

  class src.Users extends Collection
    url   : "/users"
    model : src.User

  class src.Story extends Model
    urlRoot: "/stories"

  class src.Stories extends Collection
    url   : "/stories"
    model : src.Story

  class src.Task extends Model
    urlRoot: "/tasks"

    initialize: ->
      @asana = clone @asana
      @asana.savedAttributes = (method, model) ->
        res = clone model.attributes
        delete res.id
        delete res.created_at
        delete res.completed_at
        delete res.followers unless method == "POST"
        delete res.modified_at
        delete res.projects
        delete res.workspace unless method == "POST"

        res

      @stories      = new src.Stories
      @stories.url  = =>
        "/tasks/#{@id}/stories"

      @projects     = new src.Projects
      @projects.url = =>
        "/tasks/#{@id}/projects"

  class src.Tasks extends Collection
    url   : "/tasks"
    model : src.Task

  class src.Project extends Model
    urlRoot: "/projects"

    initialize: ->
      @tasks     = new src.Tasks
      @tasks.url = =>
        "/projects/#{@id}/tasks"

  class src.Projects extends Collection
    url   : "/projects"
    model : src.Project

  class src.Workspace extends Model
    urlRoot: "/workspaces"

    initialize: ->
      @users     = new src.Users
      @users.url = =>
        "/workspaces/#{@id}/users"

      @tasks     = new src.Tasks
      @tasks.url = =>
        "/workspaces/#{@id}/tasks"

      @projects     = new src.Projects
      @projects.url = =>
        "/workspaces/#{@id}/projects"

  class src.Workspaces extends Collection
    url   : "/workspaces"
    model : src.Workspace

