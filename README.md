# Prephirences - Preϕrences

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-ios_osx_tvos-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Issues](https://img.shields.io/github/issues/phimage/Prephirences.svg?style=flat
           )](https://github.com/phimage/Prephirences/issues)
[![Cocoapod](http://img.shields.io/cocoapods/v/Prephirences.svg?style=flat)](http://cocoadocs.org/docsets/Prephirences/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/phimage/Prephirences.svg)](https://travis-ci.org/phimage/Prephirences)
[![Reference](https://www.versioneye.com/objective-c/prephirences/reference_badge.svg?style=flat)](https://www.versioneye.com/objective-c/prephirences/references)
[![Join the chat at https://gitter.im/phimage/Prephirences](https://img.shields.io/badge/GITTER-join%20chat-00D06F.svg)](https://gitter.im/phimage/Prephirences?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[<img align="left" src="logo.png" hspace="20">](#logo) Prephirences is a Swift library that provides useful protocols and convenience methods to manage application preferences, configurations and app-state.

```swift
let userDefaults = UserDefaults.standard
if let enabled = userDefaults["enabled"] as? Bool {..}
userDefaults["mycolorkey", .Archive] = UIColor.blueColor()
```

Preferences could be
- User preferences `UserDefaults`
- iCloud stored preferences `NSUbiquitousKeyValueStore`
- [Keychain](https://en.wikipedia.org/wiki/Keychain_%28software%29) to store credential
- Application information from `Bundle`
- File stored preferences (ex: *[plist](http://en.wikipedia.org/wiki/Property_list)*)
- or your own private application preferences

ie. any object which implement the simple protocol [PreferencesType](/Prephirences/PreferencesType.swift), which define key value store methods.

You can also combine multiples preferences and work with them transparently (see [Composing](#composing))

## Contents ##
- [Usage](#usage)
  - [Creating](#creating) • [Accessing](#accessing) • [Modifying](#modifying) • [Transformation and Archiving](#transformation-and-archiving)
  - [Some implementations](#some-implementations)
    - [UserDefaults](#userdefaults) • [Bundle](#bundle) • [NSUbiquitousKeyValueStore](#nsubiquitouskeyvaluestore) • [Key Value Coding](#key-value-coding) • [Core Data](#core-data) • [Plist](#plist) • [Keychain](#keychain) • [NSCoder](#nscoder)
  - [Custom implementations](#custom)
  - [Proxying preferences with prefix](#proxying-preferences-with-prefix)
  - [Composing](#composing)
  - [Managing preferences instances](#managing-preferences-instances)
  - [Remote preferences](#remote-preferences)
  - [Encrypt your preferences](#encrypt-your-preferences)
- [Setup](#setup)
  - [Using Cocoapods](#using-cocoapods) • [Using Carthage](#using-carthage) • [Using xcode project](#using-xcode-project)
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
You can access with all methods defined in [PreferencesType](/Prephirences/PreferencesType.swift) protocol

```swift
if let myValue = fromDicoLiteral.object(forKey: "myKey") {..}
if let myValue = fromDicoLiteral["bool"] as? Bool {..}

var hasKey = fromDicoLiteral.hasObject(forKey: "myKey")
var myValue = fromDicoLiteral.bool(forKey: "myKey")
..

```

If you want to access using `RawRepresentable` `enum`.
```swift
enum MyKey: PreferenceKey/*String*/ {
   case Key1, Key2, ...
}
if let myValue = fromDicoLiteral.object(forKey: MyKey.Key1) {..}
var myValue = fromDicoLiteral.bool(forKey: MyKey.Key2)

```
:warning: [RawRepresentableKey](/Prephirences/RawRepresentableKey/RawRepresentable+Prephirences.swift) must be imported, see [setup](#for-rawrepresentable-key).

## Modifying ##

Modifiable preferences implement the protocol [MutablePreferencesTypes](/Prephirences/PreferencesType.swift)

The simplest implementation is [MutableDictionaryPreferences](/Prephirences/DictionaryPreferences.swift)

```swift
var mutableFromDico: MutableDictionaryPreferences = ["myKey": "myValue"]

mutableFromDico["newKey"] = "newValue"
mutableFromDico.set("myValue", forKey: "newKey")
mutableFromDico.set(true, forKey: "newKey")
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
var intPref: MutablePreference<Int> = aPrefs.preference(forKey: "intKey")
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
## Transformation and archiving ##
Before storing or accessing the value, transformation could be applied, which conform to protocol `PreferenceTransformation`.

This allow to archive, to change type, return default value if nil and many more.

You can get and set value using `substrict`
```swift
userDefaults["aKey", myTransformation] = myObject

if let object = userDefaults["aKey", myTransformation] {...}
```

If you extract one preference, use `transformation` property to setup the transformation
```swift
var aPref: MutablePreference<MyObject> = userDefaults <| "aKey"
aPref.transformation = myTransformation
```
or you can use some utility functions to specify a default value when the stored value match a condition

```swift
public var intValueMin10: MutablePreference<Int> {
  get {
    return userDefaults.preference(forKey: "intKey")
          .whenNil(use: 100)
          .ensure(when: lessThan100, use: 100)
  }
  set {..}
}
```

### Archiving
Archiving is particularly useful with `NSUserDefaults` because `NSUserDefaults` can't store all type of objects.
The following functions could help by transforming the value into an other type

You can archive into `Data` using this two methods
```swift
userDefaults.set(objectToArchive: UIColor.blueColor(), forKey: "colorKey")
userDefaults["colorKey", .Archive] = UIColor.blueColor()
```
and unarchive using
```swift
if let color = userDefaults.unarchiveObject(forKey: "colorKey") as? UIColor {..}
if let color = userDefaults["colorKey", .Archive]  as? UIColor {..}
```
If you extract one preference, use `transformation` property to setup archive mode
```swift
var colorPref: MutablePreference<UIColor> = userDefaults <| "colorKey"
colorPref.transformation = TransformationKey.Archive
colorPref.value = UIColor.redColor()
if let color = colorPref.value as? UIColor {..}
```
### NSValueTransformer
You can also apply for all objects type an [`NSValueTransformer`](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValueTransformer_Class/index.html), to transform into JSON for instance
```swift
userDefaults["colorKey", myValueTransformerToJson] = myComplexObject

if let object = userDefaults["colorKey", myValueTransformerToJson] {...}
```
:warning: `allowsReverseTransformation` must return `true`

### Store RawRepresentable objects

For `RawRepresentable` objects like `enum` you can use the computed attribute `preferenceTransformation` as `transformation`
```swift
enum PrefEnum: String {
    case One, Two, Three
}
var pref: MutablePreference<PrefEnum> = preferences <| "enumKey"
pref.transformation = PrefEnum.preferenceTransformation
pref.value = PrefEnum.Two
```

## Some implementations ##
### UserDefaults ###

`UserDefaults` implement `PreferencesType` and can be acceded with same methods

```swift
let userDefaults = UserDefaults.standard

if let myValue = userDefaults["mykey"] as? Bool {..}
```

NSUserDefaults implement also `MutablePreferencesType` and can be modified with same methods
```swift
userDefaults["mykey"] = "myvalue"
// with type to archive
userDefaults["mykey", .Archive] = UIColor.blueColor()
```

### Bundle ###
All `Bundle` implement `PreferencesType`, allowing to access Info.plist file.

For instance the `Bundle.main` contains many useful informations about your application.

Prephirences framework come with some predefined enums described in [apple documentations](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Introduction/Introduction.html) and defined in `PropertyListKeys.swift`

```swift
let bundle = Bundle.main
let applicationName = bundle[.CFBundleName] as? String
```

### NSUbiquitousKeyValueStore ###
To store in iCloud, `NSUbiquitousKeyValueStore` implement also `PreferencesType`

See composing chapter to merge and synchronize iCloud preferences with other preferences.

### Key Value Coding ###
#### Foundation classes
You can wrap an object respond to implicit protocol [NSKeyValueCoding](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) in `KVCPreferences` or `MutableKVCPreferences`
```swift
let kvcPref = MutableKVCPreferences(myObject)
```
Be sure to affect the correct object type


#### Swift classes
Using `ReflectingPreferences` you can easily access to a struct or swift class. Just add extension.
```swift
struct PreferenceStruct {
    var color: String = "red"
    var age: Int
    let enabled: Bool = true
}
extension PreferenceStruct: ReflectingPreferences {}
```
You can then use all functions from `PreferencesType`
```
var pref = PreferenceStruct(color: "red", age: 33)
if pref["color"] as? String { .. }
```

### Core Data ###
You can wrap on `NSManageObject` in `ManageObjectPreferences` or `MutableManageObjectPreferences`
```swift
let managedPref = ManageObjectPreferences(myManagedObject)
```
### Plist ###
There is many way to play with plist files

- You can use `Plist` (with the useful `write` method)
- You can init `DictionaryPreferences` or `MutableDictionaryPreferences` with plist file
- You can read dictionary from plist file and use `set(dictionary: ` on any mutable preferences

### Keychain ###
To store into keychain, use an instance of ```KeychainPreferences```

```swift
KeychainPreferences.sharedInstance // default instance with main bundle id
var keychain = KeychainPreferences(service: "com.github.example")
```
then store `String` or `Data`
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

### NSCoder ###
`NSCoder` is partially supported (`dictionary` is not available)

When you implementing [NSCoding](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/) you can do
```swift
init?(coder decoder: NSCoder) {
  self.init()
  self.intVar = decoder["intVarKey"] as? Int ?? 0
  // or self.intVar = decoder.integer(forKey: "intVar")
  self.stringVar = decoder["stringVarKey"] as? String ?? ""
}

func encodeWithCoder(coder: NSCoder) {
  coder["intVarKey"] = self.intVar
  coder["stringVarKey"] = self.stringVar
}

```

## Custom implementations ##
### Preferences
Create a custom object that conform to `PreferencesType` is very easy.

```swift
extension MyCustomPreferences: PreferencesType {
    func object(forKey: String) -> Any? {
        // return an object according to key
    }
    func dictionary() -> [String : Any] {
        // return a full dictionary of key value
    }
}
```
Only two functions are mandatory, others are automatically mapped but can be overrided for performance or readability.

- In the same way you can implement `MutablePreferencesType` with `set` and `removeObject(forKey:` methods.
- If you structure give a list of keys instead of a full dictionary, you can instead conform to `PreferencesAdapter` and implement `func keys() -> [String]`.
- You have a collection of object with each object could define a key and a value take a look at `CollectionPreferencesAdapter` or see `NSHTTPCookieStorage` implementation.


### Accessing using custom key
Instead of using `string` or `string` constants, you can use an `enum` to define a list of keys

First create your `enum` with `String` raw value
```swift
enum MyEnum: String {
  case MyFirstKey
  case MySecondKey
}
```
Then add a subscript for your key
```swift
extension PreferencesType {
    subscript(key: MyEnum) -> Any? {
        return self[key.rawValue]
    }
}
```
Finally access your information
```swift
if let firstValue = bundle[.MyFirstKey] {..}
```
You can do the same with `MutablePreferencesType`

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

You can access or modify this composite preferences like  any `PreferencesType`.

1. When accessing, first preferences that define a value for a specified key will respond
2. When modifying, first mutable preferences will be affected by default, but you can set `MutableCompositePreferences` attribute `affectOnlyFirstMutable` to `false` to affect all mutable preferences, allowing you for instance to duplicate preferences in iCloud

The main goal is to define read-only preferences for your app (in code or files) and some mutable preferences (like `UserDefaults`, `NSUbiquitousKeyValueStore`). You can then access to one preference value without care about the origin.

## Managing preferences instances ##
If you want to use Prephirences into a framework or want to get a `Preferences` without adding dependencies between classes, you can register any `PreferencesType` into `Prephirences`

as shared instance
```swift
Prephirences.sharedInstance = myPreferences
```
 or by providing an `Hashable` key
```swift
Prephirences.register(preferences: myPreferences, forKey: "myKey")
Prephirences.instances()["myKey"] = myPreferences
Prephirences.instances()[NSStringFromClass(self.dynamicType)] = currentClassPreferences
```
Then you can access it anywhere
```swift
if let pref = Prephirences.instance(forKey: "myKey") {..}
if let pref = Prephirences.instances()["myKey"] {..}
```

## Remote preferences ##
By using remote preferences you can remotely control the behavior of your app.

If you use [Alamofire](https://github.com/Alamofire/Alamofire), [Alamofire-Prephirences](https://github.com/phimage/Alamofire-Prephirences) will help you to load preferences from remote JSON or Plist

## Encrypt your preferences ##
You can use framework [CryptoPrephirences](https://github.com/phimage/CryptoPrephirences) to encrypt/decrypt your preferences using cipher from [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)

# Setup #

## Using Cocoapods ##
[CocoaPods](https://cocoapods.org/) is a centralized dependency manager for
Objective-C and Swift. Go [here](https://guides.cocoapods.org/using/index.html)
to learn more.

1. Add the project to your [Podfile](https://guides.cocoapods.org/using/the-podfile.html).

    ```ruby
    use_frameworks!

    pod 'Prephirences'
    ```

2. Run `pod install` and open the `.xcworkspace` file to launch Xcode.

### For core data ###
Add `pod 'Prephirences/CoreData'`

### For RawRepresentable key ###
Add `pod 'Prephirences/RawRepresentableKey'`

### For PropertyListKeys ###
Add `pod 'Prephirences/Keys'`

## Using Carthage ##
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Objective-C and Swift.

1. Add the project to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

    ```
    github "phimage/Prephirences"
    ```

2. Run `carthage update` and follow [the additional steps](https://github.com/Carthage/Carthage#getting-started)
   in order to add Prephirences to your project.

## Using xcode project ##

1. Drag Prephirences.xcodeproj to your project/workspace or open it to compile it
2. Add the Prephirences framework to your project

# Logo #
By [kodlian](http://www.kodlian.com/)
