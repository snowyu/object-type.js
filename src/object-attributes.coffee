createObject    = require 'inherits-ex/lib/createObject'
isString        = require 'util-ex/lib/is/type/string'
isFunction      = require 'util-ex/lib/is/type/function'
isEmptyObject   = require 'util-ex/lib/is/empty-object'
Type            = require 'abstract-type'
AttributeType   = require './attribute-type'
defaultType     = require './default-type'

getOwnPropertyNames = Object.getOwnPropertyNames

register  = Type.register
aliases   = Type.aliases


# collect the attributes of an object.
module.exports = class ObjectAttributes

  constructor: (aAttributes)->
    return new ObjectAttributes(aAttributes) unless @ instanceof ObjectAttributes
    @defineAttributes aAttributes if aAttributes

  ###
    aOptions *(string)*: the type name.
    aOptions *(AttributeType)*
    aOptions *(Type)*: the type of this attribute.
    aOptions *(object)*:
      required: Boolean
      type: ...
  ###
  defineAttribute: (aName, aOptions, aAttributes)->
    unless aName and aName.length
      throw TypeError('defineAttribute has no attribute name')
    aAttributes = @ unless aAttributes?
    if aAttributes[aName]?
      throw TypeError('the attribute "' + aName + '" has already defined.')
    if isString aOptions
      vType = Type(aOptions)
      throw TypeError("no such type registered:"+aOptions) unless vType
      aOptions = {}
      aOptions.type = vType
    else if aOptions instanceof AttributeType
      vAttribute = aOptions
    else if aOptions instanceof Type
      aOptions = {type: aOptions}
    else if aOptions?
      if aOptions.type
        vType = aOptions.type
        vType = Type(vType) #if isString vType
        throw TypeError('no such type registered:'+aOptions.type) unless vType
        vType = vType.clone(aOptions) unless vType.isSame(aOptions)
        aOptions.type = vType
      else if defaultType.type
        aOptions.type = defaultType.type
    unless vAttribute
      aOptions = aOptions || {}
      aOptions.name = aName
      vAttribute = createObject AttributeType, aName, aOptions
    aAttributes[aName] = vAttribute

  ###
    attributes =
      attrName:
        required: true
        type: 'string'
  ###
  defineAttributes: (aAttributes, result)->
    if not isEmptyObject(aAttributes) #avoid to recusive
      result = @ unless result?
      for k,v of aAttributes
        continue unless k? and v? and aAttributes.hasOwnProperty k
        @defineAttribute k, v, result
    return result
  assign: (aAttributes)->
    @clear()
    @defineAttributes aAttributes
  clear: ->
    for key in getOwnPropertyNames @
      delete @[key]
    return @
  getKeys: ->
    result = []
    for k, v of @
      result.push k unless isFunction v
    result
  value: ->
    result = {}
    for k, v of @
      result[k] = v unless isFunction v
    result
