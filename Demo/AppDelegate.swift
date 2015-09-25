//
//  AppDelegate.swift
//
//  Created by Dawid Górny on 14/06/15.
//  Copyright (c) 2015 Dawid Górny. All rights reserved.
//

import Cocoa
import AppKit
import GLKit
import QuartzCore.CVDisplayLink

var isApplicationSetUp = false

class WindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(notification: NSNotification) {
//        NSApplication.sharedApplication().terminate(0)
    }
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let window = NSWindow(contentRect: NSMakeRect(100, 100, CGFloat(WINDOW_WIDTH), CGFloat(WINDOW_HEIGHT)),
        styleMask: NSTitledWindowMask|NSResizableWindowMask|NSMiniaturizableWindowMask|NSClosableWindowMask,
        backing: NSBackingStoreType.Buffered,
        `defer`: true)

    var glView: SwiftOpenGLView?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application

        window.title = "BGFX-Swift Cubes"
//        window.opaque = false
        window.center()

        // ---

        glView = SwiftOpenGLView(frame: NSMakeRect(0, 0, CGFloat(WINDOW_WIDTH), CGFloat(WINDOW_HEIGHT)))
//        window.contentView.addSubview(glView!)


        // ---


        window.makeKeyAndOrderFront(nil)

        let windowDelegate = WindowDelegate()
        window.delegate = windowDelegate

        let controller = MainWindowController(window: window)
        controller.showWindow(self)

       // --



        let window_ptr = UnsafeMutablePointer<Void>(Unmanaged<NSWindow>.passRetained(window).toOpaque())

        var pd_osx : bgfx_platform_data_t = bgfx_platform_data_t(ndt: nil,
            nwh: window_ptr,
            context: nil,
            backBuffer: nil,
            backBufferDS: nil)

        bgfx_set_platform_data(&pd_osx);

        bgfx_init(RENDERER_TYPE,
            UInt16(BGFX_PCI_ID_NONE),
            UInt16(0),
            nil,
            nil
        )

        bgfx_reset(UInt32(WINDOW_WIDTH), UInt32(WINDOW_HEIGHT), UInt32(WINDOW_RESET))

        glView?.bgfx_initialized = true
//        glView?.setup()
        setup()
        isApplicationSetUp = true

    }


    func applicationWillTerminate(notification: NSNotification) {
        print("applicationWillTerminate")
        shutdown()
        glView?.bgfx_initialized = false
        bgfx_shutdown()

        //CVDisplayLinkIsRunning(<#T##displayLink: CVDisplayLink##CVDisplayLink#>)

        var link: CVDisplayLink! = glView!.displayLink.memory

        if link != nil {
            if let running = CVDisplayLinkIsRunning(link) as Bool? {
                print("Stopping CVDisplayLink")
                let result = CVDisplayLinkStop(link)
    //            let r = result.value
    //            if r == kCVReturnSuccess.value { print("CVDisplayLink stopped\n\tCode: \(result)") }
            }
        }

        //  Grab the current window in our app, and from that grab the subviews of the attached viewController
        //  Cycle through that array to get our SwiftOpenGLView instance

        /*
        let windowController = NSApplication.sharedApplication().mainWindow?.windowController! as? NSWindowController
        let views = windowController?.contentViewController?.view.subviews as [NSView]
        for view in views {
            if let aView = view as? SwiftOpenGLView {
                println("Checking if CVDisplayLink is running")
                if let running = CVDisplayLinkIsRunning(aView.displayLink) as Boolean? {
                    println("Stopping CVDisplayLink")
                    let result = CVDisplayLinkStop(aView.displayLink)
                    if result == kCVReturnSuccess.value { println("CVDisplayLink stopped\n\tCode: \(result)") }
                }
            }
        }
*/
    }

}
