{b64,defaults,
 querystringify,
 isEmpty}           = require "./utils"
{Collection, Model} = require "backbone"

class module.exports.Asana
  constructor: (opts) ->
    @asana =
      params :
        auth    : b64 "#{opts.key}:"
        path    : opts.path    || "/api/1.0"
        host    : opts.host    || "app.asana.com"
        scheme  : opts.scheme  || "https"
        options : opts.options || {}

      # Default methods
      read : ->
        method  : "GET"
        expects : 200

    # For browserify..
    if @asana.params.scheme == "https"
      @asana.http = require "https"
      @asana.params.port = opts.port || 443
    else
      @asana.http = require "http"
      @asana.params.port = opts.port || 80

    # Add models and collections
    addObjects this

  sync: (method, model, opts = {}) ->
    params  = model.asana[method]()

    url    = if typeof @url == "function" then @url() else @url
    expects = params.expects || 200
    query   = params.query
    error   = opts.error   || ->
    success = opts.success || ->

    # Get options but remove error and success..
    options = defaults @asana.params.options, opts.asana

    headers =
      "Accept"               : "application/json"
      "Authorization"        : "Basic #{@asana.params.auth}"

    http_opts =
      host    : @asana.params.host
      port    : @asana.params.port
      method  : params.method || "GET"
      path    : "#{@asana.params.path}#{url}"
      headers : headers
      scheme  : @asana.params.scheme

    unless isEmpty options
      if http_opts.method == "GET"
        http_opts.path = "#{http_opts.path}?#{querystringify(options)}"
      else
        query ||= {}
        query.options = options

    if query?
      query = JSON.stringify query

      opts.headers["Content-Type"]   = "application/json"
      opts.headers["Content-Length"] = query.length

    req = @asana.http.request http_opts, (res) ->
      data = ""
      res.on "data", (buf) -> data += buf
      res.on "end", ->
        try
          data = JSON.parse data
        catch err

        if res.statusCode != expects
          err =
            code     : res.statusCode
            headers  : res.headers
            options  : http_opts
            query    : query
            response : data

          return error model, err

        success data.data, res.statusCode, res

    req.end query

# Objects

class User extends Model
  baseUrl: "/users"

class Users extends Collection
  url: "/users"

class Workspace extends Model
  baseUrl: "/workspaces"

class Workspaces extends Collection
  url: "/workspaces"

# Add objects

addModel = (client, name, klass) ->
  class client[name] extends klass
    asana: client.asana

    sync: ->
      client.sync.apply this, arguments

addCollection = (client, name, klass, model) ->
  addModel client, name, klass
  klass::model = client[model]

addObjects = (client) ->
  for name, klass of objects.models
    addModel client, name, klass

  for name, {klass, model} of objects.collections
    addCollection client, name, klass, model

objects =
  models:
    "User"      : User
    "Workspace" : Workspace

  collections:
    "Users"     :
      klass : Users
      model : "User"

    "Workspaces" :
      klass : Workspaces
      model : "Workspace"
