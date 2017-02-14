# Preϕrences - PreferencesTabViewController
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org) [![Platform](http://img.shields.io/badge/platform-osx-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/) [![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift) [![Cocoapod](http://img.shields.io/cocoapods/v/Prephirences.svg?style=flat)](http://cocoadocs.org/docsets/Prephirences/)

[PreferencesTabViewController](PreferencesTabViewController.swift) is a [`NSTabViewController`](https://developer.apple.com/library/mac/documentation/AppKit/Reference/NSTabViewController_Class/) to use into your storyboard to resize automatically the parent window according to selected children tab view.

![GitHub Logo](PreferencesWindow.gif)

# How to use
- Into storyboard set `PreferencesTabViewController` as custom class of your `NSTabViewController`
- Set this controller as `delegate` of `NSTableView` (named by default 'No Shadow Tab View')
- Set wanted sizes for each of your tab views

# Resize according to dynamic content
First let your tab view controller implement protocol `PreferencesTabViewItemControllerType`
and define the mandatory variable `preferencesTabViewSize` into your view controller
```swift
class MyCustomTabViewController : NSViewController, PreferencesTabViewItemControllerType {
	var preferencesTabViewSize: NSSize = NSSize(width: 0, height: 200)

// or read-only property
extension MyCustomTabViewController: PreferencesTabViewItemControllerType {
    var preferencesTabViewSize: NSSize {
      let heightAccordingToContent = ...
      return NSSize(width: 0, height: heightAccordingToContent)
    }
```
Then when view content change update the variable or fire event for read-only property
*For instance you can enlarge the height of the window when adding a row to a table view*
```swift
let heightAccordingToContent = ...
preferencesTabViewSize = NSSize(width: 0, height: heightAccordingToContent)

// or for read-only property
self.willChangeValueForKey(kPreferencesTabViewSize)
/// modify view, add table row, etc...
self.didChangeValueForKey(kPreferencesTabViewSize)
```

`0` means use width or height defined in storyboard

# Setup #

## Using [cocoapods](http://cocoapods.org/) ##

Add `pod 'Prephirences/Cocoa'` to your `Podfile` and run `pod install`.

*Add `use_frameworks!` to the end of the `Podfile`.*

## Using source ##

Drag [PreferencesTabViewController.swift](PreferencesTabViewController.swift) into your project

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