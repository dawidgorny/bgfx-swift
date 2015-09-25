//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 2/15/15.
//  Copyright (c) 2015 MyKo. All rights reserved.
//

//  I am assumming the use of OpenGL 3.1 or greater
//  If you are using a function from OpenGL 2.1 or lower, import OpenGL.GL

import Cocoa
import OpenGL.GL3
import QuartzCore.CVDisplayLink



@objc class SwiftOpenGLView: NSOpenGLView {
    
//    var displayLink: CVDisplayLink?
    
    var displayLink = UnsafeMutablePointer<CVDisplayLink?>.alloc(1)
    
    public var ogl_initialized: Bool = false
    public var bgfx_initialized: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init?(frame frameRect: NSRect, pixelFormat format: NSOpenGLPixelFormat?) {
        super.init(frame: frameRect, pixelFormat: format)
    }
    
    override init(frame frameRect: NSRect) {
    
//    required init?(coder: NSCoder) {
        
        //  CVDisplayLinkCreateActiveCGDisplays() takes an UnsafeMutablePointer<Unmanaged<CVDisplayLink>?>
        //  UnsafeMutablePointer can be thought of as an inout parameter--pass the address of your argument (&argument)
        //  Unmanaged<T>? is an optional, and thus indicates the parameter will potentially be nil
        //  (The function's CVReturn will indicate if the provided argument for the parameter was filled or nil)
        //  Unmanaged<T> indicates the C API does't tell the compiler if the argument was retained/unretained (it's non-ARC)
        //  Finally, we declare our type (T) which is CVDisplayLink
        //
        //  Knowing this, we declare a var of type Unmanaged<CVDisplaylink>?.  Note that we do not need to specify it as an
        //  UnsafeMutablePointer<T> (that is only important for the function declaration)
        //
        //  We initialize the CVDisplayLink? var in our class by retrieving the value from the temporary pointer with .takeRetainedValue()
        //  .takeRetainedValue() returns the value from an Unmanaged reference and destroy's the reference (displayLink is initialized)
        
        
//        var displayLinkPointer: Unmanaged<CVDisplayLink>?
//        CVDisplayLinkCreateWithActiveCGDisplays(&displayLinkPointer)
//        displayLink = displayLinkPointer?.takeRetainedValue()
        
        
        
        CVDisplayLinkCreateWithActiveCGDisplays(displayLink)
        var link: CVDisplayLink! = displayLink.memory
        
        
//        let displayLinkPointer: UnsafeMutablePointer<CVDisplayLink?> = UnsafeMutablePointer<CVDisplayLink?>.alloc(1);
        
//        CVDisplayLinkCreateWithActiveCGDisplays(displayLinkPointer)
        
//        var dl: Unmanaged<CVDisplayLink>? = displayLinkPointer
        
//        displayLink = displayLinkPointer.memory
//        displayLink = dl?.takeRetainedValue()
        
        super.init(frame: frameRect)
//        super.init(coder: coder)
        
        //  some OpenGL setup
        //  NSOpenGLPixelFormatAttribute is a typealias for UInt32 in Swift, cast each attribute
        //  Set the view's PixelFormat and Context to the custom pixelFormat and context
        
        self.wantsBestResolutionOpenGLSurface = true
        
        let attrs: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFAColorSize), UInt32(32),
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAOpenGLProfile),
            UInt32( NSOpenGLProfileVersion3_2Core),
            UInt32(0)
        ]
        let pixelFormat = NSOpenGLPixelFormat(attributes: attrs)
        self.pixelFormat = pixelFormat
        let context = NSOpenGLContext(format: pixelFormat!, shareContext: nil)
        self.openGLContext = context
        
        self.openGLContext!.makeCurrentContext()
        
        //  Set the swaping interval parameter on the context, setValues:forParameter: is expecting multiple values--use an array
        //  In Swift, context parameters are accessed though the NSOpenGLContextParameter enum, use dot syntax to access the swap interval
        
        var swapInterval: [GLint] = [1]
        self.openGLContext!.setValues(swapInterval, forParameter: .GLCPSwapInterval)
        
        //  CVDLCallbackFunctionPointer() is a C function declared in CVDisplayLinkCallbackFunction.h
        //  It returns a pointer to our callback:  CVDisplayLinkOutputCallback
        //  The third parameter takes an UnsafeMutablePointer<Void> and our argument needs to be our view (ie self)
        //  We have already stated this type of parameter requires the address of operator '&'
        //  We can't use'&' on out object, but we can still access the pointer using unsafeAddressOf()
        //  However, this address/pointer can't be passed as is--you have to cast to UnsafeMutablePointer<T> (where T is our class)
        //  To se the current display from our OpenGL context, we retrieve the pixelFormat and context as CoreGraphicsLayer objects
        //  Start the CVDisplayLink, note that we need to stop the displayLink when we are done --> done in APPDELEGATE.SWIFT!!!
        
        CVDisplayLinkSetOutputCallback(link!, CVDLCallbackFunctionPointer(), UnsafeMutablePointer<SwiftOpenGLView>(unsafeAddressOf(self)))
        let cglPixelFormat = self.pixelFormat?.CGLPixelFormatObj
        let cglContext = self.openGLContext!.CGLContextObj
        CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(link!, cglContext, cglPixelFormat!)
        CVDisplayLinkStart(link!)
        
        
//        self.ogl_initialized = true
    }
    
    
    //  Called by the callback function to ask our model to render out a frame for our context
    //  We have to cast from an UnsafePointer<CVTimeStamp> to an UnsafeMutablePointer<CVTimeStamp>
    
    func getFrameForTime(outputTime: UnsafePointer<CVTimeStamp>)->CVReturn {
//        var link: CVDisplayLink! = displayLink.memory
//        CVDisplayLinkGetCurrentTime(link!, UnsafeMutablePointer<CVTimeStamp>(outputTime))
        
        //  For development purpose, calculate the frames per second using the CVTimeStamp passed to the callback function
        //  CVTimeStamp is a C struct with several members that are accessed by going straight to their memory location with .memory
        //  'command' + 'click' on CVTimeStamp to see the struct's definition
        
//        let fps = (outputTime.memory.rateScalar * Double(outputTime.memory.videoTimeScale) / Double(outputTime.memory.videoRefreshPeriod))
//        print("FPS:\t \(fps)")
        
        //  It's time to draw, request the rendered frame
        
        if bgfx_initialized && isApplicationSetUp {
            draw()
        }
        
        return CVReturn(kCVReturnSuccess.value)
    }

    
    override func prepareOpenGL() {
//        print("prepareOpenGL")
        
        
        /*
        let context = self.openGLContext
        context!.makeCurrentContext()
        
        glClearColor(0.0, 0.5, 0.0, 1.0)
        
        CGLLockContext(context!.CGLContextObj)
        
        glClear(UInt32(GL_COLOR_BUFFER_BIT))
        
        CGLFlushDrawable(context!.CGLContextObj)
        CGLUnlockContext(context!.CGLContextObj)
        */
        
        if window != nil {
            NSLog("window is OK:")
            NSLog((window?.title)!)
        } else {
            NSLog("window is NIL")
        }
        
        
        self.ogl_initialized = true
        
        
        if bgfx_initialized && isApplicationSetUp {
            draw()
        }
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        if bgfx_initialized && isApplicationSetUp {
            draw()
        }
        
    }
    
}
