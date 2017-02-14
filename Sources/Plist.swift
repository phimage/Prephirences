//
//  Plist.swift
//  Prephirences
/*
The MIT License (MIT)

Copyright (c) 2017 Eric Marchand (phimage)

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
open class Plist: MutableDictionaryPreferences {

    static let Extension = "plist"

    var filePath: String

    /* Write to file after each modification */
    open var writeImmediatly: Bool = false

    // MARK: init
    public init?(filename: String?, bundle: Bundle = Bundle.main) {
       self.filePath = bundle.path(forResource: filename, ofType: Plist.Extension) ?? ""
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
    open func write(_ atomically: Bool = true) -> Bool {
        return self.writeToFile(self.filePath, atomically: atomically)
    }

    open func read() -> Bool {
        if let d = NSDictionary(contentsOfFile: self.filePath) as? [String: AnyObject] {
            self.dico = d
            return true
        }
        return false
    }

    fileprivate func notifyChange() {
        if writeImmediatly {
            let _ = write()
        }
    }

    // MARK: override
    open override subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
            return dico[key]
        }
        set {
            dico[key] = newValue
            notifyChange()
        }
    }

    open override func clearAll() {
        super.clearAll()
        notifyChange()
    }
    open override func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
        super.set(value, forKey: key)
        notifyChange()
    }
    open override func removeObject(forKey key: PreferenceKey) {
        super.removeObject(forKey: key)
        notifyChange()
    }
    open override func set(_ value: Int, forKey key: PreferenceKey) {
        super.set(value, forKey: key)
        notifyChange()
    }
    open override func set(_ value: Float, forKey key: PreferenceKey) {
        super.set(value, forKey: key)
        notifyChange()
    }
    open override func set(_ value: Double, forKey key: PreferenceKey) {
         super.set(value, forKey: key)
        notifyChange()
    }
    open override func set(_ value: Bool, forKey key: PreferenceKey) {
        super.set(value, forKey: key)
        notifyChange()
    }
    open override func set(_ url: URL?, forKey key: PreferenceKey) {
        super.set(url, forKey: key)
        notifyChange()
    }

    open override func set(dictionary: PreferencesDictionary) {
        super.set(dictionary: dictionary)
        notifyChange()
    }

}
