//
//  PreferencesTabViewController.swift
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
#if os(macOS)
import Cocoa

/* Controller of tab view item can give prefered size by implementing this protocol */
@objc public protocol PreferencesTabViewItemControllerType {

    var preferencesTabViewSize: NSSize {get}
}
/* Key for event on property preferencesTabViewSize */
public let kPreferencesTabViewSize = "preferencesTabViewSize"

/* Controller which resize parent window according to tab view items, useful for preferences */
@available(OSX 10.10, *)
public class PreferencesTabViewController: NSTabViewController {
    private var observe = false

    // Keep size of subview
    private var cacheSize = [NSView: NSSize]()

    // MARK: overrides

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.transitionOptions = []
    }

    override public func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        // remove listener on previous selected tab view
        if let selectedTabViewItem = self.selectedTabViewItem as? NSTabViewItem,
            let viewController = selectedTabViewItem.viewController as? PreferencesTabViewItemControllerType, observe {
                (viewController as! NSViewController).removeObserver(self, forKeyPath: kPreferencesTabViewSize, context: nil)
                observe = false
        }

        super.tabView(tabView, willSelect: tabViewItem)

        // get size and listen to change on futur selected tab view item
        if let view = tabViewItem?.view {
            let currentSize = view.frame.size // Expect size from storyboard constraints or previous size

            if let viewController = tabViewItem?.viewController as? PreferencesTabViewItemControllerType {
                cacheSize[view] = getPreferencesTabViewSize(viewController, currentSize)

                // Observe kPreferencesTabViewSize
                let options = NSKeyValueObservingOptions.new.union(.old)
                (viewController as! NSViewController).addObserver(self, forKeyPath: kPreferencesTabViewSize, options: options, context: nil)
                observe = true
            }
            else {
               cacheSize[view] = cacheSize[view] ?? currentSize
            }
        }
    }

    override public func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        if let view = tabViewItem?.view, let window = self.view.window, let contentSize = cacheSize[view] {
            self.setFrameSize(size: contentSize, forWindow: window)
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let kp = keyPath, kp == kPreferencesTabViewSize {
            if let window = self.view.window, let viewController = object as? PreferencesTabViewItemControllerType,
                let view = (viewController as? NSViewController)?.view, let currentSize = cacheSize[view]  {
                let contentSize = self.getPreferencesTabViewSize(viewController, currentSize)
                cacheSize[view] = contentSize

                DispatchQueue.main.async {
                    self.setFrameSize(size: contentSize, forWindow: window)
                }
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    override public func removeTabViewItem(_ tabViewItem: NSTabViewItem) {
        if let _ = tabViewItem.view {
            if let viewController = tabViewItem.viewController as? PreferencesTabViewItemControllerType {
                tabViewItem.removeObserver(viewController as! NSViewController, forKeyPath: kPreferencesTabViewSize)
            }
        }
    }

    func _removeAllToolbarItems(){
        // Maybe fix a bug with toolbar style
    }

    deinit {
        if let selectedTabViewItem = self.selectedTabViewItem as? NSTabViewItem,
            let viewController = selectedTabViewItem.viewController as? PreferencesTabViewItemControllerType, observe {
                (viewController as! NSViewController).removeObserver(self, forKeyPath: kPreferencesTabViewSize, context: nil)
        }
    }

    // MARK: public

    public var selectedTabViewItem: AnyObject? {
        return selectedTabViewItemIndex<0 ? nil : tabViewItems[selectedTabViewItemIndex]
    }

    // MARK: privates

    private func getPreferencesTabViewSize(_ viewController: PreferencesTabViewItemControllerType,_ referenceSize: NSSize) -> NSSize {
        var controllerProposedSize = viewController.preferencesTabViewSize
        if controllerProposedSize.width <= 0 { // 0 means keep size
            controllerProposedSize.width = referenceSize.width
        }
        if controllerProposedSize.height <= 0 {
            controllerProposedSize.height = referenceSize.height
        }
        return controllerProposedSize
    }

    private func setFrameSize(size: NSSize, forWindow window: NSWindow) {
        let newWindowSize = window.frameRect(forContentRect: NSRect(origin: CGPoint.zero, size: size)).size

        var frame = window.frame
        frame.origin.y += frame.size.height
        frame.origin.y -= newWindowSize.height
        frame.size = newWindowSize

        window.setFrame(frame, display:true, animate:true)
    }

}
#endif
