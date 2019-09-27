import Foundation

extension String {
    
    /// A helper variable providing a range from startIndex to endIndex
    private var __advanceStringFormat_completeRange: Range<String.Index> {
        return Range<String.Index>(uncheckedBounds: (lower: self.startIndex, upper: self.endIndex))
    }
    /// A helper variable that converts the completeRange to an NSRange
    private var __advanceStringFormat_completeNSRange: NSRange {
        return NSMakeRange(0, self.distance(from: self.startIndex, to: self.endIndex))
    }
    
    
    /// A formatting init that allows for index specific formatting for parameters.
    ///
    /// This is usefull when a developer provides the arguments and user or another developer provides the format.
    /// String format usage: %{key: format}.
    /// When an argument is found using index, will be formatted using standard String(format: %{format}, argument).
    /// When using structs you can access individual properties like so %{key: @.property},  You can also format the child property %{key: @.property%0.2f}
    ///
    /// - Parameters:
    ///   - format: The string format to use
    ///   - nilReplacement: The string representation of nil (default is nil)
    ///   - arguments: The arguments to format with the string format
    /// - Returns: Returns a new string built from the format and arguments
    public init(withKeyedFormat format: String, nilReplacement: String = "nil", _ arguments: [String: Any?]) {
        var str: String = format
        
        
        let regx: NSRegularExpression = try! NSRegularExpression(pattern: "%\\{(\\w+)(\\:\\s?([^\\{\\}]+))?\\}")
        
        
        let patternMatches: [NSTextCheckingResult] =  regx.matches(in: format, options: [], range: format.__advanceStringFormat_completeNSRange)
        var matchedPatterns: [String] = []
        for patternMatch in patternMatches {
            
            
            let fullPattern: String =  String(format[Range<String.Index>(patternMatch.range(at: 0), in: format)!]) //Get full pattern match
            if !matchedPatterns.contains(fullPattern) { //Don't waste time re-processing identical patterns, all patterns are replaced on frist match
                matchedPatterns.append(fullPattern)
                let objectIndex: String = String(format[Range<String.Index>(patternMatch.range(at: 1), in: format)!])
                let objectFormat: String = {
                    guard let r = Range<String.Index>(patternMatch.range(at: 3), in: format) else { return "@" }
                    return String(format[r])
                }()
                
                //objectFormat = String(objectFormat[objectFormat.index(after: objectFormat.startIndex)...])
                
                guard arguments.keys.contains(objectIndex) else {
                    //If we don't find the object for the key, lets skip and go on to the next
                    continue
                }
                let formattedObject = String.formatIndividualObject(arguments[objectIndex]!, withFormat: objectFormat, nilReplacement: nilReplacement)
                str = str.replacingOccurrences(of: fullPattern, with: formattedObject)
                
                
            }
            
        }
        
        self = str
        
        
    }
    
    /// A formatting init that allows for index specific formatting for parameters.
    ///
    /// This is usefull when a developer provides the arguments and user or another developer provides the format.
    /// String format usage: %{index: format}.
    /// When an argument is found using index, will be formatted using standard String(format: %{format}, argument).
    /// When using structs you can access individual properties like so %{index: @.property},  You can also format the child property %{index: @.property%0.2f}
    ///
    /// - Parameters:
    ///   - format: The string format to use
    ///   - nilReplacement: The string representation of nil (default is nil)
    ///   - arguments: The arguments to format with the string format
    /// - Returns: Returns a new string built from the format and arguments
    public init(withIndexedFormat format: String, nilReplacement: String = "nil", _ arguments: [Any?]) {
        var str: String = format
        
        
        let regx: NSRegularExpression = try! NSRegularExpression(pattern: "%\\{(\\d+)(\\:\\s?([^\\{\\}]+))?\\}")
        
        
        let patternMatches: [NSTextCheckingResult] =  regx.matches(in: format, options: [], range: format.__advanceStringFormat_completeNSRange)
        var matchedPatterns: [String] = []
        for patternMatch in patternMatches {
            
            
            let fullPattern: String =  String(format[Range<String.Index>(patternMatch.range(at: 0), in: format)!]) //Get full pattern match
            if !matchedPatterns.contains(fullPattern) { //Don't waste time re-processing identical patterns, all patterns are replaced on frist match
                matchedPatterns.append(fullPattern)
                let objectIndex: Int = Int(String(format[Range<String.Index>(patternMatch.range(at: 1), in: format)!]))!
                let objectFormat: String = {
                    guard let r = Range<String.Index>(patternMatch.range(at: 3), in: format) else { return "@" }
                    return String(format[r])
                }()
                
                guard objectIndex >= 0 && objectIndex < arguments.count else {
                    //If we don't find the object for the index, lets skip and go on to the next
                    continue
                }
                
                //objectFormat = String(objectFormat[objectFormat.index(after: objectFormat.startIndex)...])
                let formattedObject = String.formatIndividualObject(arguments[objectIndex], withFormat: objectFormat, nilReplacement: nilReplacement)
                str = str.replacingOccurrences(of: fullPattern, with: formattedObject)
                
                
            }
            
        }
        
        self = str
        
        
    }
    
