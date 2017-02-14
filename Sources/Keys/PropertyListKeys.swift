//
//  PropertyListKeys.swift
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

//https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Introduction/Introduction.html

// https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/TP40009249-SW1
public enum CoreFoundationKeys: PreferenceKey {

    case CFBundleAllowMixedLocalizations
    case CFBundleDevelopmentRegion
    case CFBundleDisplayName
    case CFBundleDocumentTypes
    case CFBundleExecutable
    case CFBundleIconFile
    case CFBundleIcons
    case CFBundleIdentifier
    case CFBundleInfoDictionaryVersion
    case CFBundleLocalizations
    case CFBundleName
    case CFBundlePackageType
    case CFBundleShortVersionString
    case CFBundleSignature
    case CFBundleSpokenName
    case CFBundleURLTypes
    case CFBundleVersion

    #if os(OSX)
    case CFAppleHelpAnchor
    case CFBundleHelpBookFolder
    case CFBundleHelpBookName
    case CFPlugInDynamicRegistration
    case CFPlugInDynamicRegistrationFunction
    case CFPlugInFactories
    case CFPlugInTypes
    case CFPlugInUnloadFunction

    #elseif os(iOS)
    case CFBundleIconFiles
    #endif

    // MARK: dev environment
    case DTXcode
    case DTXcodeBuild
    case DTCompiler
    case DTPlatformBuild
    case DTPlatformName
    case DTPlatformVersion
    case DTSDKBuild
    case DTSDKName

}

extension PreferencesType {

    public subscript(key: CoreFoundationKeys) -> PreferenceObject? {
        return self[key.rawValue]
    }

}

#if os(iOS)
    // https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html
    public enum IOSKeys: PreferenceKey {

        case MKDirectionsApplicationSupportedModes
        case NSHealthShareUsageDescription
        case NSHealthUpdateUsageDescription
        case UIAppFonts
        case UIApplicationExitsOnSuspend
        case UIApplicationShortcutItems
        case UIBackgroundModes
        case UIDeviceFamily
        case UIFileSharingEnabled
        case UIInterfaceOrientation
        case UILaunchImageFile
        case UILaunchImages
        case UIMainStoryboardFile
        case UINewsstandApp
        case UIPrerenderedIcon
        case UIRequiredDeviceCapabilities
        case UIRequiresPersistentWiFi
        case UIStatusBarHidden
        case UIStatusBarStyle
        case UISupportedExternalAccessoryProtocols
        case UISupportedInterfaceOrientations
        case UIViewControllerBasedStatusBarAppearance
        case UIViewEdgeAntialiasing
        case UIViewGroupOpacity
    }

    extension PreferencesType {

        public subscript(key: IOSKeys) -> PreferenceObject? {
            return self[key.rawValue]
        }

    }
#endif

#if os(watchOS)
    // https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/watchOSKeys.html#//apple_ref/doc/uid/TP40016498-SW1
    public enum WatchOSKeys: PreferenceKey {

        case CLKComplicationSupportedFamilies
        case CLKComplicationPrincipalClass
        case WKAppBundleIdentifier
        case WKCompanionAppBundleIdentifier
        case WKExtensionDelegateClassName
        case WKWatchKitApp

    }
    extension PreferencesType {

        public subscript(key: WatchOSKeys) -> PreferenceObject? {
            return self[key.rawValue]
        }

    }
#endif

#if os(OSX)
    // https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/GeneralPurposeKeys.html#//apple_ref/doc/uid/TP40009253-SW1
    public enum OSXKeys: PreferenceKey {

        case APFileDescriptionKey
        case APDisplayedAsContainer
        case APFileDestinationPath
        case APFileName
        case APFileSourcePath
        case APInstallAction

    }

    extension PreferencesType {

        public subscript(key: OSXKeys) -> PreferenceObject? {
            return self[key.rawValue]
        }

    }
#endif

// https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/LaunchServicesKeys.html
public enum LaunchServicesKeys: PreferenceKey {

    case LSMinimumSystemVersion

    #if os(OSX)
    case LSApplicationCategoryType
    case LSArchitecturePriority
    case LSBackgroundOnly
    case LSEnvironment
    case LSFileQuarantineEnabled
    case LSFileQuarantineExcludedPathPatterns
    case LSGetAppDiedEvents
    case LSMinimumSystemVersionByArchitecture
    case LSMultipleInstancesProhibited
    case LSRequiresNativeExecution
    case LSUIElement
    case LSUIPresentationMode
    case LSVisibleInClassic

    #else
    case LSRequiresIPhoneOS
    case LSSupportsOpeningDocumentsInPlace
    case LSApplicationQueriesSchemes

    #endif
}

extension PreferencesType {

    public subscript(key: LaunchServicesKeys) -> PreferenceObject? {
        return self[key.rawValue]
    }

}
