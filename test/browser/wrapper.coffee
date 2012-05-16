
window.console ||= {}

window.console.log = (val) ->
  $("#foo").append "#{val}<br/>"

util = require "util"

window.console.dir = (val) ->
  console.log util.inspect(val)

$ ->
  console.log "ready!"
  $("#run").click ->
    key = $("#key").val()
    key = $("#workspace").val()
    require("./api") key, workspace
