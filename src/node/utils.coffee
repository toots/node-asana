{fromByteArray} = require "base64-js"

utf8ToBytes = (str) ->
  byteArray = []
  for i in [0..str.length]
    if str.charCodeAt(i) <= 0x7F
      byteArray.push str.charCodeAt(i)
    else
      h = encodeURIComponent(str.charAt(i)).substr(1).split "%"
      for j in [0..h.length]
        byteArray.push parseInt(h[j], 16)

  byteArray

# For the browser..
module.exports.b64 = (str) ->
  fromByteArray utf8ToBytes(str)

module.exports.clone = clone = (src) ->
  dst = {}

  for key, value of src
    if typeof value == "object"
      value = clone(value)

    dst[key] = value

  dst

module.exports.defaults = (defaults, src = {}) ->
  res = clone defaults

  for key, value of src
    res[key] = value

  res

# For objects only!
module.exports.isEmpty = (obj) ->
  for key of obj
    return false

  true

# Custom querystring.stringify
module.exports.querystringify = (arg) ->
  params = []
  for key, value of arg
    if value.toString?
      params.push "opt_#{key}=#{value.toString()}"
    else
      params.push "opts_#{key}=#{value}"

  params.join "&"
