# Prephirence
===========

![Logo](/phimage/prephirence/raw/master/logo-128x128.png)

![Platform](http://img.shields.io/badge/platform-iOS/MacOS-orange.svg?style=flat)

Prephirence is a Swift library that provides useful protocol and methods to manage preferences.
Preferences could be user preferences (NSUserDefaults) or your own private application preferences.

## Contents ##
- [Usage](#usage)
- [Setup](#setup)
- [Roadmap](#roadmap)

# Usage #

## Creating ##
```swift
// From Dictionary
var preferencesFromFile = DictionaryPreferences(myDictionary)
// From filepath
if let preferencesFromFile = DictionaryPreferences(filenPath: "/my/file/path") {..}
// From file in main bundle ##
if let preferencesFromFile = DictionaryPreferences(filename: "mypreferences", ofType: "plist") {..}
```

## Accessing ##
You can access with all methods defined in PreferencesType

```swift
if let myValue = preferencesFromFile.objectForKey("myKey) {..}
if let myValue = preferencesFromFile["mykey"] as? Bool {..}

var hasKey = preferencesFromFile.hasObjectForKey("myKey")
var myValue = preferencesFromFile.boolForKey("myKey)
..

```

## Modifying ##
(todo)


## NSUserDefaults ##

NSUserDefaults implement PreferencesType and can be acceded with same methods

```swift
let userDefaults = NSUserDefaults.standardUserDefaults()

if let myValue = userDefaults["mykey"] as? Bool {..}
```

NSUserDefaults implement also MutablePreferencesType and can be modified with same methods
```swift
(todo)
```
### Proxing user defaults ###
You can defined a sub category of NSUserDefaults prefixed with your own string
```swift
let myAppPreferences = userDefaults["myAppKey"] as! MutableProxyPreferences
// We have :
var test: Bool = userDefaults["myAppKey.myKey] == myAppPreferences["myKey"]
```

## Composing ##

```swift
...
let myPreferences = MutableCompositePreferences(array: [preferencesFromFile, userDefaults])
```


# Setup #
- Import Prephirence.xcodeproj to your project
- Or import swift files to your projects

# Roadmap #
Add CocoaPod
