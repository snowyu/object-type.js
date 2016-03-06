isString        = require 'util-ex/lib/is/type/string'
Attributes      = require 'abstract-type/lib/attributes'
Type            = require 'abstract-type'

getOwnPropertyNames = Object.getOwnPropertyNames
getObjectKeys       = Object.keys

register  = Type.register
aliases   = Type.aliases


module.exports = class AttributeType
  register AttributeType
  aliases AttributeType, 'attribute'

  $attributes: Attributes
    type:
      name: 'type'
      required: true
      type: 'Type'
    configurable:
      type: 'Boolean'
    enumerable:
      type: 'Boolean'
    writable:
      type: 'Boolean'
      value: true
    value: #default value
      type: undefined #Any
    get:
      type: 'Function'
    set:
      type: 'Function'

  @defaultType: Type('String')
  # _assign: (aOptions)->
  #   if isString aOptions
  #     vType = aOptions
  #     aOptions = {}
  #     vType = Type(vType, aOptions)
  #     throw TypeError("no such type registered:"+aOptions) unless vType
  #     @type = vType
  #   else if aOptions instanceof AttributeType
  #     for k,v of aOptions
  #       @[k] = v if @hasOwnProperty k
  #   else if aOptions instanceof Type
  #     @type = aOptions
  #   else if aOptions?
  #     for k,v of aOptions
  #       @[k] = v if @hasOwnProperty k
  #     vType = aOptions.type
  #     if vType
  #       if not (vType instanceof Type)
  #         vType = Type(vType)
  #         unless vType
  #           throw TypeError("no such type registered:"+aOptions.type)
  #         vType = vType.clone(aOptions) unless vType.isSame(aOptions)
  #         @type = vType
  #     else
  #       @type = AttributeType.defaultType
  #
  #   return
  ###
  getFullName: ->
    vName = [@name]
    vParent = @parent
    while vParent && vParent.name isnt 'Object'
      vName.push vParent.name
      vParent = vParent.parent
    vName.reverse()
    vName.join('.')
  ###
  #getName: -> @name
  toString: -> '[Attribute ' + @name + ']'
  _toObject: (aOptions)->
    result = super
    #delete aOptions.name if aOptions?
    vType = @type.toObject(aOptions)
    result.type = vType.name
    delete vType.name
    # if it's a customize type(special options type):
    #if not @type.hasOwnProperty 'name'
    for k,v of vType
      result[k] = v
    result
  toValue: (aValue)->
    if @type.toValue
      result = @type.toValue(aValue)
    else
      result = aValue
      #try result = JSON.parse aValue
    result
  _validate: (aValue, aOptions)->
    if aOptions # the attribute do not validate the aValue, the vType do it.
      vType   = aOptions.type
      if vType
        result  = vType.validate aValue, false
        if not result
          if vType.errors.length
            @errors = vType.errors
            vType.errors = []
          else
            @errors.push name: String(vType), message: "is invalid"
    result
