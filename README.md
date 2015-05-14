# Prephirences - Preϕrence
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-iOS/MacOS-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Issues](https://img.shields.io/github/issues/phimage/Prephirences.svg?style=flat
           )](https://github.com/phimage/Prephirences/issues)


[<img align="left" src="/logo-128x128.png" hspace="20">](#logo)
Prephirences is a Swift library that provides useful protocols and convenience methods to manage application preferences, configurations and app-state.

```swift
let userDefaults = NSUserDefaults.standardUserDefaults()
if let enabled = userDefaults["enabled"] as? Bool {..}
```

Preferences could be user preferences `NSUserDefaults`, iCloud stored preferences `NSUbiquitousKeyValueStore`, file stored preferences or your own private application preferences - ie. any object which implement the protocol [PreferencesType](/Prephirences/PreferencesType.swift), which define key value store methods

You can merge multiples preferences and work with them transparently (see [Composing](#composing))

## Contents ##
- [Usage](#usage)
  - [Creating](#creating)
  - [Accessing](#accessing)
  - [Modifying](#modifying)
  - [Some implementations](#some-implementations)
    - [NSUserDefaults](#nsuserdefaults)
    - [NSUbiquitousKeyValueStore](#nsubiquitouskeyvaluestore)
    - [Key Value Coding](#kvc)
    - [Core Data](#core-data)
  - [Proxying preferences with prefix](#proxying-preferences-with-prefix)
  - [Composing](#composing)
- [Setup](#setup)
  - [Using xcode project](#using-xcode-project)
  - [Using cocoapods](#using-cocoapods)
- [Licence](#licence)
- [Logo](#logo)

# Usage #

## Creating ##
The simplest implementation of [PreferencesType](/Prephirences/PreferencesType.swift) is [DictionaryPreferences](/Prephirences/DictionaryPreferences.swift)
```swift
// From Dictionary
var fromDico = DictionaryPreferences(myDictionary)
// or literal
var fromDicoLiteral: DictionaryPreferences = ["myKey": "myValue", "bool": true]

// From filepath
if let fromFile = DictionaryPreferences(filePath: "/my/file/path") {..}
// ...in main bundle ##
if let fromFile = DictionaryPreferences(filename: "prefs", ofType: "plist") {..}
```

## Accessing ##
You can access with all methods defined in `PreferencesType` protocol

```swift
if let myValue = fromDicoLiteral.objectForKey("myKey") {..}
if let myValue = fromDicoLiteral["bool"] as? Bool {..}

var hasKey = fromDicoLiteral.hasObjectForKey("myKey")
var myValue = fromDicoLiteral.boolForKey("myKey")
..

```

## Modifying ##

Modifiable preferences implement protocol [MutablePreferencesTypes](/Prephirences/PreferencesType.swift)

The simplest implementation is [MutableDictionaryPreferences](/Prephirences/DictionaryPreferences.swift)

```swift
var mutableFromDico: MutableDictionaryPreferences = ["myKey": "myValue"]

mutableFromDico["newKey"] = "newValue"
mutableFromDico.setObject("myValue", forKey: "newKey")
mutableFromDico.setBool(true, forKey: "newKey")

```
You can append dictionary or other `PreferencesType`
```swift
mutableFromDico += ["newKey": "newValue", "otherKey": true]
```
You can remove one preference
```swift
mutableFromDico -= "myKey"
```

## Some implementations ##
### NSUserDefaults ###

`NSUserDefaults` implement `PreferencesType` and can be acceded with same methods

```swift
let userDefaults = NSUserDefaults.standardUserDefaults()

if let myValue = userDefaults["mykey"] as? Bool {..}
```

NSUserDefaults implement also `MutablePreferencesType` and can be modified with same methods
```swift
userDefaults["mykey"] = "myvalue"
```

### NSUbiquitousKeyValueStore ###
To store in iCloud, `NSUbiquitousKeyValueStore` implement also `PreferencesType`

### KVC ###
You can wrap an object respond to implicit protocol [NSKeyValueCoding](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) in `KVCPreferences` or `MutableKVCPreferences`
```swift
let kvcPref = MutableKVCPreferences(myObject)
```
Be sure to affect the correct object type

### Core Data ###
You can wrap on `NSManageObject` in `ManageObjectPreferences` or `MutableManageObjectPreferences`
```swift
let managedPref = ManageObjectPreferences(myManagedObject)
```

## Proxying preferences with prefix ##
You can defined a subcategory of preferences prefixed with your own string like that
```swift
let myAppPrefs = MutableProxyPreferences(preferences: userDefaults, key: "myAppKey.")
// We have :
userDefaults["myAppKey.myKey"] == myAppPrefs["myKey"] // is true
```
This allow prefixing all your preferences (user defaults) with same key


## Composing ##

Composing allow to aggregate multiples PreferencesType objects into one PreferencesType

```swift
let myPreferences = CompositePreferences([fromDico, fromFile, userDefaults])
// With array literal
let myPreferences: CompositePreferences = [fromDico, fromFile, userDefaults]

// Mutable, only first mutable will be affected
let myPreferences: MutableCompositePreferences = [fromDico, fromFile, userDefaults]
```

You can access or modify this composite preferences like any PreferencesType.

1. When accessing, first preferences that define a value for a specified key will respond
2. When modifying, first mutable preferences will be affected by default  (you can set `MutableCompositePreferences` attribute `affectOnlyFirstMutable` to `false` to affect all mutable preferences)

The main goal is to define read-only preferences for your app (in code or files) and some mutable preferences (like NSUserDefaults, NSUbiquitousKeyValueStore). You can then access to one preference value without care about the origin

# Setup #

## Using xcode project ##

1. Drag Prephirences.xcodeproj to your project/workspace or open it to compile it
2. Add the Prephirences framework to your project

## Using [cocoapods](http://cocoapods.org/) ##

Add `pod 'Prephirences', :git => 'https://github.com/phimage/Prephirences.git'` to your `Podfile` and run `pod install`. 

Add `use_frameworks!` to the end of the `Podfile`.

### For core data ###
Add `pod 'Prephirences/CoreData', :git => 'https://github.com/phimage/Prephirences.git'`

# Licence #
```
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
```

# Logo #
By [kodlian] (http://www.kodlian.com/), inspired by [apple swift logo](http://en.wikipedia.org/wiki/File:Apple_Swift_Logo.png)
## Why a logo?
I like to see an image for each of my project when I browse them with [SourceTree](http://www.sourcetreeapp.com/)
