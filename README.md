# IndexedStringFormat
![swift >= 4.0](https://img.shields.io/badge/swift-%3E%3D4.0-brightgreen.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)

Provides a String constructor where with a withIndexedFormat param and arguments param.
Works much like the regular String(format) constructor but supports index mapping of the parameters.  This way parametes can be used multiple times or skipped.

The idea behide this was to be able to create packages that requires using developers to generate a string based on a set of arguments when you may not want to expose the argument types themselves.

This format constructor can access properties within an object using the Mirror method, so developers can use access child properties on objects.  As well, on platforms that support Objective-C runtime, this constructor can access non-argumented methods the the same format as properties by adding () to the end.  This used Selectors to call the method.


As an addition, there is a key:value constructor that works similarly to the withIndexedFormat.  withKeyedFormat.  It works the same way but instead of using index values it uses the key names.

## Usage

```Swift

struct TestStruct: CustomStringConvertible {
    let string: String
    let int: Int
    let bool: Bool
    let float: Float

    var description: String { return "\(string) - \(int) - \(bool) - \(float)" }
}

class TestSwiftClass: CustomStringConvertible {
    let string: String = "TestSwiftClass"
    var description: String { return string }
}


//Indexed Way
let format: String = "%{0:d}, %{1:@}, %{2:@}, \"%{3:@}\" - %{2:@}, %{1:@}, %{0:@}, \"%{4:@.string}\", \"%{3:@.string}\", %{3:@.float%0.2f}"

let objects: [Any?] = [1, true, nil, TestStruct(string: "String Var", int: 13, bool: false, float: 1.3456), TestSwiftClass()]

let string = String(withIndexedFormat: format, objects)
print(string)


//Keyed Way
let keyedFormat: String = "%{int:d}, %{bool:@}, %{nil:@}, \"%{struct:@}\" - %{nil:@}, %{bool:@}, %{int:@}, \"%{class:@.string}\", \"%{struct:@.string}\", %{struct:@.float%0.2f}"

let keyedObjects: [String: Any?] = ["int": 1,
                                    "bool": true,
                                    "nil": nil,
                                    "struct": TestStruct(string: "String Var", int: 13, bool: false, float: 1.3456),
                                    "class": TestSwiftClass(),
                                    "nsclass": TestNSClass()]
                                    
let keyedString = String(withKeyedFormat: keyedFormat, keyedObjects)
print(keyedString)

```

## Author

* **Tyler Anger** - *Initial work* - [TheAngryDarling](https://github.com/TheAngryDarling)

## License

This project is licensed under Apache License v2.0 - see the [LICENSE.md](LICENSE.md) file for details

