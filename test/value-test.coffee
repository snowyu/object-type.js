chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

extend          = require 'util-ex/lib/_extend'
Type            = require 'abstract-type'
ObjectValue     = require '../src/value'
require 'number-type'
require 'string-type'
require '../src'
setImmediate    = setImmediate || process.nextTick
register        = Type.register

describe 'ObjectType Value', ->
  object     = Type 'Object'

  describe '.createValue/.create', ->
    it 'should create a value obj', ->
      attrs =
        a:'number'
        d:
          type: 'object'
          attributes:
            d1:'number'
      objectType = object.cloneType attributes: attrs
      v = objectType.create({a:1}) #create object value
      expect(v).to.have.property('a', 1)
      expect(v).to.be.instanceOf ObjectValue
      result = v.toObject()
      #result = extend {}, result #TODO why deep equal is not same?
      #result = JSON.parse JSON.stringify result
      expected = { a: 1 }
      expect(result).to.be.deep.equal expected
      result = v.toObject(withType:true)
      expected =
        value: a: 1
        name: 'Object'
        attributes:
          a: 'Number'
          d:
            type: 'Object'
            attributes:
              d1: 'Number'
      expect(result).to.be.deep.equal expected
    it 'should raise error with missing required value with strict', ->
      objectType = object.cloneType
        strict: true
        attributes:
          s: 'string'
          n:
            type:'number'
            required: true
      expect(objectType.create.bind(objectType, {s:'123'})).to.be.throw ' is an invalid Object'
      expect(objectType.errors).to.be.deep.equal [
        name: 'n', message: 'is required'
      ]
      expect(objectType.isValid(s:123)).to.be.false
      expect(objectType.errors).to.be.deep.equal [
        {name: 's', message: 'is invalid'}
        {name: 'n', message: 'is required'}
      ]
