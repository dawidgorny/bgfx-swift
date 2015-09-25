//
//  Application.swift
//
//  Created by Dawid Górny on 20/08/15.
//  Copyright © 2015 Dawid Górny. All rights reserved.
//


//
// Basic configuration
//

let WINDOW_WIDTH = 1024
let WINDOW_HEIGHT = 768
let WINDOW_RESET = Int32(BGFX_RESET_VSYNC) // | BGFX_RESET_MSAA_SHIFT

let RENDERER_TYPE = BGFX_RENDERER_TYPE_OPENGL

//
// Cubes Example
//

struct PosColorVertex {
    var x:Float
    var y:Float
    var z:Float
    var abgr:UInt32

    init(x: Float, y: Float, z: Float, abgr: UInt32)
    {
        self.x = x
        self.y = y
        self.z = z
        self.abgr = abgr
    }
}

var cubeVertices:[PosColorVertex] = [
    PosColorVertex(x: -1.0, y: 1.0, z:  1.0, abgr: 0xff000000 ),
    PosColorVertex(x:  1.0, y: 1.0, z:  1.0, abgr: 0xff0000ff ),
    PosColorVertex(x: -1.0, y:-1.0, z:  1.0, abgr: 0xff00ff00 ),
    PosColorVertex(x:  1.0, y:-1.0, z:  1.0, abgr: 0xff00ffff ),
    PosColorVertex(x: -1.0, y: 1.0, z: -1.0, abgr: 0xffff0000 ),
    PosColorVertex(x:  1.0, y: 1.0, z: -1.0, abgr: 0xffff00ff ),
    PosColorVertex(x: -1.0, y:-1.0, z: -1.0, abgr: 0xffffff00 ),
    PosColorVertex(x:  1.0, y:-1.0, z: -1.0, abgr: 0xffffffff )
]

var cubeIndices:[UInt16] = [
    0, 1, 2, // 0
    1, 3, 2,
    4, 6, 5, // 2
    5, 6, 7,
    0, 2, 4, // 4
    4, 2, 6,
    1, 5, 3, // 6
    5, 7, 3,
    0, 4, 1, // 8
    4, 5, 1,
    2, 3, 6, // 10
    6, 3, 7
]

var vbh:bgfx_vertex_buffer_handle_t?
var ibh:bgfx_index_buffer_handle_t?
var program:bgfx_program_handle_t?

var startTime:Double = 0

func setup() {
    print("-------------- SETUP");

    // Set view 0 clear state.
    /*bgfx_set_view_clear(UInt8(0),
        UInt16(BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH),
        UInt32(0x303030ff),
        Float(1.0),
        UInt8(0)
    );*/

    Renderer.setViewClear(0,
        flags: Renderer.CLEAR_COLOR | Renderer.CLEAR_DEPTH,
        rgba: 0x303030ff,
        depth: 1.0,
        stencil: 0)


    // Create vertex stream declaration.
    let cubeVertices_decl = UnsafeMutablePointer<bgfx_vertex_decl_t>.alloc(1)

    bgfx_vertex_decl_begin(cubeVertices_decl, RENDERER_TYPE)
    bgfx_vertex_decl_add(cubeVertices_decl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
    bgfx_vertex_decl_add(cubeVertices_decl, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, true, false)
    bgfx_vertex_decl_end(cubeVertices_decl)

    // Create static vertex buffer.
    // Static data can be passed with bgfx::makeRef
    vbh = bgfx_create_vertex_buffer(bgfx_make_ref(&cubeVertices, UInt32(cubeVertices.count*sizeof(PosColorVertex))),
        cubeVertices_decl, UInt16(0))

    cubeVertices_decl.destroy()

    // Create static index buffer.
    // Static data can be passed with bgfx::makeRef
    ibh = bgfx_create_index_buffer(bgfx_make_ref(&cubeIndices, UInt32(cubeIndices.count*sizeof(UInt16))), UInt16(0))

    // load shaders
    program = bgfx_utils_loadProgram("vs_cubes", fsName: "fs_cubes")

    startTime = CFAbsoluteTimeGetCurrent()

}

func draw() {

    let now:Double = CFAbsoluteTimeGetCurrent()
    let time = Float(now - startTime)

    // -- FRAME

    let at:[Float] = [ 0.0, 0.0, 0.0 ]
    let eye:[Float] = [ 0.0, 0.0, -35.0 ]

    // -- skip HMD stuff

    var view = mtxLookAt(at, eye: eye)
    var proj = mtxProj(60.0, aspect: Float(WINDOW_WIDTH)/Float(WINDOW_HEIGHT), near: 0.1, far: 100.0)

    bgfx_set_view_transform(UInt8(0), &view, &proj)

    // Set view 0 default viewport.
    bgfx_set_view_rect(UInt8(0), UInt16(0), UInt16(0), UInt16(WINDOW_WIDTH), UInt16(WINDOW_HEIGHT))

    // This dummy draw call is here to make sure that view 0 is cleared
    // if no other draw calls are submitted to view 0.
    bgfx_submit(UInt8(0), Int32(0))

    for yy in 0...10 {
        for xx in 0...10 {
            var mtx = mtxRotateXY( time + Float(xx)*Float(0.21), ay: time + Float(yy)*Float(0.37) )

            // translate
            mtx[12] = -15.0 + Float(xx)*3.0;
            mtx[13] = -15.0 + Float(yy)*3.0;
            mtx[14] = 0.0;

            // Set model matrix for rendering.
            bgfx_set_transform(&mtx, UInt16(mtx.count))

            // Set vertex and fragment shaders.
            bgfx_set_program(program!)

            // Set vertex and index buffer.
            bgfx_set_vertex_buffer(vbh!, UInt32(0), UInt32(cubeVertices.count))

            bgfx_set_index_buffer(ibh!, UInt32(0), UInt32(cubeIndices.count))

            // Set render states.
            bgfx_set_state(BGFX_STATE_DEFAULT, 0xffffffff)

            // Submit primitive for rendering to view 0.
            bgfx_submit(UInt8(0), Int32(0))
        }
    }

    // -- FRAME end

    // Advance to next frame. Rendering thread will be kicked to
    // process submitted rendering primitives.
    bgfx_frame()
}

func shutdown() {
    print("-------------- SHUTDOWN");

    bgfx_destroy_index_buffer(ibh!)
    bgfx_destroy_vertex_buffer(vbh!)
    bgfx_destroy_program(program!)

}
