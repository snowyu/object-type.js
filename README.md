## object-type [![npm][npm-svg]][npm]

[![Build Status][travis-svg]][travis]
[![Code Climate][codeclimate-svg]][codeclimate]
[![Test Coverage][codeclimate-test-svg]][codeclimate-test]
[![downloads][npm-download-svg]][npm]
[![license][npm-license-svg]][npm]

[npm]: https://npmjs.org/package/object-type
[npm-svg]: https://img.shields.io/npm/v/object-type.svg
[npm-download-svg]: https://img.shields.io/npm/dm/object-type.svg
[npm-license-svg]: https://img.shields.io/npm/l/object-type.svg
[travis-svg]: https://img.shields.io/travis/snowyu/object-type.js/master.svg
[travis]: http://travis-ci.org/snowyu/object-type.js
[codeclimate-svg]: https://codeclimate.com/github/snowyu/object-type.js/badges/gpa.svg
[codeclimate]: https://codeclimate.com/github/snowyu/object-type.js
[codeclimate-test-svg]: https://codeclimate.com/github/snowyu/object-type.js/badges/coverage.svg
[codeclimate-test]: https://codeclimate.com/github/snowyu/object-type.js/coverage

The Object type can hold the attributes of the object.

* Object Type Attributes:
  * `attributes` *(object)*: this object's attribute list.
  * `strict` *(boolean)*: whether treat this object as strict mode. defaults to false.
    * the object can only have attributes in the attributes list if strict mode is enabled.


## Usage

```js
//register the string and number types:
require('string-type')
require('number-type')

var ObjectType  = require('object-type')
var Obj = ObjectType({
  strict: true, //the strict mode, defaults to false.
  attributes: //define the object attributes
    s: 'string',
    n: {
      type:'number',
      required: true
    }
})
//=<type "Object": "attributes":{"s":"String","n":{"required":true,"type":"Number"}},"strict":true>
var value = Obj.create({s:'123', n:33})
//=<type "Object": "attributes":{"s":"String","n":{"required":true,"type":"Number"}},"strict":true,"value":{"s":"123","n":33}>
value = Obj.create({s:'123'})
//=TypeError: "[object Object]" is an invalid Object
console.log(Obj.errors)
//=[ { name: 'n', message: 'is required' } ]
Obj.isValid(s:123)
//=false
console.log(Obj.errors)
//[ { name: 's', message: 'is invalid' },
//  { name: 'n', message: 'is required' } ]
```

## API

See [abstract-type](https://github.com/snowyu/abstract-type.js).

## TODO


## License

MIT
