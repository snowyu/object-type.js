inherits        = require 'inherits-ex/lib/inherits'
extend          = require 'util-ex/lib/extend'
isString        = require 'util-ex/lib/is/type/string'
defineProperty  = require 'util-ex/lib/defineProperty'
Value           = require 'abstract-type/value'

getOwnPropertyNames = Object.getOwnPropertyNames
getObjectKeys = Object.keys

module.exports = class ObjectValue
  inherits ObjectValue, Value

  constructor: ->return super
  _initialize: (aValue, aType, aOptions)->
    for k, attr of @$type.attributes
      continue if k[0] is '$'
      vName = attr.name || k
      attr = extend {enumerable: true}, attr, (k,v)-> v isnt undefined
      defineProperty @, vName, undefined, attr
  _assign:(aValue)->
    #if isString aValue
    #  aValue = JSON.parse aValue
    if @$type.strict
      if aValue?
        for k, t of @$type.attributes
          continue if k[0] is '$'
          v = aValue[k]
          @[k] = v if v isnt undefined and t.isValid v
    else
      extend @, aValue, (k)-> k[0] isnt '$'
    return
  toString: -> @$type.toString()
  valueOf: -> @
  _toObject: (aOptions)->
    aValue = @
    result = {}
    vMeta = @$type.attributes
    vStrict = @$type.strict
    for vName in getObjectKeys aValue
      continue if vName[0] is '$'
      if !vStrict or (vMeta and (vType = vMeta[vName]))
        result[vName] = @[vName]
    result
