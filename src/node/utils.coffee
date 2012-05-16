_               = require "underscore"
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

fold = (src, dst, fn) ->
  _.reduce src, fn, dst

module.exports.clone = clone = _.clone

module.exports.defaults = (defaults, src = {}) ->
  res = clone defaults

  for key, value of src
    res[key] = value

  res

module.exports.idify = idify = (src) ->
  return src unless src? and typeof src == "object"

  return src.id if src.id?

  if src instanceof Array
    return (idify element for element in src)

  fold src, {}, (cur, value, key) ->
    cur[key] = idify value
    return cur

module.exports.attributify = attributify = (src) ->
  return src unless src? and typeof src == "object"

  return src.attributes if src.attributes?

  if src instanceof Array
    return (attributify element for element in src)

  fold src, {}, (cur, value, key) ->
    cur[key] = attributify value
    return cur

module.exports.isEmpty = _.isEmpty

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