    /// A formatting init that allows for index specific formatting for parameters.
    ///
    /// This is usefull when a developer provides the arguments and user or another developer provides the format.
    /// String format usage: %{index: format}.
    /// When an argument is found using index, will be formatted using standard String(format: %{format}, argument).
    /// When using structs you can access individual properties like so %{index: @.property},  You can also format the child property %{index: @.property%0.2f}
    ///
    /// - Parameters:
    ///   - format: The string format to use
    ///   - nilReplacement: The string representation of nil (default is nil)
    ///   - arguments: The arguments to format with the string format
    /// - Returns: Returns a new string built from the format and arguments
    public init(withIndexedFormat format: String, nilReplacement: String = "nil", _ arguments: Any?...) {
        self.init(withIndexedFormat: format, nilReplacement: nilReplacement, arguments)
    }
    
    
    /// Actual method used to format a specific object
    ///
    /// - Parameters:
    ///   - object: The object to format as a string
    ///   - format: format pararameters
    ///   - nilReplacement: The String representation for nil
    /// - Returns: The formatted string representation of the object
    private static func formatIndividualObject(_ object: Any?, withFormat format: String, nilReplacement: String) -> String {
        var objectFormat = format
        let formatTypes: [String] = ["d","D","u","U","x","X","o","O","f","F","e","E","g","G","c","C","s","S","p","a","A"]
        
        let formatObjectType: String = {
            
            if objectFormat.hasPrefix("@.") {
                objectFormat = String(objectFormat.suffix(objectFormat.count - 2))
                return "@"
            }
            if objectFormat == "@" {
                objectFormat = ""
                return "@"
                
            }
            
            for t in formatTypes {
                if objectFormat.hasSuffix(t) {
                    objectFormat = String(objectFormat.prefix(objectFormat.count - 1))
                    return t
                }
            }
            
            fatalError("Invalid Object Format Type for '\(objectFormat)'")
        }()
        
        //objectFormat = String(objectFormat[..<objectFormat.index(objectFormat.endIndex, offsetBy: -1 * formatObjectType.count)])
        //objectFormat = String(objectFormat[..<objectFormat.index(before: objectFormat.endIndex)])
        
        var objectFormatted: String = ""
        if let obj = object {
            if formatTypes.contains(formatObjectType) {
                objectFormatted = String(format: "%" + objectFormat + formatObjectType, obj as! CVarArg)
            } else if formatObjectType == "@" {
                if !objectFormat.isEmpty {
                    let funcRange = objectFormat.range(of: "()")
                    let subFmtRange = objectFormat.range(of: "%")
                    
                    let isFunc: Bool = {
                        if let fR = funcRange, let sFr = subFmtRange {
                            if fR.lowerBound < sFr.lowerBound { return true }
                            else { return false }
                        } else if funcRange != nil {
                            return true
                        } else {
                            return false
                        }
                    }()
                    
                    var childField: String = ""
                    var childFormat: String? = nil
                    var childObject: Any? = nil
                    if isFunc {
                        childField = {
                            guard let idx = objectFormat.range(of: "()") else { return objectFormat }
                            return String(objectFormat.prefix(upTo: idx.lowerBound))
                            
                        }()
                        
                        #if !_runtime(_ObjC)
                            assertionFailure("Can't access '\(childField)'. Method access is only supported through Objective-C runtime.")
                        #else
                        
                        childFormat = {
                            guard let idx = objectFormat.range(of: "()") else { return nil }
                            return String(objectFormat.suffix(from: idx.upperBound))
                            
                        }()
                        
                        guard let nsObj = obj as? NSObject else {
                            assertionFailure("Object of type \(type(of: obj)) must inherit 'NSObject'")
                            return ""
                        }
                        
                        
                        if let nsChildObj = nsObj.perform(Selector(childField)) {
                            
                            //print(nsChildObj)
                            childObject = nsChildObj.takeUnretainedValue()
                            //print(childObject)
                        } else {
                            childObject = nil
                        }
                        #endif
                        
                        
                    } else {
                        childField = {
                            guard let idx = objectFormat.range(of: "%") else { return objectFormat }
                            return String(objectFormat.prefix(upTo: idx.lowerBound))
                            
                        }()
                        childFormat = {
                            guard let idx = objectFormat.range(of: "%") else { return nil }
                            return String(objectFormat.suffix(from: idx.upperBound))
                            
                        }()
                        
                        if let dict: [String: Any] = obj as? [String: Any] {
                            childObject = dict[childField]
                        } else {
                        
                            let mirror = Mirror(reflecting: obj)
                            childObject = {
                                for child in mirror.children {
                                    if child.label == childField {
                                        
                                        func rootValue(_  o: Any) -> Any? {
                                            let m = Mirror(reflecting: o)
                                            guard m.displayStyle == .optional else { return o }
                                            guard let (_, some) = m.children.first else { return nil }
                                            return rootValue(some)
                                            
                                        }
                                        
                                        return rootValue(child.value)
                                        
                                        
                                    }
                                }
                                assertionFailure("Object of type \(type(of: obj)) missing property '\(childField)'")
                                return nil
                            }()
                        }
                        
                    }
                    
                    if let o = childObject {
                        if let cf = childFormat, !cf.isEmpty {
                            objectFormatted = formatIndividualObject(o, withFormat: cf, nilReplacement: nilReplacement)
                        } else {
                            objectFormatted = "\(o)"
                        }
                    } else {
                        objectFormatted = nilReplacement
                    }
                    
                    
                    
                    
                } else {
                    objectFormatted = "\(obj)"
                }
            }
            
        } else {
            objectFormatted = nilReplacement
        }
        return objectFormatted
    }
}
