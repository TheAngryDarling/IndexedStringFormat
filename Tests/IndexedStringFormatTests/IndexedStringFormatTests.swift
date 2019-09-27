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
        
        var expectedString = "1, true, nil, \"String Var - 13 - false - 1.3456\" - nil, true, 1, \"TestSwiftClass\", \"String Var\", 1.35"
        #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
        expectedString += ", TestNSClass"
        #endif
        //for _ in 1..<100 {
            //autoreleasepool {
            let string = String(withIndexedFormat: format, objects)
            XCTAssertEqual(string, expectedString)
            //}
        //}
    }
    
    func testKeyedFormat() {
        #if !_runtime(_ObjC)
        let format: String = "%{int:d}, %{bool:@}, %{nil:@}, \"%{struct:@}\" - %{nil:@}, %{bool:@}, %{int:@}, \"%{class:@.string}\", \"%{struct:@.string}\", %{struct:@.float%0.2f}"
        #else
        let format: String = "\"%{struct}\" --- %{int:d}, %{bool:@}, %{nil:@}, \"%{struct:@}\" - %{nil:@}, %{bool:@}, %{int:@}, \"%{class:@.string}\", \"%{struct:@.string}\", %{struct:@.float%0.2f}, %{nsclass:@.description()}"
        #endif
        
        
        let objects: [String: Any?] = ["int": 1,
                                       "bool": true,
                                        "nil": nil,
                                        "struct": TestStruct(string: "String Var", int: 13, bool: false, float: 1.3456),
                                        "class": TestSwiftClass(),
                                        "nsclass": TestNSClass()]
        
        var expectedString = "1, true, nil, \"String Var - 13 - false - 1.3456\" - nil, true, 1, \"TestSwiftClass\", \"String Var\", 1.35"
        #if _runtime(_ObjC)
        expectedString = "\"\(objects["struct"] as! TestStruct)\" --- " + expectedString + ", \(objects["nsclass"] as! TestNSClass)"
        #endif
        //for _ in 1..<100 {
            //autoreleasepool {
            let string = String(withKeyedFormat: format, objects)
            XCTAssertEqual(string, expectedString)
            //}
        //}
    }
    
    struct OptionalValues {
        let symbol: String? = "✳️"
    }
    
    func testOptionalValues() {
        let format: String = "%{log_value:@.symbol} - %{thread}"
        let thread: String? = nil
        let objects: [String: Any?] = ["log_value": OptionalValues(),
                                       "thread": thread]
        let expectedString = "\(OptionalValues().symbol!) - nil"
        let string = String(withKeyedFormat: format, objects)
        XCTAssertEqual(string, expectedString)
                                       
    }
    
    func testDictValues() {
        let format: String = "%{obj:@.value}"
        let dict: [String: Any] = ["value": 1234]
        let objects: [String: Any] = ["obj": dict]
        let expectedString = "1234"
        let string = String(withKeyedFormat: format, objects)
        XCTAssertEqual(string, expectedString)
    }
    
    

    static var allTests = [
        ("testIndexedFormat", testIndexedFormat),
        ("testKeyedFormat", testKeyedFormat),
        ("testOptionalValues", testOptionalValues),
        ("testDictValues", testDictValues)
    ]
}
