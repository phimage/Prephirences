//
//  Plist.swift
//  Prephirences
/*
The MIT License (MIT)

Copyright (c) 2015 Eric Marchand (phimage)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

/* Plist represent an editable 'plist' file as preference */
public class Plist: MutableDictionaryPreferences {
    
    static let Extension = "plist"
    
    var filePath: String
    
    /* Write to file after each modification */
    public var writeImmediatly: Bool = false
    
    
    // MARK: init
    public init?(filename: String?, bundle: NSBundle = NSBundle.mainBundle()) {
       self.filePath = bundle.pathForResource(filename, ofType: Plist.Extension) ?? ""
       super.init(filename: filename, ofType: Plist.Extension, bundle: bundle)
    }
    
    public override init?(filePath: String) {
        self.filePath = filePath
        super.init(filePath: filePath)
    }

    public required convenience init(dictionaryLiteral elements: Element...) {
        fatalError("init(dictionaryLiteral:) has not been implemented")
    }

    // MARK: functions
    public func write(atomically: Bool = true) -> Bool {
        return self.writeToFile(self.filePath, atomically: atomically)
    }
    
    public func read() -> Bool {
        if let d = NSDictionary(contentsOfFile: self.filePath) as? Dictionary<String,AnyObject> {
            self.dico = d
            return true
        }
        return false
    }
    
    private func notifyChange() {
        if writeImmediatly {
            write()
        }
    }

    // MARK: override
    public override subscript(key: String) -> AnyObject? {
        get {
            return dico[key]
        }
        set {
            dico[key] = newValue
            notifyChange()
        }
    }
    
    public override func clearAll() {
        super.clearAll()
        notifyChange()
    }
    public override func setObject(value: AnyObject?, forKey key: String) {
        super.setObject(value, forKey: key)
        notifyChange()
    }
    public override func removeObjectForKey(key: String) {
        super.removeObjectForKey(key)
        notifyChange()
    }
    public override func setInteger(value: Int, forKey key: String){
        super.setInteger(value, forKey: key)
        notifyChange()
    }
    public override func setFloat(value: Float, forKey key: String){
        super.setFloat(value, forKey: key)
        notifyChange()
    }
    public override func setDouble(value: Double, forKey key: String) {
         super.setDouble(value, forKey: key)
        notifyChange()
    }
    public override func setBool(value: Bool, forKey key: String) {
        super.setBool(value, forKey: key)
        notifyChange()
    }
    public override func setURL(url: NSURL?, forKey key: String) {
        super.setURL(url, forKey: key)
        notifyChange()
    }
    
    public override func setObjectsForKeysWithDictionary(dictionary: [String:AnyObject]) {
        super.setObjectsForKeysWithDictionary(dictionary)
        notifyChange()
    }

    
}