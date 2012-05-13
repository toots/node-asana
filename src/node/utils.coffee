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
    continue unless value?

    if typeof value == "object"
      if value instanceof Array
        value = value.slice()
      else
        value = clone(value)

    dst[key] = value

  dst

module.exports.defaults = (defaults, src = {}) ->
  res = clone defaults

  for key, value of src
    res[key] = value

  res

module.exports.idify = idify = (src) ->
  return src unless typeof src == "object"

  return src.id if src.id?

  for key, value of src
    continue unless typeof value == "object"

    if value instanceof Array
      res = []
      for element in value
        res.push idify(element)

      src[key] = res
    else
      src[key] = idify value

  src

# For objects only!
module.exports.isEmpty = (obj) ->
  for key of obj
    return false

  true

# I/O options are prefixed by "opt_"
# in GET mode. "method" option is not
# supported yet..
ioOptions = ["pretty", "fields", "expand"]
optName = (name) ->
  if ioOptions.indexOf(name) != -1
    "opt_#{name}"
  else
    name

# Custom querystring.stringify
module.exports.querystringify = (arg) ->
  params = []
  for key, value of arg
    key = optName key
    if value?.toString?
      params.push "#{key}=#{value.toString()}"
    else
      params.push "#{key}=#{value}"

  params.join "&"
