createObject    = require 'inherits-ex/lib/createObject'
inheritsObject  = require 'inherits-ex/lib/inheritsObject'
defineProperty  = require 'util-ex/lib/defineProperty'
isString        = require 'util-ex/lib/is/type/string'
isObject        = require 'util-ex/lib/is/type/object'
isEmptyObject   = require 'util-ex/lib/is/empty-object'
Attributes      = require 'abstract-type/lib/attributes'
AttributeType   = require './attribute-type'
Type            = require 'abstract-type'
ObjectValue     = require './value'
register        = Type.register
aliases         = Type.aliases

getOwnPropertyNames = Object.getOwnPropertyNames
getObjectKeys = Object.keys

module.exports = class ObjectType
  register ObjectType
  aliases ObjectType, 'object'

  constructor: ->
    return super

  ValueType: ObjectValue
  $attributes: Attributes
    attributes:
      type: 'Object'
      assigned: '$_attributes' # this should define the non-enumerable `$_attributes` property.
      assign: (value, dest, src, key)->
        if dest and dest.defineAttributes
          result = dest.defineAttributes(value)
        else
          result = value
        result
    $_attributes:
      value:{}
    strict:
      type: 'Boolean'

  @defaultType: Type('String')
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
    aAttributes = @attributes unless aAttributes?
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
      else if ObjectType.defaultType
        aOptions.type = ObjectType.defaultType
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
  defineAttributes: (aAttributes)->
    if not isEmptyObject(aAttributes) #avoid to recusive
      result = {}
      for k,v of aAttributes
        continue if not k? or not v?
        @defineAttribute k, v, result
    return result

  _toObject:(aOptions, aNameRequired)->
    result = super
    result.attributes = vAttrs = {}
    if aOptions
      delete aOptions.value
      delete aOptions.attributes
    for k,v of @attributes
      vAttrs[k] = t = v.toObject(aOptions, false)
      #delete t[NAME]
      vAttrs[k] = t.type if getObjectKeys(t).length is 1
      #console.log t
    result

  toValue: (aValue)->
    if isString aValue
      try result = JSON.parse aValue
    else
      result = aValue
    result

  _validate: (aValue, aOptions)->
    if isString aValue
      aValue = @toValue aValue

    result = isObject aValue
    if result
      if aOptions and aOptions.attributes
        for vName, vType of aOptions.attributes
          if not vType.validate aValue[vName], false
            l = vType.errors.length
            if l
              for i in [0...l]
                e = vType.errors[i]
                vName = vType.name
                unless e.name[0] is '[' or vName is e.name
                  vName += '.' + e.name
                @errors.push name: vName, message: e.message
              vType.errors = []
            else
              @errors.push name: vType.name, message: "is invalid"
            result = false
            break if aOptions.raiseError
        if @strict
          for vName in getObjectKeys aValue
            continue if vName[0] is '$'
            unless aOptions.attributes.hasOwnProperty vName
              result = false
              @errors.push
                name: vName
                message: 'is unknown'
              break if aOptions.raiseError
    result
  # can wrap a common object to an ObjectValue.
  wrapValue:(aObjectValue)->
    if isObject aObjectValue
      if not (aObjectValue instanceof ObjectValue)
        inheritsObject aObjectValue, ObjectValue
      if aObjectValue.hasOwnProperty '$type'
        @$type = @
      else
        defineProperty aObjectValue, '$type', @
    aObjectValue
  #TODO: maybe should use Attributes class and put this method into it.
  attrKeys: ->
    result = []
    for k,v of @attributes
      result.push v.name || k if v.enumerable isnt false
    result
  attrOwnPropertyNames: ->
    result = []
    for k,v of @attributes
      result.push v.name
    result
  # Returns
  #   all own, enumerable properties of an object
  # Parameters
  #   * aObject: The object whose enumerable own properties are to be returned.
  keys: (aObject)->
    result = getObjectKeys aObject
    if @strict
      vAttrKeys = @attrKeys()
      result = result.filter (element)->element in vAttrKeys
    result
  # Returns
  #   all own properties of an object, enumerable or not.
  # Parameters
  #   * aObject: The object whose enumerable and non-enumerable own properties
  #     are to be returned.
  getOwnPropertyNames: (aObject)->
    result = getOwnPropertyNames aObject
    if @strict
      vAttrKeys = @attrOwnPropertyNames()
      result = result.filter (element)->element in vAttrKeys
    result
