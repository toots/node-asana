option '-k', '--key [KEY]', 'Set asana client key for tests.'
option '-w', '--workspace [WORKSPACE]', 'Set asana workspace for tests.'

{exec} = require "child_process"

call = (command, fn) ->
  exec command, (err, stdout, stderr) ->
    if err?
      console.error "Error :"
      return console.dir   err

    fn err if fn?

build = (fn) ->
  call "coffee -c -o lib/node/ src/node/*.coffee", ->
    call "rm -rf tmp && mkdir tmp && cp src/node/*.coffee src/browser/*.coffee tmp && browserify tmp/entry.coffee -o lib/browser/asana.js", ->
      call "minifyjs lib/browser/asana.js > lib/browser/asana.min.js", ->
        call "rm -rf tmp && mkdir tmp && cp src/node/*.coffee test/*.coffee test/browser/wrapper.coffee tmp && browserify tmp/wrapper.coffee -o test/browser/files/bundle.js", fn

task 'build', 'Compile coffee scripts into plain Javascript files', ->
  build ->
    console.log "Done!"

task 'test', 'Run the tests', (args) ->
  key = args.key || process.env["ASANA_KEY"]
  app = args.app || process.env["ASANA_WORKSPACE"]

  build ->
    exec "rm -rf tmp && mkdir tmp && cp src/node/*.coffee test/*.coffee tmp", ->
      require("./tmp/api")(key, app)

