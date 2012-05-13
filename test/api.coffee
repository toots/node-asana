Asana     = require "./asana"
{inspect} = require "util"

console.dir = ->
  console.log.apply this, (inspect(value, false, 3) for value in arguments)

testObject = (name, object, opts, fn) ->
  if typeof opts == "object"
    fn = fn || ->
  else
    unless fn?
      fn   = opts || ->
      opts = {}

  opts.success = ->
      console.log "#{name}:"
      console.dir object.toJSON()

      fn()

  opts.error = (model, err) ->
      console.log "Error while fetching #{name}:"
      console.dir err

  object.fetch opts

module.exports = (key, workspace) ->
  {user, Users, Workspaces}= new Asana
    key : key

  testObject "my user", user

  users = new Users

  testObject "users", users, ->
    testObject "one user", users.models[0]

  workspaces = new Workspaces

  testObject "workspaces", workspaces, ->
    workspace = workspaces.models[0]

    testObject "one workspace", workspace, ->
      testObject "workspace users",    workspace.users

      testObject "workspace tasks",    workspace.tasks,
        asana:
          assignee: user.id

      testObject "workspace projects", workspace.projects, ->
        project = workspace.projects.models[0]

        testObject "one project", project, ->
          testObject "project tasks", project.tasks, ->
            task = project.tasks.models[0]

            testObject "one task from one project", task, ->
              testObject "tasks' stories", task.stories, ->
                story = task.stories.models[0]

                testObject "one story", story
