require "backbone.modelizer"
{clone} = require "./utils"

module.exports = (src) ->
  class Model extends src.asana.Backbone.Model
    asana : src.asana
    sync  : src.sync

  class Collection extends src.asana.Backbone.Collection
    asana : src.asana
    sync  : src.sync

  class src.User extends Model
    urlRoot: "/users"

  class src.Users extends Collection
    url   : ->
      if @workspace?
        "/workspaces/#{@workspace.id}/users"
      else
        "/users"
    model : src.User

  class src.Story extends Model
    urlRoot: "/stories"

    initialize: ->
      @asana = clone @asana
      @asana.savedAttributes = (method, model) ->
        res = clone model.attributes
        delete res.id
        delete res.created_at
        delete res.created_by
        delete res.text unless method == "POST"
        delete res.target
        delete res.source
        delete res.type

        res

  class src.Stories extends Collection
    url   : ->
      if @task?
        "/tasks/#{@task.id}/stories"
      else
        "/stories"
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
        delete res.tags
        delete res.workspace unless method == "POST"

        res

      self = this

      class this.Story extends src.Story
        url: => "/tasks/#{self.id}/stories"

    associations: ->
      assignee:
        model: src.User
      followers:
        collection: src.Users
        scope:      "followers"
      workspace:
        model: src.Workspace
      stories:
        collection: src.Stories
        scope:      "task"
      projects:
        collection: src.Projects
        scope:      "task"

  class src.Tasks extends Collection
    url   : ->
      if @workspace?
        "/workspaces/#{@workspace.id}/tasks"
      else if @project?
        "/projects/#{@project.id}/tasks"
      else
        "/tasks"
    model : src.Task

  class src.Project extends Model
    urlRoot: "/projects"

    initialize: ->
      @asana = clone @asana
      @asana.savedAttributes = (method, model) ->
        res = clone model.attributes
        delete res.id
        delete res.created_at
        delete res.followers unless method == "POST"
        delete res.modified_at
        delete res.workspace unless method == "POST"

        res

    associations: ->
      workspace:
        model: src.Workspace
      tasks:
        collection: src.Tasks
        scope:      "project"

  class src.Projects extends Collection
    url   : ->
      if @task?
        "/tasks/#{@task.id}/projects"
      else if @workspace?
        "/workspaces/#{@workspace.id}/projects"
      else
        "/projects"
    model : src.Project

  class src.Workspace extends Model
    urlRoot: "/workspaces"

    associations: ->
      users:
        collection: src.Users
        scope:      "workspace"
      tasks:
        collection: src.Tasks
        scope:      "workspace"
      projects:
        collection: src.Projects
        scope:      "workspace"

  class src.Workspaces extends Collection
    url   : "/workspaces"
    model : src.Workspace

