Asana API for node
==================

This module provide a wrapper to the [Asana API](http://developer.asana.com/documentation/) 
for [nodeJS](http://nodejs.org/) applications.

Ultimately, a support in the browser, using [node-browserify](https://github.com/substack/node-browserify)
is also planned.

Usage
=====

```
Asana = require "./asana"

asana = new Asana
  key : "deadbeef"

asana.user.fetch
  success : -> ...
  error   : -> ...

users = new asana.Users
users.fetch
  error   : -> ...
  success : -> 
    workspaces = new asana.Workspaces

    workspaces.fetch
      error    : -> ...
      successs : ->
        workspace = workspaces.first 

        task = new asana.Task
          assignee  : users.find (user) ->
            users.name == "John Difool"
          followers : [user]
          name      : "Protect the Incal"
          workspace : workspace

        task.save
          error   : -> ...
          success : -> ...
```

Get the facts!
==============

* Base reference: [Asana API](http://developer.asana.com/documentation/)
* All asana items are [backbone](http://documentcloud.github.com/backbone/) models.
  You can fetch and save them as is usually done with backbone models. However, asana
  API does not allow to create or save some items.
* All asana attributes are stored as model attributes. Creation arguments are those
  documented in the Asana API.
* It is possible to pass models or IDs as attributes values. 
* Items structure is:
    * `asana = new Asana key : asanaKey`:
        * `asana.user` : Current asana user
        * `asana.Users` : Collection of all known users
        * `asana.Stories` : Collection of all stories
        * `asna.Workspace` : Basic model for asana workspaces
        * `asana.Workspaces` : Collection of all asana workspaces
        * `asana.Project` : Basic model for asana projects
        * `asana.Projects` : Collection of all asana projects
        * `asana.Task` : Base task model
        * `asana.Tasks` : Collection of available tasks. 
        * `task = new asana.Task params`: 
            * `task.Story` : Basic model to create a new story attached to
                            `task`
            * `task.stories` : Collection of all stories attached to `task`
            * `task.projects` : Collection of all projects to which `task` belongs

You can use your own copy of `Backbone` by passing it as an option
when instanciating `asana`'s client:
```
  asana = new Asana
    key      : "deadbeef"
    Backbone : myBackbone
```
