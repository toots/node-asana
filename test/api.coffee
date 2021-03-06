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

  opts.success = fn

  opts.error = (model, err) ->
    console.log "Error while fetching #{name}:"
    console.dir err

  object.fetch opts

saveObject = (name, object, opts, fn) ->
  if typeof opts == "object"
    fn = fn || ->
  else
    unless fn?
      fn   = opts || ->
      opts = {}

  opts.success = fn

  opts.error = (model, err) ->
    console.log "Error while save #{name}:"
    console.dir err

  object.save null, opts

runTests = (asana, workspaceID) ->
  {user, Users,
    Task,
    Workspaces,
    Workspace}  = asana

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

  workspace = new Workspace
    id : workspaceID

  testObject "Test workspace", workspace, ->
    originalName = workspace.get "name"
    workspace.set name: "Updated test workspace"

    saveObject "Test workspace", workspace, ->
      workspace.set name: originalName

      saveObject "Test workspace", workspace

    task = new Task
      assignee  :  user
      followers : [user]
      name      : "Test task (#{Math.random().toString(36).substring(7)})"
      workspace : workspace

    saveObject "new task", task, ->
      story = new task.Story
        text : "New story"
       
      saveObject "new story", story

      task.set completed: true

      saveObject "new task", task

module.exports = (key, workspaceID) ->
  asana = new Asana
    key : key

  testObject "my user", asana.user, ->
    runTests asana, workspaceID
