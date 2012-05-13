module.exports = (src) ->
  class Model extends src.asana.Backbone.Model
    asana : src.asana
    sync  : src.sync

  class Collection extends src.asana.Backbone.Collection
    asana : src.asana
    sync  : src.sync

  class src.User extends Model
    baseUrl: "/users"

  class src.Users extends Collection
    url   : "/users"
    model : src.User

  class src.Workspace extends Model
    baseUrl: "/workspaces"

  class src.Workspaces extends Collection
    url   : "/workspaces"
    model : src.Workspace

