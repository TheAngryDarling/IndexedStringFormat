import XCTest
@testable import IndexedStringFormat
import Foundation

final class IndexedStringFormatTests: XCTestCase {
    
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
    
    class TestNSClass: NSObject {
        let string: String = "TestNSClass"
        override var description: String { return string }
        
    }
    
    func testIndexedFormat() {
        #if !os(macOS) && !os(iOS) && !os(tvOS) && !os(watchOS)
        let format: String = "%{0: d}, %{1:@}, %{2:@}, \"%{3:@}\" - %{2:@}, %{1:@}, %{0:@}, \"%{4:@.string}\", \"%{3:@.string}\", %{3:@.float%0.2f}"
        #else
        let format: String = "%{0: d}, %{1:@}, %{2:@}, \"%{3:@}\" - %{2:@}, %{1:@}, %{0:@}, \"%{4:@.string}\", \"%{3:@.string}\", %{3:@.float%0.2f}, %{5:@.description()}"
        #endif
        
        let objects: [Any?] = [1, true, nil, TestStruct(string: "String Var", int: 13, bool: false, float: 1.3456), TestSwiftClass(), TestNSClass()]
        for _ in 1..<100 {
            //autoreleasepool {
            let string = String(withIndexedFormat: format, objects)
            print(string)
            //}
        }
    }
    
    func testKeyedFormat() {
        #if !os(macOS) && !os(iOS) && !os(tvOS) && !os(watchOS)
        let format: String = "%{int:d}, %{bool:@}, %{nil:@}, \"%{struct:@}\" - %{nil:@}, %{bool:@}, %{int:@}, \"%{class:@.string}\", \"%{struct:@.string}\", %{struct:@.float%0.2f}"
        #else
        let format: String = "%{int:d}, %{bool:@}, %{nil:@}, \"%{struct:@}\" - %{nil:@}, %{bool:@}, %{int:@}, \"%{class:@.string}\", \"%{struct:@.string}\", %{struct:@.float%0.2f}, %{nsclass:@.description()}"
        #endif
        
        let objects: [String: Any?] = ["int": 1,
                                       "bool": true,
                                        "nil": nil,
                                        "struct": TestStruct(string: "String Var", int: 13, bool: false, float: 1.3456),
                                        "class": TestSwiftClass(),
                                        "nsclass": TestNSClass()]
        for _ in 1..<100 {
            //autoreleasepool {
            let string = String(withKeyedFormat: format, objects)
            print(string)
            //}
        }
    }
    

    static var allTests = [
        ("testIndexedFormat", testIndexedFormat),
        ("testKeyedFormat", testKeyedFormat)
    ]
}
