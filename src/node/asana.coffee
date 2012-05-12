{b64,defaults,
 querystringify,
 isEmpty}        = require "./utils"

class module.exports.Asana
  constructor: (opts) ->
    @auth    = b64 "#{opts.key}:"
    @version = "1.0" # Read only for now!
    @path    = opts.path    || "/api/#{@version}"
    @host    = opts.host    || "app.asana.com"
    @scheme  = opts.scheme  || "https"
    @options = opts.options || {}

    # For browserify..
    if @scheme == "https"
      @http = require "https"
      @port = opts.port || 443
    else
      @http = require "http"
      @port = opts.port || 80

    # Add User class
    this.User = defaults this, User

  request: (opts, options, fn) ->
    unless fn?
      fn      = options
      options = {}

    expects = opts.expects || 200
    query   = opts.query
    options = defaults @options, options

    headers =
      "Accept"               : "application/json"
      "Authorization"        : "Basic #{@auth}"

    opts =
      host    : @host
      port    : @port
      method  : opts.method || "GET"
      path    : "#{@path}#{opts.path}"
      headers : headers
      scheme  : @scheme

    unless isEmpty options
      if opts.method == "GET"
        opts.path = "#{opts.path}?#{querystringify(options)}"
      else
        query ||= {}
        query.options = options

    if query?
      query = JSON.stringify query

      opts.headers["Content-Type"]   = "application/json"
      opts.headers["Content-Length"] = query.length

    req = @http.request opts, (res) ->
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
            options  : opts
            query    : query
            response : data

          return fn err, null

        fn null, data.data

    req.end query

class User
  @all: (opts, fn) ->
    @request { path: "/users" }, opts, fn
