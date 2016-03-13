inheritsObject  = require 'inherits-ex/lib/inheritsObject'
setPrototypeOf  = require 'inherits-ex/lib/setPrototypeOf'
defineProperty  = require 'util-ex/lib/defineProperty'
isString        = require 'util-ex/lib/is/type/string'
isObject        = require 'util-ex/lib/is/type/object'
extend          = require 'util-ex/lib/_extend'
Attributes      = require 'abstract-type/lib/attributes'
Type            = require 'abstract-type'
AttributeType   = require './attribute-type'
ObjectAttributes= require './object-attributes'
ObjectValue     = require './value'
defaultType     = require './default-type'
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
        if (dest instanceof ObjectType) and dest.attributes?
          dest.attributes.assign(value)
        else
          value
    $_attributes:
      value: new ObjectAttributes
    strict:
      type: 'Boolean'

  #@defaultType: defaultType.type
  oldRegister = @register
  @register: (aClass)->
    # TODO: howto hook to the ObjectAttributes?
    oldRegister.apply ObjectType, arguments

  defineAttribute: (aName, aOptions, aAttributes)->
    @attributes.defineAttribute(aName, aOptions, aAttributes)

  defineAttributes: (aAttributes, result)->
    @attributes.defineAttributes(aAttributes, result)

  _toObject:(aOptions, aNameRequired)->
    result = super
    result.attributes = vAttrs = {}
    #   delete aOptions.name
    for k,v of @attributes.value()
      vAttrs[k] = t = v.toObject(null, false)
      #delete t[NAME]
      vAttrs[k] = t.type if getObjectKeys(t).length is 1
      # console.log k, t
    delete result.attributes unless getObjectKeys(vAttrs).length
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
        for vName, vType of aOptions.attributes.value()
          if vType.writable and !vType.set and aValue[vName] isnt undefined
            aValue[vName] = vType.toValue aValue[vName]
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
  # can wrap a common json object to an ObjectValue.
  # Note: it will replace the prototype to the ObjectValue Class directly.
  wrapValue:(aObjectValue)->
    if isObject aObjectValue
      if not (aObjectValue instanceof ObjectValue)
        setPrototypeOf aObjectValue, ObjectValue::
      if aObjectValue.hasOwnProperty '$type'
        @$type = @
      else
        defineProperty aObjectValue, '$type', @
    aObjectValue
  #TODO: maybe should use Attributes class and put this method into it.
  attrKeys: ->
    result = []
    for k,v of @attributes.value()
      result.push v.name || k if v.enumerable isnt false
    result
  attrOwnPropertyNames: ->
    result = []
    for k,v of @attributes.value()
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
