{b64,defaults,clone,
 querystringify,
 isEmpty}        = require "./utils"
Backbone         = require "backbone"
addObjects       = require "./objects"

class Asana
  constructor: (opts) ->
    @asana =
      params :
        auth     : b64 "#{opts.key}:"
        path     : opts.path     || "/api/1.0"
        host     : opts.host     || "app.asana.com"
        scheme   : opts.scheme   || "https"
        options  : opts.options  || {}

      # Backbone
      Backbone: opts.Backbone || Backbone

      # Default methods
      read: ->
        method  : "GET"
        expects : 200

      update: (model) ->
        query = clone model.attributes
        delete query.id

        method  : "PUT"
        expects : 200
        query   : query

    # For browserify..
    if @asana.params.scheme == "https"
      @asana.http = require "https"
      @asana.params.port = opts.port || 443
    else
      @asana.http = require "http"
      @asana.params.port = opts.port || 80

    # Add object
    addObjects this

    # Add myself
    @user     = new @User
    @user.url = "/users/me"

  sync: (method, model, opts = {}) ->
    params  = model.asana[method] model

    url    = if typeof @url == "function" then @url() else @url
    expects = params.expects || 200
    error   = opts.error     || ->
    success = opts.success   || ->

    if method == "GET"
      query = undefined
    else
      query = data: params.query || {}

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

      http_opts.headers["Content-Type"]   = "application/json"
      http_opts.headers["Content-Length"] = query.length

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

module.exports = Asana
