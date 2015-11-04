# Prephirences - Preϕrences
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org) [![Platform](http://img.shields.io/badge/platform-ios_osx-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/) [![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift) [![Issues](https://img.shields.io/github/issues/phimage/Prephirences.svg?style=flat
           )](https://github.com/phimage/Prephirences/issues) [![Cocoapod](http://img.shields.io/cocoapods/v/Prephirences.svg?style=flat)](http://cocoadocs.org/docsets/Prephirences/) [![Build Status](https://travis-ci.org/phimage/Prephirences.svg)](https://travis-ci.org/phimage/Prephirences)


[<img align="left" src="logo.png" hspace="20">](#logo) Prephirences is a Swift library that provides useful protocols and convenience methods to manage application preferences, configurations and app-state.

```swift
let userDefaults = NSUserDefaults.standardUserDefaults()
if let enabled = userDefaults["enabled"] as? Bool {..}
```

Preferences could be user preferences `NSUserDefaults`, iCloud stored preferences `NSUbiquitousKeyValueStore`, key chain, file stored preferences (ex: *[plist](http://en.wikipedia.org/wiki/Property_list)*) or your own private application preferences - ie. any object which implement the protocol [PreferencesType](/Prephirences/PreferencesType.swift), which define key value store methods

You can 'merge' multiples preferences and work with them transparently (see [Composing](#composing))

## Contents ##
- [Usage](#usage)
  - [Creating](#creating)
  - [Accessing](#accessing)
  - [Modifying](#modifying)
  - [Archiving](#archiving)
  - [Some implementations](#some-implementations)
    - [NSUserDefaults](#nsuserdefaults)
    - [NSUbiquitousKeyValueStore](#nsubiquitouskeyvaluestore)
    - [Key Value Coding](#kvc)
    - [Core Data](#core-data)
    - [Plist](#plist)
    - [Keychain](#keychain)
  - [Proxying preferences with prefix](#proxying-preferences-with-prefix)
  - [Composing](#composing)
  - [Managing preferences instances](#managing-preferences-instances)
  - [Remote preferences](#remote-preferences)
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

Modifiable preferences implement the protocol [MutablePreferencesTypes](/Prephirences/PreferencesType.swift)

The simplest implementation is [MutableDictionaryPreferences](/Prephirences/DictionaryPreferences.swift)

```swift
var mutableFromDico: MutableDictionaryPreferences = ["myKey": "myValue"]

mutableFromDico["newKey"] = "newValue"
mutableFromDico.setObject("myValue", forKey: "newKey")
mutableFromDico.setBool(true, forKey: "newKey")
...
```
You can append dictionary or other `PreferencesType` using operators
```swift
mutableFromDico += ["newKey": "newValue", "otherKey": true]
```
You can also remove one preference
```swift
mutableFromDico -= "myKey"
```

### Apply operators to one preference ###
You can extract a `MutablePreference` from any `MutablePreferencesTypes` and apply operators according to its value type
```swift
var intPref: MutablePreference<Int> = aPrefs.preferenceForKey("intKey")
var intPref: MutablePreference<Int> = aPrefs <| "intKey"

intPref++
intPref--
intPref += 30
intPref -= 30
intPref *= 20
intPref %= 7
intPref /= 3

switch(intPref) {
   case 1: println("one")
   case 2...10: println("not one or zero but...")
   default: println("unkwown")
}

var boolPref: MutablePreference<Bool> = aPrefs <| "boolKey")

boolPref &= false
boolPref |= true
boolPref != true

```
You can also use some methods to change value
```swift
var stringPref: MutablePreference<String> = userDefaults <| "stringKey"
stringPref.apply { value in
  return value?.uppercaseString
}
```
or transform the value type using closures
```swift
let intFromBoolPref : MutablePreference<Int> = boolPref.transform { value in
  return (value ?? false) ? 1:0
}
```
## Archiving and transformation ##
Archiving is particularly useful with `NSUserDefaults` because `NSUserDefaults` can't store all type of objects.
The following functions could help by transforming the value into an other type

You can archive into `NSData` using this two methods
```swift
userDefaults.setObjectToArchive(UIColor.blueColor(), forKey: "colorKey")
userDefaults["colorKey", .Archive] = UIColor.blueColor()
```
and unarchive using
```swift
if let color = userDefaults.unarchiveObjectForKey("colorKey") as? UIColor {..}
if let color = userDefaults["colorKey", .Archive]  as? UIColor {..}
```
If you extract one preference, use `transformation` property to setup archive mode
```swift
var colorPref: MutablePreference<UIColor> = userDefaults <| "colorKey"
colorPref.transformation = .Archive
colorPref.value = UIColor.redColor()
if let color = colorPref.value as? UIColor {..}
```
You can also apply for all objects type an [`NSValueTransformer`](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValueTransformer_Class/index.html), to transform into JSON for instance
```swift
userDefaults["colorKey", myValueTransformerToJson] = myComplexObject

if let object = userDefaults["colorKey", myValueTransformerToJson] {...}
```
:warning: `allowsReverseTransformation` must return `true`

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
// with type to archive
userDefaults["mykey", .Archive] = UIColor.blueColor()
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
### Plist ###
There is many way to play with plist files

- You can use `Plist` (with the useful `write` method)
- You can init `DictionaryPreferences` or `MutableDictionaryPreferences` with plist file
- You can read dictionnary from plist file and use `setObjectsForKeysWithDictionary` on any mutable preferences

### Keychain ###
To store into keychain, use an instance of ```KeychainPreferences```

```swift
KeychainPreferences.sharedInstance // default instance with main bundle id
var keychain = KeychainPreferences(service: "com.github.example")
```
then store `String` or `NSData`
```swift
keychain["anUserName"] = "password-encoded"

if let pass = keychain.stringForKey("anUserName") {..}
```
**Accessibility**
````
keychain.accessibility = .AccessibleAfterFirstUnlock
````

**Sharing Keychain items**
```swift
keychain.accessGroup = "AKEY.shared"
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

The main goal is to define read-only preferences for your app (in code or files) and some mutable preferences (like `NSUserDefaults`, `NSUbiquitousKeyValueStore`). You can then access to one preference value without care about the origin

## Managing preferences instances ##
If you want to use Prephirences into a framework or want to get a `Preferences` without adding dependencies between classes, you can register any `PreferencesType` into `Prephirences`

as shared instance
```swift
Prephirences.sharedInstance = myPreferences
```
 or by providing an `Hashable` key
```swift
Prephirences.registerPreferences(myPreferences, forKey: "myKey")
Prephirences.instances()["myKey"] = myPreferences
Prephirences.instances()[NSStringFromClass(self.dynamicType)] = currentClassPreferences
```
Then you can access it anywhere
```swift
if let pref = Prephirences.instanceForKey("myKey") {..}
if let pref = Prephirences.instances()["myKey"] {..}
```

## Remote preferences ##
By using remote preferences you can remotely control the behavior of your app.

If you use [Alamofire](https://github.com/Alamofire/Alamofire), [Alamofire-Prephirences](https://github.com/phimage/Alamofire-Prephirences) will help you to load preferences from remote JSON or Plist

# Setup #

## Using [cocoapods](http://cocoapods.org/) ##

Add `pod 'Prephirences'` to your `Podfile` and run `pod install`.

*Add `use_frameworks!` to the end of the `Podfile`.*

### For core data ###
Add `pod 'Prephirences/CoreData'`

## Using xcode project ##

1. Drag Prephirences.xcodeproj to your project/workspace or open it to compile it
2. Add the Prephirences framework to your project

# Logo #
By [kodlian](http://www.kodlian.com/)
## Why a logo?
I like to see an image for each of my projects when I browse them with [SourceTree](http://www.sourcetreeapp.com/)
